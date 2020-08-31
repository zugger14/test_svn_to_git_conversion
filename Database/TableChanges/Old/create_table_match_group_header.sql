SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
--drop table match_group_header
 
IF OBJECT_ID(N'[dbo].[match_group_header]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].match_group_header
    (
		[match_group_header_id]  INT IDENTITY(1, 1) NOT NULL
		, [match_group_id] INT
		, [match_group_shipment_id] INT
		, match_book_auto_id VARCHAR(MAX)
		, bookout_match_total_amount NUMERIC(38,18)
		, match_bookout CHAR(1)
		, source_minor_location_id INT
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
		, line_up VARCHAR(500)
		, commodity_origin_id INT 
		, commodity_form_id INT
		, organic CHAR(1)
		, commodity_form_attribute1	 INT 
		, commodity_form_attribute2	 INT 
		, commodity_form_attribute3	 INT 
		, commodity_form_attribute4	 INT 
		, commodity_form_attribute5  INT 		
		, estimated_movement_date DATETIME
		, [create_user]    VARCHAR(50) NULL DEFAULT dbo.FNADBUser()
		, [create_ts]      DATETIME NULL DEFAULT GETDATE()
		, [update_user]    VARCHAR(50) NULL
		, [update_ts]      DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table match_group_header EXISTS'
END
GO
