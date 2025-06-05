CREATE OR REPLACE PROCEDURE SP_GET_TABLE_INFO_JS(P_TABLE_NAMES_CSV VARCHAR)
RETURNS TABLE (TABLE_SCHEMA VARCHAR, TABLE_NAME VARCHAR)
LANGUAGE JAVASCRIPT
AS
$$
// Retrieve the input parameter
var input_csv = P_TABLE_NAMES_CSV;

// Check if input_csv is null, empty, or contains only whitespace
if (input_csv === null || input_csv.trim() === "") {
  // Return an empty result set matching the procedure's return table structure
  var emptyQueryNoInput = "SELECT NULL AS TABLE_SCHEMA, NULL AS TABLE_NAME WHERE 1=0;";
  var stmtNoInput = snowflake.createStatement({sqlText: emptyQueryNoInput});
  var resultSetNoInput = stmtNoInput.execute();
  return resultSetNoInput;
}

// Split the P_TABLE_NAMES_CSV string by commas
var table_names_array = input_csv.split(',');

// Trim leading/trailing whitespace and filter out empty strings
var cleaned_table_names = [];
for (var i = 0; i < table_names_array.length; i++) {
  var trimmed_name = table_names_array[i].trim();
  if (trimmed_name !== "") {
    cleaned_table_names.push(trimmed_name);
  }
}

// If, after parsing and filtering, the list of table names is empty
if (cleaned_table_names.length === 0) {
  // Return an empty result set matching the procedure's return table structure
  var emptyQueryParsed = "SELECT NULL AS TABLE_SCHEMA, NULL AS TABLE_NAME WHERE 1=0;";
  var stmtParsedEmpty = snowflake.createStatement({sqlText: emptyQueryParsed});
  var resultSetParsedEmpty = stmtParsedEmpty.execute();
  return resultSetParsedEmpty;
}

// Construct the SQL query string
var sql_query_string = "SELECT TABLE_SCHEMA, TABLE_NAME FROM information_schema.tables WHERE TABLE_NAME IN (";
var placeholders = [];
for (var j = 0; j < cleaned_table_names.length; j++) {
  placeholders.push("?");
}
sql_query_string += placeholders.join(',') + ")";

// The array of trimmed, non-empty table names will be used for bindings
var bindings_array = cleaned_table_names;

// Execute the main query
var stmt = snowflake.createStatement({sqlText: sql_query_string, binds: bindings_array});
var resultSet = stmt.execute();
return resultSet;
$$;
