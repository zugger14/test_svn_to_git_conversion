

------select dbo.FNAFindLastFrequencyDate ('02/01/2009','02/28/2009','m')
IF OBJECT_ID('dbo.spa_DoTransactionBlotter','p') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.spa_DoTransactionBlotter
END
GO
CREATE PROC dbo.spa_DoTransactionBlotter
	@flag char(1),
	@counterparty	int=null,
	@trader			INT	=null,
	@dealtype		INT	=null,
	@deal_date	  DATETIME=null,
	@xml		  varchar(max)=null

AS
------------------------test
/*
--exec spa_DoTransaction 'u',636,493,983,'03/01/2009', '<Root><PSRecordset edit_grid1="11336" edit_grid2="2009-03-01" edit_grid3="2009-03-31" edit_grid4="1" edit_grid5="2009-03-31" edit_grid6="t" edit_grid7="s" edit_grid10="242" edit_grid11="" edit_grid12="" edit_grid13="2" edit_grid14="" edit_grid15="900" edit_grid16="3" edit_grid17="m" edit_grid18="" edit_grid19="" edit_grid20="Physical" edit_grid21="3"></PSRecordset></Root>'
--exec spa_DoTransaction 'u',636,493,983,'03/01/2009', '<Root><PSRecordset edit_grid1="11335" edit_grid2="2009-03-01" edit_grid3="2009-03-31" edit_grid4="1" edit_grid5="2009-03-31" edit_grid6="t" edit_grid7="s" edit_grid10="246" edit_grid11="" edit_grid12="" edit_grid13="2" edit_grid14="" edit_grid15="900" edit_grid16="3" edit_grid17="m" edit_grid18="" edit_grid19="" edit_grid20="Physical" edit_grid21="3"></PSRecordset></Root>'
declare	@counterparty	int,@flag varchar(1),
	@trader			INT	,
	@dealtype		INT	,
	@deal_date	  DATETIME,
	@xml		  varchar(max)
set @flag='u'
set @counterparty=636
set 	@trader		=493
set 	@dealtype	=983
set 	@deal_date	='03/01/2009'
set @xml='
<Root><PSRecordset edit_grid1="11336" edit_grid2="2009-03-01" edit_grid3="2009-03-31" edit_grid4="1" edit_grid5="2009-03-31" edit_grid6="t" edit_grid7="s" edit_grid10="242" edit_grid11="" edit_grid12="" edit_grid13="2" edit_grid14="" edit_grid15="900" edit_grid16="3" edit_grid17="m" edit_grid18="" edit_grid19="" edit_grid20="Physical" edit_grid21="3"></PSRecordset></Root>'
drop table #tmp
drop table #source_deals
drop table #tmpb
drop table #tmp1
drop table #tmp_upd
---------------------------
*/



declare @idoc int
declare @process varchar(1) --d=restrict, p=warning		
declare @vol_c_b 	float,@vol_t_b 	float,@vol_c_s 	float,@vol_t_s 	float,@ten_c_limit int,@ten_t_limit int
declare @vol_c_limit_b 	float,@vol_t_limit_b 	float,@vol_c_limit_s 	float,@vol_t_limit_s 	float,@tenor int
declare @desc varchar(1000),@ComExists varchar(1), @dealExists  varchar(1),@CommodityID int,@frequency int
declare @tmp_msg_c varchar(1000),@tmp_msg_t varchar(1000),@buy_sell_flag varchar(1)
select @tmp_msg_c=counterparty_name from source_counterparty where source_counterparty_id=@counterparty
select @tmp_msg_t=trader_name from source_traders where source_trader_id=@trader

declare @term_start datetime,@term_end datetime, @deal_volume_frequency varchar(1),
@deal_volume_b float,@deal_volume_s float,@indexID int
DECLARE @st_sql VARCHAR(5000)
exec sp_xml_preparedocument @idoc OUTPUT, @xml

DECLARE @deal_id VARCHAR(50)

