IF COL_LENGTH('deal_actual_quality', 'split_deal_actuals_id') IS NULL
BEGIN
    ALTER TABLE deal_actual_quality ADD split_deal_actuals_id INT
END
GO

