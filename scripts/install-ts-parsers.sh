#!/usr/bin/bash

PACKDIR="$HOME/.local/share/nvim/site/pack/treesitter/start/"
ROCKDIR="$HOME/.local/share/nvim/rocks/"

parsers=(
  "tree-sitter-rust"
  "tree-sitter-c_sharp"
  "tree-sitter-xml"
)


function install_rock() {
  luarocks --tree="$ROCKDIR" install "$1"
  rock_dir=$(luarocks --tree="$ROCKDIR" show "$1" --rock-dir)
  ln -sf "$rock_dir" "$PACKDIR/$1"
}



# Build Requirements
luarocks install --local luarocks-build-treesitter-parser

# Ensure packapth exists
echo "Ensuring Packapth exists $PACKPAH"
mkdir -p "$PACKDIR"

for parser in "${parsers[@]}"; do
  echo "Checking $parser"
  if luarocks --tree="$ROCKDIR" show "$parser" > /dev/null 2>&1; then
    echo "Parser: $parser is installed"
  else
    echo "Installing $parser"
    install_rock "$parser"
  fi
done


