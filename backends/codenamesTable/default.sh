
distroToCodename() {
    # make sure we always set something:
    CODENAME="$DISTRO"

    if [ "$DISTRO" = "stable" ]; then CODENAME=etch; fi
    if [ "$DISTRO" = "oldstable" ]; then CODENAME=sarge; fi
    if [ "$DISTRO" = "testing" ]; then CODENAME=lenny; fi
    if [ "$DISTRO" = "unstable" ]; then CODENAME=sid; fi
}

codenameToDistro() {
    # make sure we always set something:
    DISTRO="$CODENAME"

    if [ "$CODENAME" = "etch" ]; then DISTRO=stable; fi
    if [ "$CODENAME" = "sarge" ]; then DISTRO=oldstable; fi
    if [ "$CODENAME" = "lenny" ]; then DISTRO=testing; fi
    if [ "$CODENAME" = "sid" ]; then DISTRO=unstable; fi
}
