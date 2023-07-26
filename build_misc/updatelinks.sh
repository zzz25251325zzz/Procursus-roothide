#!@MEMO_PREFIX@/bin/sh

@MEMO_PREFIX@@MEMO_SUB_PREFIX@/bin/find @MEMO_PREFIX@/ -xdev -type l | @MEMO_PREFIX@@MEMO_SUB_PREFIX@/libexec/updatelink >/dev/null 2>&1
