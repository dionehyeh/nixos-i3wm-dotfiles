{ config, pkgs, lib,  ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  #swapfiles
  swapDevices = [
  {
    device = "/swapfile";
    size = 8192; # optional, ignored if file already exists
  }
];

#enable notifications
services.dunst.enable = true;

  #enable bluetooth
  hardware.bluetooth = {
  enable = true;
  powerOnBoot = true;
};

  #enable blueman
  services.blueman.enable = true;


  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_IN";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_IN";
    LC_IDENTIFICATION = "en_IN";
    LC_MEASUREMENT = "en_IN";
    LC_MONETARY = "en_IN";
    LC_NAME = "en_IN";
    LC_NUMERIC = "en_IN";
    LC_PAPER = "en_IN";
    LC_TELEPHONE = "en_IN";
    LC_TIME = "en_IN";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

#get fonts
fonts.packages = with pkgs; [
  nerd-fonts.jetbrains-mono
  nerd-fonts.fira-code
  nerd-fonts.iosevka
];


#audio support and some other stuffs
services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };


# Zsh configuration
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    promptInit = ''eval "$(starship init zsh)"'';

    # Source history substring search on shell start
    interactiveShellInit = ''
      source ${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search/zsh-history-substring-search.zsh
    '';
  };

users.users.nabil.shell = pkgs.zsh;



  #enable flatpak support 
   xdg.portal = {
  enable = true;
  xdgOpenUsePortal = true;
  extraPortals = [
    pkgs.xdg-desktop-portal-gtk
  ];
};

#nvidia driver + OpenGL

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  # hardware.opengl has beed changed to hardware.graphics

  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia.modesetting.enable = true;
hardware.nvidia = {
  # Required for drivers >= 560
  open = true; # Set to false if you have an older card
  package = config.boot.kernelPackages.nvidiaPackages.latest;
};

#Nvidia prime with sync+offload

hardware.nvidia.prime = {
    offload = {
      enable = true;
      enableOffloadCmd = true;
    };

    # integrated
    amdgpuBusId = "PCI:5:0:0";
    
    # dedicated
    nvidiaBusId = "PCI:1:0:0";
  };

  specialisation = {
    gaming-time.configuration = {

      hardware.nvidia = {
        prime.sync.enable = lib.mkForce true;
        prime.offload = {
          enable = lib.mkForce false;
          enableOffloadCmd = lib.mkForce false;
        };
      };

    };
  };





# Define the mount point for your NTFS HDD
  fileSystems."/mnt/HDD" = {
    device = "/dev/disk/by-uuid/42B40D6CB40D642F";
    fsType = "ntfs-3g";
    options = [
      "uid=1000"
      "gid=1000"
      "dmask=022"
      "fmask=133"
      "nofail"
      "noatime"
      "windows_names"
    ];
  };

  # Enable udisks2 for automounting
  services.udisks2.enable = true;

  # Add udev rule for automounting external HDD
  services.udev.extraRules =
    let
      udisksctl = "${pkgs.udisks}/bin/udisksctl";
    in ''
      ACTION=="add", SUBSYSTEM=="block", ENV{ID_FS_UUID}=="42B40D6CB40D642F", RUN+="${udisksctl} mount -b /dev/%k"
      ACTION=="remove", SUBSYSTEM=="block", ENV{ID_FS_UUID}=="42B40D6CB40D642F", RUN+="${udisksctl} unmount -b /dev/%k"
    '';



  # define the display server
  services.xserver = {
    enable = true;
     

    windowManager.i3 = {
      enable = true;
    };

    # Disable default display managers
    displayManager.lightdm.enable = false;
    displayManager.startx.enable = false;
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;




  #ly display manager
  services.displayManager.ly = {
    enable = true;
    settings= {
      clear_password = true;
    };
  };
  #define input settings
  services.xserver.libinput = {
  enable = true;

  touchpad = {
    tapping = true;               # Single-finger tap = left click
    clickMethod = "clickfinger";  # 2 fingers = right click, 3 fingers = middle
    naturalScrolling = true;
    disableWhileTyping = true;
  };

  mouse = {
    accelProfile = "flat";        # Disable mouse acceleration
  };
};



  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."nabil" = {
    isNormalUser = true;
    description = "Nabil K Sabu";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget


#remove packages that you dont need
services.xserver.excludePackages = with pkgs; [
  xterm
];







environment.systemPackages = with pkgs; [

  ########################
  ## Editors & Terminal ##
  ########################

  neovim
  zed-editor

  alacritty
  alacritty-theme
  zsh
  starship

  #################
  ## Browsers/App ##
  #################
  
  librewolf
  discord
  onlyoffice-desktopeditors
  #################
  ## File Manager ##
  #################
  file-roller
  kdePackages.dolphin
  ntfs3g

  #################
  ## Desktop      ##
  #################

  rofi
  polybar
  picom
  nitrogen
  flameshot

  networkmanagerapplet
  blueman
  pulseaudio
  pavucontrol
  brightnessctl
  libnotify
  #################
  ## Utilities    ##
  #################

  fastfetch
  htop
  ncdu
  tree
  file

  jq
  yq

  wget
  curl
  aria2

  unzip
  zip

  git
  gh
  gitui

  ripgrep
  fd
  fzf

  xclip
  xev

  pciutils
  usbutils

  imagemagick
  ffmpeg

  #################
  ## Build Tools  ##
  #################

  gcc
  clang
  clang-tools
  llvmPackages.lldb

  gnumake
  cmake
  cmake-language-server
  pkg-config
  gdb

  #################
  ## Node / Web   ##
  #################

  nodejs

  prettier
  eslint

  typescript
  typescript-language-server
  vtsls

  biome
  oxlint

  tailwindcss-language-server
  vue-language-server

  #################
  ## Lua          ##
  #################

  lua
  lua-language-server
  stylua

  #################
  ## Python       ##
  #################
  
  python313Packages.pip
  python3
  basedpyright
  python313Packages.black
  python313Packages.isort
  python313Packages.flake8

  #################
  ## Nix          ##
  #################

  nil
  nixfmt-rfc-style

  #################
  ## Shell        ##
  #################

  bash-language-server
  shellcheck
  shfmt

  #################
  ## Go           ##
  #################

  go
  gopls
  golangci-lint

  #################
  ## Java         ##
  #################

  jdk
  jdt-language-server

  #################
  ## Kotlin       ##
  #################

  kotlin
  kotlin-language-server

  #################
  ## Rust         ##
  #################

  rustc
  cargo
  rust-analyzer

  #################
  ## PHP          ##
  #################

  php
  phpactor
  
  # Modern file listing & icons
    eza
zsh-history-substring-search

  #################
  ## Docker       ##
  #################

  dockerfile-language-server-nodejs
  docker-compose-language-service

  #################
  ## Config Files ##
  #################

  yaml-language-server
  taplo

  #################
  ## Markdown     ##
  #################

  marksman
  markdownlint-cli

  #################
  ## SQL          ##
  #################

  sqlfluff

  #################
  ## Typst        ##
  #################

  typst
  tinymist

  #################
  ## Zig          ##
  #################

  zig
  zls

  #################
  ## Terraform    ##
  #################

  terraform
  terraform-ls

  #################
  ## Tree-sitter  ##
  #################

  tree-sitter

  #################
  ## Lenovo       ##
  #################

  (callPackage
    (fetchTarball "https://github.com/nabilksabu/vantage-nix/archive/main.tar.gz")
    {})
];




# Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?

}
