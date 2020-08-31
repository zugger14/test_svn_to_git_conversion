

--Author: Tara Nath Subedi
--Purpose: to check whether the logged in user is admin or not.
-- If the user has 10111000 function_id privilege then its admin.

IF OBJECT_ID(N'spa_isadmin',N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_isadmin]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spa_isadmin]
@flag VARCHAR(1) = NULL
AS
BEGIN
	IF @flag = 'r' 
	BEGIN
		DECLARE @check_report_admin_role INT
		SELECT @check_report_admin_role = ISNULL(dbo.FNAReportAdminRoleCheck(dbo.FNADBUser()), 0)
		SELECT @check_report_admin_role
		RETURN
	END
	
	DECLARE @check_admin_role INT
	SELECT @check_admin_role = ISNULL(dbo.FNAAppAdminRoleCheck(dbo.FNADBUser()), 0)
	
	DECLARE @admin CHAR(1);
	CREATE TABLE #admin_rights
		(
		  function_id VARCHAR(8) COLLATE DATABASE_DEFAULT ,
		  have_rights VARCHAR(8) COLLATE DATABASE_DEFAULT 
		)
	INSERT  INTO #admin_rights
			EXEC spa_haveMultipleSecurityRights 10111000

	SELECT  CASE --WHEN function_id = have_rights THEN 'y'
			WHEN (@check_admin_role = 1) THEN 'y'
			     ELSE 'n'
			 END [admin]
	FROM    #admin_rights
	
END
