# rstudio
# Date created:        20 July 2012
# Whom:                ndwns
#
# $FreeBSD$

PORTNAME= rstudio-server
VERSION= 0.97.25u
PORTVERSION= ${VERSION}
CATEGORIES= math
MASTER_SITES=http://s3.amazonaws.com/ubalo.io/rstudio/

MAINTAINER= ian@ubalo.com
COMMENT= Integrated Development Environment for R

NO_WRKSUBDIR= yes
USE_CMAKE= yes
USE_FORTRAN= yes
USE_JAVA= yes
JAVA_VERSION= 1.6
JAVA_VENDOR= openjdk
JAVA_BUILD= yes

LIB_DEPENDS+= uuid:${PORTSDIR}/misc/e2fsprogs-libuuid \
              inotify:${PORTSDIR}/devel/libinotify \
              boost_system:${PORTSDIR}/devel/boost-libs \
              R:${PORTSDIR}/math/R
BUILD_DEPENDS+= ${LOCALBASE}/bin/pkg-config:${PORTSDIR}/devel/pkg-config \
		${LOCALBASE}/bin/ant:${PORTSDIR}/devel/apache-ant

CMAKE_INSTALL_PREFIX= ${PREFIX}
CMAKE_ARGS= -DRSTUDIO_TARGET=Server \
            -DRSTUDIO_INSTALL_BIN=${PREFIX}/bin \
            -DRSTUDIO_INSTALL_SUPPORTING=${PREFIX}/share/rstudio
CMAKE_OUTSOURCE= yes

USE_RC_SUBR= rstudio_server
SUB_FILES= rserver.conf.sample rsession.conf.sample

USERS= rstudio-server
GROUPS= rstudio-server

PLIST= ${WRKDIR}/pkg-plist

post-extract:
	@cd ${WRKDIR}/dependencies/common && \
		${SH} install-dictionaries && \
		${SH} install-gwt && \
		${SH} install-mathjax

pre-install:
	${CP} ${PKGDIR}/pkg-plist ${PLIST}
	${CP} ${PKGDIR}/files/fixed-Makefile2 ${WRKDIR}/CMakeFiles/Makefile2
	@cd ${WRKDIR}/src/gwt && \
		${FIND} www -type f | ${SORT} | \
		${SED} -e 's:^:share/rstudio/:' >> ${PLIST} && \
		${FIND} www -type d | ${SORT} | \
		${SED} -e 's:^:@dirrm share/rstudio/:' >> ${PLIST}

post-install:
	${MKDIR} ${PREFIX}/etc/rstudio
	${INSTALL_DATA} ${WRKDIR}/rserver.conf.sample ${PREFIX}/etc/rstudio/
	${INSTALL_DATA} ${WRKDIR}/rsession.conf.sample ${PREFIX}/etc/rstudio/
	@if [ ! -f ${PREFIX}/etc/rstudio/rserver.conf ]; then \
		${CP} -p ${PREFIX}/etc/rstudio/rserver.conf.sample ${PREFIX}/etc/rstudio/rserver.conf ; \
	fi
	@if [ ! -f ${PREFIX}/etc/rstudio/rsession.conf ]; then \
		${CP} -p ${PREFIX}/etc/rstudio/rsession.conf.sample ${PREFIX}/etc/rstudio/rsession.conf ; \
	fi

.include <bsd.port.mk>
