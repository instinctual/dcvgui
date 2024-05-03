#!/usr/bin/env bash

: "${CONFIGDIR:=$HOME/.config/dcvgui}"
: "${DCVVIEWER:=dcvviewer}"
DCVVIEWER_OPTIONS=(--fullscreen)
DEFAULT_PORT=8443

check_prereqs () {
    command -v yad >/dev/null 2>&1 || {
        echo >&2 "Error: yad is not installed; please install it."
        exit 1
    }
    command -v "$DCVVIEWER" >/dev/null 2>&1 || {
        echo >&2 "Error: dcvviewer ($DCVVIEWER) is not installed; please install it."
        exit 1
    }
    mkdir -p "$CONFIGDIR"
}

show_error () {
    local ERR_OPTIONS=(--text-info
                       --height 100 --width 300 --title "Error"
                       --fore=RED --margins=10 --wrap
                       --button OK:0
                      )
    yad "${ERR_OPTIONS[@]}" <<< "Error: $*"
}

run_gui () {
    local GUI_OPTIONS=(--height 300 --title "Choose DCV Connection"
                       --no-click --ellipsize end
                       --button Cancel:1
                       --button OK:0
                       --button "Create Connection":2
                      )
    # List all filenames in config dir, without extension
    local NAMES
    NAMES=$( (cd "$CONFIGDIR" && /bin/ls -1 -- *.dcv 2>/dev/null) | sed 's/\.dcv$//')

    local result
    result=$(echo "$NAMES" | yad --list "${GUI_OPTIONS[@]}" --column=Machine --separator "")
    local status=$?
    case $status in
        0 ) # OK
            if [[ -z $result ]]; then
                show_error "Must choose a connection"
                run_gui
            else
                echo Running "$DCVVIEWER" "${DCVVIEWER_OPTIONS[@]}" "${CONFIGDIR}/${result}.dcv"
                "$DCVVIEWER" "${DCVVIEWER_OPTIONS[@]}" "${CONFIGDIR}/${result}.dcv"
                exit 0
            fi
            ;;
        1 ) # Cancel
            exit 1
            ;;
        2 ) # Create Connection
            run_create
            ;;
    esac
}

run_create () {
    local CREATE_OPTIONS=(--height 500 --title "Create DCV Connection"
                          --text "Connection Details:"
                          --field "Connection Name" ""
                          --field "Host Name/IP" ""
                          --field Port:NUM "$DEFAULT_PORT"
                          --field User ""
                         )
    # Show the Create GUI form
    result=$(yad --form "${CREATE_OPTIONS[@]}")
    local status=$?
    if [[ $status != 0 ]]; then
        # Cancel -- go back to main GUI
        run_gui
    fi

    IFS="|" read -r connection_name ip port user <<< "$result"
    connection_name="${connection_name//\//_}" # remove slashes
    if [[ -z $connection_name || -z $ip || -z $port ]]; then
        show_error "Connection name, IP addr and port must all be specified."
        run_gui
    fi
    local fname="${CONFIGDIR}/${connection_name}.dcv"
    if [[ -e "$fname" ]]; then
        show_error "Connection $fname already exists; please remove it or use a different name"
        exit 1
    fi
    # Create the file
    {
        echo "[connect]"
        echo "host=$ip"
        echo "port=$port"
        echo "user=$user"
        echo
        echo "[version]"
        echo "format=1.0"
    } > "$fname"

    # Now pop up the GUI again so they can use it
    run_gui
}



# Do it
check_prereqs
run_gui
