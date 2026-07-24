{
  description = "corny";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      packages = forAllSystems (system: {
        default = nixpkgs.legacyPackages.${system}.callPackage ./package.nix { };
      });

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              gcc
              pkg-config
              gtk3
              gtk-layer-shell
              vala
              gobject-introspection
            ];
          };
        }
      );

      hmModules.default =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        let
          cfg = config.services.corny;
        in
        {
          options.services.corny = {
            enable = lib.mkEnableOption "Corny daemon";
            package = lib.mkOption {
              type = lib.types.package;
              default = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
              description = "The corny package to use.";
            };
            radius = lib.mkOption {
              type = lib.types.nullOr lib.types.int;
              description = "Corner radius.";
            };
          };

          config = lib.mkIf cfg.enable {
            systemd.user.services.corny = {
              Unit = {
                Description = "corny daemon (user service)";
                After = [ "graphical-session.target" ];
              };
              Install = {
                WantedBy = [ "graphical-session.target" ];
              };
              Service = {
                ExecStart = "${cfg.package}/bin/corny${lib.optionalString (cfg.radius != null) " -r ${toString cfg.radius}"}";
                Restart = "on-failure";
              };
            };
          };
        };
    };
}
