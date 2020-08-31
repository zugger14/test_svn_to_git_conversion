IF OBJECT_ID(N'[dbo].[spa_get_default_codes]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_get_default_codes]
GO 

-- EXEC spa_get_default_codes
--Gets all default codes 
CREATE PROC [dbo].[spa_get_default_codes]
AS

SELECT  default_code_id Code, 
		dbo.FNAToolTipText(code_def,code_description) Definition, 
		code_description Description
FROM    adiha_default_codes
ORDER BY default_code






