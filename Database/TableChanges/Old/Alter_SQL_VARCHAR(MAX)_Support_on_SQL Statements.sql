
---	Tables - alert_sql Column - sql_statement
IF COL_LENGTH('alert_sql','sql_statement') IS NOT NULL
BEGIN
ALTER TABLE alert_sql 
ALTER COLUMN sql_statement VARCHAR(MAX);
END

--	Tables - ixp_rules Column - before_insert_trigger
IF COL_LENGTH('ixp_rules','before_insert_trigger') IS NOT NULL
BEGIN
ALTER TABLE ixp_rules 
ALTER COLUMN before_insert_trigger VARCHAR(MAX);
END

--	Tables - ixp_rules Column - after_insert_trigger
IF COL_LENGTH('ixp_rules','after_insert_trigger') IS NOT NULL
BEGIN
ALTER TABLE ixp_rules 
ALTER COLUMN after_insert_trigger VARCHAR(MAX);
END