/*
	Author : Vishwas Khanal 
	Dated	 : 24.March.2009
	CR		 : 19March2009
	RCN		 : 10
*/
IF EXISTS(SELECT 'x' FROM information_schema.tables WHERE table_name = 'system_formula' and table_schema='dbo')
BEGIN
	DROP TABLE dbo.system_formula
END	
CREATE TABLE dbo.system_formula
(
	sno INT IDENTITY(1,1),
	dealType INT,
	fomulaId INT
)
PRINT 'Table created'


