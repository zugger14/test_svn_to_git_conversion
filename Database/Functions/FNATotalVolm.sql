/****** Object:  UserDefinedFunction [dbo].[FNATotalVolm]    Script Date: 01/07/2011 17:49:37 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNATotalVolm]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNATotalVolm]

GO
/****** Object:  UserDefinedFunction [dbo].[FNATotalVolm]    Script Date: 01/07/2011 17:50:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNATotalVolm](
	@book_mapi_id1 INT,
	@book_mapi_id2 INT,
	@book_mapi_id3 INT,
	@book_mapi_id4 INT,
	@deal_type INT	
)

RETURNS FLOAT AS
BEGIN
	RETURN 1	
END


