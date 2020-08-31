

/****** Object:  StoredProcedure [dbo].[spa_auto_matching_report]    Script Date: 12/02/2010 21:56:30 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_auto_matching_report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_auto_matching_report]
/****** Object:  StoredProcedure [dbo].[spa_auto_matching_report]    Script Date: 12/02/2010 21:56:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[spa_auto_matching_report] 
	@process_id VARCHAR(50),
	@v_curve_id int =null,
	@h_or_i varchar(1)=null,
	@v_buy_sell varchar(1)=null,
	@user_name varchar(50)='farrms_admin',
	@ref_id VARCHAR(50) = NULL 
AS
/*
declare @process_id VARCHAR(50),
	@v_curve_id int ,
	@h_or_i varchar(1),
	@v_buy_sell varchar(1),
	@user_name varchar(50),
	@ref_id VARCHAR(50) = NULL 
select 	@process_id='68E7C321_AEB4_4DBE_90FC_2D598FF63023', --'EC5C29C2_672C_4277_8169_590D42DC02F2',
	@v_curve_id =null,
	@h_or_i=NULL, --'i',
	@v_buy_sell=null,
	@user_name='farrms_admin'
	
	
	
DROP TABLE #tmp_report_group
DROP TABLE #tmp_report
DROP TABLE #exclude_deals
DROP TABLE #tmp_running_bal
DROP TABLE #used_per
--select *   from adiha_process.dbo.matching_farrms_admin_34107F83_3AB5_4168_B7D4_5FC873AA54A7

--Deal ID	Deal REF ID
--616	PD04001
--619	PH04002




--*/
SET NOCOUNT ON 
declare @ProcessTableName varchar(100)
SET @ProcessTableName = dbo.FNAProcessTableName('matching', @user_name, @process_id)

CREATE TABLE #tmp (
	x INT 	
)
BEGIN TRY
--	EXEC spa_print 'SELECT 1 FROM ' + @ProcessTableName
	
	INSERT INTO #tmp 
	EXEC('SELECT 1 FROM ' + @ProcessTableName + ' WHERE 1=0')
END TRY 
BEGIN CATCH
	DECLARE @err_no INT 
	SET @err_no = ERROR_NUMBER()
	IF @err_no = 208
	BEGIN
		Exec spa_ErrorHandler -1, 'Auto Matching Report', 
			
							'spa_auto_matching_report', 'DB Error', 
			
							'The report no longer exists. The report has been purged by the daily cleanup job.', 'Non Existent Data'
		RETURN 
	END 
END CATCH
declare @sql varchar(max), @sql_stmt varchar(max)
set @sql=''

if @v_curve_id is not null
	set @sql= @sql+' and p.curve_id='+cast(@v_curve_id as varchar)

if isnull(@h_or_i,'b')<>'b'
	set @sql= @sql+' and p.[Type]='''+@h_or_i+''''

IF @ref_id IS NOT NULL 
	SET @sql = @sql + ' and p.[Deal REF ID] like ''%' + @ref_id + '%'''
	
	