CREATE TABLE #tmp (deal_id VARCHAR(50) COLLATE DATABASE_DEFAULT,
				term_start  Datetime,
				term_end  Datetime,
				buy_sell_flag  CHAR(1) COLLATE DATABASE_DEFAULT,	 
				curve_id  VARCHAR(100) COLLATE DATABASE_DEFAULT ,	 
				deal_volume  FLOAT ,
				deal_volume_frequency  CHAR(1) COLLATE DATABASE_DEFAULT,
				counterparty int,trader int,deal_date Datetime
				)

IF @flag='c' OR @flag='i'
BEGIN

	INSERT INTO #tmp (deal_id,term_start,term_end,buy_sell_flag,curve_id ,deal_volume,deal_volume_frequency,counterparty ,trader ,deal_date)
	SELECT 	clmDealId,dbo.FNASTDDate(term_start) AS term_start,dbo.FNASTDDate(term_end) AS term_end,buy_sell_flag,curve_id,	deal_volume,deal_volume_frequency,@counterparty,@trader,dbo.FNASTDDate(@deal_date)
	FROM   OPENXML (@idoc, '/Root/PSRecordset',2)
		 WITH ( 
--				term_start  Datetime    '@edit_grid7',
--				term_end  Datetime    '@edit_grid8',
--				buy_sell_flag  CHAR(1)         '@edit_grid3',	 
--				curve_id  VARCHAR(100)         '@edit_grid5',	 
--				deal_volume  FLOAT         '@edit_grid9',
--				deal_volume_frequency  CHAR(1)   '@edit_grid6'

--				term_start  VARCHAR(20)    '@edit_grid7',
--				term_end  VARCHAR(20)    '@edit_grid8',
--				buy_sell_flag  CHAR(1)         '@edit_grid3',	 
--				curve_id  VARCHAR(100)         '@edit_grid5',	 
--				deal_volume  FLOAT         '@edit_grid10',
--				deal_volume_frequency  CHAR(1)   '@edit_grid9'
				clmDealId VARCHAR(50)		'@edit_grid2',
				term_start  VARCHAR(20)    '@edit_grid8',
				term_end  VARCHAR(20)    '@edit_grid9',
				buy_sell_flag  CHAR(1)         '@edit_grid4',	 
				curve_id  VARCHAR(100)         '@edit_grid6',	 
				deal_volume  FLOAT         '@edit_grid11',
				deal_volume_frequency  CHAR(1)   '@edit_grid10'

			)
	
	
			
--select * from #tmp
END
ELSE IF @flag='u'
begin
	SELECT * into #tmp_upd
	FROM   OPENXML (@idoc, '/Root/PSRecordset',2)
         WITH (source_deal_detail_id  INT    '@edit_grid1',
--	       term_start  Datetime    '@edit_grid2',
--           term_end  Datetime    '@edit_grid3',
--           leg  CHAR(1)    '@edit_grid4',
--	       buy_sell_flag  CHAR(1)         '@edit_grid7',	 
--	       curve_id  VARCHAR(100)         '@edit_grid10',	 
--	       deal_volume  FLOAT         '@edit_grid15',
--	       deal_volume_frequency  CHAR(1)         '@edit_grid17'

				clmDealId VARCHAR(50)		'@edit_grid2',
				term_start  VARCHAR(20)    '@edit_grid8',
				term_end  VARCHAR(20)    '@edit_grid9',
				buy_sell_flag  CHAR(1)         '@edit_grid4',	 
				curve_id  VARCHAR(100)         '@edit_grid6',	 
				deal_volume  FLOAT         '@edit_grid11',
				deal_volume_frequency  CHAR(1)   '@edit_grid10'
			)	
	--		select * from #tmp_upd
	SELECT 	MIN(Z.term_start) term_start,MAX(Z.term_end) term_end,MAX(Z.deal_volume_frequency) deal_volume_frequency,
	MAX(Z.buy_sell_flag) buy_sell_flag_new,MAX(t.buy_sell_flag) buy_sell_flag_old,SUM(CASE WHEN z.buy_sell_flag='s' THEN -1 ELSE 1 END * z.deal_volume) deal_volume_new,
	SUM(CASE WHEN t.buy_sell_flag='s' THEN -1 ELSE 1 END * t.deal_volume) deal_volume_old,
	MAX(t.curve_id) curve_id_old,MAX(z.curve_id) curve_id_new,max(sdh.trader_id) trader_id_old,@trader trader_id_new,max(sdh.counterparty_id) counterparty_id_old,@counterparty counterparty_id_new   INTO #tmp1
	from 	#tmp_upd z join source_deal_detail t on t.source_deal_detail_id=z.source_deal_detail_id inner join source_deal_header sdh
	on t.source_deal_header_id=sdh.source_deal_header_id
	GROUP BY z.clmDealId
