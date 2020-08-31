/****** Object:  StoredProcedure [dbo].[spa_insert_position_schedule_xml]    Script Date: 09/15/2009 23:52:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_insert_position_schedule_xml]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_insert_position_schedule_xml]
/****** Object:  StoredProcedure [dbo].[spa_insert_position_schedule_xml]    Script Date: 09/15/2009 23:53:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spa_insert_position_schedule_xml]
	@flag  VARCHAR(2),
	@book_deal_type_map_id INT ,	-- Not used
	@frequency VARCHAR(1) = 'd',	-- Not used
	@xmlValue TEXT=NULL,	
	@term_start DATETIME=NULL,
	@term_end DATETIME=NULL,
	@path_id INT=NULL,
	@volume_xml TEXT=NULL,
	@reverse CHAR(1) = NULL,
	@source_deal_detail_id INT = NULL,
	@call_from VARCHAR(50) = NULL

AS
/*
DECLARE @flag  varchar(2),
	@book_deal_type_map_id int ,	-- Not used
	@frequency varchar(1) ,	-- Not used
	@xmlValue VARCHAR(MAX),	
	@term_start datetime,
	@path_id Int


select @flag='i',
	@book_deal_type_map_id =26 ,	-- Not used
	@frequency ='d' ,	-- Not used
	@xmlValue=
	 '<Root><PSRecordset  edit_grid0="1" edit_grid1="0.02" edit_grid2="0.2" edit_grid3="30000" edit_grid4="30000" edit_grid5="23400" edit_grid6="7" edit_grid7="11" edit_grid8="20" edit_grid9="0"></PSRecordset>
 <PSRecordset  edit_grid0="2" edit_grid1="0.03" edit_grid2="0.2" edit_grid3="23400" edit_grid4="30000" edit_grid5="18018" edit_grid6="7" edit_grid7="13" edit_grid8="32" edit_grid9="1"></PSRecordset>
 <PSRecordset  edit_grid0="3" edit_grid1="0.05" edit_grid2="0.2" edit_grid3="18018" edit_grid4="30000" edit_grid5="13514" edit_grid6="7" edit_grid7="10" edit_grid8="37" edit_grid9="2"></PSRecordset></Root>'
,	
	@term_start ='2010-01-01',
	@path_id =1
	
	
drop table 	#source_deals
drop table #temp_header

---*/
DECLARE @process_id VARCHAR(50)
SET @process_id = REPLACE(NEWID(),'-','_')

DECLARE @internal_deal_subtype_value_id VARCHAR(30)
SET @internal_deal_subtype_value_id='Transportation'

DECLARE @sql VARCHAR(8000)
DECLARE @desc VARCHAR(500)	
DECLARE @idoc INT
DECLARE @doc VARCHAR(1000)
DECLARE @row INT 
DECLARE @from_source_deal_header_id INT
CREATE TABLE #temp_header(id INT)

EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlValue

-----------------------------------------------------------------
SELECT 
	row_no,
	clmRateSchedule,
	clmContract,
	clmLossFactor,
	clmFuelChange,
	clmScheduledVolume,
	clmAvailableVolume,
	clmDeliveredVolume,
	clmTrader,
	clmPipelineOwner,
	clmCounterpartyDelivered,
	clmCounterpartyReceive,
	clmPath,
	clmPathDetailId
INTO #source_deals
FROM   OPENXML (@idoc, '/Root/PSRecordset',2)
WITH ( 
	row_no INT					'@edit_grid0',
	clmPath VARCHAR(100)					'@edit_grid1',
	clmCounterpartyDelivered  CHAR(100)		'@edit_grid2',
	clmCounterpartyReceive  VARCHAR(100)	'@edit_grid3',	
	clmPipelineOwner VARCHAR(200)			'@edit_grid4',
	--clmLocationFrom VARCHAR(200)			'@edit_grid5',
	--clmLocationTo VARCHAR(200)				'@edit_grid6',
	clmScheduledVolume  NUMERIC(38,20)		'@edit_grid7',                 
    clmAvailableVolume  NUMERIC(38,20)		'@edit_grid8',  
	clmDeliveredVolume NUMERIC(38,20)		'@edit_grid9',                
	clmLossFactor VARCHAR(200)				'@edit_grid10',  
	clmFuelChange VARCHAR(200)				'@edit_grid11',   
	clmContract VARCHAR(200)				'@edit_grid12',
	clmRateSchedule VARCHAR(100)			'@edit_grid13',   
	clmPathDetailId INT						'@edit_grid14',
	clmTrader  VARCHAR(100)					'@edit_grid15'	
)

IF @call_from = 'Deal'
BEGIN
	SELECT @from_source_deal_header_id=source_deal_header_id FROM source_deal_detail WHERE source_deal_detail_id=@source_deal_detail_id
EXEC spa_print @from_source_deal_header_id
END


EXEC sp_xml_removedocument @idoc

