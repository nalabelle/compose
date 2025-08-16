{
  description = "Development environment for compose project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
        };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            pre-commit
            shellcheck
            shfmt
            gnumake
            _1password-cli
          ];

          shellHook = ''
            echo "Development environment loaded"
            echo "Available tools:"
            echo "  - pre-commit: ${pkgs.pre-commit.version}"
            echo "  - shellcheck: ${pkgs.shellcheck.version}"
            echo "  - shfmt: ${pkgs.shfmt.version}"
            echo "  - gnumake: ${pkgs.gnumake.version}"
            echo "  - 1password-cli: ${pkgs._1password-cli.version}"
          '';
        };
      });
}
