import argparse
import logging
import platform
import sys
from pathlib import Path

from python_bootstrap import utilities
from python_bootstrap.utilities import OS

_VERSION = "2026-02-08"
_BASE_URL = (
    f"https://github.com/artempyanykh/marksman/releases/download/{_VERSION}/marksman-"
)

_ARCH_MAP = {"x86_64": "x64", "aarch64": "arm64"}

_INSTALL_PATH = Path.home().joinpath(".local/bin/marksman")

_TMP_NAME = "marksman"
_LOG_NAME = "install_marksman.log"


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Install the marksman Markdown language server"
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

    logger = utilities.setup_logging("marksman_logger", log_dir.joinpath(_LOG_NAME))
    os_type = utilities.get_os_type()

    if os_type == OS.UNSUPPORTED:
        logger.error("This script is not supported on this operating system.")
        sys.exit(1)

    install(os_type, temp_dir.joinpath(_TMP_NAME), logger)


def install(os_type: OS, temp_dir: Path, logger: logging.Logger) -> None:
    logger.info("Installing marksman.")

    if os_type == OS.LINUX_x64 or os_type == OS.LINUX_arm64:
        _install_linux(temp_dir, logger)
    elif os_type == OS.MACOS_arm64:
        _install_macos(logger)
    else:
        logger.error("Unsupported OS type.")
        return

    logger.info("Finished installing marksman.")


def _install_linux(temp_dir: Path, logger: logging.Logger) -> None:
    # Released as a bare self-contained binary, so there is nothing to extract
    logger.debug("Downloading marksman.")
    temp_dir.mkdir(parents=True, exist_ok=True)
    down_path = temp_dir.joinpath("marksman")

    url = f"{_BASE_URL}linux-{_ARCH_MAP[platform.machine()]}"

    utilities.download_archive(url, down_path, logger, name="marksman")

    logger.debug("Writing marksman to install location.")
    _INSTALL_PATH.parent.mkdir(parents=True, exist_ok=True)
    _INSTALL_PATH.write_bytes(down_path.read_bytes())
    _INSTALL_PATH.chmod(0o755)


def _install_macos(logger: logging.Logger) -> None:
    logger.debug("Installing marksman via brew.")
    try:
        utilities.run_cmd(["brew", "install", "marksman"], False, logger)
    except FileNotFoundError:
        logger.error("Homebrew is not installed.")


if __name__ == "__main__":
    main()
