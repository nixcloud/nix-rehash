==========
nix-rehash
==========


Nix development utils that will blow up your mind


reService - fullstack@dev
--------------------------

reService takes your nixos config of services and creates user-enabled supervisord
config that you can use for development or deployment on non nixos systems.
Having deterministic fullstack in development has never been more awesome.

- Create `default.nix`

  ```
  { pkgs ? import <nixpkgs> {}
  , projectName ? "myProject"
  , lib ? (import <nixpkgs> {}).lib
  , nix-rehash ? import <nix-rehash> }:
    with lib;

  let
    services = nix-rehash.reService {
      name = "${projectName}";
      configuration = let servicePrefix = "/tmp/${projectName}/services"; in [
        ({ config, pkgs, ...}: {
          services.postgresql.enable = true;
          services.postgresql.package = pkgs.postgresql92;
          services.postgresql.dataDir = "${servicePrefix}/postgresql";
        })
      ];
    };
  in myEnvFun {
    name = projectName;
    buildInputs = [ services ];
  }
  ```

- install `nix-env -f default.nix -i`
- load environemnt `load-env-myProject`
- start services `myProject-start-services`, control services `myProject-control-services`,
  stop services `myProject-stop-services`

Now build this with hydra and pass the environment around :)

Alternative using nix-shell:

- set `buildInputs = [ services.config.supervisord.bin ];`
- run `nix-shell`
- use `supervisord` and `supervisorctl` as you wish

reContain - heroku@home
-----------------------

reContain makes nixos enabled installable container that can auto-update
itself. Now you can build container on hydra and auto update it on
host machine. Staging or deployments have never been easier :)

- Create `default.nix`

  ```
  { pkgs ? import <nixpkgs>
  , lib ? (import <nixpkgs> {}).lib
  , name ? "myProject"
  , nix-rehash ? import <nix-rehash> }:
    with lib;
    with pkgs;

  {
    container = nix-rehash.reContain {
      inherit name;
      configuration = [{
      services.openssh.enable = true;
      services.openssh.ports = [ 25 ];
      users.extraUsers.root.openssh.authorizedKeys.keys = [ (builtins.readFile ./id_rsa.pub) ];
      }];
    };
  }
  ```
- do `nix-env [-f default.nix] -i myProject-container` or build with hydra and add a channel
- start container: `sudo myProject-container-start`
- ssh to container: `ssh localhost -p 25`
- enable auto updates with cron:
  ```
  * * * * * nix-env -i myProject-container && sudo $HOME/.nix-profile/bin/myProject-update-container
  ```
- stop container: `sudo myProject-container-stop`

- debuggin: just pass additional paramters to the lxc-start invocation:
  `myProject-container-start -F `

- lxc-attach -n myProject 
  hacky way to get a console in the lxc container named myProject

- check if the system kernel has all features required to run lxc containers:
  lxc-checkconfig

- if stuff isn't working try: 
    bash
  or 
    source /etc/profile


http://unix.stackexchange.com/questions/170998/how-to-create-user-cgroups-with-systemd

TODO unpriviliged containers:  
- not working (systemd) https://www.flockport.com/lxc-and-lxd-support-across-distributions/
- some stuff workes better with cgmanager enabled
- https://wiki.archlinux.org/index.php/Linux_Containers#Systemd_considerations_.28required.29
