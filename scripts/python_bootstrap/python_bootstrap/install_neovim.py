import logging
import shutil
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

_MY_DIR = Path(__file__).parent.resolve()
_TMP_DIR = _MY_DIR.joinpath("tmp")
_LOG_PATH = _MY_DIR.joinpath("bootstrap.log")


def main() -> None:
    logger = utilities.setup_logging("neovim_logger", _LOG_PATH)
    os_type = utilities.get_os_type()

    if os_type == OS.UNSUPPORTED:
        logger.error("This script is not supported on this operating system.")
        sys.exit(1)

    use_sudo = utilities.get_use_sudo(logger)
    _TMP_DIR.mkdir(exist_ok=True)

    install(os_type, _TMP_DIR, use_sudo, logger)

    shutil.rmtree(_TMP_DIR)
    sys.exit(0)


def install(
    os_type: OS, temp_dir: Path, use_sudo: bool, logger: logging.Logger
) -> None:
    logger.info("Installing neovim.")

    # Remove any existing neovim installation
    utilities.run_cmd(["rm", "-rf", "/opt/neovim"], use_sudo, logger)

    if os_type == OS.RASPIOS:
        install_neovim_from_source(temp_dir, use_sudo, logger)
    elif os_type == OS.LINUX:
        install_neovim_linux(temp_dir, use_sudo, logger)
    elif os_type == OS.MACOS:
        install_neovim_macos(temp_dir, use_sudo, logger)

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
    temp_dir: Path, use_sudo: bool, logger: logging.Logger
) -> None:
    logger.debug("Installing neovim from source.")

    down_path = temp_dir.joinpath("fzf")

    logger.debug("Cloning neovim repository.")
    extra_args = ["--depth", "1", "-b", "nightly"]
    utilities.run_cmd(
        ["git", "clone"] + extra_args + [_GIT_URL, down_path.name],
        False,
        logger,
        cwd=temp_dir,
    )

    logger.debug("Building neovim.")

    utilities.run_cmd(["make"] + _CMAKE_BUILD_ARGS, False, logger, cwd=down_path)
    utilities.run_cmd(
        ["make"] + _CMAKE_BUILD_ARGS + ["install"], use_sudo, logger, cwd=down_path
    )
    utilities.run_cmd(
        ["rm", "-rf", ".local/share/nvim", ".local/state/nvim"],
        False,
        logger,
        cwd=Path.home(),
    )

    logger.debug("Finished building neovim.")


def install_neovim_linux(
    temp_dir: Path, use_sudo: bool, logger: logging.Logger
) -> None:
    logger.debug("Installing neovim for linux.")
    down_path = temp_dir.joinpath("neovim.tar.gz")
    utilities.download_archive(_LINUX_URL, down_path, logger, name="neovim")
    install_neovim_from_build(down_path, use_sudo, logger)


def install_neovim_macos(temp_dir: Path, use_sudo: bool, logger: logging.Logger):
    logger.debug("Installing neovim for macos.")
    down_path = temp_dir.joinpath("neovim.tar.gz")
    utilities.download_archive(_MACOS_URL, down_path, logger, name="neovim")
    install_neovim_from_build(down_path, use_sudo, logger)


def install_neovim_from_build(
    down_path: Path, use_sudo: bool, logger: logging.Logger
) -> None:
    utilities.run_cmd(["xattr", "-c", down_path], False, logger)
    utilities.run_cmd(["tar", "-C", "/opt", "-xf", down_path], use_sudo, logger)
    utilities.run_cmd(["mv", f"/opt/{down_path.stem}", "/opt/neovim"], use_sudo, logger)


if __name__ == "__main__":
    main()
