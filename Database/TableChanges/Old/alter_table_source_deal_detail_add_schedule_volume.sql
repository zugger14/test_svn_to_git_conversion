IF NOT EXISTS(SELECT 1 FROM information_schema.columns WHERE table_name = 'source_deal_detail' AND column_name = 'schedule_volume')
BEGIN
    ALTER TABLE source_deal_detail ADD schedule_volume NUMERIC(38, 10)
END  