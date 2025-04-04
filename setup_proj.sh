#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
# Use python3 by default. If you have a specific pyenv version active,
# it should pick that one up.
PYTHON_CMD="python3"
# Default libraries to install
DEFAULT_LIBS="pandas streamlit duckdb jupyterlab" # Added jupyterlab for notebooks

# --- Script Logic ---

echo "🚀 Starting Python Project Setup..."

# 1. Get Project Name
read -p "Enter the name for your new project (e.g., my-data-app): " PROJECT_NAME

# Basic validation for project name
if [ -z "$PROJECT_NAME" ]; then
  echo "❌ Error: Project name cannot be empty."
  exit 1
fi

# Check if directory already exists
if [ -d "$PROJECT_NAME" ]; then
  echo "❌ Error: Directory '$PROJECT_NAME' already exists."
  exit 1
fi

echo "   Project Name: $PROJECT_NAME"

# 2. Create Project Directory and CD into it
echo "   Creating project directory: $PROJECT_NAME/"
mkdir "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Get the absolute path of the project directory *now* that we are inside it
PROJECT_DIR=$(pwd)

# --- Environment Setup (using python's venv) ---
echo "🐍 Setting up Python virtual environment..."

# Ensure a suitable Python version is available
if ! command -v $PYTHON_CMD &> /dev/null; then
    echo "❌ Error: '$PYTHON_CMD' command not found."
    echo "   Please ensure Python 3 is installed and accessible."
    echo "   If using pyenv, make sure a version is selected (e.g., 'pyenv global 3.10.4' or 'pyenv local 3.10.4')."
    # Clean up created directory before exiting
    cd ..
    rm -rf "$PROJECT_NAME"
    exit 1
fi

# Create virtual environment
$PYTHON_CMD -m venv venv
echo "   Virtual environment 'venv' created."

# Determine the Python interpreter path within the venv
PYTHON_INTERPRETER_PATH="$PROJECT_DIR/venv/bin/python"
VENV_ACTIVATION_COMMAND="source $PROJECT_DIR/venv/bin/activate"

echo "🐍 Python Interpreter Path: $PYTHON_INTERPRETER_PATH"
echo "   (This path will be saved to .env_info.txt)"

# --- Install Libraries ---
echo "📦 Installing default libraries: $DEFAULT_LIBS ..."
# Use the pip from the created venv
"$PROJECT_DIR/venv/bin/pip" install --upgrade pip > /dev/null # Upgrade pip silently
"$PROJECT_DIR/venv/bin/pip" install $DEFAULT_LIBS
echo "   Libraries installed."

# --- Project Scaffolding ---
echo "🏗️ Creating project structure..."

# Create source and notebooks directories
mkdir src
mkdir notebooks

# Create essential files
touch src/app.py
touch notebooks/01_initial_exploration.ipynb # Placeholder notebook
touch .gitignore
touch requirements.txt
touch README.md
touch .env_info.txt # File to store environment details

echo "   Directory structure created:"
echo "   ├── .env_info.txt"
echo "   ├── .gitignore"
echo "   ├── README.md"
echo "   ├── requirements.txt"
echo "   ├── notebooks/"
echo "   │   └── 01_initial_exploration.ipynb"
echo "   ├── src/"
echo "   │   └── app.py"
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
build/
dist/
*.egg-info/
*.egg

# macOS stuff
.DS_Store

# IDE stuff
.vscode/
.idea/

# Notebook Checkpoints
.ipynb_checkpoints/

# Streamlit secrets
.streamlit/secrets.toml

# DuckDB files
*.db
*.db.wal

# Env info file (optional: you might want to commit this for team use)
# Comment out the next line if you want to track .env_info.txt in Git
# .env_info.txt
EOF
echo "   Populated .gitignore"

# requirements.txt (freeze installed packages)
echo "   Generating requirements.txt..."
"$PROJECT_DIR/venv/bin/pip" freeze > requirements.txt

# README.md
cat << EOF > README.md
# $PROJECT_NAME

A new Python project.

## Setup

