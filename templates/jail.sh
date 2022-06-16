#!/bin/sh

. ../templates/jail.subr
. ../templates/modules.subr


pgm="${0##*/}" # Program basename

usage() {
	echo "Usage: $pgm [prepare] [backup] [restore] [refmodules] [unrefmodules]"
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
refmodules)
	ref_modules $@
	;;
unrefmodules)
	unref_modules $@
	;;
*) usage # NOTREACHED
esac
