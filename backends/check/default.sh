

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

#USAGE: doNotOverwrite(file): doNotOverwrite "accepted/new_file"
doNotOverwrite() {
	if [ -z "${1:-}" ]; then
		Say "We expected one argument!"
		return 2
	fi

	if [ -f "${1:-}" ]; then
		Say "File ${1:-} already exists!, we won't overwrite it"
		exit 10
	fi
}
