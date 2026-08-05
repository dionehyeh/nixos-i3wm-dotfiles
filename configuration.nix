{ config, pkgs, lib, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # Boot
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 10;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  boot.loader.systemd-boot.extraEntries = {
    "windows.conf" = ''
      title Windows
      efi /EFI/Microsoft/Boot/bootmgfw.efi
    '';
  };

  boot.kernelParams = [
    "amd_pstate=active"
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
  ];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Network
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Locale
  time.timeZone = "Asia/Kolkata";
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

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Display
  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = false;
    displayManager.startx.enable = false;
    windowManager.i3.enable = true;
    desktopManager.xterm.enable = false;
  };
  
  services.displayManager.sddm={
    enable=true;
    theme="sddm-astronaut-theme";
     extraPackages = [
      (pkgs.sddm-astronaut.override {
       embeddedTheme = "black hole";
      })

     ];
    


  };


  programs.xwayland.enable = true;

  # Input
  services.libinput = {
    enable = true;
    touchpad = {
      tapping = true;
      clickMethod = "clickfinger";
      naturalScrolling = true;
      disableWhileTyping = true;
    };
    mouse.accelProfile = "flat";
  };

  # Audio
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };
  services.blueman.enable = true;

  # Notifications
  services.dunst.enable = true;

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.iosevka
  ];

  # Shell
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    promptInit = ''eval "$(starship init zsh)"'';
    interactiveShellInit = ''
      source ${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search/zsh-history-substring-search.zsh
    '';
  };
  users.users.nabil.shell = pkgs.zsh;

  # Portal
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

  # Graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # NVIDIA
  services.xserver.videoDrivers = [ "amdgpu" "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    powerManagement.enable = true;
    powerManagement.finegrained = true;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      amdgpuBusId = "PCI:5:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # Gaming specialisation
  specialisation.gaming-time.configuration = {
    hardware.nvidia = {
      powerManagement.enable = lib.mkForce false;
      powerManagement.finegrained = lib.mkForce false;
      prime.sync.enable = lib.mkForce true;
      prime.offload = {
        enable = lib.mkForce false;
        enableOffloadCmd = lib.mkForce false;
      };
    };
  };

  # Power management
  services.auto-cpufreq = {
    enable = true;
    settings = {
      charger = {
        governor = "performance";
        turbo = "auto";
        energy_performance_preference = "performance";
      };
      battery = {
        governor = "powersave";
        turbo = "never";
        energy_performance_preference = "power";
      };
    };
  };

  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "";
      CPU_SCALING_GOVERNOR_ON_BAT = "";
      CPU_BOOST_ON_AC = "";
      CPU_BOOST_ON_BAT = "";
      USB_AUTOSUSPEND = 1;
      SOUND_POWER_SAVE_ON_BAT = 1;
      SOUND_POWER_SAVE_CONTROLLER = "Y";
      WIFI_PWR_ON_BAT = "on";
      RUNTIME_PM_ON_BAT = "auto";
      STOP_CHARGE_THRESH_BAT0 = 1;
    };
  };

  services.power-profiles-daemon.enable = false;
  powerManagement.powertop.enable = true;
  services.fstrim.enable = true;
  hardware.ksm.enable = true;
  services.logind.settings.Login.HandleLidSwitch = "suspend";

  # Swap
  swapDevices = [{
    device = "/swapfile";
    size = 8192;
  }];

  # HDD
  fileSystems."/mnt/HDD" = {
    device = "/dev/disk/by-uuid/42B40D6CB40D642F";
    fsType = "ntfs-3g";
    options = [
      "uid=1000" "gid=1000" "dmask=022" "fmask=133"
      "nofail" "noatime" "windows_names"
    ];
  };

  services.udisks2.enable = true;

  services.udev.extraRules =
    let udisksctl = "${pkgs.udisks}/bin/udisksctl";
    in ''
      ACTION=="add", SUBSYSTEM=="block", ENV{ID_FS_UUID}=="42B40D6CB40D642F", RUN+="${udisksctl} mount -b /dev/%k"
      ACTION=="remove", SUBSYSTEM=="block", ENV{ID_FS_UUID}=="42B40D6CB40D642F", RUN+="${udisksctl} unmount -b /dev/%k"
    '';

  # Printing
  services.printing.enable = true;

  # User
  users.users.nabil = {
    isNormalUser = true;
    description = "Nabil K Sabu";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  nixpkgs.config.allowUnfree = true;

  # Packages
  environment.systemPackages = with pkgs; [
    neovim zed-editor alacritty alacritty-theme zsh starship
    librewolf discord onlyoffice-desktopeditors
    file-roller kdePackages.dolphin ntfs3g
    rofi polybar picom nitrogen flameshot
    networkmanagerapplet blueman pavucontrol brightnessctl libnotify
    fastfetch htop ncdu tree file jq yq
    powertop auto-cpufreq ryzenadj
    wget curl aria2 arandr unzip zip
    git gh gitui ripgrep fd fzf
    xclip xev pciutils usbutils
    imagemagick ffmpeg
    gcc clang clang-tools llvmPackages.lldb
    gnumake cmake cmake-language-server pkg-config gdb
    nodejs prettier eslint typescript typescript-language-server vtsls
    biome oxlint tailwindcss-language-server vue-language-server
    lua lua-language-server stylua
    python313Packages.pip python3 basedpyright
    python313Packages.black python313Packages.isort python313Packages.flake8
    nil nixfmt pulseaudio
    bash-language-server shellcheck shfmt
    go gopls golangci-lint
    jdk jdt-language-server
    kotlin kotlin-language-server
    rustc cargo rust-analyzer
    php phpactor
    eza zsh-history-substring-search
    dockerfile-language-server docker-compose-language-service
    yaml-language-server taplo
    marksman markdownlint-cli
    sqlfluff
    typst tinymist
    zig zls (pkgs.sddm-astronaut.override {embeddedTheme = "black hole";})
    terraform terraform-ls
    tree-sitter
    (callPackage (fetchTarball "https://github.com/nabilksabu/vantage-nix/archive/main.tar.gz") {})
  ];

  system.stateVersion = "26.05";
}
