IF NOT EXISTS(SELECT 1 FROM information_schema.columns WHERE table_name = 'delete_source_deal_detail' AND column_name = 'actual_volume')
BEGIN
    ALTER TABLE delete_source_deal_detail ADD actual_volume NUMERIC(38, 10)
END  