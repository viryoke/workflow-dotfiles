{ pkgs }:

pkgs.mkShellNoCC {
  name = "rust";

  packages = with pkgs; [
    rustc
    cargo
    rust-analyzer
    clippy
    rustfmt
  ];

  shellHook = ''
    echo "Rust $(rustc --version)"
  '';
}