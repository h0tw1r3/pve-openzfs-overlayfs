RELEASE=3.3

# source form https://github.com/zfsonlinux/

ZFSVER=0.6.3-1.2
PKGREL=1~wheezy
PKGVER=0.6.3-${PKGREL}

SPLDIR=spl-spl-${ZFSVER}
SPLSRC=spl-${ZFSVER}.tar.gz
ZFSDIR=zfs-zfs-${ZFSVER}
ZFSSRC=zfs-${ZFSVER}.tar.gz


#TOP=$(shell pwd)
#KERNEL_3.10.0_HDR=/usr/src/linux-headers-3.10.0-6-pve/
#KERNEL_2.6.32_HDR=/usr/src/linux-headers-2.6.32-35-pve/
#KERNEL_3.10.0_SRC=${TOP}/../pve-kernel-3.10.0/linux-2.6-3.10.0/
#KERNEL_2.6.32_SRC=${TOP}/../pve-kernel-2.6.32/linux-2.6-2.6.32

SPL_DEBS= 			\
spl_${PKGVER}_amd64.deb  		\
spl-dkms_${PKGVER}_all.deb

#SPL_2.6.32_DEBS= \
#${SPLDIR}_2.6.32/kmod-spl-devel_0.6.3-1.2_amd64.deb \
#${SPLDIR}_2.6.32/kmod-spl-2.6.32-35-pve_0.6.3-1.2_amd64.deb \
#${SPLDIR}_2.6.32/kmod-spl-devel-2.6.32-35-pve_0.6.3-1.2_amd64.deb

#SPL_3.10.0_DEBS= \
#${SPLDIR}_3.10.0/kmod-spl-3.10.0-6-pve_0.6.3-1.2_amd64.deb \
#${SPLDIR}_3.10.0/kmod-spl-devel-3.10.0-6-pve_0.6.3-1.2_amd64.deb 

ZFS_DEBS= 			\
libnvpair1_${PKGVER}_amd64.deb 	\
libuutil1_${PKGVER}_amd64.deb	\
libzfs2_${PKGVER}_amd64.deb	\
libzfs-dev_${PKGVER}_amd64.deb	\
libzpool2_${PKGVER}_amd64.deb	\
zfs-dkms_${PKGVER}_amd64.deb	\
zfs-doc_${PKGVER}_amd64.deb	\
zfs-initramfs_${PKGVER}_amd64.deb	\
zfsutils_${PKGVER}_amd64.deb

#ZFS_2.6.32_DEBS= \
#${ZFSDIR}_2.6.32/kmod-zfs-2.6.32-35-pve_0.6.3-1.2_amd64.deb \
#${ZFSDIR}_2.6.32/kmod-zfs-devel_0.6.3-1.2_amd64.deb \
#${ZFSDIR}_2.6.32/kmod-zfs-devel-2.6.32-35-pve_0.6.3-1.2_amd64.deb

#ZFS_3.10.0_DEBS= \
#${ZFSDIR}_3.10.0/kmod-zfs-3.10.0-6-pve_0.6.3-1.2_amd64.deb \
#${ZFSDIR}_3.10.0/kmod-zfs-devel-3.10.0-6-pve_0.6.3-1.2_amd64.deb

DEBS=${SPL_DEBS} ${ZFS_DEBS} 

all: ${DEBS}

.PHONY: dinstall
dinstall: ${DEBS}
	dpkg -i ${DEBS}

.PHONY: spl_utils
spl_utils ${SPL_DEBS}: ${SPLSRC}
	rm -rf ${SPLDIR}
	tar xf ${SPLSRC}
	cp -a spl-debian-pve ${SPLDIR}/debian
	cd ${SPLDIR}; dpkg-buildpackage -b -uc -us 

#.PHONY: spl_kmod_2.6.32
#spl_kmod_2.6.32 ${SPL_2.6.32_DEBS}: ${SPLSRC}
#	rm -rf ${SPLDIR}
#	tar xf ${SPLSRC}
#	mv ${SPLDIR} ${SPLDIR}_2.6.32
#	cd ${SPLDIR}_2.6.32; ./autogen.sh
#	cd ${SPLDIR}_2.6.32; ./configure --with-linux=${KERNEL_2.6.32_HDR} --with-linux-obj=${KERNEL_2.6.32_SRC}
#	cd ${SPLDIR}_2.6.32; make deb-kmod 

.PHONY: zfs_utils
zfs_utils ${ZFS_DEBS}: ${ZFSSRC}
	rm -rf ${ZFSDIR}
	tar xf ${ZFSSRC}
	cp -a zfs-debian-pve ${ZFSDIR}/debian
	cd ${ZFSDIR}; dpkg-buildpackage -b -uc -us 

## Note: install mod-spl-devel-* first
#.PHONY: zfs_kmod_2.6.32
#zfs_kmod_2.6.32 ${ZFS_2.6.32_DEBS}: ${ZFSSRC}
#	rm -rf ${ZFSDIR} ${ZFSDIR}_2.6.32
#	tar xf ${ZFSSRC}
#	mv ${ZFSDIR} ${ZFSDIR}_2.6.32
#	cd ${ZFSDIR}_2.6.32; ./autogen.sh
#	cd ${ZFSDIR}_2.6.32; ./configure --with-linux=${KERNEL_2.6.32_HDR} --with-linux-obj=${KERNEL_2.6.32_SRC}
#	cd ${ZFSDIR}_2.6.32; make deb-kmod

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
	rm -f /pve/${RELEASE}/extra/kmod-spl-*.deb
	rm -f /pve/${RELEASE}/extra/libnvpair1_*.deb
	rm -f /pve/${RELEASE}/extra/libuutil1_*.deb
	rm -f /pve/${RELEASE}/extra/libzfs2_*.deb
	rm -f /pve/${RELEASE}/extra/libzfs2-dbg_*.deb
	rm -f /pve/${RELEASE}/extra/libzpool2_*.deb
	rm -f /pve/${RELEASE}/extra/zfs_*.deb
	rm -f /pve/${RELEASE}/extra/Packages*
	cp ${DEBS} /pve/${RELEASE}/extra
	cd /pve/${RELEASE}/extra; dpkg-scanpackages . /dev/null > Packages; gzip -9c Packages > Packages.gz
	umount /pve/${RELEASE}; mount /pve/${RELEASE} -o ro

