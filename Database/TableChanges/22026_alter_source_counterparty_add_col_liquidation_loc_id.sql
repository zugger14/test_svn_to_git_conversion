IF COL_LENGTH(N'dbo.source_counterparty', N'liquidation_loc_id') IS NULL
BEGIN 
	ALTER TABLE dbo.source_counterparty ADD  liquidation_loc_id INT FOREIGN KEY REFERENCES dbo.source_minor_location (source_minor_location_id)
END

