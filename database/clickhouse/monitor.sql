-- SQL 执行历史详情
select hostname() hostname
      ,type
      ,query_kind
      ,event_time
      ,databases
      ,user
      ,address
      ,query_duration_ms
      ,read_rows
      ,formatReadableSize(read_bytes) as read_size
      ,round(memory_usage/1024/1024/1024,2) as memory_usage_GB
      ,result_rows
      ,formatReadableSize(result_bytes) result_size
      ,query
      ,exception_code
      ,exception
from clusterAllReplicas('default_cluster', system.query_log)
where event_date = toDate(now()) and event_time > (now() - toIntervalMinute(300))
    and query_kind='Insert'
    and type='QueryFinish'
    and user='u_tgysg'
order by event_date ,event_time desc;


-- 分区表写入情况
SELECT
    count() AS new_parts,
    toStartOfMinute(event_time) AS modification_time_m,
    table,
    sum(rows) AS total_written_rows,
    formatReadableSize(sum(size_in_bytes)) AS total_bytes_on_disk
FROM clusterAllReplicas('default_cluster', system.part_log)
WHERE (event_type = 'NewPart') AND (event_time > (now() - toIntervalHour(2)))
and table = 'cmh_fd_data_sku_speed_local'
GROUP BY
    modification_time_m,
    table
ORDER BY
    modification_time_m ASC,
    table DESC;