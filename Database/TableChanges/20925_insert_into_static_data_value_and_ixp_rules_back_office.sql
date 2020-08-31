--inserting category for ixp_rules first i.e. Inserting Back Office
IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE type_id = 23500 and value_id = 23506)
BEGIN 
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id , [type_id] , code, [description])
	VALUES (23506, 23500, 'Back Office', 'Back Office')
	SET IDENTITY_INSERT static_data_value OFF
	PRINT 'Back Office static data value added.'
END
ELSE
	PRINT 'Back Office already exists.'

--inserting ixp_rules ( Allocate Cash Apply and Contract Charge Type Value rules under that group)
IF NOT EXISTS (SELECT 1 FROM ixp_rules WHERE ixp_rules_name = 'Cash Apply' AND ixp_category = 23506)
BEGIN
	INSERT INTO ixp_rules (ixp_rules_name, individuals_script_per_ojbect, import_export_flag, ixp_owner, ixp_category, is_system_import, is_active)
	VALUES ('Cash Apply', 'n','i', 'farrms_admin', 23506, 'y', 1)
	PRINT 'Cash Apply for Back Office allocated.'
END
ELSE
	PRINT 'Cash Apply for Back Office already exists.'
/*
IF NOT EXISTS (SELECT 1 FROM ixp_rules WHERE ixp_rules_name = 'Contract Charge Type Value' AND ixp_category = 23506)
BEGIN
	INSERT INTO ixp_rules (ixp_rules_name, individuals_script_per_ojbect, import_export_flag, ixp_owner, ixp_category, is_system_import, is_active)
	VALUES ('Contract Charge Type Value', 'n','i', 'farrms_admin', 23506, 'y', 1)
	PRINT 'Contract Charge Type Value for Back Office allocated.'
END
ELSE
	PRINT 'Contract Charge Type Value for Back Office already exists.'
*/