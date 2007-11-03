
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

#USAGE: setToBuild(distro, package, packageVersion, arch): toBuild "unstable" "libfoo" "1.0-1" "i386 amd64"
setToBuild() {

	if [ -z "${1:-}" ] || [ -z "${2:-}" ] || [ -z "${3:-}" ] || [ -z "${4:-}" ] || [ -z "$BUILDARCHS" ]; then
		Say "We expected four arguments and \$BUILDARCHS to be set!"
		return 1
	fi

	local distro sourcePackage packageVersion architecture
	distro="${1:-}"; sourcePackage="${2:-}"; packageVersion="${3:-}"; toBuildIn="${4:-}"

	local ARCH

	for ARCH in $toBuildIn; do
		if [ "$ARCH" = "source" ]; then
			continue
		fi

		if [ ! isPackageKnownByNeedsBuild "$distro" "$sourcePackage" ]; then
			echo "$sourcePackage|$ARCH|needsBuild" >> "$needsBuild_dataDir/needsBuild.$distro"
			Say "\tAdding $sourcePackage to be built in $ARCH for the $distro distribution"
		else
			Say "\tNOT Adding $sourcePackage to be built in $ARCH for the $distro distribution (already listed)"
		fi
	done

	local EXISTING ALREADY_BUILT_IN i

	# Find existing packages
	getArchsPackIsBuiltAInRepository "$sourcePackage" "$packageVersion" "$distro"

	for i in $ALREADY_BUILT_IN; do
		if [ -z "$i" ]; then
			continue
		fi
		sed --in-place "s/$sourcePackage|$i//;" "$needsBuild_dataDir/needsBuild.$distro"
	done
}

#USAGE: getToBuild(distro, arch): getToBuild "unstable" "i386"
getToBuild() {
	if [ -z "${1:-}" ] || [ -z "${2:-}" ]; then
		Say "We expected two arguments!"
		return 1
	fi

	TOBUILD=

	local distro arch
	distro="${1:-}"; arch="${2:-}"

	if [ ! -f "$needsBuild_dataDir/needsBuild.$distro" ]; then
		return
	fi

	TOBUILD="`cat "$needsBuild_dataDir/needsBuild.$distro" | egrep "([^|]+)|$arch|needsBuild" | cut '-d|' -f1`"
}

#USAGE: hasPendingArchAll(distro, package): hasPendingArchAll "unstable" "foo_1.1-1"
hasPendingArchAll() {
	if [ -z "${1:-}" ] || [ -z "${2:-}" ]; then
		Say "We expected two arguments!"
		return 2
	fi

	local distro package
	distro="${1:-}"; package="${2:-}"

	if [ ! -f "$needsBuild_dataDir/needsBuild.$distro" ]; then
		return 1
	fi

	if [ ! -z "`cat "$needsBuild_dataDir/needsBuild.$distro" | egrep "$package|all|needsBuild"`" ]; then
		return 0
	else
		return 1
	fi
}

#USAGE: markAsBuilt(distro, package, arch): markAsBuilt "unstable" "foo_1.1-1" "i386"
markAsBuilt() {
	if [ -z "${1:-}" ] || [ -z "${2:-}" ] || [ -z "${3:-}" ]; then
		Say "We expected three arguments!"
		return 1
	fi

	local distro package arch
	distro="${1:-}"; package="${2:-}"; arch="${3:-}"

	if [ ! -f "$needsBuild_dataDir/needsBuild.$distro" ]; then
		return 1
	fi

	# remove any possible existing entry:
	sed -i "$needsBuild_dataDir/needsBuild.$distro" "s/$package|$arch|.*//"

	echo "$package|$arch|built" >> "$needsBuild_dataDir/needsBuild.$distro"
}

#USAGE: isPackageKnownByNeedsBuild(distro, package): isPackageKnownByNeedsBuild "unstable" "foo_1.1-1"
isPackageKnownByNeedsBuild() {
	if [ -z "${1:-}" ] || [ -z "${2:-}" ]; then
		Say "We expected two arguments!"
		return 2
	fi

	local distro package
	distro="${1:-}"; package="${2:-}"

	if [ ! -f "$needsBuild_dataDir/needsBuild.$distro" ]; then
		return 1
	fi

	if [ ! -z "`cat "$needsBuild_dataDir/needsBuild.$distro" | egrep "$package|.*|.*"`" ]; then
		return 0
	else
		return 1
	fi
}
