#!/bin/sh

jail_conf="jail.conf"

pgm="${0##*/}" # Program basename

usage() {
	echo "Usage: $pgm [up] [down] [clean]"
	exit 1
}


prepare() {
	for name in test01 test02 test03
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
	ifconfig test01.test02 ether 02:96:9c:b0:36:0a
	ifconfig test02.test01 ether 02:96:9c:b0:36:0b

	edge=$( ifconfig epair create )
	ifconfig $edge name test02.test03
	ifconfig ${edge%a}b name test03.test02
	ifconfig test02.test03 ether 02:96:9c:b0:37:0a
	ifconfig test03.test02 ether 02:96:9c:b0:37:0b

	for name in test01 test02 test03
	do
		jail -f $jail_conf -c $name
	done
}


teardown() {
	for name in test01 test02 test03
	do
		jail -f $jail_conf -r $name
	done

	ifconfig test01.test02 destroy
	ifconfig test02.test03 destroy
}

cleanup() {
	for name in test01 test02 test03
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
