SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[deal_escalation]', N'U') IS NULL
BEGIN
   CREATE TABLE [dbo].deal_escalation (
   		deal_escalation_id        INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
   		source_deal_detail_id     INT NOT NULL REFERENCES source_deal_detail(source_deal_detail_id),
   		quality                   INT NULL,
   		range_from                FLOAT NULL,
   		range_to                  FLOAT NULL,
   		increment                 FLOAT NULL,
   		cost_increment            FLOAT NULL,
   		operator                  INT NULL,
   		[reference]               INT NULL,
   		currency                  INT NULL,
   		create_user               VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
   		create_ts                 DATETIME NULL DEFAULT GETDATE(),
   		update_user               VARCHAR(50) NULL,
   		update_ts                 DATETIME NULL
   )
END
ELSE
BEGIN
    PRINT 'Table deal_escalation EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_deal_escalation]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_deal_escalation]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_deal_escalation]
ON [dbo].[deal_escalation]
FOR UPDATE
AS
    UPDATE deal_escalation
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM deal_escalation t
      INNER JOIN DELETED u ON t.[deal_escalation_id] = u.[deal_escalation_id]
GO