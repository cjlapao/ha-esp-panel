#!/usr/bin/env bash
set -euo pipefail

echo "Detecting OS for system dependencies..."
OS="$(uname -s)"
if [ "$OS" = "Linux" ]; then
    if command -v apt-get >/dev/null 2>&1; then
        echo "Installing SDL2 and python dependencies via apt-get..."
        sudo apt-get update || true
        sudo apt-get install -y python3-venv python3-pip libsdl2-dev libsdl2-image-dev libsdl2-ttf-dev libsdl2-gfx-dev
    elif command -v dnf >/dev/null 2>&1; then
        echo "Installing SDL2 and python dependencies via dnf..."
        sudo dnf install -y python3-virtualenv SDL2-devel SDL2_image-devel SDL2_ttf-devel SDL2_gfx-devel
    elif command -v pacman >/dev/null 2>&1; then
        echo "Installing SDL2 and python dependencies via pacman..."
        sudo pacman -Sy --noconfirm python-virtualenv sdl2 sdl2_image sdl2_ttf sdl2_gfx
    else
        echo "Unsupported Linux package manager. Please install SDL2 dependencies and python3-venv manually."
    fi
elif [ "$OS" = "Darwin" ]; then
    if command -v brew >/dev/null 2>&1; then
        echo "Installing SDL2 dependencies via Homebrew..."
        brew install sdl2 sdl2_image sdl2_ttf sdl2_gfx
    else
        echo "Homebrew not found. Please install SDL2 dependencies manually."
    fi
else
    echo "OS $OS not supported for automatic SDL2 dependency installation. Please install manually."
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is required"
  exit 1
fi

VENV_DIR=".venv"

# Create venv if it doesn't exist AND we are not already in a virtualenv
if [ -z "${VIRTUAL_ENV:-}" ]; then
  if [ ! -d "$VENV_DIR" ]; then
    echo "Creating python virtual environment in $VENV_DIR..."
    python3 -m venv "$VENV_DIR"
  fi
  echo "Activating virtual environment..."
  set +u
  source "${VENV_DIR}/bin/activate"
  set -u
fi

echo "Installing python dependencies..."
python3 -m pip install --upgrade pip
python3 -m pip install esphome yamllint pre-commit

echo "Bootstrap complete!"
if [ -z "${VIRTUAL_ENV:-}" ]; then
  echo "To activate the virtual environment, run:"
  echo "  source ${VENV_DIR}/bin/activate"
fi
