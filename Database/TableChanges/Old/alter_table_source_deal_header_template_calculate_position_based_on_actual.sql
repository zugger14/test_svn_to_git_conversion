IF COL_LENGTH('source_deal_header_template', 'calculate_position_based_on_actual') IS NULL
BEGIN
    ALTER TABLE source_deal_header_template ADD calculate_position_based_on_actual CHAR(1)
END
GO