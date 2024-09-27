-- 自动完成所有表的序列更新
-- 规则： 每张表都以“id”作为主键，所有的序列都是以“表名_id_seq”命名，且有一张以“_”开头的表不需要更新序列。

CREATE OR REPLACE FUNCTION update_tables_seq ( ) 
RETURNS void AS $$
  DECLARE
  table_name_cursor CURSOR FOR 
  SELECT
    tablename 
  FROM
    pg_tables 
  WHERE
    schemaname = 'public' 
    AND tablename NOT LIKE'\_%';
  
  table_name_ VARCHAR(255);
  prepared_sql VARCHAR(255);
  
BEGIN
  FOR ref_record in table_name_cursor LOOP
  prepared_sql := 'SELECT setval( ''' || ref_record.tablename;
  prepared_sql := prepared_sql || '_id_seq'','||'( SELECT MAX ( id ) FROM "'||ref_record.tablename||'") );';
  RAISE NOTICE '%', prepared_sql;
  EXECUTE prepared_sql;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

---------


