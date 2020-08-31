
IF NOT EXISTS(SELECT 'X' FROM information_schema.columns where table_name = 'save_confirm_status' and column_name='deal_volume_frequency')
ALTER TABLE save_confirm_status ADD deal_volume_frequency VARCHAR(1000)