CREATE OR REPLACE PROCEDURE SP_CREATE_TABLES_IN_LOOP(P_NUM_TABLES INTEGER)
RETURNS TABLE (STATUS VARCHAR)
LANGUAGE SQL
AS
$$
DECLARE
  counter INTEGER;
  sql_statement VARCHAR;
  table_name VARCHAR;
BEGIN
  FOR i IN 1 TO P_NUM_TABLES DO
    table_name := 'loop_created_table_' || i;
    sql_statement := 'CREATE OR REPLACE TABLE ' || table_name || ' (id INTEGER, message VARCHAR);';
    EXECUTE IMMEDIATE :sql_statement;
    sql_statement := 'INSERT INTO ' || table_name || ' (id, message) VALUES (' || i || ', ''Table ' || i || ' created'');';
    EXECUTE IMMEDIATE :sql_statement;
  END FOR;

  LET rs RESULTSET := (SELECT P_NUM_TABLES || ' tables created successfully.' AS STATUS);
  RETURN TABLE(rs);
END;
$$;
