{
  description = "RCU";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-22.05;
    utils.url = github:numtide/flake-utils;
    flake-compat = {
      url = github:input-output-hk/flake-compat;
      flake = false;
    };
  };

  outputs = { self, nixpkgs, utils, flake-compat }: {
    overlay = final: prev: {
      rcu = final.python38.pkgs.callPackage ./pkg.nix {
        productKey = builtins.getEnv "RCU_PRODUCT_KEY";
        buildUserManual = false;
      };
      rcuFull = final.rcu.override {
        buildUserManual = true;
      };
    };

  } // utils.lib.eachDefaultSystem (system: let
    inherit (nixpkgs) lib;
    pkgs = nixpkgs.legacyPackages.${system}.extend self.overlay;

    flake = {
      packages = {
        inherit (pkgs) rcu rcuFull;
      };
      defaultPackage = flake.packages.rcuFull;
      defaultApp.program = "${flake.defaultPackage}/bin/rcu";
    };
  in
    flake);
}
