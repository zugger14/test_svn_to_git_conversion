
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARCounterpartyRating]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[FNARCounterpartyRating]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ==================================================================================
-- Create date: 2010-01-29 12:50PM
-- Description:	Returns rating of a counterparty
-- Param: 
--	@counterparty_id int - Counterparty ID
-- Returns: Rating of a counterparty
-- ==================================================================================
CREATE FUNCTION [dbo].[FNARCounterpartyRating](@counterparty_id int)
RETURNS int
AS
BEGIN
	DECLARE @rating VARCHAR(50)
	
	SELECT TOP 1 @rating = rating.code FROM counterparty_credit_info cci 
	       INNER JOIN static_data_value rating ON cci.risk_rating = rating.value_id  
	       WHERE counterparty_id = @counterparty_id
	
	RETURN ISNULL(@rating, 0)
END
