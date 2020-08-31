if OBJECT_ID('hour_block_term') is not null
drop table [dbo].[hour_block_term]
GO

CREATE TABLE [dbo].[hour_block_term](
	[block_define_id] [int] NOT NULL,
	[block_type] [int] NOT NULL,
	[term_date] [datetime] NOT NULL,
	[hol_date] [datetime] NULL,
	[Hr1] [float] NULL,
	[Hr2] [float] NULL,
	[Hr3] [float] NULL,
	[Hr4] [float] NULL,
	[Hr5] [float] NULL,
	[Hr6] [float] NULL,
	[Hr7] [float] NULL,
	[Hr8] [float] NULL,
	[Hr9] [float] NULL,
	[Hr10] [float] NULL,
	[Hr11] [float] NULL,
	[Hr12] [float] NULL,
	[Hr13] [float] NULL,
	[Hr14] [float] NULL,
	[Hr15] [float] NULL,
	[Hr16] [float] NULL,
	[Hr17] [float] NULL,
	[Hr18] [float] NULL,
	[Hr19] [float] NULL,
	[Hr20] [float] NULL,
	[Hr21] [float] NULL,
	[Hr22] [float] NULL,
	[Hr23] [float] NULL,
	[Hr24] [float] NULL,
	[term_start] [datetime] NULL,
	[volume_mult] [float] NULL,
	[dst_applies] [varchar](1) NULL
)

IF EXISTS(SELECT 1 FROM sys.indexes WHERE [name]='indx_hour_block_term')
DROP INDEX indx_hour_block_term ON dbo.hour_block_term

GO

CREATE INDEX indx_hour_block_term ON dbo.hour_block_term([block_define_id],[block_type],[term_start] ,[term_date])