{
  description = "Personal Blog Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs = { nixpkgs, ... }: let
    inherit (nixpkgs) lib;
    forAllSystems = lib.genAttrs lib.systems.flakeExposed;
  in {
    devShells = forAllSystems(system: 
      let
        pkgs = import nixpkgs { inherit system; };
      in {
        default = pkgs.mkShell {
          name = "blog-devshell";
          packages = with pkgs; [ zig zls bun watchman woff2 ];
        };
      });
  };
}
