# 🛠 Dotfiles Bootstrapper

This project bootstraps a new development environment from scratch using Make, Python, and modular installer scripts.

It configures tools like:

- [Oh My Zsh](https://ohmyz.sh/)
- [Neovim (Nightly)](https://github.com/neovim/neovim)
- [fzf (Fuzzy Finder)](https://github.com/junegunn/fzf)
- [Universal Ctags](https://github.com/universal-ctags/ctags)
- [Tree-sitter CLI](https://tree-sitter.github.io/)
- [Node.js](https://nodejs.org/)
- Python packages
- Dotfile symlinks via [GNU Stow](https://www.gnu.org/software/stow/)

---

## 📦 Requirements

### ✅ Ubuntu (22.04+)

```bash
sudo apt update
sudo apt install -y make python3 python3-venv python3-pip
```


### ✅ macOS

```bash
xcode-select --install
```

Make sure `make`, `python3`, and `pip3` are available:

```bash
make --version
python3 --version
pip3 --version
```

---

## 🚀 Getting Started

Navigate to the scripts directory:

```bash
cd .dotfiles/scripts
```

Run the full bootstrap process with:

```bash
make
```

This will:

1. Create a temporary virtual environment
2. Install the `python_bootstrap` project in editable mode
3. Run the main `bootstrap` entry point
4. Clean up the temp directory

---

## 🧩 Individual Components

You can run each step manually with:

```bash
make fzf
make oh_my_zsh
make neovim
make node
make stow
make treesitter
make universal-ctags
make python_essentials
```

All commands activate the Python virtual environment and log output to `logs/`.

---


## 🧪 Development Tips

- Modify Python scripts in `python_bootstrap/python_bootstrap/`
- Add new CLI entry points in `pyproject.toml` under `[project.scripts]`
- Reinstall with:
  ```bash
  pip install -e python_bootstrap
  ```

---

## 📄 License

MIT
