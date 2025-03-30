.PHONY: all setup fzf oh_my_zsh neovim node stow treesitter universal-ctags python_essentials

LOG_DIR := logs
TEMP_DIR := temp
VENV_DIR := $(TEMP_DIR)/venv

all: setup
	. $(VENV_DIR)/bin/activate && \
		bootstrap --temp $(TEMP_DIR) --log $(LOG_DIR)
	rm -rf $(TEMP_DIR)

fzf: setup
	. $(VENV_DIR)/bin/activate && \
		install_fzf --temp $(TEMP_DIR) --log $(LOG_DIR)

oh_my_zsh: setup
	. $(VENV_DIR)/bin/activate && \
		install_oh_my_zsh --temp $(TEMP_DIR) --log $(LOG_DIR)

neovim: setup
	. $(VENV_DIR)/bin/activate && \
		install_neovim --temp $(TEMP_DIR) --log $(LOG_DIR)

node: setup
	. $(VENV_DIR)/bin/activate && \
		install_node --temp $(TEMP_DIR) --log $(LOG_DIR)

stow: setup
	. $(VENV_DIR)/bin/activate && \
		install_stow --temp $(TEMP_DIR) --log $(LOG_DIR)

treesitter: setup
	. $(VENV_DIR)/bin/activate && \
		install_treesitter --temp $(TEMP_DIR) --log $(LOG_DIR)

universal-ctags: setup
	. $(VENV_DIR)/bin/activate && \
		install_universal_ctags --temp $(TEMP_DIR) --log $(LOG_DIR)

python_essentials: setup
	. $(VENV_DIR)/bin/activate && \
		install_python_essentials --temp $(TEMP_DIR) --log $(LOG_DIR)

setup:
	mkdir -p $(TEMP_DIR)
	mkdir -p $(LOG_DIR)
	python3 -m venv $(VENV_DIR)
	. $(VENV_DIR)/bin/activate && pip install -e python_bootstrap
