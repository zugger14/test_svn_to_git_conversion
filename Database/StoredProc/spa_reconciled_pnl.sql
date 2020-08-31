
IF OBJECT_ID('spa_reconciled_pnl') IS NOT NULL
	DROP  PROCEDURE [dbo].[spa_reconciled_pnl]
GO

CREATE PROC [dbo].[spa_reconciled_pnl] 
	@calc_reconciled VARCHAR(1) = 'y',
	@as_of_date DATETIME,
	@cpty_cat_id VARCHAR(200),
	@rounding VARCHAR(2) = '4',
	@sub_id VARCHAR(MAX) = NULL,
	@stra_id VARCHAR(MAX) = NULL,
	@book_id VARCHAR(MAX) = NULL
AS

/*

DROP TABLE #tmp
DROP TABLE #final_source_deal_header_id
DROP TABLE #used_source_deal_header_id
DROP TABLE #tmp_match
DROP TABLE #tmp_unmatch
DROP TABLE #tmp_miss
DECLARE @as_of_date datetime,@flag varchar(1),@calc_reconciled varchar(1),@cpty_cat_id varchar(200)
SET @as_of_date='2008-03-31'
SET @as_of_date='2004-07-30'

SET @calc_reconciled='y'
set @cpty_cat_id='Broker'
*/
EXEC spa_print '****************start reconciled curent main************'

--*********************************************************************************

--Replace NULL with string 'NULL' (as when called by Report Writer, 'NULL' is passed instead of NULL), 
--so that they can be handled in the same way. 
SET @sub_id = ISNULL(@sub_id, 'NULL')
SET @stra_id = ISNULL(@stra_id, 'NULL')
SET @book_id = ISNULL(@book_id, 'NULL')

create table #used_source_deal_header_id (source_deal_header_id int)
create table #final_source_deal_header_id (cat_order tinyint,sub_cat_order tinyint, source_deal_header_id int,struc_deal_header_id int)


create table #pnl1 (
source_deal_header_id int,
deal_date datetime,
deal_id varchar(50) COLLATE DATABASE_DEFAULT,
source_system_book_id4 int, 
und_pnl float )

create table #pnl2 (
source_deal_header_id int,
deal_date datetime,
deal_id varchar(50) COLLATE DATABASE_DEFAULT,
source_system_book_id4 int, 
und_pnl float )



--select source_deal_header_id from source_deal_header where deal_date <= @as_of_date AND structured_deal_id IS NULL
declare @st varchar(max)
DECLARE @source_deal_header_id int,@struc_source_deal_header_id INt
DECLARE @deal_id varchar(100),@structured_deal_id varchar(100),@und_pnl float,@struc_und_pnl float
declare @pnl1 varchar(5000),@pnl2 varchar(5000)

-- start process update structured_deal_id in source_deal_header
set @st='
insert into #pnl1 
SELECT sdp.source_deal_header_id,sdh.deal_date,deal_id,source_system_book_id4, round(sum(und_pnl),' + @rounding + ') und_pnl 
FROM source_deal_pnl sdp INNER join	source_deal_header sdh 
ON sdh.source_deal_header_id=sdp.source_deal_header_id AND structured_deal_id IS null
AND pnl_as_of_date=''' + cast(@as_of_date as varchar) + ''' AND deal_date <= ''' + cast(@as_of_date as varchar) + '''
inner join source_counterparty sc  
on sc.source_counterparty_id=sdh.counterparty_id and sc.int_ext_flag=''i'' 
inner join static_data_value sdv on sdv.value_id=sc.type_of_entity and sdv.code= ''' + @cpty_cat_id + '''
GROUP BY sdp.source_deal_header_id,sdh.deal_date,deal_id,source_system_book_id4
'
exec(@st)
set @st='
insert into #pnl2 
SELECT sdp.source_deal_header_id,sdh.deal_date,deal_id,source_system_book_id4, round(-1*sum(und_pnl),' + @rounding + ') und_pnl FROM source_deal_pnl sdp INNER join
source_deal_header sdh ON sdh.source_deal_header_id=sdp.source_deal_header_id AND structured_deal_id IS null
AND pnl_as_of_date=''' + cast(@as_of_date as varchar) + ''' AND deal_date <= ''' + cast(@as_of_date as varchar) + '''
inner join source_counterparty sc  
on sc.source_counterparty_id=sdh.counterparty_id and sc.int_ext_flag=''i'' 
inner join static_data_value sdv on sdv.value_id=sc.type_of_entity and sdv.code= ''' + @cpty_cat_id + '''
GROUP BY sdp.source_deal_header_id,sdh.deal_date,deal_id,source_system_book_id4
'
exec(@st)

