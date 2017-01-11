RELEASE=4.1

# source form https://github.com/zfsonlinux/

ZFSVER=0.6.5.8
ZFSPKGREL=pve14~bpo80
SPLPKGREL=pve7~bpo80
ZFSPKGVER=${ZFSVER}-${ZFSPKGREL}
SPLPKGVER=${ZFSVER}-${SPLPKGREL}

SPLDIR=pkg-spl
SPLSRC=pkg-spl.tar.gz
ZFSDIR=pkg-zfs
ZFSSRC=pkg-zfs.tar.gz

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
zfsutils-linux_${ZFSPKGVER}_amd64.deb

ZFS_TRANS_DEBS=					\
libnvpair1_${ZFSPKGVER}_all.deb			\
libuutil1_${ZFSPKGVER}_all.deb			\
libzfs2_${ZFSPKGVER}_all.deb			\
libzpool2_${ZFSPKGVER}_all.deb			\
zfsutils_${ZFSPKGVER}_all.deb

DEBS=${SPL_DEBS} ${ZFS_DEBS} ${ZFS_TRANS_DEBS}

all: ${DEBS}

.PHONY: dinstall
dinstall: ${DEBS}
	dpkg -i ${DEBS}

.PHONY: spl
spl ${SPL_DEBS}: ${SPLSRC}
	rm -rf ${SPLDIR}
	tar xf ${SPLSRC}
	mv ${SPLDIR}/debian/changelog ${SPLDIR}/debian/changelog.org
	cat spl-changelog.Debian ${SPLDIR}/debian/changelog.org > ${SPLDIR}/debian/changelog
	cd ${SPLDIR}; ln -s ../spl-patches patches
	cd ${SPLDIR}; quilt push -a
	cd ${SPLDIR}; rm -rf .pc ./patches
	cd ${SPLDIR}; dpkg-buildpackage -b -uc -us 

.PHONY: zfs
zfs ${ZFS_DEBS} ${ZFS_TRANS_DEBS}: ${ZFSSRC}
	rm -rf ${ZFSDIR}
	tar xf ${ZFSSRC}
	mv ${ZFSDIR}/debian/changelog ${ZFSDIR}/debian/changelog.org
	cat zfs-changelog.Debian ${ZFSDIR}/debian/changelog.org > ${ZFSDIR}/debian/changelog
	cd ${ZFSDIR}; ln -s ../zfs-patches patches
	cd ${ZFSDIR}; quilt push -a
	cd ${ZFSDIR}; rm -rf .pc ./patches
	cd ${ZFSDIR}; dpkg-buildpackage -b -uc -us 

.PHONY: download
download:
	rm -rf pkg-spl pkg-zfs ${SPLSRC} ${ZFSSRC}
	# clone pkg-zfsonlinux/spl and checkout 0.6.5.8-2
	git clone -b debian/0.6.5.8-2 git://anonscm.debian.org/pkg-zfsonlinux/spl.git pkg-spl
	# clone pkg-zfsonlinux/zfs and checkout 0.6.5.8-1
	git clone -b debian/0.6.5.8-3 git://anonscm.debian.org/pkg-zfsonlinux/zfs.git pkg-zfs
	tar czf ${SPLSRC} pkg-spl
	tar czf ${ZFSSRC} pkg-zfs

.PHONY: clean
clean: 	
	rm -rf *~ *.deb *.changes ${ZFSDIR} ${SPLDIR}

.PHONY: distclean
distclean: clean


.PHONY: upload
upload: ${DEBS}
	tar -cf - ${DEBS} | ssh repoman@repo.proxmox.com upload
