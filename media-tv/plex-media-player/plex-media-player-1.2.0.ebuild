# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit eutils cmake-utils

DESCRIPTION="next generation Plex client"
HOMEPAGE="http://plex.tv/"

BUILD="481"
COMMIT="b45bbf24"
MY_PV="${PV}.${BUILD}-${COMMIT}"
MY_P="${PN}-${MY_PV}"

SRC_URI="
	https://github.com/plexinc/${PN}/archive/v${MY_PV}.tar.gz -> ${P}.tar.gz
"

LICENSE="GPL-2 PMS-EULA"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="cec +desktop joystick lirc"

CDEPEND="
	>=dev-qt/qtcore-5.7
	>=dev-qt/qtnetwork-5.7
	>=dev-qt/qtxml-5.7
	>=dev-qt/qtwebchannel-5.7[qml]
	>=dev-qt/qtwebengine-5.7
	>=dev-qt/qtdeclarative-5.7
	>=dev-qt/qtquickcontrols-5.7
	>=dev-qt/qtx11extras-5.7
	>=media-video/mpv-0.11.0[libmpv]
	virtual/opengl
	x11-libs/libX11
	x11-libs/libXrandr

	cec? (
		<dev-libs/libcec-4.0.0
	)

	joystick? (
		media-libs/libsdl2
		virtual/libiconv
	)
"
DEPEND="
	${CDEPEND}

	dev-util/conan
"
RDEPEND="
	${DEPEND}

	lirc? (
		app-misc/lirc
	)
"

PATCHES=( "${FILESDIR}"/iconv-fix.patch "${FILESDIR}"/git-revision.patch )

S="${WORKDIR}/${MY_P}"

CMAKE_IN_SOURCE_BUILD=1

src_unpack() {
	unpack "${P}".tar.gz

	cd "${S}"

	sed -i -e 's/stable/public/g' conanfile.py

	env HOME="${S}" conan remote add plex https://conan.plex.tv
	env HOME="${S}" conan install -o include_desktop=$(usex desktop True False)
}


src_prepare() {
	sed -i -e '/^  install(FILES ${QTROOT}\/resources\/qtwebengine_devtools_resources.pak DESTINATION resources)$/d' src/CMakeLists.txt

	cmake-utils_src_prepare

	eapply_user
}

src_configure() {
	local mycmakeargs=(
		-DENABLE_CEC=$(usex cec)
		-DENABLE_SDL2=$(usex joystick)
		-DENABLE_LIRC=$(usex lirc)
		-DQTROOT=/usr
	)

	export BUILD_NUMBER="${BUILD}"
	export GIT_REVISION="${COMMIT}"

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	# menu items
	domenu "${FILESDIR}/plexmediaplayer.desktop"
	newicon -s 16 "${FILESDIR}/plexmediaplayer-16x16.png" plexmediaplayer.png
	newicon -s 24 "${FILESDIR}/plexmediaplayer-24x24.png" plexmediaplayer.png
	newicon -s 32 "${FILESDIR}/plexmediaplayer-32x32.png" plexmediaplayer.png
	newicon -s 48 "${FILESDIR}/plexmediaplayer-48x48.png" plexmediaplayer.png
	newicon -s 256 "${FILESDIR}/plexmediaplayer-256x256.png" plexmediaplayer.png
}
