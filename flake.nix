{
  description = "PI agent harness";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    systems.url = "github:nix-systems/default";

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    pi = {
      url = "github:earendil-works/pi";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      pi,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        pkgVersion = (builtins.fromJSON (builtins.readFile "${pi}/packages/agent/package.json")).version;

        systemMapping = {
          aarch64-darwin = "darwin-arm64";
          aarch64-linux = "linux-arm64";
          x86_64-darwin = "darwin-x64";
          x86_64-linux = "linux-x64";
        };
        releasePlatform = systemMapping.${system};
        releaseHashes = import ./pi-release-hashes.nix;

        piCmd = pkgs.stdenv.mkDerivation (finalAttrs: {
          pname = "pi";
          version = pkgVersion;

          src = fetchTarball {
            url = "https://github.com/earendil-works/pi/releases/download/v${pkgVersion}/pi-${releasePlatform}.tar.gz";
            name = "pi-coding-agent-${pkgVersion}";
            sha256 = releaseHashes.${releasePlatform};
          };

          installPhase = ''
            runHook preInstall

            mkdir "$out"
            cp -r "$src" "$out/bin"

            runHook postInstall
          '';
        });
      in
      {
        packages.pi = piCmd;
        devShells.default = pkgs.mkShellNoCC {
          packages = with pkgs; [
            piCmd
            nodejs
          ];
        };
      }
    )
    // {
      overlays.default = final: prev: {
        pi = self.packages.${final.stdenv.hostPlatform.system}.pi;
      };
    };
}