create index inx_pnl1_aaa on #pnl1 (source_deal_header_id,und_pnl,source_system_book_id4)
create index inx_pnl1_date on #pnl1 (deal_date)
create index inx_pnl2_aaa on #pnl2 (source_deal_header_id,und_pnl,source_system_book_id4)
create index inx_pnl2_date on #pnl2 (deal_date)


	EXEC spa_print '**********************************************************************************'
	EXEC spa_print 'First time:'--+cast(getdate() as varchar)
	
create table #tmp (
deal_date datetime,source_deal_header_id int,deal_id varchar(50) COLLATE DATABASE_DEFAULT,struc_deal_date datetime,struc_source_deal_header_id int
)
set @st=' insert into #tmp 
	SELECT sdp1.deal_date,sdp1.source_deal_header_id,sdp1.deal_id,sdp2.deal_date struc_deal_date, sdp2.source_deal_header_id struc_source_deal_header_id 
		FROM #pnl1 sdp1 
	INNER JOIN #pnl2 sdp2
	ON sdp1.source_deal_header_id<>sdp2.source_deal_header_id 
	AND round(sdp1.und_pnl,' + @rounding + ')=round(sdp2.und_pnl,' + @rounding + ') AND  sdp1.source_system_book_id4=sdp2.source_system_book_id4
	ORDER BY sdp1.deal_date,sdp1.source_deal_header_id,sdp2.deal_date,sdp2.source_deal_header_id
	'
