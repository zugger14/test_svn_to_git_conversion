/****** Object:  StoredProcedure [dbo].[spa_get_finalized_charge_type]    Script Date: 04/09/2009 16:57:07 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_get_finalized_charge_type]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_get_finalized_charge_type]
/****** Object:  StoredProcedure [dbo].[spa_get_finalized_charge_type]    Script Date: 04/09/2009 16:57:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_get_finalized_charge_type]
	@flag CHAR(1) = 'u' -- u= unfinalized,f=finalized
	,@calc_id INT
	,@contract_id INT          = NULL
	,@counterparty_id INT      = NULL
	,@prod_date DATETIME       = NULL
	,@as_of_date DATETIME      = NULL
	,@invoice_type CHAR(1)     = NULL
	,@settlement_date DATETIME =NULL	
	

AS
BEGIN
SET NOCOUNT ON;

IF @flag='u'
	SELECT DISTINCT civ.invoice_line_item_id
			,line_item_value.description AS [Charge Type]
	FROM calc_Invoice_volume_variance civv
		JOIN calc_invoice_volume civ
			ON civv.calc_id = civ.calc_id
		JOIN static_data_value line_item_value
			ON civ.invoice_line_item_id = line_item_value.value_id
	WHERE civv.counterparty_id = @counterparty_id
			AND civv.contract_id = @contract_id
			AND civv.prod_date = @prod_date
			AND civv.as_of_date = @as_of_date
			AND isnull(civ.finalized, 'n') = 'n'
			AND civv.invoice_type = @invoice_type
            AND civv.settlement_date = @settlement_date


ELSE IF @flag='f'
	SELECT DISTINCT civ.invoice_line_item_id
		,line_item_value.description AS [Charge Type]
	FROM calc_Invoice_volume_variance civv
	JOIN calc_invoice_volume civ
		ON civv.calc_id = civ.calc_id
	JOIN static_data_value line_item_value
		ON civ.invoice_line_item_id = line_item_value.value_id
	WHERE (civv.counterparty_id = @counterparty_id
			OR ISNULL(@counterparty_id, 1) = 1)
		AND (civv.contract_id = @contract_id
			OR ISNULL(@contract_id, 1) = 1 )
		AND ( civv.prod_date = @prod_date
			OR ISNULL(@prod_date, 1) = 1 )
		AND ( civv.as_of_date = @as_of_date
			OR ISNULL(@as_of_date, 1) = 1 )
		--AND (civv.calc_id=@calc_id OR ISNULL(@calc_id,1)=1)
		AND isnull(civ.finalized, 'n') = 'y'
		AND civv.invoice_type = @invoice_type
                AND (civv.settlement_date = @settlement_date OR ISNULL(@settlement_date, 1) = 1)


ELSE IF @flag='j'	-- to populate grid in settlement adJustment
	SELECT 
		civ.invoice_line_item_id
		,line_item_value.description AS [Charge Type]
		,sa.value_diff [Value Diff]
	FROM calc_invoice_volume civ
	JOIN static_data_value line_item_value
		ON civ.invoice_line_item_id = line_item_value.value_id
	INNER JOIN settlement_adjustments sa
		ON civ.calc_id = sa.calc_id
			AND civ.invoice_line_item_id = sa.invoice_line_item_id
	WHERE civ.calc_id = @calc_id
		AND isnull(finalized, 'n') = 'y'
		AND ( STATUS IS NULL OR STATUS <> 'a' )
END






