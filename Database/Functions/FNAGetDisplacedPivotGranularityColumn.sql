IF  OBJECT_ID('FNAGetDisplacedPivotGranularityColumn') IS NOT NULL
    DROP FUNCTION [dbo].[FNAGetDisplacedPivotGranularityColumn]
GO 

 /**
	Breaksdown the input date range based on the input granularity

	Parameters :
	@term_start : Term Start
	@term_end : Term End
	@granularity : Granularity (Static Data - Type ID = 978)
	@dst_group_value_id : Dst Group Value Id (102200)
	@shift_value : Hour shift value

	Returns table will term breakdown based in input granularity
 */

CREATE FUNCTION [dbo].[FNAGetDisplacedPivotGranularityColumn](
	@term_start datetime
	,@term_end  datetime
	,@granularity int=982
	,@dst_group_value_id int =102200
	,@shift_value SMALLINT = 0
)
returns @tt table(clm_name varchar(15),is_dst bit,alias_name  varchar(15),rowid int identity(1,1))
AS
BEGIN
/** * DEBUG QUERY START *
 --select * from  [dbo].[FNAGetPivotGranularityColumn]('2017-11-05','2017-11-05',987,102200)
	--2015	2015-03-29 00:00:00.000	3	d
	--2015	2015-10-25 00:00:00.000	3	i

	--994	978	10Min
	--987	978	15Min
	--989	978	30Min
	--995	978	5Min
	--982	978	Hourly
	
DECLARE 
	 @term_start datetime		=	'2020-10-24' 
	,@term_end  datetime		=	'2020-10-24' 
	,@granularity int			=	982
	,@dst_group_value_id int	=	102201
	,@shift_value SMALLINT		=	6
	--set @term_start = '2020-03-28'
	--set @term_end	= '2020-03-28'

-- * DEBUG QUERY END * */

	DECLARE @is_shifted_day BIT

	IF EXISTS (
		SELECT 1 
		FROM mv90_DST
		WHERE  dst_group_value_id = 102201
			AND @shift_value <= hour 
		GROUP BY hour
	)
	BEGIN
		SET @is_shifted_day = 0
	END
	ELSE
	BEGIN
		SET @is_shifted_day = 1
	END

	declare @st varchar(max),@frequency varchar(1)

	select @frequency=case @granularity 
							when 982 then 'h'
							when 987 then 'f'
							when 994 then 'r'
							when 989 then 't'
							when 995 then 'z'
						end

	select @term_end=dateadd(mi,(24*60)-case @granularity 
										when 982 then 60
										when 987 then 15
										when 994 then 10
										when 989 then 30
										when 995 then 5
										else 0
									end,@term_end
	)

	insert into @tt 
	select  --hhmm+case when max(dst_hr)='B' then 'B' else '' end  a
	hhmm  a
	,case when max(dst_hr)='DST' then 1 else 0 end  b
	,case when mi='60' then  right('0'+cast(cast(hr as int)+1 as varchar),2)+':00' else hr+':'+mi end +max(dst_hr) c
	from
	( 

		SELECT distinct right('0'+cast(datepart(hour,term_start) as varchar),2)+right('0'+cast(datepart(MINUTE,term_start) as varchar),2) hhmm
			,right('0'+cast(case when @granularity =982 then 1 else 0 end + 
			datepart(hour,dateadd(HOUR, @shift_value, term_start))
			as varchar),2) hr
			,right('0'+cast(case @granularity
											when 987 then 15
											when 994 then 10
											when 989 then 30
											when 995 then 5
											else 0
										end +datepart(MINUTE,term_start) as varchar),2) mi 
			,'' dst_hr
		--	,max(case when dst.insert_delete='i' then 'A' else '' end) dst_hr
		FROM [FNATermBreakdown] (@frequency,@term_start,@term_end) a
		left join dbo.mv90_dst dst
				on  dst.dst_group_value_id=@dst_group_value_id  and
					 DATEADD(DAY, -1, dst.[date]) = convert(varchar(10),a.term_start,120) 
					and (dst.[hour] + 18)=DATEPART(hour,a.term_start)+1
					--and dst.insert_delete='d'
		where isnull(dst.insert_delete,'')<>'d'
		group by 
		right('0'+cast(datepart(hour,term_start) as varchar),2)+right('0'+cast(datepart(MINUTE,term_start) as varchar),2)
			,right('0'+cast(case when @granularity =982 then 1 else 0 end +
			datepart(hour,dateadd(HOUR, @shift_value, term_start))
			as varchar),2)
			,right('0'+cast(case @granularity
											when 987 then 15
											when 994 then 10
											when 989 then 30
											when 995 then 5
											else 0
										end +datepart(MINUTE,term_start) as varchar),2) 

		union all
		SELECT distinct right('0'+cast(datepart(hour,term_start) as varchar),2)+right('0'+cast(datepart(MINUTE,term_start) as varchar),2) hhmm
			,right('0'+cast(case when @granularity =982 then 1 else 0 end +
			datepart(hour,dateadd(HOUR, @shift_value, term_start))
			as varchar),2) hr
			,right('0'+cast(case @granularity
								when 987 then 15
								when 994 then 10
								when 989 then 30
								when 995 then 5
								else 0
							end +datepart(MINUTE,term_start) as varchar),2) mi 
			,'DST' dst_hr
		FROM [FNATermBreakdown] (@frequency,@term_start,@term_end) a
		inner join dbo.mv90_dst dst
				on  dst.dst_group_value_id=@dst_group_value_id  and
					 IIF(@is_shifted_day = 1,DATEADD(DAY, -1, dst.[date]),dst.[date])  = convert(varchar(10),a.term_start,120) 
					and dst.[hour] = DATEPART(hour,dateadd(HOUR, @shift_value, a.term_start)) + 1
					and dst.insert_delete='i'

	) dt
	group by hhmm,hr,mi,case when dst_hr='DST' then 'DST' else '' end
	order by LEFT(hhmm,2), case when max(dst_hr)='DST' then 99 else mi end,mi  --,case when dst_hr='DST' then 9 else 0 end 

	RETURN
END