--	select * from #tmp1
	INSERT INTO #tmp (term_start,term_end,buy_sell_flag,curve_id,deal_volume,deal_volume_frequency,counterparty ,trader ,deal_date )
	select  dbo.FNACovertToSTDDate(term_start) AS term_start,dbo.FNACovertToSTDDate(term_end) AS term_end,buy_sell_flag_new,curve_id_new curve_id,
	CASE WHEN curve_id_old<>curve_id_new or buy_sell_flag_old<>buy_sell_flag_new or counterparty_id_old<>counterparty_id_new or trader_id_old<>trader_id_new THEN
		 ABS(ISNULL(deal_volume_new,0))
	ELSE	
		 abs(ISNULL(deal_volume_new,0))-abs(ISNULL(deal_volume_old,0)) end
	deal_volume,deal_volume_frequency,@counterparty ,@trader,@deal_date 
	from 	#tmp1
--select * from #tmp_upd
--select * from #tmp
--	select * from #tmp1
end
ELSE IF @flag='b'
begin
	create table #source_deals (
		row_no int ,
		clm0 varchar(100) COLLATE DATABASE_DEFAULT, --deal_id
		clm1 varchar(100) COLLATE DATABASE_DEFAULT, --deal_date
		clm2 varchar(100) COLLATE DATABASE_DEFAULT, --buy/sell
		clm3 varchar(100) COLLATE DATABASE_DEFAULT,  --location_id
		clm4 varchar(100) COLLATE DATABASE_DEFAULT,  --index
		clm5 varchar(100) COLLATE DATABASE_DEFAULT, --frequency 
		clm6 varchar(100) COLLATE DATABASE_DEFAULT, --term_start
		clm7 varchar(100) COLLATE DATABASE_DEFAULT, --term end 
		clm8 varchar(100) COLLATE DATABASE_DEFAULT,  --volume
		clm9 varchar(100) COLLATE DATABASE_DEFAULT, --uom
		clm10 varchar(100) COLLATE DATABASE_DEFAULT, --price
		clm11 varchar(100) COLLATE DATABASE_DEFAULT, --currency
		clm12 varchar(100) COLLATE DATABASE_DEFAULT, --counteryparty
		clm13 varchar(100) COLLATE DATABASE_DEFAULT, --broker
		clm14 varchar(100) COLLATE DATABASE_DEFAULT, --trader
		clm15 varchar(30) COLLATE DATABASE_DEFAULT, --contract
		clm16 varchar(100) COLLATE DATABASE_DEFAULT, --option_strike_price
		clm17 varchar(100) COLLATE DATABASE_DEFAULT, --price_adder
		clm18 varchar(100) COLLATE DATABASE_DEFAULT --price_multipier
	)

		insert into #source_deals
		exec spa_sourcedealheader_xml_2table @xml
		delete from #source_deals where  row_no in ( select row_no from   #source_deals where clm1='undefined' OR clm2='undefined' 
					OR clm5='undefined' OR clm6 is NULL OR clm7 is NULL OR clm8 is NULL OR clm9 is NULL OR clm12='undefined' OR clm14='undefined' 
						 OR clm9='undefined')

		update #source_deals  set clm13=null where clm13='undefined'
        update #source_deals  set clm3=null where clm3='undefined'
        update #source_deals  set clm15=null where clm15='undefined'
		update #source_deals  set clm4=null where clm4='undefined'
		update #source_deals  set clm10=null where clm10 is NULL OR  rtrim(ltrim(clm10))='NULL' 

		select max(clm6) term_start,max(clm7) term_end,max(clm2) buy_sell_flag_new,max(sdd.buy_sell_flag) buy_sell_flag_old,max(clm4) curve_id_new
		,sum(case when clm2='b' then 1 else -1 end * a.clm8) deal_volume_new,max(clm5) deal_volume_frequency
		,sum(case when sdd.buy_sell_flag='b' then 1 else -1 end * isnull(sdd.deal_volume,0)) deal_volume_old,max(sdd.curve_id) curve_id_old
		,max(clm12) counterparty,max(clm14) trader,max(clm1) deal_date
		into #tmpb 
