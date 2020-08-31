
/* indexes required for measurement process */

IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = 'indx_cl_source_deal_pnl_arch2')
CREATE CLUSTERED INDEX indx_cl_source_deal_pnl_arch2 
    ON dbo.source_deal_pnl_arch2(source_deal_header_id, pnl_as_of_date, term_start, term_end, Leg,  pnl_source_value_id)

IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = 'source_deal_pnl_2')
CREATE NONCLUSTERED INDEX source_deal_pnl_2 ON dbo.source_deal_pnl(pnl_source_value_id)

IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = 'source_deal_pnl_arch1_2')
CREATE NONCLUSTERED INDEX source_deal_pnl_arch1_2 ON dbo.source_deal_pnl_arch1(pnl_source_value_id)

IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = 'source_deal_pnl_arch_2')
CREATE NONCLUSTERED INDEX source_deal_pnl_arch_2 ON dbo.source_deal_pnl_arch2(pnl_source_value_id)

IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = 'source_deal_pnl_2_1')
CREATE NONCLUSTERED INDEX source_deal_pnl_2_1 ON dbo.source_deal_pnl(source_deal_header_id,pnl_as_of_date)

IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = 'source_deal_pnl_arch1_2_1')
CREATE NONCLUSTERED INDEX source_deal_pnl_arch1_2_1 ON dbo.source_deal_pnl_arch1(source_deal_header_id,pnl_as_of_date)

IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = 'source_deal_pnl_arch_2_1')
CREATE NONCLUSTERED INDEX source_deal_pnl_arch_2_1 ON dbo.source_deal_pnl_arch2(source_deal_header_id,pnl_as_of_date)

IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = 'indx_calcprocess_deals_11')
CREATE NONCLUSTERED INDEX indx_calcprocess_deals_11 ON dbo.calcprocess_deals(fas_book_id,as_of_date)

/* indexes required for reports */

IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = 'indx_cl_report_measurement_values_expired')
CREATE CLUSTERED INDEX indx_cl_report_measurement_values_expired
    ON dbo.report_measurement_values_expired(as_of_date,sub_entity_id,strategy_entity_id,book_entity_id)

IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = 'indx_report_measurement_values_expired_1')
CREATE NONCLUSTERED INDEX indx_report_measurement_values_expired_1 ON dbo.report_measurement_values_expired(hedge_type_value_id)

IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = 'indx_report_measurement_values_expired_2')
CREATE NONCLUSTERED INDEX indx_report_measurement_values_expired_2 ON dbo.report_measurement_values_expired(term_month)

IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = 'indx_report_measurement_values_expired_3')
CREATE NONCLUSTERED INDEX indx_report_measurement_values_expired_3 ON dbo.report_measurement_values_expired(book_entity_id)

IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = 'indx_report_measurement_values_arch2_1')
CREATE NONCLUSTERED INDEX indx_report_measurement_values_arch2_1 
    ON dbo.report_measurement_values_arch2(as_of_date,sub_entity_id,strategy_entity_id,book_entity_id)

IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = 'indx_report_measurement_values_1')
CREATE NONCLUSTERED INDEX indx_report_measurement_values_1 ON dbo.report_measurement_values(book_entity_id)

IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = 'indx_report_measurement_values_2')
CREATE NONCLUSTERED INDEX indx_report_measurement_values_2 ON dbo.report_measurement_values(strategy_entity_id)

IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = 'indx_calcprocess_aoci_release_arch2_1')
CREATE NONCLUSTERED INDEX indx_calcprocess_aoci_release_arch2_1 
   ON dbo.calcprocess_aoci_release_arch2(as_of_date,link_id,source_deal_header_id,h_term)

IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = 'indx_calcprocess_deals_arch2_1')
CREATE NONCLUSTERED INDEX indx_calcprocess_deals_arch2_1 
   ON dbo.calcprocess_deals_arch2(calc_type,as_of_date,fas_subsidiary_id,fas_strategy_id,fas_book_id)

IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = 'indx_calcprocess_deals_arch2_2')
CREATE NONCLUSTERED INDEX indx_calcprocess_deals_arch2_2
   ON dbo.calcprocess_deals_arch2(source_counterparty_id,deal_type,deal_sub_type,curve_id,pnl_currency_id,link_type_value_id,hedge_type_value_id,use_eff_test_profile_id,deal_volume_uom_id)

IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = 'indx_calcprocess_deals_arch2_3')
CREATE NONCLUSTERED INDEX indx_calcprocess_deals_arch2_3 ON dbo.calcprocess_deals_arch2(fas_book_id)







   











	


	
 
