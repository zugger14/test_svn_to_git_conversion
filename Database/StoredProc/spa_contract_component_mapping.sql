IF OBJECT_ID(N'[dbo].[spa_contract_component_mapping]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_contract_component_mapping]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO


-- ===========================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2012-08-22
-- Description: CRUD operations for table contract_component_mapping
 
-- Params:
-- @flag CHAR(1) - Operation flag
-- @contract_component_mapping_id - INT - Identity value of table contract_component_mapping
-- @contract_component_id - INT - Contract Component Id
-- @deal_type_id - INT - Deal type id
-- @charge_type_id - INT - charge type id
-- @multiplier - FLOAT - Multiplier value - default 1
-- @rounding - INT - rounding value
-- @leg - INT - leg
-- @book_identifier4 - INT - book  identifier 4
-- @time_of_use - INT - time of use
-- @show_volume - CHAR(1) - ahow volume - expected value y or n
-- ===========================================================================================================

--EXEC spa_contract_component_mapping 'i',1,303218,NULL,-5500
--SELECT * FROM contract_component_mapping
Create PROCEDURE [dbo].[spa_contract_component_mapping]
    @flag CHAR(1) = NULL,
    @contract_component_mapping_id INT = NULL,
    @xml TEXT = NULL,
    @contract_component_id INT = NULL,
    @deal_type_id INT = NULL,
    @charge_type_id INT = NULL,
    @multiplier FLOAT = NULl,
    @rounding INT = NULL,
    @leg INT = NULL,
    @book_identifier1 INT = NULL,
    @book_identifier2 INT = NULL,
    @book_identifier3 INT = NULL,
    @book_identifier4 INT = NULL,
    @time_of_use INT = NULL,
    @show_volume CHAR(1) = NULL,
    @formula_id INT = NULL
AS
 
DECLARE @desc    VARCHAR(500)
DECLARE @sql     VARCHAR(MAX)
DECLARE @err_no  INT

IF @multiplier IS NULL
SET @multiplier = 1

SET NOCOUNT ON 
 
IF @flag = 's'
BEGIN
    SET @sql = 'SELECT ccm.contract_component_mapping_id [ID],
					   contract_component_id.code [Contract Component],
					   sdt.source_deal_type_name [Deal Type],
					   charge_type_id.code [Charge Type],
					   ccm.multiplier [Multiplier],
					   ccm.rounding [Rounding],
					   ccm.leg [Leg],
					   ISNULL(sb1.source_book_name, '''') + ''|'' + ISNULL(sb2.source_book_name, '''') + ''|'' + ISNULL(sb3.source_book_name, '''') + ''|'' + ISNULL(sb4.source_book_name, '''') [Book Identifiers],
					   tou.code [Time of Use],
					   ccm.show_volume [Show Volume]
					  
					   
				FROM   contract_component_mapping ccm
					   LEFT JOIN static_data_value contract_component_id
							ON  contract_component_id.value_id = ccm.contract_component_id
							AND contract_component_id.[type_id] = 10019
					   LEFT JOIN static_data_value charge_type_id
							ON  charge_type_id.value_id = ccm.charge_type_id
							AND charge_type_id.[type_id] = 5500
						LEFT JOIN static_data_value tou ON tou.value_id = ccm.time_of_use AND tou.type_id = 18900
					   LEFT JOIN source_deal_type sdt ON  sdt.source_deal_type_id = ccm.deal_type_id
					   LEFT JOIN source_book sb1 ON sb1.source_book_id = ccm.book_identifier1
					   LEFT JOIN source_book sb2 ON sb2.source_book_id = ccm.book_identifier2
					   LEFT JOIN source_book sb3 ON sb3.source_book_id = ccm.book_identifier3
					   LEFT JOIN source_book sb4 ON sb4.source_book_id = ccm.book_identifier4
				WHERE 1 = 1'
	IF @contract_component_id IS NOT NULL
	BEGIN
		SET @sql = @sql + ' AND ccm.contract_component_id = ' + CAST(@contract_component_id AS VARCHAR(30))
	END					    
    
   -- exec spa_print @sql 
    EXEC(@sql)         
END

ELSE IF @flag = 'a'
BEGIN
    SELECT ccm.contract_component_mapping_id,
           ccm.contract_component_id,
           ccm.deal_type_id,
           ccm.charge_type_id,
           ccm.multiplier,
           ccm.rounding,
           ccm.leg,
           ccm.book_identifier1,
           ccm.book_identifier2,
           ccm.book_identifier3,
           ccm.book_identifier4,
           ccm.time_of_use,
           ccm.show_volume,
		   ccm.formula_id,
		   dbo.FNAFormulaFormat(fe.formula,'r') formula_text
          
    FROM   contract_component_mapping ccm
           LEFT JOIN static_data_value contract_component_id
                ON  contract_component_id.value_id = ccm.contract_component_id
                AND contract_component_id.[type_id] = 10019
           LEFT JOIN static_data_value charge_type_id
                ON  charge_type_id.value_id = ccm.charge_type_id
                AND charge_type_id.[type_id] = 5500
           LEFT JOIN source_deal_type sdt ON  sdt.source_deal_type_id = ccm.deal_type_id
		   LEFT JOIN formula_editor fe ON fe.formula_id = ccm.formula_id
    WHERE ccm.contract_component_mapping_id = @contract_component_mapping_id
END

ELSE IF @flag = 'i'
BEGIN
	IF EXISTS(select * FROM contract_component_mapping WHERE contract_component_id = @contract_component_id AND charge_type_id = @charge_type_id)
			BEGIN
				EXEC spa_ErrorHandler -1
				, ''
				, 'spa_customer_details'
				, 'DB Error'
				, 'Contract with that name already Exist'
				, ''
   RETURN
			END
	ELSE
	BEGIN TRY
		INSERT INTO contract_component_mapping (
    		contract_component_id,
    		deal_type_id,
    		charge_type_id,
    		multiplier,
    		rounding,
    		leg,
    		time_of_use,
    		book_identifier1,
    		book_identifier2,
    		book_identifier3,
    		book_identifier4,
    		show_volume,
    		formula_id
		)
		VALUES (
    		@contract_component_id,
    		@deal_type_id,
    		@charge_type_id,
    		@multiplier,
    		@rounding,
    		@leg,
    		@time_of_use,
    		@book_identifier1,
    		@book_identifier2,
    		@book_identifier3,
    		@book_identifier4,
    		@show_volume,
    		@formula_id
		)
	
		    		
		EXEC spa_ErrorHandler 0,
		     'contract_component_mapping',
		     'spa_contract_component_mapping',
		     'Success',
		     'Data saved successfully.',
		     ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		    ROLLBACK
		    
		  
		
		IF ERROR_MESSAGE() = 'CatchError'
		    SET @desc = 'Fail to insert Data ( Errr Description:' + @desc + ').'
		ELSE
		    SET @desc = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'
		
		SELECT @err_no = ERROR_NUMBER()
		
		EXEC spa_ErrorHandler @err_no,
		     'contract_component_mapping',
		     'spa_contract_component_mapping',
		     'Error',
		     @desc,
		     ''
	END CATCH
END
 
ELSE IF @flag = 'u'
BEGIN
	BEGIN TRY
		UPDATE contract_component_mapping
		SET contract_component_id = @contract_component_id,
    		deal_type_id = @deal_type_id,
    		charge_type_id = @charge_type_id,
    		multiplier = @multiplier,
    		rounding = @rounding,
    		leg = @leg,
    		time_of_use = @time_of_use,
    		book_identifier1 = @book_identifier1,
    		book_identifier2 = @book_identifier2,
    		book_identifier3 = @book_identifier3,
    		book_identifier4 = @book_identifier4,
    		show_volume = @show_volume,
    		formula_id = @formula_id
		WHERE contract_component_mapping_id = @contract_component_mapping_id
				
		EXEC spa_ErrorHandler 0,
		     'contract_component_mapping',
		     'spa_contract_component_mapping',
		     'Success',
		     ' Updated Data successfully.',
		     ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		    ROLLBACK
		
		IF ERROR_MESSAGE() = 'CatchError'
		    SET @desc = 'Fail to update Data ( Errr Description:' + @desc + ').'
		ELSE
		    SET @desc = 'Fail to update Data ( Errr Description:' + ERROR_MESSAGE() + ').'
		
		SELECT @err_no = ERROR_NUMBER()
		
		EXEC spa_ErrorHandler @err_no,
		     'contract_component_mapping',
		     'spa_contract_component_mapping',
		     'Error',
		     @desc,
		     ''
	END CATCH
END

ELSE IF @flag = 'd'
BEGIN

	BEGIN TRY
		DELETE FROM contract_component_mapping WHERE contract_component_mapping_id = @contract_component_mapping_id
		
		EXEC spa_ErrorHandler 0,
		     'contract_component_mapping',
		     'spa_contract_component_mapping',
		     'Success',
		     'Successfully deleted data.',
		     ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		    ROLLBACK
		
		IF ERROR_MESSAGE() = 'CatchError'
		    SET @desc = 'Fail to delete Data ( Errr Description:' + @desc + ').'
		ELSE
		    SET @desc = 'Fail to delete Data ( Errr Description:' + ERROR_MESSAGE() + ').'
		
		SELECT @err_no = ERROR_NUMBER()
		
		EXEC spa_ErrorHandler @err_no,
		     'contract_component_mapping',
		     'spa_contract_component_mapping',
		     'Error',
		     @desc,
		     ''
	END CATCH
END

ELSE IF @flag = 'b' -- select the contract componnent to be displayed in the drop down in contrcat charge type detail
BEGIN
	SELECT DISTINCT contract_component_id,sdv.code
	FROM
		contract_component_mapping ccm
		INNER JOIN static_data_value sdv ON sdv.value_id = ccm.contract_component_id
		order by sdv.code
END

ELSE IF @flag = 'c'
BEGIN
   
    SET @sql = 'SELECT ccm.contract_component_mapping_id, sdv.code [contract],sdvc.code [charge]  FROM contract_component_mapping ccm 
				INNER JOIN static_data_value sdv ON ccm.contract_component_id = sdv.value_id
				INNER JOIN static_data_value sdvc ON ccm.charge_type_id = sdvc.value_id
                ORDER BY contract ASC'
				
				
    EXEC(@sql)         
END

ELSE IF @flag = 'e' -- select deal type
BEGIN
	SET @sql = 'SELECT source_deal_type_id [Deal ID],source_deal_type_name from source_deal_type '
		


	EXEC(@sql)
	
END


ELSE IF @flag = 'f' -- select rounding by value
BEGIN
	SET @sql = 'SELECT 1 code, 1 name UNION ALL SELECT 2, 2 UNION ALL SELECT 3, 3 UNION ALL SELECT 4,4 UNION ALL SELECT 5, 5 UNION ALL SELECT 6, 6'
		


	EXEC(@sql)
	
END



