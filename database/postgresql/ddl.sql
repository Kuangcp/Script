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

-- 查询库下的所有表
SELECT c.relname AS table_name, pg_catalog.obj_description(c.oid, 'pg_class') AS table_comment
FROM pg_catalog.pg_class c
         LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
WHERE c.relkind = 'r'
  and n.nspname = 'public' -- 过滤schema
and c.relname not like '%_1_prt_%' -- 排除分区表
 AND c.relname in (select table_name from INFORMATION_SCHEMA.role_table_grants where grantee = 'who' and  privilege_type='SELECT') -- 过滤who用户下有select权限的表
 ORDER BY c.relname;
