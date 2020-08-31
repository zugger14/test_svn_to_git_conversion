DROP TABLE [dbo].[deal_exercise_detail]
GO
/****** Object:  Table [dbo].[deal_exercise_detail]    Script Date: 01/15/2009 12:46:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[deal_exercise_detail](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[source_deal_detail_id] [int] NULL,
	[exercise_date] [datetime] NULL,
	[term_start] [datetime] NULL,
	[term_end] [datetime] NULL,
	[exercise_deal_id] [int] NULL,
 CONSTRAINT [PK_deal_exercise_detail] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
