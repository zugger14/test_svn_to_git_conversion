
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwSubsidiary]'))
DROP VIEW [dbo].vwSubsidiary
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  VIEW vwSubsidiary AS SELECT fas_subsidiary_id,
           a.entity_type_value_id,
           disc_source_value_id,
           disc_type_value_id,
           func_cur_value_id,
           days_in_year,
           long_term_months,
           a.entity_name entity_name_o,
           address1,
           address2,
           city,
           state_value_id,
           zip_code,
           country_value_id,
           entity_url,
           tax_payer_id,
           contact_user_id,
           primary_naics_code_id,
           secondary_naics_code_id,
           entity_category_id,
           entity_sub_category_id,
           utility_type_id,
           ticker_symbol_id,
           ownership_status,
           partners,
           holding_company,
           domestic_vol_initiatives,
           domestic_registeries,
           international_registeries,
           confidentiality_info,
           exclude_indirect_emissions,
           organization_boundaries,
           b.entity_name,
           base_year_from,
           base_year_to,
           tax_perc,
           discount_curve_id,
           risk_free_curve_id,
           counterparty_id,
           timezone_id,
		   fx_conversion_market,
		   accounting_code
    FROM   fas_subsidiaries a INNER JOIN 
           portfolio_hierarchy b
    ON  a.fas_subsidiary_id = b.entity_id

