IF EXISTS(SELECT * FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[FNARDaysInMnth]') AND TYPE IN(N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[FNARDaysInMnth]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNARDaysInMnth] (@pDate DATETIME)
RETURNS INT
AS
BEGIN


    RETURN CASE WHEN MONTH(@pDate) IN (1, 3, 5, 7, 8, 10, 12) THEN 31
                WHEN MONTH(@pDate) IN (4, 6, 9, 11) THEN 30
                ELSE CASE WHEN (YEAR(@pDate) % 4    = 0 AND
                                YEAR(@pDate) % 100 != 0) OR
                               (YEAR(@pDate) % 400  = 0)
                          THEN 29
                          ELSE 28
                     END
           END

END
GO
