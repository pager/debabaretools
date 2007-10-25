
####################
#    Copyright (C) 2007 by Raphael Geissert <atomo64@gmail.com>
#
#    This file is part of DeBaBaReTools
#
#    DeBaBaReTools is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    DeBaBaReTools is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with DeBaBaReTools.  If not, see <http://www.gnu.org/licenses/>.
####################

setDefault "needsBuild_dataDir" "$BASE_DIR/build/data"

# toBuild(distro, package, packageVersion, arch): toBuild "sid" "libfoo" "1.0-1" "i386 amd64"
setToBuild() {

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

		echo "$sourcePackage|$ARCH" >> $needsBuild_dataDir/needsBuild.$CODENAME
		Say "\tAdding $sourcePackage to be built in $ARCH for the $CODENAME distribution"
	done

	# Remove dups
	cat "$needsBuild_dataDir/needsBuild.$CODENAME" | sort -u > "$needsBuild_dataDir/needsBuild.$CODENAME"

	local EXISTING ALREADY_BUILT_IN i

	# Find existing packages 
	# TODO: check for the existence of already built but not installed!
	getArchsPackIsBuiltAInRepository "$sourcePackage" "$packageVersion" "$CODENAME"

	for i in $ALREADY_BUILT_IN; do
		if [ -z "$i" ]; then
			continue
		fi
		sed --in-place "s/$sourcePackage|$i//;" "$needsBuild_dataDir/needsBuild.$CODENAME"
	done
}

getToBuild() {
}
