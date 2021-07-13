{ pkgs ? import <nixpkgs> {
    overlays = [
      (import (builtins.fetchTarball {
        url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
      }))
    ];
  }
}:
with pkgs;
let 
  my-python-packages = python-packages: with python-packages; [
      django
      debugpy
      flake8
      neovim-remote
      pandas
      pyflakes
      requests
    ];
    python-with-my-packages = python3.withPackages my-python-packages;
in
mkShell {
  buildInputs = [
    neovim-nightly
    pkgs.gopls
    pkgs.python3
    pkgs.poetry
    python-with-my-packages
    nodePackages.bash-language-server
    nodePackages.dockerfile-language-server-nodejs
    nodePackages.eslint
    nodePackages.json-server
    nodePackages.prettier
    nodePackages.pyright
    nodePackages.typescript-language-server
    nodePackages.vim-language-server
    # nodePackages.vls
    nodePackages.vscode-css-languageserver-bin
    nodePackages.vscode-html-languageserver-bin
    nodePackages.vscode-json-languageserver
    nodePackages.yaml-language-server
  ];

  shellHook = ''
    # alias nvim="nvim -u ~/.config/nvim/init.lua"
  '';
}
