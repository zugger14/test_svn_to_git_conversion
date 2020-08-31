IF OBJECT_ID(N'[dbo].[spa_farrms_product]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_farrms_product]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: msingh@pioneersolutionsglobal.com
-- Create date: 2014-07-14

-- Params:
-- @flag CHAR(1) - Operation flag
-- 'p' List all FARRMS products.

-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_farrms_product]
    @flag CHAR(1)
AS
 
IF @flag = 'p'
BEGIN
	SELECT function_id [Function ID],function_name [Product] FROM application_functions WHERE function_id LIKE '%000000' ORDER BY function_id
END