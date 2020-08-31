IF OBJECT_ID(N'ixp_import_data_mapping', N'U') IS NOT NULL AND COL_LENGTH('ixp_import_data_mapping', 'udf_field_id') IS NULL
BEGIN
    ALTER TABLE 
	/**
		Columns
		udf_field_id : This is a UDF field id which is used to map source data and user defined deal/detail fields.
	*/
		ixp_import_data_mapping ADD udf_field_id INT
END
GO