EXEC spa_print @st
exec(@st)

	EXEC spa_print 'end First time:'--+cast(getdate() as varchar)
	EXEC spa_print '**********************************************************************************'

	while exists (select * from #tmp)
	begin
	EXEC spa_print '**********************************************************************************'
		EXEC spa_print '****************start reconciled************'

		DECLARE perfect_match CURSOR FOR 
		SELECT source_deal_header_id,struc_source_deal_header_id FROM #tmp
		OPEN perfect_match
		FETCH NEXT FROM perfect_match INTO @source_deal_header_id,@struc_source_deal_header_id
		WHILE @@FETCH_STATUS = 0
		BEGIN
			if not exists(select * from #used_source_deal_header_id where source_deal_header_id=@source_deal_header_id OR source_deal_header_id=@struc_source_deal_header_id)
			begin
				INSERT INTO #final_source_deal_header_id (cat_order,sub_cat_order,source_deal_header_id ,struc_deal_header_id )
						VALUES (1,1,@source_deal_header_id,@struc_source_deal_header_id)
				INSERT INTO #used_source_deal_header_id (source_deal_header_id) VALUES (@struc_source_deal_header_id)
				INSERT INTO #used_source_deal_header_id (source_deal_header_id) VALUES (@source_deal_header_id)

			end
		FETCH NEXT FROM perfect_match INTO @source_deal_header_id,@struc_source_deal_header_id
		END
		CLOSE perfect_match
		DEALLOCATE perfect_match

		--update structured_deal_id in source_deal_header
		----------------------------------------------------
		IF @calc_reconciled='y'
		begin
			UPDATE source_deal_header SET structured_deal_id=struc.deal_id 
			FROM source_deal_header sdh 
			INNER JOIN (
				SELECT tmp.source_deal_header_id, deal_id FROM source_deal_header sdh 
				INNER JOIN #final_source_deal_header_id tmp ON sdh.source_deal_header_id=tmp.struc_deal_header_id
			) struc ON  sdh.source_deal_header_id=struc.source_deal_header_id

			UPDATE source_deal_header SET structured_deal_id=struc.deal_id 
			FROM source_deal_header sdh 
			INNER JOIN (
				SELECT tmp.struc_deal_header_id, deal_id FROM source_deal_header sdh 
				INNER JOIN #final_source_deal_header_id tmp ON sdh.source_deal_header_id=tmp.source_deal_header_id
			) struc ON  sdh.source_deal_header_id=struc.struc_deal_header_id
		end
		----------------------------------------------------
		delete #tmp
		EXEC spa_print '**********************************************************************************'
		EXEC spa_print 'insert #tmp time:'--+cast(getdate() as varchar)
		truncate table #pnl1
		truncate table #pnl2
		set @pnl1='
			insert into #pnl1
			SELECT sdp.source_deal_header_id,sdh.deal_date,deal_id,source_system_book_id4, round(sum(und_pnl),' + @rounding + ') und_pnl 
			FROM source_deal_pnl sdp INNER join	source_deal_header sdh 
			ON sdh.source_deal_header_id=sdp.source_deal_header_id AND structured_deal_id IS null
			AND pnl_as_of_date=''' + cast(@as_of_date as varchar) +''' AND deal_date <= ''' + cast(@as_of_date as varchar) +'''
			inner join source_counterparty sc  
			on sc.source_counterparty_id=sdh.counterparty_id and sc.int_ext_flag=''i'' 
			inner join static_data_value sdv on sdv.value_id=sc.type_of_entity and sdv.code='''+ @cpty_cat_id +'''' +
			case when   @calc_reconciled='y' then '' else
			' left join #used_source_deal_header_id tmp on tmp.source_deal_header_id=sdh.source_deal_header_id
			where tmp.source_deal_header_id is null ' end + 
			' GROUP BY sdp.source_deal_header_id,sdh.deal_date,deal_id,source_system_book_id4'
		exec(@pnl1)
		set @pnl2='
			insert into #pnl2
			SELECT sdp.source_deal_header_id,sdh.deal_date,deal_id,source_system_book_id4, round(-1*sum(und_pnl),' + @rounding + ') und_pnl FROM source_deal_pnl sdp INNER join
			source_deal_header sdh ON sdh.source_deal_header_id=sdp.source_deal_header_id AND structured_deal_id IS null
			AND pnl_as_of_date=''' + cast(@as_of_date as varchar) +''' AND deal_date <= ''' + cast(@as_of_date as varchar) + '''
			inner join source_counterparty sc  
			on sc.source_counterparty_id=sdh.counterparty_id and sc.int_ext_flag=''i'' 
			inner join static_data_value sdv on sdv.value_id=sc.type_of_entity and sdv.code='''+ @cpty_cat_id +'''' +
			case when   @calc_reconciled='y' then '' else
			' left join #used_source_deal_header_id tmp on tmp.source_deal_header_id=sdh.source_deal_header_id
			where tmp.source_deal_header_id is null ' end + 
		' GROUP BY sdp.source_deal_header_id,sdh.deal_date,deal_id,source_system_book_id4'

		exec(@pnl2)


	set @st='
		insert INTO #tmp
		SELECT sdp1.deal_date,sdp1.source_deal_header_id,sdp1.deal_id,sdp2.deal_date struc_deal_date, sdp2.source_deal_header_id struc_source_deal_header_id 
			FROM #pnl1 sdp1 
		INNER JOIN #pnl2 sdp2
		ON round(sdp1.und_pnl,' + @rounding + ')=round(sdp2.und_pnl,' + @rounding + ') AND sdp1.source_deal_header_id<>sdp2.source_deal_header_id AND sdp1.source_system_book_id4=sdp2.source_system_book_id4
		ORDER BY sdp1.deal_date,sdp1.source_deal_header_id,sdp2.deal_date,sdp2.source_deal_header_id
		'
	exec(@st)
		EXEC spa_print 'end insert #tmp time:'--+cast(getdate() as varchar)
		EXEC spa_print '**********************************************************************************'
	end


-- end process update structured_deal_id in source_deal_header
--*********************************************************************************

EXEC spa_print '****************start reconciled previous************'

--****************************************************************************************

---------------start reconciled Previous
create table #tmp_match (
source_deal_header_id int,
deal_id varchar(50) COLLATE DATABASE_DEFAULT,
source_system_book_id4 int,
structured_deal_id varchar(50) COLLATE DATABASE_DEFAULT,
und_pnl float
)

set @st='
	insert  INTO #tmp_match 
	SELECT sdh.source_deal_header_id,sdh.deal_id,sdh.source_system_book_id4,
	structured_deal_id,round(sum(und_pnl),' + @rounding + ') und_pnl 
	FROM source_deal_pnl sdp INNER join
	source_deal_header sdh ON sdh.source_deal_header_id=sdp.source_deal_header_id 
	AND structured_deal_id IS NOT NULL AND pnl_as_of_date=''' + cast(@as_of_date as varchar) + ''' AND deal_date <= ''' + cast(@as_of_date as varchar) + '''
	inner join source_counterparty sc  
	on sc.source_counterparty_id=sdh.counterparty_id and sc.int_ext_flag=''i'' 
	inner join static_data_value sdv on sdv.value_id=sc.type_of_entity and sdv.code= ''' + @cpty_cat_id + '''
	left join #used_source_deal_header_id tmp on tmp.source_deal_header_id=sdh.source_deal_header_id
	where tmp.source_deal_header_id is null
	GROUP BY sdh.deal_date,sdh.source_deal_header_id,deal_id,structured_deal_id,sdh.source_system_book_id4
'
exec(@st)
set @st='
	INSERT INTO #final_source_deal_header_id (cat_order,sub_cat_order,source_deal_header_id ,struc_deal_header_id )
	select min(1),min(2),min(id1) id1,max(id2) id2 from (
	select *,
	case when id1<id2 then cast(id1 as varchar) + ''_'' + cast(id2 as varchar)		
		else cast(id2 as varchar) + ''_'' + cast(id1 as varchar)
	end grp from (
		SELECT a.source_deal_header_id id1,b.source_deal_header_id id2
		from #tmp_match a left join #tmp_match b on a.deal_id=b.structured_deal_id
		WHERE round(A.und_pnl,' + @rounding + ')+round(isnull(b.und_pnl,0),' + @rounding + ') =0 
			and a.source_system_book_id4=b.source_system_book_id4
	) aa
	) bbb
	group by grp
'
exec(@st)
set @st='
	INSERT INTO #used_source_deal_header_id (source_deal_header_id) 
	SELECT a.source_deal_header_id
	from #tmp_match a left join #tmp_match b on a.deal_id=b.structured_deal_id
		WHERE round(A.und_pnl,' + @rounding + ')+round(isnull(b.und_pnl,0),' + @rounding + ') =0
		and a.source_system_book_id4=b.source_system_book_id4
'
exec(@st)

-----------------------------------------------------------------------------------------------------
----------------------scope mismatch but reconcile pnl
set @st='
	INSERT INTO #final_source_deal_header_id (cat_order,sub_cat_order,source_deal_header_id ,struc_deal_header_id )
	select min(2),min(5),min(id1) id1,max(id2) id2 from (
	select *,
	case when id1<id2 then cast(id1 as varchar) + ''_'' + cast(id2 as varchar)		
		else cast(id2 as varchar) + ''_'' + cast(id1 as varchar)
	end grp from (
		SELECT a.source_deal_header_id id1,b.source_deal_header_id id2
		from #tmp_match a left join #tmp_match b on a.deal_id=b.structured_deal_id
		WHERE round(A.und_pnl,' + @rounding + ')+round(isnull(b.und_pnl,0),' + @rounding + ') =0 
			and a.source_system_book_id4<>b.source_system_book_id4
	) aa
	) bbb
	group by grp
'
exec(@st)
set @st='
	INSERT INTO #used_source_deal_header_id (source_deal_header_id) 
	SELECT a.source_deal_header_id
	from #tmp_match a left join #tmp_match b on a.deal_id=b.structured_deal_id
		WHERE round(A.und_pnl,' + @rounding + ')+round(isnull(b.und_pnl,0),' + @rounding + ') =0
		and a.source_system_book_id4<>b.source_system_book_id4
'
exec(@st)


-------------------------------end scope mismatch but reconcile pnl-------------------- 
--------------------------------------------------------------------------------------------------------




EXEC spa_print '****************end reconciled************'

---**************************************************************************************
---------------end reconciled

--delete #used_source_deal_header_id
EXEC spa_print '****************start book_id4 not match list (Scope mismatch)************'

--**************************************************************************************
--Start book_id4 not match list (Scope mismatch)
	create table #pnl1_no_b4 (
	source_deal_header_id int,
	deal_date datetime,
	deal_id varchar(50) COLLATE DATABASE_DEFAULT,
	source_system_book_id4 int, 
	und_pnl float )

	create table #pnl2_no_b4 (
	source_deal_header_id int,
	deal_date datetime,
	deal_id varchar(50) COLLATE DATABASE_DEFAULT,
	source_system_book_id4 int, 
	und_pnl float )


	set @st='
			insert into #pnl1_no_b4
			SELECT sdp.source_deal_header_id,sdh.deal_date,deal_id,source_system_book_id4, round(sum(und_pnl),' + @rounding + ') und_pnl FROM source_deal_pnl sdp INNER join
			source_deal_header sdh ON sdh.source_deal_header_id=sdp.source_deal_header_id AND structured_deal_id IS NULL
			AND pnl_as_of_date=''' + cast(@as_of_date as varchar) + ''' AND deal_date <= ''' + cast(@as_of_date as varchar) + '''
			inner join source_counterparty sc  
			on sc.source_counterparty_id=sdh.counterparty_id and sc.int_ext_flag=''i'' 
			inner join static_data_value sdv on sdv.value_id=sc.type_of_entity and sdv.code= ''' + @cpty_cat_id + '''
			left join #used_source_deal_header_id tt on sdh.source_deal_header_id=tt.source_deal_header_id
			where tt.source_deal_header_id is null
			GROUP BY sdp.source_deal_header_id,sdh.deal_date,deal_id,source_system_book_id4
	'
	exec(@st)
	set @st='
		insert into #pnl2_no_b4
		SELECT sdp.source_deal_header_id,sdh.deal_date,deal_id,source_system_book_id4, round(-1*sum(und_pnl),' + @rounding + ') und_pnl FROM source_deal_pnl sdp INNER join
		source_deal_header sdh ON sdh.source_deal_header_id=sdp.source_deal_header_id AND structured_deal_id IS null
		AND pnl_as_of_date=''' + cast(@as_of_date as varchar) + ''' AND deal_date <= ''' + cast(@as_of_date as varchar) + '''
		inner join source_counterparty sc  
		on sc.source_counterparty_id=sdh.counterparty_id and sc.int_ext_flag=''i'' 
		inner join static_data_value sdv on sdv.value_id=sc.type_of_entity and sdv.code= ''' + @cpty_cat_id + '''
		left join #used_source_deal_header_id tt on sdh.source_deal_header_id=tt.source_deal_header_id
		where tt.source_deal_header_id is null
		GROUP BY sdp.source_deal_header_id,sdh.deal_date,deal_id,source_system_book_id4
	'
	exec(@st)

		create index inx_#pnl1_no_b4_aaa on #pnl1_no_b4 (source_deal_header_id,und_pnl,source_system_book_id4)
		create index inx_#pnl1_no_b4_date on #pnl1_no_b4 (deal_date)
		create index inx_#pnl2_no_b4_aaa on #pnl2_no_b4 (source_deal_header_id,und_pnl,source_system_book_id4)
		create index inx_#pnl2_no_b4_date on #pnl2_no_b4 (deal_date)
	create table #tmp_miss (
	deal_date datetime,source_deal_header_id int,deal_id varchar(50) COLLATE DATABASE_DEFAULT,struc_deal_date datetime,struc_source_deal_header_id int
	)
	set @st='
		insert into #tmp_miss
		SELECT sdp1.deal_date,sdp1.source_deal_header_id,sdp1.deal_id,sdp2.deal_date struc_deal_date,
			 sdp2.source_deal_header_id struc_source_deal_header_id 
		FROM #pnl1_no_b4 sdp1 INNER JOIN #pnl2_no_b4 sdp2
		ON sdp1.source_deal_header_id<>sdp2.source_deal_header_id 
		AND round(sdp1.und_pnl,' + @rounding + ')=round(sdp2.und_pnl,' + @rounding + ') AND  sdp1.source_system_book_id4<>sdp2.source_system_book_id4
		ORDER BY sdp1.deal_date,sdp1.source_deal_header_id,sdp2.deal_date,sdp2.source_deal_header_id
	'
	exec(@st)

	DECLARE perfect_match CURSOR FOR 
	SELECT source_deal_header_id,struc_source_deal_header_id FROM #tmp_miss

	OPEN perfect_match
	FETCH NEXT FROM perfect_match INTO @source_deal_header_id,@struc_source_deal_header_id
	WHILE @@FETCH_STATUS = 0
	BEGIN
		if not exists(select * from #used_source_deal_header_id where source_deal_header_id=@source_deal_header_id OR source_deal_header_id=@struc_source_deal_header_id)
		begin
			INSERT INTO #final_source_deal_header_id (cat_order,sub_cat_order,source_deal_header_id ,struc_deal_header_id )
						VALUES (2,null,@source_deal_header_id,@struc_source_deal_header_id)
			INSERT INTO #used_source_deal_header_id (source_deal_header_id) VALUES (@struc_source_deal_header_id)
			INSERT INTO #used_source_deal_header_id (source_deal_header_id) VALUES (@source_deal_header_id)
		end
	FETCH NEXT FROM perfect_match INTO @source_deal_header_id,@struc_source_deal_header_id
	END
	CLOSE perfect_match
	DEALLOCATE perfect_match
--end book_id4 not match list (Scope mismatch)
EXEC spa_print '****************end book_id4 not match list (Scope mismatch)************'

--****************************************************************************************




----***********************************************************************

-------------------start Unreconciled
EXEC spa_print '****************start Unreconciled************'
create table #tmp_unmatch (
source_deal_header_id int,
deal_id varchar(50) COLLATE DATABASE_DEFAULT,
source_system_book_id4 int,
structured_deal_id  varchar(50) COLLATE DATABASE_DEFAULT,
und_pnl float
)

