

IF OBJECT_ID(N'[dbo].spa_faslinkdetail', N'P') IS NOT NULL
drop proc [dbo].spa_faslinkdetail
go

/*
exec spa_faslinkdetail 'i', 'i', '690', '130084', 1, 'h'
*/
create proc [dbo].[spa_faslinkdetail]
@flag char(1),
@flag2 char(1)=NULL,
@link_id BIGINT=NULL,
@source_deal_header_id varchar(5000)=NULL,
@percentage_included float=NULL, 
@hedge_or_item char(1)=NULL,
@summary_option char(1)=null,
@effective_date datetime=null,
@xml_filter TEXT = NULL,
@reference_id VARCHAR(500) = NULL

AS
SET NOCOUNT ON
--SELECT @flag, @flag2, @link_id, @source_deal_header_id, @percentage_included, @hedge_or_item, @summary_option, @effective_date
--return
DECLARE @percentage_available float
DECLARE @error_message varchar(1000)
--If @flag = 's' and @flag2= 'h'
DECLARE @sql_stmt As varchar(5000)
DECLARE @sql_where As varchar(2000)
DECLARE @sql_group_by As varchar(2000)
declare @dt datetime
DECLARE @link_effective_date varchar(20)
DECLARE @user_login_id VARCHAR(100) = dbo.FNADBUser()
DECLARE @temp_process_id VARCHAR(200) = dbo.FNAGETNEWID()
DECLARE @paging_process_table  VARCHAR(200)
SET @paging_process_table = dbo.FNAProcessTableName('paging_process_table', @user_login_id, @temp_process_id)
DECLARE @sql VARCHAR(MAX)
SET @link_id = NULLIF(@link_id,'')
--########### Group Label
declare @group1 varchar(100),@group2 varchar(100),@group3 varchar(100),@group4 varchar(100)
 if exists(select group1,group2,group3,group4 from source_book_mapping_clm)
begin	
	select @group1=group1,@group2=group2,@group3=group3,@group4=group4 from source_book_mapping_clm
end
else
begin
	set @group1='Group1'
	set @group2='Group2'
	set @group3='Group3'
	set @group4='Group4'
 
end
--######## End

select @link_effective_date = dbo.FNAGetSQLStandardDate(link_effective_date) from fas_link_header where link_id = @link_id

DECLARE @grid_process_table VARCHAR(100)

IF OBJECT_ID('tempdb..#tmp_filter_grid') IS NOT NULL
		DROP TABLE #tmp_filter_grid

CREATE TABLE #tmp_filter_grid (grid_process_table VARCHAR(100))

declare @sql_pc varchar(2000),  @link_deal_term_used_per varchar(200)
if OBJECT_ID(N'tempdb..#temp_per_used') is not null drop table #temp_per_used
if OBJECT_ID(N'tempdb..#collect_per_inc') is not null drop table #collect_per_inc
if OBJECT_ID(@link_deal_term_used_per) is not null exec('drop table '+@link_deal_term_used_per)

CREATE TABLE #temp_per_used (
	source_deal_header_id int,
	term_start date,
	used_per float
)

CREATE TABLE #collect_per_inc (
	source_deal_header_id int,
	percentage_included float
)

SET @link_deal_term_used_per = dbo.FNAProcessTableName('link_deal_term_used_per', dbo.FNADBUser(), dbo.fnagetnewid())

If @flag = 's' 
begin

