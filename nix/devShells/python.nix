{ pkgs }:

pkgs.mkShellNoCC {
  name = "python";

  packages = with pkgs; [
    python313
    uv
    ruff
    mypy
  ];

  shellHook = ''
    echo "Python $(python3 --version) + uv $(uv --version)"
  '';
}