--select * from application_functions where function_name like '%Setup Book Structure%'
---Subsidiary
UPDATE autf
SET autf.hidden = 'y'
FROM application_ui_template aut
INNER JOIN application_ui_template_group autg
	ON aut.application_ui_template_id = autg.application_ui_template_id
INNER JOIN application_ui_template_definition autd
	ON autd.application_function_id = aut.application_function_id
INNER JOIN application_ui_template_fields autf
	ON autf.application_group_id = autg.application_group_id 
	AND autd.application_ui_field_id = autf.application_ui_field_id
WHERE aut.application_function_id in (
10101216) and default_label in ('Entity Type', 
								'Source of Discount Values', 
								'Risk Free Interest Rate Curve',
								'Long-Term Months', 
								'Tax Percentage', 
								'Time Zone'
								)

--stratagey 
UPDATE autf
SET autf.hidden = 'y'
FROM application_ui_template aut
INNER JOIN application_ui_template_group autg
	ON aut.application_ui_template_id = autg.application_ui_template_id
INNER JOIN application_ui_template_definition autd
	ON autd.application_function_id = aut.application_function_id
INNER JOIN application_ui_template_fields autf
	ON autf.application_group_id = autg.application_group_id 
	AND autd.application_ui_field_id = autf.application_ui_field_id
WHERE aut.application_function_id in (
10101217)  and default_label IN ('Accounting Type')


UPDATE
aug
SET 
aug.active_flag = 'n'
FROM application_ui_template aut
INNER JOIN application_ui_template_group aug 
	ON aug.application_ui_template_id = aut.application_ui_template_id 
WHERE aut.application_function_id = 10101217  AND
group_name IN ('Details','GL Code Mapping')


UPDATE autd
SET 
autd.insert_required = 'n'
FROM application_ui_template aut
INNER JOIN application_ui_template_group autg
	ON aut.application_ui_template_id = autg.application_ui_template_id
INNER JOIN application_ui_template_definition autd
	ON autd.application_function_id = aut.application_function_id
INNER JOIN application_ui_template_fields autf
	ON autf.application_group_id = autg.application_group_id 
	AND autd.application_ui_field_id = autf.application_ui_field_id
WHERE aut.application_function_id in (
10101217)  and default_label IN ('Functional Currency')

--	Also add Primary counterparty as not required. 

--select * from application_ui_template_definition where application_function_id = 10101210

UPDATE autf
SET autf.hidden = 'y'
FROM application_ui_template aut
INNER JOIN application_ui_template_group autg
	ON aut.application_ui_template_id = autg.application_ui_template_id
INNER JOIN application_ui_template_definition autd
	ON autd.application_function_id = aut.application_function_id
INNER JOIN application_ui_template_fields autf
	ON autf.application_group_id = autg.application_group_id 
	AND autd.application_ui_field_id = autf.application_ui_field_id
WHERE aut.application_function_id in (
10101210)  and default_label IN ('Accounting Type')

UPDATE
aug
SET 
aug.active_flag = 'n'
FROM application_ui_template aut
INNER JOIN application_ui_template_group aug 
	ON aug.application_ui_template_id = aut.application_ui_template_id 
WHERE aut.application_function_id = 10101210  AND
group_name IN ('Details','GL Code Mapping')

update
autf
set
autf.application_group_id = (SELECT application_group_id 
							FROM application_ui_template_group autgg 
							INNER JOIN application_ui_template autt 
							ON autt.application_ui_template_id = autgg.application_ui_template_id 
							AND autt.application_function_id = 10101213 
							AND  autgg.group_name = 'General')
FROM application_ui_template aut
INNER JOIN application_ui_template_group autg
	ON aut.application_ui_template_id = autg.application_ui_template_id
INNER JOIN application_ui_template_definition autd
	ON autd.application_function_id = aut.application_function_id
INNER JOIN application_ui_template_fields autf
	ON autf.application_group_id = autg.application_group_id 
	AND autd.application_ui_field_id = autf.application_ui_field_id
WHERE aut.application_function_id in (
10101213) and default_label IN ('Primary Counterparty')

UPDATE
aug
SET 
aug.active_flag = 'n'
FROM application_ui_template aut
INNER JOIN application_ui_template_group aug 
	ON aug.application_ui_template_id = aut.application_ui_template_id 
WHERE aut.application_function_id = 10101213  AND
group_name in ('GL Code Mapping')



UPDATE
autf
SET
autf.application_group_id = (SELECT application_group_id 
							FROM application_ui_template_group autgg 
							INNER JOIN application_ui_template autt 
							ON autt.application_ui_template_id = autgg.application_ui_template_id 
							AND autt.application_function_id = 10101213 
							AND  autgg.group_name = 'General')
FROM application_ui_template aut
INNER JOIN application_ui_template_group autg
	ON aut.application_ui_template_id = autg.application_ui_template_id
INNER JOIN application_ui_template_definition autd
	ON autd.application_function_id = aut.application_function_id
INNER JOIN application_ui_template_fields autf
	ON autf.application_group_id = autg.application_group_id 
	AND autd.application_ui_field_id = autf.application_ui_field_id
WHERE aut.application_function_id IN (
10101213) AND group_name IN ('Tagging') AND farrms_field_id IN (
'source_system_book_id1'
,'source_system_book_id2'
,'source_system_book_id3'
,'source_system_book_id4'
,'fas_deal_type_value_id'
)

UPDATE
autd
SET
autd.is_disable = 'y'
FROM application_ui_template aut
INNER JOIN application_ui_template_group autg
	ON aut.application_ui_template_id = autg.application_ui_template_id
INNER JOIN application_ui_template_definition autd
	ON autd.application_function_id = aut.application_function_id
INNER JOIN application_ui_template_fields autf
	ON autf.application_group_id = autg.application_group_id 
	AND autd.application_ui_field_id = autf.application_ui_field_id
WHERE aut.application_function_id IN (
10101213) AND group_name IN ('General') AND farrms_field_id IN (
'source_system_book_id1'
,'source_system_book_id2'
,'source_system_book_id3'
,'source_system_book_id4'
,'fas_deal_type_value_id'
)

UPDATE
aug
SET 
aug.active_flag = 'n'
FROM application_ui_template aut
INNER JOIN application_ui_template_group aug 
	ON aug.application_ui_template_id = aut.application_ui_template_id 
WHERE aut.application_function_id = 10101213  AND
group_name in ('Tagging')

