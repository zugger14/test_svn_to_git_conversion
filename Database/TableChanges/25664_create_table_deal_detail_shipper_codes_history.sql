SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'dbo.deal_detail_shipper_codes_history',N'U') IS NULL
BEGIN
    CREATE TABLE dbo.deal_detail_shipper_codes_history
    (
		deal_detail_shipper_codes_history_id  INT IDENTITY(1, 1) PRIMARY KEY,    
		source_deal_detail_id INT FOREIGN KEY REFERENCES dbo.source_deal_detail(source_deal_detail_id) ON DELETE CASCADE,           
		shipper_code1 INT NULL,	
		shipper_code2 INT NULL,
		[user]	VARCHAR(50)  DEFAULT  dbo.FNADBUser(),	
		effective_date DATETIME DEFAULT GETDATE() NULL
    )   
END
ELSE
BEGIN
    PRINT 'Table deal_detail_shipper_codes_history EXISTS'
END
 
GO