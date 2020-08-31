IF OBJECT_ID('dbo.spa_invoice_header', 'p') IS NOT NULL
	DROP PROCEDURE dbo.spa_invoice_header
GO

CREATE PROCEDURE dbo.spa_invoice_header @flag CHAR(1)
	,@invoice_id INT = NULL
	,@counterparty_id INT = NULL
	,@invoice_FROM VARCHAR(20) = NULL
	,@invoice_to VARCHAR(20) = NULL
	,@invoice_date VARCHAR(20) = NULL
	,@invoice_ref_no VARCHAR(100) = NULL
	,@invoice_volume FLOAT = NULL
	,@uom_id INT = NULL
	,@as_of_date VARCHAR(20) = NULL
	,@production_month VARCHAR(20) = NULL
	,@status VARCHAR(10) = NULL
	,@onpeak_volume FLOAT = NULL
	,@offpeak_volume FLOAT = NULL
	,@estimate_calculation CHAR(1) = 'n'
	,@cpt_type CHAR(1) = NULL
        ,@contract_id INT = NULL
AS
DECLARE @sql_stmt VARCHAR(5000)
DECLARE @table_calc_invoice_volume_variance VARCHAR(50)
DECLARE @table_calc_invoice_volume VARCHAR(50)
DECLARE @sql VARCHAR(5000)

IF @estimate_calculation = 'y'
BEGIN
	SET @table_calc_invoice_volume_variance = 'calc_invoice_volume_variance_estimates'
	SET @table_calc_invoice_volume = 'calc_invoice_volume_estimates'
END
ELSE
BEGIN
	SET @table_calc_invoice_volume_variance = 'calc_invoice_volume_variance'
	SET @table_calc_invoice_volume = 'calc_invoice_volume'
END

