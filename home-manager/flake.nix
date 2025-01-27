{
	description = "Flake configuration of longassnixochad";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

		zen-browser = {
			url = "path:./zen";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		home-manager = {
			url = "github:nix-community/home-manager";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = { nixpkgs, home-manager, zen-browser, ... } @inputs:
		let
			system = "x86_64-linux";
			pkgs = nixpkgs.legacyPackages.${system};
		in {

			nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
				inherit system;
				specialArgs = { inherit inputs; };
				modules = [ 
					./configuration.nix 
					# Optional: Add Home Manager as NixOS module
					home-manager.nixosModules.home-manager
					{
						home-manager.useGlobalPkgs = true;
						home-manager.useUserPackages = true;
						home-manager.users.longassnixochad = import ./home.nix;
					}
				];
			};

			homeConfigurations."longassnixochad" = home-manager.lib.homeManagerConfiguration {
				inherit pkgs;

				# Pass inputs to home.nix
				extraSpecialArgs = { inherit inputs system; };

				# Specify your home configuration modules here, for example,
				# the path to your home.nix.
				modules = [ ./home.nix ];
			};
		};
}
