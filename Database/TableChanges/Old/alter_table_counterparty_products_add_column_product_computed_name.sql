IF COL_LENGTH('counterparty_products', 'product_computed_name') IS NULL
BEGIN
    ALTER TABLE counterparty_products ADD product_computed_name VARCHAR(4000)
END

GO