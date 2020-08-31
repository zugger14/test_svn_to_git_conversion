/****** Object:  Table [dbo].[pfe_results]    Script Date: 2012-11-23 15:53:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pfe_results]') AND type in (N'U'))
BEGIN
	PRINT 'Table Already Exists'
END
ELSE
BEGIN
	/****** Object:  Table [dbo].[pfe_results]    Script Date: 2012-11-23 15:53:38 ******/
	CREATE TABLE [dbo].[pfe_results](
		[pfe_id] INT IDENTITY(1,1) NOT NULL,
		[as_of_date] DATETIME NULL,
		[counterparty_id] INT NULL,
		[counterparty] VARCHAR(100) NULL,
		[criteria_id] INT NULL,
		[criteria_name] VARCHAR(100) NULL,
		[measurement_approach] VARCHAR(100) NULL,
		[confidence_interval] VARCHAR(100) NULL,
		[fixed_exposure] FLOAT,
		[current_exposure] FLOAT,
		[pfe] FLOAT NULL,
		[total_future_exposure] FLOAT NULL,
	 CONSTRAINT [PK_pfe_results] PRIMARY KEY CLUSTERED 
	(
		[pfe_id] ASC
	)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
	) ON [PRIMARY]
	
	PRINT 'Table Successfully Created'
END	

GO

