import logging
import subprocess
import sys
from pathlib import Path


def run_cmd(cmd: list[str], use_sudo: bool, logger: logging.Logger) -> None:
    """
    Run a shell command and log its output.

    Parameters
    ----------
    cmd : list[str]
        The command to run, as a list of strings.
    use_sudo : bool
        Whether to use sudo to run the command.
    logger : logging.Logger
        The logger to use for logging output.

    """
    cmd = [str(item) if isinstance(item, Path) else item for item in cmd]
    logger.debug(f"Running command: {' '.join(cmd)}")

    if use_sudo:
        cmd = ["sudo"] + cmd

    try:
        result = subprocess.run(
            cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, check=True, text=True
        )

    except subprocess.CalledProcessError as e:
        logger.error(f"Command {' '.join(cmd)} failed with exit code {e.returncode}")
        logger.error(e.output)
        sys.exit(e.returncode)

    if result.stdout:
        logger.debug(result.stdout)
    logger.debug(f"Command {' '.join(cmd)} completed successfully.")
