UPDATE setup_menu
SET parent_menu_id = 10101099
WHERE product_category = 13000000
	AND display_name = 'Setup UOM Conversion'

IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE product_category = 13000000 AND display_name = 'Template' AND function_id = 10104099)
BEGIN
  INSERT INTO setup_menu (function_id, window_name, display_name, default_parameter, hide_show, parent_menu_id, product_category, menu_order, menu_type)
   VALUES (10104099, NULL, 'Template', '', 1, 10100000, 13000000, 1, 1)
END

UPDATE setup_menu
SET parent_menu_id = 10104099
WHERE product_category = 13000000
AND display_name IN ('Compose Email', 'Formula Builder', 'Setup Custom Report Template', 'Setup UDF Template', 'Setup Field Template')

UPDATE setup_menu
SET parent_menu_id = 10104099,
    display_name = 'Setup Deal Template'
WHERE function_id = 10101400

UPDATE setup_menu
SET display_name = 'Setup Manual Journal Entry'
WHERE function_id = 10237000

UPDATE setup_menu
SET display_name = 'Manage Document'
WHERE function_id = 10102900

UPDATE setup_menu
SET display_name = 'Setup Price Curve'
WHERE function_id = 10102600

UPDATE setup_menu
SET display_name = 'Setup Alert'
WHERE function_id = 10122500

UPDATE setup_menu
SET display_name = 'Setup Deal Template'
WHERE function_id = 10101400

UPDATE setup_menu
SET display_name = 'Setup Deal Field Template'
WHERE function_id = 10104200

UPDATE setup_menu
SET display_name = 'User and Role'
WHERE function_id = 10110000

UPDATE setup_menu
SET display_name = 'Create and View Deal'
WHERE function_id = 10132000

UPDATE setup_menu
SET display_name = 'ETRM Interface'
WHERE function_id = 13180000

UPDATE setup_menu
SET display_name = 'Automate Hedge Matching'
WHERE function_id = 10234400

UPDATE setup_menu
SET display_name = 'View Outstanding Automation Result'
WHERE function_id = 10234500

UPDATE setup_menu
SET display_name = 'Hedging Strategy'
WHERE function_id = 10231997

UPDATE setup_menu
SET display_name = 'Setup Hedging Relationship Type'
WHERE function_id = 10231900

UPDATE setup_menu
SET display_name = 'View Price'
WHERE function_id = 10151000