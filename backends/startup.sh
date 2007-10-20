
sayHello() {
    local name
    local version
    
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
    
    echo "$name$version started."
}
