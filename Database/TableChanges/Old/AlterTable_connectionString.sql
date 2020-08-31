IF NOT EXISTS (SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'connection_string' and column_name = 'sql_proxy_account')
	ALTER TABLE connection_string ADD sql_proxy_account VARCHAR(100)
go

update connection_string set sql_proxy_account='FasTracker_proxy'
Go
IF NOT EXISTS (
       SELECT *
       FROM   INFORMATION_SCHEMA.[COLUMNS] c
       WHERE  c.COLUMN_NAME LIKE 'file_attachment_path'
              AND c.TABLE_NAME LIKE 'connection_string'
   )
BEGIN
    ALTER TABLE connection_string ADD
    file_attachment_path VARCHAR(1000) NULL
END
