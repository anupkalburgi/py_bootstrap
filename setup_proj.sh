#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Check for uv ---
if ! command -v uv &> /dev/null; then
    echo "❌ Error: 'uv' command not found."
    echo "   'uv' is required for environment and package management in this script."
    echo "   Install it via pip: 'pip install uv'"
    echo "   Or follow instructions at: https://github.com/astral-sh/uv"
    exit 1
fi
echo "✅ Found uv: $(command -v uv)"

# --- Get Project Name from Argument ---
if [ -z "$1" ]; then
  echo "❌ Error: Project name must be provided as the first argument."
  echo "   Usage: curl ... | bash -s -- <project-name>"
  exit 1
fi
PROJECT_NAME="$1" # Use the first argument as the project name
# Derive Python package name from project name (replace hyphens with underscores)
PACKAGE_NAME=$(echo "$PROJECT_NAME" | sed 's/-/_/g')

echo "🚀 Starting Python Project Setup for '$PROJECT_NAME' (package '$PACKAGE_NAME') using uv and pyproject.toml..."

# --- Check if directory already exists ---
if [ -d "$PROJECT_NAME" ]; then
  echo "❌ Error: Directory '$PROJECT_NAME' already exists."
  exit 1
fi

# --- Create Project Directory and CD into it ---
echo "   Creating project directory: $PROJECT_NAME/"
mkdir "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Get the absolute path of the project directory *now* that we are inside it
PROJECT_DIR=$(pwd)

# --- Environment Setup (using uv) ---
echo "🐍 Setting up Python virtual environment using uv..."
uv venv venv --seed
echo "   Virtual environment 'venv' created."

# Determine the Python interpreter path within the venv
PYTHON_INTERPRETER_PATH="$PROJECT_DIR/venv/bin/python"
VENV_ACTIVATION_COMMAND="source $PROJECT_DIR/venv/bin/activate"

echo "🐍 Python Interpreter Path: $PYTHON_INTERPRETER_PATH"
echo "   (This path will be saved to .env_info.txt)"

# --- Project Scaffolding ---
echo "🏗️ Creating project structure..."

# Create source layout, tests, notebooks
mkdir -p "src/$PACKAGE_NAME" # Create nested package directory
mkdir tests
mkdir notebooks

# Create essential files
touch "src/$PACKAGE_NAME/__init__.py"
touch "src/$PACKAGE_NAME/logic.py"
touch "src/$PACKAGE_NAME/__main__.py" # For basic CLI entry point
touch tests/__init__.py
touch tests/test_example.py
touch pyproject.toml
touch README.md
touch .gitignore
touch .env_info.txt
touch notebooks/01_initial_exploration.ipynb

echo "   Directory structure created:"
echo "   ├── pyproject.toml"
echo "   ├── README.md"
echo "   ├── .gitignore"
echo "   ├── .env_info.txt"
echo "   ├── notebooks/"
echo "   │   └── 01_initial_exploration.ipynb"
echo "   ├── src/"
echo "   │   └── $PACKAGE_NAME/"
echo "   │       ├── __init__.py"
echo "   │       ├── __main__.py"
echo "   │       └── logic.py"
echo "   ├── tests/"
echo "   │   ├── __init__.py"
echo "   │   └── test_example.py"
echo "   └── venv/"

# --- Populate Files ---
echo "📝 Populating initial files..."

# pyproject.toml
cat << EOF > pyproject.toml
[build-system]
requires = ["setuptools>=61.0"] # Or hatchling, flit_core etc.
build-backend = "setuptools.build_meta"

[project]
name = "$PACKAGE_NAME"
version = "0.1.0"
description = "A new Python project: $PROJECT_NAME" # Add a brief description
readme = "README.md"
requires-python = ">=3.8" # Specify your minimum Python version
license = {text = "MIT"} # Choose your license: MIT, Apache-2.0, etc. Add license file later.
authors = [
  { name = "Your Name", email = "your.email@example.com" }, # Update with your details
]
classifiers = [ # Optional: PyPI classifiers
    "Programming Language :: Python :: 3",
    "License :: OSI Approved :: MIT License", # Match your chosen license
    "Operating System :: OS Independent",
]
# Add your runtime dependencies here as needed
# Example: dependencies = ["pandas>=2.0", "requests"]
dependencies = [
    # Start with minimal dependencies
]

[project.optional-dependencies]
dev = [
    "pytest",      # For running tests
    "jupyterlab",  # For notebooks
    # Add other dev tools like black, ruff, mypy here if desired
]

# Optional: Define entry points for command-line scripts
[project.scripts]
$PROJECT_NAME = "$PACKAGE_NAME.__main__:main" # Example CLI script

# Optional: Project URLs for PyPI
[project.urls]
Homepage = "https://github.com/YOUR_USERNAME/$PROJECT_NAME" # Update USERNAME and repo name
Repository = "https://github.com/YOUR_USERNAME/$PROJECT_NAME"
# Bug Tracker = "https://github.com/YOUR_USERNAME/$PROJECT_NAME/issues"

