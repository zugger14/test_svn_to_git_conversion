/****** Object:  Table [dbo].[deal_status_group]    Script Date: 06/24/2011 13:40:00 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[deal_status_group]') AND type in (N'U'))
DROP TABLE [dbo].[deal_status_group]
GO



/****** Object:  Table [dbo].[deal_status_group]    Script Date: 06/24/2011 13:39:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[deal_status_group](
	[deal_status_group_id] [int] IDENTITY(1,1) NOT NULL,
	[status_value_id] [int] NOT NULL,
	[status] [varchar](50) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO
-- select * from static_data_value where type_Id=5600

INSERT INTO [deal_status_group]([status_value_id],[status]) Values(5605,'Official')
--INSERT INTO [deal_status_group]([status_value_id],[status]) Values(5606,'Official')
--INSERT INTO [deal_status_group]([status_value_id],[status]) Values(5607,'Official')
--INSERT INTO [deal_status_group]([status_value_id],[status]) Values(5603,'Official')
--INSERT INTO [deal_status_group]([status_value_id],[status]) Values(5604,'Official')


-- select * from [deal_status_group]
--select deal_status,* from source_deal_header

update source_deal_header set deal_status = 5605 WHERE deal_status IS NULL
