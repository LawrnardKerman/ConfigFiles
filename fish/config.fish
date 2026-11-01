if status is-interactive

    # Variables 

    set gitRepoDir "$HOME/ConfigFiles/"

    # Astetichs (change this to something better later)

    zfetch
    starship init fish | source

    source ~/.config/fish/fzfTheme.fish

    # Aliases 

    if test -f ~/.config/fish/aliases.fish
        source ~/.config/fish/aliases.fish
    end

    # Functions  NOTE: these should probably be in ~/.config/fish/functions but like oh well maybe later

    function saveAlias

        set fullAlias "$argv[1] '$argv[2..-1]'"
        echo "alias $fullAlias" >>~/.config/fish/aliases.fish

    end

    function discord

        argparse u/update -- $argv

        if set -q _flag_update
            sudo pacman -Syu vesktop-bin
        end

        command vesktop

    end

    function checkRunning # Pretty self explanatory - checks if a process is running

        ps aux | grep -v grep | grep "$argv"

    end

    function sober

        if contains -- $argv[1] -u --update
            flatpak update org.vinegarhq.Sober -y
            flatpak run org.vinegarhq.Sober
        else
            flatpak run org.vinegarhq.Sober
        end

    end

end

# terminal-wakatime setup
set -gx PATH "$HOME/.wakatime" $PATH
terminal-wakatime init fish | source
