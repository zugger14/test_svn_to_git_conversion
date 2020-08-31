
if object_id('spa_get_delivered_percentage') is not null
	drop proc dbo.spa_get_delivered_percentage

go

create proc dbo.spa_get_delivered_percentage
	@location_id int,
	@source_deal_detail_id int
as

/*

--select * from source_deal_detail where source_deal_header_id=30893

declare @location_id int=429,
	@source_deal_detail_id int=80458

IF OBJECT_ID(N'tempdb..#temp_transport_deal') IS NOT NULL
	DROP TABLE #temp_transport_deal

IF OBJECT_ID ('tempdb..#total_scheduled_deals') IS NOT NULL 
	DROP TABLE #total_scheduled_deals

IF OBJECT_ID ('tempdb..#list_template') IS NOT NULL 
	DROP TABLE #list_template


-- */

DECLARE @term_start VARCHAR(10),@term_end VARCHAR(10),@_source_Deal_header_id INT,@_loan_deal_id INT
DECLARE  @sdv_from_deal	INT, @sql	VARCHAR(8000),@trans_volume numeric(30,10)

SELECT 
	@_loan_deal_id = sdd1.source_deal_detail_id
	, @_source_Deal_header_id=isnull(sdd1.source_deal_detail_id,sdd.source_Deal_header_id)
	, @term_start = CONVERT(VARCHAR(10),isnull(sdd1.term_start,sdd.term_start),120)
	, @term_end = CONVERT(VARCHAR(10),isnull(sdd1.term_end,sdd.term_end),120)
FROM  source_deal_header sdh
INNER JOIN source_deal_detail sdd ON  sdh.source_deal_header_id = sdd.source_deal_header_id
INNER JOIN user_defined_deal_fields_template uddft ON  uddft.template_id = sdh.template_id 
	AND uddft.field_label = 'Loan Deal ID'
INNER join user_defined_deal_fields uddf ON uddf.source_deal_header_id = sdh.source_deal_header_id and uddft.udf_template_id = uddf.udf_template_id
left JOIN source_deal_detail sdd1 ON sdd1.source_deal_header_id = uddf.udf_value
WHERE
	sdd.source_deal_detail_id= @source_deal_detail_id



SELECT @sdv_from_deal = value_id
FROM static_data_value
WHERE [TYPE_ID] = 5500 AND code = 'From Deal'


SELECT gmv.clm1_value template_type_id, sdht.template_id 
into #list_template
FROM generic_mapping_header gmh
INNER JOIN generic_mapping_values gmv ON gmh.mapping_table_id = gmv.mapping_table_id 
	AND gmh.mapping_name = 'Imbalance Report'
LEFT JOIN source_deal_header_template sdht ON cast(sdht.template_id AS VARCHAR(100)) = gmv.clm3_value
WHERE gmv.clm1_value IN ('1','5')
	


SELECT distinct sdh.source_deal_header_id, uddf_sch.udf_value schedule_id
INTO #total_scheduled_deals  --   select * from #total_scheduled_deals
FROM [user_defined_deal_fields_template] uddft
INNER JOIN source_deal_header_template sdht ON sdht.template_id = uddft.template_id
INNER JOIN #list_template lt ON lt.template_id = sdht.template_id
INNER JOIN  user_defined_deal_fields uddf ON uddf.udf_template_id = uddft.udf_template_id 
	AND uddft.field_name = @sdv_from_deal 
	AND uddf.udf_value = CAST(@_source_Deal_header_id AS VARCHAR(10))
INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = uddf.source_deal_header_id
INNER JOIN user_defined_deal_fields_template uddft_sch ON sdh.template_id = uddft_sch.template_id
INNER JOIN user_defined_deal_fields uddf_sch ON uddf_sch.udf_template_id = uddft_sch.udf_template_id 
	AND sdh.source_deal_header_id = uddf_sch.source_deal_header_id
	and uddft_sch.Field_label='Scheduled ID'

SELECT tsd.source_deal_header_id deal_id, dp.path_id [path],tsd.schedule_id
	, max(CASE WHEN sdd.leg = 1 THEN sdd.Location_id ELSE NULL END) receipt_location
	, max(CASE WHEN sdd.leg = 2 THEN sdd.Location_id ELSE NULL END) delivery_location
	, sum(CASE WHEN sdd.leg = 1 THEN sdd.deal_volume ELSE NULL END) receipt_volume
	, sum(CASE WHEN sdd.leg = 2 THEN sdd.deal_volume ELSE NULL END) delivery_volume
INTO #temp_transport_deal --  select * from #temp_transport_deal
FROM  #total_scheduled_deals tsd 
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = tsd.source_deal_header_id
	INNER JOIN deal_schedule ds ON ds.deal_schedule_id = tsd.schedule_id
	INNER JOIN delivery_path dp ON dp.path_id = ds.path_id
	--LEFT JOIN source_minor_location sm1 ON sm1.source_minor_location_id = sdd.location_id
WHERE sdd.term_start BETWEEN @term_start AND @term_end
group by tsd.source_deal_header_id,dp.path_id,tsd.schedule_id	

Update ttd
SET ttd.receipt_volume = ttd1.receipt_volume
FROM #temp_transport_deal ttd
CROSS APPLY
(
	 SELECT MIN(schedule_id) schedule_id FROM #temp_transport_deal WHERE deal_id = ttd.deal_id AND ttd.path = path and (receipt_volume <> 0 or delivery_volume <> 0)
) a --Added by PNM, receipt/delivery volumes <> 0, else redirects were being used.
INNER JOIN #temp_transport_deal ttd1 ON ttd1.deal_id = ttd.deal_id  AND ttd1.schedule_id = a.schedule_id 
	AND ttd1.receipt_location<>ttd.receipt_location and (ttd.receipt_volume <> 0 or ttd.delivery_volume <> 0)

;WITH CTE AS (	
	SELECT dp.to_location 
	FROM delivery_path dp
		INNER JOIN #temp_transport_deal ttd ON dp.path_id = ttd.path
		INNER JOIN delivery_path_detail dpd ON dpd.Path_id = dp.path_id
	WHERE dp.groupPath = 'y'
)
DELETE ttd FROM #temp_transport_deal ttd 
INNER JOIN delivery_path dp ON  ttd.path=dp.path_id AND dp.groupPath = 'y'
 WHERE ttd.delivery_location  NOT IN (SELECT to_location FROM CTE)
	 AND EXISTS(SELECT 'x' FROM CTE)


SELECT @trans_volume=SUM(receipt_volume) 
 FROM #temp_transport_deal ttd WHERE ttd.delivery_location =@location_id

SELECT max(term_start) [prod_date],
       0 [hr],
       0 [mins],
	   --Added by PNM, Loan payback deals were using main_volume from the payback, and transporation from the loan this causes multipliers > 1. The case statement will cap multiplier at 1
        case when (ROUND(@trans_volume/nullif(SUM(deal_volume),0), 5)) < 1 then (ROUND(@trans_volume/nullif(SUM(deal_volume),0), 5)) 
		when (ROUND(@trans_volume/nullif(SUM(deal_volume),0), 5)) is null then null else 1 end [Value]
--[__final_output__]          
FROM    source_deal_detail sdd 
WHERE sdd.source_deal_detail_id =  @source_deal_detail_id
