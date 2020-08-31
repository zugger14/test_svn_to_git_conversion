-- Deleted unsed function id.
DELETE autf FROM application_ui_template_fields autf
	INNER JOIN application_ui_template_group autg ON autf.application_group_id = autg.application_group_id
	INNER JOIN application_ui_template aut ON autg.application_ui_template_id = aut.application_ui_template_id
	INNER JOIN application_functions af ON af.function_id = aut.application_function_id
WHERE af.function_id IN (20013300)

DELETE aulg FROM application_ui_layout_grid aulg 
	INNER JOIN application_ui_template_group autg ON aulg.group_id = autg.application_group_id
	INNER JOIN application_ui_template aut ON autg.application_ui_template_id = aut.application_ui_template_id
	INNER JOIN application_functions af ON af.function_id = aut.application_function_id
WHERE af.function_id IN (20013300)

DELETE autg FROM application_ui_template_group autg
	INNER JOIN application_ui_template aut ON autg.application_ui_template_id = aut.application_ui_template_id
	INNER JOIN application_functions af ON af.function_id = aut.application_function_id
WHERE af.function_id IN (20013300)

DELETE aut FROM application_ui_template aut
	INNER JOIN application_functions af ON af.function_id = aut.application_function_id
WHERE af.function_id IN (20013300)

DELETE autd FROM application_ui_template_definition autd 
	INNER JOIN application_functions af ON af.function_id = autd.application_function_id
WHERE function_id IN (20013300)

DELETE FROM application_functions 
	WHERE function_id IN (20013300, 20013301, 20013302)

DELETE FROM setup_menu 
	WHERE function_id = 20013300 
AND product_category = 10000000


