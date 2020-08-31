IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_location_loss_factor_source_minor_location]') AND parent_object_id = OBJECT_ID(N'[dbo].[location_loss_factor]'))
ALTER TABLE [dbo].[location_loss_factor] DROP CONSTRAINT [FK_location_loss_factor_source_minor_location]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_location_loss_factor_source_minor_location1]') AND parent_object_id = OBJECT_ID(N'[dbo].[location_loss_factor]'))
ALTER TABLE [dbo].[location_loss_factor] DROP CONSTRAINT [FK_location_loss_factor_source_minor_location1]
GO

/****** Object:  Table [dbo].[location_loss_factor]    Script Date: 01/15/2009 15:41:21 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[location_loss_factor]') AND type in (N'U'))
DROP TABLE [dbo].[location_loss_factor]
/****** Object:  Table [dbo].[location_loss_factor]    Script Date: 01/15/2009 15:40:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[location_loss_factor](
	[location_loss_factor_id] [int] IDENTITY(1,1) NOT NULL,
	[effective_date] [datetime] NOT NULL,
	[from_location_id] [int] NOT NULL,
	[to_location_id] [int] NOT NULL,
	[loss_factor] [float] NOT NULL,
 CONSTRAINT [PK_location_loss_factor] PRIMARY KEY CLUSTERED 
(
	[location_loss_factor_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY],
 CONSTRAINT [IX_location_loss_factor] UNIQUE NONCLUSTERED 
(
	[effective_date] ASC,
	[from_location_id] ASC,
	[to_location_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[location_loss_factor]  WITH CHECK ADD  CONSTRAINT [FK_location_loss_factor_source_minor_location] FOREIGN KEY([from_location_id])
REFERENCES [dbo].[source_minor_location] ([source_minor_location_id])
GO
ALTER TABLE [dbo].[location_loss_factor] CHECK CONSTRAINT [FK_location_loss_factor_source_minor_location]
GO
ALTER TABLE [dbo].[location_loss_factor]  WITH CHECK ADD  CONSTRAINT [FK_location_loss_factor_source_minor_location1] FOREIGN KEY([to_location_id])
REFERENCES [dbo].[source_minor_location] ([source_minor_location_id])
GO
ALTER TABLE [dbo].[location_loss_factor] CHECK CONSTRAINT [FK_location_loss_factor_source_minor_location1]