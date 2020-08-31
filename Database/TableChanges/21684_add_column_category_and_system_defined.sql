IF COL_LENGTH('data_source', 'category') IS NULL
BEGIN
    ALTER TABLE data_source
	ADD category INT
	FOREIGN KEY(category) REFERENCES static_data_value(value_id);
END

IF COL_LENGTH('data_source', 'system_defined') IS NULL
BEGIN
    ALTER TABLE data_source
	ADD system_defined BIT
END

