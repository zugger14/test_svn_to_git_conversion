IF COL_LENGTH('source_deal_detail', 'syv_time_of_use') IS NULL
BEGIN
    ALTER TABLE source_deal_detail ADD syv_time_of_use VARCHAR(10) NULL
    PRINT 'Column source_deal_detail.syv_time_of_use added.'
END
GO