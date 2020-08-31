BEGIN TRY
	BEGIN TRANSACTION
	DECLARE @user_name VARCHAR(100) = dbo.FNADBUser(),
			@time_stamp DATETIME = GETDATE()
	
	DELETE FROM static_data_value 
	WHERE type_id = 39400 
		AND value_id IN (39403, 39404)
	
	SET IDENTITY_INSERT static_data_value ON
	IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 39400)
	BEGIN
		INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
		VALUES (39400, 39400, 'Non Standard', 'Non Standard', NULL, @user_name, @time_stamp)
		PRINT 'Inserted static data value 39400 - Non Standard.'
	END
	SET IDENTITY_INSERT static_data_value OFF            

	SET IDENTITY_INSERT static_data_value ON
	IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 39401)
	BEGIN
		INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
		VALUES (39400, 39401, 'Standard', 'Standard', NULL, @user_name, @time_stamp)
		PRINT 'Inserted static data value 39401 - Standard.'
	END
	SET IDENTITY_INSERT static_data_value OFF                       

	SET IDENTITY_INSERT static_data_value ON
	IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 39402)
	BEGIN
		INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
		VALUES (39400, 39402, 'Transport', 'Transport', NULL, @user_name, @time_stamp)
		PRINT 'Inserted static data value 39402 - Transport.'
	END
	SET IDENTITY_INSERT static_data_value OFF                      
    
	SET IDENTITY_INSERT static_data_value ON
	IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 39405)
	BEGIN
		INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
		VALUES (39400, 39405, 'Execution', 'Execution', NULL, @user_name, @time_stamp)
		PRINT 'Inserted static data value 39405 - Execution.'
	END
	SET IDENTITY_INSERT static_data_value OFF

	COMMIT
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 1
		ROLLBACK

	PRINT ERROR_MESSAGE()
END CATCH