/****** Object:  UserDefinedFunction [dbo].[FNABlackScholes]    Script Date: 05/08/2009 16:28:15 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAGetFrequencyText]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAGetFrequencyText]
/****** Object:  UserDefinedFunction [dbo].[FNABlackScholes]    Script Date: 05/08/2009 16:28:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	print dbo.FNAGetFrequencyText('d','tf')
*/

CREATE FUNCTION [dbo].[FNAGetFrequencyText]
(
	@frequency_key       CHAR(1),
	@frequency_category  VARCHAR(2)-- a = (hourly,monthly etc), v = (hour,month etc)
)
RETURNS VARCHAR(100)
AS
BEGIN
	DECLARE @return VARCHAR(100)	
	IF @frequency_category='a' BEGIN
		set @return = 
		CASE @frequency_key
			WHEN 'h' then 'Hourly'
			WHEN 'd' then 'Daily'
			WHEN 'w' then 'Weekly'
			WHEN 'm' then 'Monthly'
			WHEN 'q' then 'Quarterly'
			WHEN 's' then 'Semi-Annually'
			WHEN 'a' then 'Annually'
			WHEN 't' THEN 'Term'
		END
	END
	ELSE BEGIN
		set @return = 
		CASE @frequency_key
			WHEN 'h' then 'Hour'
			WHEN 'd' then 'Day'
			WHEN 'w' then 'Week'
			WHEN 'm' then 'Month'
			WHEN 'q' then 'Quarter'
			WHEN 's' then 'Semi-annual'
			WHEN 'a' then 'Annual'
			WHEN 't' THEN 'Term'
		END
	END
	RETURN @return

END