IF OBJECT_ID('spa_rdb_error_handler') IS NOT NULL
	DROP  PROCEDURE [dbo].[spa_rdb_error_handler]
GO


-- =============================================
-- Create date: 2008-10-12 02:06PM
-- Description:	Handles error occuring while importing rdb data
-- Params:
-- @as_of_date		varchar(20) - As of date
-- @error_message	varchar(1000) - Error message
-- @recommendation	varchar(500) - Recommendatation message
-- @process_id		varchar(50) - Process id, if null generates new one
-- @batch_id		varchar(150) - Batch id 
-- @fact_id			varchar(150) - Fact id (MTM, POS, AGR, RDB)
-- @user_login_id	varchar(50) - User login id
-- =============================================
CREATE PROCEDURE [dbo].[spa_rdb_error_handler]
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

	DECLARE @desc varchar(1500)
	DECLARE @flag char(1)
	DECLARE @source_system_id INT
	
	--RDB is used by source system Endur (id: 2) only
	SET @source_system_id = 2
	
	IF @process_id IS NULL
		SET @process_id = dbo.FNAGetNewID()
	IF @user_login_id IS NULL
		SET @user_login_id = dbo.FNADBUser()
	IF ISNULL(@fact_id, '') = ''
		SET @fact_id = 'RDB'
	IF @recommendation IS NULL
		SET @recommendation = 'Please check your data format.'

	SET @desc = 'SQL Error found: (' + ISNULL(@error_message, '') + ')'
	exec spa_print 'ERROR occured while importing data from RDB. ERROR: ' --+ @error_message

	SELECT @flag = (CASE 
						WHEN EXISTS(SELECT 1 FROM import_data_files_audit WHERE process_id = @process_id) THEN 'u'
						ELSE 'i' 
					END)	

	EXEC spa_print 'flag:', @flag, ' fact:', @fact_id	
	EXEC spa_import_data_files_audit @flag, DEFAULT, DEFAULT, @process_id, @fact_id, @batch_id, @as_of_date, 'e', @elapsed_time, DEFAULT, DEFAULT, @source_system_id

	INSERT INTO source_system_data_import_status(process_id, code, module, source, [type], description, recommendation) 
	SELECT @process_id, 'Error', 'Import Data', @fact_id, 'Data Error', @desc, @recommendation
	
END


GO
