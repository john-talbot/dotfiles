import argparse
import logging
import platform
import sys
import tarfile
from pathlib import Path

from python_bootstrap import utilities
from python_bootstrap.utilities import OS

_VERSION = "v5.26.0"
_BASE_URL = f"https://github.com/latex-lsp/texlab/releases/download/{_VERSION}/texlab-"

_ARCH_MAP = {"x86_64": "x86_64", "aarch64": "aarch64", "armv7l": "armv7hf"}

_INSTALL_PATH = Path.home().joinpath(".local/bin/texlab")

_TMP_NAME = "texlab"
_LOG_NAME = "install_texlab.log"


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Install the texlab LaTeX language server"
    )
    parser.add_argument(
        "--temp",
        type=Path,
        help="The temporary directory to use for the script.",
    )
    parser.add_argument(
        "--log",
        type=Path,
        help="The directory to store the log files.",
    )
    args = parser.parse_args()

    temp_dir = args.temp
    log_dir = args.log

    logger = utilities.setup_logging("texlab_logger", log_dir.joinpath(_LOG_NAME))
    os_type = utilities.get_os_type()

    if os_type == OS.UNSUPPORTED:
        logger.error("This script is not supported on this operating system.")
        sys.exit(1)

    install(os_type, temp_dir.joinpath(_TMP_NAME), logger)


def install(os_type: OS, temp_dir: Path, logger: logging.Logger) -> None:
    logger.info("Installing texlab.")

    if os_type == OS.LINUX_x64 or os_type == OS.LINUX_arm64:
        _install_linux(temp_dir, logger)
    elif os_type == OS.MACOS_arm64:
        _install_macos(logger)
    else:
        logger.error("Unsupported OS type.")
        return

    logger.info("Finished installing texlab.")


def _install_linux(temp_dir: Path, logger: logging.Logger) -> None:
    logger.debug("Downloading texlab.")
    temp_dir.mkdir(parents=True, exist_ok=True)
    down_path = temp_dir.joinpath("texlab.tar.gz")

    url = f"{_BASE_URL}{_ARCH_MAP[platform.machine()]}-linux.tar.gz"

    utilities.download_archive(url, down_path, logger)

    logger.debug("Extracting texlab.")
    with tarfile.open(down_path) as tar:
        binary = tar.extractfile("texlab")
        if binary is None:
            raise FileNotFoundError("texlab binary not found in the release archive")
        data = binary.read()

    logger.debug("Writing texlab to install location.")
    _INSTALL_PATH.parent.mkdir(parents=True, exist_ok=True)
    _INSTALL_PATH.write_bytes(data)
    _INSTALL_PATH.chmod(0o755)


def _install_macos(logger: logging.Logger) -> None:
    logger.debug("Installing texlab via brew.")
    try:
        utilities.run_cmd(["brew", "install", "texlab"], False, logger)
    except FileNotFoundError:
        logger.error("Homebrew is not installed.")


if __name__ == "__main__":
    main()
