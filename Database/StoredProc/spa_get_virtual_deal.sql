IF OBJECT_ID(N'[dbo].[spa_get_virtual_deal]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_get_virtual_deal]
GO 

-- spa_get_virtual_deal 126,'2005-12-31','i','s'
CREATE PROC [dbo].[spa_get_virtual_deal]
	@entity_id VARCHAR(50) = NULL, 
	@deal_date_to VARCHAR(20) = NULL,
	@hedge_or_item CHAR(1) = 'h',
	@rptOption CHAR(1) = NULL
--	@deal_date_to varchar(20)

AS
SET @entity_id = ABS(@entity_id)
DECLARE @sql_stmt VARCHAR(8000)
DECLARE @sql_where VARCHAR(8000)
DECLARE @group1 VARCHAR(100), @group2 VARCHAR(100), @group3 VARCHAR(100), @group4 VARCHAR(100)
--select * from source_deal_detail where source_deal_header_id  in (select source_deal_header_id from source_deal_header)
	SET @group1='Group1'
	SET @group2='Group2'
	SET @group3='Group3'
	SET @group4='Group4'
IF EXISTS(SELECT group1,group2,group3,group4 FROM source_book_mapping_clm)
BEGIN	
	SELECT @group1=group1,@group2=group2,@group3=group3,@group4=group4 FROM source_book_mapping_clm
END
IF @rptOption='d' or @rptOption is null
BEGIN
	SET @sql_stmt = '
	SELECT     	
		sdh.source_deal_header_id AS [Deal ID], 
		--cast(round(sdh.percentage_included, 2) as varchar) AS [Perc Included], 
		dbo.FNADateFormat(sdh.deal_date) AS [Deal Date], 
		source_deal_detail.Leg AS Leg, 
		dbo.FNADateFormat(source_deal_detail.term_start) AS [Term Start], 
		dbo.FNADateFormat(source_deal_detail.term_end) AS [Term End], 
		dbo.FNAHyperLinkText(10131000,sdh.deal_id,sdh.source_deal_header_id)  AS [Source Deal ID], 
		(case source_deal_detail.fixed_float_leg when ''f'' then ''Fixed'' Else ''Float'' end) AS [Fixed Float], 
		case source_deal_detail.buy_sell_flag when ''b'' then ''Buy (Receive)'' Else ''Sell (Pay)'' end AS [Buy/Sell], 
		cast(round(source_deal_detail.deal_volume, 2) as varchar) AS Volume, 
		(case source_deal_detail.deal_volume_frequency when ''m'' then ''Monthly'' Else ''Daily'' end) AS Frequency, source_uom.uom_name AS UOM, source_price_curve_def.curve_name AS [Index],
		cast(round(source_deal_detail.fixed_price,3) as varchar) Price, 
		cast(isnull(source_deal_detail.option_strike_price, '''') as varchar) as [Strike Price],
		source_currency.currency_name as Currency,  
		Book1.source_book_name AS [Portfolio Name], 
		Book2.source_book_name AS [Strategy Name], 
		Book3.source_book_name AS [IAS39 Contract], 
		Book4.source_book_name AS [Transfer], 
		case sdh.option_type when ''c'' then ''Call'' when ''p'' then ''Put'' else '''' end AS [Option Type], 
		case sdh.option_excercise_type when ''e'' then ''European'' when ''a'' then ''American'' else sdh.option_excercise_type end AS [Excercise Type]
	FROM                     	
		source_deal_header sdh INNER JOIN
		source_book Book1 ON sdh.source_system_book_id1 = Book1.source_book_id INNER JOIN
		source_book Book2 ON sdh.source_system_book_id2 = Book2.source_book_id INNER JOIN
		source_book Book3 ON sdh.source_system_book_id3 = Book3.source_book_id INNER JOIN
		source_book Book4 ON sdh.source_system_book_id4 = Book4.source_book_id INNER JOIN
		source_deal_detail ON sdh.source_deal_header_id = source_deal_detail.source_deal_header_id INNER JOIN
		source_uom ON source_deal_detail.deal_volume_uom_id = source_uom.source_uom_id LEFT OUTER JOIN
		source_price_curve_def ON source_deal_detail.curve_id = source_price_curve_def.source_curve_def_id LEFT OUTER JOIN
		source_currency ON source_currency.source_currency_id = source_deal_detail.fixed_price_currency_id
		join source_system_book_map ssbm
		on sdh.source_system_book_id1=ssbm.source_system_book_id1 and 
		sdh.source_system_book_id2=ssbm.source_system_book_id2 and
		sdh.source_system_book_id3=ssbm.source_system_book_id3 and
		sdh.source_system_book_id4=ssbm.source_system_book_id4 
		inner join
		portfolio_hierarchy fb ON 	fb.entity_id = ssbm.fas_book_id INNER JOIN
		fas_strategy fs ON fs.fas_strategy_id = fb.parent_entity_id INNER JOIN
		portfolio_hierarchy fstr ON fstr.entity_id = fs.fas_strategy_id INNER JOIN
		portfolio_hierarchy fsub ON fsub.entity_id = fstr.parent_entity_id
	WHERE 	
	1=1 '+
	CASE WHEN @entity_id is null 
	THEN 
	'' 
	ELSE 
	' and (fb.entity_id='+ @entity_id	+ ' or fstr.entity_id='+ @entity_id	+ ' or fstr.parent_entity_id='+ @entity_id+')'
	END
	+
	CASE @hedge_or_item 
		WHEN 'h' THEN ' and (isnull(sdh.fas_deal_type_value_id,ssbm.fas_deal_type_value_id)=400)' 
		WHEN 'i' THEN ' and (isnull(sdh.fas_deal_type_value_id,ssbm.fas_deal_type_value_id)=401)' 
		ELSE ''
	END
	+
	CASE WHEN @deal_date_to IS NULL 
	THEN 
	'' 
	ELSE 
	' and (sdh.deal_date<='''+ @deal_date_to+''')'
	END
		--ssbm.fas_book_id=126 --AND upper(hedge_or_item) = ''H'' 
	+' ORDER BY sdh.source_deal_header_id, source_deal_detail.term_start, source_deal_detail.Leg'
END
ELSE
BEGIN
SET @sql_stmt = 'SELECT     	
				sdh.source_deal_header_id AS [Deal ID], 
			--	cast(round(fld.percentage_included, 2) as varchar) AS [Perc Included], 
				dbo.FNADateFormat(sdh.deal_date) AS [Deal Date], 
				max(source_deal_detail.Leg) AS Leg, 
                dbo.FNADateFormat(min(source_deal_detail.term_start)) AS [Term Start], 
				dbo.FNADateFormat(max(source_deal_detail.term_end)) AS [Term End], 
				dbo.FNAHyperLinkText(10131000,sdh.deal_id,sdh.source_deal_header_id)  AS [Source Deal ID], 
                max((case source_deal_detail.fixed_float_leg when ''f'' then ''Fixed'' Else ''Float'' end)) AS [Fixed/Float], 
				max(case sdh.header_buy_sell_flag when ''b'' then ''Buy (Receive)'' Else ''Sell (Pay)'' end) AS [Buy/Sell], 
				cast(round(sum(source_deal_detail.deal_volume)/max(source_deal_detail.Leg), 2) as varchar) AS Volume, 
                max(case source_deal_detail.deal_volume_frequency when ''m'' then ''Monthly'' Else ''Daily'' end) AS Frequency, 
				max(source_uom.uom_name) AS UOM, 
				max(source_price_curve_def.curve_name) AS [Index],
			--	cast(round(sum(source_deal_detail.fixed_price)/max(source_deal_detail.Leg),3) as varchar) Price, 
				cast(round(avg(case when source_deal_detail.fixed_price=0 then null else source_deal_detail.fixed_price end),3) as varchar) Price, 
				cast(isnull(avg(source_deal_detail.option_strike_price), '''') as varchar) [Strike Price],
				max(source_currency.currency_name) as Currency,  
                Book1.source_book_name AS ['+@group1+'], 
				Book2.source_book_name AS ['+@group2+'], Book3.source_book_name AS ['+@group3+'], 
                 Book4.source_book_name AS ['+@group4+'], 
				case sdh.option_type when ''c'' then ''Call'' when ''p'' then ''Put'' else '''' end AS [Option Type], 
				case sdh.option_excercise_type when ''e'' then ''European'' when ''a'' then ''American'' else sdh.option_excercise_type end AS [Excercise Type]
			--, sdh.link_id as [Link ID]
	FROM                     	
		source_deal_header sdh INNER JOIN
		source_book Book1 ON sdh.source_system_book_id1 = Book1.source_book_id INNER JOIN
		source_book Book2 ON sdh.source_system_book_id2 = Book2.source_book_id INNER JOIN
		source_book Book3 ON sdh.source_system_book_id3 = Book3.source_book_id INNER JOIN
		source_book Book4 ON sdh.source_system_book_id4 = Book4.source_book_id INNER JOIN
		source_deal_detail ON sdh.source_deal_header_id = source_deal_detail.source_deal_header_id INNER JOIN
		source_uom ON source_deal_detail.deal_volume_uom_id = source_uom.source_uom_id LEFT OUTER JOIN
		source_price_curve_def ON source_deal_detail.curve_id = source_price_curve_def.source_curve_def_id LEFT OUTER JOIN
		source_currency ON source_currency.source_currency_id = source_deal_detail.fixed_price_currency_id
		join source_system_book_map ssbm
		on sdh.source_system_book_id1=ssbm.source_system_book_id1 and 
		sdh.source_system_book_id2=ssbm.source_system_book_id2 and
		sdh.source_system_book_id3=ssbm.source_system_book_id3 and
		sdh.source_system_book_id4=ssbm.source_system_book_id4 
		inner join
		portfolio_hierarchy fb ON 	fb.entity_id = ssbm.fas_book_id INNER JOIN
		fas_strategy fs ON fs.fas_strategy_id = fb.parent_entity_id INNER JOIN
		portfolio_hierarchy fstr ON fstr.entity_id = fs.fas_strategy_id INNER JOIN
		portfolio_hierarchy fsub ON fsub.entity_id = fstr.parent_entity_id
	WHERE 	
	1=1 '+
	CASE WHEN @entity_id IS NULL
	THEN 
	'' 
	ELSE
	' and (fb.entity_id='+ @entity_id	+ ' or fstr.entity_id='+ @entity_id	+ ' or fstr.parent_entity_id='+ @entity_id+')'
	END
	+
	CASE @hedge_or_item 
		WHEN 'h' THEN ' and (isnull(sdh.fas_deal_type_value_id,ssbm.fas_deal_type_value_id)=400)' 
		WHEN 'i' THEN ' and (isnull(sdh.fas_deal_type_value_id,ssbm.fas_deal_type_value_id)=401)' 
		ELSE ''
	END
	+
	CASE WHEN @deal_date_to is null 
	THEN 
	'' 
	ELSE 
	' and (sdh.deal_date<='''+ @deal_date_to+''')'
	END
	+
' 
 group by sdh.source_deal_header_id,sdh.deal_id,dbo.FNADateFormat(sdh.deal_date),Book1.source_book_name,Book2.source_book_name,
					Book3.source_book_name, Book4.source_book_name,sdh.option_type,sdh.option_excercise_type
 ORDER BY sdh.source_deal_header_id, min(source_deal_detail.term_start), min(source_deal_detail.Leg)'

END
EXEC spa_print @sql_stmt
EXEC(@sql_stmt)




