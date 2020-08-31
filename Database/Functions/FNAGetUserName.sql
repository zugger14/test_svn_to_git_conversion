/*
* Function to return Full Name of a user
* param: 
* @user_id (nvarchar): user login id
*/
IF  EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAGetUserName]') AND TYPE IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[FNAGetUserName]
	
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNAGetUserName] (@user_id NVARCHAR(50))
RETURNS VARCHAR(5000)
AS
BEGIN	
	DECLARE @username NVARCHAR(50)
	SET @username = ISNULL((SELECT au.user_f_name + ' ' + ISNULL(au.user_m_name,'') + ' ' + au.user_l_name
			FROM application_users au
	    WHERE  user_login_id = @user_id), @user_id)	

		RETURN @username
END
