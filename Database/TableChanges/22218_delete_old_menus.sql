-- REFERENCED WITH application functions
DELETE FROM dbo.application_functional_users
WHERE function_id IN (
	10201600
	,10101400
	,10104100
	,10131300
)
DELETE FROM dbo.application_ui_template 
WHERE application_function_id IN (
	10201600
	,10101400
	,10104100
	,10131300
)		
DELETE FROM dbo.application_ui_template_definition 
WHERE application_function_id IN (
	10201600
	,10101400
	,10104100
	,10131300
)	
DELETE FROM dbo.favourites_menu 
WHERE function_id IN (
	10201600
	,10101400
	,10104100
	,10131300
)					
DELETE FROM dbo.menu_item 
WHERE function_id IN (
	10201600
	,10101400
	,10104100
	,10131300
)							
DELETE FROM dbo.wizard_page 
WHERE function_id IN (
	10201600
	,10101400
	,10104100
	,10131300
)						

-- Application Functions
DELETE FROM application_functions
WHERE function_id IN (
	 10201600
	,10101400
	,10104100
	,10131300
)

-- Setup Menu
DELETE FROM setup_menu
WHERE function_id IN (
	10201600
	,10101400
	,10104100
	,10131300
)
