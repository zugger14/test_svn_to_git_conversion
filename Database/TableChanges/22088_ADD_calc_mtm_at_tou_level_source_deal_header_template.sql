IF COL_LENGTH('source_deal_header_template', 'calc_mtm_at_tou_level') IS NULL
BEGIN
    ALTER TABLE source_deal_header_template ADD calc_mtm_at_tou_level varchar(1)
END
GO

