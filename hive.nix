let
  sources = import ./npins;
  goNixOverlay = import (sources.go_nix_example + "/nix/overlay.nix");
in
{
  meta = {
    nixpkgs = sources.nixpkgs;
  };
  
  "gonix" =
  {pkgs, config, ...}:
  {
    imports = [
      ./gonix/configuration.nix
      (sources.go_nix_example + "/nix/module.nix")
    ];
    deployment.targetHost = "gonix.mguentner.de";
    nixpkgs.overlays = [ goNixOverlay ];
  };
}
