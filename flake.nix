
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

          # Recursively find all pkgs/**/default.nix files
          recursePkgs = dir:
            let
              entries = builtins.attrNames (builtins.readDir dir);
              resolved = builtins.concatLists (builtins.map (name:
                let
                  sub = dir + "/${name}";
                  subEntries = builtins.readDir sub;
                in
                  if builtins.pathExists (sub + "/default.nix") then
                    [ { name = name; path = sub; } ]
                  else if subEntries != {} then
                    recursePkgs sub
                  else
                    []
              ) entries);
            in resolved;

          packages = recursePkgs ./pkgs;

          packageSet = builtins.listToAttrs (map ({ name, path }: {
            inherit name;
            value = pkgs.callPackage path {};
          }) packages);

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

