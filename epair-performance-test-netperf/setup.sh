#!/bin/sh

. ../templates/template.subr
. ../templates/network.subr
. ../templates/jail.subr

jail_conf="jail.conf"

jails="left right"
networks="left-right"

pgm="${0##*/}" # Program basename

usage() {
	echo "Usage: $pgm [up] [down] [restart] [clean]"
	echo "       $pgm [up] [jail01] [jail02] ..."
	echo "       $pgm [down] [jail01] [jail02] ..."
	echo "       $pgm [restart] [jail01] [jail02] ..."
	exit 1
}

setup() {
	local js="$@"
	if [ -n "$js" ]; then
		for name in $js
		do
			jail -f $jail_conf -c $name
		done
		return
	fi

	for pair in $networks
	do
		local l="${pair%-*}"
		local r="${pair#*-}"
		create_epair "$l" "$r"
	done

	for name in $jails
	do
		jail -f $jail_conf -c $name
	done
}


teardown() {
	local js="$@"
	if [ -n "$js" ]; then
		for name in $js
		do
			jail -f $jail_conf -r $name
		done
		return
	fi

	for name in $jails
	do
		jail -f $jail_conf -r $name
	done

	for pair in $networks
	do
		local l="${pair%-*}"
		local r="${pair#*-}"
		destroy_epair "$l" "$r"
	done
}


cleanup() {
	for name in $jails
	do
		clean_jail $name
	done
}


action="$1"
shift

case "$action" in
up)
	setup $@
        ;;
down)
	teardown $@
        ;;
restart)
	teardown $@
	setup $@
	;;
clean)
	teardown
	cleanup
        ;;
*) usage # NOTREACHED
esac
