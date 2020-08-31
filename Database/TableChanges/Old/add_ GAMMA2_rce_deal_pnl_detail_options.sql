
IF COL_LENGTH('source_deal_pnl_detail_options', 'GAMMA2') IS NULL 
begin
	alter table source_deal_pnl_detail_options add GAMMA2 float, VEGA2 float, RHO2 float, THETA2 float 
	alter table source_deal_pnl_detail_options_WhatIf add GAMMA2 float, VEGA2 float, RHO2 float, THETA2 float 
	
end 