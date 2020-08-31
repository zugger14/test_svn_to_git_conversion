
IF OBJECT_ID(N'[dbo].[spa_adjust_rec_deals]', N'P') IS NOT NULL
   DROP PROCEDURE [dbo].[spa_adjust_rec_deals]
GO



-- exec spa_adjust_rec_deals '06/01/2006', 90, 'urbaral', null


CREATE PROCEDURE [dbo].[spa_adjust_rec_deals] (@contract_month datetime, @counterparty_id int,
				@user_id varchar(50), 
				@deal_id varchar(50) = null -- not used now.. we might  need in  the  future
				)
AS


---adjust for prior months

set @contract_month = dateadd(mm, -1, dbo.FNAGetContractMonth(@contract_month))
-- select @contract_month
-- return

--------Step 1 .. Find Deals that need processing
--------You have to join this with deal tables and other table you need  to create 
--------final output that would be inserted into Transactions table (delete old records first)
--------
-- This gives a list of deals (deal_id would be same as source_deal_header.structure_deal_id)
--TRUNCATE TABLE Transactions

-- select convert(datetime, @contract_month, 102)
-- select convert(datetime, contract_month, 102) from inventory_prior_month_adjustements

SELECT ipma.deal_id, change_volume_to, change_price_to 
into #temp_process_deals
from inventory_prior_month_adjustements ipma 
where   (ipma.process_status IS NULL OR ipma.process_status <> 'c')
	 AND convert(datetime, contract_month, 102) = convert(datetime, @contract_month, 102)

--select * from #temp_process_deals

