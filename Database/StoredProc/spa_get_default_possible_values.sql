IF OBJECT_ID(N'[dbo].[spa_get_default_possible_values]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_get_default_possible_values]
GO 




--Gets all possible values for a default code
-- EXEC spa_get_default_possible_values 19
CREATE PROC [dbo].[spa_get_default_possible_values] 
	@default_code_id INT
AS

SELECT     default_code_id AS Code, dbo.FNAToolTipText(var_value,description) AS Value, description AS Description
FROM         adiha_default_codes_values_possible
WHERE     (default_code_id = @default_code_id)
ORDER BY Value






