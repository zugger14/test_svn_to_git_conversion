IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAContractFixPrice]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAContractFixPrice]
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNAContractFixPrice]
(
	@product_type	INT, 
	@price_option	INT
)
RETURNS FLOAT 
AS  
BEGIN 
	RETURN 1
END
