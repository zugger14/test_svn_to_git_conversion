IF NOT EXISTS (SELECT 'x' FROM information_schema.[COLUMNS]  WHERE TABLE_NAME ='deal_calc_cashflow_earnings' AND 
COLUMN_NAME ='leg')
ALTER table deal_calc_cashflow_earnings ADD leg int