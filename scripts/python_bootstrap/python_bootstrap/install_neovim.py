import argparse
import logging
import sys
from pathlib import Path

from python_bootstrap import utilities
from python_bootstrap.utilities import OS

_URLS = {
    OS.LINUX_x64: "https://github.com/neovim/neovim/releases/download/v0.11.0/nvim-linux-x86_64.tar.gz",  # noqa: E501
    OS.LINUX_arm64: "https://github.com/neovim/neovim/releases/download/v0.11.0/nvim-linux-arm64.tar.gz",  # noqa: E501
}

_SCRIPT_DIR = utilities.get_git_root().joinpath("scripts")
_INSTALL_DIR = Path("/opt/neovim")

_TMP_NAME = "neovim"
_LOG_NAME = "install_neovim.log"


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

    logger = utilities.setup_logging("neovim_logger", log_dir.joinpath(_LOG_NAME))
    os_type = utilities.get_os_type()
    use_sudo = utilities.get_use_sudo(logger)

    if os_type == OS.UNSUPPORTED:
        logger.error("This script is not supported on this operating system.")
        sys.exit(1)

    install(os_type, temp_dir.joinpath(_TMP_NAME), use_sudo, logger)


def install(os_type: OS, temp_dir: Path, use_sudo: bool, logger: logging.Logger):
    logger.info("Installing neovim.")

    if os_type == OS.LINUX_x64 or os_type == OS.LINUX_arm64:
        _install_linux(os_type, temp_dir, use_sudo, logger)
    elif os_type == OS.MACOS_arm64:
        _install_macos(logger)
    else:
        logger.error("Unsupported OS type.")
        return

    logger.info("Installing neovim python packages.")
    _install_python_packages(use_sudo, logger)
    logger.info("Finished installing neovim.")


def _install_macos(logger: logging.Logger) -> None:
    logger.debug("Installing neovim via brew.")
    try:
        utilities.run_cmd(["brew", "install", "neovim"], False, logger)
    except FileNotFoundError:
        logger.error("Homebrew is not installed.")
        return


def _install_linux(
    os_type: OS, temp_dir: Path, use_sudo: bool, logger: logging.Logger
) -> None:

    # Remove any existing neovim installation
    utilities.run_cmd(["rm", "-rf", "/opt/neovim"], use_sudo, logger)

    down_path = temp_dir.joinpath("neovim.tar.gz")
    utilities.download_archive(_URLS[os_type], down_path, logger, name="neovim")
    utilities.run_cmd(["mkdir", "-p", str(_INSTALL_DIR)], use_sudo, logger)
    utilities.run_cmd(
        ["tar", "-C", str(_INSTALL_DIR), "--strip-components=1", "-xf", down_path],
        use_sudo,
        logger,
    )


def _install_python_packages(use_sudo: bool, logger: logging.Logger) -> None:
    logger.debug("Installing python neovim packages in system environment.")
    utilities.run_cmd(
        ["/usr/bin/python3", "-m", "pip", "install", "neovim", "neovim-remote"],
        use_sudo,
        logger,
    )
