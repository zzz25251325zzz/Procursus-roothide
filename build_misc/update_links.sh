#!@MEMO_PREFIX@/bin/sh

@MEMO_PREFIX@@MEMO_SUB_PREFIX@/bin/find @MEMO_PREFIX@/ -type l | @MEMO_PREFIX@@MEMO_SUB_PREFIX@/sbin/updatelink >/dev/null 2>&1
