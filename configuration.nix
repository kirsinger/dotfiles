{ ... }:

{
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin";

  system.primaryUser = "kai"; 
  users.users.kai = {
    home = "/Users/kai";
  }; 

  system.stateVersion = 6;
  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      KeyRepeat= 2;  # Fast key repeat
      InitialKeyRepeat = 15;  # Short delay before repeat
      # _HIHideMenuBar = false;  # Auto-hide menu bar
      AppleShowAllExtensions = true;
    };
    dock.autohide = true; 
    dock.autohide-delay = 0.00;
    dock.show-recents = false;
    dock.persistent-apps = [
      { app = "/Applications/WezTerm.app"; }
      { app = "/Applications/Orion.app"; }
      { app = "/Applications/Google Chrome.app"; }
      { app = "/Applications/Figma.app"; }
      { app = "/Applications/Slack.app"; }
      { app = "/Applications/Utilities"; }
    ];
    dock.persistent-others = [];
    finder.FXPreferredViewStyle = "Nlsv";  # List view by default
    finder.CreateDesktop = false;  # Keep desktop clean
    trackpad.Clicking = true;  # Tap to click
  };
  
  nix-homebrew = {
    enable = true;
    user = "kai";
    autoMigrate = true;  # Clean any existing installation
  };
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";  # enforce installation via this config
    onActivation.autoUpdate = true;
    onActivation.extraFlags = [ "--force" ];
    brews = [
      "awscli"
      "docker"
      "herdr"
      "lazydocker"
      "mise"
    ];
    casks = [
      "claude-code"
      "figma"
      "karabiner-elements"
      "slack"
      "wezterm"
    ];
  };
}
