DECLARE @ixp_table_id INT

SELECT @ixp_table_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_counterparty_credit_info_template'

UPDATE ixp_columns
SET seq = 10
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Counterparty_id'

UPDATE ixp_columns
SET seq = 20
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'account_status'

UPDATE ixp_columns
SET seq = 30
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'analyst'

UPDATE ixp_columns
SET seq = 40
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'rating_outlook'

UPDATE ixp_columns
SET seq = 50
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'qualitative_rating'

UPDATE ixp_columns
SET seq = 60
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Risk_rating'

UPDATE ixp_columns
SET seq = 70
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Debt_rating'

UPDATE ixp_columns
SET seq = 80
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Debt_Rating2'

UPDATE ixp_columns
SET seq = 90
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Debt_Rating3'

UPDATE ixp_columns
SET seq = 100
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Debt_Rating4'

UPDATE ixp_columns
SET seq = 110
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Debt_Rating5'

UPDATE ixp_columns
SET seq = 120
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Industry_type1'

UPDATE ixp_columns
SET seq = 130
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Industry_type2'

UPDATE ixp_columns
SET seq = 140
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'SIC_Code'

UPDATE ixp_columns
SET seq = 150
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Duns_No'

UPDATE ixp_columns
SET seq = 160
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Ticker_symbol'

UPDATE ixp_columns
SET seq = 170
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Date_established'

UPDATE ixp_columns
SET seq = 180
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Next_review_date'

UPDATE ixp_columns
SET seq = 190
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Last_review_date'

UPDATE ixp_columns
SET seq = 200
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Customer_since'

UPDATE ixp_columns
SET seq = 210
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'curreny_code'

UPDATE ixp_columns
SET seq = 220
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'approved_by'

UPDATE ixp_columns
SET seq = 230
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Watch_list'

UPDATE ixp_columns
SET seq = 240
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'check_apply'

UPDATE ixp_columns
SET seq = 250
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'exclude_exposure_after'

UPDATE ixp_columns
SET seq = 260
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'buy_notional_month'

UPDATE ixp_columns
SET seq = 270
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'sell_notional_month'

GO