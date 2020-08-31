GO
/****** Object:  Table [dbo].[counterparty_mapping_ebase]  ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[counterparty_mapping_ebase]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[counterparty_mapping_ebase](
	[counterparty_mapping_ebase_id] [int] IDENTITY(1,1) NOT NULL,
	[source_counterparty_id] [INT] NOT NULL,
	[map_name] [VARCHAR] (50) NULL,
	CONSTRAINT pk_counterparty_mapping_ebase PRIMARY KEY NONCLUSTERED (counterparty_mapping_ebase_id),  
	CONSTRAINT fk_counterparty_mapping_ebase_source_counterparty FOREIGN KEY (source_counterparty_id)
	REFERENCES source_counterparty(source_counterparty_id)

) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table counterparty_mapping_ebase already EXISTS'
END

SET ANSI_PADDING OFF
GO