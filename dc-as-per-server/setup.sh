#!/bin/sh

jail_pool="zroot"
jail_base_path="/jails"
jail_base_templates_path="$jail_base_path/templates"
jail_base_os_ver="13.0-RELEASE"
#jail_base_os_ver="auto"

check_version() {
	if [ "$jail_base_os_ver" = "auto" ]; then
		local rver=$( freebsd-version -r )
		jail_base_os_ver="${rver%-p*}"
	fi
}

check_version

jail_base_os_path="$jail_base_templates_path/FreeBSD-${jail_base_os_ver}"
jail_base_frr_path="${jail_base_os_path}-frr7"


pgm="${0##*/}" # Program basename

usage() {
	echo "Usage: $pgm [prepare] [up] [down] [clean]"
	exit 1
}


prepare() {
	prepare_base_os
	prepare_frr_template
	create_destroy_jails prepare
}

prepare_base_os() {
	local kind="releases"
	local typever="${jail_base_os_ver#*-}"
	if [ "$typever" = "STABLE" -o "$typever" = "CURRENT" ]; then
		kind="snapshots"
	fi
	local jail_base_os_url="https://download.freebsd.org/ftp/$kind/`uname -m`/`uname -p`/$jail_base_os_ver/base.txz"

	zfs list ${jail_pool}${jail_base_path} > /dev/null 2>&1 || {
		zfs create -o mountpoint=$jail_base_path ${jail_pool}${jail_base_path} || {
			echo "Error create zfs dataset ${jail_pool}${jail_base_path}, abort!"
			exit 1
		}
	}

	zfs list ${jail_pool}${jail_base_templates_path} > /dev/null 2>&1 || {
		zfs create ${jail_pool}${jail_base_templates_path} || {
			echo "Error create zfs dataset ${jail_pool}${jail_base_templates_path}, abort!"
			exit 1
		}
	}

	zfs list ${jail_pool}${jail_base_os_path} > /dev/null 2>&1 || {
		zfs create ${jail_pool}${jail_base_os_path} || {
			echo "Error create zfs dataset ${jail_pool}${jail_base_os_path}, abort!"
			exit 1
		}
		fetch -qo - $jail_base_os_url | tar -xf - -C $jail_base_os_path || {
			zfs destroy ${jail_pool}${jail_base_os_path}
			echo "Error fetch and install base os, abort!"
			exit 1
		}
		zfs snap ${jail_pool}${jail_base_os_path}@p0
	}
}

prepare_frr_template() {
	zfs list -t snap ${jail_pool}${jail_base_frr_path}@p1 > /dev/null 2>&1 || {
		zfs clone ${jail_pool}${jail_base_os_path}@p0 ${jail_pool}${jail_base_frr_path} || {
			echo "Error create zfs dataset ${jail_pool}${jail_base_frr_path}, abort!"
			exit 1
		}

		cp /etc/resolv.conf ${jail_base_frr_path}/etc && mount -t devfs devfs ${jail_base_frr_path}/dev && pkg -c $jail_base_frr_path install -qy frr7 && umount ${jail_base_frr_path}/dev && rm ${jail_base_frr_path}/etc/resolv.conf && zfs snap ${jail_pool}${jail_base_frr_path}@p0 && {
			sysrc -R $jail_base_frr_path cron_enable=NO
			sysrc -R $jail_base_frr_path sendmail_enable=NONE
			sysrc -R $jail_base_frr_path syslogd_enable=NO
			sysrc -R $jail_base_frr_path gateway_enable=YES
			sysrc -R $jail_base_frr_path ipv6_gateway_enable=YES
			sysrc -R $jail_base_frr_path ipv6_activate_all_interfaces=YES
			sysrc -R $jail_base_frr_path frr_enable=YES
			sysrc -R $jail_base_frr_path frr_vtysh_boot=YES
			sysrc -R $jail_base_frr_path frr_daemons="zebra bgpd staticd"
			sysrc -R $jail_base_frr_path frr_flags="-P0"
		} && zfs snap ${jail_pool}${jail_base_frr_path}@p1 || {
			zfs destroy -r ${jail_pool}${jail_base_frr_path}
			echo "Error install frr pkg, abort!"
			exit 1
		}
	}
}

setup() {
	# prepare jail filesystem
	create_destroy_jails prepare

	# create jail network interfaces
	create_destroy_network_devices create

	# startup jails
	create_destroy_jails create
}

create_network_device() {
	local paira=$1
	local pairb=$2

	local edge=$( ifconfig epair create )
	ifconfig $edge name ${paira}.${pairb} > /dev/null && {
		ifconfig ${edge%a}b name ${pairb}.${paira} > /dev/null || ifconfig ${edge%a}b destroy
	} || ifconfig $edge destroy
}

destroy_network_device() {
	local paira=$1
	local pairb=$2
	ifconfig ${paira}.${pairb} destroy
}

