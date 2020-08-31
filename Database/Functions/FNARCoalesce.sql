/****** Object:  UserDefinedFunction [dbo].[FNARWeekDay]    Script Date: 07/23/2009 01:08:08 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARCoalesce]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARCoalesce]
/****** Object:  UserDefinedFunction [dbo].[FNARWeekDay]    Script Date: 07/23/2009 01:08:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNARCoalesce](
	@arg1 varchar(20),
	@arg2 varchar(20),
	@arg3 varchar(20),
	@arg4 varchar(20),
	@arg5 varchar(20),
	@arg6 varchar(20),
	@arg7 varchar(20),
	@arg8 varchar(20),
	@arg9 varchar(20),
	@arg10 varchar(20),
	@arg11 varchar(20),
	@arg12 varchar(20)	
)

RETURNS VARCHAR(20) AS
BEGIN

DECLARE @value VARCHAR(20)


	set 	@value=COALESCE(@arg1,@arg2,@arg3,@arg4,@arg5,@arg6,@arg7,@arg8,@arg9,@arg10,@arg11,@arg12)

	return @value
END



