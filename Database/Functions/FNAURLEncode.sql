
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAURLEncode]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAURLEncode]

GO

Create FUNCTION [dbo].[FNAURLEncode](@url varchar(1024))RETURNS varchar(3072)
AS
BEGIN
	RETURN replace(@url,char(32),'%20')
END

