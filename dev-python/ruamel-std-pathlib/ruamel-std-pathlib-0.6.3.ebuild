# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 python3_{4,5,6} )

inherit distutils-r1 vcs-snapshot

DESCRIPTION="Ruamel enhancements to pathlib and pathlib2"
HOMEPAGE="https://pypi.python.org/pypi/ruamel.std.pathlib"
MY_PN="${PN//-/.}"
MY_P="${MY_PN}-${PV}"
SRC_URI="https://bitbucket.org/${MY_PN/.//}/get/${PV}.tar.gz -> ${MY_P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test"

RDEPEND="${PYTHON_DEPS}
	$(python_gen_cond_dep 'dev-python/pathlib2[${PYTHON_USEDEP}]' python2_7 python3_4)"

DEPEND="${RDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]
	test? ( dev-python/pytest[${PYTHON_USEDEP}] dev-python/flake8[${PYTHON_USEDEP}] )"

S="${WORKDIR}/${MY_P}"

python_install() {
	distutils-r1_python_install --single-version-externally-managed
	find "${ED}" -name '*.pth' -delete || die
}

python_test() {
	py.test -v _test/test_*.py || die
}
