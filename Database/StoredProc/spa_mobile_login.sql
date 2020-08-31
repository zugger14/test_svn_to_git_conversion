
/****** Object:  StoredProcedure [dbo].[spa_mobile_login]  ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_mobile_login]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_mobile_login]

/****** Object:  StoredProcedure [dbo].[spa_mobile_login]  ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROC [dbo].[spa_mobile_login]	
				@flag CHAR(1) = 'l',
				@user_login_id VARCHAR(50) = NULL,
				@user_pwd VARCHAR(50) = NULL,
				@device_token VARCHAR(500) = NULL,
				@os VARCHAR(100) = NULL,
				@date DATETIME = NULL
AS 

SET NOCOUNT ON

IF @flag = 'l'
BEGIN
	--IF OBJECT_ID('tempdb..#temp_mobile_login') IS NOT NULL
 -- 		DROP TABLE #temp_mobile_login
  	
 -- 	CREATE TABLE #temp_mobile_login (
 -- 			[ErrorCode] VARCHAR(20) COLLATE DATABASE_DEFAULT ,
 -- 			[Module] VARCHAR(50) COLLATE DATABASE_DEFAULT ,
 -- 			[Area] VARCHAR(50) COLLATE DATABASE_DEFAULT ,
 -- 			[Status] VARCHAR(50) COLLATE DATABASE_DEFAULT ,
 -- 			[Message] VARCHAR(200) COLLATE DATABASE_DEFAULT ,
 -- 			[Recommendation] VARCHAR(50) COLLATE DATABASE_DEFAULT 
 -- 	)
  	
	--INSERT #temp_mobile_login
	--EXEC spa_is_valid_user @user_login_id, @user_pwd, NULL, NULL, 1	
	----EXEC spa_is_valid_user 'farrms_admin', 'faQUuij8/JHtU', NULL, NULL, 1
	
	IF @device_token <> ''
	BEGIN
		IF EXISTS (SELECT 1 FROM device_logins WHERE device_token = @device_token)
		BEGIN
			UPDATE device_logins
				SET user_login_id = @user_login_id,
					update_ts = GETDATE()
			WHERE device_token = @device_token
		END
		ELSE
		BEGIN			
			INSERT INTO device_logins ([user_login_id], [device_token], [os])
					VALUES (@user_login_id, @device_token, @os)
		
		END	
	END
	
	--SELECT * FROM #temp_mobile_login
	
END

ELSE IF @flag = 's'
BEGIN
	SELECT user_login_id, device_token, os, ISNULL(update_ts, create_ts) login_ts  FROM device_logins ORDER BY login_ts DESC
END 


ELSE IF @flag = 'a'
BEGIN
	DECLARE @ios_tokens VARCHAR(MAX)
	DECLARE @android_tokens VARCHAR(MAX)
	
	SELECT @ios_tokens = COALESCE(@ios_tokens+',' ,'') + dl.device_token FROM device_logins dl
	INNER JOIN dbo.FNASplit(@user_login_id, ',') t1 ON t1.item = dl.user_login_id
	WHERE os = 'ios'
	
	SELECT @android_tokens = COALESCE(@android_tokens+',' ,'') + dl.device_token FROM device_logins dl
	INNER JOIN dbo.FNASplit(@user_login_id, ',') t1 ON t1.item = dl.user_login_id
	WHERE os = 'android'
	
	SELECT @ios_tokens [ios_tokens], @android_tokens [android_tokens]
	
END

ELSE IF @flag = 'f'
BEGIN
	
	IF @date IS NOT NULL AND @date <> ''
	BEGIN
		IF ISNULL(@user_login_id, '') <> '' AND @user_login_id <> dbo.FNADBUser()   
		BEGIN
			--EXECUTE AS USER = @user_login_id;
			DECLARE @contextinfo VARBINARY(128)
			SELECT @contextinfo = CONVERT(VARBINARY(128), @user_login_id)
			SET CONTEXT_INFO @contextinfo
		END
		SELECT dbo.FNADateFormat(@date) [date]
	END
	ELSE 
	BEGIN		
		SELECT r.date_format
		FROM region AS r
		INNER JOIN application_users AS au ON  au.region_id = r.region_id AND au.user_login_id = @user_login_id
	END
END 
