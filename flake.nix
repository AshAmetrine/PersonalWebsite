{
  description = "Personal Blog Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
          packages = (with pkgs; [ zig_0_15 esbuild zls_0_15 watchman woff2 ]);
        };
      });
  };
}
