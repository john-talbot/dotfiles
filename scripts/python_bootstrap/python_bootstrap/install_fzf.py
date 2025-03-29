import logging
from pathlib import Path

from python_bootstrap import cmd_with_logs

_BASE_URL = "https://github.com/junegunn/fzf/archive/refs/heads/master.zip"
_CMD_STRINGS = ["--bin", "--no-key-bindings", "--no-completion", "--no-update-rc"]


def get_download_url() -> str:
    return _BASE_URL


def install(file_path: Path, logger: logging.Logger) -> None:
    logger.info("Installing fzf.")

    cmd_with_logs.run_cmd(["unzip", file_path], False, logger)
    cmd_with_logs.run_cmd(["./install"] + _CMD_STRINGS, False, logger)

    logger.info("Finished installing fzf.")
