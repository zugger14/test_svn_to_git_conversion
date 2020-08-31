IF OBJECT_id('ear_results_whatif') IS NOT NULL
BEGIN
	PRINT 'Table Already Exists'
END
ELSE
BEGIN
	CREATE TABLE [dbo].[ear_results_whatif](
		[id] [int] IDENTITY(1,1) NOT NULL,
		[whatif_criteria_id] INT,
		[as_of_date] [datetime] NULL,
		[var_criteria_id] [int] NULL,
		[ear] [float] NULL,
		[ear_c] [float] NULL,
		[ear_i] [float] NULL,
		[raroc1] [float] NULL,
		[raroc2] [float] NULL,
		[currency_id] [int] NULL,
		[create_user] [varchar](50) NULL,
		[create_ts] [nchar](10) NULL,
	CONSTRAINT [PK_ear_results_whatif] PRIMARY KEY CLUSTERED 
	(
	[id] ASC
	)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
	) ON [PRIMARY]

	ALTER TABLE [dbo].[ear_results_whatif]  WITH NOCHECK ADD  CONSTRAINT [FK_ear_results_whatif_source_currency] FOREIGN KEY([currency_id])
	REFERENCES [dbo].[source_currency] ([source_currency_id])
	
	ALTER TABLE [dbo].[ear_results_whatif] CHECK CONSTRAINT [FK_ear_results_whatif_source_currency]
END	