
# toBuild(distro, package, packageVersion, arch): toBuild "sid" "libfoo" "1.0-1" "i386 amd64"
toBuild() {

        if [ -z "${1:-}" ] || [ -z "${2:-}" ] || [ -z "${3:-}" ] || [ -z "${4:-}" ] || [ -z "$BUILDARCHS" ]; then
            return 1
        fi

        local distro sourcePackage packageVersion architecture
        distro="${1:-}"; sourcePackage="${2:-}"; packageVersion="${3:-}"; toBuildIn="${4:-}"

        # we retrieve the codename and use it for everything rather than the distribution name
        DISTRO="$distro" distroToCodename

        local ARCH

        for ARCH in $toBuildIn; do
            if [ "$ARCH" = "source" ]; then
                continue
            fi

            if [ "`echo "$BUILDARCHS" | grep "$ARCH"`" ]; then
                echo "$sourcePackage|$ARCH" >> $needsBuild_dataDir/needsBuild.$CODENAME
                if [ $VERBOSE ]; then
                        echo -e "\tAdding $sourcePackage to be built in $ARCH for the $CODENAME distribution"
                fi
            fi
        done

        #
        # Remove dups
        #
        cat "$needsBuild_dataDir/needsBuild.$CODENAME" | sort -u > "$needsBuild_dataDir/needsBuild.$CODENAME"

        local EXISTING ALREADY_BUILT_IN i

        #
        # Find existing packages 
        # TODO: check for the existence of already built but not installed!!!
        # TODO: create a backend for this
        EXISTING="`reprepro -T deb listfilter "$CODENAME" "Source (==${sourcePackage})"`"
        ALREADY_BUILT_IN=''
        for i in $EXISTING; do
            i="`basename "$i"`"
            i="`echo "$i" | grep "$packageVersion"`"

            if [ -z "$i" ]; then
                continue
            fi

            ARCH="`echo "$i" | awk -F_ '{ print $3 }' | awk -F. '{ print $1 }'`"
            ALREADY_BUILT_IN+="$ARCH "
        done

        for i in $ALREADY_BUILT_IN; do
            if [ -z "$i" ]; then
                continue
            fi
            sed --in-place "s/$sourcePackage|$i//;" "$needsBuild_dataDir/needsBuild.$CODENAME"
        done
}