EXEC sp_xml_preparedocument @idoc OUTPUT, @volume_xml  
SELECT   
 term,  
 volume  
INTO #schedule_volume  
FROM   OPENXML (@idoc, '/Root/PSRecordset',2)  
WITH (   
 term VARCHAR(100)      '@term_start',  
 volume VARCHAR(100)      '@volume'  
)  

EXEC sp_xml_removedocument @idoc 

--select * from #source_deals

UPDATE #source_deals SET clmTrader=NULL WHERE  clmTrader='NULL' OR clmTrader='' OR clmTrader=0
UPDATE #source_deals SET clmCounterpartyDelivered=NULL WHERE  clmCounterpartyDelivered='NULL' OR clmCounterpartyDelivered='' OR clmCounterpartyDelivered=0
UPDATE #source_deals SET clmCounterpartyDelivered=NULL WHERE  clmCounterpartyDelivered='NULL' OR clmCounterpartyDelivered='' OR clmCounterpartyDelivered=0
DELETE FROM #source_deals WHERE   clmCounterpartyDelivered IS NULL OR clmTrader IS NULL OR clmCounterpartyReceive IS NULL

DECLARE @temp_deal_id VARCHAR(1000)
DECLARE @new_header_id_dth VARCHAR(500)
DECLARE @from_curve VARCHAR(500)
DECLARE @new_header_id_dtd VARCHAR(500)
DECLARE @from_location VARCHAR(500)
DECLARE @from_meter VARCHAR(500)
DECLARE @to_curve VARCHAR(500)
DECLARE @to_location VARCHAR(500)
DECLARE @to_meter VARCHAR(500)
DECLARE @deliver_receiv VARCHAR(500)
--	DECLARE @counterparty VARCHAR(500)
SET @deliver_receiv='d'
	
DECLARE @deal_date DATETIME
SET @term_start = ISNULL(@term_start,GETDATE())
SET @term_end = ISNULL(@term_end,GETDATE())
SET @deal_date=@term_start

DECLARE  @temp_id VARCHAR(5000)
DECLARE  @count INT
DECLARE  @temp_source_deal_header_id VARCHAR(MAX)
SET @temp_source_deal_header_id='#'         

DECLARE @exp_date DATETIME

DECLARE	@map1 INT  ,@map2 INT, @map3 INT,@map4 INT
SELECT 	 @map1=source_system_book_id1
		   ,@map2=source_system_book_id2
		   ,@map3=source_system_book_id3
		   ,@map4=source_system_book_id4
FROM source_system_book_map WHERE book_deal_type_map_id=@book_deal_type_map_id
   


	

--	Select @counterparty=counterParty  from delivery_path where path_id=@path_id
	

CREATE TABLE #inserted_deals (
	source_deal_header_id INT, 
	term_start DATETIME, 
	term_end DATETIME,
	[deal_sub_type_type_id] INT,
	source_deal_type_id INT
)

CREATE TABLE #inserted_deal_detail (
	source_deal_header_id INT, 
	source_deal_detail_id INT,
	deal_volume FLOAT    
)

CREATE TABLE #inserted_deal_detail2 (
	source_deal_header_id INT, 
	source_deal_detail_id INT,	
	deal_volume FLOAT    
)

CREATE TABLE #inserted_dth (
	deal_transport_id INT, 
	source_deal_header_id INT 	
)
CREATE TABLE #inserted_deals_final (
	source_deal_header_id INT, 
	term_start DATETIME, 
	term_end DATETIME 	,[deal_sub_type_type_id] INT,source_deal_type_id INT
)

IF @flag='i'
BEGIN

--		set 	@process_id=cast(isNUll(IDENT_CURRENT('source_deal_header')+1,1) as varchar)+'-farrms'
	DECLARE @deal_status_new INT
	DECLARE @confirm_status_new INT 
	
	SELECT @confirm_status_new = sdv.value_id
	FROM   static_data_value sdv
	WHERE  sdv.[type_id] = 17200
	       AND sdv.code = 'Not Confirmed'
		
	SELECT @deal_status_new = srd.Change_to_status_id
	FROM   status_rule_detail srd
	       INNER JOIN status_rule_header srh
	            ON  srh.status_rule_id = srd.status_rule_id
	       LEFT JOIN static_data_value sdv1
	            ON  srd.event_id = sdv1.value_id
	            AND sdv1.[type_id] = 19500
	WHERE  srh.status_rule_name = 'Deal Status'
	       AND sdv1.code = 'deal insert'
	       AND srd.event_id = 19501

