
UPDATE user_defined_fields_template
SET sql_string = 'EXEC spa_getsourcecounterparty ''s'''

where field_label IN 
(
'Receiving Counterparty',
'Shipping Counterparty',
'Upstream CPTY'
)


