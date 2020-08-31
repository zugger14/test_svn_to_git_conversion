/*
Inserts string in the form [Index1,Field1],[Index2,Field2],[Index3,Field3],.. into tables.
*/

/****** Object:  UserDefinedFunction [dbo].[FNAParseStringIntoTable]    Script Date: 01/10/2009 18:17:56 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAParseStringIntoTable]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAParseStringIntoTable]

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go




CREATE FUNCTION [dbo].[FNAParseStringIntoTable] (@string varchar(max))
RETURNS varchar(max) AS  
BEGIN 

--declare @string varchar(max)
declare @type char(1)

--set @string = ' [i1,f1], [i2,f2],[i3,f3],[i4,f4],[i5,f5]'
--set @string = ' [''Index 1'',''Field f1''],[''Index i2'',''Field f2''],[''Index i3'',''Field f3''],[i4,f4],[i5,f5]'


set @string = ltrim(@string)
set @type = substring(@string,1,1)

if @type = '['
begin
	set @string = replace(@string,'''','')
	set @string = replace(@string,'],[',''' union all select ''')
	set @string = replace(@string,',',''',''')
	set @string = replace(@string,'[','''')
	set @string = replace(@string,']','''')
	set @string = 'select ' + @string
end

return @string

END





