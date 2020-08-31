/****** Object:  UserDefinedFunction [dbo].[FNARPriorFinalizedAmount]    Script Date: 02/14/2011 15:43:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARPriorFinalizedAmount]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARPriorFinalizedAmount]
GO


/****** Object:  UserDefinedFunction [dbo].[FNARPriorFinalizedAmount]    Script Date: 02/14/2011 15:43:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[FNARPriorFinalizedAmount] (@contract_id INT,@counterparty_id INT,@prod_date DATETIME,@invoice_line_item_id INT,@invoice_type CHAR(1))
RETURNS float AS  
BEGIN 
	DECLARE @value FLOAT

	SELECT 
		@value = SUM(ISNULL(civ.Value,0))
	FROM 
		Calc_invoice_Volume_variance civv
		INNER JOIN calc_invoice_volume civ ON civv.calc_id = civ.calc_id AND ISNULL(civ.status,'')<>'v'
		CROSS APPLY(SELECT MAX(civv1.as_of_date) as_of_date, MAX(civv1.netting_group_id) [netting_group_id] from Calc_invoice_Volume_variance civv1 INNER JOIN calc_invoice_volume civ1 
			ON civv1.calc_id = civ1.calc_id WHERE counterparty_id=civv.counterparty_id
			AND civv1.contract_id=civv.contract_id
			AND civv1.prod_date = civv.prod_date
			AND ISNULL(civv1.invoice_template_id,-1) =  ISNULL(civv.invoice_template_id,-1) AND  ISNULL(civ1.[status],'') <> 'v'
			AND civv1.invoice_type = civv.invoice_type) civv2
	WHERE
		civv.counterparty_id = @counterparty_id
		AND civv.contract_id = @contract_id
		AND YEAR(civ.prod_date) = YEAR(@prod_date) AND MONTH(civ.prod_date) = MONTH(@prod_date) 
		AND (ISNULL(civ.finalized,'n') = 'y' OR ISNULL(civ.finalized,'n') = 'f')
		AND civ.invoice_line_item_id = @invoice_line_item_id
		AND civv.netting_group_id IS NULL -- Exclude netting if not it will double up the sum
		AND ISNULL(civv.netting_group_id , -1) = ISNULL(civv2.netting_group_id , -1)
		AND civv.as_of_date = civv2.as_of_date
		AND ISNULL(civ.status,'')<>'v'
		AND civv.finalized = 'y'
		AND civv.invoice_type = @invoice_type
	RETURN ISNULL(@value,0)
END

