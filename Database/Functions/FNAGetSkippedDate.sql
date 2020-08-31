/****** Object:  UserDefinedFunction [dbo].[FNA24HrsAverage]    Script Date: 04/05/2010 17:21:07 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAGetSkippedDate]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].FNAGetSkippedDate
--Get the skipped date by @times from @event_date
-- @event_date= Base date
-- @skip_granularity = granularity to skip
-- @times: skip by this number.


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].FNAGetSkippedDate(@event_date datetime,@skip_granularity int,@times int)
RETURNS date AS  
BEGIN 

--declare @event_date datetime='2018-07-03'
--	,@skip_granularity int=990
--	,@times int=2

	declare @skipped_date date

	select @skipped_date=dateadd(day,case @skip_granularity 
		when 990 then 8-DATEPART(dw,@event_date)+1+((isnull(@times,1)-1)*7) --	Weekly
		when 980 then DATEDIFF(day,@event_date,eomonth(@event_date,isnull(@times,1)-1))+1  --	Monthly
		else  isnull(@times,0) --	Daily
	end,@event_date)

	--select @no_days no_days,@event_date event_date,dateadd(day,@no_days,@event_date) skipped_date

	return @skipped_date
end