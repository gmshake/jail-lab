# Jail based CLOS Network Virtual Lab

Jail based CLOS Network Virtual Lab


## Prerequisite

* FreeBSD 12 +
* Internet network access
* 600MB free zfs pool


## The Topology

refer: https://gitlab.com/cumulus-consulting/goldenturtle/cldemo2/-/raw/master/documentation/diagrams/cldemo2-diagram.svg


## Design



## Config Table

| Node     	| ASN   	| Loopback Address /32 	| IPv6 Address /128 	| Rack   	|
|----------	|-------	|----------------------	|-------------------	|--------	|
| spine01  	| 64520 	| 10.0.0.1             	| 2001:db8::1       	|        	|
| spine02  	| 64520 	| 10.0.0.2             	| 2001:db8::2       	|        	|
| leaf01   	| 64530 	| 10.0.10.1            	| 2001:db8::a:1     	| rack 1 	|
| leaf02   	| 64530 	| 10.0.10.2            	| 2001:db8::a:2     	| rack 1 	|
| server01 	| 65000 	| 10.0.10.100          	| 2001:db8::a:100   	| rack 1 	|
| server02 	| 65001 	| 10.0.10.101          	| 2001:db8::a:101   	| rack 1 	|
| leaf03   	| 64531 	| 10.0.11.1            	| 2001:db8::b:1     	| rack 2 	|
| leaf04   	| 64531 	| 10.0.11.2            	| 2001:db8::b:2     	| rack 2 	|
| server03 	| 65002 	| 10.0.11.100          	| 2001:db8::b:100   	| rack 2 	|
| exit01   	| 64514 	| 10.0.12.1            	| 2001:db8::c:1     	| rack 3 	|
| exit02   	| 64514 	| 10.0.12.2            	| 2001:db8::c:2     	| rack 3 	|
| edge01   	| 200   	| 10.0.12.100          	| 2001:db8::c:100   	| rack 3 	|
| isp01    	| 100   	| 100.100.0.1          	| 2001:db9::1       	|        	|
| isp02    	| 101   	| 100.101.0.1          	| 2001:dba::1       	|        	|



## Links

https://gitlab.com/cumulus-consulting/goldenturtle/cldemo2
https://www.tablesgenerator.com/markdown_tables
