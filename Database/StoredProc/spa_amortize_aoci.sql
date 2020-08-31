IF OBJECT_ID(N'spa_amortize_aoci', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_amortize_aoci]
 GO 


-- exec spa_amortize_aoci 's', null, NULL, 'f', '300000', '4', '2010-07-11'

CREATE PROCEDURE [dbo].[spa_amortize_aoci] 	@flag varchar(1), --p for prior processed, s for select for amortize, r for refresh, t for select in table, d for delete, u for amortize
					@fas_strategy varchar(MAX) = null,
					@fas_book_id varchar(MAX) = null,
					@sort_order varchar(1) = null,
					@volume_reclassify float = null,
					@volume_uom int = null,
					@reclassify_date varchar(20) = NULL,
					@seq_id int=NULL,
					@process_id varchar(100) = NULL

AS

-----------------TEST CRITERIA -------
/*
drop table #books
drop table #t_sel
drop table #t_select

DECLARE @flag varchar(1)
DECLARE @reclassify_date varchar(20)
DECLARE @fas_strategy varchar(100)
DECLARE @fas_book_id varchar(100)
DECLARE @process_id varchar(100)
DECLARE @seq_id int
DECLARE @volume_reclassify float
DECLARE @volume_uom int
DECLARE @sort_order varchar(1)

set @flag = 's' --'s' --'t' --'p'
set @reclassify_date = '2006-06-01'
set @process_id = '63E0A055_1BA4_4BA2_8BE5_CA7EB9831B3C' 
set @seq_id = 2
set @volume_reclassify = 10000
set @volume_uom = 3
set @sort_order = 'f'
if @flag in ('p', 's')
	drop table adiha_process.dbo.tmp_amortize_sa_63E0A055_1BA4_4BA2_8BE5_CA7EB9831B3C
	
drop table 	adiha_process.dbo.tmp_amortize_farrms_admin_63E0A055_1BA4_4BA2_8BE5_CA7EB9831B3C
	
	
	
--*/		
	
----------------------------END OF TEST -----------------------
SET NOCOUNT ON
DECLARE @as_of_date DATETIME
Select @as_of_date =  max(as_of_date) from measurement_run_dates where as_of_date <=isnull(@reclassify_date,GETDATE())

If @flag = 's'
BEGIN

	If (@volume_reclassify IS NULL OR @volume_uom IS NULL) 
	BEGIN
		Exec spa_ErrorHandler 1, 'Amortize AOCI', 
					'spa_amortize_aoci', 'Input Error', 
					'Both volume and volume units of measures should be provided', ''
		RETURN
	END
END

DECLARE @Sql_Select VARCHAR(8000)        
DECLARE @process_table varchar(128),@msg VARCHAR(1000)


--create process tables always
IF @process_id IS NULL
BEGIN
	SET @process_id = REPLACE(newid(),'-','_')
END

SET @process_table = dbo.FNAProcessTableName('tmp_amortize', dbo.FNADBUser(), @process_id)

--select * from adiha_process.dbo.tmp_amortize_sa_63E0A055_1BA4_4BA2_8BE5_CA7EB9831B3C
--Delete from amortization table
if @flag='r'
begin
	SET @Sql_Select = '
	SELECT	[seq_id], process_id, error_desc, DBO.FNADateFormat([AsOfDate]) [As Of Date], RelID [Rel ID], DealID [Deal ID],
			DBO.FNADateFormat([ConMonth]) [Con Month], [AOCI], [AOCI Amortized], [Volume],
			[Volume Amortized], PercAmortized [Perc Amortized], FullyAmortized [Fully Amortized], UpdateBy [Update By],
			DBO.FNADateFormat([UpdateTS]) [UpdateTS], [selected] FROM ' + @process_table 
	+ ' ORDER BY seq_id '
	--print (@Sql_Select) 
	exec (@Sql_Select) 
	return
end

