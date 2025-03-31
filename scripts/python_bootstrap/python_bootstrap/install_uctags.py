import argparse
import logging
import os
import sys
from pathlib import Path

from python_bootstrap import utilities
from python_bootstrap.utilities import OS

_URL = "https://api.github.com/repos/universal-ctags/ctags/releases/latest"

_INSTALL_DIR = Path.home().joinpath(".local")

_TMP_NAME = "uctags"
_LOG_NAME = "install_uctags.log"


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

    logger = utilities.setup_logging("uctags_logger", log_dir.joinpath(_LOG_NAME))
    os_type = utilities.get_os_type()

    if os_type == OS.UNSUPPORTED:
        logger.error("This script is not supported on this operating system.")
        sys.exit(1)

    install(os_type, temp_dir.joinpath(_TMP_NAME), logger)


def install(os_type: OS, temp_dir: Path, logger: logging.Logger) -> None:
    logger.info("Installing uctags.")

    if os_type == OS.LINUX_x64 or os_type == OS.LINUX_arm64:
        _install_linux(temp_dir, logger)
    elif os_type == OS.MACOS_arm64:
        _install_macos(logger)
    else:
        logger.error("Unsupported OS type.")
        return

    logger.info("Finished installing uctags.")


def _install_linux(temp_dir: Path, logger: logging.Logger) -> None:
    logger.info("Downloading uctags source file.")

    down_path = temp_dir.joinpath("uctags.tar.gz")
    out_path = temp_dir.joinpath("uctags")

    tar_url = utilities.get_github_tarball_url(_URL)
    logger.debug(f"Downloading uctags tarball from {tar_url}.")

    utilities.download_archive(tar_url, down_path, logger, "uctags")
    utilities.run_cmd(["mkdir", "-p", str(out_path)], False, logger)
    utilities.run_cmd(
        ["tar", "-C", str(out_path), "--strip-components=1", "-xf", down_path],
        False,
        logger,
    )

    logger.info("Configuring uctags for build.")
    utilities.run_cmd(["./autogen.sh"], False, logger, cwd=out_path)
    utilities.run_cmd(
        ["./configure", f"--prefix={_INSTALL_DIR}"], False, logger, cwd=out_path
    )

    logger.info("Building and installing uctags from source.")
    utilities.run_cmd(["make", f"-j{os.cpu_count()}"], False, logger, cwd=out_path)
    utilities.run_cmd(["make", "install"], False, logger, cwd=out_path)


def _install_macos(logger: logging.Logger) -> None:
    logger.debug("Installing universal-ctags via brew.")
    try:
        utilities.run_cmd(["brew", "install", "universal-ctags"], False, logger)
    except FileNotFoundError:
        logger.error("Homebrew is not installed.")