1.  **Environment Info:** Check the \`.env_info.txt\` file for the interpreter path and activation command.

2.  **Activate Environment:**
    \`\`\`bash
    source venv/bin/activate
    \`\`\`
    *(Or use the command from \`.env_info.txt\`)*

3.  **Install Dependencies (if needed later):**
    \`\`\`bash
    pip install -r requirements.txt
    \`\`\`

## Running the App

(Example for Streamlit app)
\`\`\`bash
# Make sure the venv is activated first!
streamlit run src/app.py
\`\`\`

## Notebooks

Experimental work and analysis can be found in the \`notebooks/\` directory. Start Jupyter Lab with:
\`\`\`bash
# Make sure the venv is activated first!
jupyter lab
\`\`\`

## IDE Configuration (VS Code / PyCharm)

Use the Python interpreter path found in \`.env_info.txt\` or printed during setup to configure your IDE for this project. See the setup script's output or the IDE-specific instructions below.

EOF
echo "   Populated README.md"

# src/app.py (Simple Streamlit Example - Same as before)
cat << EOF > src/app.py
import streamlit as st
import pandas as pd
import duckdb
import time # Just for demo purposes

st.set_page_config(layout="wide")

st.title("🚀 My New Data App!")

st.write(f"Project: **{PROJECT_NAME}**")

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

EOF
echo "   Populated src/app.py"


# --- Git Initialization ---
echo "🐙 Initializing Git repository..."
git init > /dev/null
git add . > /dev/null
git commit -m "Initial project setup via script" > /dev/null
echo "   Git repository initialized and initial commit made."

# --- Final Instructions ---
echo ""
echo "✅ Project '$PROJECT_NAME' set up successfully!"
echo "   Project Directory: $PROJECT_DIR"
echo ""
echo "--- Environment Details ---"
echo "   🐍 Python Interpreter: $PYTHON_INTERPRETER_PATH"
echo "   💾 Saved To: $PROJECT_DIR/.env_info.txt"
echo "   🚀 Activate Command: $VENV_ACTIVATION_COMMAND"
echo ""
echo "--- Next Steps ---"
echo "1. Navigate into your project directory:"
echo "   cd $PROJECT_DIR"
echo ""
echo "2. Activate the virtual environment:"
echo "   source venv/bin/activate"
echo "   (To deactivate later, just type 'deactivate')"
echo ""
echo "3. Configure your IDE (VS Code / PyCharm):"
echo "   * Use the Python interpreter path shown above (and saved in .env_info.txt)."
echo "   * VS Code:"
echo "     - Open the project folder: 'File' -> 'Open Folder...' -> Select '$PROJECT_NAME'."
echo "     - Open the Command Palette (Cmd+Shift+P or View -> Command Palette)."
echo "     - Type 'Python: Select Interpreter'."
echo "     - Click on '+ Enter interpreter path...'."
echo "     - Paste the full path: $PYTHON_INTERPRETER_PATH"
echo "     - VS Code should now use the project's venv."
echo "   * PyCharm:"
echo "     - Open the project folder: 'File' -> 'Open...' -> Select '$PROJECT_NAME'."
echo "     - Go to 'PyCharm' -> 'Settings...' (or 'Preferences...' on macOS)."
echo "     - Navigate to 'Project: $PROJECT_NAME' -> 'Python Interpreter'."
echo "     - Click the gear icon ⚙️ -> 'Add...'."
echo "     - Select 'Existing environment'."
echo "     - In the 'Interpreter:' field, click '...' and navigate to:"
echo "       $PYTHON_INTERPRETER_PATH"
echo "     - Click 'OK' on all dialogs. PyCharm will re-index using the venv."
echo ""
echo "4. Run the sample Streamlit app (after activating venv):"
echo "   streamlit run src/app.py"
echo ""
echo "5. Start Jupyter Lab for notebooks (after activating venv):"
echo "   jupyter lab"
echo ""
echo "6. Create a repository on GitHub (e.g., named '$PROJECT_NAME')."
echo "   Then link your local repository and push:"
echo "   git remote add origin git@github.com:YOUR_USERNAME/$PROJECT_NAME.git"
echo "   git branch -M main"
echo "   git push -u origin main"
echo ""
echo "Happy coding! 🎉"

exit 0
