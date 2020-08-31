
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF OBJECT_ID(N'[dbo].[Gis_Certificate]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[Gis_Certificate](
	[source_certificate_number] [int] IDENTITY(1,1) NOT NULL,
	[source_deal_header_id] [int] NULL,
	[gis_certificate_number_from] [varchar](100) NULL,
	[gis_certificate_number_to] [varchar](100) NULL,
	[certificate_number_from_int] [float] NULL,
	[certificate_number_to_int] [float] NULL,
	[gis_cert_date] [datetime] NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
	[year] [int] NULL,
	[state_value_id] [int] NULL,
	[tier_type] [int] NULL,
	[contract_expiration_date] [datetime] NULL,
 CONSTRAINT [PK_Gis_Certificate] PRIMARY KEY CLUSTERED 
(
	[source_certificate_number] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY],
 CONSTRAINT [IX_Gis_Certificate] UNIQUE NONCLUSTERED 
(
	[source_certificate_number] ASC,
	[source_deal_header_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END 
ELSE
	PRINT 'Already [dbo].[Gis_Certificate] exists'
GO

IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND   tc.Table_Name = 'Gis_Certificate'          --table name
                    AND ccu.COLUMN_NAME = 'source_deal_header_id'   --column name where FK constaint is to be created
)
BEGIN
	ALTER TABLE [dbo].[Gis_Certificate]  WITH NOCHECK ADD  CONSTRAINT [FK_Gis_Certificate_source_deal_detail] FOREIGN KEY([source_deal_header_id])
	REFERENCES [dbo].[source_deal_detail] ([source_deal_detail_id])
END 
ELSE 
	PRINT 'Already [FK_Gis_Certificate_source_deal_detail] exists'
GO






