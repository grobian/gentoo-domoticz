# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Domoticz home automation system"
HOMEPAGE="https://www.domoticz.com"
# domoticz only does unversioned releases :(
SRC_URI="https://releases.domoticz.com/releases/release/domoticz_linux_x86_64.tgz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="-* ~amd64"
IUSE="systemd"

DEPEND="net-libs/libcurl-gnutls:4"
RDEPEND="${DEPEND}
	!app-misc/domoticz"
BDEPEND=""

S=${WORKDIR}

src_install() {
	local MYPN=${PN%-bin}
	if use systemd ; then
		systemd_newunit "${FILESDIR}"/${MYPN}.service "${MYPN}.service"
		systemd_install_serviced "${FILESDIR}"/${MYPN}.service.conf
	else
		newinitd "${FILESDIR}"/${MYPN}.init.d ${MYPN}
		newconfd "${FILESDIR}"/${MYPN}.conf.d ${MYPN}
	fi

	dodir /opt/${MYPN}
	cp -pPR * ${ED}/opt/${MYPN}/

	insinto /var/lib/${MYPN}
	touch ${ED}/var/lib/${MYPN}/.keep_db_folder

	# move scripts to /var/lib/domoticz
	mv ${ED}/opt/${MYPN}/scripts ${ED}/var/lib/${MYPN}/
}
