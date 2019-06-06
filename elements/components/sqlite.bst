kind: autotools

depends:
- filename: bootstrap-import.bst

variables:
  conf-local: |
    --enable-fts5 \
    CFLAGS="${CFLAGS} \
    -DSQLITE_ENABLE_COLUMN_METADATA=1 \
    -DSQLITE_SECURE_DELETE=1 \
    -DSQLITE_ENABLE_FTS3=1 \
    -DSQLITE_ENABLE_UNLOCK_NOTIFY=1 \
    -DSQLITE_ENABLE_DBSTAT_VTAB=1"

public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{libdir}/libsqlite3.so'

  cpe:
    vendor: 'sqlite'
    version: '3.28.0'

sources:
- kind: tar
  url: https://sqlite.org/2019/sqlite-autoconf-3280000.tar.gz
  ref: d61b5286f062adfce5125eaf544d495300656908e61fca143517afcc0a89b7c3