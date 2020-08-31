
--Hide Re-Import Data menu
UPDATE setup_menu SET hide_show = 0 WHERE function_id = 20001100 

--Delete data from ixp_import_data_interface_staging
TRUNCATE TABLE ixp_import_data_interface_staging
