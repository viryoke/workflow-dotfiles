{ pkgs }:

pkgs.mkShellNoCC {
  name = "nodejs";

  packages = with pkgs; [
    nodejs_22
    bun
    typescript
    ts-node
  ];

  shellHook = ''
    echo "Node.js $(node --version) + Bun $(bun --version)"
  '';
}