if @flag = 'd'
begin

	SET @Sql_Select = 
	'update inventory_reclassify_aoci set fully_released = ''n'' 
	FROM inventory_reclassify_aoci ica INNER JOIN
	(select distinct RelID link_id from ' + @process_table + '
	where seq_id = ' + cast(@seq_id as varchar) + ' and FullyAmortized = ''y'') pt ON pt.link_id = ica.link_id
	'
	exec(@Sql_Select)

	SET @Sql_Select = 
	'delete inventory_reclassify_aoci 
	from inventory_reclassify_aoci  ira inner join
	' + @process_table + ' pt ON 
	pt.RelID = ira.link_id AND pt.AsOfDate = ira.reclassify_date AND 
	pt.DealID = ira.source_deal_header_id AND pt.ConMonth = ira.term_start AND
	pt.seq_id = ' + cast(@seq_id as varchar)
	
	exec(@Sql_Select)

	SET @Sql_Select = 
	'delete from ' + @process_table + ' where seq_id = ' + cast(@seq_id as varchar)
	exec(@Sql_Select)
	IF @@Error <> 0
	BEGIN
		EXEC spa_ErrorHandler -1
		, 'Amortize AOCI'
		, 'spa_amortize_aoci'
		, 'DB Error'
		, 'Failed to delete the data.'
		, ''
		RETURN
	END			
	ELSE
	BEGIN
		EXEC spa_ErrorHandler 0
		, 'Amortize AOCI'
		, 'spa_amortize_aoci'
		, 'Success'
		, 'Data deleted successfully .'
		, ''
		RETURN
	END		

end
----Amortize selected records
if @flag = 'u'
begin
	set @Sql_Select = '
	insert into inventory_reclassify_aoci
	select AsOfDate reclassify_date, RelID link_id, DealID source_deal_header_id, ConMonth term_start,
		AOCI total_aoci_value, [AOCI Amortized] relass_aoci_value, FullyAmortized fully_released,
		Volume total_volume, [Volume Amortized] volume_released, dbo.FNADBUser() create_user, getdate() create_ts
	from ' + @process_table

	exec(@Sql_Select)

	set @Sql_Select = 'delete from ' + @process_table
	exec(@Sql_Select)

	IF @@Error <> 0
	BEGIN
		EXEC spa_ErrorHandler -1
		, 'Amortize AOCI'
		, 'spa_amortize_aoci'
		, 'DB Error'
		, 'Failed to amortized.'
		, ''
		RETURN
	END			
	ELSE
	BEGIN
		EXEC spa_ErrorHandler 0
		, 'Amortize AOCI'
		, 'spa_amortize_aoci'
		, 'Success'
		, 'Successfully amortized.'
		, ''
		RETURN
	END		
end 


--CREATE TABLE
SET @Sql_Select = 
'CREATE TABLE ' + @process_table + '(
	[seq_id] int IDENTITY,
	process_id varchar(100),
	error_desc varchar(500),
	[AsOfDate] datetime,
	[RelID] int,
	[DealID] varchar(50),
	[ConMonth] datetime,
	[AOCI] float,
	[AOCI Amortized] float,
	[Volume] float,
	[Volume Amortized] float,
	[PercAmortized] float,
	[FullyAmortized] varchar(5),
	[UpdateBy] varchar(50),
	[UpdateTS] datetime,
	[selected] int
	)
'

if @flag = 's' OR @flag = 'p' OR @flag = 'g'
	exec (@Sql_Select)

CREATE TABLE #books (fas_book_id int) 

SET @Sql_Select=        
'INSERT INTO  #books
SELECT distinct book.entity_id fas_book_id FROM portfolio_hierarchy book (nolock) INNER JOIN
		Portfolio_hierarchy stra (nolock) ON book.parent_entity_id = stra.entity_id LEFT OUTER JOIN            
		source_system_book_map ssbm ON ssbm.fas_book_id = book.entity_id         
