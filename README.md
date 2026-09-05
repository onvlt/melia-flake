# Melia email client flake

A standalone Nix flake for [Melia](https://melia.buxjr.com/), a modern email client for linux.

Package provided by this flake is wrapper around AppImage downloaded from GitHub releases.

## Usage

### Run directly

You can run Melia directly without installing it:

```bash
nix run git+https://code.nolog.cz/uwundrej/melia-flake
```

### Install in NixOS

Add this flake to your inputs:

```nix
inputs.melia = {
  url = "git+https://code.nolog.cz/uwundrej/melia-flake";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

Then add it to your packages:

```nix
environment.systemPackages = [
  inputs.melia.packages.${system}.default
];

# Melia is proprietary, so this option must be enabled.
nixpkgs.config.allowUnfree = true;
```

### Using the overlay

You can also apply the overlay so `pkgs.melia` is available directly:

```nix
nixpkgs.overlays = [
  inputs.melia.overlays.default
];
```

Then use it anywhere as `pkgs.melia`:

```nix
environment.systemPackages = with pkgs; [
  melia
];
```

## Development

To build the package locally:

```bash
nix build .
```

The binary will be available at `./result/bin/melia`.

## Contributing

If you find something broken or not working as expected, feel free to open an issue or submit a pull request.

## License

This flake is licensed under the [MIT License](./LICENSE.md).

The Melia email client itself is proprietary.