set @st='
	insert INTO #tmp_unmatch
	SELECT sdh.source_deal_header_id,sdh.deal_id,sdh.source_system_book_id4,structured_deal_id,round(sum(und_pnl),' + @rounding + ') und_pnl  
	FROM source_deal_pnl sdp INNER join
	source_deal_header sdh ON sdh.source_deal_header_id=sdp.source_deal_header_id AND structured_deal_id IS NOT NULL
	AND pnl_as_of_date=''' + cast(@as_of_date as varchar) + ''' AND deal_date <= ''' + cast(@as_of_date as varchar) + '''
	inner join source_counterparty sc  
	on sc.source_counterparty_id=sdh.counterparty_id and sc.int_ext_flag=''i'' 
	inner join static_data_value sdv on sdv.value_id=sc.type_of_entity and sdv.code= ''' + @cpty_cat_id + '''
	left join #used_source_deal_header_id tmp on tmp.source_deal_header_id=sdh.source_deal_header_id
	where tmp.source_deal_header_id is null
	GROUP BY sdh.deal_date,sdh.source_deal_header_id,deal_id,structured_deal_id,sdh.source_system_book_id4
'
exec(@st)

set @st='
	INSERT INTO #final_source_deal_header_id (cat_order,sub_cat_order,source_deal_header_id ,struc_deal_header_id )
	select min(3),min(3),min(id1) id1,max(id2) id2 from (
	select *,
	case when id1<id2 then cast(id1 as varchar) + ''_'' + cast(id2 as varchar)		
		else cast(id2 as varchar) + ''_'' + cast(id1 as varchar)
	end grp from (
		SELECT a.source_deal_header_id id1,b.source_deal_header_id id2
		from #tmp_unmatch a left join #tmp_unmatch b on a.deal_id=b.structured_deal_id
		WHERE round(a.und_pnl,' + @rounding + ')+round(isnull(b.und_pnl,0),' + @rounding + ') <>0 
	) aa
	) bbb
	group by grp
