/****** Object:  UserDefinedFunction [dbo].[FNAGetQuarter]    Script Date: 08/20/2009 12:36:48 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAGetQuarter]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAGetQuarter]

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go





--SELECT DBO.FNAGetQuarter('2004-11-28')
--SELECT convert(datetime, '2004-2-28', 102)
-- This function converst a datatime to ADIHA format 'yyyy-mm-1'
-- Inpute is SQL datatime...
-- Input is a SQl Date variable
CREATE FUNCTION [dbo].[FNAGetQuarter](@DATE varchar(100))
RETURNS Varchar(50)
AS
BEGIN
	Declare @FNAGetContractMonth As Varchar(50)


	Set @FNAGetContractMonth = 	CAST(Year(@DATE) As Varchar)+'-Q'+
					cast(DATEPART(quarter,@DATE) as varchar)
	
	RETURN(@FNAGetContractMonth)
END