EOF
echo "   Populated pyproject.toml"

# .env_info.txt
cat << EOF > .env_info.txt
# Python Virtual Environment Information for Project: $PROJECT_NAME

# Absolute path to the Python interpreter within the virtual environment:
PYTHON_INTERPRETER="$PYTHON_INTERPRETER_PATH"

# Command to activate the virtual environment in your shell:
ACTIVATE_COMMAND="$VENV_ACTIVATION_COMMAND"

# Environment created using: uv
# Project dependencies managed via: pyproject.toml
EOF
echo "   Created .env_info.txt"

# .gitignore
cat << EOF > .gitignore
# Python stuff
venv/
__pycache__/
*.pyc
*.pyo
*.pyd
.python-version
*.ipynb_checkpoints
*.egg-info/
*.egg
build/
dist/
wheels/

# macOS stuff
.DS_Store

# IDE stuff
.vscode/
.idea/

# Streamlit secrets
.streamlit/secrets.toml

# DuckDB files
*.db
*.db.wal

# Test artifacts
.pytest_cache/
htmlcov/
.coverage

# Env info file (optional)
# .env_info.txt

# Notebook runtime files
.jupyter/
EOF
echo "   Populated .gitignore"

# src/$PACKAGE_NAME/__init__.py
cat << EOF > "src/$PACKAGE_NAME/__init__.py"
# src/$PACKAGE_NAME/__init__.py
"""
$PROJECT_NAME

A new Python project.
"""

__version__ = "0.1.0"

# Optionally expose core functions
# from .$PACKAGE_NAME.logic import add_one

EOF
echo "   Populated src/$PACKAGE_NAME/__init__.py"


# src/$PACKAGE_NAME/logic.py (Simple function for testing)
cat << EOF > "src/$PACKAGE_NAME/logic.py"
"""Sample logic file for $PACKAGE_NAME."""

def add_one(number: int) -> int:
    """Adds one to the given number."""
    if not isinstance(number, int):
        raise TypeError("Input must be an integer")
    return number + 1

EOF
echo "   Populated src/$PACKAGE_NAME/logic.py"

# src/$PACKAGE_NAME/__main__.py (Basic CLI entry point)
cat << EOF > "src/$PACKAGE_NAME/__main__.py"
"""Basic CLI entry point defined in pyproject.toml."""

import sys
from .$PACKAGE_NAME.logic import add_one

def main():
    print(f"Running CLI for {PROJECT_NAME} (package {PACKAGE_NAME})")
    # Example: process command line args
    args = sys.argv[1:]
    if not args:
        print("No arguments provided. Try providing a number.")
        return 1 # Indicate error

    try:
        num_arg = int(args[0])
        result = add_one(num_arg)
        print(f"Result of add_one({num_arg}): {result}")
        return 0 # Indicate success
    except ValueError:
        print(f"Error: Could not convert argument '{args[0]}' to an integer.")
        return 1
    except TypeError as e:
        print(f"Error: {e}")
        return 1

if __name__ == "__main__":
    sys.exit(main())

EOF
echo "   Populated src/$PACKAGE_NAME/__main__.py"


# tests/test_example.py (Updated import path)
cat << EOF > tests/test_example.py
"""Example test file using pytest for $PACKAGE_NAME."""

import pytest
from $PACKAGE_NAME.logic import add_one # Updated import path

def test_add_one_success():
    """Test that add_one correctly adds one."""
    assert add_one(3) == 4
    assert add_one(0) == 1
    assert add_one(-1) == 0

def test_add_one_type_error():
    """Test that add_one raises TypeError for non-int input."""
    with pytest.raises(TypeError):
        add_one("hello")
    with pytest.raises(TypeError):
        add_one(5.5)

def test_always_passes():
    """A simple test that should always pass."""
    assert True

# Example of skipping a test
@pytest.mark.skip(reason="Not implemented yet")
def test_future_feature():
    assert False
EOF
echo "   Populated tests/test_example.py"


# README.md (Updated for pyproject.toml workflow)
cat << EOF > README.md
# $PROJECT_NAME

A new Python project setup using uv and pyproject.toml.

## Prerequisites

*   [uv](https://github.com/astral-sh/uv): Ensure \`uv\` is installed.
*   Python 3.8+

## Setup & Installation

1.  **Clone the Repository (if not already done):**
    \`\`\`bash
    git clone https://github.com/YOUR_USERNAME/$PROJECT_NAME.git # Update URL
    cd $PROJECT_NAME
    \`\`\`

2.  **Create/Activate Virtual Environment:**
    This script already created a \`venv\` directory. Activate it:
    \`\`\`bash
    source venv/bin/activate
    \`\`\`
    *(If setting up manually later, create one with \`uv venv venv\`)*

3.  **Install Project Dependencies:**
    Install the project in editable mode along with development dependencies using \`uv\`:
    \`\`\`bash
    uv pip install -e .[dev]
    \`\`\`
    *   \`-e\`: Installs in editable mode (changes in \`src/\` are reflected immediately).
    *   \`.\`: Refers to the current directory (where \`pyproject.toml\` is).
    *   \`[dev]\`: Installs the optional dependencies listed under \`[project.optional-dependencies.dev]\` in \`pyproject.toml\`.

4.  **Adding Dependencies:**
    *   To add a **runtime** dependency (needed for the project to run), add it to the \`dependencies = [...] \` list in \`pyproject.toml\` and re-run \`uv pip install -e .[dev]\`.
    *   To add a **development** dependency (like linters, formatters), add it to the \`dev = [...] \` list in \`[project.optional-dependencies]\` and re-run \`uv pip install -e .[dev]\`.

## Running the Example CLI

After installation, the example script defined in \`pyproject.toml\` should be available.
Make sure your virtual environment is activated.
\`\`\`bash
# Run the script defined under [project.scripts]
$PROJECT_NAME 42
$PROJECT_NAME hello
\`\`\`

## Running Tests

Tests are written using \`pytest\`.

1.  **Activate Environment:** Ensure your virtual environment (\`venv\`) is activated.
2.  **Run Tests:** Execute \`pytest\` from the project root directory:
    \`\`\`bash
    pytest
    \`\`\`
    *To run with more verbose output:* \`pytest -v\`

## Notebooks

Experimental work and analysis can be found in the \`notebooks/\` directory. Start Jupyter Lab (requires the 'dev' dependencies to be installed):
\`\`\`bash
# Make sure the venv is activated first!
jupyter lab
\`\`\`

## IDE Configuration (VS Code / PyCharm)

Use the Python interpreter path found in \`.env_info.txt\` (\`$PROJECT_DIR/venv/bin/python\`) to configure your IDE for this project.

## Publishing to PyPI (Future Steps)

1.  Update \`pyproject.toml\` with accurate metadata (author, license, description, URLs, classifiers).
2.  Choose and add a \`LICENSE\` file.
3.  Ensure your runtime \`dependencies\` are correct.
4.  Install build tools: \`uv pip install build twine\` (if not already in dev dependencies).
5.  Build the package: \`python -m build\`
6.  Upload to TestPyPI first, then PyPI using \`twine upload dist/*\`.

EOF
echo "   Populated README.md"


# --- Install Project in Editable Mode + Dev Dependencies (using uv) ---
echo "📦 Installing project in editable mode with dev dependencies using uv..."
# Explicitly tell uv pip which python interpreter (and thus venv) to use
uv pip install --python "$PYTHON_INTERPRETER_PATH" -e .[dev]
echo "   Project and dev dependencies installed."

# --- Git Initialization ---
echo "🐙 Initializing Git repository..."
git init > /dev/null
git add . > /dev/null
git commit -m "Initial project setup using uv, pyproject.toml, and minimal deps" > /dev/null
echo "   Git repository initialized and initial commit made."

# --- Final Instructions ---
echo ""
echo "✅ Project '$PROJECT_NAME' set up successfully using uv and pyproject.toml!"
echo "   Project Directory: $PROJECT_DIR"
echo "   Python Package Name: $PACKAGE_NAME"
echo ""
echo "--- Environment Details ---"
echo "   🐍 Python Interpreter: $PYTHON_INTERPRETER_PATH"
echo "   💾 Saved To: $PROJECT_DIR/.env_info.txt"
echo "   🚀 Activate Command: $VENV_ACTIVATION_COMMAND"
echo ""
echo "--- Next Steps ---"
echo "1. Navigate into your project directory:"
echo "   cd \"$PROJECT_DIR\""
echo ""
echo "2. Activate the virtual environment:"
echo "   source venv/bin/activate"
echo "   (To deactivate later, just type 'deactivate')"
echo ""
echo "3. Configure your IDE (VS Code / PyCharm) using the interpreter path:"
echo "   $PYTHON_INTERPRETER_PATH"
echo ""
echo "4. Review and update 'pyproject.toml' with your details (author, license, etc.)"
echo "   Add necessary runtime dependencies to '[project].dependencies'."
echo "   Re-run 'uv pip install -e .[dev]' after modifying pyproject.toml."
echo ""
echo "5. Run the sample tests:"
echo "   pytest"
echo ""
echo "6. Run the sample CLI script:"
echo "   $PROJECT_NAME 10"
echo ""
echo "7. Start Jupyter Lab for notebooks:"
echo "   jupyter lab"
echo ""
echo "8. Create a repository on GitHub (e.g., named '$PROJECT_NAME')."
echo "   Then link your local repository and push:"
echo "   git remote add origin git@github.com:YOUR_USERNAME/$PROJECT_NAME.git" # Update USERNAME
echo "   git branch -M main"
echo "   git push -u origin main"
echo ""
echo "Happy coding! 🎉"

exit 0