BEGIN TRY
BEGIN TRAN

		DECLARE b_cursor CURSOR FOR
		SELECT row_no,clmPathDetailId FROM #source_deals
		OPEN b_cursor
		FETCH NEXT FROM b_cursor INTO @row,@count
		WHILE @@FETCH_STATUS = 0   
		BEGIN 			
			
			DELETE FROM #inserted_deals
			DELETE FROM #inserted_deal_detail
			DELETE FROM #inserted_deal_detail2
			DELETE FROM #inserted_dth 

			INSERT INTO source_deal_header
					   ([source_system_id]
					   ,[deal_id]
					   ,[deal_date]
					   ,[physical_financial_flag]
					   ,[counterparty_id]
					   ,[entire_term_start]
					   ,[entire_term_end]
					   ,[source_deal_type_id]
					   ,[deal_sub_type_type_id]
					   ,[option_flag]
					   ,[option_type]					  		   
					   ,[source_system_book_id1]
					   ,[source_system_book_id2]
					   ,[source_system_book_id3]
					   ,[source_system_book_id4]
					   ,[deal_category_value_id]
					   ,[trader_id]
					   ,[header_buy_sell_flag]					  
					  	,create_user
						,create_ts
						,template_id,term_frequency
						,contract_id
						,confirm_status_type
						,deal_status
						
					   )
					   OUTPUT INSERTED.source_deal_header_id, INSERTED.entire_term_start, INSERTED.entire_term_end , INSERTED.[deal_sub_type_type_id],INSERTED.source_deal_type_id
					   INTO #inserted_deals 
			 SELECT 2
				, @process_id + '_' + CAST(row_no AS VARCHAR) + '_' + CONVERT(VARCHAR,fb.term_start,12)
				,fb.term_start					--,@deal_date
				,t.physical_financial_flag
			--	,@counterparty
				,p.counterparty
				,fb.term_start	--				,@term_start
				,fb.term_end	--				,@term_end
				,d.deal_type_id
				,d.[deal_sub_type_id]
				,t.option_flag
				,t.option_type
				,@map1
				,@map2
				,@map3
				,@map4		
				,475 --a.deal_category_value_id
				,a.clmTrader
				,t.header_buy_sell_flag				
				,dbo.FNADBUser()
				,GETDATE()
				,t.template_id,'d'
--				,template_id 
				,p.[CONTRACT] 
				,@confirm_status_new
				,@deal_status_new
			FROM  
				 source_deal_header_template t
				INNER JOIN [default_deal_post_values] d ON t.[template_id] = d.[template_id]
				INNER JOIN internal_deal_type_subtype_types i
				ON i.[internal_deal_type_subtype_id] = d.[internal_deal_type_subtype_id]
				AND i.internal_deal_type_subtype_type=@internal_deal_subtype_value_id
				INNER JOIN #source_deals a  ON 1=1 AND a.row_no = @row
				INNER JOIN (
						SELECT 
							path_id
						FROM 
							dbo.delivery_path 
						WHERE path_id=@path_id AND ISNULL(groupPath,'n')='n'
							UNION ALL 
						SELECT 
							dpd.path_name path_id
						FROM 
						delivery_path_detail dpd
						WHERE dpd.path_id =@path_id AND dpd.delivery_path_detail_id = @count 
					) pd ON 1=1
				INNER JOIN delivery_path p  ON  p.path_id=pd.path_id
				CROSS JOIN dbo.FNATermBreakdown(@frequency,@term_start,@term_end) fb
				WHERE  a.clmPathDetailId=@count
			
--			insert into #temp_header(id) values(IDENT_CURRENT('source_deal_header'))
--		
--			insert into #temp_header(id) values(IDENT_CURRENT('source_deal_header'))
		
			--PRINT @sql
			--EXEC(@sql)

--			select @temp_id = id from #temp_header			
--			EXEC spa_print @temp_id
--			TRUNCATE TABLE #temp_header 
			-- EXEC spa_print'here it is'
			--print @count
--			set @temp_source_deal_header_id = cast(@temp_source_deal_header_id as varchar(max))+ cast(@temp_id as varchar(max))+','
--			EXEC spa_print @temp_source_deal_header_id		
--	   



	SELECT @from_curve=term_pricing_index,@from_location=p.from_location,@to_location=p.to_location FROM source_minor_location s
	INNER JOIN delivery_path p  ON p.from_location =  s.source_minor_location_id
	INNER JOIN (
	
					SELECT 
						path_id
					FROM 
						dbo.delivery_path 
					WHERE path_id=@path_id AND ISNULL(groupPath,'n')='n'
						UNION ALL 
					SELECT 
						dpd.path_name path_id
					FROM 
					delivery_path_detail dpd
					WHERE dpd.path_id =@path_id AND dpd.delivery_path_detail_id = @count 
				) pd ON  p.path_id=pd.path_id

	EXEC spa_print @from_curve
	
----------------------Leg 1----------------------------------------
--	INSERT INTO [dbo].[deal_transport_header]([source_deal_header_id]) VALUES (@temp_id)
	INSERT INTO [dbo].[deal_transport_header]([source_deal_header_id]) 
	OUTPUT INSERTED.deal_transport_id, INSERTED.source_deal_header_id 
	INTO #inserted_dth
	SELECT source_deal_header_id FROM #inserted_deals
	
