/****** Object:  StoredPROCEDURE [dbo].[spa_get_calc_invoice_volume]    Script Date: 09/14/2009 17:02:23 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_get_calc_invoice_volume]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_get_calc_invoice_volume]/****** Object:  StoredPROCEDURE [dbo].[spa_get_calc_invoice_volume]    Script Date: 09/14/2009 17:02:00 ******/
IF object_id('#temp_nest_status') IS NOT NULL
	DROP TABLE adiha_process.dbo.price_cuve_name

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spa_get_calc_invoice_volume]
	@flag VARCHAR(1)=null, 
	@counterparty_id INT=null,
	@contract_id INT=null,
	@prod_date DATETIME=null,
	@as_of_date DATETIME=null,
	@sub_id INT =null,
	@calc_id VARCHAR(MAX)=null,
	@delete_option CHAR(1)=null, -- 'a'- delete all as_of_date, 's' - delete selected as_of_date	
	@estimate_calculation CHAR(1)='n',
	@cpt_type CHAR(1) = NULL,
	@invoice_type CHAR(1) = NULL,
	@remittance_invoice_status INT = NULL,
	@invoice_number INT = NULL,
	@as_of_date_to DATETIME = NULL,
	@invoice_remmit_type CHAR(1) = NULL,
	@process_table_name VARCHAR(150) = NULL
