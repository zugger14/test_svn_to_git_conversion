IF  EXISTS (SELECT * FROM sys.objects WHERE object_id  =  OBJECT_ID(N'[dbo].[FNARPriorInvoiceAdjustment]') AND type in (N'FN',  N'IF',  N'TF',  N'FS',  N'FT'))
DROP FUNCTION [dbo].[FNARPriorInvoiceAdjustment]
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNARPriorInvoiceAdjustment](
	@prod_date				NVARCHAR(20), 
	@as_of_date				NVARCHAR(20), 
    @counterparty_id		INT,  
    @contract_id			INT, 
    @invoice_line_item_id   INT,  
    @formula_id				INT,  
    @he						INT, 
    @granularity			INT, 
    @source_deal_header_id  INT, 
    @source_deal_detail_id  INT, 
	@seq_number				INT,  
	@relative_prod_month_no INT,  
	@relative_asofdate_no	INT
)
RETURNS FLOAT AS  
BEGIN
	
	DECLARE @value FLOAT
	DECLARE @new_as_of_date DATETIME
	
	SET @prod_date = DATEADD(M, @relative_prod_month_no, @prod_date)
	SET @new_as_of_date = DATEADD(M, @relative_asofdate_no, @as_of_date)
	
	IF @granularity = 980
		SELECT 
			@value = T1.value - T2.value 
		FROM ( 
				SELECT SUM(value) [value]
				FROM Calc_invoice_Volume_variance civv
				INNER JOIN calc_formula_value cfv ON cfv.calc_id = civv.calc_id			  
				where
					ISNULL(cfv.counterparty_id, '') = ISNULL(@counterparty_id, '')  
					AND ISNULL(cfv.contract_id, '') = ISNULL(@contract_id, '')
					AND ISNULL(cfv.invoice_line_item_id, '') = ISNULL(@invoice_line_item_id, '') 
					--AND CAST(CAST(Year(cfv.prod_date) As Varchar)+'-'+CAST(MONTH(cfv.prod_date) As Varchar) +'-01' as datetime) = @prod_date
					AND CAST(dbo.FNAContractMonthFormat(cfv.prod_date) + '-01' AS DATETIME) = @prod_date					
					AND cfv.seq_number = @seq_number 
					AND ISNULL(cfv.formula_id, '') = ISNULL(@formula_id, '')
					AND ISNULL(cfv.source_deal_header_id, -1) = ISNULL(@source_deal_header_id, -1)
					AND ISNULL(cfv.deal_id, -1) = ISNULL(@source_deal_detail_id, -1)
					AND civv.as_of_date = @new_as_of_date
			)T1, 
			(
				SELECT SUM(value)  [value]
				FROM Calc_invoice_Volume_variance civv
				INNER JOIN calc_formula_value cfv ON cfv.calc_id = civv.calc_id			  
				where
					ISNULL(cfv.counterparty_id, '') = ISNULL(@counterparty_id, '')  
					AND ISNULL(cfv.contract_id, '') = ISNULL(@contract_id, '')
					AND ISNULL(cfv.invoice_line_item_id, '') = ISNULL(@invoice_line_item_id, '')
					--AND CAST(CAST(Year(cfv.prod_date) As Varchar)+'-'+CAST(MONTH(cfv.prod_date) As Varchar) +'-01' as datetime) = @prod_date
					AND CAST(dbo.FNAContractMonthFormat(cfv.prod_date) +'-01' AS DATETIME) = @prod_date
					AND cfv.seq_number = @seq_number 
					AND ISNULL(cfv.formula_id, '') = ISNULL(@formula_id, '')
					AND ISNULL(cfv.source_deal_header_id, -1) = ISNULL(@source_deal_header_id, -1)
					AND ISNULL(cfv.deal_id, -1) = ISNULL(@source_deal_detail_id, -1)
					AND civv.as_of_date = @as_of_date
			)T2	
			
	ELSE IF @granularity = 981
		SELECT 
			@value = T1.value - T2.value 
		FROM ( 
				SELECT SUM(value) [value]
				FROM Calc_invoice_Volume_variance civv
				INNER JOIN calc_formula_value cfv ON cfv.calc_id = civv.calc_id			  
				where
					ISNULL(cfv.counterparty_id, '') = ISNULL(@counterparty_id, '')  
					AND ISNULL(cfv.contract_id, '') = ISNULL(@contract_id, '')
					AND ISNULL(cfv.invoice_line_item_id, '') = ISNULL(@invoice_line_item_id, '') 
					AND cfv.prod_date = @prod_date
					AND cfv.seq_number = @seq_number 
					AND ISNULL(cfv.formula_id, '') = ISNULL(@formula_id, '')
					AND ISNULL(cfv.source_deal_header_id, -1) = ISNULL(@source_deal_header_id, -1)
					AND ISNULL(cfv.deal_id, -1) = ISNULL(@source_deal_detail_id, -1)
					AND civv.as_of_date = @new_as_of_date
			)T1, 
			(
				SELECT SUM(value)  [value]
				FROM Calc_invoice_Volume_variance civv
				INNER JOIN calc_formula_value cfv ON cfv.calc_id = civv.calc_id			  
				where
					ISNULL(cfv.counterparty_id, '') = ISNULL(@counterparty_id, '')  
					AND ISNULL(cfv.contract_id, '') = ISNULL(@contract_id, '')
					AND ISNULL(cfv.invoice_line_item_id, '') = ISNULL(@invoice_line_item_id, '')
					AND cfv.prod_date = @prod_date
					AND cfv.seq_number = @seq_number 
					AND ISNULL(cfv.formula_id, '') = ISNULL(@formula_id, '')
					AND ISNULL(cfv.source_deal_header_id, -1) = ISNULL(@source_deal_header_id, -1)
					AND ISNULL(cfv.deal_id, -1) = ISNULL(@source_deal_detail_id, -1)
					AND civv.as_of_date = @as_of_date
			)T2	
			
	ELSE IF	@granularity = 982
		SELECT 
			@value = T1.value - T2.value 
		FROM ( 
				SELECT SUM(value) [value]
				FROM Calc_invoice_Volume_variance civv
				INNER JOIN calc_formula_value cfv ON cfv.calc_id = civv.calc_id			  
				where
					ISNULL(cfv.counterparty_id, '') = ISNULL(@counterparty_id, '')  
					AND ISNULL(cfv.contract_id, '') = ISNULL(@contract_id, '')
					AND ISNULL(cfv.invoice_line_item_id, '') = ISNULL(@invoice_line_item_id, '') 
					AND cfv.prod_date = @prod_date
					AND cfv.seq_number = @seq_number 
					AND ISNULL(cfv.formula_id, '') = ISNULL(@formula_id, '')
					AND ISNULL(cfv.source_deal_header_id, -1) = ISNULL(@source_deal_header_id, -1)
					AND ISNULL(cfv.deal_id, -1) = ISNULL(@source_deal_detail_id, -1)
					AND civv.as_of_date = @new_as_of_date
					AND ISNULL([hour], 0) =  @he
			)T1, 
			(
				SELECT SUM(value)  [value]
				FROM Calc_invoice_Volume_variance civv
				INNER JOIN calc_formula_value cfv ON cfv.calc_id = civv.calc_id			  
				where
					ISNULL(cfv.counterparty_id, '') = ISNULL(@counterparty_id, '')  
					AND ISNULL(cfv.contract_id, '') = ISNULL(@contract_id, '')
					AND ISNULL(cfv.invoice_line_item_id, '') = ISNULL(@invoice_line_item_id, '')
					AND cfv.prod_date = @prod_date
					AND cfv.seq_number = @seq_number 
					AND ISNULL(cfv.formula_id, '') = ISNULL(@formula_id, '')
					AND ISNULL(cfv.source_deal_header_id, -1) = ISNULL(@source_deal_header_id, -1)
					AND ISNULL(cfv.deal_id, -1) = ISNULL(@source_deal_detail_id, -1)
					AND civv.as_of_date = @as_of_date
					AND ISNULL([hour], 0) =  @he
			)T2
						
	RETURN @value
END