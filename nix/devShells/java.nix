{ pkgs }:

pkgs.mkShellNoCC {
  name = "java";

  packages = with pkgs; [
    jdk
    gradle
  ];

  shellHook = ''
    echo "Java $(java -version 2>&1 | head -1)"
  '';
}