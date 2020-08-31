IF COL_LENGTH('source_uom', 'uom_type_id') IS NULL
BEGIN
	ALTER TABLE source_uom ADD uom_type_id INT
	FOREIGN KEY (uom_type_id)
    REFERENCES static_data_value (value_id)
END
GO

