
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

installIncoming() {
	local incomingFile rulesets rule OUTPUT

	if [ ! -z "${1:-}" ] && [ -f "${1:-}" ]; then
		incomingFile="${1:-}"
	elif [ -f "$BASE_DIR/conf/incoming" ]; then
		incomingFile="$BASE_DIR/conf/incoming"
	fi

	if [ ! -f "$incomingFile" ]; then
		Say "Couldn't find reprepro's conf/incoming, how am I going to processincoming then?"
		return 1
	fi

	rulesets="`cat "$incomingFile" | grep "Name:" | sed "s/[ \t]*Name:[ \t]*//gi" | sort -u`"

	if [ -z "$rulesets" ]; then
		Say "Couldn't find any ruleset in $incomingFile"
		return 1
	fi

	for rule in $rulesets; do
		OUTPUT="`reprepro processincoming "$rule"`"
		if [ "$?" != "0" ]; then
			Say "$OUTPUT"
			return "$?"
		fi
	done
}