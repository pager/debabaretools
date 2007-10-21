
Say() {
	if [ -z "${1:-}" ]; then
		Say "Nothing to say? too bad :("
		return 1
	fi

	if verbose; then
		echo -e "$@"
	fi
}

verbose() {
	if [ "$VERBOSE" -gt 0 ]; then
		return 1
	else
		return 0
	fi
}
