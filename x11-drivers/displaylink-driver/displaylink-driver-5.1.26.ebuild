# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils systemd udev

DESCRIPTION="DisplayLink USB Graphics Software"
HOMEPAGE="http://www.displaylink.com/downloads/ubuntu"
SRC_URI="${P}.zip"

LICENSE="DisplayLink"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="systemd"

QA_PREBUILT="/opt/displaylink/DisplayLinkManager"
RESTRICT="fetch"

DEPEND="app-admin/chrpath"
RDEPEND=">=sys-devel/gcc-4.8.3
	=x11-drivers/evdi-1.6*
	virtual/libusb:1
	|| ( x11-drivers/xf86-video-modesetting >=x11-base/xorg-server-1.17.0 )
	!systemd? ( sys-power/pm-utils )"

pkg_nofetch() {
	einfo "Please download DisplayLink USB Graphics Software for Ubuntu 4.1.zip from"
	einfo "http://www.displaylink.com/downloads/ubuntu"
	einfo "and rename it to ${P}.zip"
}

src_unpack() {
	default
	sh ./"${PN}"-"${PV}".run --noexec --target "${P}"
}

src_install() {
	if [[ ( $(gcc-major-version) -eq 5 && $(gcc-minor-version) -ge 1 ) || $(gcc-major-version) -gt 5 ]]; then
		MY_UBUNTU_VERSION=1604
	else
		MY_UBUNTU_VERSION=1404
	fi

	einfo "Using package for Ubuntu ${MY_UBUNTU_VERSION} based on your gcc version: $(gcc-version)"

	case "${ARCH}" in
		amd64)	MY_ARCH="x64" ;;
		*)		MY_ARCH="${ARCH}" ;;
	esac

	DLM="${S}/${MY_ARCH}-ubuntu-${MY_UBUNTU_VERSION}/DisplayLinkManager"

	dodir /opt/displaylink
	keepdir /var/log/displaylink

	exeinto /opt/displaylink
	chrpath -d "${DLM}"
	doexe "${DLM}"

	insinto /opt/displaylink
	doins *.spkg

	source "${S}/udev-installer.sh"
	source "${S}/udev-installer.sh"

	create_udev_rules_file "${S}/99-displaylink.rules"
	udev_dorules "${S}/99-displaylink.rules"

	insinto /opt/displaylink
	insopts -m0755
	if use systemd; then
		create_bootstrap_file systemd "${S}/udev.sh"
		newins "${S}/udev.sh" udev.sh
		# newins "${FILESDIR}/pm-systemd-displaylink" suspend.sh
		# dosym /opt/displaylink/suspend.sh /lib/systemd/system-sleep/displaylink.sh
		add_pm_script systemd
		dosym /opt/displaylink/suspend.sh /lib/systemd/system-sleep/displaylink.sh
		add_systemd_service
		systemd_dounit "${S}/displaylink-driver.service"
	else
		die "Only systemd is supported for now, pull request will be well accepted"
	fi
}

pkg_postinst() {
	einfo "The DisplayLinkManager Init is now called dlm"
	einfo ""
	einfo "You should be able to use xrandr as follows:"
	einfo "xrandr --setprovideroutputsource 1 0"
	einfo "Repeat for more screens, like:"
	einfo "xrandr --setprovideroutputsource 2 0"
	einfo "Then, you can use xrandr or GUI tools like arandr to configure the screens, e.g."
	einfo "xrandr --output DVI-1-0 --auto"
}

## copied from displaylink-installer.sh
add_pm_script()
{
  COREDIR="${D}/opt/displaylink"
  cat > $COREDIR/suspend.sh <<EOF
#!/bin/bash
# Copyright (c) 2015 - 2019 DisplayLink (UK) Ltd.

suspend_displaylink-driver()
{
  #flush any bytes in pipe
  while read -n 1 -t 1 SUSPEND_RESULT < /tmp/PmMessagesPort_out; do : ; done;

  #suspend DisplayLinkManager
  echo "S" > /tmp/PmMessagesPort_in

  if [ -p /tmp/PmMessagesPort_out ]; then
    #wait until suspend of DisplayLinkManager finish
    read -n 1 -t 10 SUSPEND_RESULT < /tmp/PmMessagesPort_out
  fi
}

resume_displaylink-driver()
{
  #resume DisplayLinkManager
  echo "R" > /tmp/PmMessagesPort_in
}

EOF

  if [ "$1" = "upstart" ]
  then
    cat >> $COREDIR/suspend.sh <<EOF
case "\$1" in
  thaw)
    resume_displaylink-driver
    ;;
  hibernate)
    suspend_displaylink-driver
    ;;
  suspend)
    suspend_displaylink-driver
    ;;
  resume)
    resume_displaylink-driver
    ;;
esac

EOF
  elif [ "$1" = "systemd" ]
  then
    cat >> $COREDIR/suspend.sh <<EOF
case "\$1/\$2" in
  pre/*)
    suspend_displaylink-driver
    ;;
  post/*)
    resume_displaylink-driver
    ;;
esac

EOF
  fi

  chmod 0755 $COREDIR/suspend.sh
#   if [ "$1" = "upstart" ]
#   then
#     ln -sf $COREDIR/suspend.sh /etc/pm/sleep.d/displaylink.sh
#   elif [ "$1" = "systemd" ]
#   then
#     ln -sf $COREDIR/suspend.sh /lib/systemd/system-sleep/displaylink.sh
#   fi
}

## copied from displaylink-installer.sh
add_systemd_service()
{
  MODVER="${PV}"

  cat > "${S}"/displaylink-driver.service <<EOF
[Unit]
Description=DisplayLink Driver Service
After=display-manager.service
Conflicts=getty@tty7.service

[Service]
ExecStartPre=/bin/sh -c 'modprobe evdi || (dkms install evdi/$MODVER && modprobe evdi)'
ExecStart=/opt/displaylink/DisplayLinkManager
Restart=always
WorkingDirectory=/opt/displaylink
RestartSec=5

EOF

  chmod 0644 "${S}"/displaylink-driver.service
}
