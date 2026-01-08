import logging
import os
from pathlib import Path

from python_bootstrap import (
    install_fzf,
    install_neovim,
    install_stow,
    install_treesitter,
    install_uctags,
    utilities,
)
from python_bootstrap.utilities import OS

GIT_ROOT = utilities.get_git_root()
APT_FILE_PATH = GIT_ROOT.joinpath("scripts/conf/apt_packages.txt")

ZSH_PATH = "/usr/bin/zsh"
LOCALE_GEN_PATH = Path("/etc/locale.gen")
TIMEZONE_PATH = Path("/etc/timezone")

LOCALE = "en_US.UTF-8"
LANGUAGE = "en_US:en"


def bootstrap(
    os_type: OS,
    temp_dir: Path,
    timezone: str,
    use_sudo: bool,
    logger: logging.Logger,
) -> None:
    """
    Bootstrap the Linux environment.

    This script does a bunch that TODO:

    Parameters
    ----------
    logger : logging.Logger
        The logger to use for logging output.

    """
    os.environ["DEBIAN_FRONTEND"] = "noninteractive"

    set_timezone(timezone, use_sudo, logger)
    update_apt_packages(use_sudo, logger)
    install_apt_packages(use_sudo, logger)
    set_locale(LOCALE, LANGUAGE, use_sudo, logger)
    change_default_shell(ZSH_PATH, use_sudo, logger)

    # Install packages
    install_stow.install(os_type, temp_dir, logger)
    install_fzf.install(logger)
    install_neovim.install(os_type, temp_dir, use_sudo, logger)
    install_treesitter.install(os_type, temp_dir, logger)
    install_uctags.install(os_type, temp_dir, logger)

    # Cleanup downloads
    rebuild_font_cache(logger)


def set_timezone(timezone: str, use_sudo: bool, logger: logging.Logger) -> None:
    """
    Set the timezone for the environment.

    Parameters
    ----------
    logger : logging.Logger
        The logger to use for logging output.

    """
    utilities.run_cmd(["timedatectl", "set-timezone", timezone], use_sudo, logger)
    utilities.run_cmd(["echo", timezone, ">", str(TIMEZONE_PATH)], use_sudo, logger)

    logger.info(f"Timezone set to {timezone}.")


def update_apt_packages(use_sudo: bool, logger: logging.Logger) -> None:
    """
    Update the apt packages.

    Parameters
    ----------
    use_sudo : bool
        Should the command be run with sudo?
    logger : logging.Logger
        The logger to use for logging output.

    """
    logger.info("Updating apt packages.")
    utilities.run_cmd(["apt-get", "update"], use_sudo, logger)
    utilities.run_cmd(["apt-get", "upgrade", "-y"], use_sudo, logger)
    logger.info("Finished updating apt packages.")


def install_apt_packages(use_sudo: bool, logger: logging.Logger) -> None:
    """
    Install a list of apt packages.

    Parameters
    ----------
    use_sudo : bool
        Should the command be run with sudo?
    logger : logging.Logger
        The logger to use for logging output.

    """
    logger.info(f"Installing apt packages from file {APT_FILE_PATH.name}.")
    logger.debug(f"Full apt package file path: {APT_FILE_PATH}")

    packages = read_apt_packages_from_file(APT_FILE_PATH, logger)
    utilities.run_cmd(["apt-get", "install", "-y"] + packages, use_sudo, logger)

    logger.info("Finished installing apt packages.")


def set_locale(locale: str, lang: str, use_sudo: bool, logger: logging.Logger) -> None:
    """
    Set the locale for the environment.

    Parameters
    ----------
    locale : str
        The locale to set.
    lang : str
        The language to set.
    use_sudo : bool
        Should the command be run with sudo?
    logger : logging.Logger
        The logger to use for logging output.

    """
    logger.info(f"Setting locale to {locale} and language to {lang}.")
    update_locale_file(LOCALE_GEN_PATH, locale, use_sudo, logger)

    utilities.run_cmd(["locale-gen", locale], use_sudo, logger)
    utilities.run_cmd(
        ["update-locale", f"LANG={locale}", f"LC_ALL={locale}", f"LANGUAGE={lang}"],
        use_sudo,
        logger,
    )

    logger.info("Finished setting locale.")


def rebuild_font_cache(logger: logging.Logger) -> None:
    """
    Rebuild the font cache.

    Parameters
    ----------
    use_sudo : bool
        Should the command be run with sudo?
    logger : logging.Logger
        The logger to use for logging output.

    """
    logger.info("Rebuilding font cache.")
    utilities.run_cmd(["fc-cache", "-f", "-v"], False, logger)
    logger.info("Finished rebuilding font cache.")


def change_default_shell(shell: str, use_sudo: bool, logger: logging.Logger) -> None:
    """
    Change the default shell for the current user.

    Parameters
    ----------
    shell : str
        The shell to set as default.
    use_sudo : bool
        Should the command be run with sudo?
    logger : logging.Logger
        The logger to use for logging output.

    """
    username = os.getlogin()
    logger.info(f"Changing default shell to {shell}.")
    utilities.run_cmd(["chsh", "-s", shell, username], use_sudo, logger)
    logger.info("Finished changing default shell.")


def read_apt_packages_from_file(file_path: Path, logger: logging.Logger) -> list[str]:
    """
    Read a list of apt packages from a file, excluding blank lines.

    Parameters
    ----------
    file_path : Path
        The path to the file containing the list of packages.

    Returns
    -------
    list[str]
        A list of package names.

    """
    logger.debug(f"Reading apt packages from file: {file_path}")
    with open(file_path, "r") as f:
        packages = [line.strip() for line in f if line.strip()]
    return packages
    logger.debug("Finished reading apt packages from file.")


def update_locale_file(
    file_path: Path, locale: str, use_sudo: bool, logger: logging.Logger
) -> None:
    """
    Update the locale file by uncommenting the specified locale.

    If the locale is already uncommented, or the locale file does not
    exist do nothing.

    Parameters
    ----------
    file_path : Path
        The path to the locale file.
    locale : str
        The locale to uncomment.
    use_sudo : bool
        Should the command be run with sudo?
    logger : logging.Logger
        The logger to use for logging output.

    """
    logger.debug(f"Uncommenting locale {locale} in file: {file_path}")

    if not file_path.exists() and not file_path.is_file():
        logger.debug("No locale file found. Skipping.")
        return

    sed_command = ["sed", "-i", f"s/^#.*{locale}/{locale}/", str(file_path)]
    utilities.run_cmd(sed_command, use_sudo, logger)

    logger.debug("Finished uncommenting locale")