--	SET @new_header_id_dth=IDENT_CURRENT('deal_transport_header')
	/*Added for deal reference prefix start*/
	DECLARE @refrence_prefix VARCHAR(1000)
	
	SELECT @refrence_prefix = drip.prefix FROM source_deal_header sdh
	INNER JOIN #inserted_dth idth ON idth.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN deal_reference_id_prefix drip ON drip.deal_type = sdh.source_deal_type_id
	
	UPDATE sdh
	SET deal_id = ISNULL(@refrence_prefix, 'FARRMS_') + CAST(sdh.source_deal_header_id  AS VARCHAR(100))  
	FROM source_deal_header sdh
	INNER JOIN #inserted_dth idth ON idth.source_deal_header_id = sdh.source_deal_header_id 
	/*Added for deal reference prefix end*/

	/*-- code for update deal_status and confirm_deal_status ends*/
	/* This code is commented as it was already defined above
	DECLARE @deal_status_new INT
	DECLARE @confirm_status_new INT 
	SET @confirm_status_new = 17200
	
	SELECT @deal_status_new = srd.Change_to_status_id FROM status_rule_detail srd
	INNER JOIN status_rule_header srh ON srh.status_rule_id = srd.status_rule_id 
	LEFT JOIN static_data_value sdv1 ON srd.event_id = sdv1.value_id AND sdv1.[type_id] = 19500
	WHERE srh.status_rule_name = 'Deal Status'
	AND sdv1.code =  'deal insert'
	AND srd.event_id = 19501
	*/
	--5604 sdv for New
	
	UPDATE sdh
	SET deal_status = ISNULL(sdh.deal_status, @deal_status_new)
		, confirm_status_type = ISNULL(sdh.confirm_status_type, @confirm_status_new)
	FROM source_deal_header sdh
	INNER JOIN #inserted_deals idh ON idh.source_deal_header_id = sdh.source_deal_header_id 
	
	/*code for update deal_status and confirm_deal_status ends*/


	INSERT INTO [dbo].[source_deal_detail]
           ([source_deal_header_id]
           ,[term_start]
           ,[term_end]
           ,[Leg]
           ,[contract_expiration_date]
           ,[fixed_float_leg]
           ,[buy_sell_flag]
           ,[curve_id]
           ,[fixed_price]
           ,[fixed_price_currency_id]
           ,[deal_volume]
           ,[deal_volume_frequency]
           ,[deal_volume_uom_id]
           ,[block_description]
           ,[deal_detail_description]
           ,[volume_left]
           ,[create_user]
           ,[create_ts]
           ,[update_user]
           ,[update_ts]
           ,[location_id]
		   ,[physical_financial_flag]
			,[meter_id]
			,[pay_opposite]
           )
     OUTPUT INSERTED.source_deal_header_id, INSERTED.source_deal_detail_id ,INSERTED.deal_volume  
     INTO #inserted_deal_detail 
     SELECT 
			id.source_deal_header_id	--           @temp_id
			,id.term_start	--           ,cast(@term_start as datetime)
			,id.term_end	--           ,@term_start
           ,td.leg
			,id.term_start	--,@deal_date
           ,td.fixed_float_leg
           ,'s'
           ,@from_curve
           ,NULL --@price
           ,td.fixed_price_currency_id
           ,ABS(ISNULL(sv.volume,a.clmScheduledVolume))   ---abs(@leg1_vol)  
           ,@frequency
           ,td.[deal_volume_uom_id] --
           ,td.block_description
           ,'Transportation->Schedule->From'
           ,ABS(a.clmScheduledVolume)   ---abs(@leg1_vol)
           ,dbo.fnadbuser()
           ,GETDATE()
           ,dbo.fnadbuser()
           ,GETDATE()
           ,@from_location
		   ,'p'
		   ,dp.meter_from
		   ,'n'
	 FROM [dbo].[source_deal_detail_template] td INNER JOIN 
	[source_deal_header_template] t  ON td.template_id = t.template_id AND td.leg=1
	INNER JOIN [default_deal_post_values] d ON t.[template_id] = d.[template_id]
	INNER JOIN internal_deal_type_subtype_types i
		ON i.[internal_deal_type_subtype_id] = d.[internal_deal_type_subtype_id]
		AND i.internal_deal_type_subtype_type=@internal_deal_subtype_value_id

	LEFT JOIN #source_deals a  ON 1=1 --and   a.clmPathDetailId =@count 
			AND a.row_no = @row
	LEFT JOIN (
				SELECT 
						path_id,
						meter_from,
						'n' groupPath
				FROM 
						dbo.delivery_path 
					WHERE path_id=@path_id AND ISNULL(groupPath,'n')='n'
						UNION ALL 
					SELECT 
						dpd.path_name path_id,
						dp.meter_from meter_from,
						'y' groupPath

					FROM 
					delivery_path_detail dpd INNER JOIN delivery_path dp ON dp.Path_id = dpd.Path_name
					WHERE dpd.path_id =@path_id AND dpd.delivery_path_detail_id = @count 

	) dp ON   1=1 
	CROSS JOIN #inserted_deals id 
 LEFT JOIN #schedule_volume sv ON sv.term=id.term_start  

	SET @new_header_id_dtd=SCOPE_IDENTITY()

