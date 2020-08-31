IF EXISTS (SELECT 1 FROM adiha_process.sys.tables WHERE [name] = REPLACE('@_input_table','adiha_process.dbo.',''))
BEGIN
	IF EXISTS(SELECT 1 FROM @_input_table)
	BEGIN
		DECLARE @counterparty_credit_enhancement_id VARCHAR(20),
		        @counterparty_id VARCHAR(20),
			    @internal_counterparty_id VARCHAR(20),
				@contract_id VARCHAR(20),
				@as_of_date VARCHAR(20),
				@xml VARCHAR(MAX),
				@amount VARCHAR(30),
				@incident_status VARCHAR(100)
		--SELECT @counterparty_id = counterparty_id FROM adiha_process.alert_counterparty_process_id_ac

		SELECT TOP 1 @incident_status = value_id 
		FROM static_data_value 
		WHERE type_id = 45800 AND code = 'Communication'

		SELECT @counterparty_id = ces.Source_Counterparty_ID
		      ,@contract_id = ces.contract_id
			  ,@as_of_date = GETDATE()
			  ,@internal_counterparty_id = ces.internal_counterparty_id
			  ,@amount = ISNULL(dbo.FNARemoveTrailingZeroes(ROUND(ROUND(ces.net_exposure_to_us - ces.cash_collateral_received - ces.limit_provided,0,1) / CAST(sdv.code as INT),0,1) * CAST(sdv.code as INT)),0)
		FROM credit_exposure_summary ces
		INNER JOIN @_input_table  alc
			ON alc.counterparty_id = ces.source_counterparty_id
			AND alc.internal_counterparty_id = ces.internal_counterparty_id
			AND alc.contract_id = ces.contract_id
			AND alc.as_of_date = ces.as_of_date 
		OUTER APPLY(SELECT cca.rounding, cca.margin_provision, cca.threshold_provided, cca.threshold_received, cca.min_transfer_amount

							FROM counterparty_contract_address cca

							WHERE cca.counterparty_id = alc.counterparty_id

							AND cca.contract_id = ces.contract_id
							
							AND cca.internal_counterparty_id = ces.internal_counterparty_id
							) rnd

		LEFT JOIN static_data_value sdv ON sdv.value_id = rnd.rounding
		WHERE rnd.margin_provision IS NOT NULL
	
		SET @xml = '<Root><IncientLog  incident_log_id="" incident_type="'+ @incident_status +'" incident_description="Communication Process has been started" incident_status="10000195" counterparty="'+ @counterparty_id +'" internal_counterparty="'+ @internal_counterparty_id +'" contract="'+ @contract_id +'" date_initiated="'+ @as_of_date +'" claim_amount="'+ @amount +'"  ></IncientLog><ApplicationNotes  category_id ="37" sub_category_id ="" notes_object_id ="'+ @counterparty_id + '" parent_object_id ="" notes_subject ="Communication Process has been started" ></ApplicationNotes></Root>'
        EXEC spa_incident_log  @flag='i',@xml_data = @xml
	END
END