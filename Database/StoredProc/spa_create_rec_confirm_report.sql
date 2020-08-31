
IF OBJECT_ID('[dbo].[spa_create_rec_confirm_report]','p') IS NOT NULL
DROP PROCEDURE [dbo].[spa_create_rec_confirm_report]
 GO 


-- exec spa_create_rec_confirm_report NULL,'102',NULL,NULL,NULL,'2006-07-01','2006-07-31','1','d','e',NULL




CREATE PROCEDURE [dbo].[spa_create_rec_confirm_report]
		@sub_entity_id varchar(100)=null, 
		@strategy_entity_id varchar(100) = NULL, 
		@book_entity_id varchar(100) = NULL, 
		@book_deal_type_map_id varchar(5000) = null,
		@source_deal_header_id varchar(5000)  = null,
		@deal_date_from varchar(20),
		@deal_date_to varchar(20),
		@counterparty_id int,
		@summary_option varchar(1), --'r' for retain and 'd' for generate
		@int_ext_flag varchar(1),
		@confirm_id int = NULL, --to print existing confirm 
		@statustype char(1)= NULL,
		@deal_locked char(1)= NULL
AS
SET NOCOUNT ON 

If @deal_date_to IS NULL
	set @deal_date_to = @deal_date_from

declare @date_stmt varchar(250)
set @date_stmt = ' BETWEEN ''' + dbo.FNAGetContractMonth(@deal_date_from)  + ''' AND ''' + 
	dbo.FNAGetContractMonth(@deal_date_to) + ''''


DECLARE @sql_stmt varchar(5000)

CREATE TABLE #temp (
	[Counterparty] [varchar] (100) COLLATE DATABASE_DEFAULT  NULL ,
	[DealID] [varchar] (500) COLLATE DATABASE_DEFAULT  NULL ,
	[SourceDealId] [int] NOT NULL ,
	[DealDate] [varchar] (50) COLLATE DATABASE_DEFAULT  NULL ,
	[ProductionMonth] [varchar] (50) COLLATE DATABASE_DEFAULT  NULL ,
	[Price] [varchar] (30) COLLATE DATABASE_DEFAULT  NOT NULL ,
	[Volume] [float] NULL ,
	[Unit] [varchar] (50) COLLATE DATABASE_DEFAULT  NOT NULL ,
	[BuySell] [varchar] (50) COLLATE DATABASE_DEFAULT  NOT NULL ,
	[curve_name] [varchar] (100) COLLATE DATABASE_DEFAULT,
	[FeederDealID] varchar(50) COLLATE DATABASE_DEFAULT,
	counterparty_id int,
	deal_id varchar(50) COLLATE DATABASE_DEFAULT,
	source_deal_header_id int,
	curve_id int,
	generator_code varchar(50) COLLATE DATABASE_DEFAULT,
	generator_id int,
	currency varchar(100) COLLATE DATABASE_DEFAULT
) ON [PRIMARY]




if @confirm_id IS NULL OR @summary_option = 'r'
BEGIN

	SET @sql_stmt = ' INSERT INTO #temp
		select 
		sc.counterparty_name Counterparty,
		dbo.FNAHyperLinkText(10131010, cast(sdh.source_deal_header_id as varchar), 
			cast(sdh.source_deal_header_id as varchar)) DealID,
		sdh.source_deal_header_id SourceDealId,
		dbo.FNADateFormat(sdh.deal_date) DealDate, 
		dbo.FNADateFormat(sdd.term_start) GenDate, 
		isnull(sdd.fixed_price, 0) Price,
		sdd.deal_volume  Volume, 
--		''MWh'' Unit,
		su.uom_name Unit,
		case when (sdd.buy_sell_flag = ''b'') then ''Buy'' else ''Sell'' end +
			'' Leg-'' + cast(sdd.leg as varchar) BuySell,
		spcd.curve_name,
		isnull(sdh.structured_deal_id, 
			isnull(sdh.ext_deal_id, cast(sdh.source_deal_header_id as varchar))) as FeederDealID,
		sdh.counterparty_id,
		sdh.deal_id,
		sdh.source_deal_header_id,
		sdd.curve_id,
		rg.code, rg.generator_id,
		scur.currency_name
	
		from 
	 	source_deal_header sdh inner join 
		source_deal_detail sdd on sdh.source_deal_header_id = sdd.source_deal_header_id 
		inner join
		source_system_book_map sbm ON sdh.source_system_book_id1 = sbm.source_system_book_id1 AND 
		sdh.source_system_book_id2 = sbm.source_system_book_id2 AND 
		sdh.source_system_book_id3 = sbm.source_system_book_id3 AND 
		sdh.source_system_book_id4 = sbm.source_system_book_id4 INNER JOIN
		portfolio_hierarchy book ON sbm.fas_book_id = book.entity_id INNER JOIN
		portfolio_hierarchy str ON str.entity_id = book.parent_entity_id LEFT OUTER JOIN
		source_counterparty sc on sc.source_counterparty_id = sdh.counterparty_id LEFT OUTER JOIN
		source_price_curve_def spcd ON sdd.curve_id = spcd.source_curve_def_id left outer join
		rec_generator rg on rg.generator_id = sdh.generator_id left outer join
		source_uom su on su.source_uom_id = sdd.deal_volume_uom_id left outer join
		source_currency scur on scur.source_currency_id = sdd.fixed_price_currency_id
									 
	
	
		where 	sbm.fas_deal_type_value_id <> 402 
			and isnull(sdh.status_value_id, 5171) NOT IN (5170, 5179)
			AND sdh.assignment_type_value_id IS NULL		

	' + case when (@source_deal_header_id IS NULL) THEN '' 
		else ' and sdh.source_deal_header_id in (' + @source_deal_header_id + ')' end 
	+ case when (@book_deal_type_map_id IS NULL) THEN '' 
		else ' and sbm.book_deal_type_map_id in (' + @book_deal_type_map_id + ')' end 
	+ case when (@deal_date_from IS NULL AND @deal_date_to IS NULL) THEN '' 
		else ' and dbo.FNAGetContractMonth(sdh.deal_date) ' + @date_stmt end 
	+ case when (@counterparty_id IS NULL) THEN '' 
		else ' and sc.source_counterparty_id = ' + cast(@counterparty_id as varchar) end 
	+ case when (@counterparty_id IS NOT NULL OR isnull(@int_ext_flag, 'b') = 'b') THEN '' 
		else ' and sc.int_ext_flag = ''' + @int_ext_flag + '''' end 
	+ case when (@sub_entity_id IS NULL) THEN '' 
		else ' and str.parent_entity_id in (' + @sub_entity_id + ')' end 
	+ case when (@strategy_entity_id IS NULL) THEN '' 
		else ' and str.entity_id in (' + @strategy_entity_id + ')' end 
	+ case when (@book_entity_id IS NULL) THEN '' 
		else ' and book.entity_id in (' + @book_entity_id + ')' end 
	
--	EXEC spa_print @sql_stmt
	
	EXEC (@sql_stmt )		
END


--If @summary_option = 'r'
--BEGIN
--
--	INSERT INTO  save_confirm_status
--	SELECT @counterparty_id, @deal_date_from, dbo.FNADBUser(), getdate(), CASE WHEN(@statustype = 'e') THEN 's' ELSE 'v' END, @source_deal_header_id
--
--	SET @confirm_id = SCOPE_IDENTITY()
--	
--	DECLARE @statusCount AS INT,@is_confirm AS CHAR(5)
--	SELECT  @statusCount=COUNT(*) FROM save_confirm_status WHERE source_deal_header_id=@source_deal_header_id AND status = 's'
--	IF @statusCount <= 1 
--	BEGIN
--		SET @is_confirm = 'n'
--	END
--	ELSE
--	BEGIN
--		SET @is_confirm = 'y'
--	END
--	EXEC spa_print @is_confirm
--
--	INSERT INTO save_confirm_detail
--	SELECT @confirm_id, #temp.* FROM #temp 
--
--
--	INSERT INTO confirm_status
--	SELECT @source_deal_header_id, @statustype, GETDATE(), NULL, NULL, @confirm_id,
--			NULL,NULL, NULL,NULL 
--
--	UPDATE source_deal_header SET
--				deal_locked=@deal_locked
--				WHERE source_deal_header_id = @source_deal_header_id


--	insert into confirm_status
--	select distinct source_deal_header_id, 'w', GETDATE(), NULL, NULL, scs.confirm_id,
--			NULL,NULL, NULL,NULL 
--	from #temp left outer join
--	(select counterparty_id, max(confirm_id) confirm_id from save_confirm_status
--	 group by counterparty_id) scs on
--		scs.counterparty_id = #temp.counterparty_id

--	IF EXISTS ( SELECT confirm_status_id FROM confirm_status_recent c
--				INNER JOIN #temp t ON t.source_deal_header_id=c.source_deal_header_id)
--	BEGIN
--		UPDATE confirm_status_recent SET TYPE=@statustype , as_of_date=GETDATE(),confirm_id=@confirm_id,is_confirm = @is_confirm
--		WHERE source_deal_header_id=@source_deal_header_id
--	END
--	ELSE
--	BEGIN			
--			INSERT INTO confirm_status_recent
--			SELECT DISTINCT source_deal_header_id, @statustype, GETDATE(), NULL, NULL, scs.confirm_id,
--					NULL,NULL, NULL,NULL,@is_confirm
--			FROM #temp left outer join
--			(SELECT counterparty_id, max(confirm_id) confirm_id FROM save_confirm_status
--			 GROUP BY counterparty_id) scs ON
--				scs.counterparty_id = #temp.counterparty_id
--	END
--	
--	DECLARE @returnvalue VARCHAR(100)
--	SET @returnvalue = @statustype +','+@is_confirm
--
--	IF @@ERROR <> 0
--	BEGIN
--		-- I think we should insert detail errors in msgboard which might be done by 
--		-- dbo.spb_Process_Transactions already????
--		
--		Exec spa_ErrorHandler @@ERROR, 'Save Confirm', 
--				'spa_create_rec_confirm_report', 'Error', 
--				'Failed to  save Confirm', ''		
--	
--	END
--	Else
--		Exec spa_ErrorHandler 0, 'Save Invoice', 
--				'spa_create_rec_confirm_report', 'Success', 
--				'Confirm Saved', @returnvalue

--END
ELSE
BEGIN
EXEC spa_print @confirm_id
	if @confirm_id IS NULL
	BEGIN
		select 	DealID [Ref ID], DealDate [Deal Date], ProductionMonth [Term], BuySell [Buy Sell],
			isnull(generator_code+ '/', '') + curve_name [Credit Source/Env Product],
			Volume [Volume], Unit [UOM], --'Hour' [Frequency], 
			Price [Price/UOM],
			currency [Currency]
			from #temp
		order by DealDate, DealID, ProductionMonth
	end

	else
		select 	DealID [Ref ID], DealDate [Deal Date], ProductionMonth [Term], BuySell [Buy Sell],
			isnull(generator_code+ '/', '')  + curve_name [Credit Source/Env Product],
			Volume [Volume], Unit [UOM], --'Hour' [Frequency], 
			Price [Price/UOM],
			currency [Currency]
			from save_confirm_detail where confirm_id = @confirm_id
		order by DealDate, DealID, ProductionMonth
		

END


















