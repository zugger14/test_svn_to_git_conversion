IF OBJECT_ID(N'[dbo].[spa_my_report]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_my_report]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Updated date: 2012-10-22
-- Description: CRUD operations for table time_zone
 
-- Params:
-- @flag CHAR(1) - Operation flag
-- @my_report_id INT - my report id
-- @my_report_name VARCHAR(200) - my report name 
-- @paramset_hash VARCHAR(200) - paramset hash
-- @dashboard_id INT dashboard id
-- @criteria VARCHAR(2000) - criteris
-- @tooltip VARCHAR(1000) - tooltip
-- @xml_group VARCHAR(8000 - xml variable for report group
-- @xml_column VARCHAR(8000) xml variable for my reports
-- @user_name VARCHAR(200) - user name
-- @role_id INT - role id
-- @group_id INT - report group id
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_my_report]
    @flag				CHAR(1),
    @my_report_id		INT = NULL,
    @my_report_name		VARCHAR(200) = NULL,
    @paramset_hash		VARCHAR(200) = NULL,
    @dashboard_id		INT = NULL,
    @criteria			VARCHAR(2000) = NULL,
    @tooltip			VARCHAR(1000) = NULL,
    @xml_group			VARCHAR(8000) = NULL,
    @xml_column			VARCHAR(8000) = NULL,
    @user_name			VARCHAR(200) = NULL,
    @role_id			INT = NULL,
    @group_id			INT = NULL,
    @display_name		VARCHAR(100) = NULL
AS
SET NOCOUNT ON 
IF @user_name IS NULL	
	SET @user_name = dbo.FNADBUser()
IF @flag = 'i'
BEGIN
	BEGIN TRY
		BEGIN TRAN
		DECLARE @new_my_report_id		INT
		DECLARE @order					INT
		DECLARE @dashboard_report_flag	CHAR(1)
		
		SELECT @order = ISNULL(MAX(mr.column_order), 0) + 1 FROM my_report mr WHERE mr.role_id = @role_id AND mr.group_id = @group_id
				
		IF @paramset_hash IS NULL 
			SET @dashboard_report_flag = 'd'
		ELSE 
			SET @dashboard_report_flag = 'r'
		
		INSERT INTO my_report (
			my_report_name,
			dashboard_report_flag,
			paramset_hash,
			dashboard_id,
			criteria,
			tooltip,
			role_id,
			my_report_owner,
			group_id,
			column_order,
			display_name
		)
		VALUES (
			@my_report_name,
			@dashboard_report_flag,
			@paramset_hash,
			@dashboard_id,
			@criteria,
			@tooltip,
			@role_id,
			CASE WHEN @role_id = 0 THEN @user_name ELSE NULL END,
			@group_id,
			@order,
			@display_name
		)	
		
		SET @new_my_report_id = SCOPE_IDENTITY()
		
		COMMIT
		EXEC spa_ErrorHandler 0
			, 'my_report'
			, 'spa_my_report' 
			, 'Success'
			, 'Successfully saved data.'
			, @new_my_report_id
	END TRY
	BEGIN CATCH
		DECLARE @DESC	VARCHAR(500)
		DECLARE @err_no INT
	 
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		IF ERROR_MESSAGE() = 'CatchError'
		   SET @DESC = 'Fail to insert Data ( Errr Description:' + @DESC + ').'
		ELSE
		   SET @DESC = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'
	 
		SELECT @err_no = ERROR_NUMBER()
	 
		EXEC spa_ErrorHandler @err_no
			, 'my_report'
			, 'spa_my_report' 
			, 'Error'
			, @DESC
			, ''
			
	END CATCH
END
IF @flag = 'a'
BEGIN
	SELECT mr.my_report_id,
	       mr.my_report_name,
	       mr.criteria,
	       mr.tooltip,
	       mr.paramset_hash,
	       mr.dashboard_id,
	       mr.display_name
	FROM   my_report mr
	WHERE mr.my_report_id = @my_report_id
END
ELSE IF @flag = 'c'
BEGIN
	SELECT	[my_report_id] [my_report_id]
			, MAX(mr.criteria) [criteria]
			, r.report_id
			, MAX(r.[name] + '_' + rp.[name])  AS [report_name]
			, dbo.FNARFXGenerateReportItemsCombined(MAX(rp.report_page_id)) [items_combined]
			, rps.report_paramset_id
			, mr.paramset_hash
			, SUM(CASE WHEN ISNULL(rpm.hidden, -1) <> 1 AND (ISNULL(dsc.widget_id, 1) IN (3, 4, 5))  THEN 1 ELSE 0 END) [tree_filter_required]
		    , SUM(CASE WHEN ISNULL(rpm.hidden, -1) <> 1 AND (ISNULL(dsc.widget_id, 1) NOT IN (3, 4, 5)) THEN 1 ELSE 0 END) [other_filter_required]
	FROM my_report mr
		INNER JOIN report_paramset rps ON rps.paramset_hash = mr.paramset_hash
		LEFT JOIN report_page rp ON rps.page_id = rp.report_page_id
		INNER JOIN report r ON rp.report_id = r.report_id
		LEFT JOIN report_dataset_paramset rdp ON rdp.paramset_id = rps.report_paramset_id
		LEFT JOIN report_param rpm ON rdp.report_dataset_paramset_id = rpm.dataset_paramset_id 
		LEFT JOIN data_source_column dsc ON dsc.data_source_column_id = rpm.column_id
	WHERE my_report_id = @my_report_id
	GROUP BY my_report_id, r.report_id, rps.report_paramset_id, mr.paramset_hash, mr.role_id
END
ELSE IF @flag = 'e'
BEGIN
	SELECT mr.my_report_id,
		   mr.my_report_name,
		   mr.role_id,
		   mr.group_id,
		   mr.column_order,
		   mr.tooltip,
		   mr.display_name
	FROM   my_report mr 
	WHERE mr.dashboard_report_flag = 'r' 
		AND ISNULL(mr.my_report_owner, @user_name) = @user_name 

	UNION ALL

	SELECT mr.my_report_id,
		   mr.my_report_name,
		   mr.role_id,
		   mr.group_id,
		   mr.column_order,
		   mr.tooltip,
		   mr.display_name
	FROM   my_report mr 
	INNER JOIN report_paramset rp ON rp.paramset_hash = mr.paramset_hash
		AND rp.report_status_id = 2
	WHERE mr.dashboard_report_flag = 'r' 
		AND mr.my_report_owner <> @user_name 
	ORDER BY mr.column_order
END
ELSE IF @flag = 'f'
BEGIN
	SELECT mr.my_report_id,
		   mr.my_report_name,
		   mr.role_id,
		   mr.group_id,
		   mr.column_order,
		   mr.tooltip,
		   mr.dashboard_id,
		   mr.display_name
	FROM   my_report mr 
	WHERE mr.dashboard_report_flag = 'd' 
		AND ISNULL(mr.my_report_owner, @user_name) = @user_name

	UNION ALL

	SELECT mr.my_report_id,
		   mr.my_report_name,
		   mr.role_id,
		   mr.group_id,
		   mr.column_order,
		   mr.tooltip,
		   mr.dashboard_id,
		   mr.display_name
	FROM   my_report mr 
	INNER JOIN report_paramset rp ON rp.paramset_hash = mr.paramset_hash
		AND rp.report_status_id = 2
	WHERE mr.dashboard_report_flag = 'd' 
		AND mr.my_report_owner <> @user_name  
	ORDER BY mr.column_order
END
ELSE IF @flag = 'u'
BEGIN
	BEGIN TRY
		UPDATE my_report
		SET my_report_name = @my_report_name,
			paramset_hash = @paramset_hash,
			dashboard_id = @dashboard_id,
			criteria = @criteria,
			tooltip = @tooltip,
			display_name = @display_name
		WHERE my_report_id = @my_report_id
		
		EXEC spa_ErrorHandler 0
			, 'my_report'
			, 'spa_my_report' 
			, 'Success'
			, 'Successfully saved reports.'
			, ''
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler -1,
			 'my_report',
			 'spa_my_report',
			 'DB Error',
			 'Error on Saving My report.',
			 ''	
	END CATCH	
END
ELSE IF @flag = 'x'
BEGIN
	BEGIN TRY
		DECLARE @idoc_group		INT
		DECLARE @idoc_column	INT
					
		--Create an internal representation of the XML document.
		EXEC sp_xml_preparedocument @idoc_group OUTPUT,@xml_group
		EXEC sp_xml_preparedocument @idoc_column OUTPUT,@xml_column

		-- Create temp table to store the report_name and report_hash
		IF OBJECT_ID('tempdb..#rfx_my_report_group') IS NOT NULL
			DROP TABLE #rfx_my_report_group
		IF OBJECT_ID('tempdb..#rfx_my_report') IS NOT NULL
			DROP TABLE #rfx_my_report

		-- Execute a INSERT-SELECT statement that uses the OPENXML rowset provider.
		-- <PSRecordset GroupId=' + group_id + ' GroupOrder=' + group_order + '></PSRecordset>
		SELECT GroupId		[group_id],
			   GroupOrder   [group_order]
		INTO #rfx_my_report_group		       
		FROM   OPENXML(@idoc_group, '/Root/PSRecordset', 1)
		WITH (
			   GroupId		VARCHAR(20),
			   GroupOrder	VARCHAR(20)
		)
		--<PSRecordset MyReportId=' + my_report_id + ' GroupId=' + parent_id + ' MyReportOrder=' + my_report_order + '></PSRecordset>
		SELECT MyReportId		[my_report_id],
			   GroupId			[group_id],
			   MyReportOrder	[my_report_order]
		INTO #rfx_my_report		       
		FROM   OPENXML(@idoc_column, '/Root/PSRecordset', 1)
		WITH (
			   MyReportId		VARCHAR(20),
			   GroupId			VARCHAR(20),
			   MyReportOrder	VARCHAR(20)
		)	
		
		MERGE my_report_group AS mrg
		USING #rfx_my_report_group AS temp ON mrg.my_report_group_id = temp.group_id
		WHEN MATCHED THEN 
			UPDATE SET mrg.group_order = temp.group_order
		;
		
		MERGE my_report AS mr
		USING #rfx_my_report AS temp ON mr.my_report_id = temp.my_report_id
		WHEN MATCHED THEN 
			UPDATE SET mr.group_id = temp.group_id,
					   mr.column_order = temp.my_report_order
		;
		
		EXEC spa_ErrorHandler 0
			, 'my_report'
			, 'spa_my_report' 
			, 'Success'
			, 'Successfully saved reports.'
			, ''
	END TRY
	BEGIN CATCH
		ROLLBACK
					
		IF @@ERROR <> 0
			EXEC spa_ErrorHandler @@ERROR,
			     'my_report',
			     'spa_my_report',
			     'DB Error',
			     'Error on Saving My report.',
			     ''			
	END CATCH
END	