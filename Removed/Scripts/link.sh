#!/bin/sh

set -xe
find . -type f -not -name "link.sh" -executable -exec sh -c '
  ln -s "$(readlink -f "$0")" /usr/local/bin/
' {} \;
