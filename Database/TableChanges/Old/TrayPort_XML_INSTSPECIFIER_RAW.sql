/****** Object:  Table [dbo].[TrayPort_XML_INSTSPECIFIER_RAW]    Script Date: 07/18/2011 23:29:38 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TrayPort_XML_INSTSPECIFIER_RAW]') AND type in (N'U'))
DROP TABLE [dbo].[TrayPort_XML_INSTSPECIFIER_RAW]
GO

/****** Object:  Table [dbo].[TrayPort_XML_INSTSPECIFIER_RAW]    Script Date: 07/18/2011 23:29:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[TrayPort_XML_INSTSPECIFIER_RAW](
	[sno] [int] IDENTITY(1,1) NOT NULL,
	[InstID] [nvarchar](255) NULL,
	[SeqSpan] [nvarchar](255) NULL,
	[FirstSequenceID] [nvarchar](255) NULL,
	[FirstSequenceItemID] [nvarchar](255) NULL,
	[SecondSequenceItemID] [nvarchar](255) NULL,
	[TermFormatID] [nvarchar](255) NULL,
	[InstName] [nvarchar](255) NULL,
	[FirstSequenceItemName] [nvarchar](255) NULL,
	[SecondSequenceItemName] [nvarchar](255) NULL,
	[Trade_id] [nvarchar](255) NULL,
 CONSTRAINT [PK_TrayPort_XML_INSTSPECIFIER_RAW] PRIMARY KEY CLUSTERED 
(
	[sno] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO


