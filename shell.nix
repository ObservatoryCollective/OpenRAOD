let
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

  # ✅ This creates a clean derivation that provides `liblua51.so`
  lua51CompatLib = pkgs.runCommand "lua51-shim" {
    nativeBuildInputs = [];
  } ''
    mkdir -p $out/lib
    ln -s ${pkgs.lua5_1}/lib/liblua.so.5.1 $out/lib/liblua51.so
  '';

in pkgs.mkShell {
  packages = [
    (pkgs.python3.withPackages (python-pkgs: with python-pkgs; [
      pandas
      requests
    ]))
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
    pkgs.pipewire
    pkgs.lua5_1
  ] ++ openglLibs;

  shellHook = ''
    export SDL_AUDIODRIVER=pulse
    export PULSE_SERVER=unix:/run/user/$(id -u)/pulse/native

    export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath (openglLibs ++ [
      pkgs.libpulseaudio
      pkgs.lua5_1
      lua51CompatLib
    ])}:$LD_LIBRARY_PATH
  '';
}
