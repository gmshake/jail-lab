PREFIX?=/usr/local
DST=	${DESTDIR}${PREFIX}

all:

install:
	mkdir -p ${DST}/etc/templates ${DST}/share/templates ${DST}/bin
	cp *.cb *.filter ${DST}/share/templates/
	cp modules.subr network.subr template.subr utils.subr ${DST}/etc/templates/
	sed s:TEMPLATE_PREFIX:${PREFIX}: jail.subr > ${DST}/etc/templates/jail.subr
	sed s:TEMPLATE_PREFIX:${PREFIX}: jail.sh > ${DST}/bin/jail-admin
	chmod 755 ${DST}/etc/templates/*.subr
	chmod 755 ${DST}/bin/jail-admin

