IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_AssignPriorityToNominationXml]') AND TYPE IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_AssignPriorityToNominationXml]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_AssignPriorityToNominationXml]
	@flag CHAR(1),
	@xmlValue NVARCHAR(MAX)		

AS
	SET NOCOUNT ON
	DECLARE @sqlStmt VARCHAR(MAX)
	DECLARE @tempdetailtable VARCHAR(128)
	DECLARE @temphourtable VARCHAR(128)
	DECLARE @user_login_id VARCHAR(100) 
	DECLARE @process_id VARCHAR(50)

	SET @user_login_id = dbo.FNADBUser()
	DECLARE @report_position_process_id VARCHAR(100)
	DECLARE @job_name VARCHAR(100)
	DECLARE @report_position_deals VARCHAR(300)
	DECLARE @sql VARCHAR(8000)

	SET @report_position_process_id = REPLACE(NEWID(), '-', '_')

	SET @report_position_deals = dbo.FNAProcessTableName('report_position', @user_login_id,@report_position_process_id)
	EXEC ('CREATE TABLE ' + @report_position_deals + '( source_deal_header_id INT, action CHAR(1))')

	SET @tempdetailtable=dbo.FNAProcessTableName('nomination_group', @user_login_id,@process_id)

BEGIN TRY

	DECLARE @idoc INT
	DECLARE @doc VARCHAR(1000)
	DECLARE @nom_value INT 
	DECLARE @nom_value_id INT

	EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlValue

	SELECT * INTO #ztbl_xmlvalue
	FROM OPENXML (@idoc, '/GridGroup/Grid/GridRow', 2)
	WITH (	
		nomination_group_id VARCHAR(50) '@nomination_group_id',
		nomination_group INT '@nomination_group',
		[priority] INT '@priority',
		effective_date DATETIME '@effective_date'		
		)	
	--SELECT * from #ztbl_xmlvalue
	DECLARE @rowcount INT
	SELECT @rowcount = COUNT(DISTINCT nomination_group) FROM #ztbl_xmlvalue
	IF @rowcount = 1
	SELECT @nom_value =  nomination_group FROM #ztbl_xmlvalue
	BEGIN 
		IF @flag IN ('i', 'u')
		BEGIN
		BEGIN TRAN	
		MERGE nomination_group AS ng
		USING ( 
				SELECT	
					nomination_group_id,
					nomination_group,
					[priority],
					effective_date
				FROM #ztbl_xmlvalue
			) zxv ON ng.nomination_group_id = zxv.nomination_group_id and ng.nomination_group = zxv.nomination_group

	WHEN NOT MATCHED BY TARGET THEN
			INSERT (
					nomination_group,
					[priority],
					effective_date
					)
			VALUES (
					zxv.[nomination_group],
					zxv.[priority],
					[dbo].[FNAGetSQLStandardDateTime](zxv.effective_date)
					)

	WHEN MATCHED THEN
		UPDATE SET    
				nomination_group = zxv.nomination_group
				, [priority] = zxv.[priority]
				, effective_date = [dbo].[FNAGetSQLStandardDateTime](zxv.effective_date);

	IF(@flag = 'i')
	BEGIN
	SELECT @nom_value_id = nomination_group_id from nomination_group 
		where nomination_group = @nom_value 
		and effective_date = ( SELECT MAX(effective_date) from nomination_group where nomination_group = @nom_value )
	END
	ELSE
	BEGIN
		SET @nom_value_id = ''
	END

	EXEC spa_ErrorHandler 0
			, 'Source Deal Detail'
			, 'spa_getXml'
			, 'Success'
			, 'Assign Priority to Nomination Group save successfully.'
			, @nom_value_id

		COMMIT
	END
	END
END TRY

BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK		
	DECLARE @msg VARCHAR(5000)
	SELECT @msg = 'Failed Inserting record (' + ERROR_MESSAGE() + ').'
	
	EXEC spa_ErrorHandler @@ERROR
		, 'Source Deal Detail'
		, 'spa_AssignPriorityToNominationXml'
		, 'DB Error'
		, @msg
		, 'Failed Inserting Record'
END CATCH
