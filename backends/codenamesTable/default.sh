
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
    # make sure we always set something:
    CODENAME="$DISTRO"

    if [ "$DISTRO" = "stable" ]; then CODENAME=etch; fi
    if [ "$DISTRO" = "oldstable" ]; then CODENAME=sarge; fi
    if [ "$DISTRO" = "testing" ]; then CODENAME=lenny; fi
    if [ "$DISTRO" = "unstable" ]; then CODENAME=sid; fi
}

codenameToDistro() {
    # make sure we always set something:
    DISTRO="$CODENAME"

    if [ "$CODENAME" = "etch" ]; then DISTRO=stable; fi
    if [ "$CODENAME" = "sarge" ]; then DISTRO=oldstable; fi
    if [ "$CODENAME" = "lenny" ]; then DISTRO=testing; fi
    if [ "$CODENAME" = "sid" ]; then DISTRO=unstable; fi
}
