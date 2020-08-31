IF OBJECT_ID('staging_table.alert_deal_process_id_ad') IS NOT NULL
BEGIN
UPDATE staging_table.alert_deal_process_id_ad
SET 
hyperlink1 = dbo.FNATrmHyperlink('i', 10131010, 'Deal #' + CAST(source_deal_header_id AS VARCHAR(10)), CAST(source_deal_header_id AS VARCHAR(10)), 'n', DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT),
hyperlink2 = dbo.FNATrmHyperlink('i',10131020,'Review Trade Ticket',CAST(source_deal_header_id AS VARCHAR(10)),DEFAULT,'n',DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT)
END