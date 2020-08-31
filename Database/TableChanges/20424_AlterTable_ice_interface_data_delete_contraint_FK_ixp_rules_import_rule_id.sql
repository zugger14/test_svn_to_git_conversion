IF  EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'FK_ixp_rules_import_rule_id')
BEGIN
	ALTER TABLE ice_interface_data
	DROP CONSTRAINT  FK_ixp_rules_import_rule_id;
END
ELSE 
 PRINT 'Constraint doesn''t exists'