IF COL_LENGTH('location_loss_factor','logical_name')  IS NULL
BEGIN
    ALTER TABLE location_loss_factor ADD [logical_name] VARCHAR(500)  UNIQUE
END
GO
IF COL_LENGTH('location_loss_factor','pipeline') IS NULL
BEGIN
    ALTER TABLE location_loss_factor ADD [pipeline] Int FOREIGN KEY REFERENCES source_counterparty(source_counterparty_id)
END
GO
IF COL_LENGTH('location_loss_factor','priority') IS NULL
BEGIN
    ALTER TABLE location_loss_factor ADD [priority] INT FOREIGN KEY REFERENCES static_data_value(value_id)
END
GO



