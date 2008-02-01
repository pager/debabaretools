
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

distroToCodename() {
	local distro="${1:-}" distributionsFile

	if [ ! -z "${2:-}" ] && [ -f "${2:-}" ]; then
		distributionsFile="${2:-}"
	elif [ -f "$BASE_DIR/conf/distributions" ]; then
		distributionsFile="$BASE_DIR/conf/distributions"
	fi

	if [ ! -f "$distributionsFile" ]; then
		Say "Couldn't find reprepro's conf/distributions, how am I going to find out the available suites and codenames then?"
		return 2
	fi

	# make sure we always set something:
	CODENAME="$distro"

	if which grep-dctrl > /dev/null; then
		CODENAME="$(grep-dctrl -n -X -FSuite "$distro" -sCodename "$distributionsFile")"
	else
		CODENAME="$(egrep -B2 -A2 "^Suite: $distro" "$distributionsFile" | egrep "^Codename: " | cut -d: -f2 | sed 's/[ \t]//g')"
	fi
}

codenameToDistro() {
	local codename="${1:-}" distributionsFile

	if [ ! -z "${2:-}" ] && [ -f "${2:-}" ]; then
		distributionsFile="${2:-}"
	elif [ -f "$BASE_DIR/conf/distributions" ]; then
		distributionsFile="$BASE_DIR/conf/distributions"
	fi

	if [ ! -f "$distributionsFile" ]; then
		Say "Couldn't find reprepro's conf/distributions, how am I going to find out the available suites and codenames then?"
		return 2
	fi

	# make sure we always set something:
	DISTRO="$codename"

	if which grep-dctrl > /dev/null; then
		DISTRO="$(grep-dctrl -n -X -FCodename "$codename" -sSuite "$distributionsFile")"
	else
		DISTRO="$(egrep -B2 -A2 "^Codename: $codename" "$distributionsFile" | egrep "^Suite: " | cut -d: -f2 | sed 's/[ \t]//g')"
	fi
}
