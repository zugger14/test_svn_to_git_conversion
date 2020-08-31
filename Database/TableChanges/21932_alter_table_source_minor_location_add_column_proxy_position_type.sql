IF COL_LENGTH('source_minor_location','proxy_position_type') IS NULL
BEGIN
	ALTER TABLE source_minor_location
	ADD proxy_position_type INT NULL
	CONSTRAINT fk_proxy_position_type FOREIGN KEY (proxy_position_type)
	REFERENCES static_data_value(value_id)
END
