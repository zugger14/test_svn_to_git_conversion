/****** Object:  Table [dbo].[Gis_Certificate]    Script Date: 11/05/2009 15:20:33 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Gis_Certificate]') AND type in (N'U'))
ALTER TABLE dbo.Gis_Certificate
ALTER COLUMN certificate_number_from_int FLOAT NULL

ALTER TABLE dbo.Gis_Certificate
ALTER COLUMN certificate_number_to_int FLOAT NULL




