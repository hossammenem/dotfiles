{ config, pkgs, system, inputs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "longassnixochad";
  home.homeDirectory = "/home/longassnixochad";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    inputs.zen-browser.packages."${system}".default

		pkgs.nodejs
		pkgs.bun
		pkgs.typescript-language-server
  ];

  programs.git = {
	  enable = true;
	  userName = "hossammenem";
	  userEmail = "hossammenem0102840@gmail.com";
	  extraConfig = {
		  init.defaultBranch = "master";
	  };
  }; 

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/longassnixochad/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
		# PATH = [ "" ];
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

	## ZSH
	programs.zsh = {
		enable = true;
		plugins = [
			{
				name = "zsh-autosuggestions";
				src = pkgs.zsh-autosuggestions;
			}
			{
				name = "zsh-syntax-highlighting";
				src = pkgs.zsh-syntax-highlighting;
			}
		];

		oh-my-zsh = {
			enable = true;
			plugins = [ "git" ];
			theme = "robbyrussell";
		};

		initExtra = ''
			bindkey '5;5u' forward-word

			copyFileContent() {
				if [ -z "$1" ]; then
					echo "Usage: copyfilepath <file_name>"
				else
					xclip -selection clipboard < $1
						echo "Content of $1 copied to clipboard"
						fi
			}

		copyFilePath() {
			if [ -z "$1" ]; then
				echo "Usage: copyfilepath <file_name>"
			else
				realpath "$1" | xclip -selection clipboard
					echo "Full path of $1 copied to clipboard"
					fi
		}
		'';
		shellAliases = {
			lla = "ls -la";
			vim = "nvim";
			rmd = "rm -rf";
			b = "cd ..";
			home = "cd ~";
			dtop = "cd ~/Desktop/";
			me = "cd ~/Desktop/me/";
			notes = "cd ~/Desktop/notes/";
			booksnshit = "cd ~/Desktop/booksnshit/";
			cfc = "copyFileContent";
			cfp = "copyFilePath";
			initValut = "cp -r ~/Desktop/notes/base/.* ./; cp -r ~/Desktop/notes/base/* ./";
			syncNotes = "notes; git add .; git commit -m \"sync\"; git push; popd";
		};
	};


	### Tmux
	programs.tmux = {
		enable = true;
		prefix = "C-s";
		keyMode = "vi";
		mouse = true;
		escapeTime = 0;
		terminal = "tmux-256color";
		extraConfig = ''
			bind r source-file ~/.tmux.conf

# Pane navigation
			bind-key h select-pane -L
			bind-key j select-pane -D
			bind-key k select-pane -U
			bind-key l select-pane -R

# Window management
			bind-key w new-window
			bind-key C-n next-window
			bind-key C-p previous-window
			bind-key C-x kill-window
			bind-key c split-window -h
			bind-key v split-window -v

# Copy mode
			bind -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe

# Terminal settings
			set-option -ga terminal-overrides "alacritty:Tc"

# Status bar styling
			set -g status-style "fg=default,bg=default"
			set -g window-status-style "fg=default,bg=default"
			set -g window-status-current-style "fg=default,bg=default"
			set -g window-status-format " #I:#W "
			set -g window-status-current-format " #I:#W*"
			set -g status-right "\"#H\" %a %d %b, %I:%M %p"
			'';
	};


## Ghostty
    programs.ghostty = {
      enable = true;
      settings = {
        # base
        class = "ghostty";
        # style
        theme = "GruvboxDarkHard";
        cursor-style = "block";
        # shell
        shell-integration = "detect";
        shell-integration-features = "no-cursor,sudo,no-title";
        # mouse
        mouse-hide-while-typing = true;
        mouse-scroll-multiplier = 1;
        mouse-shift-capture = true;
        # clipboard
        copy-on-select = "clipboard";
        clipboard-read = "allow";
        clipboard-trim-trailing-spaces = true;
        clipboard-paste-protection = true;
        # font
        font-size = 13;
        font-family = "JetBrainsMono Nerd Font";
        # window padding
        window-padding-x = 2;
        window-padding-y = 2;
        window-padding-balance = true;
        # keybinds
        keybind = [
          "ctrl+shift+v=paste_from_clipboard"
          "shift+insert=paste_from_selection"
          "ctrl+shift+r=reload_config"
          "ctrl+a=toggle_tab_overview"
        ];
      };
    };
}
