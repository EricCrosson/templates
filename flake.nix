{
  description = "esc's flake templates";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    pre-commit-hooks,
    ...
  }:
    {
      templates = {
        rust-binary = {
          path = ./rust-binary;
          description = "Rust binary project scaffold";
        };
      };
    }
    // flake-utils.lib.eachDefaultSystem (
      system: let
        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            actionlint.enable = true;
            alejandra.enable = true;
            prettier.enable = true;
          };
        };
      in {
        checks = {inherit pre-commit-check;};
        devShells = {
          default = nixpkgs.legacyPackages.${system}.mkShell {
            inherit (self.checks.${system}.pre-commit-check) shellHook;
          };
        };
      }
    );
}
