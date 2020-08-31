GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[gas_allocation_map_ebase]') AND type in (N'U'))
DROP TABLE [dbo].[gas_allocation_map_ebase]
go

CREATE TABLE [dbo].[gas_allocation_map_ebase](
	[gas_allocation_map_ebase_id] [INT]  IDENTITY(1,1),
	[source_commodity_id] [int] NULL,
	[country] [VARCHAR](64) NULL,
	[last_allocation_month] [INT] NULL
) ON [PRIMARY]

SET ANSI_PADDING OFF
GO

