IF OBJECT_ID('spa_rdb_openrowset_error_handler') IS NOT NULL
	DROP  PROCEDURE [dbo].[spa_rdb_openrowset_error_handler]
GO


-- =============================================
-- Create date: 2008-10-12 02:06PM
-- Description:	Handles error occuring while executing openrowset
-- Params:
-- @as_of_date		varchar(20) - As of date
-- @error_message	varchar(1000) - Error message
-- @recommendation	varchar(500) - Recommendatation message
-- @process_id		varchar(50) - Process id, if null generates new one
-- @batch_id		varchar(150) - Batch id 
-- @fact_id			varchar(150) - Fact id (MTM, POS, AGR, RDB)
-- @user_login_id	varchar(50) - User login id
-- =============================================
CREATE PROCEDURE [dbo].[spa_rdb_openrowset_error_handler]
	@as_of_date		varchar(20),
	@error_message	varchar(475), --source_system_data_import_status contains size only 500
	@recommendation	varchar(500) = NULL,
	@process_id		varchar(50) = NULL,
	@elapsed_time	float = NULL,	
	@fact_id		varchar(150) = '',
	@batch_id		varchar(150) = '',
	@user_login_id	varchar(50) = NULL	
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @rdb_connection_success	bit
	DECLARE @flag char(1)

	--first check if it is connection related problem
	EXEC spa_check_openrowset_connection @success = @rdb_connection_success OUTPUT
	IF @rdb_connection_success = 0
	BEGIN
		SET @error_message = 'Cannot establish connection with the RDB database server'
		SET @recommendation = 'Please check your RDB database connection parameters'
	END
	
	IF @recommendation IS NULL
		SET @recommendation = 'Verify that the query string is free of syntax errors and db name is correct.'

	exec spa_print @recommendation

	/*
	SELECT @flag = (CASE 
						WHEN EXISTS(SELECT 1 FROM spa_import_data_files_audit WHERE process_id = @process_id) THEN 'u'
						ELSE 'i' 
					END)	

	EXEC spa_import_data_files_audit @flag, DEFAULT, DEFAULT, @process_id , @fact_id, @batch_id, @as_of_date, 'e', 0

	INSERT INTO source_system_data_import_status(process_id, code, module, source, [type], description, recommendation) 
	SELECT @process_id, 'Error', 'Import Data', @fact_id, 'Data Error', @desc, @recommendation
	*/

	EXEC spa_rdb_error_handler @as_of_date, @error_message, @recommendation, @process_id, @elapsed_time, @fact_id, @batch_id, @user_login_id
	
END
































GO
