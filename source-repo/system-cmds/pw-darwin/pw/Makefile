CC              ?= aarch64-apple-darwin-clang
STRIP           ?= aarch64-apple-darwin-strip
LDID            ?= ldid
CFLAGS          ?= -arch arm64  -isysroot /home/cameron/Documents/SDK/iPhoneOS14.3.sdk -miphoneos-version-min=13.0
LDFLAGS         ?=
MEMO_PREFIX     ?=
MEMO_SUB_PREFIX ?= /usr
DESTDIR         ?=

SRC := pw_utils.c \
	pw_user.c \
	pw_conf.c \
	bitmap.c \
	psdate.c \
	pw_nis.c \
	pw.c \
	grupd.c \
	pwupd.c \
	pw_group.c \
	rm_r.c \
	pw_log.c \
	strtounum.c \
	pw_vpw.c \
	cpdir.c

LIBUTILSRC := ../libutil/login_cap.c \
	../libutil/pw_util.c \
	../libutil/gr_util.c \
	../libutil/flopen.c \
	../libutil/login_crypt.c \
	../libutil/_secure_path.c

LIBCSRC := ../libc/stdlib/strtonum.c \
	../libc/gen/pw_scan.c

all: pw

install: install-pw

pw: $(SRC:%.c=%.o) $(LIBCSRC:%.c=%.o) $(LIBUTILSRC:%.c=%.o) ../ent.xml
	$(CC) $(LDFLAGS) -o $@ -lcrypt $(SRC:%.c=%.o) $(LIBCSRC:%.c=%.o) $(LIBUTILSRC:%.c=%.o)
	$(STRIP) $@
	$(LDID) -S../ent.xml $@

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $< -I. -I../libutil -I../libc/gen

install-pw: pw pw.8 pw.conf.5
	install -d $(DESTDIR)/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/share/skel \
		$(DESTDIR)/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/sbin \
		$(DESTDIR)/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/share/man/man5 \
		$(DESTDIR)/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/share/man/man8
	install -m755 pw $(DESTDIR)/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/sbin/pw
	install -m644 pw.8 $(DESTDIR)/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/share/man/man8/pw.8
	install -m644 pw.conf.5 $(DESTDIR)/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/share/man/man5/pw.conf.5

clean:
	rm -f pw $(SRC:%.c=%.o) $(LIBCSRC:%.c=%.o) $(LIBUTILSRC:%.c=%.o)

.PHONY: all install install-pw clean
