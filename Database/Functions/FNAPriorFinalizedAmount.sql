/****** Object:  UserDefinedFunction [dbo].[FNAPriorFinalizedAmount]    Script Date: 02/14/2011 15:43:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAPriorFinalizedAmount]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAPriorFinalizedAmount]
GO


/****** Object:  UserDefinedFunction [dbo].[FNAPriorFinalizedAmount]    Script Date: 02/14/2011 15:43:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[FNAPriorFinalizedAmount] (@invoice_line_item_id INT)
RETURNS float AS  
BEGIN 
	return 1
END

GO


