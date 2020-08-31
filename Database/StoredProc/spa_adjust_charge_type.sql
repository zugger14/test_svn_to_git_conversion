/****** Object:  StoredProcedure [dbo].[spa_adjust_charge_type]    Script Date: 04/10/2009 17:06:58 ******/
IF EXISTS ( SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_adjust_charge_type]')AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_adjust_charge_type]

/****** Object:  StoredProcedure [dbo].[spa_adjust_charge_type]    Script Date: 04/10/2009 17:07:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_adjust_charge_type] @flag CHAR(1)
	,@calc_id INT
	,@invoice_line_item_id VARCHAR(250)
	,@inv_prod_date VARCHAR(250) = NULL
	,@remarks VARCHAR(100) = NULL
	,@calc_detail_id INT = NULL
AS
DECLARE @sql VARCHAR(5000)

IF NULLIF(@remarks,'') IS NULL
	SET @remarks = 'Prior Period Adj'

IF @flag = 'j'
BEGIN
	BEGIN TRY

		DECLARE @asofdate VARCHAR(20)
		,@prod_date VARCHAR(20)
		,@counterparty_id INT
		,@contract_id INT
		,@calc_id_new INT
		,@max_asofdate VARCHAR(20)
		,@invoice_type CHAR(1)
		,@netting_group_id INT

	SELECT @counterparty_id = counterparty_id
		,@contract_id = contract_id
		,@asofdate = as_of_date
		,@prod_date = prod_date
		,@invoice_type = invoice_type
		,@netting_group_id = netting_group_id
	FROM dbo.Calc_invoice_Volume_variance
	WHERE calc_id = @calc_id

	SELECT @max_asofdate = MAX(as_of_date)
	FROM Calc_invoice_Volume_variance
	WHERE counterparty_id = @counterparty_id
		AND contract_id = @contract_id
		AND prod_date = dbo.fnagetcontractmonth(@inv_prod_date)

	SELECT @calc_id_new = calc_id
	FROM calc_invoice_volume_variance
	WHERE counterparty_id = @counterparty_id
		AND contract_id = @contract_id
		AND as_of_date = @max_asofdate
		AND prod_date = dbo.fnagetcontractmonth(@inv_prod_date)
		AND invoice_type = @invoice_type
		AND ISNULL(netting_group_id, - 1) = ISNULL(@netting_group_id, - 1) 

	IF @calc_id_new IS NULL
	BEGIN
		INSERT INTO dbo.Calc_invoice_Volume_variance (
			as_of_date
			,counterparty_id
			,generator_id
			,contract_id
			,prod_date
			,metervolume
			,invoicevolume
			,allocationvolume
			,variance
			,onpeak_volume
			,offpeak_volume
			,uom
			,actualVolume
			,book_entries
			,finalized
			,invoice_id
			,deal_id
			,create_user
			,create_ts
			,update_user
			,update_ts
			,estimated
			,calculation_time
			,book_id
			,sub_id
			,process_id
			,invoice_type
			,netting_group_id
			,invoice_number
			,settlement_date
			,prod_date_to
			)
		SELECT @inv_prod_date
			,counterparty_id
			,generator_id
			,contract_id
			,dbo.fnagetcontractmonth(@inv_prod_date)
			,metervolume
			,invoicevolume
			,allocationvolume
			,variance
			,onpeak_volume
			,offpeak_volume
			,uom
			,actualVolume
			,book_entries
			,'n'
			,invoice_id
			,deal_id
			,civv.create_user
			,civv.create_ts
			,civv.update_user
			,civv.update_ts
			,estimated
			,calculation_time
			,book_id
			,sub_id
			,process_id
			,invoice_type
			,netting_group_id
			,(inv.last_invoice_number) + 1
			, @inv_prod_date
			, @inv_prod_date

		FROM Calc_invoice_Volume_variance civv
		CROSS JOIN invoice_seed inv
		WHERE calc_id = @calc_id

		IF @@ROWCOUNT > 0
			UPDATE invoice_seed
			SET last_invoice_number = (
					SELECT CAST(MAX(invoice_number) AS INT)
					FROM calc_invoice_volume_variance
					)

		SELECT @calc_id_new = SCOPE_IDENTITY()
	END

	SET @sql = 'INSERT INTO calc_invoice_volume 
		(
			calc_id,
			invoice_line_item_id,
			prod_date,
			value,
			volume,
			manual_input,
			default_gl_id,
			uom_id,
			price_or_formula,
			onpeak_offpeak,
			finalized,
			finalized_id,
			inv_prod_date,
			include_volume,
			default_gl_id_estimate,
			status,
			remarks
		)
		SELECT 
			' + CAST(@calc_id_new AS VARCHAR) + ',
			civ.invoice_line_item_id,
			civ.prod_date,
			isnull(sa.value_diff,0)*(1),
			isnull(sa.volume_diff,0)*(1),
			''y'',
			civ.default_gl_id,
			volume_uom,
			price_or_formula,
			onpeak_offpeak,
			''n'',
			finalized_id,
			''' + @inv_prod_date + ''',
			include_volume,
			ISNULL(ildg.default_gl_id,ildg1.default_gl_id)default_gl_id_estimate, 
			''a'', -- adjust
			''Prior Period Adj''
		FROM 
			calc_invoice_volume civ inner join settlement_adjustments sa on civ.calc_id = sa.calc_id and civ.invoice_line_item_id = sa.invoice_line_item_id
			LEFT JOIN calc_invoice_volume_variance civv ON civv.calc_id=civ.calc_id
			LEFT JOIN contract_group cg ON cg.contract_id = civv.contract_id
			LEFT JOIN invoice_lineitem_default_glcode ildg on ildg.invoice_line_item_id=civ.invoice_line_item_id   
				AND ildg.sub_id=cg.sub_id  
				AND ISNULL(ildg.estimated_actual,''z'')=''e''
			LEFT JOIN invoice_lineitem_default_glcode ildg1 on ildg1.invoice_line_item_id=civ.invoice_line_item_id   
				AND ildg1.sub_id IS NULL
				AND ISNULL(ildg1.estimated_actual,''z'')=''e''				
		WHERE 
			civ.calc_id=' + cast(@calc_id AS VARCHAR) + ' AND civ.invoice_line_item_id in(' + cast(@invoice_line_item_id AS VARCHAR(250)) + ')'

	EXEC (@sql)

	SET @sql = 'Update calc_invoice_volume 
		SET
			status=''a''
			--finalized=''n''
	WHERE 
		calc_id=' + cast(@calc_id_new AS VARCHAR) + ' 
		AND invoice_line_item_id in(' + cast(@invoice_line_item_id AS VARCHAR(250)) + ')'

	EXEC (@sql)

	SET @sql = 'Update civv 
		SET
			civv.invoice_type=civ.inv_type
			
	FROM 
		calc_invoice_volume_variance civv
		CROSS APPLY(SELECT CASE WHEN SUM(value)<0 THEN ''r'' ELSE ''i'' END inv_type FROM calc_invoice_volume where calc_id=civv.calc_id) civ	
	WHERE 
		civv.calc_id=' + cast(@calc_id_new AS VARCHAR)

	EXEC (@sql)
	EXEC spa_ErrorHandler 0,
             'Charges adjusted',
             'spa_adjust_charge_type',
             'Success',
             'Charges adjusted successfully.',
            ''
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler @@ERROR,
             'Charges adjusted',
             'spa_adjust_charge_type',
             'DB Error',
             'Fail to adjusted Charges.',
             ''
	END CATCH      
END
ELSE
	IF @flag = 'd' -- DELETE Adjust History
	BEGIN
		SELECT @invoice_line_item_id = invoice_line_item_id
		FROM calc_invoice_volume
		WHERE calc_detail_id = @calc_detail_id

		DELETE
		FROM calc_invoice_volume
		WHERE calc_detail_id = @calc_detail_id
			AND STATUS = 'a'

		UPDATE calc_invoice_volume
		SET STATUS = NULL
		WHERE calc_id = @calc_id
			AND invoice_line_item_id = @invoice_line_item_id
	END