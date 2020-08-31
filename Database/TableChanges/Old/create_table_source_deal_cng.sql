SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[source_deal_cng]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[source_deal_cng]
    (
    [source_deal_cng_id]             INT IDENTITY(1, 1) NOT NULL,
    [card_type]					INT NOT NULL,
    [counterparty_id]			INT REFERENCES source_counterparty(source_counterparty_id) ,
	[credit_card_no]			VARCHAR(100) NOT NULL,
	[transaction_date]			DATETIME NOT NULL,
	[start_time]				DATETIME NOT NULL,
	[end_time]					DATETIME,
	[pulser_start_time]			DATETIME,
	[pulser_end_time]			DATETIME,
    [location_id]				INT REFERENCES source_minor_location(source_minor_location_id),
	[quantity]					NUMERIC(38,20),
	[price]						NUMERIC(38,20),
	[pump_number]				VARCHAR(100),
	[driver]					VARCHAR(100),
	[vehicle_id]				VARCHAR(100),
	[odo_meter]					VARCHAR(100),
	[payment_status]			BIT,
	[cash_apply]				NUMERIC(38,20),
	[Amount]					FLOAT,
	[credit]					FLOAT,
	[settlement]				FLOAT,
	[outstanding_amount]		FLOAT,
	[receive_date]				DATETIME,
	[lock]						BIT,
    [create_user]				VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    [create_ts]					DATETIME NULL DEFAULT GETDATE(),
    [update_user]				VARCHAR(50) NULL,
    [update_ts]					DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table source_deal_cng EXISTS'
END
 
GO 
