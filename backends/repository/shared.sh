
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

#USAGE: isArchSupportedIn(arch, archsList): isArchSupportedIn "i386" "amd64 i386 sparc"
isArchSupportedIn() {
	if [ -z "${1:-}" ] || [ -z "${2:-}" ]; then
		Say "We expected two arguments!"
		return 2
	fi

	local arch archsList a
	arch="${1:-}"; archsList="${2:-}";

	for a in $archsList; do
		if [ "$a" == "$arch" ]; then
			return
		fi
	done
	false
}


#USAGE: moveToIncoming(files[, files[, files[, ...]]]): moveToIncoming "foo_1.0-1_source.changes"
moveToIncoming() {
	if [ -z "${1:-}" ]; then
		Say "We expected at least one argument!"
		return 2
	fi

	for f in $@; do
		doNotOverwrite "$INCOMING/`basename "$f"`"
		Say "mv'ing \"$f\" to \"$INCOMING\""
		mv "$f" "$INCOMING/"
	done
}
