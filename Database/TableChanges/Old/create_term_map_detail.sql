IF EXISTS (SELECT 1 FROM   sys.objects WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[term_map_detail]')AND TYPE IN (N'U'))
    DROP TABLE [dbo].[term_map_detail]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[term_map_detail]
(
	[term_map_id]              [int] IDENTITY(1, 1) NOT NULL,
	[term_code]                VARCHAR(100) NULL,	-- text field
	[date_or_block]            CHAR(1) NULL,	-- check box, possible [d,b]
	[term_start]               [datetime] NULL,
	[term_end]                 [datetime] NULL,
	[working_day_id]           [int] NULL,	-- static_data_type 2050
	[holiday_calendar_id]      [int] NULL,	-- static_data_type 10017
	[relative_days]            [int] NULL,	-- text field
	[no_of_days]               [int] NULL,	-- text field
	[holiday_include_exclude]  [char](1) NULL,
	[create_user]              [varchar](100) NULL,
	[create_ts]                [datetime] NULL,
	[update_user]              [varchar](100) NULL,
	[update_ts]                [datetime] NULL 
	CONSTRAINT [PK_term_map_detail] PRIMARY KEY CLUSTERED([term_map_id] ASC)WITH (
	    PAD_INDEX = OFF,
	    STATISTICS_NORECOMPUTE = OFF,
	    IGNORE_DUP_KEY = OFF,
	    ALLOW_ROW_LOCKS = ON,
	    ALLOW_PAGE_LOCKS = ON
	) ON [PRIMARY]
) ON [PRIMARY]


