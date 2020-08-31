--/****** Object:  UserDefinedFunction [dbo].[FNARContractValue]    Script Date: 12/13/2010 20:35:30 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARContractValue]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARContractValue]
/****** Object:  UserDefinedFunction [dbo].[FNARContractValue]    Script Date: 12/13/2010 20:35:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function	[dbo].[FNARContractValue](
	@maturity_date datetime,
	@counterparty_id as varchar(50)=null,
	@contract_id as varchar(50),
	@invoice_line_item_id int, 
	@seq_number int,
	@num_month INT,
	@month INT,
	@as_of_date VARCHAR(20),
	@relative_as_of_date INT = NULL --if incase 1, then return the filter as as_of_date else return as it is
	)


RETURNS float As
Begin

--declare @maturity_date datetime,@counterparty_id int,@contract_id int, @invoice_line_item_id int, @seq_number INT, @num_month INT, @month INT , @as_of_date VARCHAR(10), @relative_as_of_date INT

--set @maturity_date='2014-01-01'
--set @counterparty_id=7499
--set @contract_id=378
--set @invoice_line_item_id = 300257
--set @seq_number = 2
--SET @num_month=0
--SET @month = NULL
--SET @as_of_date = '2014-01-31'
--SET @relative_as_of_date = 1

--OR @relative_as_of_date = '0' OR @relative_as_of_date IS NULL

-- compare with the billing cycle given from the contract 
DECLARE @billing_cycle INT 
Declare @contract_start_date DATETIME 

SELECT @billing_cycle = billing_start_month FROM counterparty_contract_address WHERE counterparty_id = @counterparty_id AND contract_id = @contract_id
select @contract_start_date  = dbo.FNAGetContractMonth(contract_start_date) FROM counterparty_contract_address WHERE counterparty_id = @counterparty_id AND contract_id = @contract_id


IF (@billing_cycle IS NULL)
BEGIN
	SELECT @billing_cycle = billing_start_month FROM contract_group WHERE contract_id = @contract_id
END

IF (@contract_start_date IS NULL)
BEGIN
	SELECT @contract_start_date = dbo.FNAGetContractMonth(term_start) FROM contract_group WHERE contract_id = @contract_id
END

--
DECLARE @new_maturity_date DATETIME

IF (@num_month IS NOT NULL)
BEGIN
    --SET @as_of_date = NULL
    SET @new_maturity_date = DATEADD(MONTH,-@num_month, @maturity_date)
	
END
ELSE
BEGIN
	--SET @new_maturity_date = DATEADD(MONTH,((@month + ISNULL(@billing_cycle, 1))-1), @maturity_date)
	SET @new_maturity_date = DATEADD(MONTH, ((@month + ISNULL(@billing_cycle, 1)) - 1) - MONTH(@contract_start_date), @contract_start_date)
	
END

IF (@relative_as_of_date = '0' OR @relative_as_of_date IS NULL)
BEGIN
	SET @as_of_date = NULL
END

IF (@relative_as_of_date = '-1')
BEGIN
	DECLARE @new_as_of_date DATE
	
	SELECT  @new_as_of_date = as_of_date
	FROM calc_invoice_volume_variance civv
	WHERE civv.as_of_date < @as_of_date
	  AND dbo.FNAGetContractMonth(civv.prod_date) = CONVERT(VARCHAR(10), @new_maturity_date, 120)
	  AND civv.contract_id = @contract_id
	  AND civv.counterparty_id = @counterparty_id
	
	IF @new_as_of_date IS NULL
	BEGIN
		RETURN NULL
	END		
	ELSE 
	BEGIN
		SET @as_of_date = @new_as_of_date
	END
	
END
 
 
declare @retValue as float,@retValue1 as float
--- IF the contract component is manual line item, then select the value from calc_invoice_volume

	SELECT @retValue = SUM(value)
	FROM
		calc_invoice_volume civ 
		INNER JOIN calc_invoice_volume_variance civv on civv.calc_id=civ.calc_id
		CROSS APPLY(SELECT MAX(as_of_date) as_of_date, prod_date, counterparty_id,contract_id FROM calc_invoice_volume_variance
			WHERE counterparty_id = civv.counterparty_id AND contract_id = civv.contract_id AND prod_date = civv.prod_date 
			AND as_of_date = ISNULL(@as_of_date, convert(varchar(10), as_of_date, 120))
			GROUP BY prod_date, counterparty_id,contract_id
		) civv1
	WHERE
		civv.as_of_date = civv1.as_of_date
		AND civ.invoice_line_item_id = @invoice_line_item_id
		AND dbo.FNAGetContractMonth(civv.prod_date) = CONVERT(VARCHAR(10), @new_maturity_date, 120)
		AND civv.contract_id = @contract_id
		AND civv.counterparty_id = @counterparty_id
		AND ISNULL(manual_input,'n')='y'
	
	SELECT @retValue1 = sum(value)
	FROM 
		calc_formula_value cfv 
		INNER JOIN calc_invoice_volume_variance civv ON civv.calc_id=cfv.calc_id
		CROSS APPLY(SELECT MAX(as_of_date) as_of_date, prod_date, counterparty_id,contract_id FROM calc_invoice_volume_variance
			WHERE counterparty_id = civv.counterparty_id AND contract_id = civv.contract_id AND prod_date = civv.prod_date
			AND as_of_date = ISNULL(@as_of_date,convert(varchar(10), as_of_date, 120))
			GROUP BY prod_date, counterparty_id,contract_id
		) civv1
	WHERE 
		civv.as_of_date = civv1.as_of_date
		AND invoice_line_item_id = @invoice_line_item_id
		AND seq_number = @seq_number
		AND dbo.FNAGetContractMonth(civv.prod_date) = CONVERT(VARCHAR(10), @new_maturity_date, 120)
		AND cfv.contract_id = @contract_id
		AND cfv.counterparty_id = @counterparty_id

--print @retValue
	RETURN   ISNULL(@retValue,0)+ISNULL(@retValue1,0)
END


