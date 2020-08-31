set identity_insert static_data_value ON
GO
If not exists(select 'X' from fas_subsidiaries where fas_subsidiary_id=-1)
	insert into fas_subsidiaries(fas_subsidiary_id,entity_type_value_id,disc_source_value_id,disc_type_value_id,func_cur_value_id,days_in_year,long_term_months,entity_name,address1,address2,city,state_value_id,zip_code,country_value_id,entity_url,tax_payer_id,contact_user_id,primary_naics_code_id,secondary_naics_code_id,entity_category_id,entity_sub_category_id,utility_type_id,ticker_symbol_id,ownership_status,partners,holding_company,domestic_vol_initiatives,domestic_registeries,international_registeries,confidentiality_info,exclude_indirect_emissions,organization_boundaries,base_year_from,base_year_to,tax_perc,discount_curve_id,risk_free_curve_id,counterparty_id)
	SELECT -1,650,100,128,10,365,13,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1125,1162,1177,NULL,'w',NULL,'Y',NULL,NULL,NULL,'n','n',NULL,NULL,NULL,NULL,NULL,NULL,NULL

set identity_insert static_data_value OFF
GO

set identity_insert portfolio_hierarchy ON
GO
If not exists(select 'X' from portfolio_hierarchy where entity_id=-1)
	insert into portfolio_hierarchy(entity_id,entity_name,entity_type_value_id,hierarchy_level,parent_entity_id)
	SELECT -1,'Company',525,2,NULL
GO
set identity_insert portfolio_hierarchy OFF
GO
