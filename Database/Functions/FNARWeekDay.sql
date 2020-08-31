/****** Object:  UserDefinedFunction [dbo].[FNARWeekDay]    Script Date: 07/23/2009 01:08:08 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARWeekDay]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARWeekDay]
/****** Object:  UserDefinedFunction [dbo].[FNARWeekDay]    Script Date: 07/23/2009 01:08:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNARWeekDay](
	@prod_date varchar(20)
)

RETURNS INT AS
BEGIN

DECLARE @value INT


set 	@value=datepart(w,@prod_date)

	return @value
END



