IF OBJECT_ID(N'[dbo].[spa_transfer_mapping]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_transfer_mapping]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===============================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2008-09-09
-- Description: Description of the functionality in brief.
 
-- Params:
-- @flag CHAR(1)        - Description of param2
-- @param1 VARCHAR(100) - Description of param3
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[spa_transfer_mapping]
    @flag CHAR(1)
    , @mapping_id INT = NULL
    , @mapping_name VARCHAR(200) = NULL
    , @xml XML = NULL
    , @deal_date DATETIME = NULL
	, @sub_book INT = NULL
	, @tr_sub_book INT = NULL
	, @counterparty_id INT = NULL
	, @transfer_type VARCHAR(100) = NULL
AS
SET NOCOUNT ON

DECLARE @sql        VARCHAR(MAX),
        @desc       VARCHAR(500),
        @err_no     INT
 
IF @flag = 's'
BEGIN
    SELECT tm.transfer_mapping_id,
           tm.transfer_mapping_name
    FROM transfer_mapping tm
    ORDER BY tm.transfer_mapping_name 
END

IF @flag= 'c'
BEGIN
SELECT 'xfer_with_offset' [id], 'Xfer with Offset' [value] UNION ALL
SELECT 'only_offset', 'Offset only' UNION ALL
SELECT 'without_offset', 'Xfer only'
END

IF @flag = 't'
BEGIN
	SELECT ISNULL(transfer_type, '') transfer_type
	FROM transfer_mapping
	WHERE transfer_mapping_id = @mapping_id
	RETURN
END

--select * from transfer_mapping

IF @flag = 'i'
BEGIN
	BEGIN TRY
	BEGIN TRAN
		IF @xml IS NOT NULL
		BEGIN
			DECLARE @user_name VARCHAR(100) = dbo.FNADBUser()
			DECLARE @process_id VARCHAR(200) = dbo.FNAGetNewId()
			DECLARE @mapping_process_table VARCHAR(300) = dbo.FNAProcessTableName('mapping_process_table', @user_name, @process_id)
		
			EXEC spa_parse_xml_file 'b', NULL, @xml, @mapping_process_table
		
			IF @mapping_id IS NULL
			BEGIN
				INSERT INTO transfer_mapping (transfer_mapping_name, transfer_type)
					SELECT @mapping_name
					, @transfer_type

				SET @mapping_id = SCOPE_IDENTITY()
			END
			ELSE
			BEGIN
					UPDATE transfer_mapping
					SET transfer_mapping_name = @mapping_name
						, transfer_type = @transfer_type
					WHERE transfer_mapping_id = @mapping_id
				END
		
			DELETE FROM transfer_mapping_detail WHERE transfer_mapping_id = @mapping_id

			--select * from transfer_mapping_detail
		
			SET @sql = 'INSERT INTO transfer_mapping_detail (transfer_mapping_id
				, transfer_counterparty_id
				, transfer_contract_id
				, transfer_trader_id
				, transfer_sub_book
				, transfer_template_id
				, counterparty_id
				, contract_id
				, trader_id
				, sub_book
				, template_id
				, location_id
				, transfer_volume
				, volume_per
				, pricing_options
				, fixed_price
				, transfer_date
				, index_adder
				, fixed_adder

				)

				
				SELECT '
				 + CAST(@mapping_id AS VARCHAR(20)) 
				 + ', NULLIF(transfer_counterparty_id, 0)
				 , NULLIF(transfer_contract_id,0)
				 , NULLIF(transfer_trader_id, 0)
				 , NULLIF(transfer_sub_book, 0)
				 , NULLIF(transfer_template_id, 0)
				 , NULLIF(counterparty_id, 0)
				 , NULLIF(contract_id, 0)
				 , NULLIF(trader_id, 0)
				 , NULLIF(sub_book, 0)
				 , NULLIF(template_id, 0)
				 , location_id
				 , NULLIF(CONVERT(FLOAT, transfer_volume), 0)				 
				 , NULLIF(CONVERT(FLOAT, volume_per), 0)
				 , pricing_options
				 , NULLIF(fixed_price,0)
				 , transfer_date
				 , NULLIF(index_adder,0)
				 , NULLIF(fixed_adder,0)
				FROM ' + @mapping_process_table  
				--WHERE NULLIF(counterparty_id, 0) IS NOT NULL 
				--AND NULLIF(contract_id, 0) IS NOT NULL
				--AND NULLIF(transfer_counterparty_id, 0) IS NOT NULL
				--AND NULLIF(transfer_contract_id, 0) IS NOT NULL'
			
			--print @sql				
			EXEC(@sql)		
			
			EXEC('DROP TABLE ' + @mapping_process_table)
		END
		
		COMMIT
		EXEC spa_ErrorHandler 0
				, 'spa_transfer_mapping'
				, 'spa_transfer_mapping'
				, 'Success' 
				, 'Changes have been saved successfully'
				, ''
			
	END TRY
	BEGIN CATCH 
		IF @@TRANCOUNT > 0
		   ROLLBACK
 
		SET @desc = 'Errr Description:' + ERROR_MESSAGE() + '.'
 
		SELECT @err_no = ERROR_NUMBER()
 
		EXEC spa_ErrorHandler @err_no
		   , 'spa_transfer_mapping'
		   , 'spa_transfer_mapping'
		   , 'Error'
		   , @desc
		   , ''
	END CATCH
