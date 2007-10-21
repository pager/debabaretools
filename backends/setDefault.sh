
setDefault() {
	if [ -z "${1:-}" ] || [ -z "${2:-}"  ]; then
		return 1
	fi
	if [ -z "`eval "echo \\\$${1:-}"`" ]; then
		eval "${1:-}='${2:-}'"
	fi
}
