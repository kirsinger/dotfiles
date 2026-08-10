{ config, pkgs, ... }:

let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
in

{
  home.username = "kai";
  home.homeDirectory = "/Users/kai";
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    ripgrep
    fd
    fzf
    jq
    lazygit
    lazydocker
    neovim
    nerd-fonts.hack
  ];

  fonts.fontconfig.enable = true;
  
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  home.sessionPath = [
    "$HOME/.local/share/mise/shims" 
  ];

  programs.git = {
    enable = true;
    settings.user = {
      name = "kirsinger";
      email = "kai.hirsinger@gmail.com";
    };
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initContent = ''
      bindkey '^f' autosuggest-accept
      
      #
      # AWS profiles
      #
      
      awsp() {
        export AWS_PROFILE="$1"
        export AWS_REGION=ap-southeast-2
      }
      
      _awsp_complete() {
        COMPREPLY=( $(compgen -W "$(sed -n 's/^\[profile \(.*\)\]$/\1/p; s/^\[\(.*\)\]$/\1/p' ~/.aws/config 2>/dev/null)" -- "$cur") )
      }
      complete -F _awsp_complete awsp
    '';
    shellAliases = {
      ".." = "cd ..";
      add = "git add .";
      push = "git push";
      pull = "git pull";
      m = "git switch main";
      cc = "claude";
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$cmd_duration$line_break$character";
      character = {
        success_symbol = "[>](purple)";
	error_symbol = "[>](red)";
      };
      cmd_duration.format = "[$duration]($style) ";
    };
  };

  home.file.".bash_profile".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.bash_profile";
  home.file.".config/wezterm".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/wezterm";
  home.file.".config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/nvim";
  home.file.".config/herdr".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/herdr";
  home.file.".claude/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.claude/settings.json";
  home.file."projects/mise.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/global.mise.toml";
}