AS

	DECLARE @table_calc_invoice_volume_variance VARCHAR(50)
	DECLARE @table_calc_invoice_volume_recorder VARCHAR(50)
	DECLARE @table_calc_invoice_volume VARCHAR(50)
	DECLARE @table_calc_formula_value VARCHAR(50)
	DECLARE @sql VARCHAR(5000)
	DECLARE @DESC VARCHAR(5000)
	DECLARE @err_no INT
	

	IF @estimate_calculation='y'
		BEGIN
			SET @table_calc_invoice_volume_variance = 'calc_invoice_volume_variance_estimates'
			SET @table_calc_invoice_volume_recorder = 'calc_invoice_volume_recorder_estimates'
			SET @table_calc_invoice_volume = 'calc_invoice_volume_estimates'
			SET @table_calc_formula_value = 'calc_formula_value_estimates'
		END
	ELSE
		BEGIN
			SET @table_calc_invoice_volume_variance = 'calc_invoice_volume_variance'
			SET @table_calc_invoice_volume_recorder = 'calc_invoice_volume_recorder'
			SET @table_calc_invoice_volume = 'calc_invoice_volume'
			SET @table_calc_formula_value = 'calc_formula_value'
		END

	IF @flag='a' -- SELECT values FROM calc_invoice_volume_variance table
	BEGIN
		SET @sql='
			SELECT 
				civ.contract_id,
				counterparty_name,
				NULL as RecorderID,
				dbo.FNADateFormat(civ.prod_date) [Production Month],
				round(MAX(metervolume),0) [Meter Volume],
				round(MAX(invoicevolume),0) [Invoice Volume],
				round(MAX(allocationvolume),0) [Allocated Volume],
				MAX(variance) as [Variance],
				MAX(uom_name) as UOM,
				MAX(CASE WHEN actualvolume=''y'' then ''Actual'' else ''Estimated'' end) as [Volume Type],
				MAX(book_entries),
				dbo.FNADateformat(civ.prod_date),
				dbo.FNADateformat(civ.as_of_date),
				ISNULL(ng.netting_group_name,cg.contract_name),
				civ.calc_id,
				civ.deal_id,
				civ.invoice_type AS [invoice_type],
				MAX(civ.sub_id) sub_id,
				MAX(cg.[type]) contract_invoice_type,
				civ.netting_group_id,
				MAX(civ_status.status) [calc_status]
			FROM 
					'+@table_calc_invoice_volume_variance+' civ
					LEFT JOIN contract_group cg on civ.contract_id=cg.contract_id	
					LEFT JOIN source_uom su on su.source_uom_id=civ.uom
					LEFT JOIN source_counterparty sc on sc.source_counterparty_id=civ.counterparty_id
					LEFT OUTER JOIN calc_Invoice_volume cv on cv.calc_id=civ.calc_id
					LEFT JOIN netting_group ng ON ng.netting_group_id=civ.netting_group_id
					CROSS APPLY(SELECT MAX(status) status,MAX(finalized) finalized FROM calc_invoice_volume WHERE calc_id = civ.calc_id)civ_status
			WHERE
					civ.counterparty_id='+CAST(@counterparty_id AS VARCHAR)+'
					and civ.prod_date='''+CAST(@prod_date AS VARCHAR)+'''
					and (civ.as_of_date)=('''+CAST(@as_of_date AS VARCHAR)+''')'
					+case when @contract_id IS not null then ' AND civ.contract_id='+CAST(@contract_id as varchar) else '' end+ 
					+case when @invoice_type IS not null then ' AND civ.invoice_type='''+@invoice_type+'''' else '' end+ ' 
			GROUP BY 
					civ.contract_id,counterparty_name,dbo.FNADateformat(civ.prod_date),dbo.FNADateformat(civ.as_of_date),ISNULL(ng.netting_group_name,cg.contract_name),civ.calc_id,
					civ.deal_id,civ.[invoice_type],civ.netting_group_id'
		
		EXEC(@sql)
	END
	ELSE IF @flag='f' -- check to see IF finalize
	BEGIN
		SET @sql='
			SELECT
				ISNULL(civ.finalized,''n'')	as finalized
				
			FROM
				'+@table_calc_invoice_volume_variance+' civ inner join contract_group cg on
				civ.contract_id=cg.contract_id LEFT JOIN
				invoice_header ih on ih.invoice_id=civ.invoice_id
				WHERE  civ.counterparty_id='+CAST(@counterparty_id AS VARCHAR)+' and
				dbo.FNAGetContractMonth(civ.prod_date)=dbo.FNAGetContractMonth('''+CAST(@prod_date AS VARCHAR)+''')
				and (civ.as_of_date)=('''+CAST(@as_of_date AS VARCHAR)+''')'
		
		EXEC(@sql)
	END	
	ELSE IF @flag='e' -- find out esimated invoice
	BEGIN
		SET @sql=
		'
		SELECT DISTINCT
			civ.calc_id [ID],			
			sc.source_counterparty_id as [Counterparty ID],
			civ.invoice_number [Invoice No],
			counterparty_name '+CASE WHEN @cpt_type = 'm' THEN '[Model Group]' ELSE 'Counterparty' END +',
			ISNULL(ng.netting_group_name,contract_name) '+CASE WHEN @cpt_type = 'm' THEN '[Model]' ELSE 'Contract' END +',
			dbo.FNADateFormat(civ.prod_date) '+CASE WHEN @cpt_type = 'm' THEN '[ Month]' ELSE ' [Production Month From]' END +',
			dbo.FNADateFormat(civ.prod_date_to) '+CASE WHEN @cpt_type = 'm' THEN '[ Month]' ELSE ' [Production Month To]' END +',
			dbo.FNADateFormat(civ.settlement_date) '+CASE WHEN @cpt_type = 'm' THEN '[ Month]' ELSE ' [Settlement Date]' END +',
			dbo.FNADateFormat(civ.as_of_date) [As of Date],
			CASE WHEN civ.invoice_type =''i'' THEN ''Invoice'' WHEN civ.invoice_type =''r'' THEN ''Remittance'' END [Invoice Type],
			sdv.[description] AS [Invoice Status],
			CASE WHEN [status] = ''v'' THEN ''Voided'' WHEN ISNULL(civ_status.finalized,''n'')=''y'' THEN ''Final'' ELSE ''Initial'' END [CalcStatus],
			CASE WHEN ISNULL(civ.invoice_lock,''n'')=''y'' THEN ''Locked'' ELSE '''' END AS [Invoice Lock Status],
			civ.contract_id AS [Contact ID]
			--,civ.invoice_type
		FROM 
			'+@table_calc_invoice_volume_variance+' civ
			LEFT JOIN source_uom su on su.source_uom_id=civ.uom
			LEFT JOIN source_counterparty sc on sc.source_counterparty_id=civ.counterparty_id
			LEFT JOIN contract_group cg on cg.contract_id=civ.contract_id
			CROSS APPLY(SELECT MAX(status) status,MAX(finalized) finalized,MAX(calc_id) calc_id FROM calc_invoice_volume WHERE calc_id = civ.calc_id)civ_status
			LEFT JOIN static_data_value sdv ON sdv.value_id = civ.invoice_status
			LEFT JOIN netting_group ng ON ng.netting_group_id=civ.netting_group_id
			WHERE 1=1 AND civ_status.calc_id IS NOT NULL
			'+
			 CASE WHEN @counterparty_id is not null then ' And civ.counterparty_id='+cast(@counterparty_id as VARCHAR) else '' end
			+CASE WHEN @prod_date is not null then ' And dbo.FNAGETContractmonth(CIV.prod_date)=dbo.FNAGETContractmonth('''+cast(@prod_date as VARCHAR)+''')' else ''  end
			+CASE WHEN @sub_id is not null then ' And civ.sub_id='+cast(@sub_id as VARCHAR) ELSE '' end
			+case when @contract_id IS not null then 'and civ.contract_id='+CAST(@contract_id as varchar) else '' end
			+case when @invoice_type IS not null then ' AND civ.invoice_type='''+@invoice_type+'''' else '' END
			+CASE WHEN @remittance_invoice_status IS NOT NULL THEN ' AND civ.invoice_status='+CAST(@remittance_invoice_status AS VARCHAR) ELSE '' END
			+ CASE WHEN @cpt_type IS NOT NULL THEN ' AND sc.int_ext_flag=''' + @cpt_type + '''' ELSE '' END
			+ CASE WHEN @invoice_number IS NOT NULL THEN ' AND civ.invoice_number=''' + cast(@invoice_number AS VARCHAR(30)) + '''' ELSE '' END
			+CASE WHEN @as_of_date is not null then ' And (CIV.as_of_date)>=('''+cast(@as_of_date as VARCHAR)+''')' else ''  end
			+CASE WHEN @as_of_date_to is not null then ' And (CIV.as_of_date)<=('''+cast(@as_of_date_to as VARCHAR)+''')' else ''  END
			+CASE WHEN @invoice_remmit_type is not null then ' AND civ.invoice_type='''+@invoice_remmit_type+'''' else '' END
		+ ' order by 3,dbo.FNADateFormat(civ.prod_date),dbo.FNADateFormat(civ.as_of_date)'
		EXEC spa_print @sql
		--print @table_calc_invoice_volume_variance
		exec(@sql)
	END

	ELSE IF @flag='v' 
	BEGIN
		SET @sql=
		'
			SELECT 
				civ.calc_id [ID],
				sc.source_counterparty_id as [Counterparty ID],
				counterparty_name Counterparty,
				ISNULL(ng.netting_group_name,contract_name) Contract,
				dbo.FNADateFormat(civ.prod_date) [Production Month],
				dbo.FNADateFormat(civ.as_of_date) [As of Date],
				CASE WHEN civ.invoice_type =''i'' THEN ''Invoice'' WHEN civ.invoice_type =''r'' THEN ''Remittance'' END [InvoiceType],
				round(allocationvolume,0) [Volume],
				uom_name as UOM,
				civ.contract_id
				
			FROM 
				'+@table_calc_invoice_volume_variance+' civ
				LEFT JOIN source_uom su on su.source_uom_id=civ.uom
				LEFT JOIN source_counterparty sc on sc.source_counterparty_id=civ.counterparty_id
				LEFT JOIN contract_group cg on cg.contract_id=civ.contract_id
				LEFT JOIN rec_generator rg on rg.ppa_counterparty_id=civ.counterparty_id
				LEFT JOIN netting_group ng ON ng.netting_group_id=civ.netting_group_id
				WHERE 1=1'+
				 CASE WHEN @counterparty_id is not null then ' And civ.counterparty_id='+cast(@counterparty_id as VARCHAR) else '' end
				+ CASE WHEN @prod_date is not null then ' And dbo.FNAGETContractmonth(CIV.prod_date)=dbo.FNAGETContractmonth('''+cast(@prod_date as VARCHAR)+''')' else ''  end
				+ CASE WHEN @as_of_date is not null then ' And (CIV.as_of_date)>=('''+cast(@as_of_date as VARCHAR)+''')' else ''  end
				+ CASE WHEN @as_of_date_to is not null then ' And (CIV.as_of_date)<=('''+cast(@as_of_date_to as VARCHAR)+''')' else ''  end
				+ CASE WHEN @sub_id is not null then ' And rg.legal_entity_value_id='+cast(@sub_id as VARCHAR) ELSE '' END
				+ CASE WHEN @cpt_type is not null then ' AND sc.int_ext_flag = ''' + @cpt_type + '''' ELSE '' END
				+ CASE WHEN @contract_id IS NOT NULL THEN 'AND civ.contract_id=' + CAST(@contract_id AS VARCHAR) ELSE '' END
				+ ' and civ.finalized=''y'' order by counterparty_name,civ.prod_date,civ.as_of_date'
			--PRINT @table_calc_invoice_volume_variance
		EXEC(@sql)
	END

	ELSE IF @flag='d' -- delete calculated data
	BEGIN
		DECLARE @invoice_id INT
		DECLARE @xcel_sub_id INT

		SET @xcel_sub_id=-1

		--SELECT @counterparty_id=counterparty_id,@as_of_date=as_of_date,@prod_date=prod_date,@contract_id=contract_id FROM calc_invoice_volume_variance WHERE calc_id IN(@calc_id)
		SELECT @sub_id=max(legal_entity_value_id) FROM 	rec_generator WHERE ppa_counterparty_id=@counterparty_id

		IF exists(SELECT * FROM close_measurement_books WHERE 
			(as_of_date)=(@as_of_date) and (sub_id=@sub_id or sub_id=@xcel_sub_id))
		BEGIN
				
			Exec spa_ErrorHandler 1, "Accounting Book already Closed for the Accounting Period ", 
					"spa_calc_invoice_volume_input", "DB Error", 
					"Accounting Book already Closed for Accounting Period", ''

			RETURN
		END

		-- Check if calculation is already finalized

			IF exists(SELECT * FROM calc_invoice_volume_variance WHERE calc_id IN(SELECT item from dbo.SplitCommaSeperatedValues(@calc_id)) and isnull(finalized,'n')='y')
			BEGIN			
				Exec spa_ErrorHandler 1, 'Settelement already finalized for the counterparty for the selected Production Month.', 
					'spa_calc_invoice_volume_input', '"Error"', 
					'Settelemnet already finalized for the counterparty for the selected Production Month.', ''
					
			RETURN				
			END 
			
			IF exists(SELECT * FROM calc_invoice_volume_variance WHERE calc_id IN(SELECT item from dbo.SplitCommaSeperatedValues(@calc_id)) and isnull(invoice_lock,'n')='y')
			BEGIN			
				Exec spa_ErrorHandler 1, 'Settelement Invoice Locked for the counterparty for the selected Production Month.', 
					'spa_calc_invoice_volume_input', '"Error"', 
					'Settelement Invoice Locked for the counterparty for the selected Production Month.', ''
					
			RETURN				
			END 
			
		BEGIN TRAN

			EXEC('update calc_invoice_volume_variance SET finalized=''n'' WHERE calc_id IN('+@calc_id+')')			
	
			EXEC('DELETE id
				FROM 
				invoice_detail id
				INNER JOIN invoice_header ih ON id.invoice_id = ih.invoice_id
				INNER JOIN '+@table_calc_invoice_volume_variance+' civv ON ih.counterparty_id=civv.counterparty_id
					AND ih.Production_month=civv.prod_date	
					AND ih.contract_id=civv.contract_id
				CROSS APPLY(SELECT MAX(status) status,MAX(finalized) finalized FROM calc_invoice_volume WHERE calc_id = civv.calc_id)civ_status
								WHERE ISNULL(civ_status.[status],'''')<>''v'' AND civv.calc_id IN('+@calc_id+')')
				
			EXEC('DELETE ih
				FROM 
				invoice_header ih
				INNER JOIN '+@table_calc_invoice_volume_variance+' civv ON ih.counterparty_id=civv.counterparty_id
					AND ih.contract_id=civv.contract_id
					AND ih.Production_month=civv.prod_date
				CROSS APPLY(SELECT MAX(status) status,MAX(finalized) finalized FROM calc_invoice_volume WHERE calc_id = civv.calc_id)civ_status
				WHERE ISNULL(civ_status.[status],'''')<>''v'' AND civv.calc_id IN('+@calc_id+')')

			EXEC('DELETE icr
				FROM invoice_cash_received icr INNER JOIN '+@table_calc_invoice_volume+' a ON icr.save_invoice_detail_id=a.calc_detail_id WHERE a.calc_id IN('+@calc_id+')')
		

			EXEC('DELETE a
				FROM '+@table_calc_invoice_volume_variance+' a	WHERE 	a.calc_id IN('+@calc_id+')')

			EXEC('DELETE a
				FROM '+@table_calc_invoice_volume+' a LEFT JOIN '+@table_calc_invoice_volume_variance+' b ON a.calc_id=b.calc_id WHERE b.calc_id IS NULL')

			EXEC('DELETE a
				FROM '+@table_calc_formula_value+' a LEFT JOIN '+@table_calc_invoice_volume_variance+' b ON a.calc_id=b.calc_id WHERE b.calc_id IS NULL')

			 -- Delete from TrueUp month
			 EXEC ('DELETE FROM calc_invoice_true_up WHERE calc_id IN (' + @calc_id + ')')
						
			IF @@ERROR <> 0
				BEGIN	
					Exec spa_ErrorHandler @@ERROR, "Invoice Maintain", 
						"spa_invoice_header", "DB Error", 
					"Error on delete invoice.", ''
					RollBACK TRAN
				END	
			ELSE
				EXEC('DELETE a FROM settlement_adjustments a WHERE a.calc_id IN('+@calc_id+')')

				IF @@ERROR<>0
				BEGIN
					Exec spa_ErrorHandler @@ERROR, "Invoice MaINTain", 
						"spa_invoice_header", "DB Error", 
					"Error on delete invoice.", ''
					RollBACK TRAN
				END
				ELSE
				BEGIN
					BEGIN
						Exec spa_ErrorHandler 0, 'Invoice MaINTain', 
								'spa_invoice_header', 'Success', 
								'Invoice successfully deleted.', ''
					COMMIT TRAN
					END
				END
			
	END

	ELSE IF @flag='t' -- Check if settlement is already finalized
	BEGIN
	
	SET @sql ='
		IF exists(SELECT * FROM calc_invoice_volume_variance WHERE 
		calc_id IN('+@calc_id+') and isnull(finalized,''n'')=''y'')
		
			Exec spa_ErrorHandler 0, ''Invoice Maintain'', 
				''spa_calc_invoice_volume_input'', ''Error'', 
				''Settelemnet already finalized for the counterparty for the selected Production Month. '', ''''

		else
			Exec spa_ErrorHandler 0, ''Invoice MaINTain'', 
						''spa_get_calc_invoice_volume'', ''Success'', 
						''Invoice not finalized.'', '''''
	EXEC(@sql)					
		
	end

	ELSE IF @flag='r' -- show variance report for each counterparty
	BEGIN
		SET @sql='
		SELECT
			NULL AS recorderid,
			sc.counterparty_name Counterparty,
			dbo.FNADateFormat(prod_date) [Production Month],
			round(civv.metervolume,0) [Meter Volume],
			CASE WHEN book_entries=''i'' then round(civv.invoicevolume,0) else NULL end as [Invoice Volume],
			((civv.allocationvolume/CASE WHEN civv.metervolume=0 then 1 else civv.metervolume end)
			*(100.00)) as [Allocation %],
			round(civv.allocationvolume,0) [Allocated Volume],
			abs(round(((round(civv.allocationvolume,0)-round(civv.invoicevolume,0))/NULLIF(CASE WHEN (round(civv.allocationvolume,0)-round(civv.invoicevolume,0))<1 then round(CASE WHEN civv.allocationvolume=0 then 1 else civv.allocationvolume end,0) else (round(CASE WHEN civv.invoicevolume=0 then 1 else civv.invoicevolume end,0)) end,0))*100,2)) as  [Variance %],
			uom_name as UOM,
			CASE WHEN actualvolume=''y'' then ''Actual'' else ''Estimated'' end as [Volume Type]
		FROM 
			'+@table_calc_invoice_volume_variance+' civv
			INNER JOIN '+@table_calc_invoice_volume_recorder+' civ ON civv.calc_id=civ.calc_id
			LEFT JOIN source_uom su on su.source_uom_id=civv.uom
			LEFT JOIN source_counterparty sc on sc.source_counterparty_id=civv.counterparty_id
		WHERE 1=1 
			AND civv.counterparty_id='+CAST(@counterparty_id AS VARCHAR)+'
			AND dbo.FNAGETContractmonth(prod_date)=dbo.FNAGETContractmonth('''+CAST(@prod_date AS VARCHAR)+''')
			AND (as_of_date)=('''+CAST(@as_of_date AS VARCHAR)+''')
			ORDER BY sc.counterparty_name'
		EXEC(@sql)
	END
	ELSE IF @flag='c' -- show the contract list drop down
	BEGIN

	SELECT DISTINCT civv.contract_id,ISNULL(ng.netting_group_name,cg.contract_name) + ' - '+ CASE WHEN civv.invoice_type= 'i' THEN 'Inv' ELSE 'Rem' END,civv.invoice_type invoice_type
		FROM 
			calc_invoice_volume_variance civv
			LEFT JOIN contract_group cg ON cg.contract_id = civv.contract_id
			LEFT JOIN netting_group ng ON ng.netting_group_id = civv.netting_group_id
		WHERE	
			civv.counterparty_id = @counterparty_id    
			AND civv.prod_date = @prod_date
			AND civv.as_of_date = @as_of_date
	END
	
	ELSE IF @flag='x'
	BEGIN TRY
		IF @process_table_name IS NOT NULL
		BEGIN
			DECLARE @strQuery VARCHAR(1000)
			
			IF OBJECT_ID('tempdb..#temp_calc_invoice_id') IS NOT NULL
			DROP TABLE #temp_calc_invoice_id
			
			CREATE TABLE #temp_calc_invoice_id (calc_id INT)
			SET @strQuery = 'insert into #temp_calc_invoice_id (calc_id) select calc_id from ' + @process_table_name
			EXEC(@strQuery)
			SELECT @calc_id = COALESCE(@calc_id + ', ' , '') + cast(calc_id AS VARCHAR(20)) FROM #temp_calc_invoice_id
		END		
			UPDATE  civv
			SET civv.invoice_status = @remittance_invoice_status
			FROM Calc_invoice_Volume_variance civv
				 INNER JOIN (SELECT item FROM dbo.SplitCommaSeperatedValues(@calc_id) WHERE [item]>0) tmp ON tmp.item = civv.calc_id			
	
			
			UPDATE  civv
			SET civv.status_id = @remittance_invoice_status
			FROM counterpartyt_netting_stmt_status civv
				 INNER JOIN (SELECT item FROM dbo.SplitCommaSeperatedValues(@calc_id) WHERE [item]<0) tmp ON tmp.item = civv.calc_id			
	
			INSERT INTO counterpartyt_netting_stmt_status(calc_id, status_id) 
			SELECT [item],@remittance_invoice_status
			FROM
				(SELECT item FROM dbo.SplitCommaSeperatedValues(@calc_id) WHERE [item]<0) tmp
				LEFT JOIN counterpartyt_netting_stmt_status civv ON civv.calc_id = tmp.item
			WHERE civv.calc_id IS NULL
			
			-- alert call
			DECLARE @alert_process_table VARCHAR(300)
			DECLARE @process_id VARCHAR(300)
			
			SET @process_id = ISNULL(@process_id, dbo.FNAGetNewID())
			SET @alert_process_table = 'adiha_process.dbo.alert_invoice_' + @process_id + '_ai'

			exec spa_print 'CREATE TABLE ', @alert_process_table, '(calc_id INT NOT NULL, invoice_number INT NOT NULL, invoice_status INT NOT NULL)'
			EXEC('CREATE TABLE ' + @alert_process_table + ' (
			      	calc_id         INT NOT NULL,
			      	invoice_number  INT NOT NULL,
			      	invoice_status  INT NOT NULL,
			      	hyperlink1             VARCHAR(5000),
		      		hyperlink2             VARCHAR(5000),
		      		hyperlink3             VARCHAR(5000),
		      		hyperlink4             VARCHAR(5000),
		      		hyperlink5             VARCHAR(5000)
			      )')
			SET @sql = 'INSERT INTO ' + @alert_process_table + '(calc_id, invoice_number, invoice_status) 
						SELECT civv.calc_id,
							   civv.invoice_number,
							   civv.invoice_status
						FROM  calc_invoice_volume_variance civv 
						INNER JOIN (SELECT item FROM dbo.SplitCommaSeperatedValues(''' + @calc_id + ''') WHERE [item]>0) tmp ON tmp.item = civv.calc_id ' 
			exec spa_print @sql
			EXEC(@sql)		
			EXEC spa_register_event 20605, 20512, @alert_process_table, 0, @process_id
			
			EXEC spa_ErrorHandler 0,
				 'Calc_invoice_Volume_variance',
				 'spa_get_calc_invoice_volume',
				 'Success',
				 'Invoice status has been successfully updated',
				 ''

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK

		SET @DESC = 'Fail Invoice Status. ( Error Description:' + ERROR_MESSAGE() + ').'
	 
		SELECT @err_no = ERROR_NUMBER()
	 
		EXEC spa_ErrorHandler -1
			, 'Calc_invoice_Volume_variance'
			, 'spa_get_calc_invoice_volume'
			, 'Invoice status updated.'
			, @DESC
			,''
	END CATCH
	
	ELSE IF @flag = 'p' OR @flag = 'q'
	BEGIN TRY
		DECLARE @is_final CHAR(1)
		SET @is_final = CASE WHEN @flag = 'p' THEN 'y' ELSE 'n' END
		
		SET  @sql = ' UPDATE civ
			          SET finalized = ''' + @is_final + '''
			          FROM Calc_Invoice_Volume civ
			          INNER JOIN calc_invoice_volume_variance civv ON  civ.calc_id = civv.calc_id
					'
						
		IF @process_table_name IS NOT NULL
			SET  @sql = @sql +  ' INNER JOIN '+ @process_table_name + ' tmp ON  tmp.calc_id = civ.calc_id '
		ELSE 
			SET @sql = @sql + 'INNER JOIN dbo.SplitCommaSeperatedValues(''' + @calc_id + ''') tmp ON tmp.item = civ.calc_id	'
			
		exec spa_print @sql
		EXEC (@sql)
			
		SET @sql = 'UPDATE civv
					SET finalized = ''' + @is_final + '''
					FROM Calc_Invoice_Volume_variance civv
					'			
		IF @process_table_name IS NOT NULL
			SET  @sql = @sql +  ' INNER JOIN '+ @process_table_name + ' tmp ON  tmp.calc_id = civv.calc_id '
		ELSE 
			SET @sql = @sql + ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @calc_id + ''') tmp ON tmp.item = civv.calc_id	'
			
			
		exec spa_print @sql
		EXEC (@sql)
		
		EXEC spa_ErrorHandler 0,
				 'Calc_invoice_Volume_variance,Calc_invoice_Volume',
				 'spa_get_calc_invoice_volume',
				 'Success',
				 'Calc status has been successfully Changed',
				 ''
	END	TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK

		SET @DESC = 'Fail Calc Status. ( Error Description:' + ERROR_MESSAGE() + ').'
	 
		SELECT @err_no = ERROR_NUMBER()
	 
		EXEC spa_ErrorHandler -1
			, 'Calc_invoice_Volume_variance,Calc_invoice_Volume'
			, 'spa_get_calc_invoice_volume'
			, 'Calc status  Changed.'
			, @DESC
			,''
	END CATCH
	
	ELSE
	BEGIN

---- to display in variance report 
	SET @sql='
		SELECT 
			sc.counterparty_name Counterparty,
			dbo.FNADateFormat(civv.prod_date) [Production Month],
			round(civv.metervolume,0) [Meter Volume],
			CASE WHEN civv.book_entries=''i'' then round(civv.invoicevolume,2) else NULL end as [Invoice Volume],
			round((civv.allocationvolume/CASE WHEN civv.metervolume=0 then 1 else civv.metervolume end)
			*(100),0) as [Allocation %],
			round(civv.allocationvolume,0) [Allocated Volume],
			NULL as [Variance %],
			uom_name as UOM,
			CASE WHEN ISNULL(civv.estimated,''n'')=''n'' then ''Actual'' else ''Estimated'' end as [Volume Type]
		FROM 
			'+@table_calc_invoice_volume_variance+'  civv
			LEFT JOIN source_uom su on su.source_uom_id=civv.uom
			LEFT JOIN source_counterparty sc on sc.source_counterparty_id=civv.counterparty_id
		WHERE 1=1 and
			civv.counterparty_id='+CAST(@counterparty_id AS VARCHAR)+' and
			civv.contract_id='+CAST(@contract_id  AS VARCHAR)+' 
			and dbo.FNAGETContractmonth(civv.prod_date)=dbo.FNAGETContractmonth('''+CAST(@prod_date AS VARCHAR)+''')
			and (civv.as_of_date)=('''+CAST(@as_of_date AS VARCHAR)+''')'
			+case when @invoice_type IS not null then ' AND civv.invoice_type='''+@invoice_type+'''' else '' end 		
		EXEC(@sql)

	END