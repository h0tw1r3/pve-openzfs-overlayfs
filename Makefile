# source form https://github.com/zfsonlinux/

ZFSPKG=debian
ZFSVER != dpkg-parsechangelog -l ${ZFSPKG}/changelog -Sversion | cut -d- -f1
ZFSPKGVER != dpkg-parsechangelog -l ${ZFSPKG}/changelog -Sversion
ZFSDIR=zfs-linux_${ZFSVER}
ZFSSRC=upstream

ZFS_DEB1= libnvpair3linux_${ZFSPKGVER}_amd64.deb

ZFS_DEB_BINARY =				\
libpam-zfs_${ZFSPKGVER}_amd64.deb		\
libuutil3linux_${ZFSPKGVER}_amd64.deb		\
libzfs4linux_${ZFSPKGVER}_amd64.deb		\
libzfsbootenv1linux_${ZFSPKGVER}_amd64.deb	\
libzpool4linux_${ZFSPKGVER}_amd64.deb		\
zfs-test_${ZFSPKGVER}_amd64.deb			\
zfsutils-linux_${ZFSPKGVER}_amd64.deb		\
zfs-zed_${ZFSPKGVER}_amd64.deb

ZFS_DBG_DEBS = $(patsubst %_${ZFSPKGVER}_amd64.deb, %-dbgsym_${ZFSPKGVER}_amd64.deb, ${ZFS_DEB1} ${ZFS_DEB_BINARY})

ZFS_DEB2= ${ZFS_DEB_BINARY}			\
libzfslinux-dev_${ZFSPKGVER}_amd64.deb		\
python3-pyzfs_${ZFSPKGVER}_amd64.deb		\
pyzfs-doc_${ZFSPKGVER}_all.deb			\
spl_${ZFSPKGVER}_all.deb			\
zfs-initramfs_${ZFSPKGVER}_all.deb
ZFS_DEBS= ${ZFS_DEB1} ${ZFS_DEB2} ${ZFS_DBG_DEBS}

ZFS_DSC = zfs-linux_${ZFSPKGVER}.dsc

all: deb
.PHONY: deb
deb: ${ZFS_DEBS}
.PHONY: dsc
dsc: ${ZFS_DSC}

# called from pve-kernel's Makefile to get patched sources
.PHONY: kernel
kernel: dsc
	dpkg-source -x ${ZFS_DSC} ../pkg-zfs
	${MAKE} -C ../pkg-zfs -f debian/rules adapt_meta_file

.PHONY: dinstall
dinstall: ${DEBS}
	dpkg -i ${DEBS}

.PHONY: submodule
submodule:
	test -f "${ZFSSRC}/README.md" || git submodule update --init
${ZFSSRC}/README.md: submodule

.PHONY: zfs
zfs: ${ZFS_DEBS}
${ZFS_DEB2}: ${ZFS_DEB1}
${ZFS_DEB1}: ${ZFSDIR}
	cd ${ZFSDIR}; dpkg-buildpackage -b -uc -us
	lintian ${ZFS_DEBS}

${ZFS_DSC}: ${ZFSDIR}
	tar czf zfs-linux_${ZFSVER}.orig.tar.gz ${ZFSDIR}
	cd ${ZFSDIR}; dpkg-buildpackage -S -uc -us -d
	lintian $@

${ZFSDIR}: ${ZFSSRC}/README.md ${ZFSSRC} ${ZFSPKG}
	rm -rf ${ZFSDIR} ${ZFSDIR}.tmp
	cp -a ${ZFSSRC} ${ZFSDIR}.tmp
	cp -a ${ZFSPKG} ${ZFSDIR}.tmp/debian
	mv ${ZFSDIR}.tmp ${ZFSDIR}


.PHONY: clean
clean: 	
	rm -rf *~ *.deb *.changes *.buildinfo *.dsc *.orig.tar.* *.debian.tar.* ${ZFSDIR}

.PHONY: distclean
distclean: clean

.PHONY: upload
upload: ${DEBS}
	tar -cf - ${DEBS} | ssh repoman@repo.proxmox.com -- upload --product pve,pmg,pbs --dist bullseye --arch amd64
