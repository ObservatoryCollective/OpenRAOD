# shell.nix
let
  # We pin to a specific nixpkgs commit for reproducibility.
  # Last updated: 2024-04-29. Check for new commits at https://status.nixos.org.
  pkgs = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/cf8cc1201be8bc71b7cbbbdaf349b22f4f99c7ae.tar.gz") {};
  openglLibs = with pkgs; [
    mesa
    libGL
    libglvnd
    xorg.libX11
    xorg.libXrandr
    xorg.libXext
    xorg.libXcursor
    xorg.libXfixes
    xorg.libXi
    xorg.libXinerama
    xorg.libXxf86vm
  ];
in pkgs.mkShell {
  packages = [
    (pkgs.python3.withPackages (python-pkgs: with python-pkgs; [
      # select Python packages here
      pandas
      requests
    ]))
    #pkgs.mono
    pkgs.unzip
    pkgs.dotnet-sdk_6
    pkgs.dotnet-runtime_6
    pkgs.alsaLib
    pkgs.pulseaudio
    pkgs.libpulseaudio
    pkgs.SDL2
    pkgs.nsis
    pkgs.imagemagick
    pkgs.wine64
  ] ++ openglLibs;

  shellHook = ''
    export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath openglLibs}:$LD_LIBRARY_PATH
    export SDL_AUDIODRIVER=pipewire
    export PULSE_SERVER=unix:${pkgs.runtimeShell}/run/user/$(id -u)/pulse/native
  '';

}