--print 'count'
--print @count
EXEC spa_print '/**************************cccccccc'
--INSERT INTO dbo.deal_transport_detail (deal_transport_id,source_deal_detail_id_from,source_deal_detail_id_to,volume)
--	Select
--		 @new_header_id_dth
--		 ,@new_header_id_dtd
--		 ,@new_header_id_dtd,
--			-1*abs(a.clmScheduledVolume)
--			 from #source_deals a where a.clmPathDetailId= @count and a.row_no = @row

INSERT INTO dbo.deal_transport_detail (deal_transport_id,source_deal_detail_id_from,source_deal_detail_id_to,volume)
SELECT
	dth.deal_transport_id	--@new_header_id_dth
	,idd.source_deal_detail_id	--,@new_header_id_dtd
	,idd.source_deal_detail_id	--,@new_header_id_dtd,
 ,-1*ABS(idd.deal_volume)  
FROM #source_deals a 
CROSS JOIN #inserted_deal_detail idd 
INNER JOIN deal_transport_header dth ON idd.source_deal_header_id = dth.source_deal_header_id 
WHERE a.clmPathDetailId= @count AND a.row_no = @row


------------------------Leg 2---------------------------------------------------
--	select @to_curve=term_pricing_index from source_minor_location where source_minor_location_id=@to_location


EXEC spa_print '/**************************'
SELECT @to_curve=term_pricing_index FROM source_minor_location s
	INNER JOIN delivery_path p  ON p.to_location =  s.source_minor_location_id
	INNER JOIN (
	
					SELECT 
						path_id
					FROM 
						dbo.delivery_path 
					WHERE path_id=@path_id AND ISNULL(groupPath,'n')='n'
						UNION ALL 
					SELECT 
						dpd.path_name path_id
					FROM 
					delivery_path_detail dpd 
					WHERE dpd.path_id =@path_id AND dpd.delivery_path_detail_id = @count 
				) pd ON  p.path_id=pd.path_id
				
EXEC spa_print @to_curve

	INSERT INTO [dbo].[source_deal_detail]
           ([source_deal_header_id]
           ,[term_start]
           ,[term_end]
           ,[Leg]
           ,[contract_expiration_date]
           ,[fixed_float_leg]
           ,[buy_sell_flag]
           ,[curve_id]
           ,[fixed_price]
           ,[fixed_price_currency_id]
           ,[deal_volume]
           ,[deal_volume_frequency]
           ,[deal_volume_uom_id]
           ,[block_description]
           ,[deal_detail_description]
           ,[volume_left]
           ,[create_user]
           ,[create_ts]
           ,[update_user]
           ,[update_ts]
           ,[location_id]
		   ,[physical_financial_flag]
			,[meter_id]
			,[pay_opposite]
           )
     OUTPUT INSERTED.source_deal_header_id, INSERTED.source_deal_detail_id ,INSERTED.deal_volume  
     INTO #inserted_deal_detail2
     SELECT 
           id.source_deal_header_id		--@temp_id
			,id.term_start		--           ,cast(@term_start as datetime)
			,id.term_end		--           ,@term_start
           ,td.leg
           ,id.term_start		--,@deal_date
           ,td.fixed_float_leg
           ,'b'
           ,@to_curve
           ,NULL --@price
           ,td.fixed_price_currency_id
           ,ABS(clmDeliveredVolume)  ---abs(@leg2_vol)
           ,@frequency
           ,td.[deal_volume_uom_id] --
           ,td.block_description
           ,'Transportation->Schedule->To'
           ,ABS(clmDeliveredVolume)  ---abs(@leg2_vol)
           ,dbo.fnadbuser()
           ,GETDATE()
           ,dbo.fnadbuser()
           ,GETDATE()
           ,@to_location
		   ,'p'
		   ,dp.meter_to
		   ,'n'
	FROM [dbo].[source_deal_detail_template] td INNER JOIN 
	[source_deal_header_template] t  ON td.template_id = t.template_id AND td.leg=2
	INNER JOIN [default_deal_post_values] d ON t.[template_id] = d.[template_id]
	INNER JOIN internal_deal_type_subtype_types i
		ON i.[internal_deal_type_subtype_id] = d.[internal_deal_type_subtype_id]
		AND i.internal_deal_type_subtype_type=@internal_deal_subtype_value_id
	LEFT JOIN #source_deals a  ON 1=1 --and   a.clmPathDetailId =@count 
			AND a.row_no = @row
	LEFT JOIN (
				SELECT 
						path_id,
						meter_to,
						'n' groupPath
				FROM 
						dbo.delivery_path 
					WHERE path_id=@path_id AND ISNULL(groupPath,'n')='n'
						UNION ALL 
					SELECT 
						dpd.path_name path_id,
						dp.meter_to meter_to,
						'y' groupPath

					FROM 
					delivery_path_detail dpd INNER JOIN delivery_path dp ON dp.Path_id = dpd.Path_name
					WHERE dpd.path_id =@path_id AND dpd.delivery_path_detail_id = @count 

	) dp ON   1=1 
	CROSS JOIN #inserted_deals id 
	
	
	
