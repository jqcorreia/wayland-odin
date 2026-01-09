{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      build_packages = with pkgs; [
        wayland
        wayland-scanner
        wayland-protocols
        odin
      ];
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = build_packages;
        shellHook = "zsh";
        name = "arena dev shell";
      };
    };
}
