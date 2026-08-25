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

        iosevka = pkgs.fetchFromGitHub {
          owner = "be5invis";
          repo = "Iosevka";
          rev = "6b4ead9e628e754419049e70f485e841d917e486";
          hash = "sha256-1uczmW/DwSGXRXNob76AEHFcMPnodEiI9DzI8KSFJ8w=";
        };

        josefka = pkgs.stdenv.mkDerivation {
          pname = "Josefka";
          version = "0.0.0";

          src = iosevka;

          nativeBuildInputs = [ pkgs.nodejs pkgs.ttfautohint ];

          npmDeps = pkgs.fetchNpmDeps {
            src = iosevka;
            hash = "sha256-0+v+bMNL1QWuMRk3rQu8PRSeNJ459JVVhvnG1qlvty4=";
          };

          buildPhase = ''
            runHook preBuild

            cp ${./private-build-plans.toml} private-build-plans.toml

            export HOME="$PWD"
            npm ci --offline --cache "$npmDeps"
            npm run build -- all-super-ttc::Josefka

            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall
            mkdir -p $out
            cp -a dist/. $out/
            runHook postInstall
          '';
        };
      in {
        packages.default = josefka;

        devShells.default = pkgs.mkShell {
          packages = [ pkgs.nodejs pkgs.ttfautohint ];

          shellHook = ''
            export JOSEFKA_ROOT="$(git rev-parse --show-toplevel)"
            export NPM_CONFIG_CACHE="$JOSEFKA_ROOT/.npm"
            export PATH="$JOSEFKA_ROOT/node_modules/.bin:$PATH"
          '';
        };
      }
    );
}
