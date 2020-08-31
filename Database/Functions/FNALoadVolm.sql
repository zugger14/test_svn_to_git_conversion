IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNALoadVolm]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[FNALoadVolm]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ==================================================================================
-- Created date: 2010-01-29 2:23PM
-- Description:	Validates syntax of FNARLoadVolume function
-- Param: 
--	@counterparty_id int - Bucket ID
-- Returns: 1
-- ==================================================================================
CREATE FUNCTION dbo.FNALoadVolm(@bucket_id int)
RETURNS int
AS
BEGIN
	
	RETURN 1

END
