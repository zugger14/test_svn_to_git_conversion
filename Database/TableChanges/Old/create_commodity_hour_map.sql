
/****** Object:  Table [dbo].[commodity_hour_map]    Script Date: 05/28/2011 11:20:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[commodity_hour_map]') AND type in (N'U'))
DROP TABLE [dbo].[commodity_hour_map]
go

CREATE TABLE [dbo].[commodity_hour_map](
	[commodity_id] [int] NULL,
	[term_date] [datetime] NULL,
	[is_start] [bit] NULL,
	[map_term_date] [datetime] NULL,
	[hour_from] [tinyint] NULL,
	[hour_to] [tinyint] NULL
) ON [PRIMARY]

GO


SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

BEGIN TRANSACTION;
INSERT INTO [dbo].[commodity_hour_map]([commodity_id], [term_date], [is_start], [map_term_date], [hour_from], [hour_to])
SELECT -1, '20000101 00:00:00.000', 1, '20000101 00:00:00.000', 7, 25 UNION ALL
SELECT -1, '20000101 00:00:00.000', 0, '20000102 00:00:00.000', 1, 6
COMMIT;
RAISERROR (N'[dbo].[commodity_hour_map]: Insert Batch: 1.....Done!', 10, 1) WITH NOWAIT;
GO
