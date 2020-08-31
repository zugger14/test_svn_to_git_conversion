SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[deal_price_deemed]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[deal_price_deemed](
    	[deal_price_deemed_id]      INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    	[source_deal_detail_id]     INT REFERENCES source_deal_detail(source_deal_detail_id) NOT NULL,
    	[pricing_index]             INT REFERENCES source_price_curve_def(source_curve_def_id) NOT NULL,
    	[pricing_start]             DATETIME NULL,
    	[pricing_end]               DATETIME NULL,
    	[adder]                     FLOAT NULL,
    	[currency]                  INT NULL,
    	[multiplier]                FLOAT NULL,
    	[volume]                    NUMERIC(38, 20) NULL,
    	[uom]                       INT NULL,
    	[pricing_provisional]		CHAR(1) NOT NULL,
    	[pricing_type]				CHAR(1) NULL,
    	[create_user]               VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                 DATETIME NULL DEFAULT GETDATE(),
    	[update_user]               VARCHAR(50) NULL,
    	[update_ts]                 DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table deal_price_deemed EXISTS'
END

GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_deal_price_deemed]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_deal_price_deemed]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_deal_price_deemed]
ON [dbo].[deal_price_deemed]
FOR UPDATE
AS
    UPDATE deal_price_deemed
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM deal_price_deemed t
      INNER JOIN DELETED u ON t.[deal_price_deemed_id] = u.[deal_price_deemed_id]
GO