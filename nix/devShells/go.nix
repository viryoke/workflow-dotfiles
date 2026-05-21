{ pkgs }:

pkgs.mkShellNoCC {
  name = "go";

  packages = with pkgs; [
    go
    gopls
  ];

  shellHook = ''
    echo "Go $(go version)"
  '';
}