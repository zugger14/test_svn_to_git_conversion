

if  exists(select 1 from sys.indexes where [name]='cur_indx_pnl_component_price_detail')	
drop index cur_indx_pnl_component_price_detail on dbo.pnl_component_price_detail

create unique clustered index cur_indx_pnl_component_price_detail on dbo.pnl_component_price_detail(run_as_of_date, calc_type,source_deal_header_id, curve_id, ticket_detail_id, shipment_id, deal_price_type_id, term_start, leg, fin_term_start, maturity_date)