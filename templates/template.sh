#!/bin/sh

. TEMPLATE_PREFIX/etc/templates/template.subr

pgm="${0##*/}"
baseos="FreeBSD-13.1"

usage() {
	echo -e "Usage: $pgm [-h] [template1] [template2] ... [template n]"
	echo -e "    Supported templates:"
	echo -e "        baseos:\t\t${baseos}"
	echo -e "        host:\t\t${baseos}-host"
	echo -e "        router:\t\t${baseos}-router"
	echo -e "        firewall:\t${baseos}-firewall (pf based)"
	echo -e "        router-frr7:\t${baseos}-router-frr7"
	echo -e "        firewall-frr7:\t${baseos}-firewall-frr7"
	echo -e "        firewall-frr7-access:\t${baseos}-firewall-frr7-access"
	echo -e "        firewall-frr7-mpd5:\t${baseos}-firewall-frr7-mpd5"
	echo -e "        firewall-frr7-strongswan:\t${baseos}-firewall-frr7-strongswan"
	echo -e "        host-freeradius3:\t${baseos}-freeradius3"
	echo -e "        host-isc-dhcp44-server:\t${baseos}-isc-dhcp44-server"
	echo -e "        host-unbound:\t${baseos}-unbound"
	echo -e "        host-iperf3:\t${baseos}-iperf3"
	echo -e "        host-netperf:\t${baseos}-netperf"
	echo -e "    $pgm localbaseos NAME"
}

create_localbaseos() {
	create_template TEMPLATE_PREFIX/share/templates/localbaseos.cb $1
}

create_baseos() {
	create_template TEMPLATE_PREFIX/share/templates/baseos.cb ${baseos}
}

create_host() {
	create_baseos
	create_template TEMPLATE_PREFIX/share/templates/host.cb ${baseos}-host ${baseos}
}

create_router() {
	create_baseos
	create_template TEMPLATE_PREFIX/share/templates/router.cb ${baseos}-router ${baseos}
}

create_firewall() {
	create_router
	create_template TEMPLATE_PREFIX/share/templates/pf.cb ${baseos}-firewall ${baseos}-router
}

create_router_frr7() {
	create_router
	create_template TEMPLATE_PREFIX/share/templates/frr7.cb ${baseos}-router-frr7 ${baseos}-router
}

create_firewall_frr7() {
	create_firewall
	create_template TEMPLATE_PREFIX/share/templates/frr7.cb ${baseos}-firewall-frr7 ${baseos}-firewall
}

create_firewall_frr7_access() {
	create_firewall_frr7
	create_template TEMPLATE_PREFIX/share/templates/access-edge.cb ${baseos}-firewall-frr7-access ${baseos}-firewall-frr7
}

create_firewall_frr7_mpd5() {
	create_firewall_frr7
	create_template TEMPLATE_PREFIX/share/templates/mpd5.cb ${baseos}-firewall-frr7-mpd5 ${baseos}-firewall-frr7
}

create_firewall_frr7_strongswan() {
	create_firewall_frr7
	create_template TEMPLATE_PREFIX/share/templates/strongswan.cb ${baseos}-firewall-frr7-strongswan ${baseos}-firewall-frr7
}

create_host_freeradius3() {
	create_baseos
	create_template TEMPLATE_PREFIX/share/templates/freeradius3.cb ${baseos}-freeradius3 ${baseos}-host
}

create_host_isc_dhcp44_server() {
	create_baseos
	create_template TEMPLATE_PREFIX/share/templates/isc-dhcp44-server.cb ${baseos}-isc-dhcp44-server ${baseos}-host
}

create_host_unbound () {
	create_baseos
	create_template TEMPLATE_PREFIX/share/templates/unbound.cb ${baseos}-unbound ${baseos}-host
}

create_host_iperf3() {
	create_host
	create_template TEMPLATE_PREFIX/share/templates/iperf3.cb ${baseos}-iperf3 ${baseos}-host
}

create_host_netperf() {
	create_host
	create_template TEMPLATE_PREFIX/share/templates/netperf.cb ${baseos}-netperf ${baseos}-host
}

if [ "$#" -eq 0 ]; then
	usage
	exit 1
fi


for tp in "$@"
do
	case "$tp" in
	localbaseos)
		shift
		create_localbaseos "$@"
		exit $?
		;;
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
	firewall-frr7-mpd5)
		;;
	firewall-frr7-strongswan)
		;;
	host-freeradius3)
		;;
	host-isc-dhcp44-server)
		;;
	host-unbound)
		;;
	host-iperf3)
		;;
	host-netperf)
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

