/****** Object:  UserDefinedFunction [dbo].[FNAEOHHours]    Script Date: 01/11/2011 09:49:05 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAEOHHours]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAEOHHours]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAEOHHours]    Script Date: 01/11/2011 09:48:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNAEOHHours](@meter_id INT,@channel INT)

RETURNS FLOAT AS
BEGIN
	return 1
END


