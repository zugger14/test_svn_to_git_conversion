IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_source_system_data_import_status_detail]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_source_system_data_import_status_detail]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================================================================================
-- Create date: 2011-05-12
-- Description:	CRUD operation for table source_system_data_import_status_detail
-- Params:
--	@flag CHAR(1) - i: Inserts into both source_system_data_import_status (master) and source_system_data_import_status_detail (detail) table.
--						@type_error is inserted as description in source_system_data_import_status_detail.
--						Both tables are mapped by a combination (process_id, type_error).
--				  - s: Selects	
--	@process_id	VARCHAR(50) - Process id
--	@source	VARCHAR(50) - Source (import filename in most of the case).
--	@type VARCHAR(500) - Type (Error...)
--	@description VARCHAR(1000) - Error description
--	@type_error VARCHAR(500) - master description, used to map with master.
--	@user_login_id VARCHAR(50) - User login id
--	@recommendation VARCHAR(500) - Recommendation to insert into master
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[spa_source_system_data_import_status_detail]
	@flag CHAR(1) = 's', 
	@process_id	VARCHAR(50) = NULL,
	@source	VARCHAR(50) = NULL,
	@type VARCHAR(500) = NULL,
	@description VARCHAR(1000) = NULL,
	@type_error VARCHAR(500) = NULL,
	@user_login_id VARCHAR(50) = NULL,
	@insert_into_master BIT = 0,
	@module VARCHAR(500) = NULL,
	@recommendation VARCHAR(500) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @master_source VARCHAR(50)
	
	IF @user_login_id IS NULL
		SET @user_login_id = dbo.FNADBUser()
	
	IF @flag = 'i'
	BEGIN
		INSERT INTO source_system_data_import_status_detail (process_id, source, [type], [description], type_error, create_user, create_ts)
		VALUES(@process_id, @source, @type, @description, @type_error, @user_login_id, GETDATE())

		-- if record not available in master, insert new
		IF @insert_into_master = 1
		BEGIN
			-- if record available in master, and multiple sources exists in detail, then update master source to NULL
			-- as it is meaningless to show one source (filename) in master, when other sources have same error.
			SELECT @master_source = (CASE WHEN COUNT(1) > 1 THEN NULL ELSE @source END) FROM source_system_data_import_status_detail
			WHERE process_id = @process_id AND type_error = @type_error
			
			IF NOT EXISTS(SELECT 1 FROM source_system_data_import_status
							WHERE Process_id = @process_id AND [description] = @type_error)
			BEGIN
				EXEC spa_source_system_data_import_status @flag, @process_id, 'Error', @module, @master_source, @type, @type_error, @recommendation
			END
			ELSE
			BEGIN
				UPDATE source_system_data_import_status SET source = @master_source WHERE Process_id = @process_id AND [description] = @type_error
			END	
		END		
	END
	ELSE IF @flag = 's'
	BEGIN
		EXEC spa_get_import_process_status_detail @process_id, @source, @type_error, @type
	END

END
GO
