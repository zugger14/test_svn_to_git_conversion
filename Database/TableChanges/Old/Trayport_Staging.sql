/****** Object:  Table [dbo].[Trayport_Staging]    Script Date: 07/18/2011 23:29:05 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Trayport_Staging]') AND type in (N'U'))
DROP TABLE [dbo].[Trayport_Staging]
GO

/****** Object:  Table [dbo].[Trayport_Staging]    Script Date: 07/18/2011 23:29:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[Trayport_Staging](
	[staging_sno] [int] IDENTITY(1,1) NOT NULL,
	[Action] [varchar](50) NULL,
	[Trade_Id] [varchar](50) NULL,
	[RelationshipID] [varchar](50) NULL,
	[Price] [varchar](50) NULL,
	[Volume] [varchar](50) NULL,
	[DateTime] [datetime] NULL,
	[LastUpdate] [varchar](50) NULL,
	[AggressorCompany] [varchar](150) NULL,
	[AggressorCompanyID] [varchar](50) NULL,
	[AggressorTrader] [varchar](150) NULL,
	[AggressorTraderID] [varchar](50) NULL,
	[AggressorUser] [varchar](50) NULL,
	[AggressorUserID] [varchar](50) NULL,
	[AggressorAction] [varchar](50) NULL,
	[AggressorBroker] [varchar](150) NULL,
	[AggressorBrokerID] [varchar](50) NULL,
	[InitiatorCompany] [varchar](150) NULL,
	[InitiatorCompanyID] [varchar](50) NULL,
	[InitiatorTrader] [varchar](150) NULL,
	[InitiatorTraderID] [varchar](50) NULL,
	[InitiatorUser] [varchar](50) NULL,
	[InitiatorUserID] [varchar](50) NULL,
	[InitiatorAction] [varchar](50) NULL,
	[InitiatorBroker] [varchar](150) NULL,
	[InitiatorBrokerID] [varchar](50) NULL,
	[ClearingStatus] [varchar](50) NULL,
	[ClearingID] [varchar](50) NULL,
	[ManualDeal] [varchar](50) NULL,
	[VoiceDeal] [varchar](50) NULL,
	[InitSleeve] [varchar](50) NULL,
	[AggSleeve] [varchar](50) NULL,
	[PNC] [varchar](50) NULL,
	[PostTradeNegotiating] [varchar](50) NULL,
	[InitiatorOwnedSpread] [varchar](50) NULL,
	[AggressorOwnedSpread] [varchar](50) NULL,
	[UnderInvestigation] [varchar](50) NULL,
	[EngineID] [varchar](50) NULL,
	[OrderID] [varchar](50) NULL,
	[InstID] [nchar](10) NULL,
	[SeqSpan] [varchar](50) NULL,
	[FirstSequenceID] [varchar](50) NULL,
	[FirstSequenceItemID] [varchar](50) NULL,
	[SecondSequenceItemID] [varchar](50) NULL,
	[TermFormatID] [varchar](50) NULL,
	[InstName] [varchar](50) NULL,
	[FirstSequenceItemName] [varchar](50) NULL,
	[SecondSequenceItemName] [varchar](50) NULL,
	[Trade_SNO] [int] NULL,
	[Create_ts] [datetime] NULL,
	[process_id] [varchar](150) NULL,
	[XML_FileName] [varchar](100) NULL,
	[term_start] [datetime] NULL,
	[term_end] [datetime] NULL,
	[last_proceed_ts] [datetime] NULL,
 CONSTRAINT [PK_Trayport_Staging] PRIMARY KEY CLUSTERED 
(
	[staging_sno] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


