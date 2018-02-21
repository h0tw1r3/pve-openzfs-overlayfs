RELEASE=5.1

# source form https://github.com/zfsonlinux/

ZFSVER=0.7.6
ZFSPKGREL=pve1~bpo9
SPLPKGREL=pve1~bpo9
ZFSPKGVER=${ZFSVER}-${ZFSPKGREL}
SPLPKGVER=${ZFSVER}-${SPLPKGREL}

SPLDIR=spl-build
SPLSRC=spl-debian
ZFSDIR=zfs-build
ZFSSRC=zfs-debian

SPL_DEBS= 					\
spl_${SPLPKGVER}_amd64.deb

ZFS_DEBS= 					\
libnvpair1linux_${ZFSPKGVER}_amd64.deb		\
libuutil1linux_${ZFSPKGVER}_amd64.deb		\
libzfs2linux_${ZFSPKGVER}_amd64.deb		\
libzfslinux-dev_${ZFSPKGVER}_amd64.deb		\
libzpool2linux_${ZFSPKGVER}_amd64.deb		\
zfs-dbg_${ZFSPKGVER}_amd64.deb			\
zfs-zed_${ZFSPKGVER}_amd64.deb			\
zfs-initramfs_${ZFSPKGVER}_all.deb		\
zfs-test_${ZFSPKGVER}_amd64.deb		\
zfsutils-linux_${ZFSPKGVER}_amd64.deb

DEBS=${SPL_DEBS} ${ZFS_DEBS}

all: deb
deb: ${DEBS}

.PHONY: dinstall
dinstall: ${DEBS}
	dpkg -i ${DEBS}

.PHONY: submodule
submodule:
	test -f "${ZFSSRC}/debian/changelog" || git submodule update --init
	test -f "${SPLSRC}/debian/changelog" || git submodule update --init

.PHONY: spl
spl ${SPL_DEBS}: ${SPLSRC}
	rm -rf ${SPLDIR}
	mkdir ${SPLDIR}
	cp -a ${SPLSRC}/* ${SPLDIR}/
	mv ${SPLDIR}/debian/changelog ${SPLDIR}/debian/changelog.org
	cat spl-changelog.Debian ${SPLDIR}/debian/changelog.org > ${SPLDIR}/debian/changelog
	cd ${SPLDIR}; ln -s ../spl-patches patches
	cd ${SPLDIR}; quilt push -a
	cd ${SPLDIR}; rm -rf .pc ./patches
	cd ${SPLDIR}; dpkg-buildpackage -b -uc -us

.PHONY: zfs
zfs ${ZFS_DEBS} ${ZFS_TRANS_DEBS}: ${ZFSSRC}
	rm -rf ${ZFSDIR}
	mkdir ${ZFSDIR}
	cp -a ${ZFSSRC}/* ${ZFSDIR}/
	mv ${ZFSDIR}/debian/changelog ${ZFSDIR}/debian/changelog.org
	cat zfs-changelog.Debian ${ZFSDIR}/debian/changelog.org > ${ZFSDIR}/debian/changelog
	cd ${ZFSDIR}; ln -s ../zfs-patches patches
	cd ${ZFSDIR}; quilt push -a
	cd ${ZFSDIR}; rm -rf .pc ./patches
	cd ${ZFSDIR}; dpkg-buildpackage -b -uc -us

.PHONY: clean
clean: 	
	rm -rf *~ *.deb *.changes *.buildinfo ${ZFSDIR} ${SPLDIR}

.PHONY: distclean
distclean: clean


.PHONY: upload
upload: ${DEBS}
	tar -cf - ${DEBS} | ssh repoman@repo.proxmox.com -- upload --product pve,pmg --dist stretch --arch amd64
