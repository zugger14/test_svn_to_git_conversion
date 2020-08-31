
--alter table  [dbo].[EDI_template_header]	add	no_of_lines_header_text int, no_of_lines_footer_text int
	

--alter table  [dbo].[EDI_template_detail]   add
--		no_of_lines_header_text int,
--		no_of_lines_footer_text int	,
--		no_of_lines_body_text int

--drop table   EDI_template_value_defination
--drop table EDI_template_detail
--drop table   EDI_template_header


if object_id('[EDI_template_header]') is null
	CREATE TABLE [dbo].[EDI_template_header](
		[EDI_template_header_id] [int] IDENTITY(1,1) NOT NULL,
		[effective_date] [datetime] NULL,
		[counterparty_id] [int] NULL,
		[EDI_version] [varchar](10) NULL,
		[EDI_text] [varchar](max) NULL,
		[deliminator] [char](1) NULL,
		[create_user] [varchar](50) NULL,
		[create_ts] [datetime] NULL,
		[update_user] [varchar](50) NULL,
		[update_ts] [datetime] NULL,
		[footer_EDI_text] [varchar](max) NULL
	) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]


IF COL_LENGTH('EDI_template_header', 'no_of_lines_header_text') IS NULL
BEGIN
    ALTER TABLE EDI_template_header ADD no_of_lines_header_text INT
END

IF COL_LENGTH('EDI_template_header', 'no_of_lines_footer_text') IS NULL
BEGIN
    ALTER TABLE EDI_template_header ADD no_of_lines_footer_text INT
END

IF COL_LENGTH('EDI_template_header', 'last_incremental_value') IS NULL
BEGIN
    ALTER TABLE EDI_template_header ADD last_incremental_value INT
END

GO

if object_id('[EDI_template_detail]') is null
	CREATE TABLE [dbo].[EDI_template_detail](
		[EDI_template_detail_id] [int] IDENTITY(1,1) NOT NULL,
		[EDI_template_header_id] [int] NULL,
		[EDI_template_desc] [varchar](100) NULL,
		[EDI_head_text] [varchar](max) NULL,
		[EDI_text] [varchar](max) NULL,
		[create_user] [varchar](50) NULL,
		[create_ts] [datetime] NULL,
		[update_user] [varchar](50) NULL,
		[update_ts] [datetime] NULL
	) ON [PRIMARY]

IF COL_LENGTH('EDI_template_detail', 'no_of_lines_header_text') IS NULL
BEGIN
    ALTER TABLE EDI_template_detail ADD no_of_lines_header_text INT
END
IF COL_LENGTH('EDI_template_detail', 'no_of_lines_footer_text') IS NULL
BEGIN
    ALTER TABLE EDI_template_detail ADD no_of_lines_footer_text INT
END
IF COL_LENGTH('EDI_template_detail', 'no_of_lines_body_text') IS NULL
BEGIN
    ALTER TABLE EDI_template_detail ADD no_of_lines_body_text INT
END

GO 

if object_id('[EDI_template_value_defination]') is null
CREATE TABLE [dbo].[EDI_template_value_defination](
	[EDI_template_value_position_id] [int] IDENTITY(1,1) NOT NULL,
	[EDI_template_header_id] [int] NULL,
	[EDI_template_detail_id] [int] NULL,
	[row_no] [int] NULL,
	[value_column_name] [varchar](50) NULL,
	[data_type] [varchar](1) NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
	[deliver_row_no] [int] NULL
) ON [PRIMARY]


  GO
  
  --"EDI_template_detail" table should have mapping for '[EDI_template_header_id]' column with "process_control_header" table.
--IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_EDI_template_detail_EDI_template_header]') AND parent_object_id = OBJECT_ID(N'[dbo].EDI_template_detail'))
--BEGIN

--	ALTER TABLE [dbo].EDI_template_detail WITH CHECK ADD CONSTRAINT [FK_EDI_template_detail_EDI_template_header] 
--	FOREIGN KEY([EDI_template_header_id])
--	REFERENCES [dbo].EDI_template_header ([EDI_template_header_id])


--END
		



TRUNCATE TABLE [dbo].[EDI_template_header]

SET IDENTITY_INSERT [EDI_template_header] ON		

INSERT INTO [dbo].[EDI_template_header]
( [EDI_template_header_id]
      ,[effective_date]
      ,[counterparty_id]
      ,[EDI_version]
      ,[EDI_text]
      ,[deliminator]
      ,[footer_EDI_text]  , no_of_lines_header_text ,
		no_of_lines_footer_text
 )
