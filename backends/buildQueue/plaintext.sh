
####################
#    Copyright (C) 2007, 2008 by Raphael Geissert <atomo64@gmail.com>
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

#ENV: needsBuild_dataDir: directory where the plaintext BuildQueue backend stores its information
setDefault "needsBuild_dataDir" "$BASE_DIR/build/data"

#USAGE: setToBuild(distro, package, packageVersion, arch): toBuild "unstable" "libfoo" "1.0-1" "i386 amd64"
setToBuild() {

	if [ -z "${1:-}" ] || [ -z "${2:-}" ] || [ -z "${3:-}" ] || [ -z "${4:-}" ]; then
		Say "We expected four arguments!"
		return 2
	fi

	local distro package version architecture toBuildIn
	distro="${1:-}"; package="${2:-}"; version="${3:-}"; toBuildIn="${4:-}"

	local ARCH

	for ARCH in $toBuildIn; do
		if [ "$ARCH" = "source" ]; then
			continue
		fi

		if isPackageKnownByBuildQueue "$distro" "${package}_${version}" "$ARCH"; then
			Say "\tNOT Adding $package to be built in $ARCH for the $distro distribution (already listed)"
		else
			Say "\tAdding $package to be built in $ARCH for the $distro distribution"
			echo "${package}_${version}|$ARCH|needsBuild" >> "$needsBuild_dataDir/needsBuild.$distro"
		fi
	done

	local EXISTING ALREADY_BUILT_IN i

	# Find existing (Built _A_nd _In_stalled/_In_ repository) packages
	getArchsPackIsBuiltAInRepository "$package" "$version" "$distro"

	escapeForRegex "${package}_${version}"
	for i in $ALREADY_BUILT_IN; do
		if [ -z "$i" ]; then
			continue
		fi
		sed --in-place "s/$ESCAPED|$i//;" "$needsBuild_dataDir/needsBuild.$distro"
	done
}

#USAGE: getToBuild(distro, arch): getToBuild "unstable" "i386"
getToBuild() {
	if [ -z "${1:-}" ] || [ -z "${2:-}" ]; then
		Say "We expected two arguments!"
		return 2
	fi

	local distro arch
	distro="${1:-}"; arch="${2:-}"

	if [ ! -f "$needsBuild_dataDir/needsBuild.$distro" ]; then
		true
	fi

	cat "$needsBuild_dataDir/needsBuild.$distro" | egrep "([^|]+)\|$arch\|needsBuild" | cut '-d|' -f-2 || true
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
		false
	fi

	package="$(cut '-d|' -f1 <<< "$package")"

	escapeForRegex "$package"

	cat "$needsBuild_dataDir/needsBuild.$distro" | egrep "$ESCAPED\|all\|needsBuild" &>/dev/null
}

#USAGE: markAsBuilt(distro, package, version, arch): markAsBuilt "unstable" "foo" "1.1-1" "i386"
markAsBuilt() {
	if [ -z "${1:-}" ] || [ -z "${2:-}" ] || [ -z "${3:-}" ] || [ -z "${4:-}" ]; then
		Say "We expected four arguments!"
		return 2
	fi

	local distro package version arch
	distro="${1:-}"; package="${2:-}"; version="${3:-}"; arch="${4:-}"

	if [ ! -f "$needsBuild_dataDir/needsBuild.$distro" ]; then
		false
	fi

	escapeForRegex "${package}_${version}|$arch|"

	# remove any possible existing entry:
	sed -i "s/$ESCAPED.*//" "$needsBuild_dataDir/needsBuild.$distro"

	echo "${package}_${version}|$arch|built" >> "$needsBuild_dataDir/needsBuild.$distro"
}

#USAGE: isPackageKnownByBuildQueue(distro, package[, arch]): isPackageKnownByBuildQueue "unstable" "foo_1.1-1";
#. isPackageKnownByBuildQueue "unstable" "foo_1.1-1" "i386"
isPackageKnownByBuildQueue() {
	if [ -z "${1:-}" ] || [ -z "${2:-}" ]; then
		Say "We expected two arguments!"
		return 2
	fi

	local distro package arch
	distro="${1:-}"; package="${2:-}"; arch="${3:-}"

	if [ ! -f "$needsBuild_dataDir/needsBuild.$distro" ]; then
		false
	fi

	if [ -z "$arch" ]; then
		# match any architecture then:
		arch=".*"
	fi

	escapeForRegex "$package|$arch|"

	if [ ! -z "`cat "$needsBuild_dataDir/needsBuild.$distro" | egrep "$ESCAPED.*"`" ]; then
		true
	else
		false
	fi
}

#USAGE: initBuildQueue([distrosList, [codenamesList, [architecturesList]]]):
#. initBuildQueue; initBuildQueue "unstable stable testing";
#. initBuildQueue "unstable stable" "sid etch";
#. initBuildQueue "unstable stable" "sid etch" "i386 all amd64"
initBuildQueue() {
	local codenamesList codename
	codenamesList="${2:-}"

	# Our plaintext buildQueue system doesn't care about archs or distros at init-time
	for codename in $codenamesList; do
		if [ ! -f "$needsBuild_dataDir/needsBuild.$codename" ]; then
			touch "$needsBuild_dataDir/needsBuild.$codename"
		fi
	done
}

#USAGE: shutdownBuildQueue(): shutdownBuildQueue
shutdownBuildQueue() {
	# We don't do nothing here
	# buildQueue's using database connections (via external wrapper)
	# should be told to close the connection here (but don't forget to watch out for dead proc parent!)
	true
}

parsePackageEntry() {
	local pkg="$(cut '-d|' -f1 <<< "${1:-}")"
	package="$(cut -d_ -f1 <<< "$pkg")"
	version="$(cut -d_ -f2- <<< "$pkg")"
#TODO: use a better way to find the path to the .dsc file in parsePackageEntry
	dscURI="$(find "$BASE_DIR" -name "$pkg.dsc" -type f -print0 )" # | xargs -0 -r readlink -f)"
	arch="$(cut '-d|' -f2 <<< "${1:-}")"
}

