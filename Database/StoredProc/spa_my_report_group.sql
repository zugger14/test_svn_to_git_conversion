IF OBJECT_ID(N'[dbo].[spa_my_report_group]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_my_report_group]
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
-- @my_report_group_id VARCHAR(200) -- group ids
-- @my_report_group_name VARCHAR(200) -- group name
-- @report_dashboard_flag CHAR(1) -- 'r' for report, 'd' for dashboard
-- @role_id INT -- role_id
-- @my_report_ids VARCHAR(200) -- my_report_ids
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_my_report_group]
    @flag CHAR(1),
    @my_report_group_id VARCHAR(200) = NULL,
    @my_report_group_name VARCHAR(200) = NULL,
    @report_dashboard_flag CHAR(1) = NULL,
    @role_id INT = NULL,
    @my_report_ids VARCHAR(200) = NULL
AS
SET NOCOUNT ON 
IF @flag = 'i'
BEGIN
	IF EXISTS(SELECT 1 FROM my_report_group mrg WHERE mrg.my_report_group_name = @my_report_group_name AND mrg.report_dashboard_flag = @report_dashboard_flag AND mrg.role_id = @role_id)
	BEGIN
		EXEC spa_ErrorHandler -1,
			 'my_report_group',
			 'spa_my_report_group',
			 'DB Error',
			 'Group name already used.',
			 ''
			 RETURN
	END
	ELSE
	BEGIN
		BEGIN TRY
			DECLARE @order INT
			SELECT @order = ISNULL(MAX(mrg.group_order), 0) + 1 FROM my_report_group mrg WHERE mrg.role_id = @role_id
			
			INSERT INTO my_report_group (my_report_group_name, report_dashboard_flag, role_id, group_owner, group_order)
			SELECT @my_report_group_name, @report_dashboard_flag, @role_id, CASE WHEN @role_id = 0 THEN dbo.FNADBUser() ELSE NULL END, @order
			
			EXEC spa_ErrorHandler 0,
				 'my_report_group',
				 'spa_my_report_group',
				 'Success',
				 'Report Group Inserted.',
				 ''
		END TRY
		BEGIN CATCH
			EXEC spa_ErrorHandler -1,
				 'my_report_group',
				 'spa_my_report_group',
				 'Failed',
				 'Report Group Insertion Failed.',
				 ''
		END CATCH
	END
END

ELSE IF @flag = 'u'
BEGIN
    BEGIN TRY
    	UPDATE my_report_group
		SET my_report_group_name = @my_report_group_name
		WHERE my_report_group_id = @my_report_group_id
		
		EXEC spa_ErrorHandler 0,
				 'my_report_group',
				 'spa_my_report_group',
				 'Success',
				 'Report Group Updated.',
				 ''
    END TRY
    BEGIN CATCH
    	EXEC spa_ErrorHandler -1,
			 'my_report_group',
			 'spa_my_report_group',
			 'Failed',
			 'Report Group Update Failed.',
			 ''
    END CATCH
    
END

ELSE IF @flag = 'd'
BEGIN
	BEGIN TRY
    	DELETE FROM my_report_group WHERE my_report_group_id IN (SELECT item FROM dbo.SplitCommaSeperatedValues(@my_report_group_id))
		DELETE FROM my_report WHERE group_id IN (SELECT item FROM dbo.SplitCommaSeperatedValues(@my_report_group_id))
		
		IF @my_report_ids IS NOT NULL
		BEGIN
			DELETE FROM my_report WHERE my_report_id IN (SELECT item FROM dbo.SplitCommaSeperatedValues(@my_report_ids))
		END
		
		EXEC spa_ErrorHandler 0,
				 'my_report_group',
				 'spa_my_report_group',
				 'Success',
				 'Report Group Deleted.',
				 ''
    END TRY
    BEGIN CATCH
    	EXEC spa_ErrorHandler -1,
			 'my_report_group',
			 'spa_my_report_group',
			 'Failed',
			 'Report Group Deletion Failed.',
			 ''
    END CATCH
END

ELSE IF @flag = 'a'
BEGIN
	SELECT mrg.my_report_group_id,
	       mrg.my_report_group_name
	FROM   my_report_group mrg
	WHERE mrg.my_report_group_id = @my_report_group_id
END

ELSE IF @flag = 'x' -- populate report groups
BEGIN
	SELECT mrg.my_report_group_id,
	       mrg.my_report_group_name,
	       mrg.report_dashboard_flag,
	       mrg.role_id,
	       mrg.group_order	       
	FROM   my_report_group mrg
	WHERE mrg.report_dashboard_flag = 'r' AND ISNULL(mrg.group_owner, dbo.FNADBUser()) = dbo.FNADBUser() ORDER BY mrg.group_order
END

ELSE IF @flag = 'y' -- populate dashboard groups
BEGIN
	SELECT mrg.my_report_group_id,
	       mrg.my_report_group_name,
	       mrg.report_dashboard_flag,
	       mrg.role_id,
	       mrg.group_order	       
	FROM   my_report_group mrg
	WHERE mrg.report_dashboard_flag = 'd' AND ISNULL(mrg.group_owner, dbo.fnadbuser()) = dbo.fnadbuser() ORDER BY mrg.group_order
END