/*
 * [stmt_checkout] Table
 */

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF OBJECT_ID(N'[dbo].[stmt_prepay]', N'U') IS  NULL
BEGIN
CREATE TABLE [dbo].[stmt_prepay]
    (
		stmt_prepay_id				INT IDENTITY(1, 1) NOT NULL,
		source_deal_header_id		INT,		shipment_id					INT,		ticket_id					INT,		deal_charge_type_id			INT,		amount						NUMERIC(32,20),		settlement_date				DATETIME,		is_prepay					CHAR(1),		stmt_invoice_detail_id		INT,		create_user					VARCHAR(128) NULL DEFAULT dbo.FNADBUser(),		create_ts					DATETIME DEFAULT GETDATE(),		update_user					VARCHAR(128) NULL,
		update_ts					DATETIME NULL,		CONSTRAINT [PK_stmt_prepay] PRIMARY KEY CLUSTERED([stmt_prepay_id] ASC)
    ) ON [PRIMARY]
    PRINT 'Table Successfully Created'
END
ELSE
BEGIN
    PRINT 'Table stmt_checkout EXISTS'
END
GO