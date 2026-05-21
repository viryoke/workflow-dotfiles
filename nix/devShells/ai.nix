{ pkgs }:

pkgs.mkShellNoCC {
  name = "ai";

  packages = with pkgs; [
    claude-code
  ];

  shellHook = ''
    echo "AI tools: claude-code $(claude --version 2>/dev/null | head -1)"

    # Install Antigravity CLI if not already present
    if ! command -v agy &>/dev/null; then
      echo "Installing Antigravity CLI..."
      curl -fsSL https://antigravity.google/cli/install.sh | bash
    fi
    echo "Antigravity CLI: $(agy --version 2>/dev/null || echo 'not installed')"
  '';
}