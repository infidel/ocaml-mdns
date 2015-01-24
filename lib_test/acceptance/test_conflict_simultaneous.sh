#!/bin/bash
set -eu

. config.sh
. common.sh
need_root

test_name=test_conflict_simultaneous

flush_cache
create_unikernel 0 name-conflict.local
create_unikernel 1 name-conflict.local

start_capture ${test_name}
start_unikernel 0 1
echo "Delaying for probe with conflict..."
sleep 10
stop_capture ${test_name}

# NOTE: opposite order to test_conflict_later!
verify_hostname name-conflict2.local ${mirage_ipaddr_array[0]}
verify_hostname name-conflict.local ${mirage_ipaddr_array[1]}

stop_unikernel 0
stop_unikernel 1

dump_capture ${test_name}
./verify_conflict_simultaneous.py ${mirage_ipaddr_array[0]} ${mirage_ipaddr_array[1]} < $capture_txt > $tmp_here/${test_name}.canon.txt
diff -u expected_conflict_simultaneous.txt $tmp_here/${test_name}.canon.txt && echo "No differences"
