
/****** Object:  Table [dbo].[location_loss_factor]    Script Date: 01/07/2009 14:11:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[location_loss_factor](
	[location_loss_factor_id] [int] IDENTITY(1,1) NOT NULL,
	[effective_date] [datetime] NULL,
	[from_location_id] [int] NOT NULL,
	[to_location_id] [int] NOT NULL,
	[loss_factor] [float] NOT NULL,
 CONSTRAINT [PK_location_loss_factor] PRIMARY KEY CLUSTERED 
(
	[location_loss_factor_id] ASC
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