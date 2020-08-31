IF EXISTS (SELECT 1 FROM sys.columns WHERE Name = N'deal_id' AND Object_ID = Object_ID(N'master_deal_view'))
BEGIN
    ALTER TABLE master_deal_view ALTER COLUMN deal_id VARCHAR(200) NOT NULL
END