'
exec(@st)
set @st='
	INSERT INTO #used_source_deal_header_id (source_deal_header_id)
	SELECT a.source_deal_header_id
	from #tmp_unmatch a left join #tmp_unmatch b on a.deal_id=b.structured_deal_id
		WHERE round(a.und_pnl,' + @rounding + ')+round(isnull(b.und_pnl,0),' + @rounding + ') <>0
'
exec(@st)


	create index indx_used_source_deal_header_id on #used_source_deal_header_id (source_deal_header_id )

	INSERT INTO #final_source_deal_header_id (cat_order,sub_cat_order,source_deal_header_id ,struc_deal_header_id )
	select distinct 3,4,sdh.source_deal_header_id,null from source_deal_header sdh 
	inner join source_counterparty sc  
	on sc.source_counterparty_id=sdh.counterparty_id and sc.int_ext_flag='i' and sdh.structured_deal_id is null
	inner join static_data_value sdv on sdv.value_id=sc.type_of_entity and sdv.code= @cpty_cat_id
	left join #used_source_deal_header_id tmp
	on sdh.source_deal_header_id=tmp.source_deal_header_id and sdh.deal_date<=@as_of_date 
	where tmp.source_deal_header_id is null

----***********************************************************************

-------------------end Unreconciled


	create index indx_source_deal_header_id on #final_source_deal_header_id (source_deal_header_id )
	create index indx_struc_deal_header_id on #final_source_deal_header_id (struc_deal_header_id )
	set @st='
	SELECT case tmp.cat_order
			when 1 then ''Reconciled''
			when 2 then ''Scope Mismatch''
			when 3 then ''Unreconciled''
		end Status_Cat,
		case tmp.sub_cat_order
			when 1 then ''Current''
			when 2 then ''Previous''
			when 3 then ''MTM''
			when 4 then ''Not Found''
			when 5 then ''Reconciled''
		end Status_Sub_Cat,
	sv.code Counterparty_cat,sdh.source_deal_header_id ,sdh.deal_id ,sdh.deal_date,round(sdp.und_pnl,' + @rounding + ') MTM,
	sb1.source_book_name tag1,sb2.source_book_name tag2
	,sb3.source_book_name tag3,sb4.source_book_name tag4,st.trader_name,sc.counterparty_name,
	sdh1.source_deal_header_id source_deal_header_id1,sdh1.deal_id deal_id1,sdh1.deal_date deal_date1,
	round(sdp1.und_pnl,' + @rounding + ') MTM1,sb1a.source_book_name tag1a,sb2a.source_book_name tag2a
	,sb3a.source_book_name tag3a,sb4a.source_book_name tag4a,
	st1.trader_name trader_name1,sc1.counterparty_name counterparty_name1,
	isnull(round(sdp.und_pnl,' + @rounding + '),0)+isnull(round(sdp1.und_pnl,' + @rounding + '),0) Net_pnl
