RELEASE=4.0

# source form https://github.com/zfsonlinux/

ZFSVER=0.6.3-1.2
ZFSPKGREL=pve2~jessie
SPLPKGREL=pve1~jessie
ZFSPKGVER=0.6.3-${ZFSPKGREL}
SPLPKGVER=0.6.3-${SPLPKGREL}

SPLDIR=spl-spl-${ZFSVER}
SPLSRC=spl-${ZFSVER}.tar.gz
ZFSDIR=zfs-zfs-${ZFSVER}
ZFSSRC=zfs-${ZFSVER}.tar.gz

SPL_DEBS= 			\
spl_${SPLPKGVER}_amd64.deb

ZFS_DEBS= 				\
libnvpair1_${ZFSPKGVER}_amd64.deb 		\
libuutil1_${ZFSPKGVER}_amd64.deb		\
libzfs2_${ZFSPKGVER}_amd64.deb		\
libzfs-dev_${ZFSPKGVER}_amd64.deb		\
libzpool2_${ZFSPKGVER}_amd64.deb		\
zfs-doc_${ZFSPKGVER}_amd64.deb		\
zfs-initramfs_${ZFSPKGVER}_amd64.deb	\
zfsutils_${ZFSPKGVER}_amd64.deb

DEBS=${SPL_DEBS} ${ZFS_DEBS} 

all: ${DEBS}

.PHONY: dinstall
dinstall: ${DEBS}
	dpkg -i ${DEBS}

.PHONY: spl
spl ${SPL_DEBS}: ${SPLSRC}
	rm -rf ${SPLDIR}
	tar xf ${SPLSRC}
	cp -a spl-debian-pve ${SPLDIR}/debian
	cd ${SPLDIR}; dpkg-buildpackage -b -uc -us 

.PHONY: zfs
zfs ${ZFS_DEBS}: ${ZFSSRC}
	rm -rf ${ZFSDIR}
	tar xf ${ZFSSRC}
	cp -a zfs-debian-pve ${ZFSDIR}/debian
	cd ${ZFSDIR}; dpkg-buildpackage -b -uc -us 

.PHONY: download
download:
	#git clone https://github.com/zfsonlinux/pkg-spl.git
	#git clone https://github.com/zfsonlinux/pkg-zfs.git
	##git checkout master/ubuntu/precise
	##git checkout master/debian/wheezy
	rm spl-*.tar.gz
	rm zfs-*.tar.gz
	wget https://github.com/zfsonlinux/spl/archive/${SPLSRC}
	wget https://github.com/zfsonlinux/zfs/archive/${ZFSSRC}

.PHONY: clean
clean: 	
	rm -rf *~ *.deb *.changes ${ZFSDIR} ${SPLDIR}

.PHONY: distclean
distclean: clean


.PHONY: upload
upload: ${DEBS}
	umount /pve/${RELEASE}; mount /pve/${RELEASE} -o rw 
	mkdir -p /pve/${RELEASE}/extra
	rm -f /pve/${RELEASE}/extra/spl_*.deb
	rm -f /pve/${RELEASE}/extra/spl-dkms_*.deb
	rm -f /pve/${RELEASE}/extra/libnvpair1_*.deb
	rm -f /pve/${RELEASE}/extra/libnvpair1-dbg_*.deb
	rm -f /pve/${RELEASE}/extra/libuutil1_*.deb
	rm -f /pve/${RELEASE}/extra/libuutil1-dbg_*.deb
	rm -f /pve/${RELEASE}/extra/libzfs2_*.deb
	rm -f /pve/${RELEASE}/extra/libzfs2-dbg_*.deb
	rm -f /pve/${RELEASE}/extra/libzfs-dev_*.deb
	rm -f /pve/${RELEASE}/extra/libzpool2_*.deb
	rm -f /pve/${RELEASE}/extra/libzpool2-dbg_*.deb
	rm -f /pve/${RELEASE}/extra/zfs_*.deb
	rm -f /pve/${RELEASE}/extra/zfs-dkms_*.deb
	rm -f /pve/${RELEASE}/extra/zfs-doc_*.deb
	rm -f /pve/${RELEASE}/extra/zfs-initramfs_*.deb
	rm -f /pve/${RELEASE}/extra/zfsutils_*.deb
	rm -f /pve/${RELEASE}/extra/zfsutils-dbg_*.deb
	rm -f /pve/${RELEASE}/extra/Packages*
	cp ${DEBS} /pve/${RELEASE}/extra
	cd /pve/${RELEASE}/extra; dpkg-scanpackages . /dev/null > Packages; gzip -9c Packages > Packages.gz
	umount /pve/${RELEASE}; mount /pve/${RELEASE} -o ro