if @summary_option='s'
SET @sql_stmt = 'SELECT     	
				fld.source_deal_header_id, 	
				dbo.FNATRMWinHyperlink(''a'', 10131010, sdh.deal_id, ABS(fld.source_deal_header_id),''n'',null,null,null,null,null,null,null,null,null,null,0)	AS [deal_id],
				dbo.FNARemoveTrailingZeroes(round(fld.percentage_included, 4))  AS [perc_included]
				,dbo.FNAGetSQLStandardDate(max(fld.effective_date)) [effective_date], 
				dbo.FNADateFormat(sdh.deal_date) AS [deal_date], 
                dbo.FNADateFormat(min(source_deal_detail.term_start)) AS [term_start], 
				dbo.FNADateFormat(max(source_deal_detail.term_end)) AS [term_end],
				max(case sdh.header_buy_sell_flag when ''b'' then ''Buy (Receive)'' Else ''Sell (Pay)'' end) AS [buy_sell],  
				dbo.FNARemoveTrailingZeroes(round(sum(source_deal_detail.total_volume)/max(source_deal_detail.Leg), 2)) AS volume, 
                max(case source_deal_detail.deal_volume_frequency when ''m'' then ''Monthly'' Else ''Daily'' end) AS frequency, 
				max(source_uom.uom_name) AS uom, 
				max(source_price_curve_def.curve_name) AS [index],
				dbo.FNARemoveTrailingZeroes(round(avg(case when source_deal_detail.fixed_price=0 then null else source_deal_detail.fixed_price end),4)) price,
				max(source_currency.currency_name) as currency
				, fld.link_id
				, fld.fas_link_detail_id  
				, dbo.FNARemoveTrailingZeroes(round(fld.percentage_included * sum(source_deal_detail.total_volume)/max(source_deal_detail.Leg), 2)) matched_volume
				--min(source_deal_detail.Leg) AS Leg,  
    --            max((case source_deal_detail.fixed_float_leg when ''f'' then ''Fixed'' Else ''Float'' end)) AS [Fixed Float], 
				----cast(isnull(avg(source_deal_detail.option_strike_price), 0) as varchar) StrikePrice,
				--dbo.FNARemoveTrailingZeroes(avg(source_deal_detail.option_strike_price)) as [Strike Price],
    --            Book1.source_book_name AS ['+@group1+'], 
				--Book2.source_book_name AS ['+@group2+'], Book3.source_book_name AS ['+@group3+'], 
    --             Book4.source_book_name AS ['+@group4+'], 
				--case sdh.option_type when ''c'' then ''Call'' when ''p'' then ''Put'' else '''' end AS [Option Type], 
				--case sdh.option_excercise_type when ''e'' then ''European'' when ''a'' then ''American'' else sdh.option_excercise_type end AS [Excercise Type]'
else
SET @sql_stmt = 'SELECT     	
					fld.source_deal_header_id, 
					sdh.deal_id  AS [deal_id],
					fld.percentage_included AS [perc_included],
					dbo.FNAGetSQLStandardDate(fld.effective_date) as [effective_date], 
					dbo.FNADateFormat(sdh.deal_date) AS [deal_date], 
                    dbo.FNADateFormat(source_deal_detail.term_start) AS [term_start], 
					dbo.FNADateFormat(source_deal_detail.term_end) AS [term_end],  
					case source_deal_detail.buy_sell_flag when ''b'' then ''Buy (Receive)'' Else ''Sell (Pay)'' end AS [buy_sell], 
					dbo.FNARemoveTrailingZeroes(round(source_deal_detail.total_volume, 2)) AS volume, 
					(case source_deal_detail.deal_volume_frequency when ''m'' then ''Monthly'' Else ''Daily'' end) AS frequency, 
					source_uom.uom_name AS uom, 
					source_price_curve_def.curve_name AS [index],
					dbo.FNARemoveTrailingZeroes(round(source_deal_detail.fixed_price,4)) price, 
					source_currency.currency_name as currency
					, fld.link_id
					, fld.fas_link_detail_id
					--source_deal_detail.Leg AS Leg, 
					--(case source_deal_detail.fixed_float_leg when ''f'' then ''Fixed'' Else ''Float'' end) AS [Fixed Float], 
					--dbo.FNARemoveTrailingZeroes(isnull(source_deal_detail.option_strike_price, 0)) [Strike Price],
					--Book1.source_book_name AS ['+@group1+'], 
					--Book2.source_book_name AS ['+@group2+'], 
					--Book3.source_book_name AS ['+@group3+'], 
					--Book4.source_book_name AS ['+@group4+'], 
					--case sdh.option_type when ''c'' then ''Call'' when ''p'' then ''Put'' else '''' end AS [Option Type], 
					--case sdh.option_excercise_type when ''e'' then ''European'' when ''a'' then ''American'' else sdh.option_excercise_type end AS [Excercise Type]
			'


set @sql_where='
FROM         			fas_link_detail fld INNER JOIN
                      		source_deal_header sdh ON fld.source_deal_header_id = sdh.source_deal_header_id INNER JOIN
                      		source_book Book1 ON sdh.source_system_book_id1 = Book1.source_book_id INNER JOIN
                      		source_book Book2 ON sdh.source_system_book_id2 = Book2.source_book_id INNER JOIN
                      		source_book Book3 ON sdh.source_system_book_id3 = Book3.source_book_id INNER JOIN
                      		source_book Book4 ON sdh.source_system_book_id4 = Book4.source_book_id INNER JOIN
                      		source_deal_detail ON sdh.source_deal_header_id = source_deal_detail.source_deal_header_id INNER JOIN
                      		source_uom ON source_deal_detail.deal_volume_uom_id = source_uom.source_uom_id LEFT OUTER JOIN
                      		source_price_curve_def ON source_deal_detail.curve_id = source_price_curve_def.source_curve_def_id LEFT OUTER JOIN
				source_currency ON source_currency.source_currency_id = source_deal_detail.fixed_price_currency_id

WHERE 				link_id = ' + CAST(@link_id as varchar)

	If upper(@flag2) = 'H'
		SET @sql_where = @sql_where + ' AND upper(hedge_or_item) = ''H'''

	If upper(@flag2) = 'I'
		SET @sql_where = @sql_where + ' AND upper(hedge_or_item) = ''I'''


if @summary_option='s'
set @sql_group_by=' group by fld.source_deal_header_id,sdh.deal_id,fld.percentage_included,fld.link_id,
					dbo.FNADateFormat(sdh.deal_date),Book1.source_book_name,Book2.source_book_name,
					Book3.source_book_name, Book4.source_book_name,sdh.option_type,sdh.option_excercise_type
					,fld.fas_link_detail_id
				--,fld.effective_date'
	+' ORDER BY sdh.deal_id, min(source_deal_detail.term_start), min(source_deal_detail.Leg),fld.percentage_included'

	


else 
set @sql_group_by= +' ORDER BY sdh.deal_id, source_deal_detail.term_start, source_deal_detail.Leg'

	--print @sql_stmt+@sql_where+@sql_group_by
	

	IF @flag2 = 'h' OR @flag2 = 'i'
	BEGIN
		SET @sql = @sql_stmt + CHAR(13)+CHAR(10)+ ' INTO ' + @paging_process_table + ' ' + @sql_where + @sql_group_by
		EXEC(@sql)

		SELECT @paging_process_table [process_table], CASE WHEN @flag2 = 'h' THEN 'hedges' ELSE 'items' END [call_from]
		RETURN
	END
	ELSE
	BEGIN
	exec (@sql_stmt+@sql_where+@sql_group_by)
	END	

	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, 'Fas Link detail table', 
				'spa_fas_link)detail', 'DB Error', 
				'Failed to select Link detail record.', ''
