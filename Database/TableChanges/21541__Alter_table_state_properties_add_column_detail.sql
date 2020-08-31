IF COL_LENGTH('state_properties', 'detail') IS NULL
BEGIN
    ALTER TABLE state_properties
	ADD detail CHAR(1) DEFAULT 'n' NOT NULL 
END

GO
--select * from state_properties