-- INSERT INTO [Transactions] (
-- 	[Book],
-- 	[Feeder System ID],
-- 	[Gen Date From],
-- 	[Gen Date To],
-- 	[Volume],
-- 	[UOM],
-- 	[Price],
-- 	[Formula],
-- 	[Counterparty],
-- 	[Generator],
-- 	[GIS],
-- 	[GIS Certificate Number],
-- 	[GIS Certificate Date],
-- 	[Deal Type],
-- 	[Deal Sub Type],
-- 	[Trader],
-- 	[Broker],
-- 	[Index],
-- 	[Frequency],
-- 	[Deal Date],
-- 	[Currency],
-- 	[Category],
-- 	[buy_sell_flag]
-- )
-- 
-- SELECT  SB.source_system_book_id ,
--  	SDH.structured_deal_id, 
-- 	dbo.FNADateFormat(SDH.entire_term_start) entire_term_start,
-- 	dbo.FNADateFormat(SDH.entire_term_end) entire_term_end,
--  	ipma.change_volume_to,
-- 	SUOM.uom_name ,
-- 	ipma.change_price_to,
-- 	NULL Formula,
--  	SDH.counterparty_id , 
--  	RG.code , 
--         coalesce(SV.code, SV2.code) GIS,   --DRP.gis_value_id , 
--  	NULL gis_cert_number , 
--  	NULL gis_cert_date,
-- 	SDH.source_deal_type_id,
-- 	SDH.deal_sub_type_type_id,
-- 	SDH.trader_id,
-- 	SDH.broker_id,
-- 	SDD.curve_id,
-- 	SDD.deal_volume_frequency,
-- 	dbo.FNADateFormat(SDH.deal_date) deal_date,
-- 	SDD.fixed_price_currency_id,
-- 	SDH.deal_category_value_id,
-- 	SDD.buy_sell_flag
--  FROM  
-- 	(select * from #temp_process_deals) ipma 
-- 	INNER JOIN	
-- 		(select structured_deal_id, max(entire_term_start) entire_term_start, 
-- 			max(entire_term_end) entire_term_end, max(counterparty_id) counterparty_id, 
-- 			max(source_deal_type_id) source_deal_type_id, max(deal_sub_type_type_id) deal_sub_type_type_id, 
-- 			max(trader_id) trader_id, max(broker_id) broker_id, max(deal_date) deal_date, 
-- 			max(deal_category_value_id) deal_category_value_id,
-- 			max(source_system_book_id1) source_system_book_id1 
-- 		  from 	source_deal_header 
-- 		  where structured_deal_id IN (select distinct deal_id from #temp_process_deals)
-- 		  group by structured_deal_id) SDH ON
-- 			ipma.deal_id = SDH.structured_deal_id
-- 	INNER JOIN 
-- 		(select 	structured_deal_id, max(curve_id) curve_id, max(deal_volume_frequency) deal_volume_frequency, 
-- 			max(fixed_price_currency_id) fixed_price_currency_id, max(buy_sell_flag) buy_sell_flag, 
-- 			max(deal_volume_uom_id) deal_volume_uom_id
-- 		from source_deal_detail (NOLOCK) inner join source_deal_header on 
-- 		source_deal_header.source_deal_header_id = source_deal_detail.source_deal_header_id
-- 		where structured_deal_id IN (select distinct deal_id from #temp_process_deals)
-- 		group by structured_deal_id) SDD ON 
-- 		SDD. structured_deal_id = SDH.structured_deal_id
-- 	INNER JOIN
-- 		(select 	structured_deal_id, max(generator_id) generator_id, max(gis_value_id) gis_value_id
-- 		from deal_rec_properties (NOLOCK) inner join source_deal_header on 
-- 		source_deal_header.source_deal_header_id = deal_rec_properties.source_deal_header_id
-- 		where structured_deal_id IN (select distinct deal_id from #temp_process_deals)
-- 		group by structured_deal_id) DRP ON SDH.structured_deal_id = DRP.structured_deal_id
-- 	INNER JOIN
--                 source_book SB (NOLOCK)	ON SDH.source_system_book_id1 = SB.source_book_id 
-- 	INNER JOIN 
-- 		source_uom SUOM (NOLOCK) ON SDD.deal_volume_uom_id = SUOM.source_uom_id 
-- 	INNER JOIN
--                 rec_generator RG (NOLOCK)	ON DRP.generator_id = RG.generator_id
-- 	INNER JOIN 
-- 		(SELECT distinct structured_deal_id from Transaction_staging (NOLOCK)
-- 			where structured_deal_id IN (select distinct deal_id from #temp_process_deals)) staging on 
-- 			staging.structured_deal_id = ipma.deal_id
-- 	LEFT OUTER JOIN
--                       static_data_value SV (NOLOCK) ON DRP.gis_value_id = SV.value_id -- SV.code
-- 	LEFT OUTER JOIN
--                       static_data_value SV2 (NOLOCK) ON rg.gis_value_id = SV2.value_id
-- 
-- WHERE SDH.counterparty_id = @counterparty_id
-- 

-- select * from Transactions
-- Return

-- SELECT  --SDH.source_deal_header_id, 
-- 	DISTINCT
-- 	SB.source_system_book_id ,
--  	SDH.structured_deal_id, 
-- 	dbo.FNADateFormat(SDH.entire_term_start) entire_term_start,
-- 	dbo.FNADateFormat(SDH.entire_term_end) entire_term_end,
--  	ipma.change_volume_to,
-- 	SUOM.uom_name ,
-- 	ipma.change_price_to,
-- 	NULL Formula,
--  	SDH.counterparty_id , 
--  	RG.code , 
--         coalesce(SV.code, SV2.code) GIS,   --DRP.gis_value_id , 
--  	NULL gis_cert_number , 
--  	NULL gis_cert_date,
-- 	SDH.source_deal_type_id,
-- 	SDH.deal_sub_type_type_id,
-- 	SDH.trader_id,
-- 	SDH.broker_id,
-- 	SDD.curve_id,
-- 	SDD.deal_volume_frequency,
-- 	SDH.deal_date,
-- 	SDD.fixed_price_currency_id,
-- 	SDH.deal_category_value_id,
-- 	SDD.buy_sell_flag
--  FROM         source_deal_header SDH (NOLOCK)
--  	INNER JOIN
--                        source_deal_detail SDD (NOLOCK) ON SDH.source_deal_header_id = SDD.source_deal_header_id 
--  	INNER JOIN
--                        deal_rec_properties DRP(NOLOCK) ON SDH.source_deal_header_id = DRP.source_deal_header_id
-- 	INNER JOIN
--                    	source_book SB (NOLOCK)	ON SDH.source_system_book_id1 = SB. source_book_id 
-- 	INNER JOIN 
-- 			source_uom SUOM (NOLOCK) ON SDD.deal_volume_uom_id = SUOM.source_uom_id 
-- 	INNER JOIN
--                       rec_generator RG (NOLOCK)	ON DRP.generator_id = RG.generator_id
-- 	INNER JOIN 
-- 		inventory_prior_month_adjustements ipma ON ipma.deal_id = SDH.structured_deal_id
-- 	INNER JOIN 
-- 		(SELECT distinct structured_deal_id from Transaction_staging) staging on 
-- 			staging.structured_deal_id = ipma.deal_id
-- 	LEFT OUTER JOIN
--                       static_data_value SV ON DRP.gis_value_id = SV.value_id -- SV.code
-- 	LEFT OUTER JOIN
--                       static_data_value SV2 (NOLOCK) ON rg.gis_value_id = SV2.value_id
-- 
-- where   (ipma.process_status IS NULL OR ipma.process_status <> 'c')
-- 	 AND contract_month = @contract_month
-- 	AND SDH.counterparty_id = @counterparty_id

--------Step 2 .. Make updates to deals
--EXEC dbo.spb_Process_Transactions @user_id

--select * from source_deal
-----------============Update deals that are not auto generated
update source_deal_detail
set 	fixed_price = isnull(change_price_to, fixed_price), 
	formula_id = case when (change_price_to is not null and 
isnull(change_price_to, -1) <> isnull(original_price, -1)) then null else formula_id end, 
	deal_volume = isnull(ipma.change_volume_to, deal_volume)
from  source_deal_detail sdd inner join inventory_prior_month_adjustements ipma
on ipma.deal_id=sdd.source_deal_detail_id 
-- (
-- select * from inventory_prior_month_adjustements
where   (process_status IS NULL OR process_status <> 'c')
	 AND contract_month = @contract_month
	AND ipma.counterparty_id = @counterparty_id
	--AND deal_id not in (SELECT distinct structured_deal_id from Transaction_staging)) ipma  on
--ipma.deal_id = isnull(sdh.structured_deal_id, isnull(sdh.deal_id, cast(sdh.source_deal_header_id as varchar))
--)

insert into gis_deal_adjustment(source_deal_header_id,original_volume,change_volume_to,status_value_id,status_date)
select deal_id,original_volume,change_volume_to,5170,getdate() from inventory_prior_month_adjustements
where (process_status IS NULL OR process_status <> 'c')
	 AND contract_month = @contract_month
	AND counterparty_id = @counterparty_id 
	and original_volume > change_volume_to

--------Step 3 .. Update the status in the  inventory_prior_month_adjustements table for all
--------processed deals
UPDATE inventory_prior_month_adjustements set process_status = 'c'
where 	contract_month = @contract_month
	AND counterparty_id = @counterparty_id 
--	AND deal_id in (SELECT distinct [feeder system id] from transactions)


--------Ste 4 .. Return status.. MAKE ERRORS DESCRIPTIVE PLEASE
If @@ERROR <> 0
BEGIN
	-- I think we should insert detail errors in msgboard which might be done by 
	-- dbo.spb_Process_Transactions already????
	
	Exec spa_ErrorHandler @@ERROR, 'Adjust RECS', 
			'spa_adjust_rec_deals', 'Error', 
			'Failed to  adjust REC deals', ''



END
Else
	Exec spa_ErrorHandler 0, 'Adjust RECS', 
			'spa_adjust_rec_deals', 'Success', 
			'Selected REC Deals adjusted. Please review the results.', ''












