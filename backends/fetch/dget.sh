
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

#ENV: DGET_EXTRA_FLAGS: extra arguments passed to dget (--path can be overriden here)

#USAGE: fetchSource(uri): fetchSource "/pool/libfoo_1.1-1.dsc"
fetchSource() {

	if [ -z "${1:-}" ]; then
		Say "No package/.dsc/.changes file has been specified!"
		return 1
	fi

	local output uri paths p es

	uri="${1:-}"

	for p in $BUILD_DATA_CACHE; do
		if [ -z "$p" ]; then
			continue;
		fi
		paths+="$p:"
	done

	if [ -f "$uri" ]; then
		uri="file://$uri"
	fi

	if [ ! -z "$paths" ]; then
		# remove trailing semi colon
		paths="`echo "$paths" | sed 's/:$//'`"
		# make it an argument
		paths="--path \"$paths\""
	fi

	if ! output="`dget --quiet $paths $DGET_EXTRA_FLAGS "$uri"`"; then
		es="$?"
		Say "$output"
		return "$es"
	fi
}
