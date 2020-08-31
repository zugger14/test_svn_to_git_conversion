BEGIN TRY
	BEGIN TRANSACTION
	DECLARE @user_name VARCHAR(100) = dbo.FNADBUser(),
			@time_stamp DATETIME = GETDATE()
	
	DELETE FROM static_data_value 
	WHERE type_id = 44700 
		AND value_id = 44700
	
	SET IDENTITY_INSERT static_data_value ON
	IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 44701)
	BEGIN
		INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
		VALUES (44700, 44701, 'ICE Trade Vault', 'ICE Trade Vault', NULL, @user_name, @time_stamp)
	END
	SET IDENTITY_INSERT static_data_value OFF

	SET IDENTITY_INSERT static_data_value ON
	IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 44702)
	BEGIN
		INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
		VALUES (44700, 44702, 'REMIT', 'REMIT', NULL, @user_name, @time_stamp)
	END
	SET IDENTITY_INSERT static_data_value OFF            

	SET IDENTITY_INSERT static_data_value ON
	IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 44703)
	BEGIN
		INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
		VALUES (44700, 44703, 'EMIR', 'EMIR', NULL, @user_name, @time_stamp)
	END
	SET IDENTITY_INSERT static_data_value OFF        

	SET IDENTITY_INSERT static_data_value ON
	IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 44704)
	BEGIN
		INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
		VALUES (44700, 44704, 'MiFID', 'MiFID', NULL, @user_name, @time_stamp)
	END
	ELSE
	SET IDENTITY_INSERT static_data_value OFF      

	SET IDENTITY_INSERT static_data_value ON
	IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 44705)
	BEGIN
		INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
		VALUES (44700, 44705, 'ECM', 'Electronic Confirmation Matching', NULL, @user_name, @time_stamp)
	END
	SET IDENTITY_INSERT static_data_value OFF            
    
	COMMIT
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 1
		ROLLBACK

	PRINT ERROR_MESSAGE()
END CATCH