from #source_deals a left join  source_deal_header sdh  on  sdh.deal_id=a.clm0
		left join source_deal_detail sdd on sdd.source_deal_header_id=sdh.source_deal_header_id
		group by a.clm0


	INSERT INTO #tmp (term_start,term_end,buy_sell_flag,curve_id,deal_volume,deal_volume_frequency,counterparty,trader,deal_date )
	select  term_start,term_end,buy_sell_flag_new,curve_id_new curve_id,
	CASE WHEN curve_id_old<>curve_id_new or buy_sell_flag_old<>buy_sell_flag_new THEN
		 ABS(ISNULL(deal_volume_new,0))
	ELSE	
		 abs(ISNULL(deal_volume_new,0))-abs(ISNULL(deal_volume_old,0)) end
	deal_volume,deal_volume_frequency,counterparty,trader,deal_date 
	from 	#tmpb

end

--select * from #tmp

exec sp_xml_removedocument @idoc

DECLARE b_cursor CURSOR FOR 
select  deal_id,term_start,term_end,deal_volume_frequency,CASE WHEN buy_sell_flag='b' THEN deal_volume ELSE 0 END deal_volume_b,CASE WHEN buy_sell_flag='s' THEN deal_volume ELSE 0 END deal_volume_s,curve_id,counterparty,trader,deal_date,buy_sell_flag
from 	#tmp order by term_start,term_end
OPEN b_cursor
FETCH NEXT FROM b_cursor
INTO @deal_id,@term_start,@term_end, @deal_volume_frequency,@deal_volume_b,@deal_volume_s,@indexID,@counterparty,@trader,@deal_date,@buy_sell_flag
WHILE @@FETCH_STATUS = 0   
BEGIN 

	SELECT @ComExists= null, @dealExists= null,@process=null,@vol_c_b=null,@vol_t_b=null,@vol_c_s=null,@vol_t_s=null,@ten_c_limit=null,@ten_t_limit=null,
	@vol_c_limit_b=null,@vol_t_limit_b=null,@tenor=null,@desc=null,@vol_c_limit_s=null,@vol_t_limit_s=null


	---------------------counterparty_credit_block_trading
	SELECT @CommodityID = commodity_id FROM source_price_curve_def
	WHERE source_curve_def_id = @indexID

	select 		@ComExists=max(case when ccbt.comodity_id=@CommodityID	 then 'y' else 'n' end	) ,
		@dealExists	=max(case when ccbt.deal_type_id=@dealtype then 'y' else 'n' end	) 
	from 
	counterparty_credit_info scpi inner join counterparty_credit_block_trading ccbt 
	on ccbt.counterparty_credit_info_id=scpi.counterparty_credit_info_id
	and Counterparty_id=@Counterparty

	if @ComExists='y' 
	begin
		CLOSE b_cursor
		DEALLOCATE  b_cursor
		select @desc='The commodity in the index:'+ curve_name + ' is not allowed to transact for the counterparty:'+ @tmp_msg_c +'.' from source_price_curve_def where source_curve_def_id=@indexid
		goto aaa
	end

	if @dealExists='y'
	begin
		CLOSE b_cursor
		DEALLOCATE  b_cursor
		select @desc='The Deal type is not allowed to transact for the counterparty:'+ @tmp_msg_c +'.' from source_price_curve_def where source_curve_def_id=@indexid
		goto aaa
	end

	if exists (select deal_id from source_deal_header where deal_id=@deal_id) 
	begin
		CLOSE b_cursor
		DEALLOCATE  b_cursor
		select @desc='Cannot insert duplicate Ref Id:'+ @deal_id
		goto aaa
				
	end



