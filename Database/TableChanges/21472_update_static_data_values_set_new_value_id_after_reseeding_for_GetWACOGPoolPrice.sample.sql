IF EXISTS(SELECT 1 FROM static_data_value WHERE type_id = 800 AND code = 'GetWACOGPoolPrice' AND value_id <> 10000148)
BEGIN
	BEGIN TRY
	BEGIN TRANSACTION
		DELETE FROM map_function_category WHERE function_id = (SELECT value_id FROM static_data_value WHERE type_id = 800 AND code = 'GetWACOGPoolPrice')

		DELETE FROM static_data_value WHERE type_id = 800 AND code = 'GetWACOGPoolPrice'

		SET IDENTITY_INSERT static_data_value ON
		IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000148)
		BEGIN
			INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
			VALUES (10000148, 800, 'GetWACOGPoolPrice', 'GetWACOGPoolPrice', '', 'farrms_admin', GETDATE())
			PRINT 'Inserted static data value 10000148 - GetWACOGPoolPrice.'
		END
		ELSE
		BEGIN
			PRINT 'Static data value 10000148 - GetWACOGPoolPrice already EXISTS.'
		END
		SET IDENTITY_INSERT static_data_value OFF
	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		SELECT 'ROLLBACK' , ERROR_MESSAGE ()
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION
	END CATCH
END
ELSE
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000148)
	BEGIN
		INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
		VALUES (10000148, 800, 'GetWACOGPoolPrice', 'GetWACOGPoolPrice', '', 'farrms_admin', GETDATE())
		PRINT 'Inserted static data value 10000148 - GetWACOGPoolPrice.'
	END
	ELSE
	BEGIN
		PRINT 'Static data value 10000148 - GetWACOGPoolPrice already EXISTS.'
	END
	SET IDENTITY_INSERT static_data_value OFF
END
	
GO

IF NOT EXISTS(SELECT * FROM map_function_category  WHERE function_id = (SELECT value_id FROM static_data_value WHERE type_id = 800 AND code = 'GetWACOGPoolPrice'))
BEGIN
DECLARE @category_id INT 
SELECT @category_id=value_id FROM static_data_value where type_id = 27400 and code ='price'
	INSERT INTO map_function_category(category_id,function_id,is_active)
	SELECT @category_id,value_id,1 FROM static_data_value WHERE type_id = 800 AND code = 'GetWACOGPoolPrice'


END
IF EXISTS(SELECT * FROM formula_editor_parameter WHERE field_label = 'WACOG Group ID')
BEGIN
	UPDATE formula_editor_parameter SET formula_id  = (SELECT value_id FROM static_data_value WHERE type_id = 800 AND code = 'GetWACOGPoolPrice')
	WHERE field_label = 'WACOG Group ID'
END
		