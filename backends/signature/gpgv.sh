
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

checkSign() {
	if [ -z "${1:-}" ] || [ -z "${2:-}" ]; then
		return 2
	fi
	
	local output opts file="${1:-}" gpgv

	for k in ${2:-}; do
		opts+="--keyring "$k" "
	done

	gpgv="$(which gpgv)" || gpgv="$(which gpgv2)" || Say "Couldn't find a gpgv to use!"

	[ ! -z "$gpgv" ] || return $?

	if output="$($gpgv $opts --quiet "$file" 2>&1)"; then
		return
	else
		Say "$output"
		false
	fi
}