--	select @process=min(isnull(proceed,'p')),
--	@vol_c_limit_b=min(case when counterparty_id= @counterparty and ltc.position_limit>0 then ltc.position_limit else null end)
--	,@vol_t_limit_b=min(case when trader_id= @trader and ltc.position_limit>0 then ltc.position_limit else null end)
--	,@vol_c_limit_s=max(case when counterparty_id= @counterparty and ltc.position_limit<0 then ltc.position_limit else null end)
--	,@vol_t_limit_s=max(case when trader_id= @trader and ltc.position_limit<0 then ltc.position_limit else null end)
--	,@ten_c_limit=min(case when counterparty_id= @counterparty then ltc.tenor_limit else null end)
--	,@ten_t_limit =min(case when trader_id= @trader then ltc.tenor_limit else null end)
--	from limit_tracking lt inner join limit_tracking_curve ltc on lt.limit_id=ltc.limit_id and lt.actionChecked='y' and limit_type=1581
--	and ltc.curve_id=@indexID 




		if @deal_volume_frequency='m' 
			select @frequency=datediff(month,@term_start,@term_end)
		else if @deal_volume_frequency='q'
		Begin
			 select @frequency=datediff(month,@term_start,@term_end)	
			 select @frequency=round(@frequency/3,0)
		End
		else if @deal_volume_frequency='s'
		Begin
			select @frequency=datediff(month,@term_start,@term_end)	
			select 	@frequency=round(@frequency/6,0)
		End
		else if @deal_volume_frequency='a'
		Begin
			select @frequency=datediff(month,@term_start,@term_end)	
			select 	@frequency=round(@frequency/12,0)
		End
		else if @deal_volume_frequency='d'
			select @frequency=datediff(day,@term_start,@term_end)
		else if @deal_volume_frequency='w'
			select @frequency=round(datediff(day,@term_start,@term_end)/7,0)
		else if @deal_volume_frequency='h'
			select @frequency=0
		set @frequency=@frequency+1


--------------------------------------------------------------------------------------------------------------------
--validating fot counterparty

		select @process=min(isnull(proceed,'p')),
		@vol_c_limit_b=min(case when ltc.position_limit>0 then ltc.position_limit else null end)
		,@vol_c_limit_s=max(case when  ltc.position_limit<0 then ltc.position_limit else null end)
		,@ten_c_limit=min(ltc.tenor_limit)
		from limit_tracking lt inner join limit_tracking_curve ltc on lt.limit_id=ltc.limit_id and lt.actionChecked='y' and limit_type=1581
		and ltc.curve_id=@indexID and counterparty_id= @counterparty

--	select @process '@process',@vol_c_limit_b '@vol_c_limit_b'
--	,@vol_t_limit_b '@vol_t_limit_b'
--	,@vol_c_limit_s '@vol_c_limit_s'
--	,@vol_t_limit_s '@vol_t_limit_s'
--	,@ten_c_limit '@ten_c_limit'
--	,@ten_t_limit '@ten_t_limit'

	if  @process is not null
	begin

		select 
		@vol_c_b=sum(case when  buy_sell_flag='b' then sdd.deal_volume else null end) 	
		,@vol_c_s=sum(case when  buy_sell_flag='s' then sdd.deal_volume else null end)
		from source_deal_header sdh inner join source_deal_detail sdd 
		on sdh.source_deal_header_id=sdd.source_deal_header_id   and sdd.curve_id=@indexID
		and sdh.counterparty_id= @counterparty

