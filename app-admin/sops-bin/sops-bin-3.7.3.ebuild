# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit unpacker

MY_PN="${PN/-bin}"

DESCRIPTION="Mozilla SOPS: Secrets OPerationS (binary version)"
HOMEPAGE="https://github.com/mozilla/sops"

SRC_URI="https://github.com/mozilla/sops/releases/download/v${PV}/sops_${PV}_amd64.deb"

RESTRICT="mirror strip bindist"

LICENSE="MIT"
SLOT="0"
KEYWORDS="-* ~amd64"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""

#QA_PRESTRIPPED="*"
#QA_PREBUILT="opt/${MY_PN}/sops"

S="${WORKDIR}"

src_unpack(){
    unpack_deb ${A}
}
src_install(){
	dobin usr/local/bin/${MY_PN}
}
