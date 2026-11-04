{ pkgs, unstable, inputs, ... }:
{
  programs.zsh.enable = true;
  programs.zsh.enableGlobalCompInit = false;
  users.users.tudor.shell = pkgs.zsh;
  environment.sessionVariables = {
    AGENT_BROWSER_EXECUTABLE_PATH = "${unstable.chromium}/bin/chromium";
    PKG_CONFIG_PATH = "${unstable.openssl.dev}/lib/pkgconfig";
    MISE_RUBY_COMPILE = "false";
  };

  systemd.tmpfiles.rules = [
    "d /home/tudor/.local/state/zsh 0700 tudor users -"
    "d /home/tudor/.local/share/zsh 0700 tudor users -"
  ];

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    extraSpecialArgs = { inherit unstable; };
    backupFileExtension = "hm-backup";
    users.tudor = { config, ... }:
      let
        link = path: config.lib.file.mkOutOfStoreSymlink
          "${config.home.homeDirectory}/dotfiles/${path}";
      in
      {
        imports = [ ../../home.nix inputs.rex.homeManagerModules.default ];
        programs.rex.sshGuard = false;
        services.rex = {
          enable = true;
          extraListen = [ "tailnet://:7297" ];
          extraArgs = [ "--tailnet-allow-identified" ];
        };
        manual.manpages.enable = false;
        home.packages = with unstable; [
          mise starship eza zoxide fd ripgrep lazygit lazydocker tmux
          fastfetch dust scc tokei ast-grep difftastic git-lfs tree-sitter
          shfmt stylua taplo yamlfmt uv ruff go bun pnpm pandoc typst
          yt-dlp rclone gnumake unzip
          beam.packages.erlang_29.erlang beam.packages.erlang_29.elixir_1_20
          agent-browser chromium
        ];
        home.file = {
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
            [credential "https://github.com"]
            	helper =
            	helper = !gh auth git-credential
            [credential "https://gist.github.com"]
            	helper =
            	helper = !gh auth git-credential
          '';
          ".local/share/zsh-defer".source = "${unstable.zsh-defer}/share/zsh-defer";
          ".local/share/zsh-syntax-highlighting".source =
            "${unstable.zsh-syntax-highlighting}/share/zsh-syntax-highlighting";
          ".local/share/zsh-history-substring-search".source =
            "${unstable.zsh-history-substring-search}/share/zsh-history-substring-search";
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
      };
  };



}
