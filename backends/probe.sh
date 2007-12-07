
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

#ENV: EXTRA_PROBE_DIRS: space-separated list of directories where backends should be looked for
if [ ! -z "$EXTRA_PROBE_DIRS" ]; then
	PROBE_DIRS="$EXTRA_PROBE_DIRS $PROBE_DIRS"
fi

probeFile() {
	local f d succeeded h hints

	if [ -z "${1:-}" ]; then
		return 2
	fi

	for f in $@; do
		succeeded=
#ENV: HINT_$backend: space-separated list of hints used to pick the right backend (e.g. HINT_repository=reprepro)
		hints="`eval "echo \\\$HINT_$f"` default"
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
			if [ -d "$d/$f" ]; then
                        	for h in $hints; do 
					if [ -f "$d/$f/$h.sh" ]; then
						succeeded=1
						. "$d/$f/$h.sh"
						continue 3
					fi
				done
			fi
		done

		if [ ! "$succeeded" ]; then
			return 1
		fi

	done

	return 0
}