WHERE (fas_deal_type_value_id IS NULL OR fas_deal_type_value_id BETWEEN 400 AND 401) 
'   
+               
CASE WHEN (@fas_strategy IS NULL) THEN '' ELSE ' AND stra.entity_id IN  ( ' + @fas_strategy + ') ' END
+               
CASE WHEN (@fas_book_id IS NULL) THEN '' ELSE ' AND (book.entity_id IN(' + @fas_book_id + ')) ' END
                 
--print @Sql_Select
EXEC (@Sql_Select)


--Select records for delete or amortize
If @flag = 't'
begin
	create table #t_sel(DealID int, ConMonth datetime)
	set @Sql_Select = 
		'insert into #t_sel 
		select DealID, ConMonth from ' + @process_table + ' where seq_id = ' + cast(@seq_id as varchar)
	exec (@Sql_Select)

	set @Sql_Select = 
	'UPDATE  ' + @process_table + ' set selected = case when (selected = 1) then 0 else 1 end 
	FROM ' + @process_table + ' pt INNER JOIN 
		#t_sel t ON t.DealID = pt.DealID AND t.ConMonth = pt.ConMonth'
	exec (@Sql_Select)
end

--retrieve prior processed values
If @flag = 'p' OR @flag = 'g'
begin

	SET @Sql_Select = '
	INSERT INTO ' + @process_table + '
	select ''' + @process_id + ''' process_id,
	NULL error_desc,
	ira.reclassify_date [AsOfDate],
	ira.link_id [RelID],
	ira.source_deal_header_id [DealID],
	ira.term_start [ConMonth],
	round(ira.total_aoci_value, 2) [AOCI],
	round(ira.reclass_aoci_value, 2) [AOCI Amortized],
	round(ira.total_volume, 4) [Volume],
	round(ira.volume_released, 4) [Volume Amortized],
	round((ira.volume_released/nullif(ira.total_volume, 0)), 2) * 100 [PercAmortized],
	case when (fully_released = ''y'') then ''Yes'' else ''No'' end [FullyAmortized],
	ira.create_user [UpdateBy],
	ira.create_ts [UpdateTS],
	0 [selected]
	from fas_link_header flh inner join
	#books bk on bk.fas_book_id = flh.fas_book_id inner join
	inventory_reclassify_aoci ira on ira.link_id = flh.link_id 
	where reclassify_date <= ''' + @reclassify_date + '''
	order by reclassify_date, term_start, source_deal_header_id
	'
--	EXEC spa_print @Sql_Select
	EXEC (@Sql_Select)

end