IF @flag = 's'
BEGIN
	SET @sql_stmt = 
		'SELECT ih.invoice_id [Invoice ID],
                d.invoice_ref_no [Ref No],
                c.source_counterparty_id [Counterparty ID],
                cg.contract_id [Contract ID],
                dbo.FNAHyperLinkText(10211010, cg.contract_name, cg.contract_id) Contract,
                c.counterparty_name Counterparty,
                dbo.FNADateFormat(as_of_date) [As of Date],
                dbo.FNADateFormat(production_month) [Prod Month],
                dbo.FNADateFormat(d.invoice_date) [Invoice Date],
                invoice_volume Volume,
                onpeak_volume [Onpeak Volume],
                offpeak_volume [Offpeak Volume],
                u.uom_name UOM,
                CONVERT(VARCHAR(100), CONVERT(MONEY, SUM(invoice_amount)), 1) Amount,
                CASE WHEN STATUS IS NULL OR STATUS = ''n'' THEN ''PENDing'' ELSE ''Paid'' END [Status],
                cg.contract_name
     FROM   invoice_header ih
                INNER JOIN source_counterparty c ON  ih.counterparty_id = c.source_counterparty_id
                LEFT OUTER JOIN source_uom u ON  u.source_uom_id = ih.uom_id
                CROSS APPLY(SELECT SUM(invoice_amount)invoice_amount, MAX(invoice_ref_no) invoice_ref_no, MAX(invoice_date) invoice_date  FROM  invoice_detail  WHERE  invoice_id = ih.invoice_id) d
                LEFT JOIN rec_generator rg ON  rg.ppa_counterparty_id = c.source_counterparty_id
                LEFT JOIN contract_group cg ON  cg.contract_id = ih.contract_id
     WHERE  1 = 1'

	IF @counterparty_id IS NOT NULL
		SET @sql_stmt = @sql_stmt + ' AND ih.counterparty_id=' + CAST(@counterparty_id AS VARCHAR)

	IF @invoice_ref_no IS NOT NULL
		SET @sql_stmt = @sql_stmt + ' AND d.invoice_ref_no like ''' + @invoice_ref_no + '%'''

	IF @invoice_FROM IS NOT NULL
		SET @sql_stmt = @sql_stmt + ' AND d.invoice_date >= ''' + @invoice_FROM + ''''

	IF @invoice_to IS NOT NULL
		SET @sql_stmt = @sql_stmt + ' AND d.invoice_date <= ''' + @invoice_to + ''''

	IF @cpt_type IS NOT NULL
		SET @sql_stmt = @sql_stmt + 'AND c.int_ext_flag = ''' + @cpt_type + ''''

	IF @contract_id IS NOT NULL
	    SET @sql_stmt = @sql_stmt + ' AND ih.contract_id=' + CAST(@contract_id AS VARCHAR)
	    	
	SET @sql_stmt = @sql_stmt + 
	    ' GROUP BY ih.invoice_id,d.invoice_ref_no,c.source_counterparty_id,
                    cg.Contract_id, counterparty_name,d.invoice_date, as_of_date,
                    production_month,invoice_volume,onpeak_volume,offpeak_volume,
                    uom_name,STATUS,cg.contract_name ORDER BY ih.invoice_id DESC'

	EXEC spa_print @sql_stmt

	EXEC (@sql_stmt)
END

IF @flag = 'a'
BEGIN
	SELECT invoice_id
		,MAX(ih.counterparty_id)
		,MAX(dbo.FNADateFormat(invoice_date)) invoice_date
		,MAX(invoice_ref_no)
		,MAX(invoice_volume)
		,MAX(uom_id)
		,MAX(dbo.FNADateFormat(as_of_date)) as_of_date
		,MAX(dbo.FNADateFormat(production_month)) production_month
		,MAX(STATUS)
		,MAX(c.counterparty_name)
		,MAX(onpeak_volume)
		,MAX(offpeak_volume)
		,MAX(cg.contract_id)
		,MAX(cg.contract_name)
	FROM invoice_header ih
	JOIN source_counterparty c
		ON ih.counterparty_id = c.source_counterparty_id
	LEFT JOIN (
		SELECT counterparty_id
			,contract_id
		FROM source_deal_header
		GROUP BY counterparty_id
			,contract_id
		) sdh
		ON sdh.counterparty_id = ih.counterparty_id
	LEFT JOIN rec_generator rg
		ON ISNULL(rg.ppa_counterparty_id, sdh.counterparty_id) = c.source_counterparty_id
	LEFT JOIN contract_group cg
		ON cg.contract_id = ISNULL(rg.ppa_contract_id, sdh.contract_id)
	WHERE ih.invoice_id = @invoice_id
	GROUP BY invoice_id
END

IF @flag = 'e' --For Generating Invoice Item  Name  by counterparty id
BEGIN
	SELECT - 1 AS Invoice_detail_id
		,sd.value_id
		,sd.description + '(' + sd.code + ')' [Item Name]
		,NULL invoice_amount
		,cd.formula_id
		,cd.price
	FROM rec_generator r
	JOIN contract_group c
		ON r.ppa_contract_id = c.contract_id
	JOIN contract_group_detail cd
		ON c.contract_id = cd.contract_id
	JOIN static_data_value sd
		ON sd.value_id = cd.invoice_line_item_id
	WHERE r.ppa_counterparty_id = @counterparty_id
END

IF @flag = 'i'
BEGIN
	BEGIN TRY
		INSERT invoice_header (
			counterparty_id
			,invoice_date
			,invoice_ref_no
			,invoice_volume
			,uom_id
			,as_of_date
			,production_month
			,[status]
			,onpeak_volume
			,offpeak_volume
                        ,contract_id
			)
		VALUES (
			@counterparty_id
			,@invoice_date
			,@invoice_ref_no
			,@invoice_volume
			,@uom_id
			,@as_of_date
			,dbo.FNAGETContractMOnth(@production_month)
			,@status
			,@onpeak_volume
			,@offpeak_volume
                        ,@contract_id
			)
	END TRY

	BEGIN CATCH
		IF @@ERROR <> 0
			EXEC spa_ErrorHandler 0
				,'Invoice Maintain'
				,'spa_invoice_header'
				,'DB Error'
				,'The production month already exists for the given counterparty.'
				,'insert_error'

		RETURN
	END CATCH

	SET @invoice_id = SCOPE_IDENTITY()

	EXEC spa_ErrorHandler 0
		,'Invoice Maintain'
		,'spa_invoice_header'
		,'Success'
		,'Invoice successfully inserted.'
		,@invoice_id
END

IF @flag = 'u'
BEGIN
	BEGIN TRY
	UPDATE invoice_header
	SET invoice_date = @invoice_date
		,invoice_ref_no = @invoice_ref_no
		,invoice_volume = @invoice_volume
		,uom_id = @uom_id
		,as_of_date = @as_of_date
		,STATUS = @status
		,onpeak_volume = @onpeak_volume
		,offpeak_volume = @offpeak_volume
                ,contract_id = @contract_id
	        ,production_month =  dbo.FNAGETContractMOnth(@production_month)
	WHERE   invoice_id = @invoice_id
        END TRY
	BEGIN CATCH
	IF @@ERROR <> 0
	    EXEC spa_ErrorHandler 0,
		         'Invoice Maintain',
		         'spa_invoice_header',
		         'DB Error',
		         'The production month already exists for the given counterparty.',
		         'insert_error'
	     RETURN
	 END CATCH
	    EXEC spa_ErrorHandler 0,
	         'Invoice Maintain',
	         'spa_invoice_header',
	         'Success',
	         'Invoice successfully inserted.',
	         ''
END

IF @flag = 'd'
BEGIN
	EXEC ('DELETE a FROM   ' + @table_calc_invoice_volume + ' a,' + @table_calc_invoice_volume_variance + ' b
           WHERE  a.calc_id = b.calc_id AND b.invoice_id = ' + @invoice_id)

	EXEC ('DELETE a FROM   ' + @table_calc_invoice_volume_variance + ' a
           WHERE  a.invoice_id = ' + @invoice_id)

	DELETE invoice_header
	WHERE invoice_id = @invoice_id

	IF @@ERROR <> 0
		EXEC spa_ErrorHandler @@ERROR
			,'Invoice Maintain'
			,'spa_invoice_header'
			,'DB Error'
			,'Error on delete invoice.'
			,''
	ELSE
		EXEC spa_ErrorHandler 0
			,'Invoice Maintain'
			,'spa_invoice_header'
			,'Success'
			,'Invoice successfully deleted.'
			,''
END

IF @flag = 'c'
BEGIN
	SELECT DISTINCT civv.contract_id, cg.contract_name
	FROM   calc_invoice_volume_variance civv
	       LEFT JOIN contract_group cg ON  cg.contract_id = civv.contract_id
	       LEFT JOIN netting_group ng ON  ng.netting_group_id = civv.netting_group_id
	WHERE  civv.counterparty_id = @counterparty_id
END


