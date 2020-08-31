
/****** Object:  Table [dbo].[meter_id_channel]    Script Date: 12/12/2008 16:31:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[meter_id_channel](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[recorderid] [varchar](100) NOT NULL,
	[channel] [int] NULL,
	[channel_description] [varchar](100) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[meter_id_channel]  WITH CHECK ADD  CONSTRAINT [FK_meter_id_channel_meter_id] FOREIGN KEY([recorderid])
REFERENCES [dbo].[meter_id] ([recorderid])
GO
ALTER TABLE [dbo].[meter_id_channel] CHECK CONSTRAINT [FK_meter_id_channel_meter_id]