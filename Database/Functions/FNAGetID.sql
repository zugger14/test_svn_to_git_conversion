SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF EXISTS(SELECT * FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[FNAGetID]') AND TYPE IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[FNAGetID]
GO

CREATE FUNCTION [dbo].[FNAGetID]()
	RETURNS INT
AS
BEGIN
	RETURN 1
END
GO