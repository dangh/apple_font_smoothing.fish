function term_app
    set -l pid %self
    set -l last_comm ""

    while test $pid -ne 1
        set last_comm (ps -p $pid -o comm= | string trim)
        if string match -q -r '(?<app>[^/]+)(?=\.app)' -- $last_comm
            echo $app
            return
        end
        set pid (ps -p $pid -o ppid=)
    end
end

function apple_font_smoothing
    argparse a/app= -- $argv

    set -l app "$_flag_app"
    test -n "$app" || set app (term_app)

    set -l cmd toggle
    switch "$argv[1]"
        case on off toggle
            set cmd $argv[1]
    end

    if test $cmd = toggle
        set -l current_state (defaults read -app "$app" AppleFontSmoothing 2>/dev/null)
        switch "$current_state"
            case 0
                set cmd on
            case \*
                set cmd off
        end
    end

    switch "$cmd"
        case off
            defaults write -app "$app" AppleFontSmoothing -int 0
            echo Font smoothing disabled for $app
        case on
            defaults delete -app "$app" AppleFontSmoothing
            echo Font smoothing enabled for $app
    end
end
