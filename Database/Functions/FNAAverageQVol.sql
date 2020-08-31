IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAAverageQVol]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAAverageQVol]
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNAAverageQVol]
(
	@meter_id	VARCHAR(200), 
	@channel	INT
)
RETURNS FLOAT 
AS  
BEGIN 
	RETURN 1
END
