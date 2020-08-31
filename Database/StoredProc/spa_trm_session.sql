IF OBJECT_ID(N'[dbo].[spa_trm_session]', N'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[spa_trm_session]
END
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

/**
	Stored Procedure to insert/update/check/delete session data of user

	Parameters	
	@flag : 'i' Insert new session of current user
			'a' Select session data of a user
			'd' Delete session data of current user
			'p' Check session timeout for current user. Updates last request timestamp if user's session is not expired
			'q' Return username of matching session ID
			'x' Delete session data of matching user
			'z' Used for SaaS login when two factor authentication is enabled and session variable 'otp_verified' is set to false initially to restrict user from skipping OTP verification by directly accessing main.menu.trm.php page. This will set session variable otp_verified' to true after OTP verification is complete and user will then only be able to access the application.
	@trm_session_id : Session ID of the user
	@session_updated_time : Current time
	@session_data: Session variables
	@machine_name: IP address of the user
	@machine_address: Host name of the user
	@max_session_time: Maximum amount of time for session expiry in seconds. Default 86400
*/

CREATE PROCEDURE [dbo].[spa_trm_session]
    @flag CHAR(1),
	@trm_session_id NVARCHAR(100) = NULL,
	@session_updated_time DATETIME = NULL,
	@session_data NVARCHAR(MAX) = NULL,
	@machine_name NVARCHAR(100) = NULL,
	@machine_address NVARCHAR(100) = NULL,
	@max_session_time INT = 86400
AS
 
DECLARE @sql VARCHAR(MAX)
DECLARE @desc VARCHAR(500)
DECLARE @err_no INT

DECLARE @cursor_session_id NVARCHAR(200)
DECLARE @url_address	NVARCHAR(1000),
		@msg			NVARCHAR(1000),
		@cache_key	NVARCHAR(MAX),
		@user_name	    NVARCHAR(50) = dbo.FNADBUser(),
		@post_session_data			VARCHAR(MAX),
		@client_session_data  NVARCHAR(MAX),
		@enable_data_caching BIT = 0


SELECT @client_session_data = session_data FROM trm_session WHERE is_active = 1 AND session_data like '%farrms_client_dir%'  AND create_user = @user_name

SELECT @enable_data_caching = right(item,1)
FROM dbo.FNASplit(@client_session_data,';')
WHERE item LIKE '%enable_data_caching%'

/* delimiter '|' is replaced by '~' as '|' delimeter is used in CLR error reporting logic.  */
IF @enable_data_caching = 1
BEGIN	
	--Reduced post data size.	
	SELECT @post_session_data = COALESCE(@post_session_data + '&','')  + substring(item,0,charindex('|',item)) + '=' + 
			 REPLACE(REPLACE(RIGHT(item,  CHARINDEX(':',REVERSE(item))-1),';',''),'"','')
			FROM dbo.FNASplit(@client_session_data,';')
			WHERE item like '%farrms_client_dir%' --OR item LIKE '%enable_data_caching%'
END			

IF @flag = 'i'
BEGIN
	BEGIN TRY
		IF OBJECT_ID('tempdb..#deleted_session_ids') IS NOT NULL
			DROP TABLE #deleted_session_ids
		CREATE TABLE #deleted_session_ids (session_id NVARCHAR(200))
		
		DECLARE @max_inactive_session DATETIME
		
		--Delete expired session id older than 2 day.		
		SET @max_inactive_session = DATEADD(ss, -2 * @max_session_time, GETDATE())
				
		DELETE FROM trm_session
		OUTPUT DELETED.trm_session_id INTO #deleted_session_ids(session_id)
		WHERE ISNULL(last_request_ts, session_updated_time) < @max_inactive_session
		
		IF EXISTS(SELECT 1 FROM trm_session WHERE trm_session_id = @trm_session_id AND machine_name = @machine_name)
		BEGIN
			UPDATE trm_session
			SET
				session_updated_time = ISNULL(@session_updated_time, GETDATE()),
				session_data = @session_data
			WHERE trm_session_id = @trm_session_id
			AND machine_name = @machine_name
		END
		ELSE
		BEGIN
			IF EXISTS(SELECT 1 FROM trm_session WHERE create_user = @user_name AND is_active = 1 AND trm_session_id <> @trm_session_id)
			BEGIN
				UPDATE trm_session SET is_active = 0
				OUTPUT INSERTED.trm_session_id INTO #deleted_session_ids(session_id) 
				WHERE create_user = @user_name

				DELETE trm_session OUTPUT DELETED.trm_session_id INTO #deleted_session_ids(session_id) WHERE create_user = @user_name AND is_active = 0 AND DATEDIFF(D, create_ts, GETDATE()) > 1
			END

			IF EXISTS(SELECT 1 FROM trm_session WHERE trm_session_id = @trm_session_id AND is_active = 0)
			BEGIN
				EXEC spa_ErrorHandler -1
					, 'trm_session'
					, 'trm_session'
					, 'Error' 
					, 'Session Ended.'
					, ''
				RETURN
			END
			
			INSERT INTO trm_session (
				trm_session_id,
				session_updated_time,
				session_data,
				machine_name,
				machine_address
			)
			SELECT @trm_session_id, ISNULL(@session_updated_time, GETDATE()), @session_data, @machine_name, @machine_address
		END

		IF EXISTS(SELECT 1 FROM #deleted_session_ids) AND @post_session_data IS NOT NULL
		BEGIN
			BEGIN TRY
				SELECT @url_address = substring(file_attachment_path,0,CHARINDEX('adiha.php.scripts',file_attachment_path,0)+17) + '/components/process_cached_data.php'
				FROM connection_string	

				DECLARE session_destroy CURSOR LOCAL FOR
				SELECT session_id
				FROM  #deleted_session_ids
								
				OPEN session_destroy
				FETCH NEXT FROM session_destroy
				INTO  @cursor_session_id
				WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @cache_key = 'encode_key=1&prefix=' + @cursor_session_id + '&newid=' + @trm_session_id + '&' + @post_session_data
					EXEC spa_push_notification @url_address, @cache_key ,'n',@msg output						
								
					FETCH NEXT FROM session_destroy INTO @cursor_session_id
				END
				CLOSE session_destroy
				DEALLOCATE session_destroy
			END TRY
			BEGIN CATCH
				IF CURSOR_STATUS('local','session_destroy') > = -1
				BEGIN
					DEALLOCATE session_destroy
				END
			END CATCH				
		END    
	
		EXEC spa_ErrorHandler 0
			, 'trm_session'
			, 'trm_session'
			, 'Success' 
			, 'Successfully saved data.'
			, ''
	END TRY
	BEGIN CATCH 
		IF @@TRANCOUNT > 0
		   ROLLBACK
 
		SET @desc = 'Fail to save data ( Errr Description:' + ERROR_MESSAGE() + ').'
 
		SELECT @err_no = ERROR_NUMBER()
 
		EXEC spa_ErrorHandler @err_no
		   , 'trm_session'
		   , 'spa_trm_session'
		   , 'Error'
		   , @desc
		   , ''
	END CATCH
END
ELSE IF @flag = 'a'
BEGIN
	SELECT ts.session_data
	FROM trm_session ts
	WHERE ts.trm_session_id = @trm_session_id
	AND ts.machine_name = @machine_name
	AND ts.is_active = 1
END
ELSE IF @flag = 'd'
BEGIN
	BEGIN TRY
		DELETE trm_session WHERE trm_session_id = @trm_session_id AND machine_name = @machine_name		
		
		EXEC spa_ErrorHandler 0
			, 'trm_session'
		    , 'spa_trm_session'
			, 'Success' 
			, 'Successfully deleted data.'
			, ''
	END TRY
	BEGIN CATCH	 
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		SET @desc = 'Fail to delete data ( Errr Description:' + ERROR_MESSAGE() + ').'
	 
		SELECT @err_no = ERROR_NUMBER()
	 
		EXEC spa_ErrorHandler @err_no
		   , 'trm_session'
		   , 'spa_trm_session'
		   , 'Error'
		   , @desc
		   , ''
	END CATCH
END
ELSE IF @flag = 'p'
BEGIN
	DECLARE @session_timeout INT = 1800	--30mins
	SELECT @session_timeout = ISNULL(var_value, 1800) 
	FROM  adiha_default_codes adc 
	INNER JOIN adiha_default_codes_values adcv ON adcv.default_code_id = adc.default_code_id
	WHERE adc.default_code_id = 101

	IF EXISTS(SELECT 1 FROM trm_session 
				WHERE trm_session_id = @trm_session_id AND is_active = 1 
					AND DATEDIFF (ss, ISNULL(last_request_ts, GETDATE()), GETDATE()) <= @session_timeout) 
	BEGIN
		UPDATE trm_session
		SET
			last_request_ts = GETDATE()
		WHERE trm_session_id = @trm_session_id
		AND is_active = 1

		SELECT DATEDIFF (ss, GETDATE(), ISNULL(ts.last_request_ts, GETDATE())) [session_time]	
		FROM trm_session ts
		WHERE ts.trm_session_id = @trm_session_id
			AND ts.is_active = 1 --2018-04-03 14:06:38.800 -2739
	END
	ELSE
	BEGIN
		SELECT 99999999 [session_time]
	END
	RETURN
END
ELSE IF @flag = 'q'
BEGIN
	SELECT ts.create_user app_user_name
	FROM trm_session ts
	WHERE ts.trm_session_id = @trm_session_id
END
ELSE IF @flag = 'x'
BEGIN
	BEGIN TRY
		IF OBJECT_ID('tempdb..#garbage_session_ids') IS NOT NULL
			CREATE TABLE #garbage_session_ids (session_id NVARCHAR(200))

		SET @session_updated_time = DATEADD(ss, -1 * @max_session_time, GETDATE())
		
		DELETE trm_session
		OUTPUT DELETED.trm_session_id INTO #garbage_session_ids(session_id)
		WHERE session_updated_time < @session_updated_time

		IF EXISTS(SELECT 1 FROM #garbage_session_ids)  AND @post_session_data IS NOT NULL
		BEGIN
			BEGIN TRY
				SELECT @url_address = substring(file_attachment_path,0,CHARINDEX('adiha.php.scripts',file_attachment_path,0)+17) + '/components/process_cached_data.php'
				FROM connection_string	

				DECLARE session_destroy2 CURSOR LOCAL FOR
				SELECT session_id
				FROM  #garbage_session_ids
								
				OPEN session_destroy2
				FETCH NEXT FROM session_destroy2
				INTO  @cursor_session_id
				WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @cache_key = 'encode_key=1&prefix=' + @cursor_session_id + '&' + @post_session_data
					EXEC spa_push_notification @url_address, @cache_key ,'n',@msg output						
								
					FETCH NEXT FROM session_destroy2 INTO @cursor_session_id
				END
				CLOSE session_destroy2
				DEALLOCATE session_destroy2
			END TRY
			BEGIN CATCH
				IF CURSOR_STATUS('local','session_destroy2') > = -1
				BEGIN
					DEALLOCATE session_destroy2
				END
			END CATCH				
		END
		
		EXEC spa_ErrorHandler 0
			, 'trm_session'
		    , 'spa_trm_session2'
			, 'Success' 
			, 'Successfully deleted data.'
			, ''
	END TRY
	BEGIN CATCH	 
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		SET @desc = 'Fail to delete data ( Errr Description:' + ERROR_MESSAGE() + ').'
	 
		SELECT @err_no = ERROR_NUMBER()
	 
		EXEC spa_ErrorHandler @err_no
		   , 'trm_session'
		   , 'spa_trm_session2'
		   , 'Error'
		   , @desc
		   , ''
	END CATCH
END
ELSE IF @flag = 'z'
BEGIN
	IF EXISTS (SELECT 1 FROM trm_session WHERE is_active = 1 AND trm_session_id = @trm_session_id)
	BEGIN
		UPDATE trm_session
		SET session_data = REPLACE(REPLACE(session_data, 'false', 'true'), 5, 4)
		WHERE trm_session_id = @trm_session_id
	END
END
