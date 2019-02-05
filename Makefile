RELEASE=5.1

# source form https://github.com/zfsonlinux/

ZFSVER=0.7.12
ZFSPKGREL=pve1~bpo1
SPLPKGREL=pve1~bpo1
ZFSPKGVER=${ZFSVER}-${ZFSPKGREL}
SPLPKGVER=${ZFSVER}-${SPLPKGREL}

SPLDIR=spl-linux_${ZFSVER}
SPLSRC=spl/upstream
SPLPKG=spl/debian
ZFSDIR=zfs-linux_${ZFSVER}
ZFSSRC=zfs/upstream
ZFSPKG=zfs/debian

SPL_DEB = 					\
spl_${SPLPKGVER}_amd64.deb
SPL_DSC = spl-linux_${SPLPKGVER}.dsc

ZFS_DEB1= libnvpair1linux_${ZFSPKGVER}_amd64.deb
ZFS_DEB2= 					\
libuutil1linux_${ZFSPKGVER}_amd64.deb		\
libzfs2linux_${ZFSPKGVER}_amd64.deb		\
libzfslinux-dev_${ZFSPKGVER}_amd64.deb		\
libzpool2linux_${ZFSPKGVER}_amd64.deb		\
zfs-dbg_${ZFSPKGVER}_amd64.deb			\
zfs-zed_${ZFSPKGVER}_amd64.deb			\
zfs-initramfs_${ZFSPKGVER}_all.deb		\
zfs-test_${ZFSPKGVER}_amd64.deb		\
zfsutils-linux_${ZFSPKGVER}_amd64.deb
ZFS_DEBS= $(ZFS_DEB1) $(ZFS_DEB2)
ZFS_DSC = zfs-linux_${ZFSPKGVER}.dsc

DEBS=${SPL_DEB} ${ZFS_DEBS}
DSCS=${SPL_DSC} ${ZFS_DSC}

all: deb
.PHONY: deb
deb: ${DEBS}
.PHONY: dsc
dsc: ${DSCS}

.PHONY: dinstall
dinstall: ${DEBS}
	dpkg -i ${DEBS}

.PHONY: submodule
submodule:
	test -f "${ZFSSRC}/README.markdown" || git submodule update --init
	test -f "${SPLSRC}/README.markdown" || git submodule update --init

.PHONY: spl
spl: ${SPL_DEB}
${SPL_DEB}: ${SPLDIR}
	cd ${SPLDIR}; dpkg-buildpackage -b -uc -us
	lintian ${SPL_DEB}

${SPL_DSC}: ${SPLDIR}
	tar czf spl-linux_${ZFSVER}.orig.tar.gz ${SPLDIR}
	cd ${SPLDIR}; dpkg-buildpackage -S -uc -us -d
	lintian $@

${SPLDIR}: ${SPLSRC} ${SPLPKG}
	rm -rf ${SPLDIR}
	mkdir ${SPLDIR}
	cp -a ${SPLSRC}/* ${SPLDIR}/
	cp -a ${SPLPKG} ${SPLDIR}/debian

.PHONY: zfs
zfs: $(ZFS_DEBS)
$(ZFS_DEB2): $(ZFS_DEB1)
$(ZFS_DEB1): ${ZFSDIR}
	cd ${ZFSDIR}; dpkg-buildpackage -b -uc -us
	lintian ${ZFS_DEBS}

${ZFS_DSC}: ${ZFSDIR}
	tar czf zfs-linux_${ZFSVER}.orig.tar.gz ${ZFSDIR}
	cd ${ZFSDIR}; dpkg-buildpackage -S -uc -us -d
	lintian $@

${ZFSDIR}: $(ZFSSRC) ${ZFSPKG}
	rm -rf ${ZFSDIR}
	mkdir ${ZFSDIR}
	cp -a ${ZFSSRC}/* ${ZFSDIR}/
	cp -a ${ZFSPKG} ${ZFSDIR}/debian


.PHONY: clean
clean: 	
	rm -rf *~ *.deb *.changes *.buildinfo *.dsc *.orig.tar.* *.debian.tar.* ${ZFSDIR} ${SPLDIR}

.PHONY: distclean
distclean: clean

.PHONY: upload
upload: ${DEBS}
	tar -cf - ${DEBS} | ssh repoman@repo.proxmox.com -- upload --product pve,pmg --dist stretch --arch amd64
