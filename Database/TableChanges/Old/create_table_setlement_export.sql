GO
IF EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[settlement_export]') AND TYPE IN (N'U'))
BEGIN
    PRINT 'Table Already Exists'
END
ELSE
BEGIN

    CREATE TABLE [dbo].settlement_export
    (
    	id										INT IDENTITY(1, 1) PRIMARY KEY,
		counterparty_id							INT NULL,
		contract_id								INT NULL, 
		as_of_date								NVARCHAR(MAX) NULL,
		invoice_date							NVARCHAR(MAX) NULL,
		[type]									NVARCHAR(400) NULL,	
		document_header							NVARCHAR(MAX) NULL,
		comp_code								NVARCHAR(MAX) NULL,
		doc_type								NVARCHAR(MAX) NULL,
		doc_date								NVARCHAR(MAX) NULL,
		fisc_year								NVARCHAR(MAX) NULL,
		pstng_date								NVARCHAR(MAX) NULL,
		currency								NVARCHAR(MAX) NULL,
		header_txt								NVARCHAR(MAX) NULL,
		ref_doc_no								NVARCHAR(MAX) NULL,
		reason_rev								NVARCHAR(MAX) NULL,
		extension_field							NVARCHAR(MAX) NULL,
		[text]									NVARCHAR(MAX) NULL,
		quantity								NVARCHAR(MAX) NULL,
		base_unit_of_measure					NVARCHAR(MAX) NULL,
		settlement_period						NVARCHAR(MAX) NULL,
		[create_user]							NVARCHAR(100) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]								DATETIME DEFAULT GETDATE(),
		[update_user]							NVARCHAR(100) NULL,
		[update_ts]								DATETIME NULL
		
		
    ) 
    
    PRINT 'Table Successfully Created'
END

GO
--DROP TABLE settlement_export

