{
    description = "shafti's macbook system config";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";
        nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
        nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
        nix-homebrew.url = "github:zhaofengli/nix-homebrew";
        nixd.url = "github:nix-community/nixd";
    };

    outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, nixd }:
        let
        configuration = { pkgs, config, ... }: {
# List packages installed in system profile. To search by name, run:
# $ nix-env -qaP | grep wget

            nixpkgs.config.allowUnfree = true;
            environment.systemPackages = with pkgs; [
                aria2
                btop
                cava
                cloc
                cmake
                curl
                emacs
                fastfetch
                ffmpeg
                ftxui
                fzf
                gcc
                gdb
                gh
                git
                gnugrep # Homebrew's `grep` is typically GNU grep
                helix
                htop
                lua-language-server
                mkalias
                ncurses
                neofetch
                neovim
                nixd
                pnpm
                presenterm
                ripgrep
                starship
                tmux
                tree
                wget
                yarn
                yt-dlp
                zig
                zls
            ];
            system.primaryUser = "shafti";
            homebrew = {
                enable = true;
                brews = [
                    "swiftly"
                    "typescript-language-server"
                ];
                casks = [
                    "ghostty@tip"
                    "docker-desktop"
                    "emacs-app"
                    "gimp"
                    "iina"
                    "keycastr"
                    "raycast"
                    "slack"
                    "spotify"
                    "vieb"
                    "vlc"
                ];
                onActivation.cleanup = "zap";
            };
            nixpkgs.overlays = [ nixd.overlays.default ];

# Necessary for using flakes on this system.
            nix.settings.experimental-features = "nix-command flakes";

# Enable alternative shell support in nix-darwin.
# programs.fish.enable = true;

# Set Git commit hash for darwin-version.
            system.configurationRevision = self.rev or self.dirtyRev or null;

# Used for backwards compatibility, please read the changelog before changing.
# $ darwin-rebuild changelog
            system.stateVersion = 6;

# The platform the configuration will be used on.
            nixpkgs.hostPlatform = "aarch64-darwin";
        };
    in
    {
# Build darwin flake using:
# $ darwin-rebuild build --flake .#system
        darwinConfigurations."system" = nix-darwin.lib.darwinSystem {
            modules = [ 
                configuration
                nix-homebrew.darwinModules.nix-homebrew{
                    nix-homebrew = {
                        enable = true;
                        enableRosetta = true;
                        user = "shafti";
                    };
                }
            ];
        };
    };
}
