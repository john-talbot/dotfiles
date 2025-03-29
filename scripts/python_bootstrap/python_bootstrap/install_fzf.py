import logging
from pathlib import Path

from python_bootstrap import utilities

_BASE_URL = "https://github.com/junegunn/fzf.git"
_CMD_STRINGS = ["--bin", "--no-key-bindings", "--no-completion", "--no-update-rc"]


def install(file_path: Path, logger: logging.Logger) -> None:
    logger.info("Installing fzf.")

    out_path = file_path.parent.joinpath("fzf_install")
    utilities.run_cmd(
        ["unzip", "-u", "-q", "-j", file_path, "-d", out_path], False, logger
    )
    utilities.run_cmd(["./install"] + _CMD_STRINGS, False, logger)

    logger.info("Finished installing fzf.")


def download_git_repo(logger: logging.Logger) -> None:
    logger.info("Downloading fzf git repository.")

    utilities.run_cmd(
        ["git", "clone", "--depth", "1", "-b", "nightly", _BASE_URL], False, logger
    )

    logger.info("Finished downloading fzf git repository.")
