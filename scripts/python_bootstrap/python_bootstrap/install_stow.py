import argparse
import logging
import os
import sys
from pathlib import Path

from python_bootstrap import utilities
from python_bootstrap.utilities import OS

_URL = "https://ftp.gnu.org/gnu/stow/stow-latest.tar.gz"

_INSTALL_DIR = Path.home().joinpath(".local")

_TMP_NAME = "stow"
_LOG_NAME = "install_stow.log"


def main() -> None:
    parser = argparse.ArgumentParser(description="Install node from source")
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

    logger = utilities.setup_logging("stow_logger", log_dir.joinpath(_LOG_NAME))
    os_type = utilities.get_os_type()

    if os_type == OS.UNSUPPORTED:
        logger.error("This script is not supported on this operating system.")
        sys.exit(1)

    install(os_type, temp_dir.joinpath(_TMP_NAME), logger)


def install(os_type: OS, temp_dir: Path, logger: logging.Logger) -> None:
    logger.info("Installing stow.")

    if os_type == OS.LINUX_x64 or os_type == OS.LINUX_arm64:
        _install_linux(temp_dir, logger)
    elif os_type == OS.MACOS_arm64:
        _install_macos(logger)
    else:
        logger.error("Unsupported OS type.")
        return

    logger.info("Finished installing stow.")


def _install_macos(logger: logging.Logger) -> None:
    logger.debug("Installing stow via brew.")
    try:
        utilities.run_cmd(["brew", "install", "stow"], False, logger)
    except FileNotFoundError:
        logger.error("Homebrew is not installed.")
        return


def _install_linux(temp_dir: Path, logger: logging.Logger) -> None:
    logger.debug("Downloading stow.")
    down_path = temp_dir.joinpath("stow.tar.gz")
    utilities.download_archive(_URL, down_path, logger)

    logger.debug("Extracting stow.")
    out_path = temp_dir.joinpath("stow_install")
    out_path.mkdir(exist_ok=True)
    utilities.run_cmd(
        ["tar", "-C", f"{out_path}", "--strip-components=1", "-xzf", down_path],
        False,
        logger,
    )

    logger.debug("Building and installing stow.")
    utilities.run_cmd(
        ["./configure", f"--prefix={_INSTALL_DIR}"], False, logger, cwd=out_path
    )
    utilities.run_cmd(["make", f"-j{os.cpu_count()}"], False, logger, cwd=out_path)
    utilities.run_cmd(["make", "install"], False, logger, cwd=out_path)
