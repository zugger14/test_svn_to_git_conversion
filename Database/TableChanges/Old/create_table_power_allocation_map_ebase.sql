GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[power_allocation_map_ebase]') AND type in (N'U'))
DROP TABLE [dbo].[power_allocation_map_ebase]
go

CREATE TABLE [dbo].[power_allocation_map_ebase](
	[power_allocation_map_ebase_id] [INT]  IDENTITY(1,1),
	[source_commodity_id] [int] NULL,
	[country] [VARCHAR](64) NULL,
	[allocation_delay] [INT] NULL
) ON [PRIMARY]

SET ANSI_PADDING OFF
GO

