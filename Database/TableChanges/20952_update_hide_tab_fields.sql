DECLARE @function_id_counterparty INT
SET @function_id_counterparty = 
	(SELECT application_function_id FROM application_ui_template WHERE template_name ='SetupCounterparty')

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
WHERE aut.application_function_id = @function_id_counterparty AND autd.farrms_field_id like ('CSA_Reportable_Trade')

UPDATE
aug
SET 
aug.active_flag = 'n'
FROM application_ui_template aut
INNER JOIN application_ui_template_group aug 
	ON aug.application_ui_template_id = aut.application_ui_template_id 
WHERE aut.application_function_id = @function_id_counterparty  AND
group_name IN ('Submission','External ID','Meter','Product','Certificate','Approved Counterparty','History','Fees')


DECLARE @function_id_location INT
SET 
	@function_id_location = 
	(SELECT application_function_id FROM application_ui_template WHERE template_name ='SetupLocation')



UPDATE
aug
SET 
aug.active_flag = 'n'
FROM application_ui_template aut
INNER JOIN application_ui_template_group aug 
	ON aug.application_ui_template_id = aut.application_ui_template_id 
WHERE aut.application_function_id = @function_id_location  
AND group_name IN ('Additional')


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
WHERE aut.application_function_id = @function_id_location AND autd.farrms_field_id IN (
'owner'
,'address'
,'postal_code'
,'profile_code'
,'forecasting_group'
,'physical_shipper'
,'calculation_method'
,'forecast_needed'
)


 DECLARE @application_field_set INT 
SET @application_field_set = 
(
SELECT distinct autf.application_fieldset_id
	FROM application_ui_template_fieldsets autf
INNER JOIN application_ui_template_group  autg 
	ON autg.application_group_id = autf.application_group_id
INNER JOIN application_ui_template_fields autfs 
	ON autfs.application_group_id = autg.application_group_id 
JOIN application_ui_template_definition autd 
	ON autd.application_ui_field_id = autfs.application_ui_field_id
WHERE label = 'Contact' 
	AND autd.application_function_id = @function_id_location
)

		 DELETE 
		 FROM application_ui_template_fieldsets
		 WHERE
		 application_fieldset_id = @application_field_set

UPDATE
aug
SET 
aug.active_flag = 'n'
FROM application_ui_template aut
INNER JOIN application_ui_template_group aug 
	ON aug.application_ui_template_id = aut.application_ui_template_id 
WHERE aut.application_function_id = @function_id_location  
AND group_name IN ('Additional','Nom Group/Route','Optimizer Rank','Del Rank')


 DECLARE @function_id_price_curve INT
SET 
	@function_id_price_curve = 
	(SELECT application_function_id FROM application_ui_template WHERE template_name ='SetupPriceCurves')

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
WHERE aut.application_function_id = @function_id_price_curve 
AND autd.farrms_field_id IN ('udf_block_group_id')



Declare @function_id int
set @function_id = 
(select application_function_id from application_ui_template where template_name  = 'contract_group_non_standard')

UPDATE
autd
SET
	autd.is_hidden = 'y'
FROM application_ui_template_fields autf
INNER JOIN application_ui_template_definition  autd 
	ON autf.application_ui_field_id = autd.application_ui_field_id
WHERE application_function_id = @function_id 
AND autd.field_id IN ('generic_mapping_link','self_billing')


UPDATE
autd
SET
	autd.is_hidden = 'y'
FROM application_ui_template_fields autf
INNER JOIN application_ui_template_definition  autd 
	ON autf.application_ui_field_id = autd.application_ui_field_id
WHERE application_function_id = @function_id 
AND autd.field_id IN ('generic_mapping_link','self_billing')

UPDATE
autd
SET
	autd.insert_required = 'n',
	autd.update_required = 'n'
FROM application_ui_template_fields autf
INNER JOIN application_ui_template_definition  autd 
	ON autf.application_ui_field_id = autd.application_ui_field_id
WHERE application_function_id = @function_id 
AND autd.field_id IN ('Commodity')


