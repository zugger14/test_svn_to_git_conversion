IF OBJECT_ID('spa_get_date_combo_values') IS NOT NULL
    DROP PROC spa_get_date_combo_values
GO
CREATE PROC spa_get_date_combo_values
@flag char(1)
AS

IF @flag = 'f'
BEGIN
	SELECT 1  AS [value],	'01-January'   AS [key] UNION ALL 
	SELECT 2  AS [value],	'02-February'  AS [key] UNION ALL 
	SELECT 3  AS [value],	'03-March'	   AS [key] UNION ALL 
	SELECT 4  AS [value],	'04-April'	   AS [key] UNION ALL 
	SELECT 5  AS [value],	'05-May'	   AS [key] UNION ALL 
	SELECT 6  AS [value],	'06-June'	   AS [key] UNION ALL 
	SELECT 7  AS [value],	'07-July'	   AS [key] UNION ALL 
	SELECT 8  AS [value],	'08-August'    AS [key] UNION ALL 
	SELECT 9  AS [value],	'09-September' AS [key] UNION ALL 
	SELECT 10 AS [value],	'10-October'   AS [key] UNION ALL 
	SELECT 11 AS [value],	'11-November'  AS [key] UNION ALL 
	SELECT 12 AS [value],	'12-December'  AS [key]
	ORDER BY [value]
END

ELSE IF @flag = 't'
BEGIN
	SELECT 1  AS [value],	'01-January'   AS [key] UNION ALL 
	SELECT 2  AS [value],	'02-February'  AS [key] UNION ALL 
	SELECT 3  AS [value],	'03-March'	   AS [key] UNION ALL 
	SELECT 4  AS [value],	'04-April'	   AS [key] UNION ALL 
	SELECT 5  AS [value],	'05-May'	   AS [key] UNION ALL 
	SELECT 6  AS [value],	'06-June'	   AS [key] UNION ALL 
	SELECT 7  AS [value],	'07-July'	   AS [key] UNION ALL 
	SELECT 8  AS [value],	'08-August'    AS [key] UNION ALL 
	SELECT 9  AS [value],	'09-September' AS [key] UNION ALL 
	SELECT 10 AS [value],	'10-October'   AS [key] UNION ALL 
	SELECT 11 AS [value],	'11-November'  AS [key] UNION ALL 
	SELECT 12 AS [value],	'12-December'  AS [key]
	ORDER BY [value] DESC
END

ELSE IF @flag = 'n'
BEGIN
	SELECT 'c' AS [id], 'Current Year' AS [value] UNION
	SELECT 'n' AS [id], 'Next Year' AS [value]
END
