{ pkgs }:

pkgs.mkShellNoCC {
  name = "rust";

  packages = with pkgs; [
    rustc
    cargo
    rust-analyzer
    clippy
    rustfmt
    cargo-watch
    cargo-nextest
    cargo-expand
  ];

  shellHook = ''
    echo "Rust $(rustc --version)"
  '';
}