{
  description = "Custom Nix Packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      importPackages = system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config = {
              allowUnfree = true;
              allowUnsupportedSystem = true;
            };
          };

          packageDirs = builtins.attrNames (builtins.readDir ./pkgs);

          packageSet = builtins.listToAttrs (map (name: {
            inherit name;
            value = pkgs.callPackage (./pkgs + "/${name}") {};
          }) packageDirs);

          # Only include packages compatible with the current system in `default`
          defaultPackages = pkgs.lib.attrValues (
            pkgs.lib.filterAttrs (_: pkg:
              !(pkg.meta ? platforms) || pkgs.lib.elem system pkg.meta.platforms
            ) packageSet
          );
        in
          packageSet // {
            default = pkgs.symlinkJoin {
              name = "custom-nix-pkgs";
              paths = defaultPackages;
            };
          };
    in
    {
      packages = forAllSystems importPackages;

      overlays.default = final: prev: (
        let
          system = final.system;
          packages = self.packages.${system};
        in
          packages
      );
    };
}
