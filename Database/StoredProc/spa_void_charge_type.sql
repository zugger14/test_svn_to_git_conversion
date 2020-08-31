/****** Object:  StoredProcedure [dbo].[spa_void_charge_type]    Script Date: 01/02/2013 15:35:39 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_void_charge_type]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_void_charge_type]
GO

/****** Object:  StoredProcedure [dbo].[spa_void_charge_type]    Script Date: 01/02/2013 15:35:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spa_void_charge_type]
	 @flag CHAR(1)
	,@calc_id INT
	,@invoice_line_item_id VARCHAR(5000)
	,@inv_prod_date VARCHAR(250) = NULL
	,@remarks VARCHAR(100) = NULL
	,@calc_detail_id INT = NULL


As
DECLARE @sql varchar(5000)


if @remarks IS NULL
	SET @remarks=''

IF @flag='v'
BEGIN

		DECLARE @asofdate VARCHAR(20),@prod_date VARCHAR(20),@counterparty_id INT,@contract_id INT,@calc_id_new INT,@invoice_type CHAR(1)
		SELECT @counterparty_id=counterparty_id,@contract_id=contract_id, @asofdate = as_of_date,@prod_date = prod_date,@invoice_type=invoice_type FROM dbo.Calc_invoice_Volume_variance WHERE calc_id =  @calc_id
		SELECT @calc_id_new = calc_id FROM calc_invoice_volume_variance WHERE counterparty_id =@counterparty_id AND contract_id = @contract_id AND as_of_date = @inv_prod_date AND prod_date = @prod_date AND invoice_type=@invoice_type AND @inv_prod_date > @asofdate
	
	IF 	@calc_id_new IS NULL 
		BEGIN
			INSERT INTO dbo.Calc_invoice_Volume_variance
			        ( as_of_date ,
			          counterparty_id ,
			          generator_id ,
			          contract_id ,
			          prod_date ,
			          metervolume ,
			          invoicevolume ,
			          allocationvolume ,
			          variance ,
			          onpeak_volume ,
			          offpeak_volume ,
			          uom ,
			          actualVolume ,
			          book_entries ,
			          finalized ,
			          invoice_id ,
			          deal_id ,
			          create_user ,
			          create_ts ,
			          update_user ,
			          update_ts ,
			          estimated ,
			          calculation_time ,
			          book_id ,
			          sub_id ,
			          process_id,
			          invoice_type,
			          netting_group_id,
			          invoice_number,
			          prod_date_to,
			          settlement_date
			        )
			SELECT 
				      @inv_prod_date,
				      counterparty_id ,
			          generator_id ,
			          contract_id ,
			          prod_date ,
			          metervolume ,
			          invoicevolume ,
			          allocationvolume ,
			          variance ,
			          onpeak_volume ,
			          offpeak_volume ,
			          uom ,
			          actualVolume ,
			          book_entries ,
			          'n' ,
			          invoice_id ,
			          deal_id ,
			          civv.create_user ,
			          civv.create_ts ,
			          civv.update_user ,
			          civv.update_ts ,
			          estimated ,
			          calculation_time ,
			          book_id ,
			          sub_id ,
			          process_id,
			          invoice_type,
			          netting_group_id,
			          inv.last_invoice_number+1,
			          civv.prod_date_to,
			          civv.settlement_date
			   FROM
					 Calc_invoice_Volume_variance civv
					 CROSS JOIN invoice_seed inv	
				WHERE calc_id = @calc_id    
			
				SELECT @calc_id_new = SCOPE_IDENTITY()
						
				UPDATE invoice_seed SET last_invoice_number = (SELECT CAST(MAX(invoice_number) AS INT) FROM calc_invoice_volume_variance) + 1
		END	
	
	SET @sql=
		'INSERT INTO calc_invoice_volume 
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
			'+CAST(@calc_id_new AS VARCHAR)+',
			civ.invoice_line_item_id,
			civ.prod_date,
			(civ.value)*(-1),
			(civ.volume)*(-1),
			''y'',
			civ.default_gl_id,
			civ.uom_id,
			civ.price_or_formula,
			civ.onpeak_offpeak,
			civ.finalized,
			-1,
			civv.prod_date,
			civ.include_volume,
			civ.default_gl_id_estimate, 
			NULL,
			'''+@remarks +'''
		FROM 
			calc_invoice_volume  civ
			INNER JOIN calc_invoice_volume_variance civv ON civv.calc_id = civ.calc_id
			--LEFT JOIN invoice_header ih ON ih.counterparty_id=civv.counterparty_id
			--					AND ih.Production_month=civv.prod_date
			--					AND ih.as_of_date = civv.as_of_date
			--					AND ih.contract_id = civv.contract_id
			--LEFT JOIN invoice_detail id ON id.invoice_id = ih.invoice_id
			--	AND id.invoice_line_item_id = civ.invoice_line_item_id 					
		WHERE 
			civ.calc_id='+cast(@calc_id as varchar)+' AND civ.invoice_line_item_id in('+cast(@invoice_line_item_id as varchar(250))+')'

	--PRINT @sql
	EXEC(@sql)

	SET @sql='Update calc_invoice_volume 
		SET
			status=''v'' 
	WHERE 
		calc_id='+cast(@calc_id_new as varchar)+' 
		AND invoice_line_item_id in('+cast(@invoice_line_item_id as varchar(250))+')'
	EXEC(@sql)
	
	SET @sql='Update calc_invoice_volume_variance 
		SET
			finalized=''n'' 
	WHERE 
		calc_id='+cast(@calc_id as varchar)
	
	EXEC(@sql)

	SET @sql='Update civv
		SET
			civv.invoice_type =  civ.inv_type
		FROM  calc_invoice_volume_variance civv 
			  CROSS APPLY(SELECT CASE WHEN SUM(value)<0 THEN ''r'' ELSE ''i'' END as inv_type FROM calc_invoice_volume WHERE calc_id=civv.calc_id) civ		
	WHERE 
		calc_id='+cast(@calc_id_new as varchar)
	EXEC(@sql)
	
End
ELSE IF @flag='d' -- DELETE Void History
	BEGIN
		select @invoice_line_item_id=invoice_line_item_id from calc_invoice_volume where calc_detail_id=@calc_detail_id
		
			Delete from calc_invoice_volume where calc_detail_id=@calc_detail_id and status='v'

			update calc_invoice_volume 
				set status=NULL 
			where 
				calc_id=@calc_id and
				invoice_line_item_id=@invoice_line_item_id


	END






