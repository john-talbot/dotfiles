.PHONY: bootstrap setup clean

# Directory for the virtual environment
LOG_DIR := logs
TEMP_DIR := temp
VENV_DIR := ${TEMP_DIR)/venv

bootstrap: setup
	. $(VENV_DIR)/bin/activate && \
		bootstrap --temp $(TEMP_DIR) --logs $(LOG_DIR)

setup:
	mkdir -p $(TEMP_DIR)
	mkdir -p $(LOG_DIR)

	python3 -m venv $(VENV_DIR)
	. $(VENV_DIR)/bin/activate && \

	pip install -e python_bootstrap

clean:
	rm -rf $(TEMP_DIR)
