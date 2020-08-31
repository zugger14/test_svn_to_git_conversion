SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[TRGUPD_FAS_SUBSIDIARIES]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_FAS_SUBSIDIARIES]
GO

CREATE TRIGGER [dbo].[TRGUPD_FAS_SUBSIDIARIES]
ON [dbo].[fas_subsidiaries]
FOR  UPDATE
AS
	
	DECLARE @update_user VARCHAR(300) = dbo.FNADBUser()
	DECLARE @update_ts VARCHAR(300) = GETDATE()
	
	UPDATE FAS_SUBSIDIARIES
	SET    update_user = @update_user,
	       update_ts = @update_ts
	WHERE  FAS_SUBSIDIARIES.fas_subsidiary_id IN (SELECT fas_subsidiary_id FROM   DELETED)
	
	IF NOT UPDATE (create_user) AND NOT UPDATE (create_ts)
	INSERT FAS_SUBSIDIARIES_audit
	  (
	    [fas_subsidiary_id],
	    [entity_type_value_id],
	    [disc_source_value_id],
	    [disc_type_value_id],
	    [func_cur_value_id],
	    [days_in_year],
	    [long_term_months],
	    [entity_name],
	    [address1],
	    [address2],
	    [city],
	    [state_value_id],
	    [zip_code],
	    [country_value_id],
	    [entity_url],
	    [tax_payer_id],
	    [contact_user_id],
	    [primary_naics_code_id],
	    [secondary_naics_code_id],
	    [entity_category_id],
	    [entity_sub_category_id],
	    [utility_type_id],
	    [ticker_symbol_id],
	    [ownership_status],
	    [partners],
	    [holding_company],
	    [domestic_vol_initiatives],
	    [domestic_registeries],
	    [international_registeries],
	    [confidentiality_info],
	    [exclude_indirect_emissions],
	    [organization_boundaries],
	    [base_year_from],
	    [base_year_to],
	    [tax_perc],
	    [user_action],
	    [update_user],
	    [update_ts],
	    counterparty_id
	  )
	SELECT [fas_subsidiary_id],
	       [entity_type_value_id],
	       [disc_source_value_id],
	       [disc_type_value_id],
	       [func_cur_value_id],
	       [days_in_year],
	       [long_term_months],
	       [entity_name],
	       [address1],
	       [address2],
	       [city],
	       [state_value_id],
	       [zip_code],
	       [country_value_id],
	       [entity_url],
	       [tax_payer_id],
	       [contact_user_id],
	       [primary_naics_code_id],
	       [secondary_naics_code_id],
	       [entity_category_id],
	       [entity_sub_category_id],
	       [utility_type_id],
	       [ticker_symbol_id],
	       [ownership_status],
	       [partners],
	       [holding_company],
	       [domestic_vol_initiatives],
	       [domestic_registeries],
	       [international_registeries],
	       [confidentiality_info],
	       [exclude_indirect_emissions],
	       [organization_boundaries],
	       [base_year_from],
	       [base_year_to],
	       [tax_perc],
	       'Update',
	       @update_user,
	       @update_ts,
	       counterparty_id
	FROM   INSERTED