--insert into adiha_process.dbo.aaa2
	FROM #final_source_deal_header_id tmp 
	INNER JOIN source_deal_header sdh ON tmp.source_deal_header_id=sdh.source_deal_header_id
	INNER JOIN source_book sb1 ON sb1.source_book_id=sdh.source_system_book_id1
	INNER JOIN source_book sb2 ON sb2.source_book_id=sdh.source_system_book_id2
	INNER JOIN source_book sb3 ON sb3.source_book_id=sdh.source_system_book_id3 
	INNER JOIN source_book sb4 ON sb4.source_book_id=sdh.source_system_book_id4 
	INNER JOIN source_traders st ON sdh.trader_id = st.source_trader_id
	INNER JOIN source_counterparty sc ON sdh.counterparty_id = sc.source_counterparty_id
	left JOIN (
		select source_deal_header_id,round(sum(und_pnl),' + @rounding + ') und_pnl from source_deal_pnl 
		where pnl_as_of_date=''' + cast(@as_of_date as varchar) + '''  
		group by source_deal_header_id
	)
	sdp ON tmp.source_deal_header_id=sdp.source_deal_header_id

	left JOIN source_deal_header sdh1 ON tmp.struc_deal_header_id=sdh1.source_deal_header_id
	left JOIN (
		select source_deal_header_id,round(sum(und_pnl),' + @rounding + ') und_pnl from source_deal_pnl 
		where pnl_as_of_date=''' + cast(@as_of_date as varchar) + '''  group by source_deal_header_id
	)
	sdp1 ON tmp.struc_deal_header_id=sdp1.source_deal_header_id
	left JOIN source_book sb1a ON sb1a.source_book_id=sdh1.source_system_book_id1 
	left JOIN source_book sb2a ON sb2a.source_book_id=sdh1.source_system_book_id2 
	left JOIN source_book sb3a ON sb3a.source_book_id=sdh1.source_system_book_id3 
	left JOIN source_book sb4a ON sb4a.source_book_id=sdh1.source_system_book_id4 
	left JOIN source_traders st1 ON sdh1.trader_id = st1.source_trader_id
	left JOIN source_counterparty sc1 ON sdh1.counterparty_id = sc1.source_counterparty_id
	LEFT JOIN static_data_value sv ON sv.value_id=sc.type_of_entity  AND sv.type_id=10020
	LEFT JOIN source_system_book_map ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
		AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
		AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
		AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
	 LEFT JOIN portfolio_hierarchy book ON ssbm.fas_book_id = book.entity_id
	 LEFT JOIN portfolio_hierarchy stra ON stra.entity_id = book.parent_entity_id
	 WHERE (''' + @sub_id + ''' = ''NULL'' OR stra.parent_entity_id IN (' + @sub_id + ') OR ssbm.book_deal_type_map_id IS NULL)
		AND (''' + @stra_id + ''' = ''NULL'' OR stra.entity_id IN (' + @stra_id + ') OR ssbm.book_deal_type_map_id IS NULL)
		AND (''' + @book_id + ''' = ''NULL'' OR book.entity_id IN (' + @book_id + ') OR ssbm.book_deal_type_map_id IS NULL)
--	where tmp.sub_cat_order=5
	ORDER BY tmp.cat_order,sv.code,sdh.source_deal_header_id
'
exec(@st)

--SELECT * FROM #final_source_deal_header_id
--select cat_order,sub_cat_order,count(*) no_rec 
--from #final_source_deal_header_id 
--group by cat_order,sub_cat_order

/*

select count(*) cnt from source_deal_header
where 
--deal_date<='2008-03-31'  and
 structured_deal_id is not null
52849

select count(*) from (
select distinct source_deal_header_id from #final_source_deal_header_id
) aa




*/



GO
