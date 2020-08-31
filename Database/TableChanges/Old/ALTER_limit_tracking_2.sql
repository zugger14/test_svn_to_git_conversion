/********************************************************************************************/
/*AUTHOR		:  VISHWAS KHANAL															*/	
/*DATE			:  02.FEB.2009																*/
/*DESCRIPTION   : Columns "actionChecked" and "proceed" added in the table "limit_tracking"	*/
/*PURPOSE		: TRM Demo																	*/
/********************************************************************************************/

IF EXISTS (SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'limit_tracking' AND COLUMN_NAME = 'actionChecked')
BEGIN	
	SELECT 'COLUMN ALREADY EXISTS' AS "INFO"
END
ELSE
BEGIN
	ALTER TABLE limit_tracking ADD actionChecked CHAR(1)
END

GO

IF EXISTS (SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'limit_tracking' AND COLUMN_NAME = 'proceed')
BEGIN	
	SELECT 'COLUMN ALREADY EXISTS' AS "INFO"
END
ELSE
BEGIN
	ALTER TABLE limit_tracking ADD proceed CHAR(1)
END




