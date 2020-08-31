/* Poojan Shrestha || 24.March.2009 */
/* Description : Add formula_name and system_defined columns to formula_editor */
if not exists (select 'x' from information_schema.columns where table_name='formula_editor' and column_name='formula_name')
	ALTER TABLE dbo.formula_editor ADD formula_name varchar(200) NULL
GO

if not exists (select 'x' from information_schema.columns where table_name='formula_editor' and column_name='system_defined')
	ALTER TABLE dbo.formula_editor ADD system_defined char(1) NULL
GO