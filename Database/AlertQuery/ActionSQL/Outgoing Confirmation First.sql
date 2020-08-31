IF OBJECT_ID('tempdb..#confirm_status') IS NOT NULL
DROP TABLE #confirm_status	

DECLARE @as_of_date DATETIME 
SET @as_of_date = GETDATE()

CREATE TABLE #confirm_status(confirm_status_id INT, source_deal_header_id INT, [type] INT, as_of_date datetime)

INSERT INTO confirm_status(source_deal_header_id,[type],[as_of_date])
OUTPUT INSERTED.confirm_status_id, INSERTED.source_deal_header_id, INSERTED.TYPE, INSERTED.as_of_date
INTO #confirm_status(confirm_status_id, source_deal_header_id, TYPE, as_of_date)
SELECT source_deal_header_id, 17210, @as_of_date FROM staging_table.alert_deal_process_id_ad


INSERT INTO confirm_status_recent(source_deal_header_id,[type],[as_of_date])
SELECT source_deal_header_id, 17210, @as_of_date FROM staging_table.alert_deal_process_id_ad


UPDATE ps
SET confirm_status_id = cs.confirm_status_id
FROM staging_table.alert_deal_process_id_ad ps
INNER JOIN #confirm_status cs ON cs.source_deal_header_id = ps.source_deal_header_id

UPDATE staging_table.alert_deal_process_id_ad 
SET hyperlink1 = dbo.FNATrmHyperlink('i', 10171016,'Generate Confirmation', source_deal_header_id, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT),
hyperlink2 = NULL
FROM staging_table.alert_deal_process_id_ad