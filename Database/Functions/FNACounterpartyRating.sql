IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNACounterpartyRating]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[FNACounterpartyRating]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ==================================================================================
-- Created date: 2010-01-29 2:23PM
-- Description:	Validates syntax of FNARCounterpartyRating function
-- Returns: 1
-- ==================================================================================
CREATE FUNCTION dbo.FNACounterpartyRating()
RETURNS int
AS
BEGIN
	
	RETURN 1

END
