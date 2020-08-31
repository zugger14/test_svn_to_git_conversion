/*
update trigger for source_deal_header_whatif_hypo
31 oct 2013
*/
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_source_deal_header_whatif_hypo]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_source_deal_header_whatif_hypo]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_source_deal_header_whatif_hypo]
ON [dbo].[source_deal_header_whatif_hypo]
FOR UPDATE
AS
    UPDATE source_deal_header_whatif_hypo
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM source_deal_header_whatif_hypo t
      INNER JOIN DELETED u ON u.source_deal_header_id = t.source_deal_header_id
GO