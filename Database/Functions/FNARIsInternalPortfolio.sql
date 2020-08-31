IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARIsInternalPortfolio]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARIsInternalPortfolio]
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNARIsInternalPortfolio](@source_deal_header_id INT, @internal_portfolio_id INT)
RETURNS INT AS  
BEGIN 
	
	DECLARE @ret INT = 1
	
	SELECT @ret = 0 FROM source_deal_header sdh WHERE sdh.source_deal_header_id = @source_deal_header_id
	AND sdh.internal_portfolio_id = @internal_portfolio_id
	
	RETURN @ret
			
END
