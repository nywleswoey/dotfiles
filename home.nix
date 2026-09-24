{ config, pkgs, user, ... }:

let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
in

{
  home.username = user;
  home.homeDirectory = "/Users/${user}";
  home.stateVersion = "24.11";
  home.packages = with pkgs; [
    # cli i use constantly
    ripgrep   # fast search
    fd        # fast find
    fzf       # fuzzy finder
    jq        # json on the command line
    lazygit
    neovim
    # the font everything renders in
    nerd-fonts.hack
  ];
  fonts.fontconfig.enable = true;
  home.sessionVariables.EDITOR = "nvim";
  # ~/.claude/settings.json is untracked (it holds a live API token), so this
  # env var can't live there. Claude Code reads it from the shell env instead.
  # ponytail: login-shell only; move to an activation script that merges the key
  # into ~/.claude/settings.json if a GUI-launched Claude ever needs it.
  home.sessionVariables.CLAUDE_CODE_ENABLE_FUNCTION_HOOKS = "1";

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;      # ghost text from history
    syntaxHighlighting.enable = true;  # commands turn green when valid
    history = {
      size = 100000;
      save = 100000;
      extended = true;                 # timestamp + duration per command
      ignoreAllDups = true;
      saveNoDups = true;
      expireDuplicatesFirst = true;
      findNoDups = true;
    };
    initContent = ''
      bindkey '^f' autosuggest-accept
      setopt HIST_REDUCE_BLANKS
      setopt HIST_VERIFY            # `!!` expands onto the line instead of running blind
      # Don't exit the shell on EOF. Some installers (pnpm and its supply-chain
      # policy check) consume and close stdin; without this the terminal closes
      # mid-install and the host app reports it as a launch failure.
      setopt IGNORE_EOF

      # Secret lives in the login Keychain, not in this repo.
      # Store once: security add-generic-password -s typesafe-api-key -a "$USER" -w
      export TYPESAFE_API_KEY="$(security find-generic-password -s typesafe-api-key -w 2>/dev/null)"
    '';
    shellAliases = {
      ".." = "cd ..";
      add = "git add .";
      ga = "git add";
      gc = "git commit -v";
      push = "git push";
      pull = "git pull";
      m = "git switch main";
      g = "git";
      gpf = "git push --force-with-lease";
      glo = "git log --oneline";
      grbi = "git rebase --interactive";
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$cmd_duration$line_break$character";
      character = {
        success_symbol = "[❯](purple)";
        error_symbol = "[❯](red)";
      };
      cmd_duration.format = "[$duration]($style) ";
    };
  };

  # Edit-in-place: the real file stays in my repo, ~/.config just points at it.
  home.file.".gitconfig".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/gitconfig/.gitconfig";

  home.file.".config/wezterm".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/wezterm";
  home.file.".config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/nvim";
  home.file.".config/herdr".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/herdr";
  # Untracked (holds a live API token) - the symlink dangles on a fresh clone
  # until Claude Code writes its own. That's fine: the settings this repo cares
  # about are set via home.sessionVariables above.
  home.file.".claude/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.claude/settings.json";

  # Keep Pi's credential and runtime state local by linking only authored files and directories.
  home.file.".pi/agent/themes".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/themes";
  home.file.".pi/agent/extensions".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/extensions";
  home.file.".pi/agent/models.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/models.json";
  home.file.".pi/agent/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/settings.json";

  home.file.".claude/CLAUDE.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".codex/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".config/opencode/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
}