VALUES
 (1,'2010-08-01',4050,'X12','ISA~00~ ~00~ ~01~#1# ~01~#2# ~#3#~#4#~U~00304~#5#~0~T~|
GS~CU~#1#NMST~#2#NMST~#6#~#4#~#5#~X~004030
ST~873~000000001
BGN~00~43189~#6#~~~~G1
DTM~102~~~~DT~#7#
N1~78~~1~#1#
N1~SJ~~1~#2#
','~', 'SE~#total_line_number#~000000001
GE~1~#5#
IEA~1~#5#
',7,9)

SET IDENTITY_INSERT [EDI_template_header] OFF		

--SELECT '('+ CAST([EDI_template_header_id] AS VARCHAR)+',''2010-08-01'','
--+CAST([counterparty_id] AS VARCHAR)+'),''X12'',''' +[EDI_text] +''',''~'', '''+[footer_EDI_text] +'''),'
--  FROM [TRMTracker_New_Framework].[dbo].[EDI_template_header]

	


TRUNCATE TABLE [dbo].[EDI_template_detail]

SET IDENTITY_INSERT [EDI_template_detail] ON
	
INSERT INTO [dbo].[EDI_template_detail]
([EDI_template_detail_id]
      ,[EDI_template_header_id]
      ,[EDI_template_desc]
      ,[EDI_head_text]
      ,[EDI_text]
	  ,no_of_lines_header_text ,
		no_of_lines_footer_text ,
		no_of_lines_body_text
	  )
 VALUES 
 (1,1,'Threaded','DTM~007~~~~RD8~#12#-#13#
CS~#14#~~~NMT~T','SLN~#31#~~I
LQ~QT~R
LQ~TT~#16#
LQ~MRI~N
N9~PKG~#15#
N1~US~~ZZ~N/A
LCD~1~M2~~~DR~#17#
LQ~R2~#18#
QTY~38~#19#~BZ
N1~DW~~ZZ~N/A
LCD~1~MQ~~~DR~#20#
LQ~R3~#21#
',2,0,12),
(2,1,'Unthreaded','DTM~007~~~~RD8~#12#-#13#
CS~#14#~~~NMT~U','SLN~#31#~~I
LQ~QT~#26#
LQ~TT~#16#
LQ~MRI~N
N9~PKG~#15#
N1~#33#~~1~#32#
LCD~1~#29#~~~DR~#23#
N9~#24#~#25#
LQ~#28#~#27#
QTY~38~#19#~BZ
',2,0,10)

--SELECT '(' +CAST([EDI_template_detail_id]  AS VARCHAR) +','+CAST([EDI_template_header_id] AS VARCHAR)  +','''+[EDI_template_desc]+''','''+[EDI_head_text]+''','''+[EDI_text] +'''),'
-- FROM [dbo].[EDI_template_detail]

SET IDENTITY_INSERT [EDI_template_detail] OFF	




TRUNCATE TABLE [EDI_template_value_defination]	
		
SET IDENTITY_INSERT [EDI_template_value_defination] ON		
																	   
INSERT  INTO  [dbo].[EDI_template_value_defination]([EDI_template_value_position_id],[EDI_template_header_id],[EDI_template_detail_id],[value_column_name],[data_type])
VALUES
(1,1,null,'DUNS_shipper','t'),
(2,1,null,'DUNS_pipeline','t'),
(3,1,null,'yymmdd','t'),
(4,1,null,'hhmm','t'),
(5,1,null,'ssmcs','t'),
(6,1,null,'yyyymmdd','t'),
(7,1,null,'yyyymmddhhmm','t'),
(12,1,1,'from_term','t'),
(13,1,1,'to_term','t'),
(14,1,1,'contract_id','t'),
(15,1,1,'source_deal_header_id','t'),
(16,1,1,'udf_tran_type','t'),
(17,1,1,'leg_1_tsp_location','t'),
(18,1,1,'leg_1_loc_rank','t'),
(19,1,1,'deal_volume','t'),
(20,1,1,'leg_2_tsp_location','t'),
(21,1,1,'leg_2_loc_rank','t'),
(28,1,2,'deal_orientation','t'),
(23,1,2,'unthread_tsp_location','t'),
(24,1,2,'contract_steam','t'),
(25,1,2,'unthread_contract_id','t'),
(26,1,2,'unthread_type','t'),
(27,1,2,'unthread_location_rank','t'),
(29,1,2,'location_group','t'),
(30,1,2,'unthread_deal_id','t'),
(31,1,2,'source_deal_detail_id','t'),
(32,1,2,'customer_duns_number','t'),
(33,1,2,'US_DW','t')




 SET IDENTITY_INSERT [EDI_template_value_defination] OFF	


