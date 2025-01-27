{ config, pkgs, system, inputs, ... }:
{ programs.home-manager.enable = true;

	home.username = "longassnixochad";
	home.homeDirectory = "/home/longassnixochad";

	home.packages = [ pkgs.fzf inputs.zen-browser.packages."${system}".default ];

	home.sessionVariables = {
		EDITOR = "nvim";
		VISUAL = "nvim";
		TERMINAL = "ghostty";
		BROWSER = "zen";
	};


	#####################################
	# My Programs
	#####################################
	programs.ghostty.enable = true;

	programs.git = {
		enable = true;
		userName = "hossammenem";
		userEmail = "hossammenem0102840@gmail.com";
		extraConfig = {
			init.defaultBranch = "master";
		};
	}; 

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
			source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
			source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

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
			cpb = "xclip -selection clipboard";
			zcd = "cd $(find . -type d -print | fzf)";
			ts= "tmux attach -t $(tmux ls | fzf | cut -d: -f1)";
		};
	};

	programs.fzf = {
		enable = true;
		enableZshIntegration = true;  # Critical for **<TAB>
	};

	### Tmux
	programs.tmux = {
		enable = true;
		prefix = "C-s";
		keyMode = "vi";
		mouse = true;
		escapeTime = 0;
		terminal = "tmux-256color";
		plugins = with pkgs.tmuxPlugins; [
			resurrect   # Session persistence
		];
		extraConfig = ''
			bind r source-file ~/.tmux.conf

			# Window management
			bind-key w new-window
			bind-key C-n next-window
			bind-key C-p previous-window
			bind-key C-x kill-window

			# window swapping
			bind -n M-H swap-window -t -1  # Alt+H to swap left
			bind -n M-L swap-window -t +1  # Alt+L to swap right

			# Pane navigation (both with and without Ctrl)
			bind-key h select-pane -L
			bind-key j select-pane -D
			bind-key k select-pane -U
			bind-key l select-pane -R
			bind-key C-h select-pane -L
			bind-key C-j select-pane -D
			bind-key C-k select-pane -U
			bind-key C-l select-pane -R

			# Spliting
			bind _ split-window -h
			bind - split-window -v

			# pane resizing
			bind -r H resize-pane -L 2
			bind -r J resize-pane -D 2
			bind -r K resize-pane -U 2
			bind -r L resize-pane -R 2

			# pane swapping
			bind > swap-pane -D       # swap current pane with the next one
			bind < swap-pane -U       # swap current pane with the previous one

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

			# ========== tmux-resurrect config ==========
			# Enable manual session persistence (no auto-save/restore)
			set -g @plugin 'tmux-plugins/tmux-resurrect'

			# Optional: Save Neovim sessions when saving tmux
			set -g @resurrect-strategy-nvim 'session'
			set -g @resurrect-capture-pane-contents 'on'  # Save terminal output

			# Optional: Change default save/restore keybinds (defaults: Ctrl-s/Ctrl-r)
			# bind-key S run-shell '~/.tmux/plugins/tmux-resurrect/scripts/save.sh'
			# bind-key R run-shell '~/.tmux/plugins/tmux-resurrect/scripts/restore.sh'
			'';
	};

	home.stateVersion = "24.05";
}
