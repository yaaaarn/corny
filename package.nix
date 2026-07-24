{
  stdenv,
  lib,
  vala,
  pkg-config,
  gtk3,
  gtk-layer-shell,
  gobject-introspection,
  ...
}:
stdenv.mkDerivation {
  pname = "corny";
  version = "unstable";

  src = ./.;

  nativeBuildInputs = [
    vala
    pkg-config
  ];

  buildInputs = [
    gtk3
    gtk-layer-shell
    gobject-introspection
  ];

  buildPhase = ''
    runHook preBuild
    valac --pkg gtk+-3.0 --pkg gtk-layer-shell-0 main.vala -o corny
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -Dm755 corny $out/bin/corny
    runHook postInstall
  '';

  meta = {
    description = "Rounded corners for your wayland compositor.";
    platforms = lib.platforms.linux;
  };
}
