{
  description = "Martijn's NixOS configuration (delft + london)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    stylix.url = "github:danth/stylix/release-25.11";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, stylix, ... }:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;

      pkgsUnstable = import nixpkgs-unstable {
        inherit system;
        config = { allowUnfree = true; };
      };

      mkPkgs = { overlays ? [ ] }:
        import nixpkgs {
          inherit system overlays;
          config = {
            allowUnfree = true;
            citrix_workspace.enableEULA = true;
            permittedInsecurePackages = [
              "electron-38.8.4"
            ];
          };
        };

      pkgsDelft = mkPkgs { overlays = [ ]; };
      pkgsAmsterdam = mkPkgs { overlays = [ ]; };
      pkgsLondon = mkPkgs { overlays = [ ]; };
    in
    {
      nixosConfigurations = {
        delft = lib.nixosSystem {
          inherit system;
          pkgs = pkgsDelft;
          modules = [
            stylix.nixosModules.stylix
            ({ ... }: { _module.args.flakeRoot = self; _module.args.pkgsUnstable = pkgsUnstable; })
            ./hosts/delft/default.nix
          ];
        };

        amsterdam = lib.nixosSystem {
          inherit system;
          pkgs = pkgsAmsterdam;
          modules = [
            stylix.nixosModules.stylix
            ({ ... }: { _module.args.flakeRoot = self; _module.args.pkgsUnstable = pkgsUnstable; })
            ./hosts/amsterdam/default.nix
          ];
        };

        london = lib.nixosSystem {
          inherit system;
          pkgs = pkgsLondon;
          modules = [
            stylix.nixosModules.stylix
            ({ ... }: { _module.args.flakeRoot = self; _module.args.pkgsUnstable = pkgsUnstable; })
            ./hosts/london/default.nix
          ];
        };
      };

      # Separate HM outputs per host so host-specific wrappers never leak.
      homeConfigurations = {
        "martijn@delft" = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsDelft;
          modules = [
            stylix.homeModules.stylix
            ({ ... }: { _module.args.flakeRoot = self; _module.args.pkgsUnstable = pkgsUnstable; })
            ./home/martijn/default.nix
            ./home/martijn/hosts/delft.nix
          ];
        };

        "martijn@amsterdam" = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsAmsterdam;
          modules = [
            stylix.homeModules.stylix
            ({ ... }: { _module.args.flakeRoot = self; _module.args.pkgsUnstable = pkgsUnstable; })
            ./home/martijn/default.nix
            ./home/martijn/hosts/delft.nix
          ];
        };

        "martijn@london" = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsLondon;
          modules = [
            stylix.homeModules.stylix
            ({ ... }: { _module.args.flakeRoot = self; _module.args.pkgsUnstable = pkgsUnstable; })
            ./home/martijn/default.nix
            ./home/martijn/hosts/london.nix
          ];
        };
      };
    };
}

