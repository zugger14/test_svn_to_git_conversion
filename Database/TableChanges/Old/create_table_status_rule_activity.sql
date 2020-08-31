/****** Object:  Table [dbo].[status_rule_activity]    Script Date: 03/27/2012 09:39:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[status_rule_activity]', N'U') IS NULL
BEGIN 
	CREATE TABLE [dbo].[status_rule_activity](
		[status_rule_activity_id] [int] IDENTITY(1,1) NOT NULL,
		[event_id] [int] NOT NULL,
		[workflow_activity_id] [int] NOT NULL,
	 CONSTRAINT [PK_status_rule_activity] PRIMARY KEY CLUSTERED 
	(
		[status_rule_activity_id] ASC
	)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
	) ON [PRIMARY]
END 


