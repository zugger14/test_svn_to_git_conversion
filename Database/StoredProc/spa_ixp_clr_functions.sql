IF OBJECT_ID(N'[dbo].[spa_ixp_clr_functions]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_ixp_clr_functions]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===============================================================================================================
-- Author: Dewanand Manandhar
-- Create date: 2017-11-13
-- Description: Different operations using table ixp_clr_functions.
 
-- Params:
-- @flag CHAR(1)        - Operational flag 
--						- 's' - select, 
--						

-- =============================================================================================================== 
CREATE PROCEDURE [dbo].[spa_ixp_clr_functions]
    @flag CHAR(1),
	@rules_id INT = NULL
    
AS
SET NOCOUNT ON

IF @flag = 's'
BEGIN
    SELECT NULLIF('', '') ixp_clr_functions_id , ' ' ixp_clr_functions_name UNION ALL SELECT ixp_clr_functions_id,
           ixp_clr_functions_name
    FROM   ixp_clr_functions 
END
ELSE IF @flag = 'm'
BEGIN
	SELECT method_name
	FROM ixp_clr_functions icf
	INNER JOIN ixp_import_data_source iids
		ON icf.ixp_clr_functions_id = iids.clr_function_id
	WHERE iids.rules_id = @rules_id
END










