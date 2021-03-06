
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

#USAGE: getChangesEntry(changesFile, entryName): getChangesEntry "foo_0.1-1_i386.changes" "Version"
getChangesEntry() {
	if [ -z "${1:-}" ] || [ -z "${2:-}" ]; then
		Say "We expected two arguments!"
		return 1
	fi

	local file entry var
	file="${1:-}"; entry="${2:-}"

	case $entry in
		Version|Distribution|Format|Date|Source|Binary|Architecture|Urgency|Changed-By|Closes)
			# good :)
		;;
		*)
			Say "getChangesEntry doesn't know (or fully support) reading $entry entries from .changes"
		;;
	esac

	var="$(echo "$entry" | sed "s/\-/_/g" | awk '{ print toupper($0) }')"

	eval "$var=\""$(egrep -m1 "^$entry:" "$file" | cut '-d:' -f2- | sed "s/^ //")"\""
}

#USAGE: getDscEntry(dscFile, entryName): getDscEntry "foo_0.1-1.dsc" "Version"
getDscEntry() {
	if [ -z "${1:-}" ] || [ -z "${2:-}" ]; then
		Say "We expected two arguments!"
		return 1
	fi

	local file entry var
	file="${1:-}"; entry="${2:-}"

	case $entry in
		Version|Format|Standards-Version|Source|Binary|Architecture|Build-Depends)
			# good :)
		;;
		*)
			Say "getDscEntry doesn't know (or fully support) reading $entry entries from .changes"
		;;
	esac

	var="$(echo "$entry" | sed "s/\-/_/g" | awk '{ print toupper($0) }')"

	eval "$var=\""$(egrep -m1 "^$entry:" "$file" | cut '-d:' -f2- | sed "s/^ //")"\""
}

#USAGE: getChangesFiles(dscFile): getChangesFiles "foo_0.1-1.dsc"
getChangesFiles() {
	if [ -z "${1:-}" ]; then
		Say "We expected one argument!"
		return 1
	fi

	local file changesFiles dirname
	file="${1:-}"

	dirname="$(dirname "$file")"
	changesFiles="$(egrep "[0-9a-f]{32} [0-9]+ [a-z]+ [a-z]+ .*" "$file" | cut '-d ' -f6- )"

	CHANGES_FILES=
	for f in $changesFiles; do
		CHANGES_FILES+="$dirname/$f "
	done
}

#USAGE: getDscFiles(dscFile): getDscFiles "foo_0.1-1.dsc"
getDscFiles() {
	if [ -z "${1:-}" ]; then
		Say "We expected one argument!"
		return 1
	fi

	local file dscFiles dirname
	file="${1:-}"

	dirname="$(dirname "$file")"
	dscFiles="$(egrep "[0-9a-f]{32} [0-9]+ .*" "$file" | cut '-d ' -f4-)"

	DSC_FILES=
	for f in $dscFiles; do
		DSC_FILES+="$dirname/$f "
	done
}
