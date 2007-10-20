
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
