/*
Script to make Prepay UDF internal (-ve).
*/

SET XACT_ABORT ON
GO

DECLARE @old_sdv_value_id_prepay INT
DECLARE @new_sdv_value_id_prepay INT = -6600

SELECT @old_sdv_value_id_prepay = value_id FROM static_data_value sdv WHERE sdv.type_id = 5500 AND sdv.code = 'Prepay'

PRINT 'Old Prepay sdv_id:' + CAST(@old_sdv_value_id_prepay AS VARCHAR(10))

IF @old_sdv_value_id_prepay = @new_sdv_value_id_prepay 
BEGIN
	PRINT 'Prepay UDF is already internal'
	RETURN;
END

--Throw error is uddft.field_id is null for any UDF, because the UDF relocation assumes there are no such rows for safe relocation
IF EXISTS (SELECT 1 FROM user_defined_deal_fields_template_main WHERE ISNULL(field_id, field_name) IS NULL)
BEGIN
	RAISERROR('There are some rows with NULL uddft.field_id or uddft.field_name which will make this Prepay UDF relocation unsafe. 
Please remove such rows carefully before rerunning this script'
		, 12, 1)
END

BEGIN TRY
	BEGIN TRAN

	--Insert new sdv with a modified code to avoid duplication, as (5500, 'Prepay') will already be available.
	SET IDENTITY_INSERT static_data_value ON
	IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = @new_sdv_value_id_prepay)
	BEGIN
		INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
		VALUES (@new_sdv_value_id_prepay, 5500, 'Prepay-TBD', 'Prepay', '', 'farrms_admin', GETDATE())
		PRINT 'Inserted static data value @new_sdv_value_id_prepay - Prepay-TBD.'
	END
	ELSE
	BEGIN
		PRINT 'Static data value @new_sdv_value_id_prepay - Prepay-TBD already EXISTS.'
	END
	SET IDENTITY_INSERT static_data_value OFF

	--Reset values to NULL for old Prepay UDF as we cannot directly update to new value due to FK relation to udft.field_id/field_name
	UPDATE dbo.user_defined_deal_fields_template_main
	SET field_id = NULL, field_name = NULL WHERE field_id = @old_sdv_value_id_prepay

	--Update udft.field_name & field_id to point to new id (@new_sdv_value_id_prepay) for existing Prepay UDF
	UPDATE dbo.user_defined_fields_template
	SET field_id = @new_sdv_value_id_prepay, field_name = @new_sdv_value_id_prepay WHERE field_id = @old_sdv_value_id_prepay

	--Update field_id, field_name in deal udf where field_Id is null
	UPDATE dbo.user_defined_deal_fields_template_main
	SET field_id = @new_sdv_value_id_prepay, field_name = @new_sdv_value_id_prepay WHERE field_id IS NULL

	--Delete old sdv of Prepay
	DELETE FROM static_data_value WHERE [type_id] = 5500 AND code = 'Prepay' AND value_id <> @new_sdv_value_id_prepay

	--Finally, rename the newly inserted sdv to Prepay
	UPDATE static_data_value SET code = 'Prepay' WHERE value_id = @new_sdv_value_id_prepay

	COMMIT

END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 ROLLBACK TRAN

	PRINT 'Error while relocation Prepay UDF in 22269_insert_sdv_-6600.sql';

	--throw so that the error is shown in Patch Executor
	THROW;
END CATCH
