# pi.nix

A small Nix flake that packages the prebuilt [PI agent harness](https://github.com/earendil-works/pi) release tarballs.

## Usage

Run PI directly from the flake:

```sh
nix run github:earendil-works/pi.nix#pi
```

Or add the overlay to your own `nixpkgs` configuration:

```nix
{
  inputs.pi-nix.url = "github:earendil-works/pi.nix";

  outputs = { nixpkgs, pi-nix, ... }: {
    nixpkgs.overlays = [ pi-nix.overlays.default ];
  };
}
```

The overlay exposes the package as `pkgs.pi`.

## Updates

The flake is auto-updated every 12 hours using GitHub Actions (`.github/workflows/update-pi.yml`).
