
IF EXISTS ( SELECT *FROM   sys.objects WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[FNADealStrikePrice]') AND TYPE IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
    DROP FUNCTION [dbo].[FNADealStrikePrice]
/****** Object:  UserDefinedFunction [dbo].[FNADealStrikePrice] */

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Created by: rgiri@pioneersolutionsglobal.com
-- Create date: 2013-04-27
-- Description: for syntax checkup for  FNADealStrikePrice

-- ===========================================================================================================

CREATE FUNCTION [dbo].[FNADealStrikePrice] ()
RETURNS FLOAT
AS
BEGIN
	RETURN 1 
END
