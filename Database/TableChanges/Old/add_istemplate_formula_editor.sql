IF NOT EXISTS(SELECT 'x' FROM information_schema.columns WHERE TABLE_NAME ='formula_editor'
 AND COLUMN_NAME = 'istemplate')
ALTER TABLE formula_editor ADD istemplate CHAR(1)