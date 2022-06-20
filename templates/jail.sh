#!/bin/sh

. TEMPLATE_PREFIX/etc/templates/jail.subr
. TEMPLATE_PREFIX/etc/templates/modules.subr


pgm="${0##*/}" # Program basename

usage() {
	echo "Usage: $pgm [prepare] [backup] [restore] [refmodules] [unrefmodules] [refmodules_force]"
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
refmodules_force)
	ref_modules_force $@
	;;
*) usage # NOTREACHED
esac
