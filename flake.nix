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
          pkgs = nixpkgs.legacyPackages.${system};
          packageDirs = builtins.attrNames (builtins.readDir ./pkgs);
          packages = builtins.listToAttrs (map (name: {
            inherit name;
            value = pkgs.callPackage (./pkgs + "/${name}") {};
          }) packageDirs);
        in
          packages;
      in
      {
        packages = forAllSystems importPackages;
        overlay = final: prev:
          let
            system = prev.system;
            packages = self.packages.${system};
          in
            packages;
      };
}