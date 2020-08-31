IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNACorresMnthValue]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNACorresMnthValue]
GO 

CREATE FUNCTION [dbo].[FNACorresMnthValue](@x int, @y int)
RETURNS float AS  
BEGIN 
	return 1
END






