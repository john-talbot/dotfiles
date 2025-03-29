import logging
import shutil
import sys
from pathlib import Path

from python_bootstrap.utilities import OS

from python_bootstrap import utilities

_GIT_URL = "https://github.com/junegunn/fzf.git"
_CMD_STRINGS = ["--bin", "--no-key-bindings", "--no-completion", "--no-update-rc"]

_MY_DIR = Path(__file__).parent.resolve()
_TMP_DIR = _MY_DIR.joinpath("tmp")
_LOG_PATH = _MY_DIR.joinpath("bootstrap.log")


def main() -> None:
    logger = utilities.setup_logging("neovim_logger", _LOG_PATH)
    os_type = utilities.get_os_type()

    if os_type == OS.UNSUPPORTED:
        logger.error("This script is not supported on this operating system.")
        sys.exit(1)

    _TMP_DIR.mkdir(exist_ok=True)

    install(_TMP_DIR, logger)

    shutil.rmtree(_TMP_DIR)
    sys.exit(0)


def install(tmp_dir: Path, logger: logging.Logger) -> None:
    logger.info("Installing fzf.")

    down_path = tmp_dir.joinpath("fzf")
    down_path.mkdir(exist_ok=True)

    extra_args = ["--depth", "1"]
    utilities.run_cmd(
        ["git", "clone"] + extra_args + [_GIT_URL, down_path.name],
        False,
        logger,
        cwd=tmp_dir,
    )

    out_path = tmp_dir.joinpath("fzf_install")
    utilities.run_cmd(
        ["unzip", "-u", "-q", "-j", down_path, "-d", out_path], False, logger
    )
    utilities.run_cmd(["./install"] + _CMD_STRINGS, False, logger, cwd=out_path)

    logger.info("Finished installing fzf.")
