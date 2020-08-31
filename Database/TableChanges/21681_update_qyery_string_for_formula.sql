UPDATE formula_editor_parameter
SET sql_string = 'EXEC spa_getsourcedealtype @flag = d'
WHERE sql_string = 'EXEC spa_getsourcedealtype @flag = s'

UPDATE formula_editor_parameter
SET sql_string = 'EXEC spa_source_currency_maintain @flag=''e'''
WHERE sql_string = 'EXEC spa_source_currency_maintain @flag=''p'''

