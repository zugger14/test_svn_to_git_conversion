UPDATE maintain_field_deal SET system_required='y' 
WHERE farrms_field_id IN ('physical_financial_flag','structured_deal_id','entire_term_start',
'entire_term_end','trader_id','template_id','header_buy_sell_flag','deal_category_value_id',
'deal_sub_type_type_id','option_flag','source_system_id','contract_expiration_date','fixed_float_leg','Leg',
'buy_sell_flag','physical_financial_flag')
