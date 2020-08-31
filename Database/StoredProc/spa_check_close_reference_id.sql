IF OBJECT_ID(N'[dbo].[spa_check_close_reference_id]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].spa_check_close_reference_id
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: padhikari@pioneersolutionsglobal.com
-- Create date: 2011-06-06
-- Description: CRUD operations for table time_zone
 
-- Params:
-- @flag CHAR(1) - Operation flag
-- ===========================================================================================================
CREATE PROCEDURE [dbo].spa_check_close_reference_id
    @flag CHAR(1),
    @internal_portfolio_id INT,
	@product_id INT 

AS
 
DECLARE @internal_portfolio_name VARCHAR(MAX)
DECLARE @product_id_name VARCHAR(MAX)
 
IF @flag = 's'
BEGIN
	SELECT @product_id_name = sdv.code 
	FROM static_data_value sdv
	INNER JOIN static_data_type sdt ON sdt.[type_id] = sdv.[type_id]
	WHERE sdv.value_id = @product_id
   
--	SELECT * FROM 	
	SELECT @internal_portfolio_name = sip.internal_portfolio_name FROM source_internal_portfolio sip
	WHERE sip.source_internal_portfolio_id = @internal_portfolio_id
	
	SELECT  @internal_portfolio_name, @product_id_name
END
