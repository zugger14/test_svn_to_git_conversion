IF COL_LENGTH('calcprocess_storage_wacog', 'inj_inventory_amt') IS NULL
BEGIN
    ALTER TABLE calcprocess_storage_wacog ADD inj_inventory_amt NUMERIC(38, 18)
END


IF COL_LENGTH('calcprocess_storage_wacog', 'wth_inventory_amt') IS NULL
BEGIN
    ALTER TABLE calcprocess_storage_wacog ADD wth_inventory_amt NUMERIC(38, 18)
END
GO


