/****** Object:  Table [dbo].[risk_tenor_bucket_header]    Script Date: 01/15/2010 17:32:08 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[risk_tenor_bucket_header]') AND type in (N'U'))
DROP TABLE [dbo].[risk_tenor_bucket_header]
GO
CREATE TABLE risk_tenor_bucket_header(
 bucket_header_id INT IDENTITY(1,1) NOT NULL,
 bucket_header_name VARCHAR(50)
CONSTRAINT [PK_bucket_header_id] PRIMARY KEY CLUSTERED 
(
	[bucket_header_id] ASC
)
) ON [PRIMARY]
GO