ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

ifeq (,$(findstring darwin,$(MEMO_TARGET)))
STRAPPROJECTS += roothide
ROOTHIDE_VERSION  := 0.0.1
DEB_ROOTHIDE_V    ?= $(ROOTHIDE_VERSION)

roothide-setup: setup
	$(call GITHUB_ARCHIVE,RootHide,libroothide,$(ROOTHIDE_VERSION),$(ROOTHIDE_VERSION))
	$(call EXTRACT_TAR,libroothide-$(ROOTHIDE_VERSION).tar.gz,libroothide-$(ROOTHIDE_VERSION),libroothide)

ifneq ($(wildcard $(BUILD_WORK)/roothide/.build_complete),)
roothide:
	@echo "Using previously built roothide."
else
roothide: roothide-setup base
	mkdir -p $(BUILD_STAGE)/$(MEMO_PREFIX)/roothide/{var/mobile,etc,$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/{bin,sbin,lib,libexec}}

	$(LN_S) $(MEMO_ROOTFS)/ $(BUILD_STAGE)/roothide/$(MEMO_PREFIX)/rootfs
	$(LN_S) $(MEMO_ROOTFS)/dev $(BUILD_STAGE)/roothide/$(MEMO_PREFIX)/dev

	mkdir $(BUILD_STAGE)/roothide/$(MEMO_PREFIX)/private
	$(LN_S) $(MEMO_ROOTFS)/private/preboot $(BUILD_STAGE)/roothide/$(MEMO_PREFIX)/private/preboot
	$(LN_S) ../var $(BUILD_STAGE)/roothide/$(MEMO_PREFIX)/private/var
	$(LN_S) ../tmp $(BUILD_STAGE)/roothide/$(MEMO_PREFIX)/var/tmp

	$(LN_S) $(MEMO_ROOTFS)/private/var/containers $(BUILD_STAGE)/roothide/$(MEMO_PREFIX)/var/containers
	$(LN_S) $(MEMO_ROOTFS)/private/var/mobile/Containers $(BUILD_STAGE)/roothide/$(MEMO_PREFIX)/var/mobile/Containers

	$(LN_S) $(MEMO_ROOTFS)/etc/hosts $(BUILD_STAGE)/roothide/$(MEMO_PREFIX)/etc/hosts
	$(LN_S) $(MEMO_ROOTFS)/etc/hosts.equiv $(BUILD_STAGE)/roothide/$(MEMO_PREFIX)/etc/hosts.equiv

	mkdir -p $(BUILD_STAGE)/roothide/$(MEMO_PREFIX)/usr/share/misc
	$(LN_S) $(MEMO_ROOTFS)/usr/share/misc/trace.codes $(BUILD_STAGE)/roothide/$(MEMO_PREFIX)/usr/share/misc/trace.codes
	$(LN_S) $(MEMO_ROOTFS)/usr/share/zoneinfo $(BUILD_STAGE)/roothide/$(MEMO_PREFIX)/usr/share/zoneinfo

	mkdir -p $(BUILD_STAGE)/roothide/$(MEMO_PREFIX)/var/db
	$(LN_S) $(MEMO_ROOTFS)/var/db/timezone $(BUILD_STAGE)/roothide/$(MEMO_PREFIX)/var/db/timezone

	mkdir -p $(BUILD_STAGE)/roothide/$(MEMO_PREFIX)/var/run
	$(LN_S) $(MEMO_ROOTFS)/var/run/utmpx $(BUILD_STAGE)/roothide/$(MEMO_PREFIX)/var/run/utmpx

	mkdir -p $(BUILD_STAGE)/roothide/$(MEMO_PREFIX)/bin
	$(LN_S) $(MEMO_ROOTFS)/bin/df $(BUILD_STAGE)/roothide/$(MEMO_PREFIX)/bin/df
	mkdir -p $(BUILD_STAGE)/roothide/$(MEMO_PREFIX)/sbin
	$(LN_S) $(MEMO_ROOTFS)/sbin/mount $(BUILD_STAGE)/roothide/$(MEMO_PREFIX)/sbin/mount

	mkdir -p $(BUILD_STAGE)/roothide/$(MEMO_PREFIX)/System/Library/CoreServices/
	$(LN_S) $(MEMO_ROOTFS)/System/Library/CoreServices/SystemVersion.plist $(BUILD_STAGE)/roothide/$(MEMO_PREFIX)/System/Library/CoreServices/SystemVersion.plist

	sed -e 's|@MEMO_PREFIX@|$(MEMO_PREFIX)|g' -e 's|@MEMO_SUB_PREFIX@|$(MEMO_SUB_PREFIX)|g' $(BUILD_MISC)/updatelinks.sh > $(BUILD_STAGE)/roothide/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/libexec/updatelinks.sh
	chmod +x $(BUILD_STAGE)/roothide/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/libexec/updatelinks.sh

	
	$(MAKE) -C $(BUILD_WORK)/libroothide clean
	CFLAGS="$(CFLAGS) -DLIBIOSEXEC_INTERNAL" $(MAKE) -C $(BUILD_WORK)/libroothide all

	cp -a $(BUILD_WORK)/libroothide/libroothide.dylib	$(BUILD_STAGE)/roothide/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/
	cp -a $(BUILD_WORK)/libroothide/libvroot.dylib	$(BUILD_STAGE)/roothide/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/
	cp -a $(BUILD_WORK)/libroothide/libvrootapi.dylib	$(BUILD_STAGE)/roothide/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/
	cp -a $(BUILD_WORK)/libroothide/updatelink	$(BUILD_STAGE)/roothide/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/libexec/
	cp -a $(BUILD_WORK)/libroothide/jbrand	$(BUILD_STAGE)/roothide/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/
	cp -a $(BUILD_WORK)/libroothide/jbroot	$(BUILD_STAGE)/roothide/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/
	cp -a $(BUILD_WORK)/libroothide/rootfs	$(BUILD_STAGE)/roothide/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/

	$(call AFTER_BUILD,,,,NO-VROOT)
endif

roothide-package: roothide-stage
	# roothide.mk Package Structure
	rm -rf $(BUILD_DIST)/roothide

	# roothide.mk Prep roothide
	cp -a $(BUILD_STAGE)/roothide $(BUILD_DIST)

	$(FAKEROOT) chown -R 0:0 $(BUILD_DIST)/roothide
	$(FAKEROOT) chown -R 501:501 $(BUILD_DIST)/roothide/$(MEMO_PREFIX)/var/mobile

	# roothide.mk Sign
	$(call SIGN,roothide,general.xml)
	
	# roothide.mk Make .debs
	$(call PACK,roothide,DEB_ROOTHIDE_V,2)

	# roothide.mk Build cleanup
	rm -rf $(BUILD_DIST)/roothide

.PHONY: roothide roothide-package

endif # ($(MEMO_TARGET),darwin-\*)
