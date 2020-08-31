/****** Object:  UserDefinedFunction [dbo].[FNADateTimeFormat]    Script Date: 04/12/2010 17:07:51 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNADateTimeFormat]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNADateTimeFormat]
/****** Object:  UserDefinedFunction [dbo].[FNADateTimeFormat]    Script Date: 04/12/2010 17:07:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- select dbo.FNADateTimeFormat('1/30/2003 23:1:31', 1)
-- select dbo.FNADateTimeFormat('2015-09-04 00:04:37.663', 2)
-- select dbo.FNADateTimeFormat('1/30/2003 00:23:00', 1)
-- select dbo.FNADateTimeFormat('1/30/2003', 1)

-- This function converst a datatime to ADIHA DateTime format 
-- Inpute is SQL datatime...
-- Input is a SQl Date variable
-- type = 1    Jan 2, 1967 hh:mm:ss
-- type = 2    1/2/1967 hh:mm:ss
CREATE FUNCTION [dbo].[FNADateTimeFormat](@DATE datetime, @type int)
RETURNS Varchar(50)
AS
BEGIN
	Declare @FNADateTimeFormat As Varchar(50)
	DECLARE @hh Int
	DECLARE @mm Int
	DECLARE @ss Int

	--IF @type <> 0
	--BEGIN
		SET @DATE=dbo.FNAConvertTimezone(@DATE,0)
	--END
	
	SET @hh = datepart(hh, @DATE)
	SET @mm = datepart(mi, @DATE)
	SET @ss = datepart(ss, @DATE)
	
	Set @FNADateTimeFormat =  dbo.FNAGetGenericDate(@DATE, dbo.FNADBUser()) + ' ' + 
		case when @hh<10 then '0' else '' end + cast(@hh as varchar) +':'+ 
		case when @mm<10 then '0' else '' end + cast(@mm as varchar) +':'+
		case when @ss<10 then '0' else '' end + cast(@ss as varchar) 
-- 		case WHEN (@hh > 0) then ' ' + 
-- 			case when (@hh < 10) then '0' else '' end + cast(@hh as varchar) 
-- 		else '' end + 
-- 
-- 		case WHEN (@mm > 0) then ':' + 
-- 			case when (@mm < 10) then '0' else '' end + cast(@mm as varchar)  
-- 		else '' end +
-- 
-- 		case WHEN (@ss > 0) then ':' + 
-- 			case when (@ss < 10) then '0' else '' end + cast(@ss as varchar) 
-- 		else '' end 

	RETURN(@FNADateTimeFormat)
END










