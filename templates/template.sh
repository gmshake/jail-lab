#!/bin/sh

. template.subr

pgm="${0##*/}"
baseos="FreeBSD-13.0-RELEASE"

usage() {
	echo -e "Usage: $pgm [-h] [template1] [template2] ... [template n]"
	echo -e "    Supported templates:"
	echo -e "        baseos:\t\tFreeBSD-13.0-RELEASE"
	echo -e "        host:\t\tFreeBSD-13.0-RELEASE-host"
	echo -e "        router:\t\tFreeBSD-13.0-RELEASE-router"
	echo -e "        firewall:\tFreeBSD-13.0-RELEASE-firewall (pf based)"
	echo -e "        router-frr7:\tFreeBSD-13.0-RELEASE-router-frr7"
	echo -e "        firewall-frr7:\tFreeBSD-13.0-RELEASE-firewall-frr7"
	echo -e "        firewall-frr7-access:\tFreeBSD-13.0-RELEASE-firewall-frr7-access"
	echo -e "        firewall-frr7-dial:\tFreeBSD-13.0-RELEASE-firewall-frr7-dial"
	echo -e "        firewall-strongswan:\tFreeBSD-13.0-RELEASE-firewall-strongswan"
	echo -e "        host-freeradius3:\tFreeBSD-13.0-RELEASE-freeradius3"
	echo -e "        host-isc-dhcp44-server:\tFreeBSD-13.0-RELEASE-isc-dhcp44-server"
	echo -e "        host-unbound:\tFreeBSD-13.0-RELEASE-unbound"
}

create_baseos() {
	create_template baseos.cb ${baseos}
}

create_host() {
	create_baseos
	create_template host.cb ${baseos}-host ${baseos}
}

create_router() {
	create_baseos
	create_template router.cb ${baseos}-router ${baseos}
}

create_firewall() {
	create_router
	create_template pf.cb ${baseos}-firewall ${baseos}-router
}

create_router_frr7() {
	create_router
	create_template frr7.cb ${baseos}-router-frr7 ${baseos}-router
}

create_firewall_frr7() {
	create_firewall
	create_template frr7.cb ${baseos}-firewall-frr7 ${baseos}-firewall
}

create_firewall_frr7_access() {
	create_firewall_frr7
	create_template access-edge.cb ${baseos}-firewall-frr7-access ${baseos}-firewall-frr7
}

create_firewall_frr7_dial() {
	create_firewall_frr7
	create_template dial-edge.cb ${baseos}-firewall-frr7-dial ${baseos}-firewall-frr7
}

create_firewall_strongswan() {
	create_firewall
	create_template strongswan.cb ${baseos}-firewall-strongswan ${baseos}-firewall
}

create_host_freeradius3() {
	create_baseos
	create_template freeradius3.cb ${baseos}-freeradius3 ${baseos}-host
}

create_host_isc_dhcp44_server() {
	create_baseos
	create_template isc-dhcp44-server.cb ${baseos}-isc-dhcp44-server ${baseos}-host
}

create_host_unbound () {
	create_baseos
	create_template unbound.cb ${baseos}-unbound ${baseos}-host
}

if [ "$#" -eq 0 ]; then
	usage
	exit 1
fi


for tp in "$@"
do
	case "$tp" in
	baseos)
		;;
	host)
		;;
	router)
		;;
	firewall)
		;;
	router-frr7)
		;;
	firewall-frr7)
		;;
	firewall-frr7-access)
		;;
	firewall-frr7-dial)
		;;
	firewall-strongswan)
		;;
	host-freeradius3)
		;;
	host-isc-dhcp44-server)
		;;
	host-unbound)
		;;
	-h)
		usage
		exit 1
		;;
	*)
		echo "Unsupported tempate $tp"
		usage # NOT REACHED
		exit 1
		;;
	esac

	tp=$( echo $tp | sed -e "s/-/_/g" )
	create_${tp}
done

