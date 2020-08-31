IF object_id('marginal_var_whatif') IS  null
CREATE TABLE [dbo].[marginal_var_whatif](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[whatif_criteria_id] [int] NULL,
	[var_criteria_id] [int] NULL,
	[as_of_date] [datetime] NULL,
	[curve_id] [int] NULL,
	[term] [datetime] NULL,
	[MVaR] [float] NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [nchar](10) NULL,
	[MTM_value] [float] NULL,
	[MTM_value_C] [float] NULL,
	[MTM_value_I] [float] NULL,
	[MVaR_C] [float] NULL,
	[MVaR_I] [float] NULL,
 CONSTRAINT [PK_marginal_var_whatif] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO


