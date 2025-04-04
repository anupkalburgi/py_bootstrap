#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
DEFAULT_LIBS="pandas streamlit duckdb jupyterlab pytest" # Added pytest

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

echo "🚀 Starting Python Project Setup for '$PROJECT_NAME' using uv..."

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
# Create virtual environment named 'venv'
# Use -p python3 to be more explicit if needed, but uv should find it now we're not in an active env confusion state
uv venv venv --seed
echo "   Virtual environment 'venv' created."

# Determine the Python interpreter path within the venv
PYTHON_INTERPRETER_PATH="$PROJECT_DIR/venv/bin/python"
VENV_ACTIVATION_COMMAND="source $PROJECT_DIR/venv/bin/activate"

echo "🐍 Python Interpreter Path: $PYTHON_INTERPRETER_PATH"
echo "   (This path will be saved to .env_info.txt)"

# --- Install Libraries (using uv) ---
echo "📦 Installing default libraries using uv: $DEFAULT_LIBS ..."

# Explicitly tell uv pip which python interpreter (and thus venv) to use
# This avoids auto-detection issues immediately after venv creation in scripts
uv pip install --python "$PYTHON_INTERPRETER_PATH" $DEFAULT_LIBS

echo "   Libraries installed."

# --- Project Scaffolding ---
echo "🏗️ Creating project structure..."

# Create source, notebooks, and tests directories
mkdir src
mkdir notebooks
mkdir tests

# Create essential files
touch src/__init__.py             # Make src a package
touch src/logic.py              # Sample logic file
touch src/app.py                # Streamlit app
touch notebooks/01_initial_exploration.ipynb # Placeholder notebook
touch tests/__init__.py           # Make tests a package
touch tests/test_example.py     # Sample test file
touch .gitignore
touch requirements.txt
touch README.md
touch .env_info.txt             # File to store environment details

echo "   Directory structure created:"
echo "   ├── .env_info.txt"
echo "   ├── .gitignore"
echo "   ├── README.md"
echo "   ├── requirements.txt"
echo "   ├── notebooks/"
echo "   │   └── 01_initial_exploration.ipynb"
echo "   ├── src/"
echo "   │   ├── __init__.py"
echo "   │   ├── app.py"
echo "   │   └── logic.py"
echo "   ├── tests/"
echo "   │   ├── __init__.py"
echo "   │   └── test_example.py"
echo "   └── venv/"

# --- Populate Files ---
echo "📝 Populating initial files..."

# .env_info.txt
cat << EOF > .env_info.txt
# Python Virtual Environment Information for Project: $PROJECT_NAME

# Absolute path to the Python interpreter within the virtual environment:
PYTHON_INTERPRETER="$PYTHON_INTERPRETER_PATH"

# Command to activate the virtual environment in your shell:
ACTIVATE_COMMAND="$VENV_ACTIVATION_COMMAND"

# Environment created using: uv
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

# Build artifacts
build/
dist/
*.egg-info/
*.egg

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

# Env info file (optional)
# .env_info.txt

# Test artifacts
.pytest_cache/
htmlcov/
.coverage
EOF
echo "   Populated .gitignore"

# requirements.txt (generate using uv, specify python path here too for consistency)
echo "   Generating requirements.txt using uv..."
uv pip freeze --python "$PYTHON_INTERPRETER_PATH" > requirements.txt

# src/logic.py (Simple function for testing)
cat << EOF > src/logic.py
"""Sample logic file."""

def add_one(number: int) -> int:
    """Adds one to the given number."""
    if not isinstance(number, int):
        raise TypeError("Input must be an integer")
    return number + 1

EOF
echo "   Populated src/logic.py"

# tests/test_example.py (Simple pytest example)
cat << EOF > tests/test_example.py
"""Example test file using pytest."""

import pytest
from src.logic import add_one

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


# README.md (Updated for uv and tests)
cat << EOF > README.md
# $PROJECT_NAME

A new Python project setup using uv.

## Prerequisites

