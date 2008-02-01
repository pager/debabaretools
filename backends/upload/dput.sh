
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

#ENV: DPUT_EXTRA_FLAGS: extra arguments passed to dput
#ENV: DPUT_HOST: 'host' parameter of dput

#USAGE: uploadSource(uri): uploadSource "/buildd-results/libfoo_1.0-1_i386.changes"
uploadSource() {

	if [ -z "${1:-}" ]; then
		Say "No .changes file has been specified!"
		return 1
	fi

	local output uri es

	uri="${1:-}"

	if ! output="`dput $DPUT_EXTRA_FLAGS "$DPUT_HOST" "$uri"`"; then
		es="$?"
		Say "$output"
		return "$es"
	fi
}
