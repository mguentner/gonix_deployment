{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot = {
    loader.grub.enable = true;
    loader.grub.devices = [ "/dev/sda" ];
    loader.efi.efiSysMountPoint = "/EFI";
  };

  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = lib.mkForce "us";
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
  ];

  users.users.root.openssh.authorizedKeys.keys = [
  	"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE7xJKSrG244SyJjbdIOUvDSbwaxCiJ8asQdcfEC7vw0 max@fw"
  ];
  
  networking = {
    hostName = "gonix";
    useDHCP = false;
    useNetworkd = true;
    nameservers = [
      "213.133.98.98"
      "213.133.99.99"
      "213.133.100.100"
    ];
    defaultGateway = { address = "172.31.1.1"; interface = "enp1s0"; };
    defaultGateway6 = { address = "fe80::1"; interface = "enp1s0"; };
    interfaces = {
      enp1s0 = {
        ipv4.addresses = [
          {
            address = "65.108.219.174";
            prefixLength = 32;
          }
        ];
        ipv4.routes = [ { address = "172.31.1.1"; prefixLength = 32; } ];
        ipv6.addresses = [
          {
            address = "2a01:4f9:c010:a79d::1";
            prefixLength = 64;
          }
        ];
        ipv6.routes = [ { address = "::"; prefixLength = 0; via = "fe80::1"; } ];
      };
    };
    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 443 ];
    };
  };

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "prohibit-password";
  };

  services.nginx = {
    enable = true;
    virtualHosts = {
      "gonix.mguentner.de" = {
        enableACME = true;
        forceSSL = true;
        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:1337";
          };
        };
      };
    };
  };
  
  services.go-nix = {
    enable = true;
    listenAddress = ":1337";
  };
  
  security.acme = {
    acceptTerms = true;
    defaults.email = "acme@mguentner.de";
  };
  
  system.stateVersion = "24.11";
}