--	select	@vol_c_b	 '@vol_c_b'
--		,@vol_t_b '@vol_t_b'
--		,@vol_c_s '@vol_c_s'
--		,@vol_t_s '@vol_t_s'


		if @buy_sell_flag='b'
		begin 
			if @vol_c_limit_b is not null
			begin
				if @vol_c_limit_b<@vol_c_b 
				begin
					CLOSE b_cursor
					DEALLOCATE  b_cursor
					select @desc='The buying volume of the index:'+ curve_name + ' exceeded the limit before this transaction for the counterparty:'+ @tmp_msg_c +'.' from source_price_curve_def where source_curve_def_id=@indexid
					goto aaa
				end
				set @vol_c_b=isnull(@vol_c_b,0)+(@deal_volume_b*@frequency)
				if @vol_c_limit_b<@vol_c_b
				begin
					CLOSE b_cursor
					DEALLOCATE  b_cursor
					select @desc='The buying volume of the index:'+ curve_name + ' exceeded the limit for the counterparty:'+ @tmp_msg_c +' by '+cast(abs(@vol_c_limit_b-@vol_c_b) as varchar)+'.' from source_price_curve_def where source_curve_def_id=@indexid
					goto aaa
				end
			end
		end
		if @buy_sell_flag='s'
		begin 
			if @vol_c_limit_s is not null
			begin
				if abs(@vol_c_limit_s)<@vol_c_s 
				begin
					CLOSE b_cursor
					DEALLOCATE  b_cursor
					select @desc='The selling volume of the index:'+ curve_name + ' exceeded the limit before this transaction for the counterparty:'+ @tmp_msg_c +'.' from source_price_curve_def where source_curve_def_id=@indexid
					goto aaa
				end
				set @vol_c_s=abs(isnull(@vol_c_s,0))+abs((@deal_volume_s*@frequency))
				if abs(@vol_c_limit_s)<abs(@vol_c_s)
				begin
					CLOSE b_cursor
					DEALLOCATE  b_cursor
					select @desc='The selling volume of the index:'+ curve_name + ' exceeded the limit for the counterparty:'+ @tmp_msg_c +' by '+cast(abs(abs(@vol_c_limit_s)-@vol_c_s) as varchar)+'.' from source_price_curve_def where source_curve_def_id=@indexid
					goto aaa
				end
			end
		end

		SELECT @term_start = dbo.FNAFindLastFrequencyDate (@term_start,@term_end,@deal_volume_frequency)
		SELECT @tenor = DATEDIFF(DAY,@deal_date,@term_start)
		if @ten_c_limit<@tenor 
		begin
			CLOSE b_cursor
			DEALLOCATE  b_cursor
			select @desc='The Tenor of the index:'+ curve_name + ' exceeded the limit for the counterparty:'+ @tmp_msg_c +' by '+cast(abs(@tenor-@ten_c_limit) as varchar) +'.' from source_price_curve_def where source_curve_def_id=@indexid
			goto aaa
		end
	end 
	set @process=null
	select @process=min(isnull(proceed,'p')),
	@vol_t_limit_b=min(case when  ltc.position_limit>0 then ltc.position_limit else null end)
	,@vol_t_limit_s=max(case when ltc.position_limit<0 then ltc.position_limit else null end)
	,@ten_t_limit =min(ltc.tenor_limit)
	from limit_tracking lt inner join limit_tracking_curve ltc on lt.limit_id=ltc.limit_id and lt.actionChecked='y' and limit_type=1581
	and ltc.curve_id=@indexID  and trader_id= @trader
