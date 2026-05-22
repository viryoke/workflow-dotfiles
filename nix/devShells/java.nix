{ pkgs }:

pkgs.mkShellNoCC {
  name = "java";

  packages = with pkgs; [
    jdk21
    gradle
  ];

  shellHook = ''
    echo "Java JDK 21 $(java -version 2>&1 | head -1)"
  '';
}