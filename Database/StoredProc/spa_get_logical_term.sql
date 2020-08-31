IF OBJECT_ID(N'[dbo].[spa_get_logical_term]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_get_logical_term]
GO


CREATE PROCEDURE [dbo].[spa_get_logical_term]
@source_value VARCHAR(10),
@default_value INT
AS
	
select 
	case when isdate(dbo.FNAGetSQLStandardDate(@source_value))=1 then 
		dbo.fnadateformat(case @default_value 
			when 19400 then @source_value --Current Day
			when 19401 then dateadd(day,1,@source_value) --Next Day
			when 19402 then dateadd(month,1,convert(varchar(8),@source_value,120)+ '01') --Next Month
			when 19403 then DATEADD(wk, DATEDIFF(wk,0,@source_value), 0)  --Current Business Week
			when 19404 then DATEADD(wk, DATEDIFF(wk,0,@source_value)+1, 0) --Next Business Week
			when 19405 then dateadd(QUARTER,datepart(QUARTER,@source_value)-1,convert(varchar(5),@source_value,120)+ '01-01')	 --Current Quarter
			when 19406 then dateadd(QUARTER,datepart(QUARTER,@source_value),convert(varchar(5),@source_value,120)+ '01-01') --Next Quarter
			when 19407 then DATEADD(YEAR,1,convert(varchar(5),@source_value,120)+ '01-01') --Next Year
		end)
	else @source_value
	end TermStart,
	case when isdate(dbo.FNAGetSQLStandardDate(@source_value))=1 then 
		dbo.fnadateformat(case @default_value 
			when 19400 then @source_value --Current Day
			when 19401 then dateadd(day,1,@source_value) --Next Day
			when 19402 then dateadd(month,2,convert(varchar(8),@source_value,120)+ '01')-1 --Next Month
			when 19403 then DATEADD(wk, DATEDIFF(wk,0,@source_value), 0)+6  --Current Business Week
			when 19404 then DATEADD(wk, DATEDIFF(wk,0,@source_value)+1, 0)+6 --Next Business Week
			when 19405 then dateadd(QUARTER,datepart(QUARTER,@source_value),convert(varchar(5),@source_value,120)+ '01-01')-1	 --Current Quarter
			when 19406 then dateadd(QUARTER,datepart(QUARTER,@source_value)+1,convert(varchar(5),@source_value,120)+ '01-01')-1 --Next Quarter
			when 19407 then DATEADD(YEAR,2,convert(varchar(5),@source_value,120)+ '01-01')-1 --Next Year
		end)
	else @source_value
	end TermEnd
