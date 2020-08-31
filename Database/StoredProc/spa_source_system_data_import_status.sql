IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_source_system_data_import_status]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_source_system_data_import_status]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================================================================================
-- Create date: 2011-05-12
-- Description:	CRUD operation for table source_system_data_import_status
-- Params:
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[spa_source_system_data_import_status]
	@flag CHAR(1) = 's', 
	@process_id	VARCHAR(100) = NULL,
	@code VARCHAR(50) = NULL,
	@module	VARCHAR(500) = NULL,
	@source	VARCHAR(100) = NULL,
	@type VARCHAR(50) = NULL,
	@description VARCHAR(500) = NULL,
	@recommendation	VARCHAR(500) = NULL,
	@user_login_id VARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	IF @user_login_id IS NULL
		SET @user_login_id = dbo.FNADBUser()
	
	IF @flag = 'i'
	BEGIN
		INSERT INTO source_system_data_import_status (Process_id, code, module, source, [type], [description], recommendation, create_user, create_ts)
		VALUES(@process_id, @code, @module, @source, @type, @description, @recommendation, @user_login_id, GETDATE())
	END
	ELSE IF @flag = 's'
	BEGIN
		EXEC spa_get_import_process_status @process_id, @user_login_id
	END

END
GO