create_destroy_network_devices() {
	local action=$1

	# spine leaf edges
	for spine in spine01 spine02
	do
		for leaf in leaf01 leaf02 leaf03 leaf04 exit01 exit02
		do
			${action}_network_device $spine $leaf
		done
	done

	# leaf server edges
	for leaf in leaf01 leaf02
	do
		for server in server01 server02
		do
			${action}_network_device $leaf $server
		done
	done

	for leaf in leaf03 leaf04
	do
		for server in server03
		do
			${action}_network_device $leaf $server
		done
	done

	for leaf in exit01 exit02
	do
		for server in edge01
		do
			${action}_network_device $leaf $server
		done
	done

	for edge in edge01
	do
		for isp in isp01 isp02
		do
			${action}_network_device $edge $isp
		done
	done

}

create_destroy_jails() {
	local action=$1

	for spine in spine01 spine02
	do
		${action}_jail $spine "leaf01 leaf02 leaf03 leaf04 exit01 exit02"
	done

	for leaf in leaf01 leaf02
	do
		${action}_jail $leaf "server01 server02" "spine01 spine02" 24
	done

	for server in server01 server02
	do
		${action}_jail $server "leaf01 leaf02"
	done

	for leaf in leaf03 leaf04
	do
		${action}_jail $leaf "server03" "spine01 spine02" 24
	done

	for server in server03
	do
		${action}_jail $server "leaf03 leaf04"
	done

	for leaf in exit01 exit02
	do
		${action}_jail $leaf "edge01" "spine01 spine02" 24
	done

	for e in edge01
	do
		${action}_jail $e "isp01 isp02" "exit01 exit02" 24
	done

	for isp in isp01 isp02
	do
		${action}_jail $isp "edge01"
	done
}

prepare_jail() {
	local name=$1
	local path="$jail_base_path/$name"

	[ -d "$path" ] || {
		zfs list -t snap ${jail_pool}${jail_base_frr_path}@p1 > /dev/null || {
			echo "Please prepare first, abort!"
			exit 1
		}
		zfs clone ${jail_pool}${jail_base_frr_path}@p1 ${jail_pool}${path} || {
			echo "Error prepare jail $name, abort!"
			exit 1
		}
		zfs snap ${jail_pool}${path}@init
	}
}

clean_jail() {
	local name=$1
	local path="$jail_base_path/$name"

	[ -d "$path" ] && zfs destroy -r ${jail_pool}${path}
}

create_jail() {
	local name=$1
	local downlinks=$2
	local uplinks=$3
	local maxports=$4
	local path="$jail_base_path/$name"
	local exec_created="\"mount -t nullfs $PWD/conf/$name $path/usr/local/etc/frr\""
	local exec_start=""
	local vnet_interface=""

	local i=0
	for downlink in $downlinks
	do
		vnet_interface="$vnet_interface vnet.interface=\"${name}.${downlink}\""
		exec_start="$exec_start exec.start=\"ifconfig ${name}.${downlink} name en$i up\""
		i=$(($i+1))
	done

	local uplink_count=0
	for uplink in $uplinks
	do
		uplink_count=$(($uplink_count+1))
	done

	if [ $uplink_count -gt 0 ]; then
		local j=$(($maxports-$uplink_count))
		if [ $j -le $i ]; then
			echo "Current maxports [$maxports] is too small, please increase maxports, abort."
			exit 1
		fi

		for uplink in $uplinks
		do
			vnet_interface="$vnet_interface vnet.interface=\"${name}.${uplink}\""
			exec_start="$exec_start exec.start=\"ifconfig ${name}.${uplink} name en$j up\""
			j=$(($j+1))
		done
	fi

	exec_start="$exec_start exec.start=\"/bin/sh /etc/rc\""
	#jail -c name=$name path=$path exec.created=$exec_created host.hostname=$name mount.devfs vnet persist $vnet_interface $exec_start
	sh -c "jail -c name=$name path=$path exec.created=$exec_created host.hostname=$name mount.devfs vnet persist $vnet_interface $exec_start"
}

destroy_jail() {
	local name=$1
	local downlinks=$2
	local uplinks=$3
	local maxports=$4
	local path="$jail_base_path/$name"
	local exec_stop="/bin/sh /etc/rc.shutdown jail"

	jls -j $name > /dev/null 2>&1 && {
		jexec $name $exec_stop

		local i=0
		for downlink in $downlinks
		do
			jexec $name ifconfig en$i name ${name}.${downlink} down
			i=$(($i+1))
		done

		local uplink_count=0
		for uplink in $uplinks
		do
			uplink_count=$(($uplink_count+1))
		done
		if [ $uplink_count -gt 0 ]; then
			local j=$(($maxports-$uplink_count))
			for uplink in $uplinks
			do
				jexec $name ifconfig en$j name ${name}.${uplink} down
				j=$(($j+1))
			done
		fi

		jail -r $name
		umount -t nullfs $path/usr/local/etc/frr
		umount -t devfs $path/dev
	}
}


teardown() {
	# destroy jails
	create_destroy_jails destroy

	# XXX vnet interface will not immediately visable to vnet 0
	sleep 1

	create_destroy_network_devices destroy
}


cleanup() {
	# clean jails filesystem
	create_destroy_jails clean

	echo "Now you can remove dataset ${jail_pool}${jail_base_os_path} and ${jail_pool}${jail_base_frr_path} if they are not needed any more"
}


action="$1"

case "$action" in
prepare)
	prepare
        ;;
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
