/*
* function to identify either the provided user is in admin group or not.
* param: 
* @user_id (nvarchar): user login id
* @include_reporting_admin_group (bit): whether to consider reporting admin group as admin or not. 
* sligal@pioneersolutionsglobal.com
* 20 sep 2013
*/
IF  EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAIsUserOnAdminGroup]') AND TYPE IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[FNAIsUserOnAdminGroup]
	
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNAIsUserOnAdminGroup] (@user_id NVARCHAR(50), @include_reporting_admin_group BIT)
RETURNS BIT
AS
BEGIN
	
	DECLARE @is_admin BIT
	
	IF @user_id = dbo.FNAAppAdminID()
	BEGIN
		SET @is_admin = 1;
	END 
	ELSE 
	BEGIN
		DECLARE @role_value_id_for_admin INT = 7, 
				@role_value_id_for_reporting_admin INT = 8
		SET @role_value_id_for_reporting_admin = CASE WHEN @include_reporting_admin_group = 1 
														THEN @role_value_id_for_reporting_admin 
													  ELSE @role_value_id_for_admin 
												 END
	
		SET @include_reporting_admin_group = ISNULL(@include_reporting_admin_group, 0)
		IF EXISTS (	
			SELECT 1 
			FROM dbo.FNAGetUserRole(@user_id) fur
				INNER JOIN application_security_role asr 
					ON asr.role_id = fur.role_id 
					AND asr.role_type_value_id IN (@role_value_id_for_admin, @role_value_id_for_reporting_admin) 					
		)
		BEGIN
			SET @is_admin = 1
		END			
		ELSE 
			SET @is_admin = 0
	END 
		
	RETURN @is_admin
END
