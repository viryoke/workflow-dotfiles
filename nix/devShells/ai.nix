{ pkgs }:

pkgs.mkShellNoCC {
  name = "ai";

  packages = with pkgs; [
    claude-code
    gemini-cli
  ];

  shellHook = ''
    echo "AI tools: claude-code $(claude --version 2>/dev/null | head -1), gemini-cli $(gemini --version 2>/dev/null | head -1)"
  '';
}