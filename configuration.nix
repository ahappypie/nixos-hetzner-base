{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware.nix
      ./disko.nix
    ];

  system.stateVersion = "25.05";

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  nix.extraOptions = ''experimental-features = nix-command flakes'';

  security.sudo.wheelNeedsPassword = false;

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    extraConfig = ''
      PrintLastLog no
    '';
  };

  programs.zsh.enable = true;
  environment.shells = [ pkgs.zsh ];
  environment.enableAllTerminfo = true;

  users.users.admin = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" ];
    initialHashedPassword = "";

    openssh.authorizedKeys.keys = [
      #TODO
    ];
  };
}
