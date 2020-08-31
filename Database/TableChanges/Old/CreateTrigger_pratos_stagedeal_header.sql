/****** Object:  Trigger [TRGINS_pratos_stage_deal_header]    Script Date: 04/10/2012 16:29:06 ******/
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRGINS_pratos_stage_deal_header]'))
DROP TRIGGER [dbo].[TRGINS_pratos_stage_deal_header]
GO



/****** Object:  Trigger [dbo].[TRGINS_pratos_stage_deal_header]    Script Date: 04/10/2012 16:28:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE TRIGGER [dbo].[TRGINS_pratos_stage_deal_header]
ON [dbo].[pratos_stage_deal_header]
FOR INSERT
AS
UPDATE pratos_stage_deal_header SET create_ts = getdate() where  pratos_stage_deal_header.source_deal_id in (select source_deal_id from inserted)



GO


