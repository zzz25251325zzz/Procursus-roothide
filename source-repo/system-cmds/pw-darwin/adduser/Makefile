DESTDIR         ?=
MEMO_PREFIX     ?=
MEMO_SUB_PREFIX ?= /usr

all: adduser rmuser

adduser: adduser.sh
	sed -e 's|@MEMO_PREFIX@|$(MEMO_PREFIX)|g' \
		-e 's|@MEMO_SUB_PREFIX@|$(MEMO_SUB_PREFIX)|g' \
		$< > $@

rmuser: rmuser.sh
	sed -e 's|@MEMO_PREFIX@|$(MEMO_PREFIX)|g' \
		-e 's|@MEMO_SUB_PREFIX@|$(MEMO_SUB_PREFIX)|g' \
		$< > $@

clean:
	rm -f adduser rmuser

install: install-adduser install-rmuser

install-adduser: adduser adduser.8 adduser.conf.5
	install -d $(DESTDIR)/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/sbin \
		$(DESTDIR)/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/share/man/man5 \
		$(DESTDIR)/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/share/man/man8
	install -m755 adduser $(DESTDIR)/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/sbin/adduser
	install -m644 adduser.8 $(DESTDIR)/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/share/man/man8/adduser.8
	install -m644 adduser.conf.5 $(DESTDIR)/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/share/man/man5/adduser.conf.5

install-rmuser: rmuser rmuser.8
	install -d $(DESTDIR)/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/sbin \
		$(DESTDIR)/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/share/man/man8
	install -m755 rmuser $(DESTDIR)/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/sbin/rmuser
	install -m644 rmuser.8 $(DESTDIR)/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/share/man/man8/rmuser.8

.PHONY: all install install-adduser install-rmuser clean
