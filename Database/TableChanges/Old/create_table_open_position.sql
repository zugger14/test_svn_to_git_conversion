GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[open_position]') AND type in (N'U'))
DROP TABLE [dbo].[open_position]
go

CREATE TABLE [dbo].[open_position](
	open_position_id [INT]  IDENTITY(1,1),
	as_of_date DATETIME,
	source_deal_header_id int, 
	curve_id int,
	term_start date, 
	Hr tinyint,
	deal_volume_uom_id int,
	formula_breakdown bit,
	book_id int,
	--user_toublock_id int,
	--toublock_id int,
	counterparty_id int,
	position	numeric(26,10),
	maturity_hr datetime,
	maturity_mnth date,
	maturity_qtr date,
	maturity_semi date,
	maturity_yr date,
	commodity_id int,
	dst tinyint,
	source_system_book_id1 INT,
	source_system_book_id2 INT,
	source_system_book_id3 INT,
	source_system_book_id4 INT,
	location_id INT,
	create_user [VARCHAR](50) NULL DEFAULT([dbo].[FNADBUser]()),
	create_ts [DATETIME] NULL DEFAULT(GETDATE()),
	update_user [VARCHAR] (50) NULL,
	update_ts DATETIME NULL
	
) ON [PRIMARY]

SET ANSI_PADDING OFF
GO

