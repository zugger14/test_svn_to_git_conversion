IF OBJECT_ID('[var_probability_density]') IS NOT NULL
BEGIN
	PRINT 'Table Already Exists'
END
ELSE
BEGIN
	/****** Object:  Table [dbo].[var_probability_density]    Script Date: 10/12/2012 16:53:56 ******/
	CREATE TABLE [dbo].[var_probability_density](
		[id] [int] IDENTITY(1,1) NOT NULL,
		[var_criteria_id] [int] NULL,
		[as_of_date] [datetime] NULL,
		[counterparty] [int] NULL,
		[mtm_value] [float] NULL,
		[probab_den] [float] NULL,
		[create_user] [varchar](50) NULL,
		[create_ts] [datetime] NULL,
		[update_user] [varchar](50) NULL,
		[update_ts] [datetime] NULL
	 CONSTRAINT [PK_var_probability_density] PRIMARY KEY CLUSTERED 
	(
		[id] ASC
	)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
	) ON [PRIMARY]
	
	PRINT 'Table Successfully Created'
END	

GO

