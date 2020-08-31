SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[deal_price_std_event]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[deal_price_std_event](
    	[deal_price_std_event_id]      INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    	[source_deal_detail_id]        INT REFERENCES source_deal_detail(source_deal_detail_id) NOT NULL,
    	[event_type]                   INT NULL,
    	[event_date]                   DATETIME NULL,
    	[event_pricing_type]           INT NULL,
    	[pricing_index]                INT REFERENCES source_price_curve_def(source_curve_def_id) NOT NULL,
    	[adder]                        FLOAT NULL,
    	[currency]                     INT NULL,
    	[multiplier]                   FLOAT NULL,
    	[volume]                       NUMERIC(38, 20) NULL,
    	[uom]                          INT NULL,
    	[pricing_provisional]		   CHAR(1) NOT NULL,
    	[pricing_type]				   CHAR(1) NULL,
    	[create_user]                  VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                    DATETIME NULL DEFAULT GETDATE(),
    	[update_user]                  VARCHAR(50) NULL,
    	[update_ts]                    DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table deal_price_std_event EXISTS'
END

GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_deal_price_std_event]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_deal_price_std_event]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_deal_price_std_event]
ON [dbo].[deal_price_std_event]
FOR UPDATE
AS
    UPDATE deal_price_std_event
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM deal_price_std_event t
      INNER JOIN DELETED u ON t.[deal_price_std_event_id] = u.[deal_price_std_event_id]
GO