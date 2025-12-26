{
  description = "Martijn's NixOS configuration (delft + london)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    stylix.url = "github:danth/stylix/release-25.11";
  };

  outputs = { self, nixpkgs, home-manager, stylix, ... }:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;

      # Only apply this overlay to delft (you needed it there)
      denoNoChecksOverlay = (final: prev: {
        deno = prev.deno.overrideAttrs (_old: {
          doCheck = false;
          checkPhase = "";
        });
      });

      mkPkgs = { overlays ? [ ] }:
        import nixpkgs {
          inherit system overlays;
          config = {
            allowUnfree = true;
            citrix_workspace.enableEULA = true;
          };
        };

      pkgsDelft = mkPkgs { overlays = [ denoNoChecksOverlay ]; };
      pkgsLondon = mkPkgs { overlays = [ ]; };
    in
    {
      nixosConfigurations = {
        delft = lib.nixosSystem {
          inherit system;
          pkgs = pkgsDelft;
          modules = [
            stylix.nixosModules.stylix
            ({ ... }: { _module.args.flakeRoot = self; })
            ./hosts/delft/default.nix
          ];
        };

        london = lib.nixosSystem {
          inherit system;
          pkgs = pkgsLondon;
          modules = [
            stylix.nixosModules.stylix
            ({ ... }: { _module.args.flakeRoot = self; })
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
            ({ ... }: { _module.args.flakeRoot = self; })
            ./home/martijn/default.nix
            ./home/martijn/hosts/delft.nix
          ];
        };

        "martijn@london" = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsLondon;
          modules = [
            stylix.homeModules.stylix
            ({ ... }: { _module.args.flakeRoot = self; })
            ./home/martijn/default.nix
            ./home/martijn/hosts/london.nix
          ];
        };
      };
    };
}

