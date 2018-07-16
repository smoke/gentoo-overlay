# Copyright 2017 Yurij Mikhalevich <yurij@mikhalevi.ch>
# Distributed under the terms of the MIT License

EAPI=6

inherit unpacker gnome2-utils xdg

MY_PN="${PN/-bin/}"

DESCRIPTION="Video conferencing and web conferencing service"
BASE_SERVER_URI="https://zoom.us"
HOMEPAGE="${BASE_SERVER_URI}"
SRC_URI="${BASE_SERVER_URI}/client/${PV}/${MY_PN}_x86_64.pkg.tar.xz -> ${MY_PN}-${PV}_x86_64.pkg.tar.xz"

LICENSE="ZOOM"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="mirror"

IUSE="pulseaudio"

QA_PREBUILT="opt/zoom/*"

DEPEND=""
RDEPEND="${DEPEND}
	pulseaudio? ( media-sound/pulseaudio )
	dev-db/sqlite
	dev-db/unixODBC
	dev-libs/glib
	dev-libs/nss
	dev-libs/libxslt
	dev-qt/qtmultimedia
	media-libs/fontconfig
	media-libs/gstreamer:0.10
	media-libs/gst-plugins-base:0.10
	media-libs/mesa
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXi
	x11-libs/libXrender
	dev-qt/qtwebengine
	dev-qt/qtsvg"

S=${WORKDIR}

src_prepare() {
	rm -f ${WORKDIR}/.PKGINFO ${WORKDIR}/.INSTALL ${WORKDIR}/.MTREE
	sed -i -e 's:Icon=Zoom.png:Icon=Zoom:' "${WORKDIR}/usr/share/applications/Zoom.desktop"
	sed -i -e 's:Application;::' "${WORKDIR}/usr/share/applications/Zoom.desktop"
	eapply_user
}

src_install() {
	cp -Rp "${S}/"* "${D}"
}

pkg_preinst() {
	xdg_pkg_preinst
	gnome2_icon_savelist
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
	gnome2_icon_cache_update
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
	gnome2_icon_cache_update
}
