IF COL_LENGTH('delivery_path','logical_name')  IS NULL
BEGIN
    ALTER TABLE delivery_path ADD [logical_name] VARCHAR(500)
END
GO
IF COL_LENGTH('delivery_path','mdq') IS NULL
BEGIN
    ALTER TABLE delivery_path ADD mdq NUMERIC(38,20)
END
GO
IF COL_LENGTH('delivery_path','priority') IS NULL
BEGIN
    ALTER TABLE delivery_path ADD [priority] INT FOREIGN KEY REFERENCES static_data_value(value_id);
END
GO
