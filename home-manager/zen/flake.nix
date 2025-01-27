{
  description = "Zen Browser (Local Tarball)";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};

    # Local tarball setup
    zenTarball = ./zen.linux-x86_64.tar.bz2;
    zenHash = "SiriLHGfnIsbpsOKTO0YjOvr/62Y7qJdfMT/oFczZ3o=";  # Get via: nix-prefetch-url file://$(pwd)/./zen.linux-x86_64.tar.bz2

    # Full dependency list from original flake
    runtimeLibs = with pkgs; [
      libGL
      libGLU
      libevent
      libffi
      libjpeg
      libpng
      libstartup_notification
      libvpx
      libwebp
      stdenv.cc.cc
      fontconfig
      libxkbcommon
      zlib
      freetype
      gtk3
      libxml2
      dbus
      xcb-util-cursor
      alsa-lib
      libpulseaudio
      pango
      atk
      cairo
      gdk-pixbuf
      glib
      udev
      libva
      mesa
      libnotify
      cups
      pciutils
      ffmpeg
      libglvnd
      pipewire
      speechd
    ] ++ (with pkgs.xorg; [
      libxcb
      libX11
      libXcursor
      libXrandr
      libXi
      libXext
      libXcomposite
      libXdamage
      libXfixes
      libXScrnSaver
    ]);

	desktopFile = "zen.desktop";

  in {
    packages.${system}.default = pkgs.stdenv.mkDerivation {
      pname = "zen-browser";
      version = "1.0.0";

      src = pkgs.fetchzip {
        url = "file://${zenTarball}";
        sha256 = zenHash;
      };
			desktopSrc = ./.;

      nativeBuildInputs = with pkgs; [ 
        autoPatchelfHook
        makeWrapper
        wrapGAppsHook
      ];

      buildInputs = runtimeLibs;

			installPhase = ''
				mkdir -p $out/opt/zen

				echo "=== DEBUG: Contents of \$src ==="
				ls -la $src
				echo "==============================="

				# Copy the ENTIRE extracted directory (zen/) into opt/zen
				cp -r $src/* $out/opt/zen

				# Symlink the binary
				mkdir -p $out/bin
				ln -s $out/opt/zen/zen $out/bin/zen

				install -D $desktopSrc/zen.desktop $out/share/applications/${desktopFile}

				install -D $src/browser/chrome/icons/default/default16.png $out/share/icons/hicolor/16x16/apps/zen.png
				install -D $src/browser/chrome/icons/default/default32.png $out/share/icons/hicolor/32x32/apps/zen.png
				install -D $src/browser/chrome/icons/default/default48.png $out/share/icons/hicolor/48x48/apps/zen.png
				install -D $src/browser/chrome/icons/default/default64.png $out/share/icons/hicolor/64x64/apps/zen.png
				install -D $src/browser/chrome/icons/default/default128.png $out/share/icons/hicolor/128x128/apps/zen.png
				'';

      fixupPhase = ''
				chmod 755 $out/bin/zen $out/opt/zen/*
        patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/opt/zen/zen
        wrapProgram $out/opt/zen/zen \
          --set LD_LIBRARY_PATH "${pkgs.lib.makeLibraryPath runtimeLibs}" \
          --set MOZ_LEGACY_PROFILES 1 \
          --set MOZ_ALLOW_DOWNGRADE 1

        # Repeat for other binaries if needed (zen-bin, glxtest, etc.)
      '';

      meta = {
				inherit desktopFile;

        description = "Zen Browser (Local Build)";
        homepage = "https://zen-browser.app";
        platforms = [ "x86_64-linux" ];
      };
    };
  };
}
