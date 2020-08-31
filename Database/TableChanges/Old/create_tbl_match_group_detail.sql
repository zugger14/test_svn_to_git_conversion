SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[match_group_detail]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].match_group_detail
    (
		match_group_detail_id INT IDENTITY(1, 1) NOT NULL
		, [match_group_id] INT
		, split_id INT
		, quantity NUMERIC(38,18)
		, source_commodity_id int
		, last_edited_by  VARCHAR(500)
		, last_edited_on DATETIME
		, scheduler  VARCHAR(500)
		, location INT
		, status  VARCHAR(500)
		, scheduled_from DATETIME
		, scheduled_to DATETIME
		, match_number  VARCHAR(500)
		, comments  VARCHAR(5000)
		, pipeline_cycle INT
		, consignee INT
		, carrier INT
		, po_number  VARCHAR(500)
		, container INT
		, estimated_movement_date DATETIME
		, scheduling_period VARCHAR(500)
		, notes VARCHAR(5000)
		, source_deal_detail_id INT
		, bookout_match CHAR(1)
		, is_complete CHAR(1)
		, line_up VARCHAR(500)
		, [create_user] VARCHAR(50) NULL DEFAULT dbo.FNADBUser()
		, [create_ts] DATETIME NULL DEFAULT GETDATE()
		, [update_user] VARCHAR(50) NULL
		, [update_ts] DATETIME NULL	
    )
END
ELSE
BEGIN
    PRINT 'Table match_group_detail EXISTS'
END
 
GO

