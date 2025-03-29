import logging
import sys
from pathlib import Path

from python_bootstrap.utilities import OS

from python_bootstrap import utilities

_LINUX_URL = "https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.tar.gz"  # noqa E501
_MACOS_URL = "https://github.com/neovim/neovim/releases/download/nightly/nvim-macos.tar.gz"  # noqa E501
_GIT_URL = "https://github.com/neovim/neovim.git"
_CMAKE_BUILD_ARGS = [
    "CMAKE_BUILD_TYPE=Release",
    "CMAKE_INSTALL_PREFIX=/opt/neovim",
]


def install(os_type: OS, tmp_dir: Path, use_sudo: bool, logger: logging.Logger) -> None:
    logger.info("Installing neovim.")

    # Remove any existing neovim installation
    utilities.run_cmd(["rm", "-rf", "/opt/neovim"], use_sudo, logger)
    dwn_dir = tmp_dir.joinpath("neovim")

    if os_type == OS.RASPIOS:
        logging.debug("Installing neovim from source.")
        install_neovim_from_source(dwn_dir, use_sudo, logger)

    elif os_type == OS.LINUX:
        logging.debug(f"Installing neovim from {dwn_dir}.")
        install_neovim_linux(dwn_dir, use_sudo, logger)

    elif os_type == OS.MACOS:
        logging.debug(f"Installing neovim from {dwn_dir}.")
        install_neovim_macos(dwn_dir, use_sudo, logger)

    py_path = sys.executable

    logger.debug(f"Installing python neovim packages in environment {py_path}.")
    need_root = py_path.startswith("/usr")

    if need_root:
        logger.debug("Installing packages in a system environment using sudo.")

    utilities.run_cmd(
        [str(py_path), "-m", "pip", "install", "neovim", "neovim-remote"],
        need_root,
        logger,
    )

    logger.info("Finished installing neovim.")


def install_neovim_from_source(
    dwn_dir: Path, use_sudo: bool, logger: logging.Logger
) -> None:
    logger.debug("Installing neovim from source.")

    extra_args = ["--depth", "1", "-b", "nightly"]
    logger.debug("Cloning neovim repository.")
    dwn_dir.mkdir(exist_ok=True)
    utilities.run_cmd(
        ["git", "clone"] + extra_args + [_GIT_URL, dwn_dir], False, logger, cwd=dwn_dir
    )
    logger.debug("Building neovim.")
    utilities.run_cmd(["make"] + _CMAKE_BUILD_ARGS, False, logger, cwd=dwn_dir)
    utilities.run_cmd(
        ["make"] + _CMAKE_BUILD_ARGS + ["install"], use_sudo, logger, cwd=dwn_dir
    )
    utilities.run_cmd(
        ["rm", "-rf", ".local/share/nvim", ".local/state/nvim"],
        False,
        logger,
        cwd=Path.home(),
    )
    logger.debug("Finished building neovim.")


def install_neovim_linux(dwn_dir: Path, use_sudo: bool, logger: logging.Logger) -> None:
    logger.debug("Installing neovim for linux.")
    utilities.download_archive(_LINUX_URL, dwn_dir, logger, name="neovim")
    install_neovim_from_build(dwn_dir, use_sudo, logger)


def install_neovim_macos(dwn_dir: Path, use_sudo: bool, logger: logging.Logger):
    logger.debug("Installing neovim for macos.")
    utilities.download_archive(_MACOS_URL, dwn_dir, logger, name="neovim")
    install_neovim_from_build(dwn_dir, use_sudo, logger)


def install_neovim_from_build(
    dwn_dir: Path, use_sudo: bool, logger: logging.Logger
) -> None:
    utilities.run_cmd(["xattr", "-c", dwn_dir], False, logger)
    utilities.run_cmd(["tar", "-C", "/opt", "-xf", dwn_dir], use_sudo, logger)
    utilities.run_cmd(["mv", f"/opt/{dwn_dir.stem}", "/opt/neovim"], use_sudo, logger)
