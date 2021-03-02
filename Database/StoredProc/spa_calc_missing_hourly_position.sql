IF EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_calc_missing_hourly_position]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_calc_missing_hourly_position]
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[spa_calc_missing_hourly_position] 
	@sub_id int=null,
	@process_id varchar(50)=null,
	@db_usr varchar(30)=null,
	@calc_position varchar(1)='y'
as

/*

if object_id('tempdb..#books') is not null
drop table #books

declare @sub_id int

--select * from process_deal_position_breakdown
--delete process_deal_position_breakdown

--*/

declare @report_position varchar(250),@st varchar(max)



set @db_usr= isnull(@db_usr,dbo.FNADBUser())
set @process_id=isnull(@process_id,dbo.FNAGetNewID())
SET @report_position = dbo.FNAProcessTableName('report_position', @db_usr, @process_id)

if object_id(@report_position) is not null
	exec('drop table '+@report_position)


CREATE TABLE #books (fas_book_id INT, source_system_book_id1 INT,source_system_book_id2 INT,source_system_book_id3 INT,source_system_book_id4 INT)

set @st='
INSERT INTO #books
SELECT distinct
ssbm.fas_book_id,ssbm.source_system_book_id1,ssbm.source_system_book_id2,ssbm.source_system_book_id3,ssbm.source_system_book_id4
FROM portfolio_hierarchy book (nolock) INNER JOIN
Portfolio_hierarchy stra (nolock) ON book.parent_entity_id = stra.entity_id LEFT OUTER JOIN
source_system_book_map ssbm ON ssbm.fas_book_id = book.entity_id
where 1=1' +case when @sub_id is null then '' else ' stra.parent_entity_id='+cast(@sub_id as varchar) end

exec(@st)

SET @st='CREATE TABLE ' + @report_position + '(source_deal_header_id INT, [action] VARCHAR(1),source_deal_detail_id INT) '
EXEC(@st)

set @st='
   INSERT INTO ' + @report_position + '
SELECT DISTINCT sdh.source_deal_header_id, ''i'' action,sdd.source_deal_detail_id
--INTO '+@report_position+'
FROM source_deal_header sdh
	inner join #books ssbm on
		ssbm.source_system_book_id1=sdh.source_system_book_id1 and ssbm.source_system_book_id2=sdh.source_system_book_id2
		and ssbm.source_system_book_id3=sdh.source_system_book_id3 and ssbm.source_system_book_id4=sdh.source_system_book_id4
	inner join source_deal_header_template sdht on sdht.template_id=sdh.template_id
	inner join source_deal_detail sdd on sdh.source_deal_header_id=sdd.source_deal_header_id
	left join report_hourly_position_deal_main s on s.term_start between sdd.term_start and sdd.term_end and   sdd.source_deal_detail_id=s.source_deal_detail_id
	left join source_deal_detail_position sddp on sddp.source_deal_detail_id=sdd.source_deal_detail_id
where (s.source_deal_header_id is null or sddp.total_volume is null)
	and isnull(sdh.internal_desk_id,17300) in (17300,17302) and isnull(sdh.product_id,4101) = 4101
	and sdd.fixed_float_leg = ''t'' AND ISNULL(sdht.internal_deal_type_value_id,-1) NOT IN(21,20)
	and isnull(sdd.deal_volume,0)<>0
union
SELECT DISTINCT sdh.source_deal_header_id, ''i'' action,sdd.source_deal_detail_id
FROM source_deal_header sdh
	inner join #books ssbm on
		ssbm.source_system_book_id1=sdh.source_system_book_id1 and ssbm.source_system_book_id2=sdh.source_system_book_id2
		and ssbm.source_system_book_id3=sdh.source_system_book_id3 and ssbm.source_system_book_id4=sdh.source_system_book_id4
	inner join source_deal_header_template sdht on sdht.template_id=sdh.template_id
	inner join source_deal_detail sdd on sdh.source_deal_header_id=sdd.source_deal_header_id
	left join source_deal_detail_position sddp on sddp.source_deal_detail_id=sdd.source_deal_detail_id
	left join report_hourly_position_profile_main s on s.term_start between sdd.term_start and sdd.term_end and sdd.source_deal_header_id=s.source_deal_header_id
	outer apply
	(
	select 
		sum(Hr1+Hr2+Hr3+Hr4+Hr5+Hr6+Hr7+Hr8+Hr9+Hr10+Hr11+Hr12+Hr13+Hr14+Hr15+Hr16+Hr17+Hr18+Hr19+Hr20+Hr21+Hr22+Hr23+Hr24) forecast
		from deal_detail_hour where profile_id=sdd.profile_id and term_date between sdd.term_start and sdd.term_end
	) forecast
where (s.source_deal_header_id is null or sddp.total_volume is null)
	and sdh.internal_desk_id in (17301) and isnull(sdh.product_id,4101) = 4101
	and sdd.fixed_float_leg = ''t'' AND ISNULL(sdht.internal_deal_type_value_id,-1) NOT IN(21,20) 
	and isnull(forecast.forecast,0)<>0
union
SELECT DISTINCT sdh.source_deal_header_id, ''i'' action,sdd.source_deal_detail_id
FROM source_deal_header sdh
	inner join #books ssbm on
		ssbm.source_system_book_id1=sdh.source_system_book_id1 and ssbm.source_system_book_id2=sdh.source_system_book_id2
		and ssbm.source_system_book_id3=sdh.source_system_book_id3 and ssbm.source_system_book_id4=sdh.source_system_book_id4
	inner join source_deal_header_template sdht on sdht.template_id=sdh.template_id
	inner join source_deal_detail sdd on sdh.source_deal_header_id=sdd.source_deal_header_id
	left join source_deal_detail_position sddp on sddp.source_deal_detail_id=sdd.source_deal_detail_id
	left join report_hourly_position_fixed_main s on s.term_start between sdd.term_start and sdd.term_end and sdd.source_deal_detail_id=s.source_deal_detail_id
where (s.source_deal_header_id is null or sddp.total_volume is null)
	and sdh.product_id =4100 and sdd.fixed_float_leg = ''t'' AND ISNULL(sdht.internal_deal_type_value_id,-1) NOT IN(21,20) 
'

exec spa_print @st
exec(@st)


if @@ROWCOUNT>0
begin
	if isnull(@calc_position,'y')='y'
		EXEC dbo.spa_update_deal_total_volume NULL, @process_id, 0,1,@db_usr,'n',2,default,'n'
end
