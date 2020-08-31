/****** Object:  Table [dbo].[risk_tenor_bucket_detail]    Script Date: 01/15/2010 17:32:08 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[risk_tenor_bucket_detail]') AND type in (N'U'))
DROP TABLE [dbo].[risk_tenor_bucket_header]
GO
CREATE TABLE risk_tenor_bucket_detail(
 bucket_detail_id INT IDENTITY(1,1) NOT NULL,
 bucket_header_id INT NOT NULL,
 tenor_name VARCHAR(50),
 tenor_description VARCHAR(100),
 tenor_from INT,
 tenor_to INT 
CONSTRAINT [PK_bucket_detail_id] PRIMARY KEY CLUSTERED 
(
	[bucket_detail_id] ASC
)
) ON [PRIMARY]
GO

IF OBJECT_ID('FK_bucket_header_id','F') IS NOT NULL
		ALTER TABLE [dbo].[risk_tenor_bucket_detail] DROP CONSTRAINT [FK_bucket_header_id]
	
IF OBJECT_ID('FK_bucket_header_id','F') IS NULL
	ALTER TABLE [dbo].[risk_tenor_bucket_detail] WITH NOCHECK ADD
	CONSTRAINT [FK_bucket_header_id] FOREIGN KEY ([bucket_header_id]) REFERENCES [dbo].[risk_tenor_bucket_header] ([bucket_header_id]) ON UPDATE CASCADE
	
