spool /u1/usr/tiptop/out/pga.out
select  PGA_TARGET_FOR_ESTIMATE as PGA_TARGET
       ,PGA_TARGET_FACTOR
       ,ESTD_PGA_CACHE_HIT_PERCENTAGE as c3
       ,ESTD_OVERALLOC_COUNT as c4
from V$PGA_TARGET_ADVICE;

spool off;