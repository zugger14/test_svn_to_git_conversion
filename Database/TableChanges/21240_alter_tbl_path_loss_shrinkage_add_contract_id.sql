

IF COL_LENGTH('path_loss_shrinkage', 'contract_id') IS NULL
BEGIN
    ALTER TABLE path_loss_shrinkage ADD contract_id INT
END
GO
