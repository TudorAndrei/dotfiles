{ pkgs }:
[
  pkgs.neovim
  pkgs.codex
  pkgs.herdr
  pkgs.gh
  pkgs.forgejo-cli
  pkgs.nh
  pkgs.just
  # Runtime dependencies of the plugins in configs/herdr/plugins.txt.
  pkgs.nodejs
  pkgs.jq
  pkgs.fzf
  pkgs.worktrunk
  # Build tools for Herdr plugins distributed as Rust source.
  pkgs.cargo
  pkgs.rustc
  pkgs.stdenv.cc
  pkgs.pkg-config
]
