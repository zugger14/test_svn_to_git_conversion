--update generic mapping combo list 'Formula Functions'
UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT fe.formula_id,dbo.FNAFormulaFormatMaxString(fe.formula, ''r'') formula 
FROM formula_editor fe
 WHERE formula IS NOT NULL AND formula LIKE ''%[^0-9]%'''
 WHERE  Field_label = 'Formula Functions'