END

IF @flag = 'r'
BEGIN
	SELECT 
		   tmd.transfer_counterparty_id
	       , tmd.transfer_contract_id
	       , tmd.transfer_trader_id
	       , tmd.transfer_sub_book
		   , tmd.transfer_template_id
		   , tmd.counterparty_id
	       , tmd.contract_id
	       , tmd.trader_id
	       , tmd.sub_book
		   , tmd.template_id
	       , tmd.location_id [location_id]
	       , tmd.transfer_volume [transfer_volume]
	       , tmd.volume_per [volume_per]
	       , tmd.pricing_options [pricing_options]
	       , tmd.fixed_price [fixed_price]
	       , @deal_date [transfer_date]
		   , tmd.index_adder [index_adder]
		   , tmd.fixed_adder [fixed_adder]
	FROM transfer_mapping_detail tmd
	--WHERE tmd.transfer_mapping_id = 12
	WHERE tmd.transfer_mapping_id = @mapping_id
END

IF @flag = 'd'
BEGIN
	BEGIN TRY
	BEGIN TRAN		
		DELETE FROM transfer_mapping_detail WHERE transfer_mapping_id = @mapping_id
		DELETE FROM transfer_mapping WHERE transfer_mapping_id = @mapping_id
		
		COMMIT
		EXEC spa_ErrorHandler 0
				, 'spa_transfer_mapping'
				, 'spa_transfer_mapping'
				, 'Success' 
				, 'Changes have been saved successfully'
				, ''
			
	END TRY
	BEGIN CATCH 
		IF @@TRANCOUNT > 0
		   ROLLBACK
 
		SET @desc = 'Failed to delete mapping:' + ERROR_MESSAGE() + '.'
 
		SELECT @err_no = ERROR_NUMBER()
 
		EXEC spa_ErrorHandler @err_no
		   , 'spa_transfer_mapping'
		   , 'spa_transfer_mapping'
		   , 'Error'
		   , @desc
		   , ''
	END CATCH
END

IF @flag = 'g'
BEGIN
	SELECT COALESCE(ssbm.primary_counterparty_id,fb.primary_counterparty_id,fs_st.primary_counterparty_id,fs.counterparty_id) [counterparty_id], cca1.contract_id [contract_id]
	FROM source_system_book_map  ssbm
	INNER JOIN fas_books fb 
		ON fb.fas_book_id = ssbm.fas_book_id
	INNER JOIN portfolio_hierarchy ph_book 
		ON ph_book.[entity_id] = fb.fas_book_id
	INNER JOIN portfolio_hierarchy ph_st 
		ON ph_st.[entity_id] = ph_book.parent_entity_id
	INNER JOIN portfolio_hierarchy ph_sub 
		ON ph_sub.[entity_id] = ph_st.parent_entity_id
	INNER JOIN fas_subsidiaries fs 
		ON ph_sub.[entity_id] = fs.fas_subsidiary_id
	INNER JOIN fas_strategy fs_st 
		ON ph_st.[entity_id] = fs_st.fas_strategy_id
	OUTER APPLY (
		SELECT MAX(contract_id) contract_id
		FROM counterparty_contract_address cca
		WHERE cca.counterparty_id = COALESCE(ssbm.primary_counterparty_id,fb.primary_counterparty_id,fs_st.primary_counterparty_id,fs.counterparty_id)
	) cca1
	WHERE ssbm.book_deal_type_map_id = @sub_book
END

IF @flag = 'k'
BEGIN
	SELECT MAX(contract_id) contract_id
	FROM counterparty_contract_address cca
	WHERE cca.counterparty_id = @counterparty_id
END
