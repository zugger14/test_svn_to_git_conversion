
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_invoice_detail]') AND type IN (N'P' ,N'PC' ))
	DROP PROCEDURE [dbo].[spa_invoice_detail]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--spa_invoice_detail 's',9
--spa_invoice_detail 'e',null,88
CREATE PROCEDURE [dbo].[spa_invoice_detail] @flag CHAR(1)
	,@invoice_id INT                   = NULL
	,@counterparty_id INT              = NULL 
	,@prod_date DATETIME		   = NULL
	,@contract_id INT                  = NULL
	,@invoice_ref_no VARCHAR(200)      = NULL
	,@invoice_line_item_id INT         = NULL
	,@invoice_amount FLOAT             = NULL
	,@invoice_date DATETIME            = NULL
	,@short_text VARCHAR(200)          = NULL
	,@invoice_description VARCHAR(500) = NULL
	,@invoice_detail_id INT            = NULL

AS
DECLARE @sql_stmt VARCHAR(5000)

IF @flag = 's'
BEGIN
	SELECT Invoice_detail_id ,invoice_line_item_id value_id  ,invoice_amount
	FROM invoice_detail i
	JOIN static_data_value sd ON i.invoice_line_item_id = sd.value_id
	WHERE invoice_id = @invoice_id
END

IF @flag = 'e' --For Generating Invoice Item  Name  by counterparty id
BEGIN
    SELECT DISTINCT - 1 AS Invoice_detail_id ,sd.value_id ,sd.description + '(' + sd.code + ')' [Item Name] ,NULL invoice_amount ,cgd.formula_id ,cgd.price
    FROM calc_invoice_volume_variance civv
    LEFT JOIN contract_group cg ON cg.contract_id = civv.contract_id
    LEFT JOIN contract_group_detail cgd ON cgd.contract_id = cg.contract_id
            AND cgd.prod_type = CASE  WHEN ISNULL(cg.term_start, '') = '' THEN 'p' WHEN dbo.fnagetcontractmonth(cg.term_start) <= dbo.fnagetcontractmonth(@prod_date) THEN 'p'    ELSE 't' END
    LEFT JOIN contract_charge_type cct ON cct.contract_charge_type_id = cg.contract_charge_type_id
    LEFT JOIN contract_charge_type_detail cctd ON cctd.contract_charge_type_id = cct.contract_charge_type_id
            AND cctd.prod_type = CASE  WHEN ISNULL(cg.term_start, '') = '' THEN 'p' WHEN dbo.fnagetcontractmonth(cg.term_start) <= dbo.fnagetcontractmonth(@prod_date) THEN 'p' ELSE 't' END
    LEFT JOIN static_data_value sd ON sd.value_id = ISNULL(cgd.invoice_line_item_id, cctd.invoice_line_item_id)
    WHERE 1 = 1
            AND civv.counterparty_id = @counterparty_id AND civv.contract_id = @contract_id
            --AND civv.prod_date=@prod_dat

END

IF @flag = 'm' --For Generating Invoice Item  For manual Entry
BEGIN
	SELECT - 1 AS Invoice_detail_id ,sd.value_id ,sd.description + '(' + sd.code + ')' [Item Name] ,NULL [Invoice Amount], cd.formula_id, cd.price
	FROM rec_generator r
	JOIN contract_group c ON r.ppa_contract_id = c.contract_id
	JOIN contract_group_detail cd 	ON c.contract_id = cd.contract_id
	JOIN static_data_value sd ON sd.value_id = cd.invoice_line_item_id
	WHERE ( cd.price IS NULL AND cd.formula_id IS NULL )
        AND r.ppa_counterparty_id = @counterparty_id
END

IF @flag = 'x'
BEGIN
    SELECT i.invoice_id [Invoice ID],
           i.invoice_ref_no [Invoice Ref ID],
           DBO.FNADateformat(i.invoice_date) [Invoice Date],
           sd.description + '(' + sd.code + ')' [Charge Type],
           i.invoice_amount [Invoice Amount],
           i.short_text [Short Text],
           i.invoice_description [Description],
           sd.value_id,
           i.invoice_detail_id
    FROM   invoice_detail i
           JOIN static_data_value sd
                ON  i.invoice_line_item_id = sd.value_id

            WHERE 1= 1 AND i.invoice_id = @invoice_id
END

IF @flag = 'i'
BEGIN
BEGIN try
    INSERT INTO invoice_detail
      (
        invoice_id,
        invoice_line_item_id,
        invoice_ref_no,
        invoice_amount,
        invoice_date,
        short_text,
        invoice_description
      )
    VALUES
      (
        @invoice_id,
        @invoice_line_item_id,
        @invoice_ref_no,
        @invoice_amount,
        @invoice_date,
        @short_text,
        @invoice_description
      )
      EXEC spa_ErrorHandler 0
                , 'invoice_detail'
                , 'spa_invoice_detail'
                , 'Success' 
                , 'Successfully saved data.'
                , ''
END TRY
BEGIN CATCH	
	DECLARE @DESC VARCHAR(500)
	DECLARE @err_no INT 
        IF @@TRANCOUNT > 0
           ROLLBACK

        SET @DESC = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'

        SELECT @err_no = ERROR_NUMBER()

        EXEC spa_ErrorHandler @err_no
           , 'invoice_detail'
           , 'spa_invoice_detail'
           , 'Error'
           , @DESC
           , ''
END CATCH	 
END

IF @flag = 'u'
BEGIN
        BEGIN TRY
    UPDATE  invoice_detail
      SET
        invoice_id =  @invoice_id,
        invoice_line_item_id = @invoice_line_item_id,
        invoice_ref_no = @invoice_ref_no,
        invoice_amount = @invoice_amount,
        invoice_date = @invoice_date,
        short_text = @short_text,
        invoice_description = @invoice_description
    WHERE invoice_id = @invoice_id AND invoice_detail_id= @invoice_detail_id

     EXEC spa_ErrorHandler 0
                , 'invoice_detail'
                , 'spa_invoice_detail'
                , 'Success' 
                , 'Successfully saved data.'
                , ''
END TRY
BEGIN CATCH	 
        IF @@TRANCOUNT > 0
           ROLLBACK

        SET @DESC = 'Fail to update Data ( Errr Description:' + ERROR_MESSAGE() + ').'

        SELECT @err_no = ERROR_NUMBER()

        EXEC spa_ErrorHandler @err_no
           , 'invoice_detail'
           , 'spa_invoice_detail'
           , 'Error'
           , @DESC
           , ''
END CATCH	 
        END

IF @flag = 'd'
BEGIN
   DELETE FROM invoice_detail
    WHERE invoice_id = @invoice_id AND invoice_detail_id= @invoice_detail_id

END

IF @flag = 'a'
BEGIN
  SELECT invoice_line_item_id,
         invoice_amount,
         DBO.FNAGetSQLStandardDate(invoice_date) [Invoice Date],
         invoice_ref_no,
         short_text,
         invoice_description
  FROM   invoice_detail
  WHERE  invoice_detail_id = @invoice_detail_id

END

