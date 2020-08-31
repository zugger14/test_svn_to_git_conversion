IF OBJECT_ID('dbo.spa_report_writer_view_users') IS NOT null
DROP PROC dbo.[spa_report_writer_view_users]
go

CREATE proc dbo.[spa_report_writer_view_users] 
	  @flag					char(1)
	, @functional_users_id	varchar(MAX)= NULL
	, @function_id			varchar(MAX) = NULL
	, @role_id				int = NULL
	, @login_id				varchar(50) = NULL
	, @entity_id			int = NULL
AS
 SET NOCOUNT ON 
DECLARE @sucess_msg varchar(2000)
DECLARE @error_msg	varchar(2000)

SET @sucess_msg = ''
SET @error_msg = ''

BEGIN TRY

--	IF @flag = 'i'
--	BEGIN
--		SET @sucess_msg = 'Data Successfully Inserted.'
--		SET @error_msg = 'Error inserting data'
--		INSERT INTO report_writer_view_users (function_id, role_id, login_id, entity_id, create_user, create_ts) 
--			SELECT item, @role_id, @login_id, @entity_id, dbo.FNADBUser(), GETDATE()
--			FROM dbo.SplitCommaSeperatedValues(@function_id)
--	END
	IF @flag = 'u'
	BEGIN
		SET @sucess_msg = 'Data Successfully Updated.'
		SET @error_msg = 'Error updating data'
		UPDATE report_writer_view_users SET function_id = @function_id, role_id = @role_id, login_id = @login_id
		, entity_id = @entity_id, update_user = dbo.FNADBUser(), update_ts = GETDATE() 
		WHERE functional_users_id = @functional_users_id
	END
--	ELSE IF @flag = 'd'
--	BEGIN
--		DECLARE @sql varchar(5000)
--		SET @sucess_msg = 'Data Successfully Deleted.'
--		SET @error_msg = 'Error deleting data'
--		
--		SET @sql = 'DELETE FROM report_writer_view_users
--					WHERE functional_users_id IN (' + @functional_users_id + ')'
--		EXEC (@sql)
--	END
	ELSE IF @flag = 'a'
	BEGIN
		SET @error_msg = 'Error selecting data'
		SELECT functional_users_id, function_id, role_id, login_id, entity_id, create_user, create_ts
		, update_user, update_ts 
		FROM report_writer_view_users WHERE functional_users_id = @functional_users_id
	END
	ELSE IF @flag = 's'
	BEGIN
		SET @error_msg = 'Error selecting data'
		SELECT functional_users_id, function_id, role_id, login_id, entity_id, create_user
		, dbo.FNADateFormat(create_ts) create_ts, update_user, dbo.FNADateFormat(update_ts) update_ts 
		FROM report_writer_view_users WHERE functional_users_id = @functional_users_id
	END

	IF @sucess_msg <> ''
		SELECT 0, 'report_writer_view_users', 'spa_report_writer_view_users'
				, 'Success', @sucess_msg, ''
END TRY
BEGIN CATCH
	DECLARE @error_number int
	SET @error_number = ERROR_NUMBER()
	
	SET @error_msg = @error_msg + ' (' + ERROR_MESSAGE() +').'
	SELECT @error_number, 'report_writer_view_users', 'spa_report_writer_view_users'
			, 'DB Error', @error_msg, ''

END CATCH
