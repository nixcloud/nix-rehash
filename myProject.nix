{ pkgs ? import <nixpkgs>
  , lib ? (import <nixpkgs> {}).lib
  , name ? "myProject"
  , nix-rehash ? import ./. }:
    with lib;
  {
    container = nix-rehash.reContain {
      inherit name;
      configuration = [{
        services.openssh.enable = true;
        services.openssh.ports = [ 25 ];
        users.extraUsers.root.openssh.authorizedKeys.keys = [ (builtins.readFile ./id_rsa.pub) ];
        #environment.systemPackages = [ dfc ]; 
      }
      {
      }];
    };
  }

