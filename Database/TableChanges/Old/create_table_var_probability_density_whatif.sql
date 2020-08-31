/****** Object:  Table [dbo].[var_probability_density_whatif]    
* Script Date: 04/08/2013 12:38:42 
* 
* ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF OBJECT_ID('var_probability_density_whatif') IS NULL
BEGIN
	CREATE TABLE [dbo].[var_probability_density_whatif](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[whatif_criteria_id] [int] NULL,
	[as_of_date] [datetime] NULL,
	[counterparty] [int] NULL,
	[mtm_value] [float] NULL,
	[probab_den] [float] NULL,
	[source_deal_header_id] [int] NULL,
	[measure] INT NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
	 CONSTRAINT [PK_var_probability_density_whatif] PRIMARY KEY CLUSTERED 
	(
		[id] ASC
	)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
	) ON [PRIMARY]
		
END
ELSE
	PRINT 'Table already exists'
	



