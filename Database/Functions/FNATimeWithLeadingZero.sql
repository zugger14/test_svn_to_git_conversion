IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNATimeWithLeadingZero]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNATimeWithLeadingZero]

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION FNATimeWithLeadingZero
(
@time VARCHAR(25)
)
RETURNS VARCHAR(25) AS 
BEGIN
	DECLARE @new_time VARCHAR(25)
	SELECT @new_time =  CASE WHEN LEN(LEFT(@time, CHARINDEX(':',@time,0) -1)) = 1 THEN '0' +LEFT(@time, CHARINDEX(':',@time,0) -1) + ':00:00' ELSE  @time END
	SELECT @new_time = CASE WHEN LEN(@new_time) = 5 THEN @new_time + ':00' ELSE @new_time END 
	RETURN @new_time	
END 
