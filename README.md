# 🌽 corny

rounded corners for your wayland compositor.

## table of contents

- [install](#install)
  - [nix flake](#nix-flake)
- [usage](#usage)
- [home-manager module](#home-manager-module)
- [dev](#dev)
- [license](#license)

## install

### nix flake

add to your `flake.nix` inputs:

```nix
corny = {
  url = "github:yaaaarn/corny";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

then add `corny.packages.${system}.default` to your `environment.systemPackages` or home-manager packages.

## usage

```
corny
```

can take a `--radius` (or `-r`) argument.

## home-manager module

```nix
{
  imports = [ corny.hmModules.default ];

  services.corny = {
    enable = true;
    radius = 16;
  };
}
```

## dev

```bash
# enter the dev shell (if using nix)
nix develop

# build
nix build .
```

## license

mit
