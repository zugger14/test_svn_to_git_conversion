IF OBJECT_ID(N'[calc_invoice_true_up]', N'U') IS NULL
BEGIN
    CREATE TABLE calc_invoice_true_up
    (
    	true_up_id               INT IDENTITY(1, 1) PRIMARY KEY,
    	calc_id                  INT,
    	counterparty_id          INT,
    	contract_id              INT,
    	true_up_month            DATETIME,
    	invoice_line_item_id     INT,
    	invoice_number           VARCHAR(50),
    	formula_id               INT,
    	sequence_id              INT,
    	as_of_date               VARCHAR(10),
    	prod_date                VARCHAR(10),
    	prod_date_to             VARCHAR(10),
    	[value]                  NUMERIC(18, 4),
    	[create_user]            VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]              DATETIME NULL DEFAULT GETDATE()
    )
END
ELSE
BEGIN
    PRINT 'Table calc_invoice_true_up EXISTS'
END

GO