*   [uv](https://github.com/astral-sh/uv): Ensure \`uv\` is installed. If not: \`pip install uv\` or use the official installer.
*   Python 3.8+

## Setup

1.  **Environment Info:** Check the \`.env_info.txt\` file for the interpreter path and activation command.

2.  **Activate Environment:**
    \`\`\`bash
    source venv/bin/activate
    \`\`\`
    *(Or use the command from \`.env_info.txt\`)*

3.  **Install/Update Dependencies (using uv):**
    If you modify dependencies or clone the repo later:
    \`\`\`bash
    # Ensure venv is activated first
    uv pip sync requirements.txt
    # OR if not activated and in project root:
    # uv pip sync --python venv/bin/python requirements.txt
    \`\`\`
    *(Using \`uv pip sync\` is generally preferred over \`install -r\` for reproducing exact environments)*

## Running the App

(Example for Streamlit app)
\`\`\`bash
# Make sure the venv is activated first!
streamlit run src/app.py
\`\`\`

## Running Tests

Tests are written using \`pytest\`.

1.  **Activate Environment:** Ensure your virtual environment (\`venv\`) is activated.
    \`\`\`bash
    source venv/bin/activate
    \`\`\`
2.  **Run Tests:** Execute \`pytest\` from the project root directory:
    \`\`\`bash
    pytest
    \`\`\`
    *To run with more verbose output:*
    \`\`\`bash
    pytest -v
    \`\`\`

## Notebooks

Experimental work and analysis can be found in the \`notebooks/\` directory. Start Jupyter Lab with:
\`\`\`bash
# Make sure the venv is activated first!
jupyter lab
\`\`\`

## IDE Configuration (VS Code / PyCharm)

Use the Python interpreter path found in \`.env_info.txt\` or printed during setup (\`$PROJECT_DIR/venv/bin/python\`) to configure your IDE for this project.

EOF
echo "   Populated README.md"

# src/app.py (Simple Streamlit Example)
cat << EOF > src/app.py
import streamlit as st
import pandas as pd
import duckdb
import time # Just for demo purposes
# Example of potentially using logic from src
from src.logic import add_one

st.set_page_config(layout="wide")

st.title("🚀 My New Data App!")

st.write(f"Project: **{PROJECT_NAME}**")
st.write(f"Testing logic: 1 + 1 = {add_one(1)}") # Example usage

@st.cache_resource
def get_duckdb_connection():
    # Create an in-memory DuckDB database
    conn = duckdb.connect(database=':memory:', read_only=False)
    st.toast("DuckDB connection established.")
    return conn

@st.cache_data(ttl=600) # Cache data for 10 minutes
def create_sample_data(_conn):
    _conn.execute("CREATE OR REPLACE TABLE sample_data AS SELECT range AS id, random() AS value FROM range(10)")
    df = _conn.execute("SELECT * FROM sample_data").fetchdf()
    time.sleep(1) # Simulate data loading time
    return df

st.header("Sample Data")

conn = get_duckdb_connection()

if st.button("Load/Refresh Sample Data"):
    df = create_sample_data(conn)
    st.dataframe(df)
    st.success(f"Loaded {len(df)} rows from DuckDB.")
else:
    st.info("Click the button to load data.")

st.sidebar.header("Options")
option = st.sidebar.selectbox("Choose an option", ["A", "B", "C"])
st.sidebar.write("You selected:", option)

st.write("---")
st.write("Explore more in the \`notebooks/\` directory!")
st.write("Run tests using \`pytest\` in your terminal (after activating venv).")

EOF
echo "   Populated src/app.py"


# --- Git Initialization ---
echo "🐙 Initializing Git repository..."
git init > /dev/null
git add . > /dev/null
git commit -m "Initial project setup using uv and pytest" > /dev/null
echo "   Git repository initialized and initial commit made."

# --- Final Instructions ---
echo ""
echo "✅ Project '$PROJECT_NAME' set up successfully using uv!"
echo "   Project Directory: $PROJECT_DIR"
echo ""
echo "--- Environment Details ---"
echo "   🐍 Python Interpreter: $PYTHON_INTERPRETER_PATH"
echo "   💾 Saved To: $PROJECT_DIR/.env_info.txt"
echo "   🚀 Activate Command: $VENV_ACTIVATION_COMMAND"
echo ""
echo "--- Next Steps ---"
echo "1. Navigate into your project directory:"
echo "   cd \"$PROJECT_DIR\""  # Added quotes for names with spaces
echo ""
echo "2. Activate the virtual environment:"
echo "   source venv/bin/activate"
echo "   (To deactivate later, just type 'deactivate')"
echo ""
echo "3. Configure your IDE (VS Code / PyCharm) using the interpreter path:"
echo "   $PYTHON_INTERPRETER_PATH"
echo "   (See README.md for more detailed IDE steps)"
echo ""
echo "4. Run the sample tests:"
echo "   pytest"
echo ""
echo "5. Run the sample Streamlit app:"
echo "   streamlit run src/app.py"
echo ""
echo "6. Start Jupyter Lab for notebooks:"
echo "   jupyter lab"
echo ""
echo "7. Create a repository on GitHub (e.g., named '$PROJECT_NAME')."
echo "   Then link your local repository and push:"
echo "   git remote add origin git@github.com:YOUR_USERNAME/$PROJECT_NAME.git"
echo "   git branch -M main"
echo "   git push -u origin main"
echo ""
echo "Happy coding! 🎉"

exit 0
