/****** Object:  UserDefinedFunction [dbo].[FNAInput]    Script Date: 08/20/2009 12:38:09 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAInput]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAInput]

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


CREATE FUNCTION [dbo].[FNAInput](@curve_id int)
RETURNS float AS  
BEGIN 
	return 1
END





