####################
#    Copyright (C) 2007, 2008 by Raphael Geissert <atomo64@gmail.com>
#    Copyright (C) 2009 by Dmitiry Timokhin <avanie@gmail.com>
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
	local pbuilderopts es logFile basepath

	basepath="$(cowbuilderFindBaseDir "$distro")" || return

	if [ "$UPDATE_ENVIRONMENT" -gt 0 ]; then
		updateBASE "$basepath"
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

	if ! $GAINROOT cowbuilder --build $pbuilderopts --buildresult "$workingDir" \
		--logfile "$logFile" \
		--basepath "$basepath" "$workingDir/$dscURI" \
		&> /dev/null; then
			es=$?
			Say "\t\tBuild failed, cat "$logFile" for more information"
			return $es
	fi
}

updateBASE() {
	local file output es

	file="$(cowbuilderFindBaseDir "${1:-}")"

	if [ ! -d "$file" ]; then
		Say "err, what basedir do you want me to update?"
		return 1
	fi

	if [ "$UPDATE_ENVIRONMENT_AGE" -gt 0 ]; then
	    local mtime="$(stat --printf='%Y' "$file")" ctime="$(date +%s)" dtime
	    dtime=$(($ctime - $mtime))
	    if [ $dtime -lt "$UPDATE_ENVIRONMENT_AGE" ]; then
		return
	    fi
	fi

	Say "\t\tExecuting $GAINROOT cowbuilder --update --basepath $file"

	if ! output="$($GAINROOT cowbuilder --update --basepath "$file" 2>&1)"; then
		es=$?
		Say "$output"
		return $es
	fi
}

cowbuilderFindBaseDir() {
	local file

	if [ ! -z "${1:-}" ]; then
        	if  [ -d "${1:-}" ]; then
			file="${1:-}"
		elif [ -d "$(eval "echo \$COWBUILDER_${1:-}")" ]; then
			file="$(eval "echo \$COWBUILDER_$f")"
		elif [ -d "${PBUILDER_CACHE}/base-${1:-}.cow" ]; then
			file="${PBUILDER_CACHE}/base-${1:-}.cow"
		fi
	fi

	if [ -z "$file" ] && [ -d "${PBUILDER_CACHE}/base-${DISTRO}.cow" ]; then
		file="${PBUILDER_CACHE}/base-${DISTRO}.cow"
	fi

	[ -d "$file" ] && echo "$file" || return
}
