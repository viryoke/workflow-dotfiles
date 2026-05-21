{ pkgs }:

pkgs.mkShell {
  name = "cpp";

  packages = with pkgs; [
    gcc
    cmake
    clang
    gdb
  ];

  shellHook = ''
    echo "C++: gcc $(gcc -dumpversion), clang $(clang --version | head -1), cmake $(cmake --version | head -1)"
  '';
}