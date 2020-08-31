IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAPriorInvoiceAdjustment]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAPriorInvoiceAdjustment]
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNAPriorInvoiceAdjustment](
	@seq_number INT, 
	@relative_prod_month_no INT, 
	@relative_asofdate_no INT
)
RETURNS FLOAT AS  
BEGIN
	RETURN 1
END