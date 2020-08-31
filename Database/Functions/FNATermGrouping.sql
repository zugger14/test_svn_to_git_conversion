/****** Object:  UserDefinedFunction [dbo].[FNATermGrouping]    Script Date: 07/26/2009 20:25:13 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNATermGrouping]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNATermGrouping]

/****** Object:  UserDefinedFunction [dbo].[FNATermGrouping]    Script Date: 07/26/2009 20:25:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


-- This function converst a datatime to ADIHA format 'mm/dd/yyyy'
-- Inpute is SQL datatime...
-- Input is a SQl Date variable
--DROP FUNCTION FNAGetTermGrouping
-- grnaulirty type m (month), q(quarter), s(semi-annual), a(annual)
--SELECT [dbo].[FNATermGrouping]('2008-1-17 12:00:00', 982)
CREATE FUNCTION [dbo].[FNATermGrouping](@DATE datetime, @granularity VARCHAR(100))
RETURNS Varchar(50)
AS
BEGIN
	Declare @FNAGetTermGrouping As Varchar(50)
	Set @FNAGetTermGrouping = CASE WHEN (@granularity = '980' OR @granularity = '703' OR @granularity = 'm') THEN
						CAST(YEAR(@DATE) AS VARCHAR)+'-'+RIGHT('00'+CAST(MONTH(@DATE) AS VARCHAR),2)
				       WHEN (@granularity = '991' OR @granularity = '704' OR @granularity = 'q') THEN
						CAST(Year(@DATE) As Varchar)+'-Q' + 
						cast(DATEPART(quarter,@DATE) as varchar)
						
				       WHEN (@granularity = '992' OR @granularity = '705' OR @granularity = 's') THEN
							CAST(Year(@DATE) As Varchar)+'-'+
							CASE WHEN (Month(@DATE) < 7) THEN '1st'  
						     ELSE '2nd' END 
						
				       WHEN (@granularity ='993' OR @granularity = '706' OR @granularity = 'a') THEN
							CAST(Year(@DATE) As Varchar)	
						WHEN (@granularity ='981' OR @granularity = 'd' ) THEN
							convert(VARCHAR(10),@DATE,120)
						WHEN (@granularity ='982' ) THEN
							RIGHT('00'+CAST(day(@DATE) AS VARCHAR),2)+ '-'+ RIGHT('00'+CAST(DATEPART(hh,@DATE) AS VARCHAR),2)
			
				       ELSE
							CAST(Year(@DATE) As Varchar)					
				       END			
	-- select * from static_data_value where type_id=978
	RETURN(@FNAGetTermGrouping)
END