--	set @sql= @sql+' and p.match is null and p.[Type]='''+@h_or_i+''''

if isnull(@v_buy_sell,'a')<>'a'
	set @sql= @sql+'  and p.buy_sell='''+@v_buy_sell+''''

--	set @sql= @sql+'  and p.match is null and p.buy_sell='''+@v_buy_sell+''''

create table #tmp_report (
	Rowid int identity(1,1),
	process_Rowid INT,
	Match INT,
	[Hedged Item Product] varchar(200) COLLATE DATABASE_DEFAULT  ,
	[Tenor]	varchar(50) COLLATE DATABASE_DEFAULT  ,
	[Effective Date] DATETIME,
	[Deal Date]	datetime,
	[Type] varchar(1000) COLLATE DATABASE_DEFAULT  ,
	[Deal ID]  int,
	[Deal REF ID]  varchar(500) COLLATE DATABASE_DEFAULT  ,
	[Volume % Avail]  float,
	[Volume Avail] numeric(38,20),
	[Volume matched] float,
	[% Matched] float,
	[UOM] varchar(20) COLLATE DATABASE_DEFAULT  ,
	process_id varchar(100) COLLATE DATABASE_DEFAULT  ,
	[Counterparty] VARCHAR(50) COLLATE DATABASE_DEFAULT  
)

create table #exclude_deals (source_deal_header_id int,create_ts datetime)

insert into #exclude_deals (source_deal_header_id ,create_ts )
select fld.source_deal_header_id,max(dld.create_ts) create_ts 
	from [dedesignated_link_deal]  dld inner join fas_link_detail fld 
		on fld.link_id=dld.link_id where fld.hedge_or_item='i'
group by fld.source_deal_header_id
UNION all
select dld.source_deal_header_id,max(dld.create_ts) create_ts 
	from [dedesignated_link_deal]  dld 
group by dld.source_deal_header_id
UNION all
SELECT isnull(source_deal_header_id1,source_deal_header_id2) source_deal_header_id ,create_ts  FROM exclude_deal_auto_matching WHERE exclude_flag='r'

--updating [Volume Avail]
create table #tmp_running_bal(
[rowid] int ,[deal id] int, [Volume Avail] float
,[Volume matched] float,[Running Volume matched] float,rec int
)

set @sql_stmt='
insert into #tmp_running_bal(
[rowid] ,[deal id], [Volume Avail]
,[Volume matched],[Running Volume matched],rec
)
select p2.[rowid],p2.[deal id], max(p2.[Volume Avail]) [Volume Avail] 
,max(p2.[Volume matched]) [Volume matched],	sum(p1.[Volume matched]) [Running Volume matched],count(*) rec  from '+@ProcessTableName+' p1 
inner join '+@ProcessTableName+' p2 
on p1.[deal id]=p2.[deal id] and p1.[rowid]<=p2.[rowid]
group by p2.[rowid],p2.[deal id] order by p2.[rowid]
'

--print @sql_stmt
exec(@sql_stmt)

--set @sql_stmt='
--UPDATE p  set 
--	[Volume Avail]=p.[Volume Avail]-(r.[Running Volume matched]-r.[Volume matched])
--from '+@ProcessTableName+' p inner join #tmp_running_bal r on r.[rowid]=p.Rowid
--where r.rec>1 --and p.match is not null
--'
--
--print @sql_stmt
--exec(@sql_stmt)

--------------------------------------------------


create table #used_per (source_deal_header_id int,used_percentage FLOAT,link_create_date datetime)
set @sql_stmt='
insert into #used_per (source_deal_header_id,used_percentage,link_create_date)
select source_deal_header_id,sum(percentage_use),max(link_end_date) from (
		select 	dh.source_deal_header_id, null link_end_date,sum(gfld.percentage_included) as  percentage_use,max(''o'') src
		from 	source_deal_header dh 
		INNER JOIN
			gen_fas_link_detail gfld ON gfld.deal_number = dh.source_deal_header_id 
		INNER JOIN
			gen_fas_link_header gflh ON gflh.gen_link_id = gfld.gen_link_id
			 AND gflh.gen_status = ''a''
		INNER JOIN '+@ProcessTableName+' p1 on p1.[Deal ID]=dh.source_deal_header_id
		GROUP BY dh.source_deal_header_id, dh.deal_date
	union all
		select source_deal_header_id,max(fas_link_detail.create_ts) link_create_date 
		,sum(case when convert(varchar(10),fas_link_detail.create_ts,120) >=isnull(fas_link_header.link_end_date,''9999-01-01'') then 0 else percentage_included end) percentage_included,max(''f'') 
		from fas_link_detail 
		INNER JOIN '+@ProcessTableName+' p1 on p1.[Deal ID]=fas_link_detail.source_deal_header_id
		inner join fas_link_header
		on  fas_link_detail.link_id=fas_link_header.link_id group by source_deal_header_id
	union all
		select a.source_deal_header_id ,NULL link_create_date, sum(a.[per_dedesignation]) [per_dedesignation],max(''l'') src from 
		(
			select distinct process_id ,source_deal_header_id ,[per_dedesignation] from [dbo].[dedesignated_link_deal]
		) a group by a.source_deal_header_id

) used_per group by used_per.source_deal_header_id
having sum(percentage_use)>.989'

--PRINT @sql_stmt
EXEC(@sql_stmt)

--delete #used_per where used_percentage<=.999

SET @sql_stmt='
insert into #tmp_report (
	process_Rowid ,Match ,[Hedged Item Product],[Tenor],[Effective Date],[Deal Date],
	[Type],[Deal ID] ,[Deal REF ID] ,[Volume % Avail] ,[Volume Avail] ,[Volume matched] ,
	[% Matched],[UOM],process_id, [Counterparty]
)
select 
	p.Rowid,eff.sno,max(p.[Hedged Item Product]) [Hedged Item Product]
	,max(p.[Tenor]) [Tenor],max(eff.link_effective_date) [Effective Date],max(p.[Deal Date]) [Deal Date]
	,max(case  p.[Type] when ''i'' then ''Item'' when ''h'' then ''Der'' else p.[Type] end ) [Type],
	max(p.[Deal ID]) [Deal ID], max(case when p.[Deal ID] is null then ''Offset_Deal'' else dbo.FNATRMWinHyperlink(''a'', 10131010, p.[Deal REF ID], p.[Deal ID], NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0) 
	end) AS [Deal REF ID]
	, avg(p.[Volume % Avail]) [Volume % Avail],sum(p.[Volume Avail]) [Volume Avail],
	sum(p.[Volume matched]) [Volume matched] ,avg(p.[% Matched]) [% Matched] ,max(p.[UOM]) [UOM],MAX(p.process_id ) process_id
	,max(p.[Counterparty])
from '+@ProcessTableName+' p 
inner join  (
		select  row_number() over(order by Match) sno,   Match,max(link_effective_date) link_effective_date from '+@ProcessTableName+' 
		where Match IS NOT null group by  Match 
	) eff on eff.match=p.Match
left join #exclude_deals d on p.[Deal ID]=d.source_deal_header_id 
left join 
(
	select source_deal_header_id,MAX([create_ts]) [create_ts] from fas_link_detail GROUP BY source_deal_header_id
) fld on p.[Deal ID]=fld.source_deal_header_id 
where d.source_deal_header_id  is null and p.[create_ts]>isnull(d.[create_ts],''1900-01-01'')
 AND p.[create_ts]>isnull(fld.[create_ts],''1900-01-01'') 
and p.Match IS NOT null ' +@sql
+ ' GROUP BY eff.sno ,p.Rowid with ROLLUP
HAVING GROUPING(eff.sno)=0'

--print @sql_stmt
exec(@sql_stmt)
--UPDATE #tmp_report SET 
--Match=null ,
--[Hedged Item Product]=null,
--[Tenor] =null,
--[Effective Date]=null,
--[Deal Date]=null	,
--[Type]=null,
--[Deal ID] =null,
--[Deal REF ID] ='<b>Sub Total:</b>',
--[UOM]=null,
--process_id=null
--WHERE process_Rowid IS NULL

create table #tmp_report_group (
	Rowid int identity(1,1),
	[Hedged Item Product] varchar(200) COLLATE DATABASE_DEFAULT  ,
	[Tenor]	varchar(50) COLLATE DATABASE_DEFAULT  ,
	[Effective Date] DATETIME,no_rec int
)

SET @sql_stmt='
insert into #tmp_report_group (
	[Hedged Item Product],
	[Tenor],
	[Effective Date],no_rec
)
select 
	p.[Hedged Item Product] [Hedged Item Product]
	,p.[Tenor],max(p.link_effective_date) [Effective Date],COUNT(*)
from '+@ProcessTableName+' p left join #exclude_deals d on p.[Deal ID]=d.source_deal_header_id 
left join #used_per fld on fld.source_deal_header_id=p.[Deal ID] 
where d.source_deal_header_id  is null and p.[create_ts]>isnull(d.[create_ts],''1900-01-01'') 
AND p.Match IS null 
--and p.[create_ts]>isnull(fld.[create_ts],''1900-01-01'') 
and fld.source_deal_header_id  is null '
+@sql
+' GROUP BY p.[Hedged Item Product] ,p.[Tenor]'

--print @sql_stmt
exec(@sql_stmt)


SET @sql_stmt='
insert into	#tmp_report (
	process_Rowid ,[Hedged Item Product],[Tenor],[Effective Date],[Deal Date]	,
	[Type],[Deal ID] ,[Deal REF ID] ,[Volume % Avail] ,[Volume Avail] ,
	[Volume matched] ,[% Matched],[UOM],process_id, [Counterparty]
)
select 
	p.Rowid,max(p.[Hedged Item Product]) [Hedged Item Product]
	,max(p.[Tenor]) [Tenor],max(t_grp.[Effective Date]) [Effective Date]
	,max(p.[Deal Date]) [Deal Date]
	,max(case p.[Type] when ''i'' then ''Item'' when ''h'' then ''Der'' when ''offsetting'' then dbo.FNAHyperLinkText7(10233800,''offsetting'',p.Rowid,p.process_id,''auto_match_rpt'') else p.[Type] end ) [Type],
	max(p.[Deal ID]) [Deal ID], max(case when p.[Deal ID] is null then ''Offset_Deal'' else dbo.FNAHyperLink(10131010,p.[Deal REF ID],p.[Deal ID],''-1'') end) AS [Deal REF ID]
	,avg(p.[Volume % Avail]) [Volume % Avail],sum(p.[Volume Avail]) [Volume Avail],
	sum(p.[Volume matched]) [Volume matched] ,avg(p.[% Matched]) [% Matched] ,max(p.[UOM]) [UOM],MAX(p.process_id ) process_id,
	max(sc.[Counterparty_name])
from '+@ProcessTableName+' p
INNER JOIN  #tmp_report_group t_grp ON p.[Hedged Item Product]=t_grp.[Hedged Item Product] AND p.[Tenor]=t_grp.[Tenor]
--AND p.[link_effective_date]=t_grp.[Effective Date] 
AND p.match IS null
left JOIN source_counterparty sc ON sc.counterparty_id = p.counterparty
left join #exclude_deals d on p.[Deal ID]=d.source_deal_header_id 
left join  
#used_per fld on fld.source_deal_header_id=p.[Deal ID] 
where d.source_deal_header_id  is null and  p.[create_ts]>isnull(d.[create_ts],''1900-01-01'') AND p.Match IS null 
--and p.[create_ts]>isnull(fld.[create_ts],''1900-01-01'')
and fld.source_deal_header_id  is null 
' +@sql+'
GROUP BY t_grp.Rowid,p.Rowid with ROLLUP
HAVING GROUPING(t_grp.Rowid)=0'



--print @sql_stmt
exec(@sql_stmt)

UPDATE #tmp_report SET 
	Match=null ,
	[Hedged Item Product]=null,
	[Tenor] =null,
	[Effective Date]=null,
	[Deal Date]=null	,
	[Type]=null,
	[Deal ID] =null,
	[Deal REF ID] ='<b>Sub Total:</b>',
	[UOM]=null,
	process_id=null,
	[Volume % Avail] =null ,
	[% Matched]=NULL,
	[Counterparty] = NULL 
WHERE process_Rowid IS NULL


--set @sql_stmt='
--UPDATE p  set 
--	[Volume Avail]=p.[Volume Avail]-(r.[Running Volume matched]-r.[Volume matched])
--from '+@ProcessTableName+' p inner join #tmp_running_bal r on r.[rowid]=p.Rowid
--where r.rec>1 --and p.match is not null
--'
--
--print @sql_stmt
--exec(@sql_stmt)


--select * from #tmp_running_bal

SELECT @sql_stmt='
SELECT t.process_Rowid rowid1,t.Match ,t.[Hedged Item Product],t.[Tenor],dbo.fnadateformat(t.[Effective Date]) [Effective Date],dbo.fnadateformat(t.[Deal Date]) [Deal Date],
		t.[Type],t.[Deal ID] ,t.[Deal REF ID] ,round(t.[Volume % Avail],4) [Volume % Avail]
		, case when t.[Deal REF ID] =''<b>Sub Total:</b>'' then ''<b>''+[dbo].FNARemoveTrailingZero(LTRIM(RTRIM(STR(round(CAST(t.[Volume Avail] AS NUMERIC(28,2)),2), 28, 2))))+''</b>'' else [dbo].FNARemoveTrailingZero(LTRIM(RTRIM(STR(round(CAST(t.[Volume Avail] AS NUMERIC(28,2)),2), 28, 2)))) end  [Volume Avail]
		, case when t.[Deal REF ID] =''<b>Sub Total:</b>'' then ''<b>''+[dbo].FNARemoveTrailingZero(LTRIM(RTRIM(STR(CAST(round(t.[Volume matched],2) AS NUMERIC(28,2)), 28, 2))))+''</b>'' else [dbo].FNARemoveTrailingZero(LTRIM(RTRIM(STR(CAST(round(t.[Volume matched],2) AS NUMERIC(28,2)), 28, 2)))) end [Volume matched] ,
		round(t.[% Matched],4) [% Matched],t.[UOM],
		CASE WHEN (sb1.source_book_id < 0) THEN ''None'' ELSE sb1.source_book_name END AS ['+group1+'],
		CASE WHEN (sb2.source_book_id < 0) THEN ''None'' ELSE sb2.source_book_name END AS ['+group2+'],
		CASE WHEN (sb3.source_book_id < 0) THEN ''None'' ELSE sb3.source_book_name END AS ['+group3+'],
		CASE WHEN (sb4.source_book_id < 0) THEN ''None'' ELSE sb4.source_book_name END AS ['+group4+']
		,sc.counterparty_name [Counterparty]
		,t.process_id
	FROM #tmp_report t
	left JOIN source_counterparty sc ON sc.counterparty_id = t.counterparty 
	left join #tmp_running_bal r on r.[rowid]=t.process_Rowid
	LEFT OUTER JOIN source_deal_header sdh ON sdh.source_deal_header_id=t.[Deal ID]
	LEFT OUTER JOIN source_book sb1 ON sb1.source_book_id = sdh.source_system_book_id1 
	LEFT OUTER JOIN source_book sb2 ON sb2.source_book_id = sdh.source_system_book_id2
	LEFT OUTER JOIN source_book sb3 ON sb3.source_book_id = sdh.source_system_book_id3
	LEFT OUTER JOIN source_book sb4 ON sb4.source_book_id = sdh.source_system_book_id4
 order by t.rowid '
FROM source_book_mapping_clm

EXEC(@sql_stmt)

