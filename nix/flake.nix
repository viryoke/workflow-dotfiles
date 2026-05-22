{
  description = "viryoke dev environments";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-darwin"
      ];
      pkgsFor = forAllSystems (system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        }
      );
    in
    {
      devShells = forAllSystems (system:
        let pkgs = pkgsFor.${system}; in
        {
          python = import ./devShells/python.nix { inherit pkgs; };
          nodejs = import ./devShells/nodejs.nix { inherit pkgs; };
          rust = import ./devShells/rust.nix { inherit pkgs; };
          go = import ./devShells/go.nix { inherit pkgs; };
          cpp = import ./devShells/cpp.nix { inherit pkgs; };
          java = import ./devShells/java.nix { inherit pkgs; };
        } // nixpkgs.lib.optionalAttrs (system == "x86_64-linux") {
          cuda = import ./devShells/cuda.nix { pkgs = pkgsFor.x86_64-linux; };
        }
      );
    };
}