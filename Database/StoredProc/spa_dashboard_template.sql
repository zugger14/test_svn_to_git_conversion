IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_dashboard_template]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_dashboard_template]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO

-- ===============================================================================================================
-- Created By : Biju Maharjan
-- Create date: 2014-04-24 
-- Description:	CRUD operation for dashboard template
-- Params:
-- @flag CHAR(1) -  Flag 's' to select dashboard template 
--				    Flag 'i' to insert dashboard template 
--					Flag 'u' to update dashboard template 
--					Flag 'd' to delete dashboard template				
-- @dashboard_template_id NVARCHAR(100) = NULL
-- @dashboard_template_name	NVARCHAR(100) = NULL
-- @dashboard_template_desc	NVARCHAR(100) = NULL
-- @dashboard_template_owner NVARCHAR(100) = NULL
-- @system_defined NCHAR(1) = NULL
-- @owner_filter NVARCHAR(100) = NULL -- to filter the dashboard template
-- ===============================================================================================================

CREATE PROCEDURE [dbo].[spa_dashboard_template]
	@flag						NCHAR(1),
	@dashboard_template_id		NVARCHAR(100) = NULL,
	@dashboard_template_name	NVARCHAR(100) = NULL,
	@dashboard_template_desc	NVARCHAR(100) = NULL,
	@dashboard_template_owner	NVARCHAR(100) = NULL,
	@system_defined				NCHAR(1) = NULL,
	@owner_filter				NVARCHAR(100) = NULL,
	@debug_mode					BIT = NULL
AS
IF ISNULL(@debug_mode, 0) = 0
   SET NOCOUNT ON

DECLARE @sql NVARCHAR(MAX)
DECLARE @identity_id INT

IF @flag = 's'
BEGIN
	SET @sql = 'SELECT 	dt.[dashboard_template_id] AS [Dashboard ID],
						dt.[dashboard_template_name] AS [Dashboard Name],
						dt.[dashboard_template_desc] AS [Dashboard Description],
						dt.[dashboard_template_owner] AS [Owner],
						dt.[system_defined] AS [System Defined]
				FROM dashboard_template dt
				WHERE 1=1 '	
				
				IF @owner_filter<>null or @owner_filter<>''
						   SET @sql = @sql + ' AND dt.dashboard_template_owner = ''' + @owner_filter + ''''	
						  
				IF @dashboard_template_id<>null or @dashboard_template_id<>''
						   SET @sql = @sql + ' AND dt.dashboard_template_id = ''' + @dashboard_template_id + ''''			
	IF @debug_mode = 1 
		exec spa_print @sql			
	EXEC(@sql)	
END

IF @flag = 'i'
BEGIN
	BEGIN TRY
		INSERT INTO dashboard_template
			(
				[dashboard_template_name],
				[dashboard_template_desc],
				[dashboard_template_owner],
				[system_defined]
			)
			VALUES
			(
				@dashboard_template_name,
				@dashboard_template_desc,
				@dashboard_template_owner,
				@system_defined
			)
		SET @identity_id = SCOPE_IDENTITY();
		
		EXEC spa_ErrorHandler 0
				, 'dashboard_template' 
				, 'spa_dashboard_template'
				, 'Success'
				, 'Dashboard Template Saved'
				, @identity_id
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler -1
			, 'dashboard_template'
			, 'spa_dashboard_template'
			, 'Error'
			, 'Failed to save Dashboard Template'
			, ''
	END CATCH
END

IF @flag = 'u'
BEGIN
	BEGIN TRY
		UPDATE dashboard_template
		SET
			dashboard_template_name = @dashboard_template_name,
			dashboard_template_desc = @dashboard_template_desc,
			system_defined = @system_defined
		WHERE
			dashboard_template_id = @dashboard_template_id
		
		EXEC spa_ErrorHandler 0
				, 'dashboard_template'
				, 'spa_dashboard_template'
				, 'Success'
				, 'Dashboard Template Updated'
				, ''
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler -1
			, 'dashboard_template'
			, 'spa_dashboard_template'
			, 'Error'
			, 'Failed to update Dashboard Template'
			, ''
	END CATCH
END

IF @flag = 'd'
BEGIN
	BEGIN TRY
		--DELETE FROM dashboard_template_privilege
		--WHERE dashboard_template_id = @dashboard_template_id
	
		DELETE FROM dashboard_template_detail
		WHERE dashboard_template_id = @dashboard_template_id
	
		DELETE FROM dashboard_template
		WHERE dashboard_template_id = @dashboard_template_id
		
		EXEC spa_ErrorHandler 0
				, 'dashboard_template'
				, 'spa_dashboard_template'
				, 'Success'
				, 'Changes have been saved successfully.'
				, ''
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler -1
			, 'dashboard_template'
			, 'spa_dashboard_template'
			, 'Error'
			, 'Failed to delete Dashboard Template'
			, ''
	END CATCH
END