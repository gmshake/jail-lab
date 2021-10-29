#!/bin/sh

. ../templates/jail.subr


pgm="${0##*/}" # Program basename

usage() {
	echo "Usage: $pgm [prepare] [backup] [restore]"
	exit 1
}

action="$1"
shift

case "$action" in
prepare)
	prepare_jail $@
	;;
backup)
	backup_jail $@
	;;
restore)
	restore_jail $@
	;;
*) usage # NOTREACHED
esac
