IF OBJECT_ID(N'[dbo].[spa_get_static_value_code]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_get_static_value_code]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: Dewanand Manandhar
-- Create date: 
-- Description: Returning code from table static_data_value.  
 
-- Params:
-- @type_id INT - Type id of which code is needed
--EXEC spa_get_static_value_code 10015
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_get_static_value_code]
    @type_id INT
AS

SELECT value_id, code
FROM static_data_value sdv 
WHERE sdv.[type_id] = @type_id

GO
