/****** Object:  UserDefinedFunction [dbo].[FNARandNumber]    Script Date: 08/28/2013 11:27:03 ******/

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARandNumber]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARandNumber]
GO

/****** Object:  UserDefinedFunction [dbo].[FNARandNumber]    Script Date: 08/28/2013 11:27:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNARandNumber]()
RETURNS FLOAT
AS
  BEGIN
  RETURN (SELECT RandNumber FROM [dbo].vwRandNumber)
  END
GO


