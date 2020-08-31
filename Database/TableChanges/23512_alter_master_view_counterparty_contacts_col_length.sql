IF OBJECT_ID(N'master_view_counterparty_contacts', N'U') IS NOT NULL AND COL_LENGTH('master_view_counterparty_contacts', 'address1') IS NOT NULL
BEGIN
    ALTER TABLE master_view_counterparty_contacts ALTER COLUMN address1 VARCHAR(255)
END
GO

IF OBJECT_ID(N'master_view_counterparty_contacts', N'U') IS NOT NULL AND COL_LENGTH('master_view_counterparty_contacts', 'address2') IS NOT NULL
BEGIN
    ALTER TABLE master_view_counterparty_contacts ALTER COLUMN address2 VARCHAR(255)
END
GO

IF OBJECT_ID(N'master_view_counterparty_contacts', N'U') IS NOT NULL AND COL_LENGTH('master_view_counterparty_contacts', 'zip') IS NOT NULL
BEGIN
    ALTER TABLE master_view_counterparty_contacts ALTER COLUMN zip VARCHAR(100)
END
GO

IF OBJECT_ID(N'master_view_counterparty_contacts', N'U') IS NOT NULL AND COL_LENGTH('master_view_counterparty_contacts', 'email') IS NOT NULL
BEGIN
    ALTER TABLE master_view_counterparty_contacts ALTER COLUMN email VARCHAR(500)
END
GO

IF OBJECT_ID(N'master_view_counterparty_contacts', N'U') IS NOT NULL AND COL_LENGTH('master_view_counterparty_contacts', 'fax') IS NOT NULL
BEGIN
    ALTER TABLE master_view_counterparty_contacts ALTER COLUMN fax VARCHAR(50)
END
GO

IF OBJECT_ID(N'master_view_counterparty_contacts', N'U') IS NOT NULL AND COL_LENGTH('master_view_counterparty_contacts', 'cell_no') IS NOT NULL
BEGIN
    ALTER TABLE master_view_counterparty_contacts ALTER COLUMN cell_no VARCHAR(20)
END
GO