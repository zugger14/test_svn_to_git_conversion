IF EXISTS(SELECT * FROM   sys.objects WHERE  [object_id] = OBJECT_ID(N'[dbo].[FNAPriceMultiplier]') AND TYPE IN (N'FN', N'IF', N'TF', N'FS', N'FT') )
    DROP FUNCTION [dbo].[FNAPriceMultiplier]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAPriceMultiplier] ()

RETURNS FLOAT AS
BEGIN
	RETURN 1
END
GO
