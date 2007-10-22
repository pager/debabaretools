
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

if [ -z "$LOCK_DIR" ]; then
    LOCK_DIR="`pwd`"
fi

setLockFiles() {
    if [ -z "$APP_NAME" ]; then
        LOCK_FILE="$LOCK_DIR/lock"
        UNLOCK_FILE="$LOCK_DIR/unlock"
    else
        LOCK_FILE="$LOCK_DIR/$APP_NAME.lock"
        UNLOCK_FILE="$LOCK_DIR/$APP_NAME.unlock"
    fi
}

lockApplication() {

    setLockFiles

    if [ -f "$LOCK_FILE" ]; then
        echo "$APP_NAME won't start because $LOCK_FILE is present"
        exit 1
    fi

    touch "$LOCK_FILE"

    checkUnlock
}

unlockApplication() {

    setLockFiles
    checkLock

    unlink "$LOCK_FILE"

    if [ -f "$UNLOCK_FILE" ]; then
        unlink "$UNLOCK_FILE"
    fi
}

checkLock() {

    setLockFiles

    if [ ! -f "$LOCK_FILE" ]; then
        echo "$APP_NAME's lock is gone! aborting!"
        exit 3
    fi
}

checkUnlock() {

    setLockFiles
    checkLock

    if [ -f "$UNLOCK_FILE" ]; then
        echo "$UNLOCK_FILE file is present, aborting operations!"
        rm "$UNLOCK_FILE" "$LOCK_FILE"
        exit 2
    fi
}
