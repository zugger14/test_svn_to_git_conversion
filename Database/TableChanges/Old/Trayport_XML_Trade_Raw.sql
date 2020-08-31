
/****** Object:  Table [dbo].[Trayport_XML_Trade_Raw]    Script Date: 07/18/2011 23:29:59 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Trayport_XML_Trade_Raw]') AND type in (N'U'))
DROP TABLE [dbo].[Trayport_XML_Trade_Raw]
GO
/****** Object:  Table [dbo].[Trayport_XML_Trade_Raw]    Script Date: 07/18/2011 23:29:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Trayport_XML_Trade_Raw](
	[sno] [int] IDENTITY(1,1) NOT NULL,
	[Action] [nvarchar](255) NULL,
	[Trade_Id] [nvarchar](255) NULL,
	[RelationshipID] [nvarchar](255) NULL,
	[Price] [nvarchar](255) NULL,
	[Volume] [nvarchar](255) NULL,
	[DateTime] [nvarchar](255) NULL,
	[LastUpdate] [nvarchar](255) NULL,
	[AggressorCompany] [nvarchar](255) NULL,
	[AggressorCompanyID] [nvarchar](255) NULL,
	[AggressorTrader] [nvarchar](255) NULL,
	[AggressorTraderID] [nvarchar](255) NULL,
	[AggressorUser] [nvarchar](255) NULL,
	[AggressorUserID] [nvarchar](255) NULL,
	[AggressorAction] [nvarchar](255) NULL,
	[AggressorBroker] [nvarchar](255) NULL,
	[AggressorBrokerID] [nvarchar](255) NULL,
	[InitiatorCompany] [nvarchar](255) NULL,
	[InitiatorCompanyID] [nvarchar](255) NULL,
	[InitiatorTrader] [nvarchar](255) NULL,
	[InitiatorTraderID] [nvarchar](255) NULL,
	[InitiatorUser] [nvarchar](255) NULL,
	[InitiatorUserID] [nvarchar](255) NULL,
	[InitiatorAction] [nvarchar](255) NULL,
	[InitiatorBroker] [nvarchar](255) NULL,
	[InitiatorBrokerID] [nvarchar](255) NULL,
	[ClearingStatus] [nvarchar](255) NULL,
	[ClearingID] [nvarchar](255) NULL,
	[ManualDeal] [nvarchar](255) NULL,
	[VoiceDeal] [nvarchar](255) NULL,
	[InitSleeve] [nvarchar](255) NULL,
	[AggSleeve] [nvarchar](255) NULL,
	[PNC] [nvarchar](255) NULL,
	[PostTradeNegotiating] [nvarchar](255) NULL,
	[InitiatorOwnedSpread] [nvarchar](255) NULL,
	[AggressorOwnedSpread] [nvarchar](255) NULL,
	[UnderInvestigation] [nvarchar](255) NULL,
	[EngineID] [nvarchar](255) NULL,
	[OrderID] [nvarchar](255) NULL,
	[Trade_SNO] [nvarchar](255) NULL,
 CONSTRAINT [PK_Trayport_XML_Trade_Raw] PRIMARY KEY CLUSTERED 
(
	[sno] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO


