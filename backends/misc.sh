
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

sayHello() {
	local name version

	if [ -z "$APP_NAME" ]; then
		name="Application"
	else
		name="$APP_NAME"
	fi

	if [ -z "$APP_VERSION" ]; then
		version=""
	else
		version=" v$APP_VERSION"
	fi
	
	Say "$name$version started."
}

sayBye() {
	local name version

	if [ -z "$APP_NAME" ]; then
		name="Application"
	else
		name="$APP_NAME"
	fi

	if [ -z "$APP_VERSION" ]; then
		version=""
	else
		version=" v$APP_VERSION"
	fi
	
	Say "$name$version stopped."
}

escapeForRegex() {
	if [ -z "${1:-}" ]; then
		Say "We expected one argument!"
		return 1
	fi

	local original escaped
	original="${1:-}"

	escaped="`echo "$original" | sed -e 's/\+/\\\+/g;s/|/\\\|/g'`" 

	local other
	for other in ${2:-}; do
		case "$other" in
			UNDERSCORE)
				escaped="`echo "$escaped" | sed 's/_/\\_/g'`"
			;;
			BACKSLASH)
				escaped="`echo "$escaped" | sed 's/\\/\\\\/g'`"
			;;
			DOT)
				escaped="`echo "$escaped" | sed 's/\./\\\./g'`"
			;;
		esac
	done

	# make it public
	ESCAPED="$escaped"
}