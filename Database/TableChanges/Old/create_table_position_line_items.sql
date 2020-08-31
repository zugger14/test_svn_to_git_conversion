GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[position_line_items]') AND type in (N'U'))
DROP TABLE [dbo].[position_line_items]
go

CREATE TABLE [dbo].[position_line_items](
	position_line_items_id [INT]  IDENTITY(1,1),
	item_type INT, -- 1: rsr, 2: open_pos, 3: premium, 4: fees 
	as_of_date DATETIME,
	term DATETIME, 
	book_id INT, 
	counterparty_id INT, 
	tou INT, 
	line_item VARCHAR(128), 
	[value] NUMERIC(38,20), 
	line_item_type VARCHAR(250),
	create_user [VARCHAR](50) NULL DEFAULT([dbo].[FNADBUser]()),
	create_ts [DATETIME] NULL DEFAULT(GETDATE()),
	update_user [VARCHAR] (50) NULL,
	update_ts DATETIME NULL
	
) ON [PRIMARY]

SET ANSI_PADDING OFF
GO

