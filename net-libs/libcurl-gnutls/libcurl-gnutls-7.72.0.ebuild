# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools multilib-minimal

DESCRIPTION="libcurl-gnutls.so for compatibility with Debian/Ubuntu binpkgs"
HOMEPAGE="https://www.gentoo.org/"
SRC_URI="https://curl.haxx.se/download/curl-${PV}.tar.xz"

LICENSE=""
SLOT="4"  # soname
KEYWORDS="~amd64"
IUSE="ipv6 test"

RESTRICT="!test? ( test )"

RDEPEND="
	net-libs/gnutls:0=[${MULTILIB_USEDEP}]
	dev-libs/nettle:0=[${MULTILIB_USEDEP}]
	app-misc/ca-certificates
	sys-libs/zlib[${MULTILIB_USEDEP}]"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

S=${WORKDIR}/curl-${PV}

src_prepare() {
	eapply "${FILESDIR}"/curl-respect-cflags-3.patch
	eapply "${FILESDIR}"/curl-fix-gnutls-nettle.patch

	sed -i '/LD_LIBRARY_PATH=/d' configure.ac || die #382241
	sed -i '/CURL_MAC_CFLAGS/d' configure.ac || die #637252

	# avoid building the client
	sed -i -e '/SUBDIRS/s:src::' Makefile.am || die
	sed -i -e '/SUBDIRS/s:scripts::' Makefile.am || die

	# rename the lib to match the installed name
	sed -i -e 's/libcurl\.la/libcurl-gnutls.la/' lib/Makefile.am || die
	sed -i -e 's/libcurl_la/libcurl_gnutls_la/g' lib/Makefile.am || die

	eapply_user
	eautoreconf
}

multilib_src_configure() {
	local myconf=()

	myconf+=(
		--without-mbedtls
		--without-nss
		--without-polarssl
		--without-ssl
		--without-winssl
		--without-ca-fallback
		--with-ca-bundle="${EPREFIX}"/etc/ssl/certs/ca-certificates.crt
		--with-gnutls
		--with-nettle
		--with-default-ssl-backend=gnutls
	)

	# These configuration options are organized alphabetically
	# within each category.  This should make it easier if we
	# ever decide to make any of them contingent on USE flags:
	# 1) protocols first.  To see them all do
	# 'grep SUPPORT_PROTOCOLS configure.ac'
	# 2) --enable/disable options second.
	# 'grep -- --enable configure | grep Check | awk '{ print $4 }' | sort
	# 3) --with/without options third.
	# grep -- --with configure | grep Check | awk '{ print $4 }' | sort

	ECONF_SOURCE="${S}" \
	econf \
		--disable-alt-svc \
		--enable-crypto-auth \
		--enable-dict \
		--disable-esni \
		--enable-file \
		--disable-ftp \
		--disable-gopher \
		--enable-http \
		--disable-imap \
		--disable-ldap \
		--disable-ldaps \
		--disable-mqtt \
		--disable-ntlm-wb \
		--disable-pop3 \
		--enable-rt  \
		--enable-rtsp \
		--disable-smb \
		--disable-libssh2 \
		--disable-smtp \
		--disable-telnet \
		--disable-tftp \
		--enable-tls-srp \
		--disable-ares \
		--enable-cookies \
		--enable-dateparse \
		--enable-dnsshuffle \
		--enable-doh \
		--enable-hidden-symbols \
		--enable-http-auth \
		$(use_enable ipv6) \
		--enable-largefile \
		--enable-manual \
		--enable-mime \
		--enable-netrc \
		--disable-progress-meter \
		--enable-proxy \
		--disable-sspi \
		--disable-static \
		--disable-threaded-resolver \
		--disable-pthreads \
		--disable-versioned-symbols \
		--without-amissl \
		--without-bearssl \
		--without-cyassl \
		--without-darwinssl \
		--without-fish-functions-dir \
		--without-libidn2 \
		--without-gssapi \
		--without-libmetalink \
		--without-nghttp2 \
		--without-libpsl \
		--without-nghttp3 \
		--without-ngtcp2 \
		--without-quiche \
		--without-librtmp \
		--without-brotli \
		--without-schannel \
		--without-secure-transport \
		--without-spnego \
		--without-winidn \
		--without-wolfssl \
		--with-zlib \
		"${myconf[@]}"
}

multilib_src_install() {
	default

	rm -Rf "${ED}"/usr/{bin,include,share}
	rm -Rf "${ED}"/usr/$(get_libdir)/pkgconfig
}

multilib_src_install_all() {
	find "${ED}" -type f -name '*.la' -delete
	rm -rf "${ED}"/etc/
}
