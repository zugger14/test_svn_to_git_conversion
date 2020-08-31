IF OBJECT_ID(N'FNACovertToSTDCurveMaturityDate', N'FN') IS NOT NULL
DROP FUNCTION [dbo].[FNACovertToSTDCurveMaturityDate]
GO

--This function returns the date in a regional format to standard sql format 'yyyy-mm-dd'
--select dbo.FNACovertToSTDCurveMaturityDate('31/1/2003')
CREATE FUNCTION [dbo].[FNACovertToSTDCurveMaturityDate]
(
	@aDate VARCHAR(20)
)
RETURNS Varchar(20)
AS
BEGIN
	DECLARE @FNACovertToSTDCurveMaturityDate varchar(50)
	DECLARE @hh Int
	DECLARE @mm Int
	DECLARE @ss Int	
	
	SET @hh = datepart(hh, @aDate)
	SET @mm = datepart(mi, @aDate)
	SET @ss = datepart(ss, @aDate)

	Set @FNACovertToSTDCurveMaturityDate = dbo.FNACovertToSTDDate(@aDate) +

					case WHEN (@hh > 0) then ' ' + 
						case when (@hh < 10) then '0' else '' end + cast(@hh as varchar) 
					else '' end + 
			
					case	WHEN (@hh = 0) then ''
						WHEN (@mm > 0) then ':' + 
							case when (@mm < 10) then '0' else '' end + cast(@mm as varchar)  
					else ':00' end +
			
					case 	WHEN (@hh = 0) then ''
						WHEN (@ss > 0) then ':' + 
							case when (@ss < 10) then '0' else '' end + cast(@ss as varchar) 
					else ':00' end 

	RETURN @FNACovertToSTDCurveMaturityDate

END










