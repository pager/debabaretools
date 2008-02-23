
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

setDefault "PBUILDER_CACHE" "/var/cache/pbuilder"

#buildPackage "$dscURI" "$BUILD_TYPE" "$workingDir" "$distro" ["$maintainer"]
buildPackage() {

	local dscURI="${1:-}" buildType="${2:-}" workingDir="${3:-}" distro="${4:-}" maintainer="${5:-}"
	local pbuilderopts es logFile basetgz

	basetgz="$(pbuilderFindBasetgz "$distro")" || return

	if [ "$UPDATE_ENVIRONMENT" -gt 0 ]; then
		updateTGZ "$basetgz"
	fi

	case $buildType in 
		binary-arch)
			pbuilderopts=' --binary-arch'
		;;
		binary-indep)
			pbuilderopts='--debbuildopts -A'
		;;
		binary-all)
			pbuilderopts='--debbuildopts -b'
		;;
	esac

	if [ ! -z "$maintainer" ]; then
		pbuilderopts+=" --debbuildopts -m'$maintainer'"
	fi

	logFile="$workingDir/$(sed "s#\.dsc#_$DEB_HOST_ARCH#" <<< "$dscURI").build"

	Say "\t\tStarting build process"

	if ! $GAINROOT pbuilder --build $pbuilderopts --buildresult "$workingDir" \
		--basetgz "$basetgz" "$workingDir/$dscURI" \
		--logfile "$logFile"
		&> /dev/null; then
			es=$?
			Say "\t\tBuild failed, cat "$logFile" for more information"
			return $es
	fi
}

updateTGZ() {
	local file output es

	file="$(pbuilderFindBasetgz "${1:-}")"

	if [ ! -f "$file" ]; then
		Say "err, what basetgz do you want me to update?"
		return 1
	fi
	Say "\t\tExecuting $GAINROOT pbuilder --update --basetgz $file"

	if ! output="`$GAINROOT pbuilder --update --basetgz "$file" 2>&1`"; then
		es=$?
		Say "$output"
		return $es
	fi
}

pbuilderFindBasetgz() {
	local file

	if [ ! -z "${1:-}" ]; then
        	if  [ -f "${1:-}" ]; then
			file="${1:-}"
		elif [ -f "$(eval "echo \$PBUILDER_${1:-}")" ]; then
			file="$(eval "echo \$PBUILDER_$f")"
		elif [ -f "${PBUILDER_CACHE}/${1:-}.tgz" ]; then
			file="${PBUILDER_CACHE}/${1:-}.tgz"
		fi
	fi

	if [ -z "$file" ] && [ -f "${PBUILDER_CACHE}/${DISTRO}.tgz" ]; then
		file="${PBUILDER_CACHE}/${DISTRO}.tgz"
	fi

	[ -f "$file" ] && echo "$file" || return
}
