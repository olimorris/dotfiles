{ pkgs ? import <nixpkgs> {
    overlays = [
      (import (builtins.fetchTarball {
        url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
      }))
    ];
  }
}:
with pkgs;
mkShell {
  buildInputs = [
    neovim-nightly
    nodePackages.json-server
    nodePackages.eslint
    nodePackages.pyright
    nodePackages.prettier
    nodePackages.typescript-language-server
    nodePackages.vscode-css-languageserver-bin
    nodePackages.vscode-html-languageserver-bin
    nodePackages.vscode-json-languageserver
    nodePackages.yaml-language-server
    nodePackages.dockerfile-language-server-nodejs
    (lib.optional pkgs.stdenv.isLinux sumneko-lua-language-server)
  ];

  # shellHook = ''
  #   alias nvim="nvim -u ~/.config/nvim/init.lua"
  # '';
}
