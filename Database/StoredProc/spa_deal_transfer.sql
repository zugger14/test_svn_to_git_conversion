IF OBJECT_ID(N'[dbo].[spa_deal_transfer]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_deal_transfer]
GO
 
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
 

/**
	Used to transfer a deal from one Subbook to another Subbook. Another Offset deal is also created along with Transferred deal with negative amount to cancel out original deal.

	Parameters:
		@flag						:	Operation flag that decides the action to be performed.
		@source_deal_header_id		:	Identifier of Deal that is to be transferred.
		@transfer_without_offset	:	Transfer the deal to another subbook without creating offset deal.
		@transfer_only_offset		:	Transfer only the offset deal, do not create transferred deal.
		@xml						:	Values required to create transferred deal built in XML format.
		@price_adder				:	Not in Use.
		@formula_curve_id			:	Not in Use.
		@est_movement_date			:	Estimated date of transferring the deal.
		@transfer_price_process_id	:	Unique identifier to create process table for storing pricing data.
		@transfer_provisional_price_process_id	:	Unique identifier to create process table for storing provisional pricing data.
*/

CREATE PROCEDURE [dbo].[spa_deal_transfer]
	@flag CHAR(1),
	@source_deal_header_id NVARCHAR(MAX) = NULL,
	@xml XML = NULL,
	@transfer_price_process_id NVARCHAR(100) = NULL,
	@transfer_provisional_price_process_id NVARCHAR(100) = NULL
AS

/*------------Debug Section----------------------
DECLARE @flag CHAR(1),
		@source_deal_header_id NVARCHAR(MAX),
		@transfer_without_offset BIT = 0,
		@transfer_only_offset BIT = 0,
		@xml XML = NULL,
		@price_adder FLOAT = NULL,
		@formula_curve_id INT = NULL,
		@est_movement_date DATETIME = NULL,
		@transfer_price_process_id NVARCHAR(100) = NULL,
		@transfer_provisional_price_process_id NVARCHAR(100) = NULL

SELECT @flag='t',@source_deal_header_id='219948',
@xml='<GridXML><GridHeader source_deal_header_id="219948" transfer_without_offset="0" transfer_only_offset="0"><GridRow  transfer_counterparty_id="7648" transfer_contract_id="8151" transfer_trader_id="1154" transfer_sub_book="3523" transfer_template_id="" counterparty_id="11015" contract_id="14287" trader_id="1154" sub_book="3523" template_id="" location_id="" transfer_volume="" volume_per="20" pricing_options="d" fixed_price="" transfer_date="2019-04-15" index_adder="" fixed_adder=""></GridRow></GridHeader></GridXML>',
@transfer_price_process_id='A97672CF_A7A1_4161_BA60_89D27AE88C01'
,@transfer_provisional_price_process_id='064DD1C4_7CFE_445C_9B37_E26D948A8375'

-- SELECT @flag='s', @source_deal_header_id='249960'
--------------------------------------------------*/
SET NOCOUNT ON
DECLARE @volume_left NUMERIC(38, 20)
DECLARE @volume_used_vol NUMERIC(38, 20)
DECLARE @sql NVARCHAR(MAX)

IF @transfer_price_process_id IS NOT NULL
BEGIN
	DECLARE @price_process_table NVARCHAR(100)

	SET @price_process_table = 'adiha_process.dbo.pricing_xml_' + dbo.FNADBUser() + '_' + @transfer_price_process_id
END

IF @transfer_price_process_id IS NOT NULL
BEGIN
	DECLARE @provisional_price_process_table NVARCHAR(100)

	SET @provisional_price_process_table = 'adiha_process.dbo.provisional_pricing_xml_' + dbo.FNADBUser() + '_' + @transfer_provisional_price_process_id
END

IF OBJECT_ID ('tempdb..#volume_left') IS NOT NULL
	DROP TABLE #volume_left

SELECT (1 - ISNULL(SUM(sdd.volume_multiplier2), 0)) volume_left,
	   MAX(sdh.source_deal_header_id) source_deal_header_id,
	   sdh.close_reference_id
INTO #volume_left
FROM source_deal_detail sdd
INNER JOIN source_deal_header sdh ON  sdh.source_deal_header_id = sdd.source_deal_header_id
INNER JOIN (
	SELECT MIN(source_deal_detail_id) source_deal_detail_id
	FROM   source_deal_detail sdd
	GROUP BY sdd.source_deal_header_id
) s ON sdd.source_deal_detail_id = s.source_deal_detail_id
INNER JOIN dbo.SplitCommaSeperatedValues(@source_deal_header_id) t ON sdh.close_reference_id = t.item 
GROUP BY sdh.close_reference_id

IF OBJECT_ID('tempdb..#volume_used_vol') IS NOT NULL
	DROP TABLE #volume_used_vol
	 
SELECT SUM(sdd.deal_volume) volume_used_vol,
	   MAX(sdh.source_deal_header_id) source_deal_header_id,
	   sdh.close_reference_id
INTO #volume_used_vol
FROM source_deal_detail sdd
INNER JOIN source_deal_header sdh ON  sdh.source_deal_header_id = sdd.source_deal_header_id
INNER JOIN (
	SELECT MIN(source_deal_detail_id) source_deal_detail_id
	FROM   source_deal_detail sdd
	GROUP BY sdd.source_deal_header_id
) s ON sdd.source_deal_detail_id = s.source_deal_detail_id
INNER JOIN dbo.SplitCommaSeperatedValues(@source_deal_header_id) t ON sdh.close_reference_id = t.item 
WHERE NULLIF(sdd.volume_multiplier2, 0) IS NULL
GROUP BY sdh.close_reference_id

IF @flag = 'r'
BEGIN
	SELECT dbo.FNATRMWinHyperlink('i', 10131010, CAST(vtd.source_deal_header_id AS NVARCHAR(20)) + '[' + vtd.deal_id + ']', vtd.source_deal_header_id, 'n', DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, 0) [Deal ID],
	       dbo.FNATRMWinHyperlink('i', 10131010, CAST(vtd.transfer_deal_id AS NVARCHAR(20))  + '[' + vtd.transfer_ref_id + ']', vtd.transfer_deal_id, 'n', DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, 0) [Transfer/Offset Deal ID],
	       vtd.counterparty_name [Counterparty],
	       vtd.contract_name [Contract],
	       vtd.trader_name [Trader],
	       vtd.sub_book_name [Sub Book],
	       vtd.transfer_percentage [Transfer/Offset %],
	       vtd.transfer_deal_volume [Transfer/Offset Volume],
		   vtd.transfer_total_volume [Total Volume]
	FROM   vwTransferredDeals vtd
	WHERE vtd.source_deal_header_id = @source_deal_header_id
	UNION ALL
	SELECT dbo.FNATRMWinHyperlink('i', 10131010, CAST(vod.source_deal_header_id AS NVARCHAR(20)) + '[' + vod.deal_id + ']', vod.source_deal_header_id, 'n', DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, 0) [Deal ID],
	    dbo.FNATRMWinHyperlink('i', 10131010, CAST(vod.offset_deal_id AS NVARCHAR(20))  + '[' + vod.offset_ref_id + ']', vod.offset_deal_id, 'n', DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, 0) [Transfer/Offset Deal ID],
	    vod.counterparty_name [Counterparty],
	    vod.contract_name [Contract],
	    vod.trader_name [Trader],
	    vod.sub_book_name [Sub Book],
	    vod.offset_percentage [Transfer/Offset %],
	    vod.offset_deal_volume [Transfer/Offset Volume],
		vod.offset_total_volume [Total Volume]
	FROM   vwOffsetDeals vod
	WHERE vod.source_deal_header_id = @source_deal_header_id
END

IF @flag = 's'
BEGIN
	SELECT DISTINCT dbo.FNARemoveTrailingZero(sdd.deal_volume) deal_volume,
		   dbo.FNARemoveTrailingZero((sdd.deal_volume * ISNULL(vl.volume_left, 1)) - ISNULL(vu.volume_used_vol, 0)) [available_volume],
		   ROUND(dbo.FNARemoveTrailingZero(((sdd.deal_volume * ISNULL(vl.volume_left, 1)) - ISNULL(vu.volume_used_vol, 0))/NULLIF(sdd.deal_volume, 0)), 4) [avail_per],
		   COALESCE(sdh.internal_counterparty, ssbm.primary_counterparty_id,fb.primary_counterparty_id,fs_st.primary_counterparty_id, fs.counterparty_id, sdh.counterparty_id) counterparty_id,
		   sdh.trader_id,
		   ssbm.book_deal_type_map_id sub_book,
		   COALESCE(sdh.contract_id,cca1.contract_id) contract_id,
		   sc.counterparty_name,
		   st.trader_name,
		   ssbm.logical_name [sub_book_name],
		   cg.[contract_name],
		   sdh.deal_date,
		   sdh.internal_desk_id [deal_type]
	FROM source_deal_header sdh
	INNER JOIN dbo.SplitCommaSeperatedValues(@source_deal_header_id) t
		ON t.item = sdh.source_deal_header_id
	LEFT JOIN #volume_left vl ON vl.close_reference_id = sdh.source_deal_header_id
	LEFT JOIN #volume_used_vol vu ON vu.close_reference_id = sdh.source_deal_header_id	
	INNER JOIN source_system_book_map ssbm
		ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
		AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
		AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
		AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
	OUTER APPLY (
		SELECT MIN(ISNULL(sdd.deal_volume, sdd.total_volume)) deal_volume
		FROM source_deal_detail sdd		
		INNER JOIN source_uom su ON su.source_uom_id = sdd.deal_volume_uom_id
		WHERE sdd.source_deal_header_id = sdh.source_deal_header_id
	) sdd
	INNER JOIN fas_books fb ON fb.fas_book_id = ssbm.fas_book_id
	INNER JOIN portfolio_hierarchy ph_book ON ph_book.[entity_id] = fb.fas_book_id
	INNER JOIN portfolio_hierarchy ph_st ON ph_st.[entity_id] = ph_book.parent_entity_id
	INNER JOIN portfolio_hierarchy ph_sub ON ph_sub.[entity_id] = ph_st.parent_entity_id
	INNER JOIN fas_strategy fs_st 
		ON ph_st.[entity_id] = fs_st.fas_strategy_id
	INNER JOIN fas_subsidiaries fs ON ph_sub.[entity_id] = fs.fas_subsidiary_id 	
	INNER JOIN source_counterparty sc ON sc.source_counterparty_id = COALESCE(sdh.internal_counterparty, ssbm.primary_counterparty_id,fb.primary_counterparty_id,fs_st.primary_counterparty_id, fs.counterparty_id, sdh.counterparty_id)
	INNER JOIN source_traders st ON st.source_trader_id = sdh.trader_id
	OUTER APPLY (
		SELECT MAX(contract_id) contract_id
		FROM counterparty_contract_address cca
		WHERE cca.counterparty_id = COALESCE(sdh.internal_counterparty, ssbm.primary_counterparty_id,fb.primary_counterparty_id,fs_st.primary_counterparty_id, fs.counterparty_id, sdh.counterparty_id)
	) cca1
	LEFT JOIN contract_group cg ON cg.contract_id = COALESCE(sdh.contract_id,cca1.contract_id)
	
	RETURN
END

ELSE IF @flag = 't'
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			IF @xml IS NOT NULL
			BEGIN
				DECLARE @idoc INT
				EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
		
				IF OBJECT_ID('tempdb..#temp_deal_transfer') IS NOT NULL
					DROP TABLE #temp_deal_transfer
		
				CREATE TABLE #temp_deal_transfer (
					id INT IDENTITY(1, 1),
					parent_source_deal_header_id INT,
					transfer_counterparty_id INT, -- transfer
					transfer_contract_id INT, -- transfer
					transfer_trader_id INT, -- transfer
					transfer_sub_book INT, -- transfer
					transfer_template_id INT, -- transfer
					counterparty_id INT, -- offset,
					contract_id INT, -- offset
					trader_id INT, -- offset
					sub_book INT, -- offset
					template_id INT, -- offset
					location_id INT,
					transfer_volume NVARCHAR(1000) COLLATE DATABASE_DEFAULT,
					volume_per NUMERIC(38,20),
					pricing_options CHAR(1) COLLATE DATABASE_DEFAULT,
					fixed_price FLOAT,
					fixed_adder FLOAT,
					transfer_date DATETIME,
					source_system_book_id1 INT,
					source_system_book_id2 INT,
					source_system_book_id3 INT,
					source_system_book_id4 INT,
					transfer_source_system_book_id1 INT,
					transfer_source_system_book_id2 INT,
					transfer_source_system_book_id3 INT,
					transfer_source_system_book_id4 INT,
					transfer_without_offset BIT,
					transfer_only_offset BIT,
					est_movement_date NVARCHAR(10) COLLATE DATABASE_DEFAULT,
					index_adder INT
				)

				IF OBJECT_ID('tempdb..#temp_sdg_transfer') IS NOT NULL
					DROP TABLE #temp_sdg_transfer
			
				CREATE TABLE #temp_sdg_transfer (
					source_deal_header_id INT,
					source_deal_groups_id INT,
					group_name NVARCHAR(500) COLLATE DATABASE_DEFAULT ,
					static_group_name NVARCHAR(500) COLLATE DATABASE_DEFAULT ,
					old_id INT,
					quantity INT,
					leg INT
				) 
		
				INSERT INTO #temp_deal_transfer (
					parent_source_deal_header_id, transfer_without_offset, transfer_only_offset, est_movement_date,
					transfer_counterparty_id, transfer_contract_id, transfer_trader_id, transfer_sub_book, transfer_template_id, counterparty_id,contract_id, 
					trader_id, sub_book, template_id, transfer_volume, volume_per, pricing_options, fixed_price, fixed_adder, transfer_date, location_id,index_adder
				)
				SELECT NULLIF(A.deal.value('@source_deal_header_id', 'int'), 0) parent_source_deal_header_id,
					A.deal.value('@transfer_without_offset', 'int') transfer_without_offset,
					A.deal.value('@transfer_only_offset', 'int') transfer_only_offset,
					A.deal.value('@est_movement_date', 'NVARCHAR(10)') est_movement_date,
					NULLIF(B.trans.value('@transfer_counterparty_id', 'int'), 0) transfer_counterparty_id,
					NULLIF(B.trans.value('@transfer_contract_id', 'int'), 0) transfer_contract_id,
					NULLIF(B.trans.value('@transfer_trader_id', 'int'), 0) transfer_trader_id,
					NULLIF(B.trans.value('@transfer_sub_book', 'int'), 0) transfer_sub_book,
					NULLIF(B.trans.value('@transfer_template_id', 'int'), 0) transfer_template_id,
					NULLIF(B.trans.value('@counterparty_id', 'int'), 0) counterparty_id,
					NULLIF(B.trans.value('@contract_id', 'int'), 0) contract_id,
					NULLIF(B.trans.value('@trader_id', 'int'), 0) trader_id,
					NULLIF(B.trans.value('@sub_book', 'int'), 0) sub_book,
					NULLIF(B.trans.value('@template_id', 'int'), 0) template_id,
					NULLIF(B.trans.value('@transfer_volume', 'float'), 0) transfer_volume,
					NULLIF(B.trans.value('@volume_per', 'float'), 0) volume_per,
					B.trans.value('@pricing_options', 'char') pricing_options,
					B.trans.value('@fixed_price', 'float') fixed_price,
					B.trans.value('@fixed_adder', 'float') fixed_adder,
					B.trans.value('@transfer_date', 'date') transfer_date,
					NULLIF(B.trans.value('@location_id', 'int'), 0) location_id,
					NULLIF(B.trans.value('@index_adder', 'int'), 0) index_adder
				FROM @xml.nodes('/GridXML/GridHeader') A(deal)
				CROSS APPLY deal.nodes('GridRow') B(trans)

				-- Find out the available volume.
				IF OBJECT_ID('tempdb..#avail_vol') IS NOT NULL DROP TABLE #avail_vol

				SELECT DISTINCT dbo.FNARemoveTrailingZero((sdd.deal_volume * ISNULL(vl.volume_left, 1)) - ISNULL(vu.volume_used_vol, 0)) [available_volume],
					ROUND(dbo.FNARemoveTrailingZero(((sdd.deal_volume * ISNULL(vl.volume_left, 1)) - ISNULL(vu.volume_used_vol, 0))/NULLIF(sdd.deal_volume, 0)), 4) [avail_per]
					, sdh.source_deal_header_id
					, sdd.deal_volume [original_deal_volume]
				INTO #avail_vol
				FROM source_deal_header sdh
				INNER JOIN dbo.SplitCommaSeperatedValues(@source_deal_header_id) t ON t.item = sdh.source_deal_header_id
				LEFT JOIN #volume_left vl ON vl.close_reference_id = sdh.source_deal_header_id
				LEFT JOIN #volume_used_vol vu ON vu.close_reference_id = sdh.source_deal_header_id
				INNER JOIN source_system_book_map ssbm
					ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
					AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
					AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
					AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
				OUTER APPLY (
					SELECT MIN(ISNULL(sdd.deal_volume, sdd.total_volume)) deal_volume
					FROM source_deal_detail sdd		
					INNER JOIN source_uom su ON su.source_uom_id = sdd.deal_volume_uom_id
					WHERE sdd.source_deal_header_id = sdh.source_deal_header_id
				) sdd
				
				DECLARE @pricing_options CHAR(1);
				SELECT @pricing_options = pricing_options FROM #temp_deal_transfer

				--IF @transfer_only_offset = 0
				--BEGIN
				--IF EXISTS (
				--	SELECT 1
				--	FROM   #temp_deal_transfer
				--		GROUP BY transfer_counterparty_id, transfer_contract_id, transfer_trader_id, transfer_sub_book
				--	HAVING COUNT(id) > 1
				--)
				--BEGIN
				--	EXEC spa_ErrorHandler -1
				--		, 'Deal Transfer'
				--		, 'spa_deal_transfer_new'
				--		, 'DB Error'
				--		, 'Transfer detail combination is repeated. Please use unique combination of Counterparty, Contract, Trader and Sub Book.'
				--		, ''
				--	COMMIT
				--	RETURN
				--END
				--END
			
				UPDATE temp
				SET source_system_book_id1 = ssbm.source_system_book_id1,
					source_system_book_id2 = ssbm.source_system_book_id2,
					source_system_book_id3 = ssbm.source_system_book_id3,
					source_system_book_id4 = ssbm.source_system_book_id4
				FROM #temp_deal_transfer temp
				INNER JOIN source_system_book_map ssbm ON ssbm.book_deal_type_map_id = temp.sub_book
			
				UPDATE temp
				SET transfer_source_system_book_id1 = ssbm.source_system_book_id1,
					transfer_source_system_book_id2 = ssbm.source_system_book_id2,
					transfer_source_system_book_id3 = ssbm.source_system_book_id3,
					transfer_source_system_book_id4 = ssbm.source_system_book_id4
				FROM #temp_deal_transfer temp
				INNER JOIN source_system_book_map ssbm ON ssbm.book_deal_type_map_id = temp.transfer_sub_book

				-- Calculate the volume to be transferred when percentage is provided.
				UPDATE tdt
				SET transfer_volume = CASE WHEN volume_per IS NOT NULL THEN (av.original_deal_volume * volume_per)/100 ELSE transfer_volume END
				--,volume_per = NULL
				-- SELECT * 
				FROM #temp_deal_transfer tdt
				INNER JOIN #avail_vol av ON av.source_deal_header_Id = tdt.parent_source_deal_header_id



				IF OBJECT_ID('tempdb..#temp_original_deal_header') IS NOT NULL
					DROP TABLE #temp_original_deal_header
			
				SELECT sdh.* 
				INTO #temp_original_deal_header 
				FROM source_deal_header sdh 
				INNER JOIN #temp_deal_transfer t ON sdh.source_deal_header_id = t.parent_source_deal_header_id

				--Update pricing_type to 'Indexed' when pricing_option is market and index adder is not null
				UPDATE todh				
				SET pricing_type = 46701 --Indexed
				FROM #temp_original_deal_header todh
				INNER JOIN #temp_deal_transfer sdt
					ON sdt.parent_source_deal_header_id = todh.source_deal_header_id
				WHERE sdt.pricing_options = 'm' 
					AND sdt.index_adder IS NOT NULL
		
				IF OBJECT_ID('tempdb..#temp_original_deal_detail') IS NOT NULL
					DROP TABLE #temp_original_deal_detail
			
				SELECT sdd.*
				INTO #temp_original_deal_detail 
				FROM #temp_deal_transfer t
				INNER JOIN source_deal_header sdh
					ON sdh.source_deal_header_id = t.parent_source_deal_header_id
				INNER JOIN source_deal_type sdt
					ON sdt.source_deal_type_id = sdh.source_deal_type_id
				INNER JOIN source_deal_detail sdd
					ON sdd.source_deal_header_id = t.parent_source_deal_header_id
					AND sdd.leg = CASE WHEN sdh.deal_id like '%SCHD_%' OR sdt.deal_type_id = 'Transportation' THEN 1 ELSE sdd.leg END --exclude leg 2 for SCHD deals

				--update detail buy_sell as per header
				UPDATE d
				SET d.buy_sell_flag = h.header_buy_sell_flag
				FROM #temp_original_deal_detail d
				INNER JOIN #temp_original_deal_header h ON h.source_deal_header_id = d.source_deal_header_id
		
			
				DECLARE @header_column_list NVARCHAR(MAX)
				DECLARE @header_select_list NVARCHAR(MAX)
				DECLARE @detail_column_list NVARCHAR(MAX)
				DECLARE @detail_select_list NVARCHAR(MAX)

				SELECT @header_column_list = COALESCE(@header_column_list + ',', '') + column_name,
					   @header_select_list = COALESCE(@header_select_list + ',', '') + 't1.' + column_name
				FROM INFORMATION_SCHEMA.Columns
				WHERE TABLE_NAME = 'source_deal_header'
					AND column_name NOT IN (
						'source_deal_header_id', 'create_ts', 'create_user', 'update_ts', 'update_user', 'counterparty_id', 'contract_id', 'trader_id',
						'sub_book', 'deal_date', 'source_system_book_id1', 'source_system_book_id2', 'source_system_book_id3', 'source_system_book_id4',
						'deal_id', 'deal_locked', 'deal_status', 'confirm_status_type', 'header_buy_sell_flag', 'deal_reference_type_id', 'ext_deal_id',
						'close_reference_id', 'template_id', 'description4'
					)

				SET @header_column_list = @header_column_list + ',counterparty_id, contract_id, trader_id, sub_book, deal_date, source_system_book_id1, source_system_book_id2, source_system_book_id3, source_system_book_id4, template_id'
			
				DECLARE @transfer_header_select_list NVARCHAR(MAX), @offset_header_select_list NVARCHAR(MAX)

				--SET @transfer_header_select_list = @header_select_list + ',t1.transfer_counterparty_id, t1.transfer_contract_id, t1.transfer_trader_id, t2.transfer_sub_book, t2.transfer_date, t2.source_system_book_id1, t2.source_system_book_id2, t2.source_system_book_id3, t2.source_system_book_id4'
		
				--SET @offset_header_select_list = @header_select_list + ',t2.counterparty_id, NULLIF(t2.contract_id, 0), t2.trader_id, t1.sub_book, t2.transfer_date, t1.source_system_book_id1, t1.source_system_book_id2, t1.source_system_book_id3, t1.source_system_book_id4'

				SET @offset_header_select_list = @header_select_list + ',t2.counterparty_id, NULLIF(t2.contract_id, 0), NULLIF(t2.trader_id,0), t2.sub_book, ISNULL(t2.transfer_date,t1.deal_date), t2.source_system_book_id1, t2.source_system_book_id2, t2.source_system_book_id3, t2.source_system_book_id4, ISNULL(NULLIF(t2.template_id,''''),t1.template_id)'
				SET @transfer_header_select_list = @header_select_list + ',t2.transfer_counterparty_id, NULLIF(t2.transfer_contract_id, 0), NULLIF(t2.transfer_trader_id,0), t2.transfer_sub_book, ISNULL(t2.transfer_date,t1.deal_date), t2.transfer_source_system_book_id1, t2.transfer_source_system_book_id2, t2.transfer_source_system_book_id3, t2.transfer_source_system_book_id4, ISNULL(NULLIF(t2.transfer_template_id,''''),t1.template_id)'

				SELECT @detail_column_list = COALESCE(@detail_column_list + ',', '') + column_name,
					   @detail_select_list = COALESCE(@detail_select_list + ',', '') + 't1.' + column_name		       
				FROM INFORMATION_SCHEMA.Columns 
				WHERE TABLE_NAME = 'source_deal_detail' 
				AND column_name NOT IN ('source_deal_header_id', 'create_ts', 
									   	'create_user', 'update_ts', 'update_user', 
									   	'source_deal_detail_id', 'buy_sell_flag', 'fixed_price',
									   	'location_id', 'process_deal_status', 'volume_multiplier2',
										'deal_volume', 'price_adder', 'formula_curve_id', 'total_volume'
				)
		
				SET @detail_column_list = @detail_column_list + ',source_deal_header_id,fixed_price,location_id,process_deal_status,volume_multiplier2,deal_volume,price_adder,formula_curve_id'
				SET @detail_select_list = @detail_select_list + ',t2.source_deal_header_id, CASE WHEN t2.pricing_options = ''d'' THEN t1.fixed_price WHEN t2.pricing_options = ''x'' THEN t2.fixed_price ELSE NULL END, ISNULL(t2.location_id, t1.location_id),12500, ROUND(CASE WHEN t2.volume_per IS NOT NULL THEN t2.volume_per/100 ELSE NULL END, 4), CASE WHEN t2.volume_per IS NOT NULL THEN t1.deal_volume ELSE t2.transfer_volume END , t2.fixed_adder, CASE WHEN t2.index_adder IS NOT NULL THEN t2.index_adder ELSE t1.formula_curve_id END'
			
				IF OBJECT_ID('tempdb..#temp_offset_deal_headers') IS NOT NULL
					DROP TABLE #temp_offset_deal_headers
		
				CREATE TABLE #temp_offset_deal_headers (
					id INT IDENTITY(1,1),
					source_deal_header_id INT,
					deal_id NVARCHAR(200) COLLATE DATABASE_DEFAULT,
					volume_percent NVARCHAR(20) COLLATE DATABASE_DEFAULT,
					original_deal_id INT,
					fixed_price FLOAT,
					pricing_options NCHAR(1) COLLATE DATABASE_DEFAULT
				)
			
				IF OBJECT_ID('tempdb..#temp_transfer_deal_headers') IS NOT NULL
					DROP TABLE #temp_transfer_deal_headers
		
				CREATE TABLE #temp_transfer_deal_headers (
					id INT IDENTITY(1,1),
					source_deal_header_id INT,
					deal_id NVARCHAR(200) COLLATE DATABASE_DEFAULT,
					volume_percent NVARCHAR(20) COLLATE DATABASE_DEFAULT,
					original_deal_id INT,
					fixed_price FLOAT,
					pricing_options NCHAR(1) COLLATE DATABASE_DEFAULT
				)
			
				IF EXISTS (
					SELECT 1 
					FROM #temp_deal_transfer 
					WHERE (transfer_without_offset = 0 AND transfer_only_offset = 0)
						OR (transfer_only_offset =1)
				) -- insert only offset 
				BEGIN
					IF OBJECT_ID('tempdb..#temp_offset_deal_detail') IS NOT NULL
						DROP TABLE #temp_offset_deal_detail
		
					CREATE TABLE #temp_offset_deal_detail (
						id INT IDENTITY(1,1),
						source_deal_header_id INT,
						source_deal_detail_id INT
					)
			
					SET @sql = 'INSERT INTO source_deal_header(' + @header_column_list + ', ext_deal_id, close_reference_id, deal_status, confirm_status_type, deal_reference_type_id, header_buy_sell_flag, deal_locked, deal_id, description4)
								OUTPUT INSERTED.source_deal_header_id, INSERTED.deal_id, INSERTED.description4, INSERTED.close_reference_id INTO #temp_offset_deal_headers(source_deal_header_id, deal_id, volume_percent, original_deal_id)
								SELECT DISTINCT ' + @offset_header_select_list + ', t1.deal_id, t2.parent_source_deal_header_id, t1.deal_status, t1.confirm_status_type, 12500, CASE WHEN t1.header_buy_sell_flag = ''b'' THEN ''s'' ELSE ''b'' END, ''n'', (CAST(t2.parent_source_deal_header_id AS NVARCHAR(20)) + ''_Offset_'' + CAST(t2.id AS NVARCHAR(20))), dbo.FNARemoveTrailingZero(t2.volume_per)
								FROM #temp_original_deal_header t1
								CROSS APPLY (
									SELECT id, IIF(transfer_date = ''1900-01-01'', t1.deal_date, transfer_date) transfer_date, counterparty_id, contract_id, trader_id, sub_book, source_system_book_id1, source_system_book_id2, source_system_book_id3, source_system_book_id4, template_id, parent_source_deal_header_id, volume_per
									FROM #temp_deal_transfer 
									WHERE t1.source_deal_header_id = parent_source_deal_header_id
								) t2
								'
					--PRINT(@sql)	
					EXEC(@sql)

					--Update fixed price in temp table to insert fixed price in deal detail hour table
					UPDATE todh
					SET fixed_price = tdt.fixed_price,
						pricing_options = tdt.pricing_options
					FROM #temp_offset_deal_headers todh
					INNER JOIN #temp_deal_transfer tdt
						ON todh.original_deal_id = tdt.parent_source_deal_header_id

					UPDATE sdh
					SET description4 = sdh1.description4
					FROM source_deal_header sdh
					INNER JOIN source_deal_header sdh1 ON sdh1.source_deal_header_id = sdh.close_reference_id
					INNER JOIN #temp_offset_deal_headers t ON t.source_deal_header_id = sdh.source_deal_header_id

					INSERT INTO deal_required_document (
						source_deal_header_id, document_type, comments
					)
					SELECT temp.source_deal_header_id, document_type, comments
					FROM #temp_offset_deal_headers temp
					INNER JOIN deal_required_document drd
						ON drd.source_deal_header_id = temp.original_deal_id

					INSERT INTO deal_remarks (source_deal_header_id, deal_remarks)
					SELECT temp.source_deal_header_id, dr.deal_remarks 
					FROM #temp_offset_deal_headers temp
					INNER JOIN deal_remarks dr
						ON dr.source_deal_header_id = temp.original_deal_id
				
					DELETE FROM #temp_sdg_transfer
			
					INSERT INTO source_deal_groups (
						source_deal_header_id,
						source_deal_groups_name, 
						static_group_name,
						quantity,
						leg
					)
					OUTPUT INSERTED.source_deal_groups_id, INSERTED.source_deal_header_id, INSERTED.source_deal_groups_name, INSERTED.static_group_name, INSERTED.quantity, INSERTED.leg INTO #temp_sdg_transfer (source_deal_groups_id, source_deal_header_id, group_name, static_group_name, quantity, leg)
					SELECT temp.source_deal_header_id, sdg.source_deal_groups_name, sdg.static_group_name, sdg.quantity, sdg.leg
					FROM #temp_offset_deal_headers temp
					INNER JOIN source_deal_groups sdg
						ON sdg.source_deal_header_id = temp.original_deal_id
					GROUP BY temp.source_deal_header_id, sdg.source_deal_groups_name, sdg.static_group_name, sdg.quantity , sdg.leg
					
					UPDATE temp
					SET old_id = sdg_old.source_deal_groups_id
					FROM #temp_sdg_transfer temp 
					INNER JOIN source_deal_groups sdg_old
						ON ISNULL(sdg_old.static_group_name, '') = ISNULL(temp.static_group_name, '')
						AND ISNULL(sdg_old.source_deal_groups_name, '') = ISNULL(temp.group_name, '')
						AND ISNULL(sdg_old.quantity, '') = ISNULL(temp.quantity, '')
						AND ISNULL(sdg_old.leg, '') = ISNULL(temp.leg, '')
					INNER JOIN #temp_deal_transfer t ON sdg_old.source_deal_header_id = t.parent_source_deal_header_id
					
					SET @sql = '
						INSERT INTO source_deal_detail(' + @detail_column_list + ', buy_sell_flag)
						OUTPUT INSERTED.source_deal_header_id, INSERTED.source_deal_detail_id 
						INTO #temp_offset_deal_detail(source_deal_header_id, source_deal_detail_id)
						SELECT DISTINCT ' + @detail_select_list + ', IIF(t1.buy_sell_flag = ''b'', ''s'', ''b'')
						FROM #temp_original_deal_detail t1
						OUTER APPLY (
							SELECT tod.source_deal_header_id, tdt.pricing_options, tdt.volume_per, tdt.location_id, tdt.fixed_price, tdt.transfer_volume, tdt.fixed_adder, tdt.index_adder
							FROM #temp_offset_deal_headers tod
							INNER JOIN source_deal_header sdh ON tod.source_deal_header_id = sdh.source_deal_header_id
							OUTER APPLY (
								SELECT volume_per, location_id, pricing_options, fixed_price, transfer_volume, fixed_adder, parent_source_deal_header_id, index_adder
								FROM #temp_deal_transfer t
								WHERE t.id = CAST(REPLACE(REPLACE(sdh.deal_id, t.parent_source_deal_header_id, ''''), ''_Offset_'', '''') AS INT)
							) tdt
							WHERE tdt.parent_source_deal_header_id = t1.source_deal_header_id
						) t2
					'
					--PRINT(@sql)	
					EXEC(@sql)

					UPDATE sdd
					SET source_deal_group_id = sdg.source_deal_groups_id
					FROM source_deal_detail sdd
					INNER JOIN #temp_sdg_transfer sdg ON sdg.source_deal_header_id = sdd.source_deal_header_id
						--AND sdd.source_deal_group_id = sdg.old_id
						AND sdd.leg =  ISNULL(sdg.leg,sdd.leg)
						
					--UPDATE sdd
					--	SET price_adder = @price_adder
					--FROM source_deal_detail sdd 
					--INNER JOIN #temp_offset_deal_detail todd ON sdd.source_deal_detail_id = todd.source_deal_detail_id
					--WHERE @price_adder IS NOT NULL

					--UPDATE sdd
					--	SET formula_curve_id = @formula_curve_id
					--FROM source_deal_detail sdd 
					--INNER JOIN #temp_offset_deal_detail todd ON sdd.source_deal_detail_id = todd.source_deal_detail_id 
					--WHERE @formula_curve_id IS NOT NULL

				/* Transfer 'Cost' udf when pricing option is 'Original Deal Price' */
					SET @sql =
					'INSERT INTO user_defined_deal_fields (source_deal_header_id,udf_template_id,udf_value, currency_id, uom_id, counterparty_id, contract_id, receive_pay)
					 SELECT temp.source_deal_header_id,
							uddf.udf_template_id,
							uddf.udf_value,
							uddf.currency_id,
							uddf.uom_id,
							uddf.counterparty_id,
							uddf.contract_id, 
							uddf.receive_pay
					 FROM #temp_offset_deal_headers temp
					INNER JOIN #temp_deal_transfer t 
						ON t.parent_source_deal_header_id = temp.original_deal_id
						AND t.id = CAST(REPLACE(REPLACE(temp.deal_id,temp.original_deal_id, ''''), ''_Offset_'', '''') AS INT)
					INNER JOIN source_deal_header sdh
						ON sdh.source_deal_header_id = temp.original_deal_id
					INNER JOIN source_deal_header_template sdht 
						ON sdht.template_id = sdh.template_id
					INNER JOIN user_defined_deal_fields uddf 
						ON uddf.source_deal_header_id = sdh.source_deal_header_id
					INNER JOIN user_defined_deal_fields_template uddft 
						ON uddft.udf_template_id = uddf.udf_template_id AND uddft.template_id = sdht.template_id
					INNER JOIN user_defined_fields_template udft 
						ON udft.field_name = uddft.field_name
					WHERE IIF(t.pricing_options <> ''d'', ISNULL(udft.deal_udf_type, ''-1''), ''1'') <> IIF(t.pricing_options <> ''d'', ''c'', ''1'')
					'

					EXEC (@sql);				
		

					SET @sql =
					'INSERT INTO user_defined_deal_detail_fields (source_deal_detail_id, udf_template_id, udf_value, currency_id, uom_id, counterparty_id, contract_id, receive_pay)
					SELECT sdd_offset.source_deal_detail_id, uddf.udf_template_id, uddf.udf_value, uddf.currency_id, uddf.uom_id, uddf.counterparty_id
					,uddf.contract_id, uddf.receive_pay
					FROM #temp_offset_deal_headers temp
					INNER JOIN #temp_deal_transfer t 
						ON t.parent_source_deal_header_id = temp.original_deal_id
						AND t.id = CAST(REPLACE(REPLACE(temp.deal_id,temp.original_deal_id, ''''), ''_Offset_'', '''') AS INT)
					INNER JOIN source_deal_header sdh
						ON sdh.source_deal_header_id = temp.original_deal_id
					INNER JOIN source_deal_detail sdd
						ON sdd.source_deal_header_id = sdh.source_deal_header_id
					INNER JOIN source_deal_detail sdd_offset
						ON sdd_offset.source_deal_header_id = temp.source_deal_header_id
						AND sdd_offset.leg = sdd.leg
						AND sdd_offset.term_start = sdd.term_start
						AND sdd_offset.term_end = sdd.term_end
					INNER JOIN user_defined_deal_detail_fields uddf
						ON uddf.source_deal_detail_id = sdd.source_deal_detail_id 
					INNER JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id
					INNER JOIN user_defined_deal_fields_template uddft 
						ON uddft.udf_template_id = uddf.udf_template_id 
						AND uddft.template_id = sdht.template_id
					INNER JOIN user_defined_fields_template udft 
						ON udft.field_name = uddft.field_name
					WHERE IIF(t.pricing_options <> ''d'', ISNULL(udft.deal_udf_type, ''-1''), ''1'') <> IIF(t.pricing_options <> ''d'', ''c'', ''1'')
					'
					EXEC (@sql);

				END
				
				IF EXISTS (
					SELECT 1 
					FROM #temp_deal_transfer 
					WHERE (transfer_without_offset = 1 AND transfer_without_offset = 0)
						OR (transfer_only_offset = 0)
				)			
				BEGIN
					IF OBJECT_ID('tempdb..#temp_transfer_deal_detail') IS NOT NULL
						DROP TABLE #temp_transfer_deal_detail
		
					CREATE TABLE #temp_transfer_deal_detail (
						id INT IDENTITY(1,1),
						source_deal_header_id INT,
						source_deal_detail_id INT
					)

					SET @sql = 'INSERT INTO source_deal_header(' + @header_column_list + ', deal_status, confirm_status_type, deal_reference_type_id, header_buy_sell_flag, deal_locked, deal_id, description4,close_reference_id)
								OUTPUT INSERTED.source_deal_header_id, INSERTED.deal_id, INSERTED.description4, INSERTED.close_reference_id INTO #temp_transfer_deal_headers(source_deal_header_id, deal_id, volume_percent,original_deal_id)
								SELECT DISTINCT ' + @transfer_header_select_list  + ', t1.deal_status, t1.confirm_status_type, 12503, t1.header_buy_sell_flag, ''n'', CAST(t2.parent_source_deal_header_id AS NVARCHAR(20)) + ''_Xferred_'' + CAST(t2.id AS NVARCHAR(20)), dbo.FNARemoveTrailingZero(t2.volume_per),t2.parent_source_deal_header_id
								FROM #temp_original_deal_header t1
								CROSS APPLY (
									SELECT id, transfer_counterparty_id,transfer_contract_id,transfer_trader_id,IIF(transfer_date = ''1900-01-01'', t1.deal_date, transfer_date) transfer_date, 
										   transfer_source_system_book_id1, transfer_source_system_book_id2, transfer_source_system_book_id3, 
										   transfer_source_system_book_id4, transfer_sub_book, transfer_template_id, parent_source_deal_header_id, volume_per
									FROM #temp_deal_transfer
									WHERE t1.source_deal_header_id = parent_source_deal_header_id
								) t2
								'
					--print(@sql)	
					EXEC(@sql)
								
					--Update fixed price in temp table to insert fixed price in deal detail hour table
					UPDATE ttdh
					SET fixed_price = tdt.fixed_price,
						pricing_options = tdt.pricing_options
					FROM #temp_transfer_deal_headers ttdh
					INNER JOIN #temp_deal_transfer tdt
						ON ttdh.original_deal_id = tdt.parent_source_deal_header_id

					UPDATE sdh
					SET description4 = sdh1.description4
					FROM source_deal_header sdh
					INNER JOIN source_deal_header sdh1 ON sdh1.source_deal_header_id = sdh.close_reference_id
					INNER JOIN #temp_transfer_deal_headers t ON t.source_deal_header_id = sdh.source_deal_header_id

					IF EXISTS(SELECT 1 FROM #temp_offset_deal_headers)
					BEGIN
						UPDATE sdh
						SET ext_deal_id = t2.deal_id,
							close_reference_id = t2.source_deal_header_id
						FROM source_deal_header sdh
						INNER JOIN #temp_transfer_deal_headers t1 ON t1.source_deal_header_id = sdh.source_deal_header_id
						OUTER APPLY (
							SELECT t2.deal_id, t2.source_deal_header_id
							FROM #temp_offset_deal_headers t2 
							WHERE t2.deal_id = REPLACE(t1.deal_id, '_Xferred_', '_Offset_')
						) t2
					END
					ELSE
					BEGIN
						UPDATE sdh
						SET ext_deal_id = t2.deal_id,
							close_reference_id = t2.source_deal_header_id
						FROM source_deal_header sdh
						INNER JOIN #temp_transfer_deal_headers t1 ON t1.source_deal_header_id = sdh.source_deal_header_id
						INNER JOIN source_deal_header t2
							ON t2.source_deal_header_id = t1.original_deal_id
					END

					INSERT INTO deal_required_document (
						source_deal_header_id, document_type, comments
					)
					SELECT temp.source_deal_header_id, document_type, comments
					FROM #temp_transfer_deal_headers temp
					INNER JOIN deal_required_document drd
						ON drd.source_deal_header_id = temp.original_deal_id

					INSERT INTO deal_remarks (source_deal_header_id, deal_remarks)
					SELECT temp.source_deal_header_id, dr.deal_remarks 
					FROM #temp_transfer_deal_headers temp
					INNER JOIN deal_remarks dr
						ON dr.source_deal_header_id = temp.original_deal_id
 				
 					DELETE FROM #temp_sdg_transfer
 			 			
 					INSERT INTO source_deal_groups (
						source_deal_header_id,
						source_deal_groups_name, 
						static_group_name,
						quantity,
						leg
					)
					OUTPUT INSERTED.source_deal_groups_id, INSERTED.source_deal_header_id, INSERTED.source_deal_groups_name, INSERTED.static_group_name, INSERTED.quantity, INSERTED.leg INTO #temp_sdg_transfer (source_deal_groups_id, source_deal_header_id, group_name, static_group_name, quantity, leg)
					SELECT temp.source_deal_header_id, sdg.source_deal_groups_name, sdg.static_group_name, sdg.quantity, sdg.leg
					FROM #temp_transfer_deal_headers temp
					INNER JOIN source_deal_groups sdg
						ON sdg.source_deal_header_id = temp.original_deal_id
					GROUP BY temp.source_deal_header_id, sdg.source_deal_groups_name, sdg.static_group_name, sdg.quantity , sdg.leg
			
					UPDATE temp
					SET old_id = sdg_old.source_deal_groups_id
					FROM #temp_sdg_transfer temp 
					INNER JOIN source_deal_groups sdg_old
						ON ISNULL(sdg_old.static_group_name, '') = ISNULL(temp.static_group_name, '')
						AND ISNULL(sdg_old.source_deal_groups_name, '') = ISNULL(temp.group_name, '')
						AND ISNULL(sdg_old.quantity, '') = ISNULL(temp.quantity, '')
						AND ISNULL(sdg_old.leg, '') = ISNULL(temp.leg, '')
					INNER JOIN #temp_deal_transfer t ON sdg_old.source_deal_header_id = t.parent_source_deal_header_id
			 								
					SET @sql = '
						INSERT INTO source_deal_detail(' + @detail_column_list + ', buy_sell_flag)
						OUTPUT INSERTED.source_deal_header_id, INSERTED.source_deal_detail_id 
						INTO #temp_transfer_deal_detail(source_deal_header_id, source_deal_detail_id)
						SELECT DISTINCT ' + @detail_select_list + ', t1.buy_sell_flag
						FROM #temp_original_deal_detail t1
						OUTER APPLY (
							SELECT tod.source_deal_header_id, tdt.pricing_options, tdt.volume_per, tdt.location_id, tdt.fixed_price, tdt.transfer_volume, tdt.fixed_adder, tdt.index_adder
							FROM #temp_transfer_deal_headers tod
							INNER JOIN source_deal_header sdh ON tod.source_deal_header_id = sdh.source_deal_header_id
							OUTER APPLY (
								SELECT volume_per, location_id, pricing_options, fixed_price, transfer_volume, fixed_adder, parent_source_deal_header_id, index_adder
								FROM #temp_deal_transfer
								WHERE #temp_deal_transfer.id = CAST(REPLACE(REPLACE(sdh.deal_id, parent_source_deal_header_id, ''''), ''_Xferred_'', '''') AS INT)
							) tdt
							WHERE tdt.parent_source_deal_header_id = t1.source_deal_header_id
						) t2
								'
					--PRINT(@sql)	
					EXEC(@sql)
			
					UPDATE sdd
					SET source_deal_group_id = sdg.source_deal_groups_id
					FROM source_deal_detail sdd
					INNER JOIN #temp_sdg_transfer sdg
						ON sdg.source_deal_header_id = sdd.source_deal_header_id
						--AND sdd.source_deal_group_id = sdg.old_id
						AND sdd.leg =  ISNULL(sdg.leg,sdd.leg)

					--UPDATE sdd
					--	SET price_adder = @price_adder
					--FROM source_deal_detail sdd 
					--INNER JOIN #temp_transfer_deal_detail todd ON sdd.source_deal_detail_id = todd.source_deal_detail_id
					--WHERE @price_adder IS NOT NULL

					--UPDATE sdd
					--	SET formula_curve_id = @formula_curve_id
					--FROM source_deal_detail sdd 
					--INNER JOIN #temp_transfer_deal_detail todd ON sdd.source_deal_detail_id = todd.source_deal_detail_id
					--WHERE @formula_curve_id IS NOT NULL

				/* Transfer 'Cost' udf when pricing option is 'Original Deal Price' */
					
					SET @sql =
					'INSERT INTO user_defined_deal_fields (source_deal_header_id,udf_template_id,udf_value, currency_id, uom_id, counterparty_id, contract_id, receive_pay)
					 SELECT temp.source_deal_header_id,
							uddf.udf_template_id,
							uddf.udf_value,
							uddf.currency_id,
							uddf.uom_id,
							uddf.counterparty_id,
							uddf.contract_id, 
							uddf.receive_pay
					 FROM #temp_transfer_deal_headers temp
					INNER JOIN #temp_deal_transfer t 
						ON t.parent_source_deal_header_id = temp.original_deal_id
						AND t.id = CAST(REPLACE(REPLACE(temp.deal_id,temp.original_deal_id, ''''), ''_Xferred_'', '''') AS INT)
					INNER JOIN source_deal_header sdh
						ON sdh.source_deal_header_id = temp.original_deal_id
					INNER JOIN source_deal_header_template sdht 
						ON sdht.template_id = sdh.template_id
					INNER JOIN user_defined_deal_fields uddf 
						ON uddf.source_deal_header_id = sdh.source_deal_header_id
					INNER JOIN user_defined_deal_fields_template uddft 
						ON uddft.udf_template_id = uddf.udf_template_id AND uddft.template_id = sdht.template_id
					INNER JOIN user_defined_fields_template udft 
						ON udft.field_name = uddft.field_name
					WHERE IIF(t.pricing_options <> ''d'', ISNULL(udft.deal_udf_type, ''-1''), ''1'') <> IIF(t.pricing_options <> ''d'', ''c'', ''1'')
					'
					EXEC (@sql);
			
					SET @sql =
					'INSERT INTO user_defined_deal_detail_fields (source_deal_detail_id, udf_template_id, udf_value, currency_id, uom_id, counterparty_id, contract_id, receive_pay)
					SELECT sdd_transfer.source_deal_detail_id, uddf.udf_template_id, uddf.udf_value, uddf.currency_id, uddf.uom_id, uddf.counterparty_id
					,uddf.contract_id, uddf.receive_pay
					FROM #temp_transfer_deal_headers temp
					INNER JOIN #temp_deal_transfer t 
						ON t.parent_source_deal_header_id = temp.original_deal_id
						AND t.id = CAST(REPLACE(REPLACE(temp.deal_id,temp.original_deal_id, ''''), ''_Xferred_'', '''') AS INT)
					INNER JOIN source_deal_header sdh
						ON sdh.source_deal_header_id = temp.original_deal_id
					INNER JOIN source_deal_detail sdd
						ON sdd.source_deal_header_id = sdh.source_deal_header_id
					INNER JOIN source_deal_detail sdd_transfer
						ON sdd_transfer.source_deal_header_id = temp.source_deal_header_id
						AND sdd_transfer.leg = sdd.leg
						AND sdd_transfer.term_start = sdd.term_start
						AND sdd_transfer.term_end = sdd.term_end
					INNER JOIN user_defined_deal_detail_fields uddf
						ON uddf.source_deal_detail_id = sdd.source_deal_detail_id 
					INNER JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id
					INNER JOIN user_defined_deal_fields_template uddft 
						ON uddft.udf_template_id = uddf.udf_template_id 
						AND uddft.template_id = sdht.template_id
					INNER JOIN user_defined_fields_template udft 
						ON udft.field_name = uddft.field_name
					WHERE IIF(t.pricing_options <> ''d'', ISNULL(udft.deal_udf_type, ''-1''), ''1'') <> IIF(t.pricing_options <> ''d'', ''c'', ''1'')
					'
					EXEC (@sql);

					IF EXISTS (
						SELECT 1 
						FROM #temp_deal_transfer 
						WHERE transfer_without_offset = 1
					)
					BEGIN
						UPDATE sdh
						SET sdh.source_deal_type_id = ISNULL(sdh.source_deal_type_id, sdht.source_deal_type_id), 
							sdh.deal_sub_type_type_id = ISNULL(sdh.deal_sub_type_type_id, sdht.deal_sub_type_type_id)
						FROM #temp_deal_transfer tdf
						INNER JOIN source_deal_header_template sdht ON sdht.template_id = tdf.transfer_template_id
						INNER JOIN source_deal_header sdh ON sdh.template_id = tdf.transfer_template_id
						INNER JOIN #temp_transfer_deal_headers TEMP ON sdh.source_deal_header_id = TEMP.source_deal_header_id
					END
				END
				
				IF EXISTS (
					SELECT 1 
					FROM #temp_deal_transfer 
					WHERE transfer_only_offset = 1
				)
				BEGIN
					UPDATE sdh
					SET sdh.source_deal_type_id = ISNULL(sdh.source_deal_type_id, sdht.source_deal_type_id),
						sdh.deal_sub_type_type_id = ISNULL(sdh.deal_sub_type_type_id, sdht.deal_sub_type_type_id)
					FROM #temp_deal_transfer tdf
					INNER JOIN source_deal_header_template sdht ON sdht.template_id = tdf.template_id
					INNER JOIN source_deal_header sdh ON sdh.template_id = tdf.template_id
					INNER JOIN #temp_offset_deal_headers TEMP ON sdh.source_deal_header_id = TEMP.source_deal_header_id
				END

				IF EXISTS (
					SELECT 1 
					FROM #temp_deal_transfer 
					WHERE transfer_only_offset = 0
						AND transfer_without_offset  = 0
				)
				BEGIN					
					UPDATE sdh
					SET sdh.source_deal_type_id = ISNULL(sdh.source_deal_type_id, sdht.source_deal_type_id),
						sdh.deal_sub_type_type_id = ISNULL(sdh.deal_sub_type_type_id, sdht.deal_sub_type_type_id)
					FROM #temp_deal_transfer tdf
					INNER JOIN source_deal_header_template sdht ON sdht.template_id = tdf.template_id
					INNER JOIN source_deal_header sdh ON sdh.template_id = tdf.template_id
					INNER JOIN #temp_offset_deal_headers TEMP ON sdh.source_deal_header_id = TEMP.source_deal_header_id
				
					UPDATE sdh
					SET sdh.source_deal_type_id = ISNULL(sdh.source_deal_type_id, sdht.source_deal_type_id),
						sdh.deal_sub_type_type_id = ISNULL(sdh.deal_sub_type_type_id, sdht.deal_sub_type_type_id)
					FROM #temp_deal_transfer tdf
					INNER JOIN source_deal_header_template sdht ON sdht.template_id = tdf.transfer_template_id
					INNER JOIN source_deal_header sdh ON sdh.template_id = tdf.transfer_template_id
					INNER JOIN #temp_transfer_deal_headers TEMP ON sdh.source_deal_header_id = TEMP.source_deal_header_id
				END
				
				--[TO DO] changes done as per latest requirement in enercity which was done only for product_id IN (4100, 4101)
				UPDATE sdh
				SET deal_id = t2.deal_id + '_offset_' + CAST(t1.original_deal_id AS NVARCHAR(20))
				   --,close_reference_id = t2.close_reference_id
				   ,create_user = dbo.FNADBUser()
				   ,create_ts = GETDATE()
				FROM #temp_offset_deal_headers t1
				INNER JOIN source_deal_header sdh
					ON sdh.source_deal_header_id = t1.source_deal_header_id
				INNER JOIN source_deal_header t2
					ON t2.source_deal_header_id = t1.original_deal_id
				--WHERE t2.product_id IN (4100, 4101)
				
				UPDATE sdh
				SET deal_id = t2.deal_id + '_Xferred_' + CAST(t1.original_deal_id AS NVARCHAR(20))
				   --,close_reference_id = t2.close_reference_id
				   ,create_user = dbo.FNADBUser()
				   ,create_ts = GETDATE()
				FROM #temp_transfer_deal_headers t1
				INNER JOIN source_deal_header sdh
					ON sdh.source_deal_header_id = t1.source_deal_header_id
				INNER JOIN source_deal_header t2
					ON t2.source_deal_header_id = t1.original_deal_id
				--WHERE t2.product_id IN (4100, 4101)
				
				----Update close reference id  as of original for fixation deals
				UPDATE sdh
				SET close_reference_id = t2.close_reference_id				   
				FROM #temp_offset_deal_headers t1
				INNER JOIN source_deal_header sdh
					ON sdh.source_deal_header_id = t1.source_deal_header_id
				INNER JOIN source_deal_header t2
					ON t2.source_deal_header_id = t1.original_deal_id
				WHERE t2.product_id IN (4100, 4101)

				UPDATE sdh
				SET close_reference_id = t2.close_reference_id				   
				FROM #temp_transfer_deal_headers t1
				INNER JOIN source_deal_header sdh
					ON sdh.source_deal_header_id = t1.source_deal_header_id
				INNER JOIN source_deal_header t2
					ON t2.source_deal_header_id = t1.original_deal_id
				WHERE t2.product_id IN (4100, 4101)				
				
	
				IF OBJECT_ID('tempdb..#temp_all_deal_ids') IS NOT NULL
					DROP TABLE #temp_all_deal_ids 
				CREATE TABLE #temp_all_deal_ids (source_deal_header_id INT)
	
				INSERT INTO #temp_all_deal_ids(source_deal_header_id)	
				SELECT source_deal_header_id FROM #temp_offset_deal_headers
				UNION ALL
				SELECT source_deal_header_id FROM #temp_transfer_deal_headers	

				IF OBJECT_ID('tempdb..#pricing_detail') IS NOT NULL 
					DROP TABLE #pricing_detail

				SELECT sddt.detail_pricing, tdf.transfer_template_id
				INTO #pricing_detail
				FROM #temp_deal_transfer tdf 
				INNER JOIN source_deal_detail_template sddt ON sddt.template_id  = tdf.transfer_template_id
				
				--SELECT * 
				UPDATE sdd
				SET sdd.detail_pricing = ISNULL(sdd.detail_pricing, pd.detail_pricing)
				FROM #temp_all_deal_ids ids
				INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = ids.source_deal_header_id
				INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = ids.source_deal_header_id
				INNER JOIN #pricing_detail pd ON pd.transfer_template_id = sdh.template_id

				--IF OBJECT_ID('tempdb..#pricing_detail_offset') IS NOT NULL 
				--  DROP TABLE #pricing_detail_offset
			 
				--SELECT sddt.detail_pricing, tdf.template_id
				--INTO #pricing_detail_offset
				--FROM #temp_deal_transfer tdf 
				--INNER JOIN source_deal_detail_template sddt ON sddt.template_id  = tdf.template_id

				--SELECT * 
				UPDATE sdd
				SET sdd.detail_pricing = ISNULL( sdd.detail_pricing, sddt.detail_pricing)
				FROM #temp_all_deal_ids ids
				INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = ids.source_deal_header_id
				INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = ids.source_deal_header_id
				INNER JOIN #temp_deal_transfer tdf ON sdh.template_id = tdf.template_id
				INNER JOIN source_deal_detail_template sddt ON sddt.template_id  = tdf.template_id
				--INNER JOIN #pricing_detail_offset pd ON pd.template_id = sdh.template_id
			
				--Logic to insert prepay details while transferring deals
				INSERT INTO source_deal_prepay (
					prepay, [value], [percentage], formula_id, settlement_date, settlement_calendar, settlement_days,
					payment_date, payment_calendar, payment_days, granularity, source_deal_header_id
				)
				SELECT prepay, [value], [percentage], formula_id, settlement_date, settlement_calendar,
					   settlement_days, payment_date, payment_calendar, payment_days, granularity, a.source_deal_header_id
				FROM source_deal_prepay sdp
				OUTER APPLY (
					SELECT source_deal_header_id 
					FROM #temp_all_deal_ids
				) a
				INNER JOIN #temp_deal_transfer t ON sdp.source_deal_header_id = t.parent_source_deal_header_id
			
				IF EXISTS(SELECT 1 FROM #temp_all_deal_ids) 
				BEGIN
					DECLARE @after_insert_process_table NVARCHAR(300)
					DECLARE @user_login_id NVARCHAR(100) = dbo.FNADBUser()
					DECLARE @process_id NVARCHAR(200) = dbo.FNAGETNEWID()
					DECLARE @job_name NVARCHAR(MAX)

					/************ TO DO:Deal pricing logic is commented as pricing page is not available in oct_release version		
									-- Start of Deal Pricing Logic
					DECLARE @deal_pricing_table NVARCHAR(300)
 	
 					SET @deal_pricing_table = dbo.FNAProcessTableName('deal_pricing_table', @user_login_id, @process_id)	

					IF OBJECT_ID(@deal_pricing_table) IS NOT NULL
 					BEGIN
 						EXEC('DROP TABLE ' + @deal_pricing_table)
 					END

					EXEC ('CREATE TABLE ' + @deal_pricing_table + '(source_deal_detail_id INT, detail_pricing INT, formula_curve_id INT, price_adder NUMERIC(38,18), adder_currency_id INT )')

					SET @sql = 'INSERT INTO ' + @deal_pricing_table + '(source_deal_detail_id, detail_pricing, formula_curve_id, price_adder, adder_currency_id)
								SELECT sdd.source_deal_detail_id, sdd.detail_pricing, sdd.formula_curve_id, sdd.price_adder, sdd.adder_currency_id
								FROM #temp_all_deal_ids i
								INNER JOIN source_deal_detail sdd
									ON sdd.source_deal_header_id = i.source_deal_header_id
								WHERE NULLIF(sdd.detail_pricing, '''') IS NOT NULL 
									AND NULLIF(sdd.formula_curve_id, '''') IS NOT NULL

								EXEC spa_deal_pricing_detail @flag = ''f'', @process_id = ''' + @process_id	+ ''''			
					EXEC(@sql)
					-- End of Deal Pricing Logic
					*/		
					SET @after_insert_process_table = dbo.FNAProcessTableName('after_insert_process_table', @user_login_id,@process_id)
					EXEC ('CREATE TABLE ' + @after_insert_process_table + '( source_deal_header_id INT)')
		
					SET @sql = 'INSERT INTO ' + @after_insert_process_table + '(source_deal_header_id) 
								SELECT DISTINCT source_deal_header_id FROM #temp_all_deal_ids'
					EXEC (@sql)
		
					SET @sql = 'spa_deal_insert_update_jobs ''i'', ''' + @after_insert_process_table + ''''
					SET @job_name = 'spa_deal_insert_update_jobs_' + @process_id
 		
					EXEC spa_run_sp_as_job @job_name, @sql, 'spa_deal_insert_update_jobs', @user_login_id
		
		
					DECLARE @jobs_process_id NVARCHAR(200) = dbo.FNAGETNewID()
					DECLARE @alert_process_table NVARCHAR(300)
					SET @alert_process_table = 'adiha_process.dbo.alert_deal_transfer_' + @jobs_process_id + '_ad'
			
					EXEC ('CREATE TABLE ' + @alert_process_table + '(
								source_deal_header_id		INT,
								source_deal_header_id_new	INT
							)')
 			   
					SET @sql = 'INSERT INTO ' + @alert_process_table + ' (
 									source_deal_header_id,
									source_deal_header_id_new
 								)
 								SELECT a.item, source_deal_header_id 
 								FROM #temp_all_deal_ids
								OUTER APPLY (
									SELECT item FROM dbo.SplitCommaSeperatedValues(''' + CAST(@source_deal_header_id AS NVARCHAR(200)) + ''')
								) a
 								GROUP BY a.item, source_deal_header_id'
					EXEC(@sql)
 		
					SET @sql = 'spa_register_event 20601, 20536, ''' + @alert_process_table + ''', 1, ''' + @jobs_process_id + ''''
					SET @job_name = 'scheduling_alert_job_' + @jobs_process_id
					EXEC spa_run_sp_as_job @job_name, @sql, 'scheduling_alert_job', @user_login_id
				END
			END
		
			IF NULLIF(@transfer_price_process_id, '') IS NOT NULL AND EXISTS (SELECT 1 FROM #temp_deal_transfer WHERE pricing_options = 'd')
			BEGIN
				DECLARE @price_process_id NVARCHAR(50) = dbo.FNAGetNewID(),
						@deal_header_ids NVARCHAR(1000)

				SELECT @deal_header_ids = ISNULL(@deal_header_ids + ',', '') + CAST(source_deal_header_id AS NVARCHAR(10))
				FROM #temp_all_deal_ids

				SET @sql = '
					DECLARE @flag CHAR(1),
							@source_deal_detail_id INT,
							@xml_value NVARCHAR(MAX),
							@apply_to_xml NVARCHAR(MAX),
							@is_apply_to_all CHAR(1),
							@call_from NVARCHAR(50),
							@process_id NVARCHAR(200)

					DECLARE @get_source_deal_detail_id CURSOR
					SET @get_source_deal_detail_id = CURSOR FOR

						SELECT DISTINCT ''m'',
								x.source_deal_detail_id,
								p.xml_value,
								p.apply_to_xml,
								p.is_apply_to_all,
								p.call_from,
								p.process_id
						FROM ' + @price_process_table + ' p
						INNER JOIN source_deal_detail sdd
							ON p.source_deal_detail_id = sdd.source_deal_detail_id
						LEFT JOIN source_deal_detail x
							ON x.term_start = sdd.term_start
								AND x.term_end = sdd.term_end
								AND x.leg = sdd.leg
						INNER JOIN dbo.SplitCommaSeperatedValues(''' + @deal_header_ids + ''') t
							ON x.source_deal_header_id = t.item

					OPEN @get_source_deal_detail_id
					FETCH NEXT
					FROM @get_source_deal_detail_id INTO @flag, @source_deal_detail_id, @xml_value, @apply_to_xml, @is_apply_to_all, @call_from, @process_id
					WHILE @@FETCH_STATUS = 0
					BEGIN
						EXEC [dbo].[spa_deal_pricing_detail] @flag = @flag,
															@source_deal_detail_id = @source_deal_detail_id,
															@xml = @xml_value,
															@apply_to_xml = @apply_to_xml,
															@is_apply_to_all = @is_apply_to_all,
															@call_from = @call_from,
															@process_id = @process_id,
															@mode = ''save'',
															@xml_process_id = NULL
					FETCH NEXT
					FROM @get_source_deal_detail_id INTO @flag, @source_deal_detail_id, @xml_value, @apply_to_xml, @is_apply_to_all, @call_from, @process_id
					END
					CLOSE @get_source_deal_detail_id
					DEALLOCATE @get_source_deal_detail_id
				'
			
				EXEC spa_run_multi_step_job @job_name = 'deal_pricing_insert_job_Xfer', @step1 = @sql, @process_id = @price_process_id	
			END
			
			IF NULLIF(@transfer_price_process_id, '') IS NOT NULL AND EXISTS (SELECT 1 FROM #temp_deal_transfer WHERE pricing_options = 'd')
			BEGIN
				DECLARE @provisional_price_process_id NVARCHAR(50) = dbo.FNAGetNewID(),
						@deal_header_ids_transer NVARCHAR(1000)

				SELECT @deal_header_ids_transer = ISNULL(@deal_header_ids_transer + ',', '') + CAST(source_deal_header_id AS NVARCHAR(10))
				FROM #temp_all_deal_ids

				SET @sql = '
					DECLARE @flag CHAR(1),
							@source_deal_detail_id INT,
							@xml_value NVARCHAR(MAX),
							@apply_to_xml NVARCHAR(MAX),
							@is_apply_to_all CHAR(1),
							@call_from NVARCHAR(50),
							@process_id NVARCHAR(200)

					DECLARE @get_source_deal_detail_id CURSOR
					SET @get_source_deal_detail_id = CURSOR FOR

						SELECT DISTINCT ''m'',
								x.source_deal_detail_id,
								p.xml_value,
								p.apply_to_xml,
								p.is_apply_to_all,
								p.call_from,
								p.process_id
						FROM ' + @provisional_price_process_table + ' p
						INNER JOIN source_deal_detail sdd
							ON p.source_deal_detail_id = sdd.source_deal_detail_id
						LEFT JOIN source_deal_detail x
							ON x.term_start = sdd.term_start
								AND x.term_end = sdd.term_end
								AND x.leg = sdd.leg
						INNER JOIN dbo.SplitCommaSeperatedValues(''' + @deal_header_ids_transer + ''') t
							ON x.source_deal_header_id = t.item

					OPEN @get_source_deal_detail_id
					FETCH NEXT
					FROM @get_source_deal_detail_id INTO @flag, @source_deal_detail_id, @xml_value, @apply_to_xml, @is_apply_to_all, @call_from, @process_id
					WHILE @@FETCH_STATUS = 0
					BEGIN
						EXEC [dbo].[spa_deal_pricing_detail_provisional] @flag = @flag,
															@source_deal_detail_id = @source_deal_detail_id,
															@xml = @xml_value,
															@apply_to_xml = @apply_to_xml,
															@is_apply_to_all = @is_apply_to_all,
															@call_from = @call_from,
															@process_id = @process_id,
															@mode = ''save'',
															@xml_process_id = NULL
					FETCH NEXT
					FROM @get_source_deal_detail_id INTO @flag, @source_deal_detail_id, @xml_value, @apply_to_xml, @is_apply_to_all, @call_from, @process_id
					END
					CLOSE @get_source_deal_detail_id
					DEALLOCATE @get_source_deal_detail_id
				'
			
				EXEC spa_run_multi_step_job @job_name = 'deal_provisional_pricing_insert_job_Xfer', @step1 = @sql, @process_id = @provisional_price_process_id	
			END

			DECLARE @internal_desk_id  INT 

			SELECT @internal_desk_id = internal_desk_id 
			FROM source_deal_header sdh
			INNER JOIN #temp_deal_transfer t ON t.parent_source_deal_header_id = sdh.source_deal_header_id

			IF @internal_desk_id in (17301, 17302) 
			BEGIN
				DECLARE @transfer_deal_id NVARCHAR(2000)
						, @offset_deal_id  NVARCHAR(2000)
						, @user_name NVARCHAR(100)
						
				SET @user_name = dbo.FNADBUser()	
		
				SELECT @transfer_deal_id = ISNULL(@transfer_deal_id + ', ', '') +  CAST(source_deal_header_id AS NVARCHAR(10))
				FROM source_deal_header sdh
				INNER JOIN #temp_deal_transfer t ON t.parent_source_deal_header_id = sdh.close_reference_id

				SELECT @offset_deal_id = ISNULL(@offset_deal_id + ', ', '') +  CAST(source_deal_header_id AS NVARCHAR(10))
				FROM source_deal_header sdh
				INNER JOIN SplitCommaSeperatedValues(@transfer_deal_id) t
					ON sdh.close_reference_id = t.item

				IF OBJECT_ID('tempdb..#vol_mul') IS NOT NULL
					DROP TABLE #vol_mul

				SELECT sdd.source_deal_detail_id, (volume_per/100 ) vol_multiplier
				INTO #vol_mul
				FROM #temp_deal_transfer t
				INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = t.parent_source_deal_header_id

				IF @internal_desk_id = 17301 --Forecast Deal
				BEGIN
					UPDATE sdd
					SET volume_multiplier2 =  vm.vol_multiplier
					FROM source_deal_detail sdd
					INNER JOIN #vol_mul vm ON vm.source_deal_detail_id = sdd.source_deal_detail_id
					INNER JOIN SplitCommaSeperatedValues(ISNULL(@transfer_deal_id + ',', '') + @offset_deal_id) t
						ON sdd.source_deal_header_id = t.item
				END
			
				IF OBJECT_ID('tempdb..#volume_percent') IS NOT NULL
					DROP TABLE #volume_percent
			
				SELECT source_deal_header_id, CAST(volume_percent AS NUMERIC(38,20)) volume_percent
				INTO #volume_percent
				FROM #temp_transfer_deal_headers
				UNION ALL
				SELECT source_deal_header_id, CAST(volume_percent AS NUMERIC(38,20)) volume_percent 
				FROM #temp_offset_deal_headers			

				IF OBJECT_ID('tempdb..#price_options') IS NOT NULL
					DROP TABLE #price_options
			
				SELECT source_deal_header_id, CAST(fixed_price AS NUMERIC(38,20)) fixed_price, pricing_options
				INTO #price_options
				FROM #temp_transfer_deal_headers
				UNION ALL
				SELECT source_deal_header_id, CAST(fixed_price AS NUMERIC(38,20)) fixed_price, pricing_options
				FROM #temp_offset_deal_headers

				IF @internal_desk_id = 17302 --SHAPED DEAL
				BEGIN 
					DECLARE @trans_offset NVARCHAR(MAX)

					SET @trans_offset =  ISNULL(@transfer_deal_id + ',', '') + ISNULL(@offset_deal_id, '')

					SET @trans_offset = IIF(@offset_deal_id IS NULL, LEFT(@trans_offset, LEN(@trans_offset) - 1 ), @trans_offset)
				
					INSERT INTO source_deal_detail_hour (
						source_deal_detail_id 				
						, term_date	
						, hr	
						, is_dst	
						, volume	
						, price	
						, formula_id	
						, granularity
						, schedule_volume
						, actual_volume
						, contractual_volume
						, period
					)			
					SELECT  sdd.source_deal_detail_id
							, sddh.term_date	
							, sddh.hr	
							, sddh.is_dst							
						    , sddh.volume
							--, sddh.price
							, CASE WHEN po.pricing_options = 'd' THEN sddh.price WHEN po.pricing_options = 'x' THEN po.fixed_price ELSE NULL END price
							, sddh.formula_id	
							, sddh.granularity
							, sddh.schedule_volume
							, sddh.actual_volume
							, sddh.contractual_volume
							, sddh.period
					FROM source_deal_detail sdd
					INNER JOIN SplitCommaSeperatedValues(@trans_offset) t
						ON sdd.source_deal_header_id = t.item
					INNER JOIN source_deal_detail sdd_old
						ON sdd.term_start = sdd_old.term_start
						AND sdd.term_end = sdd_old.term_end
						AND sdd.leg = sdd_old.leg
					INNER JOIN SplitCommaSeperatedValues(@source_deal_header_id) td
						ON td.item = sdd_old.source_deal_header_id
					INNER JOIN source_Deal_detail_hour sddh
						ON sddh.source_deal_detail_id = sdd_old.source_deal_detail_id
					INNER JOIN #vol_mul v ON v.source_deal_detail_id = sdd_old.source_deal_detail_id
					INNER JOIN #volume_percent vp
						ON vp.source_deal_header_id = sdd.source_deal_header_id
					LEFT JOIN source_Deal_detail_hour sddh1
						ON sdd.source_deal_detail_id = sddh1.source_deal_detail_id
					INNER JOIN #price_options po ON po.source_deal_header_id = sdd.source_deal_header_id
					WHERE sddh1.source_deal_detail_id IS NULL
				END					
			END

			EXEC spa_ErrorHandler 0
				, 'Deal Transfer'
				, 'spa_deal_transfer_new'
				, 'Success'
				, 'The deal is successfully transfered.'
				, ''
		
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		DECLARE @err      NVARCHAR(1000),
		        @err_no   INT
		        
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN
			
		IF ERROR_NUMBER() = 2627
			SET @err = 'The selected deal has already been transferred. It cannot be transferred again.'
		ELSE
			SELECT  @err=ERROR_MESSAGE()
			
		SELECT @err_no = error_number()
		
		EXEC spa_ErrorHandler @err_no
				, 'Deal Transfer'
				, 'spa_deal_transfer_new'
				, 'DB Error'
				, @err
				, ''
	END CATCH
END

GO
