{ pkgs }:

pkgs.mkShellNoCC {
  name = "nodejs";

  packages = with pkgs; [
    nodejs_22
    bun
  ];

  shellHook = ''
    echo "Node.js $(node --version) + Bun $(bun --version)"
  '';
}