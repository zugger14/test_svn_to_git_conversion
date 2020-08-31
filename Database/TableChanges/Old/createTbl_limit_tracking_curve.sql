
/****** Object:  Table [dbo].[limit_tracking_curve]    Script Date: 12/16/2008 10:30:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[limit_tracking_curve](
	[limit_id] [int] NULL,
	[curve_id] [int] NULL,
	[limit_value] [float] NULL
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[limit_tracking_curve]  WITH CHECK ADD  CONSTRAINT [FK_limit_tracking_curve_limit_tracking] FOREIGN KEY([limit_id])
REFERENCES [dbo].[limit_tracking] ([limit_id])
GO
ALTER TABLE [dbo].[limit_tracking_curve] CHECK CONSTRAINT [FK_limit_tracking_curve_limit_tracking]