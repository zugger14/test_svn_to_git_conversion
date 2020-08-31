IF OBJECT_ID(N'FNAGetFirstLastDayOfMonth', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNAGetFirstLastDayOfMonth]
 GO 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAGetFirstLastDayOfMonth] ( @input_date    DATETIME, @first_last NCHAR(1) )
RETURNS DATETIME
BEGIN
	DECLARE @return_value DATETIME
	SET @first_last = ISNULL(@first_last, 'f')
	
	IF @first_last = 'f'
	BEGIN
		SELECT @return_value =  CAST(CAST(YEAR(@input_date) AS VARCHAR(4)) + '/' + 
						        CAST(MONTH(@input_date) AS VARCHAR(2)) + '/01' AS DATETIME)
	END
	ELSE IF @first_last = 'l'
		SELECT @return_value = DATEADD(month, ((YEAR(@input_date) - 1900) * 12) + MONTH(@input_date), -1)

    RETURN @return_value
END

GO