UPDATE
autd
SET
	autd.default_label = 'Charge Type Template'
FROM application_ui_template_fields autf
INNER JOIN application_ui_template_definition  autd 
	ON autf.application_ui_field_id = autd.application_ui_field_id
WHERE application_function_id = @function_id  AND
autd.default_label = 'Contract Component Template'


UPDATE
autd
SET
	autd.default_label ='Statement Type'
FROM application_ui_template_fields autf
INNER JOIN application_ui_template_definition  autd 
	ON autf.application_ui_field_id = autd.application_ui_field_id
WHERE application_function_id = @function_id  AND
autd.default_label = 'Document Type'

Update
autf
set
autf.application_group_id = (SELECT application_group_id 
							FROM application_ui_template_group autgg 
							INNER JOIN application_ui_template autt 
							ON autt.application_ui_template_id = autgg.application_ui_template_id 
							AND autt.application_function_id =@function_id 
							AND  autgg.group_name = 'General')
FROM application_ui_template_fields autf
INNER JOIN application_ui_template_definition  autd 
	ON autf.application_ui_field_id = autd.application_ui_field_id
INNER JOIN application_ui_template aut 
	ON aut.application_function_id = @function_id
INNER JOIN application_ui_template_group aug 
	ON aug.application_ui_template_id = aut.application_ui_template_id 
WHERE autd.application_function_id = @function_id  AND
autd.default_label in ('settlement specialist' ,'settlement accountant')
	AND group_name = 'Contact'

UPDATE
AUG 
SET 
	aug.active_flag = 'n'
FROM application_ui_template aut
INNER JOIN application_ui_template_group aug 
	ON aug.application_ui_template_id = aut.application_ui_template_id 
WHERE aut.application_function_id = @function_id  
AND group_name IN ('Contact','Price')

UPDATE
autd
SET
autd.is_hidden = 'y'
FROM application_ui_template_fields autf
INNER JOIN application_ui_template_definition  autd 
	ON autf.application_ui_field_id = autd.application_ui_field_id
WHERE application_function_id = @function_id 
AND default_label IN (
'Billing cycle'
,'Billing start month' 
,'Billing from date'
,'Billing to date'
,'Billing from hour'
,'Billing to hour'
,'Payment calendar'
,'Settlement calendar'
,'Pnl rule'
,'Pnl calendar')


UPDATE
autf
SET
	autf.hidden = 'y'
FROM application_ui_template_fields autf
INNER JOIN application_ui_template_definition  autd 
	ON autf.application_ui_field_id = autd.application_ui_field_id
WHERE application_function_id = @function_id 
and default_label IN (
'Billing cycle'
,'Billing start month' 
,'Billing from date'
,'Billing to date'
,'Billing from hour'
,'Billing to hour'
,'Payment calendar'
,'Settlement calendar'
,'Pnl rule'
,'Pnl calendar')


UPDATE
autd
SET
sql_string = 'EXEC spa_StaticDataValues @flag = ''b'', @type_id = 978,@license_not_to_static_value_id=''982,987,989,994,995
'''
FROM 
application_ui_template_definition autd
WHERE application_function_id = @function_id 
AND default_label = 'invoice frequency'


Declare @function_id_charge_type INT
SET @function_id_charge_type = 10211415

UPDATE
autd
SET
autd.is_hidden = 'y'
FROM application_ui_template_fields autf
INNER JOIN application_ui_template_definition  autd 
	ON autf.application_ui_field_id = autd.application_ui_field_id
WHERE application_function_id = @function_id_charge_type 
AND default_label IN (
'Effective date',
'End date')

UPDATE
autf
SET
autf.hidden = 'y'
FROM application_ui_template_fields autf
INNER JOIN application_ui_template_definition  autd 
	ON autf.application_ui_field_id = autd.application_ui_field_id
WHERE application_function_id = @function_id_charge_type 
AND default_label IN (
'Effective date',
'End date')


UPDATE
autd
SET
sql_string = 
	'EXEC spa_StaticDataValues @flag = ''b'', @type_id = 978,@license_not_to_static_value_id=''993,992,991'''
