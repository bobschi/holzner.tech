# Taken from https://averyan.ru/en/p/nix-flakes-hugo/
{
  description = "Florian Holzner's Professsional Website";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        page = pkgs.stdenv.mkDerivation {
          name = "holzner.tech";
          src = builtins.filterSource
            (path: type: !(type == "directory" &&
              (baseNameOf path == "themes" ||
                baseNameOf path == "public")))
            ./.;
          buildPhase = "${pkgs.hugo}/bin/hugo --minify";
          installPhase = "cp -r public $out";
          meta = with pkgs.lib; {
            description = "Florian Holzner's Professsional Website";
            platforms = platforms.all;
          };
        };
      in
      {
        packages = {
          page = page;
          default = page;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [ hugo pre-commit ];
        };
      });
}
