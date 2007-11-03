
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

distroToCodename() {
	local distro="${1:-}"

	# make sure we always set something:
	CODENAME="$distro"

	if [ "$distro" = "stable" ]; then CODENAME=etch; fi
	if [ "$distro" = "oldstable" ]; then CODENAME=sarge; fi
	if [ "$distro" = "testing" ]; then CODENAME=lenny; fi
	if [ "$distro" = "unstable" ]; then CODENAME=sid; fi
}

codenameToDistro() {
	local codename="${1:-}"

	# make sure we always set something:
	DISTRO="$codename"

	if [ "$codename" = "etch" ]; then DISTRO=stable; fi
	if [ "$codename" = "sarge" ]; then DISTRO=oldstable; fi
	if [ "$codename" = "lenny" ]; then DISTRO=testing; fi
	if [ "$codename" = "sid" ]; then DISTRO=unstable; fi
}
