# ... (previous script parts: check uv, get project name, cd, create venv) ...

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
# ... (rest of the script: creating files, git init, etc.) ...
