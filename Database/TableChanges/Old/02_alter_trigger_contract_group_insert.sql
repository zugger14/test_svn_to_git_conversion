SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER TRIGGER [dbo].[TRGINS_CONTRACT_GROUP]
ON [dbo].[contract_group]
FOR  INSERT
AS
	
	INSERT INTO contract_group_audit
	  (
	    contract_id,
	    sub_id,
	    contract_name,
	    contract_date,
	    receive_invoice,
	    settlement_accountant,
	    billing_cycle,
	    invoice_due_date,
	    volume_granularity,
	    hourly_block,
	    currency,
	    volume_mult,
	    onpeak_mult,
	    offpeak_mult,
	    [type],
	    reverse_entries,
	    volume_uom,
	    rec_uom,
	    contract_specialist,
	    term_start,
	    term_end,
	    [name],
	    company,
	    [state],
	    city,
	    zip,
	    [address],
	    address2,
	    telephone,
	    email,
	    fax,
	    name2,
	    company2,
	    telephone2,
	    fax2,
	    email2,
	    source_contract_id,
	    source_system_id,
	    contract_desc,
	    create_user,
	    create_ts,
	    update_user,
	    update_ts,
	    energy_type,
	    area_engineer,
	    metering_contract,
	    miso_queue_number,
	    substation_name,
	    project_county,
	    voltage,
	    time_zone,
	    contract_service_agreement_id,
	    contract_charge_type_id,
	    billing_from_date,
	    billing_to_date,
	    contract_report_template,
	    Subledger_code,
	    UD_Contract_id,
	    extension_provision_description,
	    term_name,
	    increment_name,
	    ferct_tarrif_reference,
	    point_of_delivery_control_area,
	    point_of_delivery_specific_location,
	    contract_affiliate,
	    point_of_receipt_control_area,
	    point_of_receipt_specific_location,
	    no_meterdata,
	    billing_start_month,
	    increment_period,
	    bookout_provision,
	    contract_status,
	    holiday_calendar_id,
	    billing_from_hour,
	    billing_to_hour,
	    block_type,
	    is_active,
	    payment_calendar,
	    pnl_date,
	    pnl_calendar,
	    payment_days,
	    settlement_calendar,
	    settlement_days,
	    settlement_rule,
	    settlement_date,
	    invoice_report_template,
	    netting_template,
	    self_billing,
	    neting_rule,
	    user_action,
	    netting_statement,
	    contract_email_template
	  )
	SELECT contract_id,
	       sub_id,
	       contract_name,
	       contract_date,
	       receive_invoice,
	       settlement_accountant,
	       billing_cycle,
	       invoice_due_date,
	       volume_granularity,
	       hourly_block,
	       currency,
	       volume_mult,
	       onpeak_mult,
	       offpeak_mult,
	       [type],
	       reverse_entries,
	       volume_uom,
	       rec_uom,
	       contract_specialist,
	       term_start,
	       term_end,
	       [name],
	       company,
	       [state],
	       city,
	       zip,
	       [address],
	       address2,
	       telephone,
	       email,
	       fax,
	       name2,
	       company2,
	       telephone2,
	       fax2,
	       email2,
	       source_contract_id,
	       source_system_id,
	       contract_desc,
	       ISNULL(create_user, dbo.FNADBUser()),
	       ISNULL(create_ts, GETDATE()),
	       update_user,
	       update_ts,
	       energy_type,
	       area_engineer,
	       metering_contract,
	       miso_queue_number,
	       substation_name,
	       project_county,
	       voltage,
	       time_zone,
	       contract_service_agreement_id,
	       contract_charge_type_id,
	       billing_from_date,
	       billing_to_date,
	       contract_report_template,
	       Subledger_code,
	       UD_Contract_id,
	       extension_provision_description,
	       term_name,
	       increment_name,
	       ferct_tarrif_reference,
	       point_of_delivery_control_area,
	       point_of_delivery_specific_location,
	       contract_affiliate,
	       point_of_receipt_control_area,
	       point_of_receipt_specific_location,
	       no_meterdata,
	       billing_start_month,
	       increment_period,
	       bookout_provision,
	       contract_status,
	       holiday_calendar_id,
	       billing_from_hour,
	       billing_to_hour,
	       block_type,
	       is_active,
	       payment_calendar,
	       pnl_date,
	       pnl_calendar,
	       payment_days,
		   settlement_calendar,
		   settlement_days,
		   settlement_rule,
		   settlement_date,
		   invoice_report_template,
		   netting_template,
		   self_billing,
		   neting_rule,
	       'insert',
	       netting_statement,
	       contract_email_template
	FROM   INSERTED
	

	


