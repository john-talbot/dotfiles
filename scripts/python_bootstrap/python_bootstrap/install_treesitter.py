import argparse
import logging
import sys
from pathlib import Path

from python_bootstrap import utilities
from python_bootstrap.utilities import OS

_TMP_NAME = "node"
_LOG_NAME = "install_node.log"

_VERSION = "0.25.10"


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

    logger = utilities.setup_logging("treesitter_logger", log_dir.joinpath(_LOG_NAME))
    os_type = utilities.get_os_type()

    if os_type == OS.UNSUPPORTED:
        logger.error("This script is not supported on this operating system.")
        sys.exit(1)

    install(os_type, temp_dir.joinpath(_TMP_NAME), logger)


def install(os_type: OS, temp_dir: Path, logger: logging.Logger) -> None:
    logger.info("Installing treesitter.")

    if os_type == OS.LINUX_x64 or os_type == OS.LINUX_arm64:
        _install_linux(temp_dir, logger)
    elif os_type == OS.MACOS_arm64:
        _install_macos(logger)
    else:
        logger.error("Unsupported OS type.")
        return

    logger.info("Finished installing treesitter.")


def _install_linux(logger: logging.Logger) -> None:
    logger.debug("Installing treesitter via npm.")
    try:
        utilities.run_cmd(
            ["npm", "install", "-g", f"tree-sitter-cli@{_VERSION}"], False, logger
        )
    except FileNotFoundError:
        logger.error("npm is not installed.")


def _install_macos(logger: logging.Logger) -> None:
    logger.debug("Installing treesitter via brew.")
    try:
        utilities.run_cmd(["brew", "install", "tree-sitter"], False, logger)
    except FileNotFoundError:
        logger.error("Homebrew is not installed.")
