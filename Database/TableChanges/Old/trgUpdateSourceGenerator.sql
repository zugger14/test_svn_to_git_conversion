
/****** Object:  Trigger [dbo].[TRGUPD_SOURCE_product]    Script Date: 05/20/2009 17:01:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TRGUPD_source_generator]
ON [dbo].[source_generator]
FOR UPDATE
AS
UPDATE source_generator SET update_user =  dbo.FNADBUser(), update_ts = getdate()  where  source_generator.source_generator_id in (select source_generator_id from deleted)