/*
	select @process_vol_b=min(isnull(proceed,'p')),
	@process_vol_s=min(case when  ltc.position_limit>0 then ltc.position_limit else null end)
	,@vol_t_limit_s=max(case when ltc.position_limit<0 then ltc.position_limit else null end)
	,@ten_t_limit =min(ltc.tenor_limit)
	from limit_tracking lt inner join limit_tracking_curve ltc on lt.limit_id=ltc.limit_id and lt.actionChecked='y' and limit_type=1581
	and ltc.curve_id=@indexID  and trader_id= @trader

	select min(case when  ltc.position_limit>0 then ltc.position_limit else null end) l_v_b
	,max(case when  ltc.position_limit<0 then ltc.position_limit else null end) l_v_s
	from limit_tracking lt inner join limit_tracking_curve ltc on lt.limit_id=ltc.limit_id and lt.actionChecked='y' and limit_type=1581
	and ltc.curve_id=@indexID  and trader_id= @trader

select * from  limit_tracking
select * from limit_tracking_curve
*/
--------------------------------------------------------------------------------------------------------------------------------
--validating fot trader
	if  @process is not null
	begin
		select 
		@vol_t_b=sum(case when buy_sell_flag='b' then sdd.deal_volume else null end)
		,@vol_t_s=sum(case when buy_sell_flag='s' then sdd.deal_volume else null end)
		from source_deal_header sdh inner join source_deal_detail sdd 
		on sdh.source_deal_header_id=sdd.source_deal_header_id   and sdd.curve_id=@indexID
		and sdh.trader_id= @trader

		if @buy_sell_flag='b'
		begin 
		if @vol_t_limit_b is not null
			begin
				if @vol_t_limit_b<@vol_t_b 
				begin
					CLOSE b_cursor
					DEALLOCATE  b_cursor
					select @desc='The buying volume of the index:'+ curve_name + ' exceeded the limit before this transaction for the trader:'+ @tmp_msg_t +'.' from source_price_curve_def where source_curve_def_id=@indexid
					goto aaa
				end
				set @vol_t_b=isnull(@vol_t_b,0)+(@deal_volume_b*@frequency)
				if @vol_t_limit_b<@vol_t_b
				begin
					CLOSE b_cursor
					DEALLOCATE  b_cursor
					select @desc='The buying volume of the index:'+ curve_name + ' exceeded the limit for the trader:'+ @tmp_msg_t +' by '+cast(abs(@vol_t_limit_b-@vol_t_b ) as varchar)+'.' from source_price_curve_def where source_curve_def_id=@indexid
					goto aaa
				end
			end
		end
		if @buy_sell_flag='s'
		begin 
			if @vol_t_limit_s is not null
			begin
				if abs(@vol_t_limit_s)<abs(@vol_t_s )
				begin
					CLOSE b_cursor
					DEALLOCATE  b_cursor
					select @desc='The selling volume of the index:'+ curve_name + ' exceeded the limit before this transaction for the trader:'+ @tmp_msg_t +'.' from source_price_curve_def where source_curve_def_id=@indexid
					goto aaa
				end
				set @vol_t_s=abs(isnull(@vol_t_s,0))+abs((@deal_volume_s*@frequency))
				if abs(@vol_t_limit_s)<@vol_t_s
				begin
					CLOSE b_cursor
					DEALLOCATE  b_cursor
					select @desc='The selling volume of the index:'+ curve_name + ' exceeded the limit for the trader:'+ @tmp_msg_t +' by '+cast(abs(abs(@vol_t_limit_s)-@vol_t_s)  as varchar)+'.' from source_price_curve_def where source_curve_def_id=@indexid
					goto aaa
				end
			end
		end
		SELECT @term_start = dbo.FNAFindLastFrequencyDate (@term_start,@term_end,@deal_volume_frequency)
		SELECT @tenor = DATEDIFF(DAY,@deal_date,@term_start)

		if @ten_t_limit<@tenor
		begin
			CLOSE b_cursor
			DEALLOCATE  b_cursor
			select @desc='The Tenor of the index:'+ curve_name + ' exceeded the limit for the trader:'+ @tmp_msg_t +' by '+cast(abs(@tenor-@ten_t_limit) as varchar) +'.' from source_price_curve_def where source_curve_def_id=@indexid
			goto aaa
		end
----------------------------------------end trader validation

	end
	FETCH NEXT FROM b_cursor
	INTO @deal_id,@term_start,@term_end, @deal_volume_frequency,@deal_volume_b,@deal_volume_s,@indexID,@counterparty,@trader,@deal_date,@buy_sell_flag
end
CLOSE b_cursor
DEALLOCATE  b_cursor


aaa:
SELECT @desc desc_err, @process Process				

