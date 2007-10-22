
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

PROBE_DIRS="$BACKEND_DIR /usr/share/DeBaBaReTools/backends /usr/local/share/DeBaBaReTools/backends"

if [ ! -z "$EXTRA_PROBE_DIRS" ]; then
	PROBE_DIRS="$EXTRA_PROBE_DIRS $PROBE_DIRS"
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
