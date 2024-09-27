-- show create table 语句
-- 说明： nspname 是schema relname 是 表名
SELECT
    'CREATE TABLE ' || nspname || '.' || relname || E'(\n' || array_to_string(array_agg(attname || ' ' || format_type(atttypid, atttypmod) || ' ' || CASE WHEN attnotnull THEN
                'NOT NULL'
            ELSE
                'NULL'
            END || CASE WHEN col_description(attrelid, attnum) IS NOT NULL THEN
                ' COMMENT ''' || replace(col_description(attrelid, attnum), '''', '''''') || ''''
            ELSE
                ''
            END), E',\n') || E'\n);' AS create_table_sql
FROM (
    SELECT
        *
    FROM
        pg_attribute
        JOIN pg_class ON pg_class.oid = pg_attribute.attrelid
        JOIN pg_namespace ON pg_namespace.oid = pg_class.relnamespace
    WHERE
        nspname = 'public'
        AND relname = 't_user'
        AND pg_class.relkind = 'r'::char
        AND attisdropped = 'f'
        AND attnum > 0
    ORDER BY
        attnum) t1
GROUP BY
    nspname,
    relname;

---
-- 查询表的 owner
SELECT c.relname AS table_name, r.rolname AS table_owner
FROM pg_class c
         INNER JOIN pg_roles r ON c.relowner = r.oid
         INNER JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE c.relkind = 'r'
  AND n.nspname = 'public'
  AND c.relname = 't_user';

--- 

-- 查询表占用的存储
SELECT
    pg_relation_size(pg_class.oid) AS table_size,
    pg_class.relname AS table_name
FROM
    pg_class
        LEFT JOIN pg_namespace ON pg_class.relnamespace = pg_namespace.oid
WHERE
        pg_namespace.nspname = 'public'
  AND pg_class.relname = 't_user';


---

-- 查询库下的所有表
SELECT c.relname AS table_name, pg_catalog.obj_description(c.oid, 'pg_class') AS table_comment
FROM pg_catalog.pg_class c
         LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
WHERE c.relkind = 'r'
  and n.nspname = 'public' -- 过滤schema
and c.relname not like '%_1_prt_%' -- 排除分区表
 AND c.relname in (select table_name from INFORMATION_SCHEMA.role_table_grants where grantee = 'who' and  privilege_type='SELECT') -- 过滤who用户下有select权限的表
 ORDER BY c.relname;

--- 

-- 查询表上关联的索引

select i.indrelid::regclass table_name,c.oid::regclass index_name,a.amname index_type
       ,pg_catalog.pg_get_indexdef(i.indexrelid, 0, true)
from pg_class c
join pg_index i on c.oid=i.indexrelid
join pg_am a on c.relam= a.oid
where i.indrelid='public.t_user'::regclass;

---

-- 查询表的分区信息

WITH att_arr AS (SELECT unnest(paratts) 
        FROM pg_catalog.pg_partition p 
        WHERE p.parrelid = (SELECT c.oid
FROM pg_catalog.pg_class c
     LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname||'.'||c.relname = 'public.t_user')  AND p.paristemplate = false
        ), 
idx_att AS (SELECT row_number() OVER() AS idx, unnest AS att_num FROM att_arr) 
SELECT attname FROM pg_catalog.pg_attribute, idx_att 
        WHERE attrelid=(SELECT c.oid
FROM pg_catalog.pg_class c
     LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname||'.'||c.relname = 'public.t_user') AND attnum = att_num ORDER BY idx


