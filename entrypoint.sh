#!/bin/bash
set -e

COMFYUI_DIR="/app/ComfyUI"
CUSTOM_NODES_DIR="/app/ComfyUI/custom_nodes"
NODES_LIST="/app/custom-nodes.txt"

echo "=========================================="
echo "ComfyUI Docker - Starting up..."
echo "=========================================="

# Function to install a custom node
install_node() {
    local repo_url="$1"
    local repo_name=$(basename "$repo_url" .git)
    local target_dir="$CUSTOM_NODES_DIR/$repo_name"
    
    # Handle @branch or @tag suffix
    local branch=""
    if [[ "$repo_url" == *"@"* ]]; then
        branch="${repo_url##*@}"
        repo_url="${repo_url%@*}"
        repo_name=$(basename "$repo_url" .git)
        target_dir="$CUSTOM_NODES_DIR/$repo_name"
    fi
    
    if [ -d "$target_dir" ]; then
        echo "[OK] $repo_name already installed"
    else
        echo "[INSTALLING] $repo_name..."
        if [ -n "$branch" ]; then
            git clone --depth 1 --branch "$branch" "$repo_url" "$target_dir" 2>/dev/null || \
            git clone --depth 1 "$repo_url" "$target_dir"
        else
            git clone --depth 1 "$repo_url" "$target_dir"
        fi
        
        # Install requirements if they exist
        if [ -f "$target_dir/requirements.txt" ]; then
            echo "  -> Installing dependencies for $repo_name..."
            pip install --no-cache-dir -r "$target_dir/requirements.txt" || true
        fi
        
        # Run install.py if it exists
        if [ -f "$target_dir/install.py" ]; then
            echo "  -> Running install.py for $repo_name..."
            cd "$target_dir" && python install.py || true
            cd "$COMFYUI_DIR"
        fi
        
        echo "[DONE] $repo_name installed"
    fi
}

# Process custom nodes list
if [ -f "$NODES_LIST" ]; then
    echo ""
    echo "Processing custom nodes list..."
    echo ""
    
    while IFS= read -r line || [ -n "$line" ]; do
        # Skip empty lines and comments
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
        
        # Trim whitespace
        line=$(echo "$line" | xargs)
        
        install_node "$line"
    done < "$NODES_LIST"
    
    echo ""
    echo "Custom nodes processing complete."
else
    echo "No custom-nodes.txt found, skipping custom node installation."
fi

echo ""
echo "=========================================="
echo "Starting ComfyUI..."
echo "=========================================="
echo ""

# Start ComfyUI
cd "$COMFYUI_DIR"
exec python main.py --listen 0.0.0.0 --port 8188 "$@"
