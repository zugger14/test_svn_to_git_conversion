UPDATE maintain_field_deal
SET sql_string = 'EXEC spa_getsourcecounterparty @flag=''s'''
WHERE farrms_field_id = 'counterparty_id'

GO


UPDATE maintain_field_deal
SET sql_string = 'EXEC spa_getsourcecounterparty @flag=''s'', @int_ext_flag = ''b'''
WHERE farrms_field_id = 'broker_id'

GO


UPDATE maintain_field_deal
SET sql_string = 'EXEC spa_getAllMeter @flag=''s'''
WHERE farrms_field_id = 'meter_id'

GO


UPDATE maintain_field_deal
SET sql_string = 'EXEC spa_GetAllPriceCurveDefinitions @flag=''a'''
WHERE farrms_field_id = 'formula_curve_id'

GO

UPDATE maintain_field_deal
SET sql_string = 'EXEC spa_GetAllPriceCurveDefinitions @flag=''a'''
WHERE farrms_field_id = 'curve_id'

GO

UPDATE maintain_field_deal
SET sql_string = 'EXEC spa_contract_group ''r'''
WHERE farrms_field_id = 'contract_id'


GO


