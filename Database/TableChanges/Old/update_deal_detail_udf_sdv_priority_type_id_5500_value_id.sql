/*
Script to update value id for udf field 'Priority' of type id 5500, the different value id other than 309152 created issue on extracting deal priority on Flow optimization report.
date created: 2016-04-11
*/
SET IDENTITY_INSERT static_data_value ON
GO

IF EXISTS (SELECT TOP 1 1
    FROM static_data_value sdv
    WHERE sdv.code = 'priority'
    AND sdv.type_id = 5500)
BEGIN TRY
	BEGIN TRAN
    
	ALTER TABLE user_defined_fields_template NOCHECK CONSTRAINT ALL
	ALTER TABLE user_defined_deal_fields_template NOCHECK CONSTRAINT ALL
	
    DELETE static_data_value
    WHERE code = 'priority'
        AND type_id = 5500

	UPDATE udft SET udft.field_name = 309152
	FROM  user_defined_fields_template udft
	WHERE  1=1 and udft.field_label in ('priority')

	UPDATE uddft SET uddft.field_name = 309152
	FROM  user_defined_deal_fields_template uddft
	WHERE  1=1 and uddft.field_label in ('priority')

	ALTER TABLE user_defined_fields_template CHECK CONSTRAINT ALL
	ALTER TABLE user_defined_deal_fields_template CHECK CONSTRAINT ALL

	
	
	INSERT INTO static_data_value(value_id, type_id, code, description)
    SELECT 309152, 5500, 'Priority', 'Priority'
    PRINT 'Static Data ''Priority'' with type ID 5500 updated.'

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK
	DECLARE @err_msg VARCHAR(5000) = ERROR_MESSAGE()
	PRINT @err_msg
END CATCH
ELSE
BEGIN
    PRINT 'Static Data ''Priority'' with type ID 5500 does not exist.'
END
SET IDENTITY_INSERT static_data_value OFF
GO