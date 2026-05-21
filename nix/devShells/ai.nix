{ pkgs }:

pkgs.mkShellNoCC {
  name = "ai";

  packages = with pkgs; [
    claude-code
  ];

  shellHook = ''
    echo "AI tools: claude-code $(claude --version 2>/dev/null | head -1)"
  '';
}