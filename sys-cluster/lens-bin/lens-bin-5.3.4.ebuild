# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
# Forked from https://gitlab.einfach.org/r900/r900-overlay/-/tree/master/sys-cluster/lens-bin

EAPI=8
inherit unpacker desktop

MY_PN="${PN%-bin}"

DESCRIPTION="Kubernetes IDE"
HOMEPAGE="https://k8slens.dev/"
SRC_URI="https://api.k8slens.dev/binaries/Lens-5.3.4-latest.20220120.1.amd64.deb"

LICENSE="Lens IDE EULA"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="bindist strip"

# Depends: libgtk-3-0, libnotify4, libnss3, libxss1, libxtst6, xdg-utils, libatspi2.0-0, libuuid1, libsecret-1-0
# Recommends: libappindicator3-1
# this depends on so much more...
DEPEND="x11-libs/gtk+:3
		x11-libs/libnotify
		dev-libs/nss
		x11-misc/xdg-utils
		app-crypt/libsecret"
RDEPEND="${DEPEND}"
BDEPEND=""

S="${WORKDIR}"

src_prepare() {
	default
	gunzip usr/share/doc/lens/changelog.gz
}

src_install() {
	doicon usr/share/icons/hicolor/512x512/apps/lens.png
	doicon -s 512 usr/share/icons/hicolor/512x512/apps/lens.png
	domenu usr/share/applications/lens.desktop
	dodoc usr/share/doc/lens/changelog
	mv opt "${ED}" || die
}
