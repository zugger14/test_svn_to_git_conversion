IF  EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAAveragePrice]') 
				AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[FNAAveragePrice]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNAAveragePrice](@curve_id INT, @block_define_id INT, @aggregation_level CHAR(1))
	RETURNS float AS  
BEGIN 
	return 1.0
END