--	SET @new_header_id_dtd=IDENT_CURRENT('source_deal_detail')
--	INSERT INTO dbo.deal_transport_detail (deal_transport_id,source_deal_detail_id_from,source_deal_detail_id_to,volume)
--	Select
--		 @new_header_id_dth,@new_header_id_dtd,@new_header_id_dtd,
--			abs(a.clmDeliveredVolume)
--			 from #source_deals a  where a.clmPathDetailId= @count and a.row_no = @row

INSERT INTO dbo.deal_transport_detail (deal_transport_id,source_deal_detail_id_from,source_deal_detail_id_to,volume)
SELECT
	dth.deal_transport_id	--@new_header_id_dth
	,idd.source_deal_detail_id	--,@new_header_id_dtd
	,idd.source_deal_detail_id	--,@new_header_id_dtd,
   , -1*ABS(idd.deal_volume)  
FROM #source_deals a 
CROSS JOIN #inserted_deal_detail2 idd 
INNER JOIN deal_transport_header dth ON idd.source_deal_header_id = dth.source_deal_header_id 
WHERE a.clmPathDetailId= @count AND a.row_no = @row



/**********************End  leg2******************************************************/

		
/**********************insert into *[delivery_status]*****************************************************/
--	EXEC spa_compliance_workflow 109,'i',@temp_id,'Deal',null		 

		
  --INSERT INTO [dbo].[delivery_status]
		--	   ([deal_transport_id]
		--	   ,[delivery_status]
		--	   ,[status_timestamp]
		--	   ,[current_facility]
		--	   ,[estimated_delivery_date]
		--	   ,[estimated_delivery_time]
		--	   ,[memo1]
		--	   ,[memo2]
		--		,scheduled_volume
		--		,delivered_volume
  --  ,deal_transport_detail_id)  
		-- SELECT
		--	   idth.deal_transport_id	-- @new_header_id_dth
  --    --,case when @deliver_receiv='d' then  1655 else 1654 end    
  --    ,1655 -- status =nominated   
		--	   ,getdate()
		--	   ,case when @deliver_receiv='d' then  @from_location else @to_location end
		--	   ,null
		--	   ,null
		--	   ,null
		--	   ,null
  -- ,abs(b.deal_volume)  
		--	,NULL
  -- ,dtd.deal_transport_detail_id  
		--FROM #source_deals a 
		--CROSS JOIN #inserted_dth idth  
  --LEFT JOIN(select MIN(deal_transport_deatail_id) deal_transport_detail_id,deal_transport_id FROM deal_transport_detail GROUP BY deal_transport_id) dtd ON idth.deal_transport_id=dtd.deal_transport_id  
  --LEFT JOIN(SELECT id.source_deal_header_id,MAX(idd.deal_volume) deal_volume FROM #inserted_deals id LEFT JOIN #inserted_deal_detail idd ON id.source_deal_header_id=idd.source_deal_header_id GROUP BY id.source_deal_header_id) b ON idth.source_deal_header_id=b.source_deal_header_id  
		--where   a.clmPathDetailId= @count and a.row_no = @row


/**********************insert into *[user_defined_deal_fields]*****************************************************/
 DECLARE @Dcounterparty_value_id   VARCHAR(400),
         @Rcounterparty_value_id  VARCHAR(400),
         @Dfuel_charge            VARCHAR(400),
         @From_Deal               VARCHAR(10),
         @delivery_path_id        VARCHAR(20)
 
 SELECT @Rcounterparty_value_id = value_id
 FROM   static_data_value
 WHERE  code = 'Receiving Counterparty'
 
 SELECT @Dcounterparty_value_id = value_id
 FROM   static_data_value
 WHERE  code = 'Shipping Counterparty'
 
 SELECT @Dfuel_charge = value_id
 FROM   static_data_value
 WHERE  code = 'Fuel_Charge'
 
 SELECT @From_Deal = value_id
 FROM   static_data_value
 WHERE  code = 'From Deal'
 
 SELECT @delivery_path_id = value_id
 FROM   static_data_value sdv
 WHERE  sdv.code = 'Delivery Path'

--	EXEC spa_print @temp_id
EXEC spa_print @Dcounterparty_value_id
EXEC spa_print @Rcounterparty_value_id



  INSERT INTO [dbo].[user_defined_deal_fields]
			   ([source_deal_header_id]
			   ,[udf_template_id]
			   ,[udf_value]
			   ,[create_user]
			   ,[create_ts])
	 SELECT id.source_deal_header_id --@temp_id
	        , udf.udf_template_id,
	        CASE udf.field_name
	             WHEN @Dcounterparty_value_id THEN a.clmCounterpartyDelivered
	             WHEN @Rcounterparty_value_id THEN a.clmCounterpartyReceive
	             WHEN @Dfuel_charge THEN a.clmFuelChange
	             WHEN @From_Deal THEN @from_source_deal_header_id
	             WHEN @delivery_path_id THEN @path_id
	             ELSE trs.rate
	        END
		    ,dbo.fnadbuser()
		    ,GETDATE()
	 FROM  [dbo].[user_defined_deal_fields_template] udf 
			INNER JOIN [default_deal_post_values] d ON udf.[template_id] = d.[template_id] 
			INNER JOIN internal_deal_type_subtype_types i
			ON i.[internal_deal_type_subtype_id] = d.[internal_deal_type_subtype_id]
			AND i.internal_deal_type_subtype_type=@internal_deal_subtype_value_id
			INNER JOIN (
						SELECT 
							path_id
						FROM 
							dbo.delivery_path 
						WHERE path_id=@path_id AND ISNULL(groupPath,'n')='n'
							UNION ALL 
						SELECT 
							dpd.path_name path_id
						FROM 
						delivery_path_detail dpd
						WHERE dpd.path_id =@path_id AND dpd.delivery_path_detail_id = @count 
					) pd ON 1=1
			INNER JOIN delivery_path dp  ON  dp.path_id=pd.path_id
			LEFT JOIN transportation_rate_schedule trs ON udf.field_name = trs.rate_type_id 
--			and trs.rate_schedule_id=@schedule
			AND trs.rate_schedule_id=dp.rateSchedule
		--	Left JOIN delivery_path dp on dp.rateSchedule=trs.rate_schedule_id and dp.path_id=@path_id
			LEFT JOIN #source_deals a  ON 1=1 AND a.row_no = @row	-- and  a.clmPathDetailId=@count  
			CROSS JOIN #inserted_deals id 


/*******************************END***********************************************/
/*************Concatenate SourceDealHeader Id*************************************/

	SELECT @temp_id = COALESCE(@temp_id + ',' + CAST(source_deal_header_id AS VARCHAR), CAST(source_deal_header_id AS VARCHAR)) 
                                        FROM #inserted_deals  
                                        
	SET @temp_source_deal_header_id = CAST(@temp_source_deal_header_id AS VARCHAR(MAX))+ CAST(@temp_id AS VARCHAR(MAX))+','
	EXEC spa_print @temp_source_deal_header_id

	INSERT INTO #inserted_deals_final SELECT * FROM #inserted_deals

/*******************************END***********************************************/
/***********************Counter increment*****************************************/
--	     set @maxrow=@maxrow-1
--	     set @count=@count+1
/*******************************END***********************************************/

		EXEC spa_print '@count:', @count
		FETCH NEXT FROM b_cursor INTO @row,@count
	END
	CLOSE b_cursor
	DEALLOCATE  b_cursor
	EXEC spa_print 'end cursor'
	UPDATE source_deal_header SET deal_id =CAST(source_deal_header_id AS VARCHAR)+ '_farrms' WHERE deal_id LIKE @process_id+'%'
COMMIT TRAN

--select * from delivery_status

INSERT INTO  delivery_status(  
  deal_transport_id,estimated_delivery_date,status_timestamp,delivered_volume,deal_transport_detail_id,uom_id,source_deal_detail_id
  ,location_id,meter_id,pipeline_id,contract_id,receive_delivery,delivery_status
 )
SELECT dth.deal_transport_id,  
	sdd.term_start,  sdd.term_start,   ABS(sdd.deal_volume), dtd.deal_transport_deatail_id,
	  sdd.deal_volume_uom_id,  
	sdd.source_deal_detail_id,  
	sdd.location_id,  
	smlm.meter_id,  
	sdh1.counterparty_id,  
	sdh1.contract_id,  
	CASE WHEN sdd.Leg=1 THEN 'r' ELSE 'd' END  reciept_delivery  ,1650
FROM #inserted_deals_final sdh 
INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id  AND sdh.source_deal_type_id=57
INNER JOIN source_deal_header sdh1 ON sdh1.source_deal_header_id=sdh.source_deal_header_id
INNER JOIN deal_transport_header dth ON sdd.source_deal_header_id = dth.source_deal_header_id  
INNER JOIN deal_transport_detail dtd ON dtd.deal_transport_id = dth.deal_transport_id  
AND dtd.source_deal_detail_id_from =  sdd.source_deal_detail_id  
LEFT JOIN source_minor_location_meter smlm ON smlm.source_minor_location_id=sdd.location_id

UPDATE  delivery_status 
SET delivered_volume= ABS((CASE WHEN sdd1.buy_sell_flag ='s' THEN -1 ELSE 1 END * delivered_volume) +(CASE WHEN sdd.buy_sell_flag ='s' THEN -1 ELSE 1 END *sdd.deal_volume))
	 
FROM #inserted_deals_final sdh 
	INNER JOIN  source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id AND sdh.source_deal_type_id=93
	INNER JOIN source_deal_header h ON h.source_deal_header_id=sdh.source_deal_header_id
	INNER JOIN source_deal_header sdh1 ON sdh1.source_deal_header_id= case when sdh.source_deal_type_id=93 then CAST(REPLACE(h.deal_id,'CSHD_','') AS INT) ELSE -1 END 
	INNER JOIN source_deal_detail sdd1 ON sdd1.source_deal_header_id = sdh1.source_deal_header_id
CROSS APPLY (
	SELECT MAX(status_timestamp) as_of_date FROM delivery_status  WHERE source_deal_detail_id=sdd1.source_deal_detail_id
) dt
INNER JOIN delivery_status ds  ON ds.source_deal_detail_id=sdd1.source_deal_detail_id AND ds.status_timestamp=dt.as_of_date
	AND sdd.Leg=sdd1.Leg

DECLARE @report_position_deals VARCHAR(300),@user_login_id  VARCHAR(30),@spa VARCHAR(MAX),@job_name  VARCHAR(MAX)
 SET @user_login_id=dbo.fnadbuser()

 SET @report_position_deals = dbo.FNAProcessTableName('report_position', @user_login_id,@process_id)
 EXEC ('CREATE TABLE ' + @report_position_deals + '( source_deal_header_id INT, action CHAR(1))')
 
 --SET @sql = 'INSERT INTO ' + @report_position_deals + '(source_deal_header_id,action) SELECT  item ,''i'' from dbo.SplitCommaSeperatedValues( ''' + LEFT(Replace(@temp_source_deal_header_id, '#', ''), LEN(Replace(@temp_source_deal_header_id, '#', '') )-1)  + ''')'
 --PRINT '00000000000000000000000000000000'
 --PRINT @sql 
 --EXEC (@sql) 

SET @sql = 'INSERT INTO ' + @report_position_deals + '(source_deal_header_id,action) SELECT source_deal_header_id,''i''  from #inserted_deals_final'
EXEC spa_print '11111111111111111111111111111111111111111111'
EXEC spa_print  @sql
EXEC (@sql) 

-- reverse the buy_sell_flag if reverse is set true
DECLARE @detail_id VARCHAR(MAX)
SELECT @detail_id = COALESCE(@detail_id + ',' + CAST(source_deal_detail_id AS VARCHAR), CAST(source_deal_detail_id AS VARCHAR)) FROM source_deal_detail WHERE source_deal_header_id IN (SELECT item FROM dbo.SplitCommaSeperatedValues(@temp_id))
EXEC spa_print @detail_id
EXEC spa_print @temp_id
EXEC spa_print @temp_source_deal_header_id
IF @reverse = 'y'
BEGIN
	UPDATE source_deal_header
	SET header_buy_sell_flag = CASE WHEN header_buy_sell_flag = 'b' THEN 's' WHEN header_buy_sell_flag = 's' THEN 'b' ELSE '' END
	FROM source_deal_header
	WHERE source_deal_header_id IN (SELECT item FROM dbo.SplitCommaSeperatedValues(@temp_id))
	
	UPDATE source_deal_detail
	SET buy_sell_flag = CASE WHEN buy_sell_flag = 'b' THEN 's' WHEN buy_sell_flag = 's' THEN 'b' ELSE '' END
	FROM source_deal_detail
	WHERE source_deal_detail_id IN (SELECT item FROM dbo.SplitCommaSeperatedValues(@detail_id))	
END



 SET @spa = 'spa_update_deal_total_volume NULL,''' + CAST(@process_id AS VARCHAR(200)) + '''' 
 SET @job_name = 'spa_update_deal_total_volume_' + @process_id 
 EXEC spa_run_sp_as_job @job_name, @spa, 'spa_update_deal_total_volume', @user_login_id
--ROLLBACK
	EXEC spa_ErrorHandler 0, 'Transportation', 
					'spa_schedule_n_delivery', 'Success',
					'Successfully saved transportation deal.',@temp_source_deal_header_id	
END TRY
BEGIN CATCH
	DECLARE @err_no INT
	EXEC spa_print 'Catch Error'
	IF @@TRANCOUNT>0
	ROLLBACK	
	SELECT @err_no=ERROR_NUMBER()
	EXEC spa_ErrorHandler @err_no, 'Transportation', 
				'spa_schedule_n_delivery', 'Error',
				'Fail to save transportation deal.',''
END CATCH

END
/*****************End of 'i' flag****/
   
