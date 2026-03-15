{ inputs, self, ... }:
{
  flake.darwinModules.nix =
    { pkgs, ... }:
    {
      # manage nix's own config in /etc/nix/nix.conf
      nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
      nix.settings = {
        max-jobs = 0;
        substituters = [ "https://mirrors.ustc.edu.cn/nix-channels/store" ];
        experimental-features = "nix-command flakes pipe-operators";
        trusted-users = [
          "root"
          self.identity.username
        ];
      };
      nix.package = pkgs.nix;

      nixpkgs.hostPlatform = self.identity.arch;
    };
}