FROM application_ui_template_fields autf
INNER JOIN application_ui_template_definition  autd 
	ON autf.application_ui_field_id = autd.application_ui_field_id
WHERE application_function_id = @function_id_charge_type 
and default_label IN (
'Volume Granularity')


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
WHERE aut.application_function_id = 10211415 
	AND autd.farrms_field_id IN ('eqr_product_name', 'group_by', 'time_bucket_formula_id')


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
WHERE aut.application_function_id = 10211016 AND autd.farrms_field_id IN ('rate_id', 'total_id')


UPDATE
autd
SET
sql_string = 'EXEC spa_StaticDataValues @flag = ''b'', @type_id = 978,@license_not_to_static_value_id=''993,992,991,990'''
FROM application_ui_template_fields autf
INNER JOIN application_ui_template_definition  autd 
	ON autf.application_ui_field_id = autd.application_ui_field_id
WHERE application_function_id = 10211016 
and default_label IN ('Granularity')

UPDATE
autd
SET
sql_string = 
	'EXEC spa_StaticDataValues @flag = ''b'', @type_id = 1200,@license_not_to_static_value_id=''1205,1202,1204,1201,1203'''
FROM application_ui_template_fields autf
INNER JOIN application_ui_template_definition  autd 
	ON autf.application_ui_field_id = autd.application_ui_field_id
WHERE application_function_id = 10211016 
and default_label IN ('Show Value as')


Update
 application_ui_template_definition 
 SET
 default_label = 'Buy/Sell Netting'
 WHERE application_function_id = 10105830 AND default_label = 'Apply Netting'
 
 
 DECLARE @application_field_set_contract INT 
SET @application_field_set_contract = 
(
SELECT distinct autf.application_fieldset_id
	FROM application_ui_template_fieldsets autf
INNER JOIN application_ui_template_group  autg 
	ON autg.application_group_id = autf.application_group_id
INNER JOIN application_ui_template_fields autfs 
	ON autfs.application_group_id = autg.application_group_id 
JOIN application_ui_template_definition autd 
	ON autd.application_ui_field_id = autfs.application_ui_field_id
WHERE label = 'Invoice Rule' 
	AND autd.application_function_id = 10211415
)

DELETE FROM application_ui_template_fieldsets
 WHERE
 application_fieldset_id = @application_field_set_contract


UPDATE
application_ui_template_definition 
SET
	is_hidden = 'y'
WHERE application_function_id = 10211415
	AND default_label IN ( 
	 'Settlement Date'
	,'Settlement Calendar'
	,'Payment Calendar'
	,'PNL Calendar'
	,'PNL Date'
	)
	
UPDATE
application_ui_template_fields
SET
	hidden = 'y'
WHERE application_ui_field_id IN (
SELECT application_ui_field_id FROM application_ui_template_definition
WHERE application_function_id = 10211415
AND default_label IN ( 
	'Settlement Date'
	,'Settlement Calendar'
	,'Payment Calendar'
	,'PNL Calendar'
	,'PNL Date'
	)
)

UPDATE
autd
SET
	autd.insert_required = 'n',
	autd.update_required = 'n'
FROM application_ui_template_fields autf
INNER JOIN application_ui_template_definition  autd 
	ON autf.application_ui_field_id = autd.application_ui_field_id
WHERE application_function_id = 10211200 
AND autd.field_id IN ('Commodity')

UPDATE
autd
SET
	autd.default_label = 'Charge Type Template'
FROM application_ui_template_fields autf
INNER JOIN application_ui_template_definition  autd 
	ON autf.application_ui_field_id = autd.application_ui_field_id
WHERE application_function_id = 10211200  AND
autd.default_label = 'Contract Component Template'


UPDATE
autd
SET
	autd.default_label ='Statement Type'
FROM application_ui_template_fields autf
INNER JOIN application_ui_template_definition  autd 
	ON autf.application_ui_field_id = autd.application_ui_field_id
WHERE application_function_id = 10211200  AND
autd.default_label = 'Document Type'


