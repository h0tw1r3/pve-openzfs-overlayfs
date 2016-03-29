RELEASE=4.1

# source form https://github.com/zfsonlinux/

ZFSVER=0.6.5
ZFSPKGREL=pve7~jessie
SPLPKGREL=pve3~jessie
ZFSPKGVER=${ZFSVER}-${ZFSPKGREL}
SPLPKGVER=${ZFSVER}-${SPLPKGREL}

SPLDIR=pkg-spl
SPLSRC=pkg-spl.tar.gz
ZFSDIR=pkg-zfs
ZFSSRC=pkg-zfs.tar.gz

SPL_DEBS= 					\
spl_${SPLPKGVER}_amd64.deb

ZFS_DEBS= 					\
libnvpair1_${ZFSPKGVER}_amd64.deb 		\
libuutil1_${ZFSPKGVER}_amd64.deb		\
libzfs2_${ZFSPKGVER}_amd64.deb			\
libzfs-dev_${ZFSPKGVER}_amd64.deb		\
libzpool2_${ZFSPKGVER}_amd64.deb		\
zfs-dbg_${ZFSPKGVER}_amd64.deb			\
zfs-initramfs_${ZFSPKGVER}_amd64.deb		\
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
	mv ${SPLDIR}/debian/changelog ${SPLDIR}/debian/changelog.org
	cat spl-changelog.Debian ${SPLDIR}/debian/changelog.org > ${SPLDIR}/debian/changelog
	cd ${SPLDIR}; ln -s ../spl-patches patches
	cd ${SPLDIR}; quilt push -a
	cd ${SPLDIR}; rm -rf .pc ./patches
	cd ${SPLDIR}; ./debian/rules override_dh_prep-base-deb-files
	cd ${SPLDIR}; dpkg-buildpackage -b -uc -us 

.PHONY: zfs
zfs ${ZFS_DEBS}: ${ZFSSRC}
	rm -rf ${ZFSDIR}
	tar xf ${ZFSSRC}
	mv ${ZFSDIR}/debian/changelog ${ZFSDIR}/debian/changelog.org
	cat zfs-changelog.Debian ${ZFSDIR}/debian/changelog.org > ${ZFSDIR}/debian/changelog
	cd ${ZFSDIR}; ln -s ../zfs-patches patches
	cd ${ZFSDIR}; quilt push -a
	cd ${ZFSDIR}; rm -rf .pc ./patches
	cd ${ZFSDIR}; ./debian/rules override_dh_prep-base-deb-files
	cd ${ZFSDIR}; dpkg-buildpackage -b -uc -us 

.PHONY: download
download:
	rm -rf pkg-spl pkg-zfs ${SPLSRC} ${ZFSSRC}
	git clone https://github.com/zfsonlinux/pkg-spl.git
	# list tags with:  git tag --list 'master/*'
	cd pkg-spl; git fetch https://github.com/zfsonlinux/spl.git spl-0.6.5-release
	cd pkg-spl; git checkout master/debian/jessie/0.6.5-1
	# manual merge spl-0.6.5.6
	cd pkg-spl; git merge --no-edit spl-0.6.5.6
	git clone https://github.com/zfsonlinux/pkg-zfs.git
	cd pkg-zfs; git fetch https://github.com/zfsonlinux/zfs.git zfs-0.6.5-release
	cd pkg-zfs; git checkout master/debian/jessie/0.6.5.2-2
	# manual cherry-pick relevant 0.6.5.3 updates
	cd pkg-zfs; git cherry-pick cd887ab869bb506c88a66ba8c225ca42680b89d f9f5394f74f7bf421eb484e8d1653257d92f5ace 9aaf60b66d10cb01c3c1fc67fa094b17a83b002a
	# manual cherry-pick relevant 0.6.5.4 updates
	cd pkg-zfs; git cherry-pick e909a45d22be9645f8bca27bfc4db6912648e1be^..1ffc4c150e10310b319ab8a7d83f1f98f9a1e651
	# manual cherry-pick relevant 0.6.5.5 updates
	cd pkg-zfs; git cherry-pick a5dae61721fac617d37ac8585a9ed5fe5aa20d1d^..504ff597092ec6160675685db938dbd21043b690
	# manual cherry-pick relevant 0.6.5.6 updates
	cd pkg-zfs; git cherry-pick 63ce7b6fcfc417fc58cbfaca641d54d66eeaccab^..21f21fe85989004e60d316fca9bb4eb4cde10eb7
	tar czf ${SPLSRC} pkg-spl
	tar czf ${ZFSSRC} pkg-zfs

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
	rm -f /pve/${RELEASE}/extra/zfs-dbg_*.deb
	rm -f /pve/${RELEASE}/extra/zfs-initramfs_*.deb
	rm -f /pve/${RELEASE}/extra/zfsutils_*.deb
	rm -f /pve/${RELEASE}/extra/zfsutils-dbg_*.deb
	rm -f /pve/${RELEASE}/extra/Packages*
	cp ${DEBS} /pve/${RELEASE}/extra
	cd /pve/${RELEASE}/extra; dpkg-scanpackages . /dev/null > Packages; gzip -9c Packages > Packages.gz
	umount /pve/${RELEASE}; mount /pve/${RELEASE} -o ro

