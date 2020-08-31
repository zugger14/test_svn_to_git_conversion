/****** Object:  Table [dbo].[RWEST]    Script Date: 07/18/2011 23:30:32 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RWEST]') AND type in (N'U'))
DROP TABLE [dbo].[RWEST]
GO


/****** Object:  Table [dbo].[RWEST]    Script Date: 07/18/2011 23:30:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[RWEST](
	[Trade_Id] [varchar](150) NULL,
	[Status] [varchar](150) NULL,
	[Instrument] [varchar](100) NULL,
	[Toolset] [varchar](100) NULL,
	[buy_sell] [varchar](100) NULL,
	[reference] [varchar](100) NULL,
	[Int Bunit] [varchar](100) NULL,
	[CounterParty] [varchar](100) NULL,
	[Portfolio] [varchar](100) NULL,
	[Ext Pfolio] [varchar](100) NULL,
	[Trader] [varchar](100) NULL,
	[Ext Contact] [varchar](100) NULL,
	[Trade_Date] [varchar](100) NULL,
	[Energy_Vol ] [varchar](100) NULL,
	[Price] [varchar](100) NULL,
	[Currency] [varchar](100) NULL,
	[Ins Subtype] [varchar](100) NULL,
	[Broker] [varchar](100) NULL,
	[Start_Date] [varchar](100) NULL,
	[End_Date] [varchar](100) NULL,
	[Commodity] [varchar](100) NULL,
	[zone] [varchar](100) NULL,
	[pipeline] [varchar](100) NULL,
	[Delivery_Location] [varchar](100) NULL,
	[region] [varchar](100) NULL,
	[product] [varchar](100) NULL,
	[Commodity_Balance] [varchar](100) NULL,
	[External_Commodity_Balance] [varchar](100) NULL,
	[side_currency] [varchar](100) NULL,
	[settlement_type] [varchar](100) NULL,
	[unit_of_measure] [varchar](100) NULL,
	[ias39_scope] [varchar](100) NULL,
	[ias39_book] [varchar](100) NULL,
	[Price_Unit] [varchar](100) NULL,
	[Start Time] [varchar](100) NULL,
	[End time] [varchar](100) NULL,
	[Payment Currency] [varchar](100) NULL,
	[Settlement Currency] [varchar](100) NULL,
	[Holiday Schedule] [varchar](100) NULL,
	[Volume Type] [varchar](100) NULL,
	[Day  start time] [varchar](100) NULL,
	[Currency Conversion Ref Source] [varchar](100) NULL,
	[Currency Conversion Method] [varchar](100) NULL,
	[DST Handling] [varchar](100) NULL,
	[Entity] [varchar](100) NULL,
	[Strategy] [varchar](100) NULL,
	[Book] [varchar](100) NULL,
	[Organization] [varchar](100) NULL,
	[Primary Secondary] [varchar](100) NULL,
	[Energy_Unit] [varchar](50) NULL,
	[Index 1] [varchar](50) NULL,
	[Weight 1] [varchar](50) NULL,
	[Currency Index 1] [varchar](50) NULL,
	[Lagging 1] [varchar](50) NULL,
	[Index 2] [varchar](50) NULL,
	[Weight 2] [varchar](50) NULL,
	[Currency Index 2] [varchar](50) NULL,
	[Lagging 2] [varchar](50) NULL,
	[Index 3] [varchar](50) NULL,
	[Weight 3] [varchar](50) NULL,
	[Currency Index 3] [varchar](50) NULL,
	[Lagging 3] [varchar](50) NULL,
	[Index 4] [varchar](50) NULL,
	[Weight 4] [varchar](50) NULL,
	[Currency Index 4] [varchar](50) NULL,
	[Lagging 4] [varchar](50) NULL,
	[Adder] [varchar](50) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


