
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

setLockFiles() {
	if [ -z "$APP_NAME" ]; then
		LOCK_FILE="$LOCK_DIR/lock"
		UNLOCK_FILE="$LOCK_DIR/unlock"
	else
		LOCK_FILE="$LOCK_DIR/$APP_NAME.lock"
		UNLOCK_FILE="$LOCK_DIR/$APP_NAME.unlock"
	fi
}

# try to lock the application and exit if already locked
lockApplication() {

	ln -s $$ "$LOCK_FILE" &> /dev/null || {
	    echo "$APP_NAME won't start because $LOCK_FILE is present" >&2
	    exit 1
	}

	checkUnlock
}

# smoothly unlock the application (but don't exit)
unlockApplication() {

	checkLock

	unlink "$LOCK_FILE"

	if [ -f "$UNLOCK_FILE" ]; then
		unlink "$UNLOCK_FILE"
	fi
}

# make sure the lock file is present, otherwise exit
checkLock() {

	if [ ! -f "$LOCK_FILE" ]; then
		echo "$APP_NAME's lock is gone! aborting!"
		exit 3
	fi
}

# check if .unlock is present and abort (but remove .lock and .unlock)
#  this should only be used when it is safe to abort (i.e. operations can be resumed later)
checkUnlock() {
	checkLock
	if [ -f "$UNLOCK_FILE" ]; then
		echo "$UNLOCK_FILE file is present, aborting operations NOW!"
		rm -f "$UNLOCK_FILE" "$LOCK_FILE"
		exit 2
	fi
}
