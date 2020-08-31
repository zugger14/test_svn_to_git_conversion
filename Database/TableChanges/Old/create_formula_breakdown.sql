if OBJECT_ID('formula_breakdown') is  null
CREATE TABLE [dbo].[formula_breakdown](
	[rowid] [int] IDENTITY(1,1) NOT NULL,
	[formula_id] [int] NULL,
	[nested_id] [tinyint] NULL,
	[formula_level] [int] NULL,
	[func_name] [varchar](100) NULL,
	[arg_no_for_next_func] [tinyint] NULL,
	[parent_nested_id] [int] NULL,
	[level_func_sno] [tinyint] NULL,
	[parent_level_func_sno] [tinyint] NULL,
	[arg1] [varchar](50) NULL,
	[arg2] [varchar](50) NULL,
	[arg3] [varchar](50) NULL,
	[arg4] [varchar](50) NULL,
	[arg5] [varchar](50) NULL,
	[arg6] [varchar](50) NULL,
	[arg7] [varchar](50) NULL,
	[arg8] [varchar](50) NULL,
	[arg9] [varchar](50) NULL,
	[arg10] [varchar](50) NULL,
	[arg11] [varchar](50) NULL,
	[arg12] [varchar](50) NULL,
	[eval_value] [float] NULL,
	[create_ts] [datetime] NULL
) ON [PRIMARY]



