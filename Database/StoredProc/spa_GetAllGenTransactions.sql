if object_id('[dbo].[spa_GetAllGenTransactions]') is not null
DROP PROCEDURE [dbo].[spa_GetAllGenTransactions]
GO 

--select * from [gen_fas_link_detail] order by create_ts desc


-- EXEC spa_GetAllGenTransactions 'h', 461,'m'
-- EXEC spa_GetAllGenTransactions 'i', 2

--===========================================================================================
--This Procedure returns all outstanding transactions for outstanding gen links
--Input Parameters:
-- hedge_item_flag: 'h' is for hedge and 'i' for item
-- gen_link_id


--===========================================================================================

CREATE PROCEDURE [dbo].[spa_GetAllGenTransactions]
	@hedge_item_flag CHAR,
	@gen_link_id VARCHAR(MAX),
	@tran_type CHAR(1) = NULL
AS

SET NOCOUNT ON

if @tran_type='m'
begin
	DECLARE @percentage_available float
	DECLARE @error_message varchar(1000)
	--If @flag = 's' and @flag2= 'h'
	DECLARE @sql_stmt As varchar(5000)
	DECLARE @sql_where As varchar(2000)
	DECLARE @sql_group_by As varchar(2000)
	declare @dt datetime

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
	SET @sql_stmt = 'SELECT     	
				fld.deal_number AS DealID, 
				cast(round(fld.percentage_included, 2) as varchar) AS PercIncluded,
				dbo.FNADateFormat(max(flh.link_effective_date)) [Eff Date], 
				dbo.FNADateFormat(sdh.deal_date) AS DealDate, 
				max(source_deal_detail.Leg) AS Leg, 
                dbo.FNADateFormat(min(source_deal_detail.term_start)) AS TermStart, 
				dbo.FNADateFormat(max(source_deal_detail.term_end)) AS TermEnd, 
				dbo.FNAHyperLinkText(10131000,sdh.deal_id,fld.deal_number)  AS SourceDealID, 
                max((case source_deal_detail.fixed_float_leg when ''f'' then ''Fixed'' Else ''Float'' end)) AS FixedFloat, 
				max(case sdh.header_buy_sell_flag when ''b'' then ''Buy (Receive)'' Else ''Sell (Pay)'' end) AS BuySell, 
				dbo.FNARemoveTrailingZeroes(round(sum(source_deal_detail.deal_volume)/max(source_deal_detail.Leg), 2)) AS Volume, 
                max(case source_deal_detail.deal_volume_frequency when ''m'' then ''Monthly'' Else ''Daily'' end) AS Frequency, 
				max(source_uom.uom_name) AS UOM, 
				max(source_price_curve_def.curve_name) AS [Index],
				dbo.FNARemoveTrailingZeroes(round(avg(case when source_deal_detail.fixed_price=0 then null else source_deal_detail.fixed_price end),3)) Price, 
				--cast(isnull(avg(source_deal_detail.option_strike_price), '''') as varchar) StrikePrice,
				dbo.FNARemoveTrailingZeroes(avg(source_deal_detail.option_strike_price)) StrikePrice,
				max(source_currency.currency_name) as Currency,  
                Book1.source_book_name AS ['+@group1+'], 
				Book2.source_book_name AS ['+@group2+'], Book3.source_book_name AS ['+@group3+'], 
                 Book4.source_book_name AS ['+@group4+'], 
				case sdh.option_type when ''c'' then ''Call'' when ''p'' then ''Put'' else '''' end AS OptionType, 
				case sdh.option_excercise_type when ''e'' then ''European'' when ''a'' then ''American'' else sdh.option_excercise_type end AS [Exercise Type], fld.gen_link_id as LinkId'
	set @sql_where='
			FROM  gen_fas_link_detail fld INNER JOIN gen_fas_link_header flh on fld.gen_link_id=flh.gen_link_id inner join
                      		source_deal_header sdh ON fld.deal_number = sdh.source_deal_header_id INNER JOIN
                      		source_book Book1 ON sdh.source_system_book_id1 = Book1.source_book_id INNER JOIN
                      		source_book Book2 ON sdh.source_system_book_id2 = Book2.source_book_id INNER JOIN
                      		source_book Book3 ON sdh.source_system_book_id3 = Book3.source_book_id INNER JOIN
                      		source_book Book4 ON sdh.source_system_book_id4 = Book4.source_book_id INNER JOIN
                      		source_deal_detail ON sdh.source_deal_header_id = source_deal_detail.source_deal_header_id INNER JOIN
                      		source_uom ON source_deal_detail.deal_volume_uom_id = source_uom.source_uom_id LEFT OUTER JOIN
                      		source_price_curve_def ON source_deal_detail.curve_id = source_price_curve_def.source_curve_def_id LEFT OUTER JOIN
				source_currency ON source_currency.source_currency_id = source_deal_detail.fixed_price_currency_id

			WHERE 	fld.gen_link_id IN (SELECT Item FROM [dbo].[SplitCommaSeperatedValues](''' + CAST(@gen_link_id AS VARCHAR) + '''))'

	If upper(@hedge_item_flag) = 'H'
		SET @sql_where = @sql_where + ' AND upper(hedge_or_item) = ''H'''

	If upper(@hedge_item_flag) = 'I'
		SET @sql_where = @sql_where + ' AND upper(hedge_or_item) = ''I'''


	set @sql_group_by=' group by fld.deal_number,sdh.deal_id,fld.percentage_included,fld.gen_link_id,
					dbo.FNADateFormat(sdh.deal_date),Book1.source_book_name,Book2.source_book_name,
					Book3.source_book_name, Book4.source_book_name,sdh.option_type,sdh.option_excercise_type'
	+' ORDER BY sdh.deal_id, min(source_deal_detail.term_start), min(source_deal_detail.Leg),fld.percentage_included'

	EXEC spa_print @sql_stmt, @sql_where, @sql_group_by
	exec (@sql_stmt+@sql_where+@sql_group_by)

End

else
begin
	If @hedge_item_flag = 'h'
	BEGIN
		select sdd.source_deal_header_id as DealHeaderID, 
		dbo.FNADateFormat(sdd.term_start) as TermStart, dbo.FNADateFormat(sdd.term_end) as TermEnd, 
		sdd.Leg as Leg, dbo.FNADateFormat(sdd.contract_expiration_date) as ExpirationDate, 
		sdd.fixed_float_leg as FixedFloatLeg, sdd.buy_sell_flag as BuySellFlag, 
		sdd.curve_id as [Index], dbo.FNARemoveTrailingZeroes(round(sdd.fixed_price, 2)) as FixedPrice, 
		sdd.fixed_price_currency_id as CurID, dbo.FNARemoveTrailingZeroes(round(sdd.option_strike_price, 2)) as StrikePrice, 
		dbo.FNARemoveTrailingZeroes(round(sdd.deal_volume, 2)) as Volume, sdd.deal_volume_frequency as Frequency, 
		sdd.deal_volume_uom_id as UOM, sdd.block_description as BolckDesc, 
		NULL as InternalTypeID, NULL as InternalSubTypeID, 
		sdd.deal_detail_description as [Desc], 
		sdd.create_user as CreatedUser, dbo.FNADateFormat(sdd.create_ts) as CreatedTS
		from source_deal_detail sdd, 
		gen_fas_link_detail gld 
		where 	sdd.source_deal_header_id = gld.deal_number and gld.hedge_or_item = 'h' 
		and gld.gen_link_id = @gen_link_id --461 
		order by sdd.source_deal_header_id, sdd.contract_expiration_date
	END
	ELSE
	BEGIN
		select sdd.gen_deal_header_id as GenDealHeadID, 
		dbo.FNADateFormat(sdd.term_start) as TermStart, dbo.FNADateFormat(sdd.term_end) as TermEnd, 
		sdd.Leg as Leg, dbo.FNADateFormat(sdd.contract_expiration_date) as ExpirationDate, 
		sdd.fixed_float_leg as FixedFloatLeg, sdd.buy_sell_flag as BuySellFlag, 
		sdd.curve_id as [Index], dbo.FNARemoveTrailingZeroes(round(sdd.fixed_price, 2)) as FixedPrice, 
		sdd.fixed_price_currency_id as CurID, dbo.FNARemoveTrailingZeroes(round(sdd.option_strike_price, 2)) as StrikePrice, 
		dbo.FNARemoveTrailingZeroes(round(sdd.deal_volume, 2)) as Volume, sdd.deal_volume_frequency as Frequency, 
		sdd.deal_volume_uom_id as UOM, sdd.block_description as BolckDesc, 
		sdd.internal_deal_type_value_id as InternalTypeID, sdd.internal_deal_subtype_value_id as InternalSubTypeID, 
		sdd.deal_detail_description as [Desc], 
		sdd.create_user as CreatedUser, dbo.FNADateFormat(sdd.create_ts) as CreatedTS
		from gen_deal_detail sdd, 
		gen_fas_link_detail gld 
		where 	sdd.gen_deal_header_id = gld.deal_number and gld.hedge_or_item =  'i' 
		and gld.gen_link_id = @gen_link_id -- 461 
		order by sdd.gen_deal_header_id, sdd.contract_expiration_date
	END
		If @@ERROR <> 0
			Exec spa_ErrorHandler @@ERROR, 'Source Systems', 
					'spa_GetAllGenTransactions', 'DB Error', 
					'Failed to select outstanding transactions.', ''
end










