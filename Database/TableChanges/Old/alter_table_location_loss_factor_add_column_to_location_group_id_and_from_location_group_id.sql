IF COL_LENGTH('location_loss_factor', 'from_location_group_id') IS NULL
BEGIN
    ALTER TABLE location_loss_factor ADD from_location_group_id INT
END
GO
IF COL_LENGTH('location_loss_factor', 'to_location_group_id') IS NULL
BEGIN
    ALTER TABLE location_loss_factor ADD to_location_group_id INT
END
GO