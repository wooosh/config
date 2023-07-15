{ config, pkgs, ... }:

let 
  sensitive = import ./sensitive.nix;
in {
  disabledModules = [ "programs/senpai.nix" ];
  imports = [ ./senpai.nix ];

  home.username = "monomara";
  home.homeDirectory = "/home/monomara";
  # home.sessionVariables.NIX_PATH = "nixpkgs=nixpkgs=flake:nixpkgs$\{NIX_PATH:+:$NIX_PATH}";

  programs.git = {
    enable = true;
    userName = "wooosh";
    userEmail = sensitive.git-email;
  };

  programs.gpg = {
    enable = true;
  };

  programs.password-store.enable = true;

  services.gpg-agent.enable = true;

  home.packages = with pkgs; [
    senpai
    vscode
    libnotify # notify-send
  ];

  programs.senpai = {
    enable = true;
    config = {
      address = sensitive.service.soju.address;
      nickname = sensitive.service.soju.nick;
      password-cmd = ["pass" "show" "selfhosted/soju"];
      highlight = ["minerva" "min" "emanon" "em" "monomara" "beetle"];
    };
    highlight-script = ''
      #!/bin/sh
      escape() {
        printf "%s" "$1" | sed 's#\\#\\\\#g'
      }

      notify-send -a IRC "[$BUFFER] $SENDER" "$(escape "$MESSAGE")"
    '';
  };

  home.stateVersion = "23.05";
  programs.home-manager.enable = true;
}
