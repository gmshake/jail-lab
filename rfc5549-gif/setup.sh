#!/bin/sh

jail_conf="jail.conf"

pgm="${0##*/}" # Program basename

usage() {
	echo "Usage: $pgm [up] [down] [clean]"
	exit 1
}


prepare() {
	for name in test01 test02
	do
		[ -d "/jails/$name" ] || {
			zfs clone zroot/jails/templates/FreeBSD-13.0-RELEASE@p0 zroot/jails/$name && zfs snap zroot/jails/$name@p0

			sysrc -R /jails/$name cron_enable=NO
			sysrc -R /jails/$name sendmail_enable=NONE
			sysrc -R /jails/$name syslogd_enable=NO
			sysrc -R /jails/$name gateway_enable=YES
			sysrc -R /jails/$name ipv6_gateway_enable=YES
			sysrc -R /jails/$name ipv6_activate_all_interfaces=YES

			zfs snap zroot/jails/$name@p1
		}
	done
}

setup() {
	prepare

	local edge=$( ifconfig epair create )
	ifconfig $edge name test01.test02
	ifconfig ${edge%a}b name test02.test01

	for name in test01 test02
	do
		jail -f $jail_conf -c $name
	done
}


teardown() {
	for name in test01 test02
	do
		jail -f $jail_conf -r $name
	done

	ifconfig test01.test02 destroy
}

cleanup() {
	for name in test01 test02
	do
		zfs destroy -r zroot/jails/$name
	done
}


action="$1"

case "$action" in
up)
	setup
        ;;
down)
	teardown
        ;;
clean)
	cleanup
        ;;
*) usage # NOTREACHED
esac
