SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'dbo.process_deal_alert_transfer_adjust',N'U') IS NULL
BEGIN
    CREATE TABLE dbo.process_deal_alert_transfer_adjust
    (
		source_deal_header_id INT,
		create_user	NVARCHAR(30),
		create_ts	DATETIME,
		process_status TINYINT NOT NULL,
		error_description NVARCHAR(4000)
    )   
END
ELSE
BEGIN
    PRINT 'Table process_deal_alert_transfer_adjust EXISTS'
END
 
GO
