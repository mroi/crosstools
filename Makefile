HOST    := $(shell cc -dumpmachine)
TARGETS ?= i386-linux-gnu x86_64-linux-gnu i386-pc-mingw32

ifeq ($(SANDBOX),)

SANDBOX_PROFILE = \
	(version 1)(deny default)(debug deny) \
	(import "system.sb") \
	(allow file-read-metadata)(allow file-write-data (literal "/dev/tty")) \
	(allow file-read* (require-all (file-mode \#o0004)(require-not (subpath "$$HOME")))) \
	(allow file* (subpath "/private/tmp")(subpath "/private/var/tmp")(subpath "/private/var/folders")) \
	(allow file* (subpath "$(PWD)")) \
	(allow file-read* $(shell path=$(PWD) ; while test "$$path" ; do echo "(literal \"$$path\")" ; path="$${path%/*}" ; done)) \
	(deny process-exec (literal "/usr/bin/xcodebuild")) \
	(allow process-fork)(allow process-exec)

all %:
	@sandbox-exec -p '$(SANDBOX_PROFILE)' $(MAKE) SANDBOX=yes $@

else

all: binutils libc gcc

clean:
	rm -rf bin include lib libexec share $(TARGETS) src/*-build

purge:
	rm -rf src

gcc: binutils libc gmp mpfr mpc
mpfr: gmp
mpc: mpfr gmp

binutils: $(foreach arch,$(TARGETS),src/binutils-build/$(arch))
libc: $(foreach arch,$(TARGETS),src/libc-build/$(arch))
gmp: src/gmp-build/$(HOST)
mpfr: src/mpfr-build/$(HOST)
mpc: src/mpc-build/$(HOST)
gcc: $(foreach arch,$(TARGETS),src/gcc-build/$(arch))

src/binutils-build/%: $(or $(wildcard src/binutils-[0-9]*),src/binutils-<latest>)
	mkdir -p $@ && cd $@ && \
	../../../$</configure \
		--prefix=$(PWD) \
		--target=$(@F) \
		--disable-multilib && \
	$(MAKE) all install

src/libc-build/i386-linux-gnu: $(foreach pkg,linux-libc-dev libc6 libc6-dev,$(or $(wildcard src/$(pkg)_*_i386.deb),src/$(pkg)_<latest>_i386.deb))
src/libc-build/x86_64-linux-gnu: $(foreach pkg,linux-libc-dev libc6 libc6-dev,$(or $(wildcard src/$(pkg)_*_amd64.deb),src/$(pkg)_<latest>_amd64.deb))
src/libc-build/%-linux-gnu:
	mkdir -p $@ && $(foreach pkg,$^,dpkg-deb -x $(pkg) $@ &&) touch $@ || rmdir -p $@
	mkdir -p $(@F)/include && mv -n $@/usr/include/$(@F)/* $@/usr/include/* $(@F)/include/ && rmdir $(@F)/include/$(@F)
	mkdir -p $(@F)/lib && mv -n $@/lib/$(@F)/* $@/usr/lib/$(@F)/*.[oa] $(@F)/lib/
	for lib in $@/usr/lib/$(@F)/*.so ; do \
		test -f $$lib && \
			sed 's|/usr/|/|g;s|/$(@F)/|/|g;s| /| $(PWD)/$(@F)/|g' $$lib > $(@F)/lib/$$(basename $$lib) ; \
		test -L $$lib && \
			ln -s $$(basename $$(readlink $$lib)) $(@F)/lib/$$(basename $$lib) ; \
	done
	case $(@F) in (x86_64-*) mv -n $(@F)/lib $(@F)/lib64 ; ln -s lib64 $(@F)/lib ;; esac

src/libc-build/i386-pc-mingw32: $(foreach pkg,mingwrt w32api,$(or $(wildcard src/$(pkg)-*),src/$(pkg)-<latest>))
	mkdir -p $(@F)/include && cp -R $(addsuffix /include/*,$^) $(@F)/include/
	mkdir -p $(@F)/lib && cp -R $(addsuffix /lib/*,$^) $(@F)/lib/
	touch $@

src/gmp-build/%: $(or $(wildcard src/gmp-[0-9]*),src/gmp-<latest>)
	mkdir -p $@ && cd $@ && \
	../../../$</configure \
		--prefix=$(PWD) \
		--host=$(@F) && \
	$(MAKE) all check install

src/mpfr-build/%: $(or $(wildcard src/mpfr-[0-9]*),src/mpfr-<latest>)
	mkdir -p $@ && cd $@ && \
	../../../$</configure \
		--prefix=$(PWD) \
		--host=$(@F) \
		--with-gmp=$(PWD) && \
	$(MAKE) all check install

src/mpc-build/%: $(or $(wildcard src/mpc-[0-9]*),src/mpc-<latest>)
	mkdir -p $@ && cd $@ && \
	../../../$</configure \
		--prefix=$(PWD) \
		--host=$(@F) \
		--with-gmp=$(PWD) \
		--with-mpfr=$(PWD) && \
	$(MAKE) all check install

src/gcc-build/%: $(or $(wildcard src/gcc-[0-9]*),src/gcc-<latest>)
	mkdir -p $@ && cd $@ && \
	../../../$</configure \
		--prefix=$(PWD) \
		--target=$(@F) \
		--enable-languages="c,c++,objc,obj-c++" \
		--with-gmp=$(PWD) \
		--with-mpfr=$(PWD) \
		--with-mpc=$(PWD) \
		--disable-multilib \
		--disable-libquadmath \
		--disable-libsanitizer && \
	PATH=$(PATH):$(PWD)/bin $(MAKE) all install

src/%.deb:
	@echo 'download $(@F) and place it in $(@D)/'
	@false

src/%-<latest>:
	@echo 'download $(@F) and unpack it under $(@D)/'
	@false

endif