-- selected values for amortization
If @flag = 's' or @flag = 'v'
begin

	create table #t_select
	(
	seq_id int identity, link_id int, source_deal_header_id int, as_of_date datetime, h_term datetime, total_pnl float,
	u_total_aoci float, aoci_reclassified float, deal_volume float, volume_amortized_perc float, volume_left float, 
	volume_left_after FLOAT,uom_id int
	)

	set @Sql_Select = '
	insert into #t_select (link_id,source_deal_header_id,as_of_date,h_term,total_pnl,u_total_aoci, aoci_reclassified,deal_volume,volume_amortized_perc,volume_left,volume_left_after,uom_id )
	select car.link_id, car.source_deal_header_id, car.as_of_date, car.h_term, 
	round(max(cd.und_pnl), 2) total_pnl,
	round(max(car.u_aoci), 2) u_total_aoci, 
	round(sum(isnull(amortized_aoci.aoci_reclassified, 0)), 2) aoci_reclassified,
	round(max(cd.deal_volume* 
	case when cd.deal_volume_uom_id='+cast(@volume_uom as varchar)+' then 1 
	else 
		isnull(conv1.conversion_factor,cast(1 as float)/conv2.conversion_factor)
	end) , 4) deal_volume,
	round(sum(isnull(amortized_aoci.aoci_reclassified, 0))/max(car.u_aoci), 2) volume_amortized_perc,
	round((1 - (isnull(sum(isnull(amortized_aoci.aoci_reclassified, 0)), 0)/max(car.u_aoci))) * max(cd.deal_volume *
	case when cd.deal_volume_uom_id='+cast(@volume_uom as varchar)+' then 1 
	else 
		isnull(conv1.conversion_factor,cast(1 as float)/conv2.conversion_factor)
	end), 0) volume_left,
	round((1 - (isnull(sum(isnull(amortized_aoci.aoci_reclassified, 0)), 0)/max(car.u_aoci))) * max(cd.deal_volume *
	case when cd.deal_volume_uom_id='+cast(@volume_uom as varchar)+' then 1 
	else 
		isnull(conv1.conversion_factor,cast(1 as float)/conv2.conversion_factor)
	end), 0) volume_left_after,
	max(cd.deal_volume_uom_id) uom_id
	from fas_link_header flh inner join
	#books bk on bk.fas_book_id = flh.fas_book_id inner join
	(
	select car.link_id, max(i_term) i_term, max(as_of_date) max_as_of_date FROM 
	' +dbo.FNAGetProcessTableName(@as_of_date,'calcprocess_aoci_release') + ' car 
	where car.oci_rollout_approach_value_id = 502 and
				as_of_date < dateadd(m, 1, i_term)
	group by car.link_id
	) mdate ON mdate.link_id = flh.link_id INNER JOIN ' +dbo.FNAGetProcessTableName(@as_of_date,'calcprocess_aoci_release') + ' car
		ON mdate.max_as_of_date = car.as_of_date and mdate.link_id = car.link_id INNER JOIN 
	source_deal_detail sdd on sdd.source_deal_header_id = car.source_deal_header_id and sdd.term_start = car.h_term and sdd.leg = 1
	LEFT OUTER JOIN -- do not include all amortized links
	(
	select link_id, source_deal_header_id, term_start
	from inventory_reclassify_aoci 
	where fully_released = ''y''
	group by link_id, source_deal_header_id, term_start
	) fully_amortized on fully_amortized.link_id = car.link_id and
		fully_amortized.source_deal_header_id = car.source_deal_header_id and
		fully_amortized.term_start= car.h_term
	LEFT OUTER JOIN --remove amortized aoci
	(
	select link_id, source_deal_header_id, term_start, sum(reclass_aoci_value) aoci_reclassified, max(fully_released) fully_released
	from inventory_reclassify_aoci 
	group by link_id, source_deal_header_id, term_start
	having max(fully_released) <> ''y''
	) amortized_aoci
	on amortized_aoci.link_id = car.link_id and
		amortized_aoci.source_deal_header_id = car.source_deal_header_id and
		amortized_aoci.term_start= car.h_term
	LEFT OUTER JOIN ' +dbo.FNAGetProcessTableName(@as_of_date,'calcprocess_deals') + ' cd ON cd.link_id = mdate.link_id and cd.as_of_date = mdate.max_as_of_date 
		and cd.source_deal_header_id = sdd.source_deal_header_id and cd.term_start = sdd.term_start
		
		

	LEFT OUTER JOIN rec_volume_unit_conversion conv1 on
	 conv1.from_source_uom_id  = cd.deal_volume_uom_id 
	 AND conv1.to_source_uom_id ='+ cast(@volume_uom as varchar) +'
	LEFT OUTER JOIN rec_volume_unit_conversion conv2 on
	 conv2.from_source_uom_id  ='+cast(@volume_uom as varchar) +'
	 AND conv2.to_source_uom_id = cd.deal_volume_uom_id 
		
		
	where car.i_term < ''' + @reclassify_date   + ''' and fully_amortized.link_id is null

	group by car.link_id, car.source_deal_header_id, car.as_of_date, car.h_term
	having round((1 - (isnull(sum(isnull(amortized_aoci.aoci_reclassified, 0)), 0)/max(car.u_aoci))) * max(cd.deal_volume), 0) > 0 
	order by ' + case when (@sort_order = 'l') then ' car.h_term desc ' else ' car.h_term asc ' end + ', car.source_deal_header_id
	'
	--print @sql_Select
	exec (@sql_Select)

	If exists(SELECT 1 FROM #t_select WHERE deal_volume IS NULL ) 
	BEGIN
		select @msg='Volume conversion factor from '+ su_from.uom_name +' to ' + su_to.uom_name + ' not found. Please define before proceeding.'
			FROM (SELECT TOP(1) uom_id from_uom_id,@volume_uom to_uom_id from #t_select WHERE deal_volume IS NULL) t 
			INNER JOIN source_uom su_from ON t.from_uom_id=su_from.source_uom_id
			INNER JOIN source_uom su_to ON t.to_uom_id=su_to.source_uom_id
		
			Exec spa_ErrorHandler -1, 'Amortize AOCI', 'spa_amortize_aoci', 'Missing Conversion Factor',
			 @msg, ''
		RETURN
	END
	if @flag = 'v'
	begin
			Exec spa_ErrorHandler 0, 'Amortize AOCI', 'spa_amortize_aoci', 'Missing Conversion Factor',
			 @msg, ''
			return
	end



	DECLARE @n_seq_id int,
	@n_link_id int, @n_source_deal_header_id int, @n_as_of_date datetime, @n_h_term datetime, 
	@n_total_pnl float, @n_u_total_aoci float, @n_aoci_reclassified float, @n_deal_volume float, @n_volume_amortized_perc float,
	@n_volume_left float, @n_volume_left_after float
	
	DECLARE @last_deal_id int, @last_h_term datetime, @volume_assigned_so_far float, @volume_assign_now float
	set @volume_assigned_so_far = 0
	set @volume_assign_now = 0

	--select * from #t_select 

	DECLARE amortized_cursor CURSOR FOR 
	select seq_id,link_id,source_deal_header_id,as_of_date,h_term,total_pnl,u_total_aoci, aoci_reclassified,deal_volume,volume_amortized_perc,volume_left,volume_left_after
	 from #t_select order by seq_id
	OPEN amortized_cursor

	FETCH NEXT FROM amortized_cursor 
	INTO @n_seq_id, @n_link_id, @n_source_deal_header_id, @n_as_of_date, @n_h_term, @n_total_pnl, @n_u_total_aoci, 
	@n_aoci_reclassified, @n_deal_volume, @n_volume_amortized_perc, @n_volume_left, @n_volume_left_after
	
	WHILE @@FETCH_STATUS = 0
	Begin
	
		IF @volume_assigned_so_far < @volume_reclassify
		BEGIN
			If (@last_deal_id IS NULL OR @last_deal_id <> @n_source_deal_header_id OR 
				@last_h_term IS NULL OR @last_h_term <> @n_h_term)
			begin
				if (@volume_assigned_so_far + @n_volume_left) <= @volume_reclassify
					set @volume_assign_now = @n_volume_left
				else
					set @volume_assign_now = @volume_reclassify - @volume_assigned_so_far
				end					

				set @volume_assigned_so_far = @volume_assigned_so_far + @volume_assign_now

			end


			set @sql_Select = 
			'INSERT INTO ' + @process_table + '
			(process_id, error_desc, AsOfDate, RelID, DealID, ConMonth, AOCI, [AOCI Amortized], Volume, [Volume Amortized], 
			PercAmortized, FullyAmortized, UpdateBy, UpdateTS, selected )
			SELECT ''' + @process_id + ''', NULL error_desc, ' + '''' + @reclassify_date + ''', ' + cast(@n_link_id as varchar) + ', ' + cast(@n_source_deal_header_id as varchar) + ',  				
				''' + dbo.FNAGetSQLStandardDate(@n_h_term) + ''', ' + cast(@n_u_total_aoci as varchar) + ', ' + 
				case when (@volume_assign_now = @n_volume_left) then 
					cast(round(@n_u_total_aoci - @n_aoci_reclassified, 2) as varchar)
				else
					cast(round((@volume_assign_now/@n_deal_volume) * @n_u_total_aoci, 2)	as varchar) 
				end+ ', ' +
				cast(@n_deal_volume as varchar) + ', ' + cast(@volume_assign_now as varchar) + ', ' +
				cast(round((@volume_assign_now/@n_deal_volume), 2)	as varchar) + ', ' +
				case when (@n_volume_left = @volume_assign_now) then '''Yes''' else '''No''' end +
				',''' + dbo.FNADBUser() + ''', getdate(), 1'
					
			--print 	@sql_Select 
			exec(@sql_Select)	

		IF @volume_assigned_so_far >= @volume_reclassify
			BREAK

		IF @last_deal_id IS NULL OR (@last_deal_id <> @n_source_deal_header_id OR @last_h_term <> @n_h_term)
		BEGIN
			set @last_deal_id = @n_source_deal_header_id
			set @last_h_term = @n_h_term
		END

		FETCH NEXT FROM amortized_cursor 
		INTO @n_seq_id, @n_link_id, @n_source_deal_header_id, @n_as_of_date, @n_h_term, @n_total_pnl, @n_u_total_aoci, 
		@n_aoci_reclassified, @n_deal_volume, @n_volume_amortized_perc, @n_volume_left, @n_volume_left_after
			
	END

	CLOSE amortized_cursor
	DEALLOCATE  amortized_cursor

	set @sql_Select = 
		' UPDATE ' + @process_table + ' SET FullyAmortized = ''No''
		  FROM ' + @process_table + ' pt INNER JOIN
			(select distinct RelID from ' + @process_table + ' where FullyAmortized = ''no'') nfa ON
			pt.RelID = nfa.RelID 
		'
	exec (@sql_Select)

	--Not enough volume to match
	If (@volume_assigned_so_far + 0.01) < @volume_reclassify
	BEGIN
		set @sql_Select = 
			' UPDATE ' + @process_table + ' SET error_desc = ''' + 
				' Only volume of ' + cast(@volume_assigned_so_far as varchar) + 
				' could be matched for total volume of ' + cast(@volume_reclassify as varchar) + ''''
	
		exec (@sql_Select)
	END

END

--else 
if @flag = 'g'
begin
	SET @Sql_Select = '
		SELECT	 DBO.FNADateFormat([AsOfDate]) [As Of Date], RelID [Rel ID], DealID [Deal ID],
		DBO.FNADateFormat([ConMonth]) [Con Month], [AOCI], [AOCI Amortized], [Volume],
		[Volume Amortized], PercAmortized [Perc Amortized], FullyAmortized [Fully Amortized], UpdateBy [Update By],
		DBO.FNADateTimeFormat([UpdateTS], 1) [Update TS], [Selected] FROM ' + @process_table 
+ ' ORDER BY seq_id '
EXEC (@Sql_Select) 
end


else 
BEGIN
	SET @Sql_Select = '
	SELECT	[seq_id], process_id, error_desc, DBO.FNADateFormat([AsOfDate]) [As Of Date], RelID [Rel ID], DealID [Deal ID],
			DBO.FNADateFormat([ConMonth]) [Con Month], [AOCI], [AOCI Amortized], [Volume],
			[Volume Amortized], PercAmortized [Perc Amortized], FullyAmortized [Fully Amortized], UpdateBy [Update By],
			DBO.FNADateTimeFormat([UpdateTS], 1) [Update TS], [Selected] FROM ' + @process_table 
	+ ' ORDER BY seq_id '
EXEC (@Sql_Select) 
end



