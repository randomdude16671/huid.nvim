{
  description = "Implementation of Tsoding's issue tracker using his HUID's for Neovim";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    git-hooks.url = "github:cachix/git-hooks.nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      git-hooks,
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forEachSystem =
        f:
        nixpkgs.lib.genAttrs systems (
          system:
          f {
            inherit system;
            pkgs = import nixpkgs {
              inherit system;
            };
          }
        );
    in
    {

      formatter = forEachSystem (
        { pkgs, system }:
        let
          config = self.checks.${system}.pre-commit-check.config;
          inherit (config) package configFile;
          script = ''
            ${pkgs.getExe package} run --all-files --config ${configFile}
          '';
        in
        pkgs.writeShellScriptBin "pre-commit-run" script
      );

      checks = forEachSystem (
        { system, pkgs }:
        {
          pre-commit-check = git-hooks.lib.${system}.run {
            src = ./.;
            package = pkgs.prek;
            hooks = {
              nixfmt-rfc-style.enable = true;
              stylua.enable = true;

              convco.enable = true;
            };
          };
        }
      );

      devShells = forEachSystem (
        { pkgs, system }:
        let
          inherit (self.checks.${system}.pre-commit-check) shellHook enabledPackages;
        in
        {
          default = pkgs.mkShell {
            name = "huid";
            inherit shellHook;
            packages = [
              pkgs.lua-language-server
              pkgs.opencode
            ];
            buildInputs = enabledPackages;
          };
        }
      );

    };
}