End
Else if @flag = 'i'
begin
	--New Added Anoop	
	if @effective_date is not null 
	begin
		create table #dt_i (eff_date datetime null)
		exec('insert #dt_i (eff_date)
		select max(deal_date) from source_deal_header where source_deal_header_id in (' + @source_deal_header_id + ')')
		select @dt = eff_date from #dt_i
--		select @dt=deal_date from source_deal_header where source_deal_header_id=@source_deal_header_id
		if @dt<=@effective_date
		begin
--			select @dt=link_effective_date from fas_link_header where link_id=@link_id
			if @link_effective_date>@effective_date
			begin
				SET @error_message = 'Effective Date can not be less than the link effective date or Deal Date. One or more selected deals violated this.'
				Select 'Error' As ErrorCode, 'Fas Link detail' As Module, 
							'spa_fas_link-detail' AS Area , 'Application Error' AS tatus,
					('Failed to Insert Link detail record. ' + @error_message) AS Message, @error_message AS Recommendation
				return
			end
		end
		else
		begin
			SET @error_message = 'Effective Date can not be less than the link effective date or Deal Date. One or more selected deals violated this.'
			Select 'Error' As ErrorCode, 'Fas Link detail' As Module, 
						'spa_fas_link-detail' AS Area , 'Application Error' AS tatus,
				('Failed to Insert Link detail record. ' + @error_message) AS Message, @error_message AS Recommendation
			return
		end
	end

	--- FOR INSERT AND UPDATE FIND what % can be included.. the following is what % has been already linked
	SET @percentage_available = 1.0

	create table #temp_per_i(
	per_include float)
	set @sql_stmt=
	'insert #temp_per_i (per_include)
	select min(per) per_include from 
	(SELECT source_deal_header_id , 
		  	(1.0 - isnull(SUM(CASE WHEN (''' + @link_effective_date + ''' >= isnull(link_end_date,''9999-01-01'')) THEN 0 ELSE percentage_included END), 0))  per
	FROM    fas_link_detail INNER JOIN fas_link_header ON fas_link_header.link_id = fas_link_detail.link_id
	WHERE   source_deal_header_id in ('+ @source_deal_header_id +')
    group by source_deal_header_id
	)  cc
	'

	exec(@sql_stmt)
	select @percentage_available=per_include from #temp_per_i

	If @percentage_included > @percentage_available
	BEGIN	
		SET @error_message = 'Deal: ' + cast(@source_deal_header_id as varchar) + 
					' Can only be included up to: ' + cast(@percentage_available as varchar)

		Select 'Error' As ErrorCode, 'Fas Link detail' As Module, 
					'spa_fas_link-detail' AS Area , 'Application Error' AS tatus,
			('Failed to Insert Link detail record. ' + @error_message) AS Message, @error_message AS Recommendation

	END	
	Else
	BEGIN
	--End Added Anoop
	set @sql_stmt='
		insert into fas_link_detail
			(link_id,
			source_deal_header_id,
			percentage_included,
			hedge_or_item,
			effective_date)
		select '+ cast(@link_id as varchar) +',source_deal_header_id,'+	
			cast(@percentage_included as varchar) +','''+@hedge_or_item +''','+case when @effective_date is null then 'null' else ''''+cast(@effective_date as varchar)+'''' end+
		  ' from source_deal_header where source_deal_header_id in ('+ @source_deal_header_id +')'
	--print(@sql_stmt)
	exec(@sql_stmt)
	
		If @@ERROR <> 0
			Exec spa_ErrorHandler @@ERROR, 'Fas Link detail table', 
					'spa_fas_link_detail', 'DB Error', 
					'Failed to select Link detail record.', ''
		Else
			Exec spa_ErrorHandler 0, 'Link Dedesignation Table', 
					'spa_fas_link_detail', 'Success', 
					'Link Detail records successfully Inserted.', ''
	end
end	
Else if @flag = 'u'
begin
	if @effective_date is not null 
	begin
		If not exists(select sdh.deal_date from source_deal_header sdh 
		inner join fas_link_detail fld on sdh.source_deal_header_id=fld.source_deal_header_id
		inner join fas_link_header flh on flh.link_id=fld.link_id 
		where flh.link_id=@link_id and sdh.source_deal_header_id=@source_deal_header_id and (sdh.deal_date<=@effective_date and flh.link_effective_date<=@effective_date))

		BEGIN	
			SET @error_message = 'Effective Date can not be less than the link effective date or Deal Date.'

			Select 'Error' As ErrorCode, 'Fas Link detail' As Module, 
						'spa_fas_link-detail' AS Area , 'Application Error' AS tatus,
				('Failed to Update Link detail record. ' + @error_message) AS Message, @error_message AS Recommendation
			return
		END	
	end
	--DECLARE @percentage_available float
	--DECLARE @error_message varchar(1000)

/*
	SET @percentage_available = 1.0
	SELECT    @percentage_available = (1.0 - isnull(SUM(percentage_included), 0))
	FROM      fas_link_detail
	WHERE     source_deal_header_id = @source_deal_header_id 
			AND link_id <>  @link_id 	
*/
	--- FOR INSERT AND UPDATE FIND what % can be included.. the following is what % has been already linked
	SET @percentage_available = 1.0
	 
--	select @link_effective_date = '2005-01-01'

	create table #temp_per_u (per_include float)
	set @sql_stmt=
	'insert #temp_per_u (per_include)
	SELECT (1.0 - isnull(SUM(CASE WHEN (''' + @link_effective_date + ''' >= isnull(link_end_date,''9999-01-01'')) THEN 0 ELSE percentage_included END), 0))  per
	FROM    fas_link_detail INNER JOIN fas_link_header ON fas_link_header.link_id = fas_link_detail.link_id
	WHERE   source_deal_header_id in ('+ @source_deal_header_id +') AND fas_link_header.link_id <> ' + cast(@link_id as varchar)

	exec(@sql_stmt)
	select @percentage_available=per_include from #temp_per_u

	If @percentage_included > @percentage_available
	BEGIN	
		SET @error_message = 'Deal: ' + cast(@source_deal_header_id as varchar) + 
					' can only be included up to: ' + cast(@percentage_available as varchar)
		
		Select 'Error' As ErrorCode, 'Fas Link detail' As Module, 
					'spa_fas_link-detail' AS Area , 'Application Error' AS tatus,
			('Failed to Update Link detail record. ' + @error_message) AS Message, @error_message AS Recommendation
	END	
	Else
	BEGIN

		Update fas_link_detail
		Set	percentage_included=@percentage_included,
			hedge_or_item=@hedge_or_item,effective_date=@effective_date
		Where link_id =@link_id
		and   source_deal_header_id=@source_deal_header_id
	
		
		If @@ERROR <> 0
			Exec spa_ErrorHandler @@ERROR, 'Fas Link detail table', 
					'spa_fas_link-detail', 'DB Error', 
					'Failed to Update Link detail record.', ''
		Else
			Exec spa_ErrorHandler 0, 'Link Dedesignation Table', 
					'spa_fas_link_detail', 'Success', 
					'Link Detail records successfully updated.', ''
	END
end	

Else if @flag = 'd'
BEGIN
	/*
	delete from fas_link_detail
	Where 	link_id = @link_id
	AND source_deal_header_id = @source_deal_header_id
	*/
	
	DELETE fld 
	FROM fas_link_detail fld
	INNER JOIN dbo.SplitCommaSeperatedValues(@source_deal_header_id) deals
		ON deals.item = fld.source_deal_header_id
	WHERE fld.link_id = @link_id
	
	DELETE fldd 
	FROM fas_link_detail_dicing fldd
	INNER JOIN dbo.SplitCommaSeperatedValues(@source_deal_header_id) deals
		ON deals.item = fldd.source_deal_header_id
	WHERE fldd.link_id = @link_id
	
	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, 'Fas Link detail table', 
				'spa_fas_link_detail', 'DB Error', 
				'Failed to delete Link detail record.', ''
	Else
		Exec spa_ErrorHandler 0, 'Link Dedesignation Table', 
				'spa_fas_link_detail', 'Success', 
				'Link Detail record successfully deleted.', ''
end
ELSE IF @flag = 'h'
BEGIN
	--deal detail for Designation of Hedge
	-- Collects fas link detail percentage included Starts	
	
	exec dbo.spa_get_link_deal_term_used_per @as_of_date =NULL,@link_ids=NULL,@header_deal_id =NULL,@term_start=null
			,@no_include_link_id =NULL,@output_type =1	,@include_gen_tranactions  = 'b',@process_table=@link_deal_term_used_per
		
	SET @sql_pc = 'INSERT INTO #temp_per_used (source_deal_header_id  ,term_start,used_per )	
	SELECT source_deal_header_id,	term_start, sum(isnull(percentage_used ,1)) percentage_used from ' +@link_deal_term_used_per 
	+ ' GROUP BY source_deal_header_id,term_start	'
					
	exec(@sql_pc)			

	INSERT INTO #collect_per_inc(source_deal_header_id, percentage_included)
	SELECT 
		sdh.source_deal_header_id, 
		1-isnull(avg(tpu.used_per),0)
	FROM source_deal_header sdh 
		INNER JOIN source_deal_detail sdd
			ON sdh.source_deal_header_id = sdd.source_deal_header_id
		LEFT JOIN #temp_per_used tpu
			ON sdd.source_deal_header_id = tpu.source_deal_header_id	
				and sdd.term_start = tpu.term_start			
	GROUP BY sdh.source_deal_header_id
		
	--SELECT * FROM #collect_per_inc
	-- Collects fas link detail percentage included ends

	CREATE TABLE #designate_deals(row_id INT IDENTITY(1,1),
		source_deal_header_id INT,
		deal_id VARCHAR(2000) COLLATE DATABASE_DEFAULT  ,
		perc_included FLOAT,
		effective_date DATETIME,
		deal_date DATETIME,
		term_start DATETIME,
		term_end DATETIME,
		buy_sell CHAR(1) COLLATE DATABASE_DEFAULT  ,
		volume NUMERIC(38,20),
		frequency VARCHAR(2000) COLLATE DATABASE_DEFAULT  ,
		uom VARCHAR(200) COLLATE DATABASE_DEFAULT  ,
		curve_name VARCHAR(2000) COLLATE DATABASE_DEFAULT  ,
		price NUMERIC(38,20),
		currency VARCHAR(100) COLLATE DATABASE_DEFAULT  ,
		link_id INT NULL,
		fas_link_detail_id INT NULL
		
	)
	----Collect designated deals
	--INSERT INTO #designate_deals(source_deal_header_id, deal_id, perc_included, effective_date, deal_date, term_start, term_end, buy_sell, volume, frequency, uom, curve_name,
	--	price, currency, link_id, fas_link_detail_id
	--)
	--SELECT     	
	--		fld.source_deal_header_id, 				 
	--		sdh.deal_id,
	--		fld.percentage_included,
	--		max(fld.effective_date) [effective_date], 
	--		sdh.deal_date AS [deal_date], 
	--        min(source_deal_detail.term_start) AS [term_start], 
	--		max(source_deal_detail.term_end) AS [term_end],
	--		max(sdh.header_buy_sell_flag) AS [buy_sell],  
	--		sum(source_deal_detail.total_volume)/max(source_deal_detail.Leg) AS volume, 
	--        max(source_deal_detail.deal_volume_frequency) AS frequency, 
	--		max(source_uom.uom_name) AS uom, 
	--		max(source_price_curve_def.curve_name) AS [index],
	--		avg(source_deal_detail.fixed_price) price,
	--		max(source_currency.currency_name) as currency,
	--		fld.link_id,
	--		fld.fas_link_detail_id  
	--FROM   fas_link_detail fld INNER JOIN
	--	source_deal_header sdh ON fld.source_deal_header_id = sdh.source_deal_header_id INNER JOIN
	--	source_book Book1 ON sdh.source_system_book_id1 = Book1.source_book_id INNER JOIN
	--	source_book Book2 ON sdh.source_system_book_id2 = Book2.source_book_id INNER JOIN
	--	source_book Book3 ON sdh.source_system_book_id3 = Book3.source_book_id INNER JOIN
	--	source_book Book4 ON sdh.source_system_book_id4 = Book4.source_book_id INNER JOIN
	--	source_deal_detail ON sdh.source_deal_header_id = source_deal_detail.source_deal_header_id INNER JOIN
	--	source_uom ON source_deal_detail.deal_volume_uom_id = source_uom.source_uom_id LEFT OUTER JOIN
	--	source_price_curve_def ON source_deal_detail.curve_id = source_price_curve_def.source_curve_def_id LEFT OUTER JOIN
	--	source_currency ON source_currency.source_currency_id = source_deal_detail.fixed_price_currency_id

	--WHERE link_id = @link_id AND hedge_or_item = @hedge_or_item 
	--group by fld.source_deal_header_id
	--	,sdh.deal_id,fld.percentage_included,fld.link_id,
	--	sdh.deal_date,Book1.source_book_name,Book2.source_book_name,
	--					Book3.source_book_name, Book4.source_book_name,sdh.option_type,sdh.option_excercise_type
	--					,fld.fas_link_detail_id
	--ORDER BY fld.fas_link_detail_id


	--Collect deals to be designated
	INSERT INTO #designate_deals(source_deal_header_id, deal_id, perc_included, effective_date, deal_date, term_start, term_end, buy_sell, volume, frequency, uom, curve_name,
		price, currency, link_id, fas_link_detail_id
	)
	SELECT     	
		sdh.source_deal_header_id, 				 
		MAX(sdh.deal_id),
		MAX(cpi.percentage_included),
		max(sdh.deal_date), 
		MAX(sdh.deal_date), 
		min(sdd.term_start), 
		max(sdd.term_end),
		max(sdh.header_buy_sell_flag),  
		sum(sdd.total_volume)/max(sdd.Leg), 
		max(sdd.deal_volume_frequency), 
		max(su.uom_name), 
		max(spcd.curve_name),
		avg(sdd.fixed_price),
		max(sc.currency_name),
		@link_id,
		NULL 
	FROM  source_deal_header sdh
		INNER JOIN dbo.SplitCommaSeperatedValues(@source_deal_header_id) scsv ON scsv.item = sdh.source_deal_header_id
		INNER JOIN source_deal_detail sdd ON scsv.item = sdd.source_deal_header_id 
		INNER JOIN source_uom su ON sdd.deal_volume_uom_id = su.source_uom_id 
		LEFT JOIN source_price_curve_def spcd ON sdd.curve_id = spcd.source_curve_def_id 
		LEFT JOIN source_currency sc ON sc.source_currency_id = sdd.fixed_price_currency_id
		LEFT JOIN #collect_per_inc cpi ON cpi.source_deal_header_id = sdh.source_deal_header_id
	GROUP BY sdh.source_deal_header_id
					
	SELECT source_deal_header_id
		, deal_id
		, perc_included
		, dbo.FNADateFormat(effective_date) effective_date
		, dbo.FNADateFormat(deal_date) deal_date
		, dbo.FNADateFormat(term_start) term_start
		, dbo.FNADateFormat(term_end) term_end
		, case buy_sell when 'b' then 'Buy (Receive)' Else 'Sell (Pay)' end buy_sell
		, dbo.FNARemoveTrailingZeroes(round(volume, 2)) volume 
		, case frequency when 'm' then 'Monthly' Else 'Daily' end frequency
		, uom
		, curve_name [index]
		, dbo.FNARemoveTrailingZeroes(round(price,4)) price
		, currency
		, link_id
		, fas_link_detail_id
	FROM #designate_deals
	ORDER BY row_id
END
-- EXEC spa_faslinkdetail @flag='h',@hedge_or_item = 'h', @link_id = 5, @source_deal_header_id='34678,34679'

ELSE If @flag = 'j' -- Used in Hedge/Item grid after Matching Deal 
BEGIN
	/************************************************
	 *			CHECK DEAL Already selected 		*
	 ************************************************/
	DECLARE @msg VARCHAR(MAX)
	 
	CREATE TABLE #deal_exists ( test int)
	SET @sql = '
					INSERT INTO #deal_exists 
					SELECT 1 
					FROM fas_link_detail fld
					INNER JOIN source_deal_header sdh
						ON fld.source_deal_header_id = sdh.source_deal_header_id 
					INNER JOIN source_deal_detail sdd
					ON sdh.source_deal_header_id = sdd.source_deal_header_id
					WHERE 1 = 1 
					AND fld.link_id = ' + CAST(@link_id AS VARCHAR(50))
	IF @source_deal_header_id IS NOT NULL
	BEGIN 
		SET @sql = @sql + ' AND sdh.source_deal_header_id IN (' + CAST(@source_deal_header_id AS VARCHAR(50)) + ') '
	END 
	
	IF @reference_id IS NOT NULL
	BEGIN
		SET @sql = @sql + ' AND sdh.deal_id = ''' + CAST (@reference_id AS VARCHAR(50)) + '''' 
	END
	exec spa_print @sql
	EXEC(@sql)

	IF EXISTS (SELECT * FROM #deal_exists)
	BEGIN
		Exec spa_ErrorHandler -1, 'Fas Link detail table', 
				'spa_fasLink', 'DB Error', 
				'The selected deal already exists in the link.', ''
		RETURN
	END
	DROP TABLE #deal_exists
	
	/************************************************
	 *			CHECK DEAL Already selected END		*
	 ************************************************/
	
	/************************************************
	 *			CHECK DEAL EXISTS					*
	 ************************************************/

	CREATE TABLE #deal_check ( test int)
	
	--DECLARE @source_system_id INT
	
	--SELECT TOP 1 @source_system_id = fs.source_system_id
	--FROM fas_link_header flh
	--INNER JOIN portfolio_hierarchy book ON flh.fas_book_id = book.entity_id
	--INNER JOIN fas_strategy fs ON book.parent_entity_id = fs.fas_strategy_id
	--WHERE flh.link_id = @link_id 	
					
	SET @sql = ' INSERT INTO #deal_check
				SELECT 1 FROM source_deal_header sdh
				WHERE 1 = 1 '
					
	IF @source_deal_header_id IS NOT NULL
	BEGIN 
		SET @sql = @sql + ' AND sdh.source_deal_header_id IN (' + CAST(@source_deal_header_id AS VARCHAR(50)) + ') '
	END 
	
	IF @reference_id IS NOT NULL
	BEGIN
		SET @sql = @sql + ' AND sdh.deal_id = ''' + CAST (@reference_id AS VARCHAR(50)) + ''''
	END
	exec spa_print @sql
	EXEC(@sql)

	IF NOT EXISTS (SELECT * FROM #deal_check)
	BEGIN
		Exec spa_ErrorHandler -1, 'Fas Link detail table', 
				'spa_fasLink', 'DB Error', 
				'The entered deal does not exist.', ''
		RETURN
	END
	DROP TABLE #deal_check

	/************************************************
	 *			CHECK DEAL EXISTS END				*
	 ************************************************/
	
	/************************************************
	 *			CHECK DEAL MAPPING					*
	 ************************************************/

	CREATE TABLE #deal_mapping ( test int)
	SET @sql =	'
					INSERT INTO #deal_mapping
					SELECT 1 
					FROM source_deal_header sdh
					INNER JOIN source_system_book_map ssb1 
						ON sdh.source_system_book_id1 = ssb1.source_system_book_id1
						AND sdh.source_system_book_id2 = ssb1.source_system_book_id2
						AND sdh.source_system_book_id3 = ssb1.source_system_book_id3
						AND sdh.source_system_book_id4 = ssb1.source_system_book_id4
					WHERE 1 = 1 
				'
	IF @source_deal_header_id IS NOT NULL
	BEGIN 
		SET @sql = @sql + ' AND sdh.source_deal_header_id IN (' + CAST(@source_deal_header_id AS VARCHAR(50)) + ') '
	END 
	
	IF @reference_id IS NOT NULL
	BEGIN
		SET @sql = @sql + ' AND sdh.deal_id = ''' + CAST (@reference_id AS VARCHAR(50)) + '''' 
	END
	exec spa_print @sql
	EXEC(@sql)
	
	IF NOT EXISTS (SELECT * FROM #deal_mapping)
	BEGIN
		Exec spa_ErrorHandler -1, 'Fas Link detail table', 
				'spa_fasLink', 'DB Error', 
				'You are not allowed to select a unmapped deal.', ''
		RETURN
	END
	DROP TABLE #deal_mapping
	
	/************************************************
	 *			CHECK DEAL MAPPING END				*
	 ************************************************/


	/************************************************
	 *		CHECK DEAL IS HEDGE OR ITEM				*
	 ************************************************/
	CREATE TABLE #deal_hedge_item ( test int)
	SET @sql =	'
					INSERT INTO #deal_hedge_item
					SELECT 1 
					FROM source_deal_header sdh
					INNER JOIN source_system_book_map ssb1 
						ON sdh.source_system_book_id1 = ssb1.source_system_book_id1
						AND sdh.source_system_book_id2 = ssb1.source_system_book_id2
						AND sdh.source_system_book_id3 = ssb1.source_system_book_id3
						AND  sdh.source_system_book_id4 = ssb1.source_system_book_id4
						AND ISNULL(sdh.fas_deal_type_value_id,ssb1.fas_deal_type_value_id )= CASE WHEN ''' + @hedge_or_item + ''' = ''h'' THEN 400 ELSE 401 END
					WHERE 1=1 
				'
	IF @source_deal_header_id IS NOT NULL
	BEGIN 
		SET @sql = @sql + ' AND sdh.source_deal_header_id IN (' + CAST(@source_deal_header_id AS VARCHAR(50)) + ') '
	END 
	
	IF @reference_id IS NOT NULL
	BEGIN
		SET @sql = @sql + ' AND sdh.deal_id = ''' + CAST (@reference_id AS VARCHAR(50)) + ''''
	END
	EXEC spa_print @sql

	EXEC(@sql)
	IF NOT EXISTS (SELECT * FROM #deal_hedge_item)
	BEGIN
		
		SET @msg = 'The selected deal is not a ' + CASE WHEN @hedge_or_item = 'h' THEN 'Hedge' ELSE 'Hedged Item' END + '.'
		EXEC spa_ErrorHandler -1, 'Fas Link detail table', 
				'spa_fasLink', 'DB Error', 
				@msg, ''
		RETURN
	END
	DROP TABLE #deal_hedge_item

	/************************************************
	 *		CHECK DEAL IS HEDGE OR ITEM	END			*
	 ************************************************/

	/************************************************
	 *		CHECK DEAL IS Assigned Percent			*
	 ************************************************/
		IF @reference_id IS NOT NULL
		BEGIN
			select @source_deal_header_id  = source_deal_header_id from source_deal_header where deal_id = @reference_id
		END
	

		if OBJECT_ID(@link_deal_term_used_per) is not null
				exec('drop table '+@link_deal_term_used_per)
		
		exec dbo.spa_get_link_deal_term_used_per @as_of_date =@effective_date,@link_ids=NULL,@header_deal_id =@source_deal_header_id,@term_start=null
			,@no_include_link_id =NULL, @output_type =1, @include_gen_tranactions = 'b',@process_table=@link_deal_term_used_per

		SET @sql = 'INSERT INTO #temp_per_used (source_deal_header_id  ,used_per )	
		SELECT source_deal_header_id, AVG(percentage_used) percentage_used from 
		 (
			SELECT source_deal_header_id,	term_start, sum(isnull(percentage_used,1)) percentage_used from ' +@link_deal_term_used_per + ' GROUP BY source_deal_header_id,term_start
		) p GROUP BY source_deal_header_id'
						
		exec(@sql)			
			 

		if exists (select 1 from #temp_per_used where used_per>.9988 )
		BEGIN
			SET @msg = 'The entered deal is fully assigned as of ' + dbo.FNAUserDateFormat(@effective_date, @user_login_id) + '.Please change the effective date to include the deal in relationship.'
			EXEC spa_ErrorHandler -1, 'Fas Link detail table', 
					'spa_fasLink', 'DB Error', 
					@msg, '1'
			RETURN
		END
	 
	/************************************************
	 *		CHECK DEAL IS Assigned Percent END		*
	 ************************************************/
	
	SET @sql_stmt = '	SELECT 
						MAX(aa.[source_deal_header_id]) [source_deal_header_id]
						, MAX(aa.reference_id) [deal_id]
						,  1 - ISNULL(MAX(tpu.used_per), 0) [perc_included]
						, ''' + CASE 
								WHEN @effective_date IS NULL THEN ''
								ELSE dbo.FNAUserDateFormat(@effective_date, @user_login_id)
							END + ''' [effective_date]
						, MAX(dbo.FNAUserDateFormat(aa.[deal_date], ''' + @user_login_id + ''')) [deal_date] 
						, MAX(dbo.FNAUserDateFormat(aa.[term_start], ''' + @user_login_id + ''')) [term_start]
						, MAX(dbo.FNAUserDateFormat(aa.[term_end], ''' + @user_login_id + ''')) [term_end]
						, MAX(aa.[buy_sell]) [buy_sell]
						, MAX(aa.volume) volume
						, MAX(aa.frequency) frequency
						, MAX(aa.uom) uom
						, MAX(aa.[index]) [index]
						, MAX(aa.price) price
						, MAX(aa.currency) currency
						, ' + ISNULL(CAST(@link_id AS VARCHAR(10)), 'NULL') + ' link_id
						, NULL link_detail_id'

	SET @sql_where	= '	FROM (
						SELECT 
							sdh.source_deal_header_id [source_deal_header_id], 
							MAX(sdh.deal_id) [reference_id], 
							MAX(sdh.deal_date) [deal_date],
							MAX(sdh.entire_term_start) [term_start],
							MAX(sdh.entire_term_end) [term_end],
							CASE WHEN MAX(sdh.header_buy_sell_flag) = ''b'' THEN ''Buy'' ELSE ''Sell'' END [buy_sell], 
							dbo.FNARemoveTrailingZeroes(SUM(sdd.total_volume)) AS volume,
							max(case sdd.deal_volume_frequency when ''m'' then ''Monthly'' Else ''Daily'' end) AS frequency, 
							max(su.uom_name) AS uom, 
							max(spcd.curve_name) AS [index],
							dbo.FNARemoveTrailingZeroes(round(avg(case when sdd.fixed_price=0 then null else sdd.fixed_price end),4)) price,
							max(scc.currency_name) as currency						
						FROM source_deal_header sdh 
							INNER JOIN source_deal_detail sdd
								ON sdh.source_deal_header_id = sdd.source_deal_header_id
							LEFT JOIN source_price_curve_def spcd
								ON spcd.source_curve_def_id = sdd.curve_id							
							LEFT JOIN source_counterparty sc
								ON sc.source_counterparty_id = sdh.counterparty_id
							LEFT JOIN source_uom su ON sdd.deal_volume_uom_id = su.source_uom_id
							LEFT JOIN source_currency scc ON scc.source_currency_id = sdd.fixed_price_currency_id 							
						WHERE 1 = 1 '
	IF @source_deal_header_id IS NOT NULL
	BEGIN
		SET @sql_where = @sql_where + ' AND sdh.source_deal_header_id IN (' + CAST(@source_deal_header_id AS VARCHAR(50)) + ') '
	END

	IF @reference_id IS NOT NULL
	BEGIN
		SET @sql_where = @sql_where + ' AND sdh.deal_id=''' + CAST(@reference_id AS VARCHAR) + ''''
	END	
	
	SET @sql_group_by = '	GROUP BY sdh.source_deal_header_id
						) aa
									LEFT JOIN #temp_per_used tpu
										ON aa.[source_deal_header_id] = tpu.source_deal_header_id
							group by aa.[source_deal_header_id]'	

	IF (@hedge_or_item = 'h' OR @hedge_or_item = 'i') AND @flag2 = 'p'  -- return process table
	BEGIN
		SET @sql = @sql_stmt + CHAR(13)+CHAR(10)+ ' INTO ' + @paging_process_table + ' ' + @sql_where + @sql_group_by
		EXEC(@sql)

		SELECT @paging_process_table [process_table], CASE WHEN @hedge_or_item = 'h' THEN 'hedges' ELSE 'items' END [call_from]
		RETURN
	END
	ELSE
	BEGIN
		EXEC(@sql_stmt + @sql_where + @sql_group_by)
	END

End
ELSE If @flag = 'k' -- Used in Designation of Hedge 1st Match Deal grid
BEGIN
	
	INSERT INTO #tmp_filter_grid (grid_process_table)
	EXEC spa_source_deal_header @flag='t', @filter_xml = @xml_filter , @trans_type=NULL, @call_from = 'designation_of_hedge'

	SELECT @grid_process_table = grid_process_table FROM #tmp_filter_grid
	
	SET @sql_stmt = 'SELECT  
					 sdh2.source_deal_header_id [source_deal_header_id]
					, sdh.deal_id [ref_id]
					, sdh.[location_index] [product]
					, sdh.[commodity] [commodity]
					, sdh.buy_sell [buy_sell]
					, sdh.counterparty [counterparty]
					, sdh.deal_date [deal_date]
					, sdh.term_start [term_start]
					, sdh.term_end [term_end]
					, FORMAT(sdd.expiration_date, ''MMM yyyy'') AS [expiration_date]
					, ROUND([dbo].[FNARemoveTrailingZeroes](isnull(sdd.total_volume,0)),2) [actual_volume]
					, ROUND([dbo].[FNARemoveTrailingZeroes](isnull(sdd.total_volume * (1 - sdh.percentage_included),0)),2) [matched] -- here sdh.percentage_included is percentage available in deal 
					, ROUND([dbo].[FNARemoveTrailingZeroes](CAST(isnull(sdd.total_volume,0) AS NUMERIC(38,20)) - CAST(isnull(sdd.total_volume * (1 - sdh.percentage_included),0) AS NUMERIC(38,20))),2) [remaining]
					, CASE sdd.deal_volume_frequency WHEN ''x'' THEN ''15 Minutes''
						WHEN ''y'' THEN	''30 Minutes''
						WHEN ''a'' THEN	''Annually''
						WHEN ''d'' THEN	''Daily''
						WHEN ''h'' THEN	''Hourly''
						WHEN ''m'' THEN	''Monthly''
						WHEN ''t'' THEN	''Term''	
					END frequency
					, sdh.deal_volume_uom_id [uom]
					, ROUND(sdh.deal_price, 2) [price]
					, ROUND([dbo].[FNARemoveTrailingZeroes](isnull(sdd.total_volume,0) * sdh.deal_price),2) [vp_value]
					, sdh.currency [currency]
					FROM '      			
                    + @grid_process_table + ' AS sdh
					INNER JOIN source_deal_header sdh2 ON sdh2.source_deal_header_id = sdh.id
					INNER JOIN source_system_book_map ssb1 
						ON sdh2.source_system_book_id1 = ssb1.source_system_book_id1
						AND sdh2.source_system_book_id2 = ssb1.source_system_book_id2
						AND sdh2.source_system_book_id3 = ssb1.source_system_book_id3
						AND  sdh2.source_system_book_id4 = ssb1.source_system_book_id4
					OUTER APPLY
						(
						SELECT SUM(total_volume) total_volume,
							MAX(contract_expiration_date) expiration_date,
							MAX(deal_volume_frequency) deal_volume_frequency
						FROM
						source_deal_detail 
						WHERE source_deal_header_id = sdh.id
						) sdd
					WHERE 1 = 1 AND sdd.total_volume <> 0 AND ISNULL(sdh2.fas_deal_type_value_id,ssb1.fas_deal_type_value_id)= CASE WHEN ''' + @hedge_or_item + ''' = ''h'' THEN 400 ELSE 401 END' 
	
	SET @sql_group_by = ' ORDER BY sdh2.deal_date, sdh2.source_deal_header_id'
	
	EXEC (@sql_stmt + @sql_group_by)	
END
ELSE IF @flag = 'l'
BEGIN
	DECLARE @hedge_deals VARCHAR(5000)
	SELECT @hedge_deals = SUBSTRING(@source_deal_header_id, 3, CHARINDEX('i:', @source_deal_header_id)- 3) 
		
	SET @source_deal_header_id = REPLACE(REPLACE(@source_deal_header_id, 'h:',''),'i:','')
	
	EXEC('SELECT deal_date.deal_date, subidiary.entity_name + '','' + stra.entity_name + '','' + book.entity_name book_str,  
			subidiary.entity_id subidiary_id, stra.entity_id stra_id, book.entity_id book_id
		FROM portfolio_hierarchy subidiary
		INNER JOIN portfolio_hierarchy stra (nolock) ON stra.parent_entity_id = subidiary.entity_id    
		INNER JOIN portfolio_hierarchy book (nolock) ON book.parent_entity_id = stra.entity_id     
		INNER JOIN (
			SELECT MIN(fas_book_id) book_id
			FROM source_deal_header sdh 
			INNER JOIN source_system_book_map ssb1 
				ON sdh.source_system_book_id1 = ssb1.source_system_book_id1
				AND sdh.source_system_book_id2 = ssb1.source_system_book_id2
				AND sdh.source_system_book_id3 = ssb1.source_system_book_id3
				AND sdh.source_system_book_id4 = ssb1.source_system_book_id4	
			WHERE sdh.source_deal_header_id IN (' + @hedge_deals + ') 
		) ssbm ON ssbm.book_id = book.entity_id
		OUTER APPLY(
			SELECT MAX(deal_date) deal_date FROM source_deal_header WHERE source_deal_header_id IN (' + @source_deal_header_id + ')
		) deal_date
	')	
END
