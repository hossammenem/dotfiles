{ config, lib, pkgs, ... }:

{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  imports = [ ./hardware-configuration.nix ];

  # Bootloader
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi/";
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    useOSProber = true;
  };

  # Networking 
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;
  programs.nix-ld.enable = true; # Keep from current config

  # Time/Locale
  time.timeZone = "Africa/Cairo";
  i18n.defaultLocale = "en_US.UTF-8";

  # GNOME Desktop
  services.xserver = {
    enable = true;
    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;
    xkb.layout = "us";
    xkb.options = "eurosign:e,caps:escape";
  };

  # Audio
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # User config (Keep working setup)
  users.users.longassnixochad = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [ tree ];
    shell = pkgs.zsh;
  };

  environment.systemPackages = with pkgs; [
    home-manager

    neovim
    git
    tmux
    wget
    ghostty
    zsh

    firefox
    discord
    postman
    obs-studio

    btop
    usbutils
    pciutils
    micro
    smartmontools 
    lm_sensors   
    iotop       

    bat
    ripgrep
    ffmpeg-full
    imagemagick
    gimp
    unzip
    p7zip
    rsync
    duf    
    fd    
    jq   
    yq-go
    xclip

    gcc
    cmake
    gnumake

    python3
    pyright 
    (python3.withPackages (ps: [ ps.pip ]))  # Includes pip

    nodejs
    bun
    typescript-language-server

    ghc
    cabal-install
    haskell-language-server
    stack
  ];

  programs.zsh.enable = true;

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "24.11";
}
