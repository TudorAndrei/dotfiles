{ config, unstable, ... }:
let
  link = path: config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/dotfiles/${path}";
in
{
  home = {
    username = "tudor";
    homeDirectory = "/home/tudor";
    stateVersion = "26.05";
    packages = import ./packages.nix { pkgs = unstable; } ++ (with unstable; [
      zsh mise starship eza zoxide fd ripgrep lazygit lazydocker tmux
      fastfetch dust scc tokei ast-grep difftastic git-lfs tree-sitter
      shfmt stylua taplo yamlfmt uv ruff go bun pnpm pandoc typst
      yt-dlp rclone gnumake unzip btop htop
      beam.packages.erlang_29.erlang beam.packages.erlang_29.elixir_1_20
      agent-browser chromium cursor-cli
      (writeShellScriptBin "agent" ''exec ${cursor-cli}/bin/cursor-agent "$@"'')
    ]);
    sessionVariables = {
      NH_HOME_FLAKE = "/home/tudor/dotfiles/nix";
      NH_OS_FLAKE = "/home/tudor/dotfiles/nix";
    };
    activation.zshStateDirs = config.lib.dag.entryAfter [ "writeBoundary" ] ''
      run mkdir -p -m 0700 "$HOME/.local/state/zsh" "$HOME/.local/share/zsh"
    '';
    file = {
      ".zshrc".source = link "configs/zsh/zshrc";
      ".zshenv".source = link "configs/zsh/zshenv";
      ".tmux.conf".source = link "configs/tmux/tmux.conf";
      ".gitignore_global".source = link "gitconfig/gitignore_global";
      ".gitconfig".source = link "gitconfig/gitconfig";
      ".gitconfig-pythia".source = link "gitconfig/gitconfig-pythia";
      ".gitconfig-cave".source = link "gitconfig/gitconfig-cave";
      ".gitconfig.local".text = ''
        [commit]
        	gpgsign = false
      '';
      ".local/share/zsh-defer".source = "${unstable.zsh-defer}/share/zsh-defer";
      ".local/share/zsh-syntax-highlighting".source =
        "${unstable.zsh-syntax-highlighting}/share/zsh-syntax-highlighting";
      ".local/share/zsh-history-substring-search".source =
        "${unstable.zsh-history-substring-search}/share/zsh-history-substring-search";
    };
  };
  xdg.configFile = {
    "zsh".source = link "configs/zsh";
    "starship.toml".source = link "configs/starship/starship.toml";
    "tmux".source = link "configs/tmux";
    "nvim".source = link "nvim";
    "rex".source = link "configs/rex";
    "mise/config.toml".text = ''
      [settings]
      all_compile = false
      disable_tools = ["erlang", "elixir"]
    '';
  };
}
