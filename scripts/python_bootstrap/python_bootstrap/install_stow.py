from python_bootstrap import cmd_with_logs

STOW_INSTALL_DIR = Path.home().joinpath(".local")


def get_stow_download_url() -> tuple[str, str]:
    return ("stow", "https://ftp.gnu.org/gnu/stow/stow-latest.tar.gz")


def install_stow(file_path: Path, logger: logging.Logger) -> None:
    logger.info("Installing stow from source.")

    out_path = file_path.parent.joinpath("stow_install")
    cmd_with_logs.run_cmd(
        ["tar", "-C", f"{out_path}", "-xzf", file_path], False, logger
    )
    cmd_with_logs.run_cmd(
        ["./configure", f"--prefix={STOW_INSTALL_DIR}"],
        False,
        logger,
        cwd=out_path,
    )
    cmd_with_logs.run_cmd(["make", "-j$(nproc)"], False, logger, cwd=out_path)
    cmd_with_logs.run_cmd(["make", "install"], False, logger, cwd=out_path)

    logger.info("Finished installing stow.")
