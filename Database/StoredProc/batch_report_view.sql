IF OBJECT_ID(N'batch_report_view' ,N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[batch_report_view]
GO 

CREATE PROC [dbo].[batch_report_view]
	@report_name			VARCHAR(100) = NULL,
	@batch_process_id		VARCHAR(100) = NULL,
	@flag					CHAR(1) = 's'
AS
SET NOCOUNT ON

DECLARE @user_login_id		VARCHAR(50),
        @temptablename		VARCHAR(128),
        @str_batch_table	VARCHAR(MAX)

SET @user_login_id = dbo.FNADBUser()
SET @temptablename = dbo.FNAProcessTableName('batch_report' ,@user_login_id ,@batch_process_id)

IF @flag = 'u' -- update the message board to retrieve saved file
BEGIN
    SELECT @str_batch_table = dbo.FNABatchProcess('r', @batch_process_id, '' , GETDATE(), '', @report_name)
    --PRINT @str_batch_table
    EXEC (@str_batch_table) 
           
    SELECT OBJECT_NAME([OBJECT_ID]), * FROM   sys.columns
END
ELSE 
IF @flag = 'p' -- update the messageboard with processing message
BEGIN
    SELECT @str_batch_table = dbo.FNABatchProcess('p', @batch_process_id, '' , GETDATE(), '', @report_name)
    
    EXEC spa_print 'batch_table: ', @str_batch_table         
    EXEC (@str_batch_table)
    
    SET @str_batch_table = 'IF EXISTS(SELECT 1 FROM adiha_process.INFORMATION_SCHEMA.COLUMNS WITH(NOLOCK)
									WHERE [column_name]=''ROWID'' AND table_name=''' + REPLACE(@temptablename ,'adiha_process.dbo.' ,'') + ''') 
							BEGIN 
								ALTER TABLE ' + @temptablename + ' DROP COLUMN ROWID
							END'
    
   -- EXEC spa_print @str_batch_table
    EXEC (@str_batch_table)
	
	EXEC spa_ErrorHandler 0, 
						'Message Board', 
						'Success', 
						@report_name, 
						@batch_process_id, 
						@temptablename, 
						''
END
ELSE
BEGIN
    EXEC ('SELECT * FROM ' + @temptablename)
END
