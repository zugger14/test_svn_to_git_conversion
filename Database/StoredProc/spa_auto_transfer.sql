IF OBJECT_ID(N'[dbo].[spa_auto_transfer]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_auto_transfer]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===============================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2008-09-09
-- ===============================================================================================================

 /**
	Procedure that is used to generate xml with information required for transfering deal

	Parameters:
	@source_deal_header_id : Deal ids supplied in CSV format
*/

CREATE PROCEDURE [dbo].[spa_auto_transfer] 
	@source_deal_header_id NVARCHAR(MAX) = NULL
AS

/*-------------------Debug Section--------------------
DECLARE @source_deal_header_id NVARCHAR(MAX) = NULL

SELECT @source_deal_header_id = '249958,249959,249960'
-----------------------------------------------------*/
DECLARE @SQL NVARCHAR(MAX)
BEGIN TRY
	IF EXISTS(
		SELECT 1 
		FROM source_deal_header sdh
		INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id 
		INNER JOIN dbo.SplitCommaSeperatedValues(@source_deal_header_id) i ON sdh.source_deal_header_id = i.item
		INNER JOIN deal_transfer_mapping dtm 
			ON (dtm.counterparty_id_from = sdh.counterparty_id or dtm.counterparty_id_from IS NULL)
			AND dtm.source_book_mapping_id_from = sdh.sub_book 
			AND (dtm.counterparty_id_to = sdh.internal_counterparty OR dtm.counterparty_id_to IS NULL)
			AND (dtm.contract_id_from = sdh.contract_id OR dtm.contract_id_from IS NULL)
			AND (dtm.trader_id_from = sdh.trader_id OR dtm.trader_id_from IS NULL)
			AND (dtm.source_deal_type_id = sdh.source_deal_type_id OR dtm.source_deal_type_id IS NULL)
			AND (dtm.template_id = sdh.template_id OR dtm.template_id IS NULL)
			AND (dtm.location_id = sdd.location_id OR dtm.location_id IS NULL)
			AND (dtm.pricing_type = sdh.pricing_type OR dtm.pricing_type IS NULL)
			AND (dtm.commodity_id = sdh.commodity_id OR dtm.commodity_id IS NULL)
			AND (dtm.header_buy_sell_flag = sdh.header_buy_sell_flag OR dtm.header_buy_sell_flag IS NULL)
			AND (dtm.physical_financial_flag = sdh.physical_financial_flag OR dtm.physical_financial_flag IS NULL)
	)
	BEGIN 	
		DECLARE @val_source_deal_header_id NVARCHAR(100),
				@val_transfer_without_offset NVARCHAR(100),
				@val_transfer_only_offset NVARCHAR(100),
				@val_book_map_id NVARCHAR(100),
				@val_book_map_id_offset NVARCHAR(100),
				@val_contract_to NVARCHAR(100),
				@val_trader_to NVARCHAR(100),
				@deal_transfer_mapping_id NVARCHAR(2000),
				@val_fixed NVARCHAR(100),
				@val_xm NVARCHAR(MAX),
				@val_transfer_type NVARCHAR(100),
				@val_counterparty_to NVARCHAR(100),
				@val_fixed_adder NVARCHAR(100),
				@val_location_id NVARCHAR(100),
				@val_total_volume NVARCHAR(MAX),
				@val_index_adder NVARCHAR(100),
				@transfer_type NVARCHAR(100),
				@val_transfer_counterparty_id NVARCHAR(100),
				@val_transfer_contract_id NVARCHAR(100),
				@counterparty_id_to NVARCHAR(100),
				@transfer_template_id NVARCHAR(100)
			
		IF OBJECT_ID ('tempdb..#transfer_mapping_ids') IS NOT NULL
			DROP TABLE #transfer_mapping_ids

		SELECT sdh.source_deal_header_id, dtm.deal_transfer_mapping_id
		INTO #transfer_mapping_ids
		FROM source_deal_header sdh
		INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
		INNER JOIN dbo.SplitCommaSeperatedValues(@source_deal_header_id) i ON sdh.source_deal_header_id = i.item
		INNER JOIN deal_transfer_mapping dtm 
			ON (dtm.counterparty_id_from = sdh.counterparty_id or dtm.counterparty_id_from IS NULL)
			AND dtm.source_book_mapping_id_from = sdh.sub_book 
			AND (dtm.counterparty_id_to = sdh.internal_counterparty OR dtm.counterparty_id_to IS NULL)
			AND (dtm.contract_id_from = sdh.contract_id OR dtm.contract_id_from IS NULL)
			AND (dtm.trader_id_from = sdh.trader_id OR dtm.trader_id_from IS NULL)
			AND (dtm.source_deal_type_id = sdh.source_deal_type_id OR dtm.source_deal_type_id IS NULL)
			AND (dtm.template_id = sdh.template_id OR dtm.template_id IS NULL)
			AND (dtm.location_id = sdd.location_id OR dtm.location_id IS NULL)
			AND (dtm.pricing_type = sdh.pricing_type OR dtm.pricing_type IS NULL)
			AND (dtm.commodity_id = sdh.commodity_id OR dtm.commodity_id IS NULL)
			AND (dtm.internal_portfolio_id = sdh.internal_portfolio_id OR dtm.internal_portfolio_id IS NULL)
			AND (dtm.header_buy_sell_flag = sdh.header_buy_sell_flag OR dtm.header_buy_sell_flag IS NULL)
			AND (dtm.physical_financial_flag = sdh.physical_financial_flag OR dtm.physical_financial_flag IS NULL)
		GROUP BY sdh.source_deal_header_id, dtm.deal_transfer_mapping_id
			
		IF OBJECT_ID ('tempdb..#to_criteria') IS NOT NULL
			DROP TABLE #to_criteria

		SELECT val_book_map_id = dtmd.transfer_sub_book,
				val_trader_to = dtmd.transfer_trader_id,
				val_fixed = dtmd.fixed_price,
				transfer_type = dtm.[transfer],
				val_transfer_type = dtmd.pricing_options,
				val_fixed_adder = NULLIF(dtmd.fixed_adder, ''),
				val_index_adder = NULLIF(dtmd.index_adder, ''),
				val_transfer_counterparty_id = dtmd.transfer_counterparty_id,
				val_transfer_contract_id = dtmd.transfer_contract_id,
				counterparty_id_to = dtm.counterparty_id_to,
				transfer_template_id = dtmd.transfer_template_id
		INTO #to_criteria
		FROM deal_transfer_mapping dtm 
		INNER JOIN deal_transfer_mapping_detail dtmd
			ON dtmd.deal_transfer_mapping_id = dtm.deal_transfer_mapping_id
		INNER JOIN #transfer_mapping_ids t ON dtm.deal_transfer_mapping_id = t.deal_transfer_mapping_id 
		
		IF OBJECT_ID ('tempdb..#original_deal') IS NOT NULL
			DROP TABLE #original_deal

		SELECT val_source_deal_header_id = sdh.source_deal_header_id, 
				val_book_map_id_offset = sdh.sub_book, 
				val_contract_to = sdh.contract_id,
				val_counterparty_to = sdh.counterparty_id,
				val_location_id = sdd.location_id,
				val_total_volume = sdd.total_volume
		INTO #original_deal
		FROM source_deal_header sdh
		INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
		INNER JOIN dbo.SplitCommaSeperatedValues(@source_deal_header_id) d ON sdh.source_deal_header_id = d.item
			
		IF EXISTS (SELECT 1 FROM #to_criteria WHERE val_transfer_type = 'd') -- Original price
		BEGIN
			SET @val_fixed = NULL
			SET @val_index_adder = NULL
		END

		IF EXISTS (SELECT 1 FROM #to_criteria WHERE val_transfer_type = 'm') -- Market Price
		BEGIN
			SET @val_fixed = NULL
			SELECT @val_index_adder = val_index_adder FROM #to_criteria
		END

		IF EXISTS (SELECT 1 FROM #to_criteria WHERE val_transfer_type = 'x') -- Fixed price
		BEGIN
			SET @val_index_adder = NULL
		END

		IF EXISTS (SELECT 1 FROM #to_criteria WHERE transfer_type = 'o') -- offset only
		BEGIN
			SET @val_transfer_without_offset = '0'
			SET @val_transfer_only_offset = '1'
		END
		ELSE IF EXISTS (SELECT 1 FROM #to_criteria WHERE transfer_type = 'b')-- offset with xfer
		BEGIN
			SET @val_transfer_without_offset = '0'
			SET @val_transfer_only_offset = '0'
		END
		ELSE IF EXISTS (SELECT 1 FROM #to_criteria WHERE transfer_type = 'x') -- xfer only
		BEGIN
			SET @val_transfer_without_offset = '1'
			SET @val_transfer_only_offset = '0'
			SELECT @val_book_map_id_offset = @val_book_map_id
		END

		IF OBJECT_ID('tempdb..#temp_deal_data') IS NOT NULL
				DROP TABLE #temp_deal_data

		SELECT sdh.trader_id
			    ,sdh.contract_id
				,sdh.template_id
				,ssbm.primary_counterparty_id
				,sdh.counterparty_id
				,sdh.source_deal_header_id
		INTO #temp_deal_data
		FROM source_deal_header sdh
		INNER JOIN source_system_book_map ssbm
			ON ssbm.book_deal_type_map_id = sdh.sub_book
		INNER JOIN dbo.SplitCommaSeperatedValues(@source_deal_header_id) d 
			ON sdh.source_deal_header_id = d.item
			
		SELECT @val_xm = CAST((SELECT t1.source_deal_header_id AS [@source_deal_header_id],
					ISNULL(@val_transfer_without_offset, 0) AS [@transfer_without_offset],
					ISNULL(@val_transfer_only_offset, 0) AS [@transfer_only_offset],
					@val_fixed_adder AS [@price_adder],
					@val_index_adder AS [@formula_curve_id],					
					(SELECT COALESCE(dtmd.counterparty_id,ssbm.primary_counterparty_id,deal_data.primary_counterparty_id,deal_data.counterparty_id) AS [@counterparty_id],
							COALESCE(dtmd.contract_id,deal_data.contract_id) AS [@contract_id],
							COALESCE(dtmd.trader_id,deal_data.trader_id) AS [@trader_id],
							dtmd.sub_book AS [@sub_book],
							COALESCE(dtmd.template_id,deal_data.template_id) AS [@template_id],
							dtmd.location_id AS [@location_id],
							dtmd.transfer_volume AS [@transfer_volume],
							CAST(dtmd.volume_per AS NVARCHAR(10)) AS [@volume_per],
							dtmd.pricing_options AS [@pricing_options],
							CAST(dtmd.fixed_price AS NVARCHAR(10)) AS [@fixed_price],
							CONVERT(NVARCHAR(10), dtmd.transfer_date, 120) AS [@transfer_date],
							COALESCE(dtmd.transfer_counterparty_id,ssbm_transfer.primary_counterparty_id,deal_data.counterparty_id) AS [@transfer_counterparty_id],
							COALESCE(dtmd.transfer_contract_id,deal_data.contract_id) AS [@transfer_contract_id],
							COALESCE(dtmd.transfer_trader_id,deal_data.trader_id) AS [@transfer_trader_id],
							dtmd.transfer_sub_book AS [@transfer_sub_book],
							COALESCE(dtmd.transfer_template_id,deal_data.template_id) AS [@transfer_template_id],
							dtmd.fixed_adder AS [@fixed_adder],
							@val_index_adder AS [@index_adder]
					FROM deal_transfer_mapping dtm
					INNER JOIN deal_transfer_mapping_detail dtmd
						ON dtmd.deal_transfer_mapping_id = dtm.deal_transfer_mapping_id
					INNER JOIN #transfer_mapping_ids t ON dtm.deal_transfer_mapping_id = t.deal_transfer_mapping_id
					LEFT JOIN source_system_book_map ssbm
						ON ssbm.book_deal_type_map_id = dtmd.transfer_sub_book
					LEFT JOIN source_system_book_map ssbm_transfer
						ON ssbm_transfer.book_deal_type_map_id = dtmd.sub_book
					INNER JOIN #temp_deal_data deal_data
						ON deal_data.source_deal_header_id = t1.source_deal_header_id
					WHERE t.source_deal_header_id = t1.source_deal_header_id
					FOR XML PATH ('GridRow'), TYPE
					)
			FROM #transfer_mapping_ids t1
			FOR XML PATH ('GridHeader'), ROOT ('GridXML')
		) AS NVARCHAR(MAX))
		DECLARE @transfer_volume NVARCHAR(100)
		DECLARE @user_login_id NVARCHAR(100) = dbo.FNADBUser();
		DECLARE @desc1 NVARCHAR(200) = 'The shaped deal(' + CAST(@source_deal_header_id AS VARCHAR) + ') cannot be transferred. Please setup Volume % in transfer rule OR transfer the deal manually.';

		SELECT @transfer_volume = NULLIF(transfer_volume, 0)
		FROM deal_transfer_mapping dtm
		INNER JOIN deal_transfer_mapping_detail dtmd
			ON dtmd.deal_transfer_mapping_id = dtm.deal_transfer_mapping_id
		WHERE dtm.deal_transfer_mapping_id = @deal_transfer_mapping_id

		IF EXISTS (SELECT 1 FROM source_deal_header WHERE source_deal_header_id = @source_deal_header_id AND internal_desk_id IN (17301, 17302) AND @transfer_volume IS NOT NULL)
		BEGIN
			EXEC spa_message_board 'i', @user_login_id, NULL, 'Transfer Deal', @desc1, '',  '', '', 'Transfer Deal', NULL, ''
		RETURN
		END
			
		EXEC spa_deal_transfer @flag='t', @source_deal_header_id = @source_deal_header_id, @xml= @val_xm
	END
END TRY
BEGIN CATCH
	DECLARE @desc NVARCHAR(500), @err_no INT
 
	SELECT @err_no = ERROR_NUMBER()
 
	SET @desc = 'Fail to transfer deal ( Errr Description:' + ERROR_MESSAGE() + ').'
  
	EXEC spa_ErrorHandler @err_no, 'spa_auto_transfer', 'spa_auto_transfer', 'Error', @desc, ''
END CATCH
