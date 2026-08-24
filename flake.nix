{
  description = "Josefka";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          packages = builtins.attrValues {
            inherit (pkgs)
            nodejs ttfautohint;
          };

          shellHook = ''
            export JOSEFKA_ROOT="$(git rev-parse --show-toplevel)"
            export NPM_CONFIG_CACHE="$JOSEFKA_ROOT/.npm"
            export PATH="$JOSEFKA_ROOT/node_modules/.bin:$PATH"
          '';
        };
      }
    );
}
