import logging
from pathlib import Path

from python_bootstrap.defines import OS

from python_bootstrap import cmd_with_logs

_CMAKE_BUILD_ARGS = [
    "CMAKE_BUILD_TYPE=Release",
    "CMAKE_INSTALL_PREFIX=/opt/neovim",
]


_DOWNLOAD_URLS = {
    OS.LINUX: "https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.tar.gz",  # noqa E501
    OS.MACOS: "https://github.com/neovim/neovim/releases/download/nightly/nvim-macos.tar.gz",  # noqa E501
    OS.RASPIOS: "https://github.com/neovim/neovim/archive/refs/heads/master.zip",
}


def get_download_url(os_type: OS) -> str:
    return _DOWNLOAD_URLS[os_type]


def install(
    file_path: Path, venv_py_path: Path, use_sudo: bool, logger: logging.Logger
) -> None:
    logger.info("Installing neovim.")

    # Remove any existing neovim installation
    cmd_with_logs.run_cmd(["rm", "-rf", "/opt/neovim"], use_sudo, logger)

    if file_path.suffix == ".zip":
        logging.debug("Installing neovim from source.")
        install_neovim_from_source(file_path, use_sudo, logger)
    elif file_path.suffix == ".tar.gz":
        logging.debug(f"Installing neovim from {file_path}.")
        install_neovim_from_build(file_path, use_sudo, logger)
    else:
        logger.error(
            f"Unrecognized file type {file_path.suffix}. Skipping neovim installation."
        )
        return

    if venv_py_path:
        logger.debug(
            f"Installing python neovim packages in virtual environment {venv_py_path}."
        )
        need_root = venv_py_path.startswith("/usr")

        if need_root:
            logger.debug(
                "Installing packages in a system environment. "
                "This will be run with sudo."
            )

        cmd_with_logs.run_cmd(
            [str(venv_py_path), "-m", "pip", "install", "neovim", "neovim-remote"],
            need_root,
            logger,
        )

    logger.info("Finished installing neovim.")


def install_neovim_from_source(
    path_to_zip: Path, use_sudo: bool, logger: logging.Logger
) -> None:
    logger.debug("Installing neovim from source.")

    cmd_with_logs.run_cmd(["unzip", path_to_zip], use_sudo, logger)
    cmd_with_logs.run_cmd(
        ["make"] + _CMAKE_BUILD_ARGS,
        False,
        logger,
        cwd=path_to_zip.parent.joinpath(f"{path_to_zip.stem}"),
    )
    cmd_with_logs.run_cmd(
        ["make"] + _CMAKE_BUILD_ARGS + ["install"],
        use_sudo,
        logger,
        cwd=path_to_zip.parent.joinpath(f"{path_to_zip.stem}"),
    )
    cmd_with_logs.run_cmd(
        ["rm", "-rf", ".local/share/nvim", ".local/state/nvim"],
        use_sudo,
        logger,
        cwd=Path.home(),
    )


def install_neovim_from_build(
    path_to_tar: Path, use_sudo: bool, logger: logging.Logger
) -> None:
    logger.debug(f"Installing neovim from {path_to_tar}.")

    cmd_with_logs.run_cmd(["xattr", "-c", path_to_tar], use_sudo, logger)
    cmd_with_logs.run_cmd(["tar", "-C", "/opt", "-xf", path_to_tar], use_sudo, logger)
    cmd_with_logs.run_cmd(
        ["mv", f"/opt/{path_to_tar.stem}", "/opt/neovim"], use_sudo, logger
    )
