import pathlib
import re
import shutil
import subprocess
import tempfile

import modal


# One worker is intentionally large enough for the LLVM/MLIR link while
# remaining CPU-only.
CPU_CORES = 32.0
MEMORY_MIB = 128 * 1024
EPHEMERAL_DISK_MIB = 1024 * 1024

cache_volume = modal.Volume.from_name("mlir-lsp-bazel-cache", create_if_missing=True)

build_image = (
    modal.Image.from_registry("ubuntu:24.04", add_python="3.11")
    .apt_install(
        "build-essential",
        "ca-certificates",
        "curl",
        "file",
        "git",
        "unzip",
        "zip",
    )
    .run_commands(
        "curl -fsSL https://github.com/bazelbuild/bazelisk/releases/download/v1.29.0/bazelisk-linux-amd64 -o /usr/local/bin/bazelisk",
        "chmod 0755 /usr/local/bin/bazelisk",
    )
    # Source is mounted after the cached dependency image has been built.
    .add_local_dir(
        ".",
        remote_path="/src",
        ignore=[".git", ".git/**", "bazel-*", "dist", "dist/**"],
    )
)

app = modal.App("mlir-lsp-linux-release")


def run(command: list[str], cwd: pathlib.Path) -> None:
    print("+", " ".join(command), flush=True)
    subprocess.run(command, cwd=cwd, check=True)


@app.function(
    image=build_image,
    cpu=CPU_CORES,
    memory=MEMORY_MIB,
    ephemeral_disk=EPHEMERAL_DISK_MIB,
    timeout=6 * 60 * 60,
    volumes={"/cache": cache_volume},
)
def build_linux(source_commit: str, run_id: str) -> list[str]:
    if not re.fullmatch(r"[0-9a-f]{40}([0-9a-f]{24})?", source_commit):
        raise ValueError("source_commit must be a full Git commit hash")
    if not re.fullmatch(r"[A-Za-z0-9._-]+", run_id):
        raise ValueError("run_id contains unsupported characters")

    with tempfile.TemporaryDirectory(prefix="mlir-lsp-build-") as temp:
        temp_path = pathlib.Path(temp)
        source = temp_path / "source"
        dist = temp_path / "dist"
        extract = temp_path / "extract"
        shutil.copytree("/src", source, symlinks=True)

        run(["bazelisk", "build", "--config=modal", "//:mlir-lsp"], source)

        binary = source / "bazel-bin/mlir-lsp"
        run([str(binary), "--help"], source)
        dependencies = subprocess.check_output(["ldd", binary], text=True)
        print(dependencies, flush=True)
        if "not found" in dependencies:
            raise RuntimeError("release binary has unresolved runtime dependencies")

        run(
            [
                "./scripts/package-release.sh",
                "linux-x86_64",
                str(binary),
                source_commit,
                str(dist),
            ],
            source,
        )

        archive = "mlir-lsp-linux-x86_64.tar.gz"
        run(["sha256sum", "--check", f"{archive}.sha256"], dist)
        extract.mkdir()
        run(["tar", "-xzf", archive, "-C", str(extract)], dist)
        run([str(extract / "mlir-lsp-linux-x86_64/mlir-lsp"), "--help"], source)

        result_dir = pathlib.Path("/cache/results") / run_id
        result_dir.mkdir(parents=True, exist_ok=False)
        names = [archive, f"{archive}.sha256"]
        for name in names:
            shutil.copy2(dist / name, result_dir / name)
        cache_volume.commit()

    return [f"results/{run_id}/{name}" for name in names]


@app.local_entrypoint()
def main(source_commit: str, run_id: str, output_dir: str = "dist") -> None:
    remote_paths = build_linux.remote(source_commit, run_id)
    destination = pathlib.Path(output_dir)
    destination.mkdir(parents=True, exist_ok=True)

    try:
        for remote_path in remote_paths:
            local_path = destination / pathlib.Path(remote_path).name
            with local_path.open("wb") as output:
                for chunk in cache_volume.read_file(remote_path):
                    output.write(chunk)
            print(f"Downloaded {local_path}")
    finally:
        cache_volume.remove_file(f"results/{run_id}", recursive=True)
