--SELECT * FROM maintain_field_deal mfd 

	
UPDATE maintain_field_deal SET field_size = 20 WHERE field_id = 5

UPDATE maintain_field_deal SET field_type = 'a' WHERE field_id = 107

UPDATE maintain_field_deal SET field_type = 'a' WHERE field_id = 39

UPDATE maintain_field_deal SET field_type = 'd' WHERE field_id = 70
UPDATE maintain_field_deal SET sql_string = 'SELECT  ''m'' id,''Monthly'' val UNION SELECT ''q'', ''Quarterly'' UNION SELECT ''h'',''Hourly'' UNION SELECT ''s'',''Semi-Annually'' UNION SELECT ''a'', ''Annually'' UNION SELECT ''d'', ''Daily''' WHERE field_id = 70

UPDATE maintain_field_deal SET field_type = 't' WHERE field_id = 41
UPDATE maintain_field_deal SET field_type = 't' WHERE field_id = 40
UPDATE maintain_field_deal SET field_type = 't' WHERE field_id = 43
UPDATE maintain_field_deal SET field_type = 't' WHERE field_id = 44
UPDATE maintain_field_deal SET field_type = 't' WHERE field_id = 59


UPDATE maintain_field_deal SET field_type = 'd' WHERE field_id = 62
UPDATE maintain_field_deal SET sql_string = 'SELECT value_id,DESCRIPTION FROM static_data_value WHERE TYPE_ID = 978' WHERE field_id = 62

UPDATE maintain_field_deal SET field_type = 't' WHERE field_id = 64
UPDATE maintain_field_deal SET field_type = 't' WHERE field_id = 65
UPDATE maintain_field_deal SET field_type = 't' WHERE field_id = 66
UPDATE maintain_field_deal SET field_type = 't' WHERE field_id = 67

UPDATE maintain_field_deal SET field_type = 't' WHERE field_id = 72
UPDATE maintain_field_deal SET field_type = 't' WHERE field_id = 74
UPDATE maintain_field_deal SET field_type = 't' WHERE field_id = 76
UPDATE maintain_field_deal SET field_type = 't' WHERE field_id = 78
UPDATE maintain_field_deal SET field_type = 't' WHERE field_id = 80
UPDATE maintain_field_deal SET field_type = 't' WHERE field_id = 81
UPDATE maintain_field_deal SET field_type = 't' WHERE field_id = 84
UPDATE maintain_field_deal SET sql_string = 'SELECT source_curve_def_id,curve_name FROM source_price_curve_def' WHERE field_id =  88
UPDATE maintain_field_deal SET field_type = 't' WHERE field_id = 89
UPDATE maintain_field_deal SET field_type = 't' WHERE field_id = 91
UPDATE maintain_field_deal SET field_type = 't' WHERE field_id = 92
UPDATE maintain_field_deal SET field_type = 't' WHERE field_id = 96
UPDATE maintain_field_deal SET field_type = 't' WHERE field_id = 97
UPDATE maintain_field_deal SET sql_string = 'SELECT fe.formula_id,dbo.FNAFormulaFormat(fe.formula,''r'') AS [Formula] FROM formula_nested fn INNER JOIN formula_editor fe ON fn.formula_id = fe.formula_id WHERE fe.istemplate =''y''' WHERE field_id = 97


UPDATE maintain_field_deal SET field_type = 't' WHERE field_id = 99
UPDATE maintain_field_deal SET field_type = 't' WHERE field_id = 59
UPDATE maintain_field_deal SET field_type = 't' WHERE field_id = 105
UPDATE maintain_field_deal SET field_type = 't' WHERE field_id = 106
UPDATE maintain_field_deal SET field_type = 't' WHERE field_id = 108
UPDATE maintain_field_deal SET field_type = 'd' WHERE field_id = 110
UPDATE maintain_field_deal SET sql_string = 'SELECT  meter_id,recorderid FROM    meter_id' WHERE field_id =110
UPDATE maintain_field_deal SET field_type = 't' WHERE field_id = 112
UPDATE maintain_field_deal SET field_type = 't' WHERE field_id = 113
UPDATE maintain_field_deal SET field_type = 't' WHERE field_id = 114
UPDATE maintain_field_deal SET field_type = 't' WHERE field_id = 115
UPDATE maintain_field_deal SET field_type = 't' WHERE field_id = 119
UPDATE maintain_field_deal SET field_type = 't' WHERE field_id = 121
UPDATE maintain_field_deal SET field_type = 't' WHERE field_id = 122
UPDATE maintain_field_deal SET field_type = 't' WHERE field_id = 124
UPDATE maintain_field_deal SET sql_string = 'exec spa_staticDataValues ''b'',10101' WHERE field_id = 129







