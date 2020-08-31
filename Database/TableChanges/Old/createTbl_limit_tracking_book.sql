
/****** Object:  Table [dbo].[limit_tracking_book]    Script Date: 12/16/2008 10:26:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[limit_tracking_book](
	[limit_id] [int] NULL,
	[book_id] [int] NULL,
	[limit_value] [float] NULL
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[limit_tracking_book]  WITH CHECK ADD  CONSTRAINT [FK_limit_tracking_book_limit_tracking] FOREIGN KEY([limit_id])
REFERENCES [dbo].[limit_tracking] ([limit_id])
GO
ALTER TABLE [dbo].[limit_tracking_book] CHECK CONSTRAINT [FK_limit_tracking_book_limit_tracking]