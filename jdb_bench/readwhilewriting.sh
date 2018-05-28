#!/usr/bin/env bash

echo "Reading $r keys while writing $wps keys per sec in database in random order...."

bpl=10485760;
mcz=0;
del=0;
levels=7;
ctrig=4;
delay=8;
stop=12;
wbn=2;
mbc=4;
mb=2097152;
wbs=4194304;
sync=false;
bs=4096;
si=1000000;

time $jdb_bench \
  --benchmarks=readwhilewriting \
  --mmap_read=false \
  --statistics=true \
  --histogram=true \
  --reads=$r \
  --writes=$r \
  --threads=$t \
  --num=$num \
  --value_size=$ks \
  --value_size=$vs \
  --block_size=$bs \
  --cache_size=$cs \
  --bloom_bits=-1 \
  --cache_numshardbits=4 \
  --open_files=$of \
  --verify_checksum=false \
  --db=$db \
  --wal_dir=$db/wal \
  --sync=$sync \
  --disable_wal=$dwal \
  --compression_type=snappy \
  --stats_interval=$si \
  --compression_ratio=0.5 \
  --write_buffer_size=$wbs \
  --target_file_size_base=$mb \
  --max_write_buffer_number=$wbn \
  --max_background_compactions=$mbc \
  --level0_file_num_compaction_trigger=$ctrig \
  --level0_slowdown_writes_trigger=$delay \
  --level0_stop_writes_trigger=$stop \
  --num_levels=$levels \
  --delete_obsolete_files_period_micros=$del \
  --min_level_to_compress=$mcz \
  --stats_per_interval=1 \
  --max_bytes_for_level_base=$bpl \
  --use_existing_db=true \
  --writes_per_second=$wps

#--disable_seek_compaction=true \
#dds=false
#--disable_data_sync=$dds \
#overlap=10
#--max_grandparent_overlap_factor=$overlap \
