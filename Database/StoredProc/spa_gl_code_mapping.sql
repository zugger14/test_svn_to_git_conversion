IF OBJECT_ID(N'spa_gl_code_mapping', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_gl_code_mapping]
GO
 
CREATE PROCEDURE [dbo].[spa_gl_code_mapping]
	@flag CHAR(1),
	@account_type_id INT
AS

IF @flag = 's'
BEGIN 
	SELECT column_map_name,
	       *
	FROM   gl_code_mapping_temp t
	WHERE  t.account_type_id = @account_type_id
	ORDER BY sequence_order
	END 
	
ELSE IF @flag = 'a'
BEGIN 
	SELECT gl_account_id, gl_account_description FROM   gl_code_mapping_temp t
	WHERE  t.account_type_id = @account_type_id
	ORDER BY sequence_order 

END 