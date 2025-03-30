#!/usr/bin/env python3

import argparse
import platform
import sys
from pathlib import Path

from python_bootstrap import (
    install_node,
    install_omz,
    install_python_essentials,
    linux_bootstrap,
    utilities,
)
from python_bootstrap.utilities import OS

GIT_ROOT = utilities.get_git_root()
PROC_PATH = Path("/proc/cpuinfo")


def main(timezone: str, temp_dir: Path, log_dir: Path) -> None:
    logger = utilities.setup_logging("bootstrap_logger", log_dir)
    use_sudo = utilities.get_use_sudo(logger)
    os_type = utilities.get_os_type()

    if os_type == OS.LINUX_x64 or os_type == OS.LINUX_arm64:
        logger.info("Detected Linux. Proceeding with Linux-specific setup.")
        linux_bootstrap.bootstrap(os_type, temp_dir, timezone, use_sudo, logger)
    elif platform.system() == "Darwin":
        logger.info("Detected macOS. Proceeding with macOS-specific setup.")
    else:
        logger.error("This script is not supported on this operating system.")
        sys.exit(1)

    install_omz.install(temp_dir, logger)
    install_node.install(temp_dir, logger)
    install_python_essentials.install(logger)

    logger.info("Deploying dotfiles.")
    stow_cmd = Path.home().joinpath(".local/bin/stow")
    utilities.run_command(
        [str(stow_cmd), "-R", f"--target={str(Path.home())}", "--dotfiles", "."],
        False,
        logger,
        cwd=GIT_ROOT,
    )

    logger.info("Installing vim plugins.")
    vim_pkg_path = Path.home().joinpath(".vim/install_packages.vim")
    utilities.run_command(
        ["vim", "-E", "-s", "-u", "NONE", "-N", "-c", f"source {vim_pkg_path}"],
        False,
        logger,
    )
    nvim_pkg_path = Path.home().joinpath(".config/nvim/install_packages.vim")
    utilities.run_command(
        ["/opt/neovim/bin/nvim", "--headless", "-c", f"source {nvim_pkg_path}"],
        False,
        logger,
    )

    logger.info("Bootstrapping complete.")
    logger.info("Please restart your shell to apply changes.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Bootstrapping script to setup a fresh environment."
    )
    parser.add_argument(
        "--timezone",
        type=str,
        default="America/New_York",
        help="The timezone to set for the environment.",
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
    main(args.timezone, args.temp, args.log)
