
PROBE_DIRS="/usr/share/DeBaBaReTools/backends /usr/local/share/DeBaBaReTools/backends $BACKEND_DIR"

if [ ! -z "$EXTRA_PROBE_DIRS" ]; then
    PROBE_DIRS="$PROBE_DIRS $EXTRA_PROBE_DIRS"
fi

probeFile() {
    local f d succeeded
    
    if [ -z "${1:-}" ]; then
        return 2
    fi
    
    for f in $@; do
        succeeded=
        for d in $PROBE_DIRS; do
            if [ -f "$d/$f" ]; then
                succeeded=1
                . "$d/$f"
                continue 2
            fi
            if [ -f "$d/$f.sh" ]; then
                succeeded=1
                . "$d/$f.sh"
                continue 2
            fi
            if [ -d "$d/$f" ] && [ -f "$d/$f/default.sh" ] ; then
                succeeded=1
                . "$d/$f/default.sh"
                continue 2
            fi
        done
        
        if [ ! "$succeeded" ]; then
            return 1
        fi
        
    done
    
    return 0
}
