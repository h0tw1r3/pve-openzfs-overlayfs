RELEASE=5.1

# source form https://github.com/zfsonlinux/

ZFSDIR=zfs-linux_${ZFSVER}
ZFSSRC=zfs/upstream
ZFSPKG=zfs/debian

ZFSVER != dpkg-parsechangelog -l ${ZFSPKG}/changelog -Sversion | cut -d- -f1

ZFSPKGVER != dpkg-parsechangelog -l ${ZFSPKG}/changelog -Sversion

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

all: deb
.PHONY: deb
deb: ${ZFS_DEBS}
.PHONY: dsc
dsc: ${ZFS_DSC}

# called from pve-kernel's Makefile to get patched sources
.PHONY: kernel
kernel: dsc
	dpkg-source -x ${ZFS_DSC} ../pkg-zfs
	$(MAKE) -C ../pkg-zfs -f debian/rules adapt_meta_file

.PHONY: dinstall
dinstall: ${DEBS}
	dpkg -i ${DEBS}

.PHONY: submodule
submodule:
	test -f "${ZFSSRC}/README.markdown" || git submodule update --init

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
	rm -rf *~ *.deb *.changes *.buildinfo *.dsc *.orig.tar.* *.debian.tar.* ${ZFSDIR}

.PHONY: distclean
distclean: clean

.PHONY: upload
upload: ${DEBS}
	tar -cf - ${DEBS} | ssh repoman@repo.proxmox.com -- upload --product pve,pmg --dist buster --arch amd64
