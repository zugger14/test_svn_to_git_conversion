/****** Object:  UserDefinedFunction [dbo].[FNAContractValue]    Script Date: 12/13/2010 20:34:39 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAContractValue]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAContractValue]
GO


--select dbo.FNAPeakDemand()

CREATE FUNCTION [dbo].[FNAContractValue] (@x1 int, @x2 int,@x3 int, @x4 INT, @month INT, @relative_as_of_date VARCHAR(10))
RETURNS float AS  
BEGIN
	RETURN 1
END
