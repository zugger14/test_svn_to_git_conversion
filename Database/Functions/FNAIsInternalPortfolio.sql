IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAIsInternalPortfolio]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAIsInternalPortfolio]
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAIsInternalPortfolio](@internal_portfolio_id INT)
RETURNS INT AS  
BEGIN 
	RETURN 1
END
