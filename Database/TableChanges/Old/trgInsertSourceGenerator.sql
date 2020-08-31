
/****** Object:  Trigger [dbo].[TRGINS_SOURCE_product]    Script Date: 05/20/2009 17:01:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TRGINS_source_generator]
ON [dbo].[source_generator]
FOR INSERT
AS
UPDATE source_generator SET create_user =  dbo.FNADBUser(), create_ts = getdate() where  source_generator.source_generator_id in (select source_generator_id from inserted)
