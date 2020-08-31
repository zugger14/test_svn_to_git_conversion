
IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'[dbo].[spa_schedule_n_delivery]')
                    AND type IN ( N'P', N'PC' ) ) 
    DROP PROCEDURE [dbo].[spa_schedule_n_delivery]
GO
/****** Object:  StoredProcedure [dbo].[spa_schedule_n_delivery]    Script Date: 02/08/2009 10:40:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spa_schedule_n_delivery]
    @flag VARCHAR(1),
    @book_deal_type_map_id INT = NULL,
    @term_start VARCHAR(30) = NULL,
    @term_end VARCHAR(30) = NULL,
    @counterparty_id INT = NULL,
    @source_deal_detail_ids VARCHAR(1000) = NULL,
    @receipt_xml VARCHAR(MAX) = NULL,
    @delivery_xml VARCHAR(MAX) = NULL,
    @location_id INT = NULL,
    @trader INT = NULL,
    @broker_id INT = NULL,
    @deal_date VARCHAR(30) = NULL,
    @path_id INT = NULL,
    @frequency VARCHAR(1) = NULL,
    @commodity INT = NULL,
    @contract INT = NULL,
    @subsidiary VARCHAR(250) = NULL,
    @strategy VARCHAR(250) = NULL,
    @book VARCHAR(250) = NULL,
    @map1 INT = NULL,
    @map2 INT = NULL,
    @map3 INT = NULL,
    @map4 INT = NULL,
    @book_out CHAR(1) = 'n',  -- y=booked and n=not booked
    @uom INT = NULL,
	@meter_id VARCHAR(100)=NULL,
	@deal_type INT=NULL,
	@contract_id VARCHAR(100)=NULL
AS -------------------------- 


--declare @flag varchar(1)
--,@book_deal_type_map_id int 
--,@term_start varchar(30) 
--,@term_end varchar(30) 
--,@counterparty_id int 
--,@source_deal_detail_ids varchar(1000) 
--,@receipt_xml varchar(max) 
--,@delivery_xml varchar(max) 
--,@location_id int 
--,@trader int 
--,@broker_id int 
--,@deal_date varchar(30) 
--,@path_id int 
--,@frequency varchar(1) 
--,@commodity int 
--,@contract int 
--
--
--set @flag='i'
--set @book_deal_type_map_id=617
--set @term_start='2009-01-01'
--set @term_end='2009-03-01'
--set @counterparty_id=1
--set @source_deal_detail_ids =null
--set @receipt_xml ='<Root>
--<PSRecordset  id="8171" volume="10">
--</PSRecordset>
--<PSRecordset  id="8172" volume="10">
--</PSRecordset>
--</Root>'
--set @delivery_xml ='<Root>
--<PSRecordset  id="8177" volume="10">
--</PSRecordset>
--<PSRecordset  id="8178" volume="10">
--</PSRecordset>
--</Root>'
--set @location_id =null
--set @trader =1
--set @broker_id=1
--set @deal_date='2009-01-01'
--set @path_id=1
--set @frequency ='m'
--set @commodity=1
--set @contract=2
--
--
--drop table #receipt 
--drop table #delivery

--------------------------------------
DECLARE @sql_stmt VARCHAR(5000)
DECLARE @idoc INT
DECLARE @internal_deal_subtype_value_id VARCHAR(30)
IF @flag = 'z' --to populate the data in the deal type combo.
	BEGIN
		SELECT source_deal_type_id, source_deal_type_name FROM source_deal_type WHERE source_deal_type_id IN(57, 93, 94)
	END
ELSE
    IF @flag = 'b' 
        BEGIN
            DECLARE @capacity_NG VARCHAR(100)
            SET @capacity_NG = 'Capacity NG'

            SET @sql_stmt = 'select 
						sdd.source_deal_detail_id as [Source Deal Detail ID],
						dbo.FNADateFormat(sdd.term_start) as [Term Start],
						dbo.FNADateFormat(sdd.term_end) as [Term End],
						sc.counterparty_name as Counterparty,
						sml.Location_Name as Location,
						ROUND(sdd.volume_left* '
                + CASE WHEN @uom IS NULL THEN '1'
                       ELSE 'isnull(conv.conversion_factor,0)'
                  END + ',2) as Volume,
						sdd.buy_sell_flag [Buy/Sell],
						sdd.fixed_price as Price,'
                + CASE WHEN @uom IS NULL THEN 'su.uom_name'
                       ELSE 'su1.uom_name'
                  END
                + ' UOM,
						sdd.deal_volume-sdd.volume_left [Bookout Volume],
						isnull(sdd.Booked,''n'') [Booked Status]
					from source_deal_header sdh
					inner join internal_deal_type_subtype_types idt on idt.internal_deal_type_subtype_id=sdh.internal_deal_subtype_value_id
					and idt.internal_deal_type_subtype_type='''
                + @capacity_NG
                + '''
					join source_deal_detail sdd on sdd.source_deal_header_id = sdh.source_deal_header_id
					left outer join source_system_book_map sbmp ON
						sdh.source_system_book_id1 = sbmp.source_system_book_id1 AND 
						sdh.source_system_book_id2 = sbmp.source_system_book_id2 AND 
						sdh.source_system_book_id3 = sbmp.source_system_book_id3 AND 
						sdh.source_system_book_id4 = sbmp.source_system_book_id4
					left join portfolio_hierarchy book on book.entity_id=sbmp.fas_book_id
					left join portfolio_hierarchy strategy on strategy.entity_id=book.parent_entity_id
					left outer join source_counterparty sc on sc.source_counterparty_id = sdh.counterparty_id
					left outer join contract_group cg on cg.contract_id = sdh.contract_id 
					left outer join source_minor_location sml on sml.source_minor_location_id = sdd.location_id 
					left outer join source_uom su on su.source_uom_id = sdd.deal_volume_uom_id'
                + CASE WHEN @uom IS NULL THEN ''
                       ELSE '
					left join volume_unit_conversion conv on conv.from_source_uom_id=sdd.uom_id and conv.to_source_uom_id='
                            + ISNULL(CAST(@uom AS VARCHAR), '')
                            + ' 
					left outer join source_uom su1 on su1.source_uom_id =conv.to_source_uom_id '
                  END + '
					where 1=1 AND isnull(sdd.Booked,''n'')='''
                + ISNULL(@book_out, 'n') + ''''
					--AND cg.bookout_provision = ''y'' AND isnull(sdd.Booked,''n'')=''' + isnull(@book_out,'n') +''''
					
            exec spa_print  @sql_stmt 

            IF @term_start IS NOT NULL 
                SET @sql_stmt = @sql_stmt + ' AND sdd.term_start >= '''
                    + CAST(@term_start AS VARCHAR) + ''''

            IF @term_end IS NOT NULL 
                SET @sql_stmt = @sql_stmt + ' AND sdd.term_end <= '''
                    + CAST(@term_end AS VARCHAR) + ''''

            IF @counterparty_id IS NOT NULL 
                SET @sql_stmt = @sql_stmt + ' AND sdh.counterparty_id = '''
                    + CAST(@counterparty_id AS VARCHAR) + ''''

            IF @subsidiary IS NOT NULL 
                SET @sql_stmt = @sql_stmt
                    + ' AND strategy.parent_entity_id in (' + @subsidiary
                    + ')'
            IF @strategy IS NOT NULL 
                SET @sql_stmt = @sql_stmt + ' AND strategy.entity_id in ('
                    + @strategy + ')'
            IF @book IS NOT NULL 
                SET @sql_stmt = @sql_stmt + ' AND book.entity_id in (' + @book
                    + ')'

            exec spa_print  @sql_stmt 
            EXEC ( @sql_stmt
                )
				
        END
    ELSE 
        IF @flag = 'r' 
            BEGIN
                SET @sql_stmt = 'select 
						sdd.source_deal_detail_id,
						dbo.fnadateformat(sdh.deal_date) [Deal Date],
						dbo.FNADateFormat(sdd.term_start) as TermStart,
						dbo.FNADateFormat(sdd.term_end) as TermEnd,
						scm.commodity_name Commodity,
						sc.counterparty_name as Counterparty,
						sml.Location_Name as Location,
						sdd.volume_left as Volume,
						su.uom_name as UOM,
						isnull(sdd.Booked,''n'') Booked
					from source_deal_header sdh
					join source_deal_detail sdd on sdd.source_deal_header_id = sdh.source_deal_header_id
					left outer join source_system_book_map sbmp ON
						sdh.source_system_book_id1 = sbmp.source_system_book_id1 AND 
						sdh.source_system_book_id2 = sbmp.source_system_book_id2 AND 
						sdh.source_system_book_id3 = sbmp.source_system_book_id3 AND 
						sdh.source_system_book_id4 = sbmp.source_system_book_id4
					left join portfolio_hierarchy book on book.entity_id=sbmp.fas_book_id
					left join portfolio_hierarchy strategy on strategy.entity_id=book.parent_entity_id
					left outer join source_counterparty sc on sc.source_counterparty_id = sdh.counterparty_id
					left outer join contract_group cg on cg.contract_id = sdh.contract_id 
					left outer join source_minor_location sml on sml.source_minor_location_id = sdd.location_id 
					left outer join source_uom su on su.source_uom_id = sdd.deal_volume_uom_id
					left outer join source_commodity scm on scm.source_commodity_id = sdh.commodity_id
					where 1=1 
					AND  sdd.buy_sell_flag = ''b'' AND sdd.physical_financial_flag = ''p''
					AND isnull(sdd.Booked,''n'') <> ''y'' AND sdd.volume_left > 0'

                IF @term_start IS NOT NULL 
                    SET @sql_stmt = @sql_stmt + ' AND sdd.term_start >= '''
                        + CAST(@term_start AS VARCHAR) + ''''

                IF @term_end IS NOT NULL 
                    SET @sql_stmt = @sql_stmt + ' AND sdd.term_end <= '''
                        + CAST(@term_end AS VARCHAR) + ''''

                IF @counterparty_id IS NOT NULL 
                    SET @sql_stmt = @sql_stmt
                        + ' AND sdh.counterparty_id = '''
                        + CAST(@counterparty_id AS VARCHAR) + ''''

                IF @subsidiary IS NOT NULL 
                    SET @sql_stmt = @sql_stmt
                        + ' AND strategy.parent_entity_id in (' + @subsidiary
                        + ')'
                IF @strategy IS NOT NULL 
                    SET @sql_stmt = @sql_stmt + ' AND strategy.entity_id in ('
                        + @strategy + ')'
                IF @book IS NOT NULL 
                    SET @sql_stmt = @sql_stmt + ' AND book.entity_id in ('
                        + @book + ')'
                IF @commodity IS NOT NULL 
                    SET @sql_stmt = @sql_stmt + ' AND sdh.commodity_id = '
                        + CAST(@commodity AS VARCHAR)
                IF @frequency IS NOT NULL 
                    SET @sql_stmt = @sql_stmt
                        + ' AND sdd.[deal_volume_frequency] = ''' + @frequency
                        + ''''
	
                IF @location_id IS NOT NULL 
                    SET @sql_stmt = @sql_stmt + ' AND sdd.location_id = '
                        + CAST(@location_id AS VARCHAR)
                SET @sql_stmt = @sql_stmt
                    + ' ORDER BY sdh.deal_date,sdd.term_start'

                exec spa_print  @sql_stmt 

                EXEC ( @sql_stmt
                    )
            END
        ELSE 
            IF @flag = 'd' 
                BEGIN
                    SET @sql_stmt = 'select 
						sdd.source_deal_detail_id,
						dbo.fnadateformat(sdh.deal_date) [Deal Date],
						dbo.FNADateFormat(sdd.term_start) as TermStart,
						dbo.FNADateFormat(sdd.term_end) as TermEnd,
						scm.commodity_name Commodity,
						sc.counterparty_name as Counterparty,
						sml.Location_Name as Location,
						sdd.volume_left as Volume,
						su.uom_name as UOM,
						isnull(sdd.Booked,''n'') Booked
					from source_deal_header sdh
					join source_deal_detail sdd on sdd.source_deal_header_id = sdh.source_deal_header_id
					left outer join source_system_book_map sbmp ON
						sdh.source_system_book_id1 = sbmp.source_system_book_id1 AND 
						sdh.source_system_book_id2 = sbmp.source_system_book_id2 AND 
						sdh.source_system_book_id3 = sbmp.source_system_book_id3 AND 
						sdh.source_system_book_id4 = sbmp.source_system_book_id4
					left join portfolio_hierarchy book on book.entity_id=sbmp.fas_book_id
					left join portfolio_hierarchy strategy on strategy.entity_id=book.parent_entity_id
					left outer join source_counterparty sc on sc.source_counterparty_id = sdh.counterparty_id
					left outer join contract_group cg on cg.contract_id = sdh.contract_id 
					left outer join source_minor_location sml on sml.source_minor_location_id = sdd.location_id 
					left outer join source_uom su on su.source_uom_id = sdd.deal_volume_uom_id
					left outer join source_commodity scm on scm.source_commodity_id = sdh.commodity_id
					where 1=1 
					AND  sdd.buy_sell_flag = ''s'' AND sdd.physical_financial_flag = ''p''
					AND isnull(sdd.Booked,''n'') <> ''y'' AND sdd.volume_left > 0'

                    IF @term_start IS NOT NULL 
                        SET @sql_stmt = @sql_stmt
                            + ' AND sdd.term_start >= '''
                            + CAST(@term_start AS VARCHAR) + ''''

                    IF @term_end IS NOT NULL 
                        SET @sql_stmt = @sql_stmt + ' AND sdd.term_end <= '''
                            + CAST(@term_end AS VARCHAR) + ''''

                    IF @counterparty_id IS NOT NULL 
                        SET @sql_stmt = @sql_stmt
                            + ' AND sdh.counterparty_id = '''
                            + CAST(@counterparty_id AS VARCHAR) + ''''

                    IF @subsidiary IS NOT NULL 
                        SET @sql_stmt = @sql_stmt
                            + ' AND strategy.parent_entity_id in ('
                            + @subsidiary + ')'
                    IF @strategy IS NOT NULL 
                        SET @sql_stmt = @sql_stmt
                            + ' AND strategy.entity_id in (' + @strategy + ')'
                    IF @book IS NOT NULL 
                        SET @sql_stmt = @sql_stmt + ' AND book.entity_id in ('
                            + @book + ')'
                    IF @commodity IS NOT NULL 
                        SET @sql_stmt = @sql_stmt + ' AND sdh.commodity_id = '
                            + CAST(@commodity AS VARCHAR)
                    IF @frequency IS NOT NULL 
                        SET @sql_stmt = @sql_stmt
                            + ' AND sdd.[deal_volume_frequency] = '''
                            + @frequency + ''''
                    IF @location_id IS NOT NULL 
                        SET @sql_stmt = @sql_stmt + ' AND sdd.location_id = '
                            + CAST(@location_id AS VARCHAR)
                    SET @sql_stmt = @sql_stmt
                        + ' ORDER BY sdh.deal_date,sdd.term_start'

                    exec spa_print  @sql_stmt 

                    EXEC ( @sql_stmt
                        )

                END
            ELSE 
                IF @flag = 's' 
                    BEGIN

                        SET @sql_stmt = 'select
							dbo.FNAHyperLinkText(10131010, sdd.source_deal_header_id, sdd.source_deal_header_id),
							sdh.deal_id,
							max(sc.counterparty_name) Counterparty,
							mi.recorderid [Meter],
							dbo.FNADateFormat(sdd.term_start) as TermStart,
							MAX(sml.Location_Name) AS [Location],
							max(case when sdd.leg=2 then ''Deliver'' else ''Receive'' end) [Transport Type],  
							--case when sdd.leg=1 then dbo.FNAHyperLinkTextFourParameters(10161312,max(CAST(round(sdd.deal_volume,2) AS FLOAT)),dth.deal_transport_id, 1,dtd.deal_transport_deatail_id, dbo.FNADateFormat(sdd.term_start))  
							--else dbo.FNAHyperLinkTextFourParameters(10161312,max(CAST(round(sdd.deal_volume,2) AS FLOAT)),dth.deal_transport_id, 2,dtd.deal_transport_deatail_id, dbo.FNADateFormat(sdd.term_start)) end  [Nominated Volume],  
							--case when sdd.leg=1 then dbo.FNAHyperLinkTextFourParameters(10161312,max(CAST(round(ds.delivered_volume,2) AS FLOAT)),dth.deal_transport_id,1,dtd.deal_transport_deatail_id, dbo.FNADateFormat(sdd.term_start))   
							--else dbo.FNAHyperLinkTextFourParameters(10161312,max(CAST(round(ds.delivered_volume,2) AS FLOAT)),dth.deal_transport_id,2,dtd.deal_transport_deatail_id, dbo.FNADateFormat(sdd.term_start)) end [Actual Volume],  
							
							case when sdd.leg=1 then dbo.FNAHyperLinkTextFourParameters(10161312,dbo.FNARemoveTrailingZero(max(CAST(round(sdd.deal_volume,2) AS NUMERIC(38,20)))),dth.deal_transport_id, 1,dtd.deal_transport_deatail_id, dbo.FNADateFormat(sdd.term_start))  
							else dbo.FNAHyperLinkTextFourParameters(10161312,dbo.FNARemoveTrailingZero(max(CAST(round(sdd.deal_volume,2) AS NUMERIC(38,20)))),dth.deal_transport_id, 2,dtd.deal_transport_deatail_id, dbo.FNADateFormat(sdd.term_start)) end  [Nominated Volume],  
							case when sdd.leg=1 then dbo.FNAHyperLinkTextFourParameters(10161312,dbo.FNARemoveTrailingZero(max(CAST(round(ds.delivered_volume,2) AS NUMERIC(38,20)))),dth.deal_transport_id,1,dtd.deal_transport_deatail_id, dbo.FNADateFormat(sdd.term_start))   
							else dbo.FNAHyperLinkTextFourParameters(10161312,dbo.FNARemoveTrailingZero(max(CAST(round(ds.delivered_volume,2) AS NUMERIC(38,20)))),dth.deal_transport_id,2,dtd.deal_transport_deatail_id, dbo.FNADateFormat(sdd.term_start)) end [Actual Volume],  
							
							
							max(su.uom_name)  UOM,
							dth.deal_transport_id as [Deal Transport ID],
							max(ds.status_timestamp) status_timestamp
						from deal_transport_header dth 
						INNER JOIN deal_transport_detail dtd ON dth.deal_transport_id=dtd.deal_transport_id
						inner join source_deal_detail sdd on dtd.source_deal_detail_id_to =sdd.source_deal_detail_id
						inner join  source_deal_header sdh on sdd.source_deal_header_id = sdh.source_deal_header_id
						LEFT JOIN source_deal_detail sdd_next_leg ON sdh.source_deal_header_id = sdd_next_leg.source_deal_header_id
								AND sdd.leg <> sdd_next_leg.leg
							left outer join source_system_book_map sbmp ON
								sdh.source_system_book_id1 = sbmp.source_system_book_id1 AND 
								sdh.source_system_book_id2 = sbmp.source_system_book_id2 AND 
								sdh.source_system_book_id3 = sbmp.source_system_book_id3 AND 
								sdh.source_system_book_id4 = sbmp.source_system_book_id4
							left join portfolio_hierarchy book on book.entity_id=sbmp.fas_book_id
							left join portfolio_hierarchy strategy on strategy.entity_id=book.parent_entity_id
							left outer join source_counterparty sc on sc.source_counterparty_id = sdh.counterparty_id
							left outer join contract_group cg on cg.contract_id = sdh.contract_id 
							left outer join source_minor_location sml on sml.source_minor_location_id = sdd.location_id 
							left outer join source_uom su on su.source_uom_id = sdd.deal_volume_uom_id
							left outer join source_commodity scm on scm.source_commodity_id = sdh.commodity_id
							LEFT join source_minor_location_meter smlm ON smlm.meter_id=sdd.meter_id
							LEFT JOIN meter_id mi ON mi.meter_id=smlm.meter_id
							LEFT JOIN delivery_status ds ON ds.deal_transport_detail_id=dtd.deal_transport_deatail_id
							LEFT JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id					
						where 1=1 '

                        IF @term_start IS NOT NULL 
                            SET @sql_stmt = @sql_stmt
                                + ' AND (sdd.term_start >= '''
                                + CAST(@term_start AS VARCHAR) 
                                + ''' OR sdd_next_leg.term_start >= '''
                                + CAST(@term_start AS VARCHAR) + ''')'
                                

                        IF @term_end IS NOT NULL 
                            SET @sql_stmt = @sql_stmt
                                + ' AND (sdd.term_end <= '''
                                + CAST(@term_end AS VARCHAR) 
                                + ''' OR sdd_next_leg.term_end <= '''
                                + CAST(@term_end AS VARCHAR) + ''')'

                        IF @counterparty_id IS NOT NULL 
                            SET @sql_stmt = @sql_stmt
                                + ' AND sdh.counterparty_id = '''
                                + CAST(@counterparty_id AS VARCHAR) + ''''

                        IF @subsidiary IS NOT NULL 
                            SET @sql_stmt = @sql_stmt
                                + ' AND strategy.parent_entity_id in ('
                                + @subsidiary + ')'
                        IF @strategy IS NOT NULL 
                            SET @sql_stmt = @sql_stmt
                                + ' AND strategy.entity_id in (' + @strategy
                                + ')'
                        IF @book IS NOT NULL 
                            SET @sql_stmt = @sql_stmt
                                + ' AND book.entity_id in (' + @book + ')'
                        IF @location_id IS NOT NULL 
                            SET @sql_stmt = @sql_stmt
                                + ' AND (sdd.location_id = '
                                + CAST(@location_id AS VARCHAR)
                                + ' OR sdd_next_leg.location_id = '
                                + CAST(@location_id AS VARCHAR) + ')'

						IF @meter_id IS NOT NULL
							SET @sql_stmt = @sql_stmt+' AND (sdd.meter_id IN ('+CAST(@meter_id AS VARCHAR)+') OR  sdd_next_leg.meter_id IN ('+CAST(@meter_id AS VARCHAR)+'))'
						IF @deal_type IS NOT NULL
							SET @sql_stmt = @sql_stmt + 'AND sdt.source_deal_type_id=(' + CAST(@deal_type AS VARCHAR) + ')' 
					    IF @deal_type IS NULL	
					        SET @sql_stmt = @sql_stmt + 'AND sdt.source_deal_type_id IN (57, 93, 94)'
                        SET @sql_stmt = @sql_stmt
                            + ' group by sdd.source_deal_header_id, sdh.deal_id, dth.deal_transport_id,sdd.term_start,sdd.term_end,mi.recorderid,smlm.meter_id,dtd.deal_transport_deatail_id,sdd.leg,sdh.contract_id'
	

                        exec spa_print  @sql_stmt 
						CREATE TABLE #tmpTestForCTE(
									[ID] [int] IDENTITY(1,1) NOT NULL,
									[Deal ID] VARCHAR(200) COLLATE DATABASE_DEFAULT,
									[Deal Ref ID] VARCHAR(100) COLLATE DATABASE_DEFAULT,
									[Counterparty] VARCHAR(100) COLLATE DATABASE_DEFAULT,
									[Meter] VARCHAR(100) COLLATE DATABASE_DEFAULT,
									[TermStart] datetime,
									[Location] VARCHAR(100) COLLATE DATABASE_DEFAULT,
									[Transport Type] VARCHAR(100) COLLATE DATABASE_DEFAULT,
									[Nominated Volume] VARCHAR(1000) COLLATE DATABASE_DEFAULT,
									[Actual Volume] VARCHAR(1000) COLLATE DATABASE_DEFAULT,
									[UOM] VARCHAR(100) COLLATE DATABASE_DEFAULT,
									[Deal Transport ID] VARCHAR(100) COLLATE DATABASE_DEFAULT,
									[status_timestamp] DATETIME									
							)                
							--EXEC ( @sql_stmt)        
							INSERT INTO #tmpTestForCTE 
							EXEC ( @sql_stmt)
							exec spa_print @sql_stmt 
														
							SELECT ROW_NUMBER() OVER(
							           PARTITION BY 
							           dtd.deal_transport_deatail_id ORDER BY 
							           ds.status_timestamp DESC
							       ) AS a,
							       ds.deal_transport_id,
							       ds.status_timestamp,
							       ds.delivered_volume,
							       ds.deal_transport_detail_id,
							       CASE sdd.leg
							            WHEN 2 THEN 'Delivery'
							            ELSE 'Receive'
							       END [Transport Type]
							       INTO #temp
							FROM   delivery_status ds
							       INNER JOIN deal_transport_detail dtd
							            ON  ds.deal_transport_detail_id = dtd.deal_transport_deatail_id
							       INNER JOIN source_deal_detail sdd
							            ON  dtd.source_deal_detail_id_from = sdd.source_deal_detail_id
							ORDER BY
							       deal_transport_id,
							       status_timestamp DESC
							       
							       
							 SELECT * into #temp1 FROM  #temp WHERE a = 1
							
							;WITH Delivery_Transaction as(
								SELECT [Deal ID],
								       [Deal Ref ID],
								       [Counterparty],
								       [Meter],
								       [TermStart],
								       [Location],
								       [Transport Type],
								       [Nominated Volume],
								       [Actual Volume],
								       [UOM],
								       [Deal Transport ID],								       
								       [status_timestamp],
								       ROW_NUMBER() 
								       OVER(
								           PARTITION BY [Deal Transport ID] 
								           ORDER BY [status_timestamp] desc
								       ) AS rn
								FROM   #tmpTestForCTE
							)
							
							--SELECT * FROM Delivery_Transaction 
							--SELECT * FROM #tmpTestForCTE 		
							select [Deal ID], [Deal Ref ID],[Counterparty],
								max(case when [Transport Type]='Deliver' then [Meter] end) as [From Meter],
								max(case when [Transport Type]='Receive' then [Meter] end) as [To Meter],
								dbo.fnadateformat([TermStart]) as [Term Start],
								max(case when [Transport Type]='Deliver' then [Location] else NULL end) as [From Location],
								max(case when [Transport Type]='Receive' then [Location] else NULL end) as [To Location],
								max(case when [Transport Type]='Deliver' then [Nominated Volume] else NULL end) as [Nominated Deliver Volume],
								max(case when [Transport Type]='Receive' then [Nominated Volume] else NULL end) as [Nominated Receive Volume],
								max(case when [Transport Type]='Deliver' then [Actual Volume] END) as [Actual Deliver Volume],
								max(case when [Transport Type]='Receive' then [Actual Volume] END) as [Actual Receive Volume],
								[UOM],[Deal Transport ID], MAX([Transport Type]) [Transport Type]
								INTO #temp2
							FROM Delivery_Transaction dt
							
							group by [Deal ID],[Deal Ref ID], [Counterparty],[TermStart],[UOM], [Deal Transport ID]--, [Transport Type], [Actual Volume]
							--having ds.status_timestamp = max(ds.status_timestamp)
							order by [Deal ID]
							
							UPDATE t2
							SET    t2.[Actual Receive Volume] = dbo.FNAHyperLinkTextFourParameters(
							           10161312,
							           dbo.FNARemoveTrailingZero(CAST(ROUND(t1.delivered_volume, 2) AS NUMERIC(38,20))),
							           t1.deal_transport_id,
							           2,
							           t1.deal_transport_detail_id, dbo.FNADateFormat(t2.[Term Start])
							       )
							FROM   #temp2 t2
							       INNER JOIN #temp1 t1
							            ON  t2.[Deal Transport ID] = t1.deal_transport_id
							WHERE  t1.[Transport Type] = 'Receive'
							
							UPDATE t2
							SET    t2.[Actual Deliver Volume] = dbo.FNAHyperLinkTextFourParameters(
							           10161312,
							           dbo.FNARemoveTrailingZero(CAST(ROUND(t1.delivered_volume, 2) AS NUMERIC(38,20))),
							           t1.deal_transport_id,
							           2,
							           t1.deal_transport_detail_id, dbo.FNADateFormat(t2.[Term Start])
							       )
							FROM   #temp2 t2
							       INNER JOIN #temp1 t1
							            ON  t2.[Deal Transport ID] = t1.deal_transport_id
							WHERE  t1.[Transport Type] = 'Delivery'
						
							
							SELECT * FROM #temp2 t2
							
                    END
--------------------- following section is for showing matched deals in map --------------------------
-- Author: Milan Lamichhane
-- Date: 02/05/2009
--------------------------------------------------------------------------------------------------

                ELSE 
                    IF @flag = 'm' 
                        BEGIN
	
                            CREATE TABLE #temp_location
                                (
                                  transportation_from_id INT,
                                  transportation_from VARCHAR(1000) COLLATE DATABASE_DEFAULT,
                                  transportation_to_id INT,
                                  transportation_to VARCHAR(1000) COLLATE DATABASE_DEFAULT,
                                  ReceiptVolumn FLOAT,
                                  DeliveryVolumn FLOAT,
                                  MOU VARCHAR(500) COLLATE DATABASE_DEFAULT
                                )


                            SET @sql_stmt = 'INSERT INTO #temp_location 
					select 
						--max(sc.counterparty_name) Counterparty,
						--max(scm.commodity_name) Commodity,
						--dbo.FNADateFormat(sdd.term_start) as TermStart,
						max(case when sdd.leg=1 then sml.source_minor_location_id else null end) [Transport From ID],
						max(case when sdd.leg=1 then sml.Location_Name else null end) [Transport From],
						max(case when sdd.leg=2 then sml.source_minor_location_id else null end) [Transport To ID],
						max(case when sdd.leg=2 then sml.Location_Name else null end) [Transport To],
						max(case when sdd.leg=1 then sdd.deal_volume else null end) ReceiptVolume,
						max(case when sdd.leg=2 then sdd.deal_volume else null end) DeliveryVolume,
						max(su.uom_name)  UOM
				from deal_transport_header dth 
				
				INNER JOIN deal_transport_detail dtd ON dth.deal_transport_id=dtd.deal_transport_id
				inner join source_deal_detail sdd on dtd.source_deal_detail_id_to =sdd.source_deal_detail_id
				inner join  source_deal_header sdh on sdd.source_deal_header_id = sdh.source_deal_header_id
					left outer join source_system_book_map sbmp ON
						sdh.source_system_book_id1 = sbmp.source_system_book_id1 AND 
						sdh.source_system_book_id2 = sbmp.source_system_book_id2 AND 
						sdh.source_system_book_id3 = sbmp.source_system_book_id3 AND 
						sdh.source_system_book_id4 = sbmp.source_system_book_id4
					left join portfolio_hierarchy book on book.entity_id=sbmp.fas_book_id
					left join portfolio_hierarchy strategy on strategy.entity_id=book.parent_entity_id
					left outer join source_counterparty sc on sc.source_counterparty_id = sdh.counterparty_id
					left outer join contract_group cg on cg.contract_id = sdh.contract_id 
					left outer join source_minor_location sml on sml.source_minor_location_id = sdd.location_id 
					left outer join source_uom su on su.source_uom_id = sdd.deal_volume_uom_id
					left outer join source_commodity scm on scm.source_commodity_id = sdh.commodity_id
					where 1=1 '

                            IF @term_start IS NOT NULL 
                                SET @sql_stmt = @sql_stmt
                                    + ' AND sdd.term_start = '''
                                    + CAST(@term_start AS VARCHAR) + ''''

                            IF @term_end IS NOT NULL 
                                SET @sql_stmt = @sql_stmt
                                    + ' AND sdd.term_end = '''
                                    + CAST(@term_end AS VARCHAR) + ''''

                            IF @counterparty_id IS NOT NULL 
                                SET @sql_stmt = @sql_stmt
                                    + ' AND sdh.counterparty_id = '''
                                    + CAST(@counterparty_id AS VARCHAR) + ''''

                            IF @subsidiary IS NOT NULL 
                                SET @sql_stmt = @sql_stmt
                                    + ' AND strategy.parent_entity_id in ('
                                    + @subsidiary + ')'
                            IF @strategy IS NOT NULL 
                                SET @sql_stmt = @sql_stmt
                                    + ' AND strategy.entity_id in ('
                                    + @strategy + ')'
                            IF @book IS NOT NULL 
                                SET @sql_stmt = @sql_stmt
                                    + ' AND book.entity_id in (' + @book + ')'
                            IF @location_id IS NOT NULL 
                                SET @sql_stmt = @sql_stmt
                                    + ' AND sdd.location_id = '
                                    + CAST(@location_id AS VARCHAR)

                            SET @sql_stmt = @sql_stmt
                                + ' group by dth.deal_transport_id,sdd.term_start,sdd.term_end'
                            exec spa_print  @sql_stmt 

                            EXEC ( @sql_stmt
                                )
	
	--select * from #temp_location

                            SELECT  transportation_from_id [Transportation From ID],
                                    MAX(sml.x_position) [x_position],
                                    MAX(sml.y_position) [y_position],
                                    SUM(DeliveryVolumn) [DeliveryVolumn],
		--transportation_from [Transportation From],
                                    transportation_to_id [Transporation To ID],
                                    MAX(sml2.x_position) [x_position],
                                    MAX(sml2.y_position) [y_position],
		--transportation_to [Transporatation To],
                                    SUM(ReceiptVolumn) [ReceiptVolumn]
                            FROM    #temp_location tloc
                                    LEFT JOIN source_minor_location sml ON tloc.transportation_from_id = sml.source_minor_location_id
                                    LEFT JOIN source_minor_location sml2 ON tloc.transportation_to_id = sml2.source_minor_location_id
                            GROUP BY transportation_from_id,
                                    transportation_to_id
                        END
---------------------------------- end map section -----------------------------------------
                    ELSE 
                        IF @flag = 'u' 
                            BEGIN
                                BEGIN TRY
                                    EXEC sp_xml_preparedocument @idoc OUTPUT,
                                        @receipt_xml

                                    SELECT  *
                                    INTO    #booked
                                    FROM    OPENXML (@idoc, '/Root/PSRecordset',2)
                                            WITH ( id VARCHAR(50) '@id', volume FLOAT '@volume' )

                                    UPDATE  source_deal_detail
                                    SET     booked = 'y',
                                            volume_left = volume_left
                                            -- ISNULL(#booked.volume, 0)
                                    FROM    source_deal_detail
                                            INNER JOIN #booked ON source_deal_detail.source_deal_detail_id = #booked.id

                                    EXEC spa_ErrorHandler 0, 'Transportation',
                                        'spa_schedule_n_delivery', 'Success',
                                        'Successfully updated selected deal.',
                                        ''
                                END TRY

                                BEGIN CATCH
                                    DECLARE @err_no3 INT
                                    EXEC spa_print 'Catch Error'
                                    SELECT  @err_no3 = ERROR_NUMBER()
                                    EXEC spa_ErrorHandler @err_no3,
                                        'Transportation',
                                        'spa_schedule_n_delivery', 'Error',
                                        'Fail to update selected deal.', ''

                                END CATCH



                            END

                        ELSE 
                            IF @flag = 'n' 
                                BEGIN
                                    BEGIN TRY
                                        EXEC sp_xml_preparedocument @idoc OUTPUT,
                                            @receipt_xml
                                        SELECT  *
                                        INTO    #unbooked
                                        FROM    OPENXML (@idoc, '/Root/PSRecordset',2)
                                                WITH ( id VARCHAR(50) '@id' )
                                        EXEC sp_xml_removedocument @idoc

                                        EXEC sp_xml_preparedocument @idoc OUTPUT,
                                            @delivery_xml


                                        UPDATE  source_deal_detail
                                        SET     booked = 'n',
                                                volume_left = deal_volume
                                        FROM    source_deal_detail
                                                INNER JOIN #unbooked ON source_deal_detail.source_deal_detail_id = #unbooked.id

                                        EXEC spa_ErrorHandler 0,
                                            'Transportation',
                                            'spa_schedule_n_delivery',
                                            'Success',
                                            'Successfully updated selected deal.',
                                            ''
                                    END TRY

                                    BEGIN CATCH
                                        DECLARE @err_no2 INT
                                        EXEC spa_print 'Catch Error'
                                        SELECT  @err_no2 = ERROR_NUMBER()
                                        EXEC spa_ErrorHandler @err_no2,
                                            'Transportation',
                                            'spa_schedule_n_delivery', 'Error',
                                            'Fail to update selected deal.',
                                            ''

                                    END CATCH



                                END
--
--
--ELSE IF @flag='i'
--BEGIN
--	BEGIN try
--	exec sp_xml_preparedocument @idoc OUTPUT, @receipt_xml
--
--	--SELECT * 
--	--FROM   OPENXML (@idoc, '/Root/PSRecordset',2)
--
--	SELECT * into #receipt
--	FROM   OPENXML (@idoc, '/Root/PSRecordset',2)
--		WITH (
--			id varchar(50)	'@id',      
--			volume float    '@volume'
--	)
--	exec sp_xml_removedocument @idoc
--
--	exec sp_xml_preparedocument @idoc OUTPUT, @delivery_xml
--
--	SELECT * into #delivery
--	FROM   OPENXML (@idoc, '/Root/PSRecordset',2)
--		WITH (
--			id varchar(50)	'@id',      
--			volume float    '@volume'
--	)
--
--
----	declare  @source_system_book_id1 int
----           ,@source_system_book_id2 int
----           ,@source_system_book_id3 int
----           ,@source_system_book_id4 int
----			,@internal_deal_subtype_value_id varchar(100)
--
--	SELECT 	 @map1=source_system_book_id1
--			   ,@map2=source_system_book_id2
--			   ,@map3=source_system_book_id3
--			   ,@map4=source_system_book_id4
--	FROM source_system_book_map WHERE book_deal_type_map_id=@book_deal_type_map_id
--
--	SET @internal_deal_subtype_value_id='Transportation'
--
--	DECLARE  @ref_id  varchar(50),@new_header_id int,@price float,@currency_id int,@volume float
--			,@location_from int,@location_to int,@new_header_id_dth int ,@new_header_id_dtd int
--
--	SELECT @location_from=from_location_id,@location_to=to_location_id FROM delivery_path WHERE path_id=@path_id
--
--	set 	@ref_id=cast(isNUll(IDENT_CURRENT('source_deal_header')+1,1) as varchar)+'-farrms'
--
--	if @frequency='m'
--		set @term_end=dateadd(dd,-1,(dateadd(month,1,@term_start)))	
--	else if @frequency='q' 
--		set @term_end=dateadd(dd,-1,(dateadd(month,3,@term_start))	)
--	else if  @frequency='s'
--		set @term_end=dateadd(dd,-1,(dateadd(month,6,@term_start))	)
--	else if @frequency='a'
--		set @term_end=dateadd(dd,-1,(dateadd(month,12,@term_start)))	
--	else if @frequency='d'
--		set @term_end=@term_start
--	else if @frequency='w'
--		set @term_end=dateadd(dd,-1,(dateadd(day,7,@term_start)))
--
--	BEGIN tran
--	INSERT INTO [dbo].[source_deal_header] (
--			[source_system_id]
--           ,[deal_id]
--           ,[deal_date]
--           ,[physical_financial_flag]
--           ,[counterparty_id] ---????????
--           ,[entire_term_start]
--           ,[entire_term_end]
--           ,[source_deal_type_id]
--           ,[deal_sub_type_type_id]
--           ,[option_flag]
--           ,[option_type]
--           ,[source_system_book_id1]
--           ,[source_system_book_id2]
--           ,[source_system_book_id3]
--           ,[source_system_book_id4]
--           ,[description1]
--           ,[description2]
--           ,[description3]
--           ,[deal_category_value_id] --?????????
--           ,[trader_id] --?????????
--           ,[internal_deal_type_value_id]
--           ,[internal_deal_subtype_value_id]
--           ,[template_id]
--           ,[header_buy_sell_flag]
--			,broker_id
--           ,[create_user]
--           ,[create_ts]
--           ,[update_user]
--           ,[update_ts]
--			,contract_id
--	)
--     select
--           2
--           ,@ref_id
--           ,cast(@deal_date as datetime)
--           ,t.physical_financial_flag
--           ,@counterparty_id
--           ,@term_start
--           ,@term_end
--		  ,d.deal_type_id
--           ,d.[deal_sub_type_id]
--           ,t.option_flag
--           ,t.option_type
--           ,@map1
--           ,@map2
--           ,@map3
--           ,@map4
--           ,t.description1
--           ,t.description2
--           ,t.description3
--           ,475
--           ,@trader
--           ,t.internal_deal_type_value_id
--           ,t.internal_deal_subtype_value_id
--           ,t.template_id
--           ,t.buy_sell_flag
--           ,@broker_id
--           ,dbo.fnadbuser()
--           ,getdate()
--           ,dbo.fnadbuser()
--           ,getdate()
--			,@contract
--	from [dbo].[source_deal_header_template] t 
-- INNER JOIN [default_deal_post_values] d ON t.[template_id] = d.[template_id]
----	INNER JOIN [default_deal_post_values] d ON t.[internal_deal_subtype_value_id] = d.[internal_deal_type_subtype_id]
----		AND t.source_deal_type_id=d.deal_type_id AND t.deal_sub_type_type_id=d.[deal_sub_type_id]
--	INNER JOIN internal_deal_type_subtype_types i
--	ON i.[internal_deal_type_subtype_id] = d.[internal_deal_type_subtype_id]
--	AND i.internal_deal_type_subtype_type=@internal_deal_subtype_value_id
--
--	SET @new_header_id=scope_identity()
--
------------------------Start Receipt----------------------------------------
--	INSERT INTO [dbo].[deal_transport_header]([source_deal_header_id]) VALUES (@new_header_id)
--	SET @new_header_id_dth=scope_identity()
--
--	update source_deal_detail SET volume_left=volume_left-t.volume 
--		FROM source_deal_detail sdd INNER JOIN #receipt t ON sdd.source_deal_detail_id=t.id
--
--	SELECT @price=avg(fixed_price),@currency_id=max([fixed_price_currency_id]),@volume=sum(t.volume)
--			FROM source_deal_detail sdd INNER JOIN #receipt t ON sdd.source_deal_detail_id=t.id
--
--	INSERT INTO [dbo].[source_deal_detail]
--           ([source_deal_header_id]
--           ,[term_start]
--           ,[term_end]
--           ,[Leg]
--           ,[contract_expiration_date]
--           ,[fixed_float_leg]
--           ,[buy_sell_flag]
--           ,[curve_id]
--           ,[fixed_price]
--           ,[fixed_price_currency_id]
--           ,[deal_volume]
--           ,[deal_volume_frequency]
--           ,[deal_volume_uom_id]
--           ,[block_description]
--           ,[deal_detail_description]
--           ,[volume_left]
--           ,[create_user]
--           ,[create_ts]
--           ,[update_user]
--           ,[update_ts]
--           ,[location_id]
--		   ,[physical_financial_flag]
--		)
--     SELECT 
--           @new_header_id
--           ,cast(@term_start as datetime)
--           ,@term_end
--           ,td.leg
--           ,@term_end
--           ,td.fixed_float_leg
--           ,'b'
--           ,td.curve_id
--           ,@price
--           ,@currency_id
--           ,@volume ---
--           ,@frequency
--           ,td.[deal_volume_uom_id] --
--           ,td.block_description
--           ,'Transportation->Receipt'
--           ,@volume---
--           ,dbo.fnadbuser()
--           ,getdate()
--           ,dbo.fnadbuser()
--           ,getdate()
--           ,@location_from
--		   ,'p'
--	 FROM [dbo].[source_deal_detail_template] td INNER JOIN 
--	[source_deal_header_template] t  ON td.template_id = t.template_id AND td.leg=1
--	INNER JOIN [default_deal_post_values] d ON t.[template_id] = d.[template_id]
----	INNER JOIN [default_deal_post_values] d ON t.[internal_deal_subtype_value_id] = d.[internal_deal_type_subtype_id]
----		AND t.source_deal_type_id=d.deal_type_id AND t.deal_sub_type_type_id=d.[deal_sub_type_id]
--	INNER JOIN internal_deal_type_subtype_types i
--	ON i.[internal_deal_type_subtype_id] = d.[internal_deal_type_subtype_id]
--		AND i.internal_deal_type_subtype_type=@internal_deal_subtype_value_id
--
--	SET @new_header_id_dtd=scope_identity()
--	INSERT INTO dbo.deal_transport_detail (deal_transport_id,source_deal_detail_id_from,source_deal_detail_id_to,volume)
--	SELECT @new_header_id_dth,t.id,@new_header_id_dtd,t.volume FROM #receipt t
--
--
--
--
---------------------------Start Delivery---------------------------------------------------
--
--
--	update source_deal_detail SET volume_left=volume_left-t.volume 
--		FROM source_deal_detail sdd INNER JOIN #delivery t ON sdd.source_deal_detail_id=t.id
--
--
--	SELECT @price=avg(fixed_price),@currency_id=max([fixed_price_currency_id]),@volume=sum(t.volume)
--			FROM source_deal_detail sdd INNER JOIN #delivery t ON sdd.source_deal_detail_id=t.id
--
--	INSERT INTO [dbo].[source_deal_detail]
--           ([source_deal_header_id]
--           ,[term_start]
--           ,[term_end]
--           ,[Leg]
--           ,[contract_expiration_date]
--           ,[fixed_float_leg]
--           ,[buy_sell_flag]
--           ,[curve_id]
--           ,[fixed_price]
--           ,[fixed_price_currency_id]
--           ,[deal_volume]
--           ,[deal_volume_frequency]
--           ,[deal_volume_uom_id]
--           ,[block_description]
--           ,[deal_detail_description]
--           ,[volume_left]
--           ,[create_user]
--           ,[create_ts]
--           ,[update_user]
--           ,[update_ts]
--           ,[location_id]
--		   ,[physical_financial_flag]
--		)
--     SELECT 
--           @new_header_id
--           ,cast(@term_start as datetime)
--           ,@term_end
--           ,td.leg
--           ,@term_end
--           ,td.fixed_float_leg
--           ,'s'
--           ,td.curve_id
--           ,@price
--           ,@currency_id
--           ,@volume---
--           ,@frequency
--           ,td.[deal_volume_uom_id] --
--           ,td.block_description
--           ,'Transportation->Delivery'
--           ,@volume---
--           ,dbo.fnadbuser()
--           ,getdate()
--           ,dbo.fnadbuser()
--           ,getdate()
--           ,@location_to
--		   ,'p'
--	FROM [dbo].[source_deal_detail_template] td INNER JOIN 
--	[source_deal_header_template] t  ON td.template_id = t.template_id AND td.leg=2
-- INNER JOIN [default_deal_post_values] d ON t.[template_id] = d.[template_id]
----	INNER JOIN [default_deal_post_values] d ON t.[internal_deal_subtype_value_id] = d.[internal_deal_type_subtype_id]
----		AND t.source_deal_type_id=d.deal_type_id AND t.deal_sub_type_type_id=d.[deal_sub_type_id]
--	INNER JOIN internal_deal_type_subtype_types i
--	ON i.[internal_deal_type_subtype_id] = d.[internal_deal_type_subtype_id]
--	AND i.internal_deal_type_subtype_type=@internal_deal_subtype_value_id
--
--	SET @new_header_id_dtd=scope_identity()
--	INSERT INTO dbo.deal_transport_detail (deal_transport_id,source_deal_detail_id_from,source_deal_detail_id_to,volume)
--	SELECT @new_header_id_dth,t.id,@new_header_id_dtd,-1*t.volume FROM #delivery t
--
--	COMMIT tran
--	Exec spa_ErrorHandler 0, 'Transportation', 
--					'spa_schedule_n_delivery', 'Success',
--					'Successfully saved transportation deal.',''
--	END try
--	BEGIN catch
--		DECLARE @err_no int
--		EXEC spa_print 'Catch Error'
--		if @@TRANCOUNT>0
--		ROLLBACK	
--		SELECT @err_no=error_number()
--		Exec spa_ErrorHandler @err_no, 'Transportation', 
--					'spa_schedule_n_delivery', 'Error',
--					'Fail to save transportation deal.',''
--	END catch
--end





