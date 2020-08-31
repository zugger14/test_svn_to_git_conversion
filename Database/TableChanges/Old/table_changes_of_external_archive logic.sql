
PRINT 'Script 1: Table changes....'


--Deleting Column temp_id from source_price_curve table
IF EXISTS(SELECT * FROM   sys.columns WHERE  [OBJECT_ID] = OBJECT_ID('source_price_curve') AND [name] = 'temp_id')
   ALTER TABLE source_price_curve
   DROP COLUMN temp_id
GO
------------------

---Alter Table process_table_archive_policy add columns fieldlist, wherefield, frequency_type, archieve_type_id
---Alter Column name upto_month to upto

IF not EXISTS(SELECT * FROM   sys.columns WHERE  [name] = 'fieldlist' AND OBJECT_NAME([OBJECT_ID]) = 'process_table_archive_policy')
	ALTER TABLE dbo.process_table_archive_policy ADD  fieldlist VARCHAR(500)
GO

IF not EXISTS(SELECT * FROM   sys.columns WHERE  [name] = 'wherefield' AND OBJECT_NAME([OBJECT_ID]) = 'process_table_archive_policy')
	ALTER TABLE dbo.process_table_archive_policy ADD  wherefield VARCHAR(100)
GO

IF not EXISTS(SELECT * FROM   sys.columns WHERE  [name] = 'frequency_type' AND OBJECT_NAME([OBJECT_ID]) = 'process_table_archive_policy')
	ALTER TABLE dbo.process_table_archive_policy ADD  frequency_type VARCHAR(1)
GO

IF not EXISTS(SELECT * FROM   sys.columns WHERE  [name] = 'archieve_type_id' AND OBJECT_NAME([OBJECT_ID]) = 'process_table_archive_policy')
	ALTER TABLE dbo.process_table_archive_policy ADD  archieve_type_id INT
GO

IF EXISTS(SELECT * FROM   sys.columns WHERE  [name] = 'upto_month' AND OBJECT_NAME([OBJECT_ID]) = 'process_table_archive_policy')
	EXEC sp_rename 'dbo.process_table_archive_policy.upto_month', 'upto', 'COLUMN'
GO
	
--------------------------

----Archieve Data Type
IF NOT EXISTS(SELECT * FROM static_data_type WHERE type_id = 2150)
BEGIN
	INSERT INTO static_data_type (TYPE_ID, TYPE_NAME, INTERNAL, DESCRIPTION)
	SELECT 2150, 'Archive Data', 1, 'Archive Data'
END
GO

SET IDENTITY_INSERT static_data_value ON
GO
IF NOT EXISTS(SELECT * FROM static_data_value WHERE value_id = 2150)
BEGIN
	INSERT INTO static_data_value (VALUE_ID, TYPE_ID, CODE, DESCRIPTION)
		SELECT 2150, 2150, 'Run Measurement Data', 'Run Measurement Data'
END

IF NOT EXISTS(SELECT * FROM static_data_value WHERE value_id = 2151)
BEGIN
	INSERT INTO static_data_value (VALUE_ID, TYPE_ID, CODE, DESCRIPTION)
		SELECT 2151, 2150, 'Run EMS Inventory Data', 'Run Emissions Inventory Data'
END


IF NOT EXISTS(SELECT * FROM static_data_value WHERE value_id = 2152)
BEGIN
	INSERT INTO static_data_value (VALUE_ID, TYPE_ID, CODE, DESCRIPTION)
		SELECT 2152, 2150, 'View Price', 'View Price'
END

IF NOT EXISTS(SELECT * FROM static_data_value WHERE value_id = 2153)
BEGIN
	INSERT INTO static_data_value (VALUE_ID, TYPE_ID, CODE, DESCRIPTION)
		SELECT 2153, 2150, 'Calc Invoice Data', 'Calc Invoice Data'
END
GO

SET IDENTITY_INSERT static_data_value ON
GO

-----------------------


--Insert Update Data in process_table_archive_policy
IF NOT EXISTS(select 1 from process_table_archive_policy WHERE tbl_name='source_deal_pnl' AND  prefix_location_table='_arch2')
BEGIN
	INSERT INTO process_table_archive_policy
  (
    tbl_name,
    prefix_location_table,
    upto,
    dbase_name,
    fieldlist,
    wherefield,
    frequency_type,
    archieve_type_id
  )
VALUES
  (
    'source_deal_pnl',
    '_arch2',
    0,
    NULL,
    '*',
    'pnl_as_of_date',
    'm',
    2150
  )
END


UPDATE process_table_archive_policy
SET    upto = CASE 
               WHEN prefix_location_table = '_arch1' THEN 1
               ELSE 0
          END,
   dbase_name = NULL,
   fieldlist = '*',
   wherefield = CASE 
                     WHEN tbl_name = 'source_deal_pnl' THEN 'pnl_as_of_date'
                     ELSE 'as_of_date'
                END,
   frequency_type = 'm',
   archieve_type_id = 2150


UPDATE process_table_archive_policy
SET
	fieldlist = '[netted_gl_entry_id],[as_of_date],[netting_parent_group_id],[netting_parent_group_name],[netting_group_name],[gl_number],[gl_account_name]
			,[debit_amount],[credit_amount],[discount_option],[create_user],[create_ts]'
WHERE tbl_name = 'report_netted_gl_entry'

UPDATE process_table_archive_policy
SET
	fieldlist = '[source_deal_pnl_id],[source_deal_header_id],[term_start],[term_end],[Leg],[pnl_as_of_date],[und_pnl],[und_intrinsic_pnl],[und_extrinsic_pnl]
	,[dis_pnl],[dis_intrinsic_pnl],[dis_extrinisic_pnl],[pnl_source_value_id],[pnl_currency_id],[pnl_conversion_factor]
	,[pnl_adjustment_value],[deal_volume],[create_user],[create_ts],[update_user],[update_ts],und_pnl_set'
WHERE tbl_name = 'source_deal_pnl'
------------------------------------------


----Create source_deal_pnl_arch2 table
/****** Object:  Table [dbo].[source_deal_pnl_arch2]    Script Date: 09/29/2010 11:38:05 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[source_deal_pnl_arch2]') AND type in (N'U'))
DROP TABLE [dbo].[source_deal_pnl_arch2]
GO
/****** Object:  Table [dbo].[source_deal_pnl_arch2]    Script Date: 09/29/2010 11:38:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[source_deal_pnl_arch2](
	[source_deal_pnl_id] [int]  NULL,
	[source_deal_header_id] [int] NOT NULL,
	[term_start] [datetime] NOT NULL,
	[term_end] [datetime] NOT NULL,
	[Leg] [int] NOT NULL,
	[pnl_as_of_date] [datetime] NOT NULL,
	[und_pnl] [float] NOT NULL,
	[und_intrinsic_pnl] [float] NOT NULL,
	[und_extrinsic_pnl] [float] NOT NULL,
	[dis_pnl] [float] NOT NULL,
	[dis_intrinsic_pnl] [float] NOT NULL,
	[dis_extrinisic_pnl] [float] NOT NULL,
	[pnl_source_value_id] [int] NOT NULL,
	[pnl_currency_id] [int] NOT NULL,
	[pnl_conversion_factor] [float] NOT NULL,
	[pnl_adjustment_value] [float] NULL,
	[deal_volume] [float] NULL,
	[create_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[update_ts] [datetime] NULL,
	[und_pnl_set] [float] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
-----Add column achieve_type_id in table close_measurement_books,and alter the triggers for table
-----Drop and add constraint
IF not  EXISTS(SELECT * FROM   sys.columns WHERE  [name] = 'archive_type_id' AND OBJECT_NAME([OBJECT_ID]) = 'close_measurement_books')
	ALTER TABLE dbo.close_measurement_books ADD  archive_type_id INT
GO

IF EXISTS (SELECT name FROM sysindexes WHERE name = 'indx_close_measurement_books') 
	DROP INDEX [dbo].[close_measurement_books].indx_close_measurement_books
GO
	CREATE UNIQUE INDEX [indx_close_measurement_books] ON  [dbo].[close_measurement_books] (as_of_date, archive_type_id)
GO
	UPDATE close_measurement_books SET	archive_type_id = 2150
GO

ALTER TRIGGER [TRGUPD_CLOSE_MEASUREMENT_BOOKS]
ON [dbo].[close_measurement_books]
FOR UPDATE
AS
UPDATE CLOSE_MEASUREMENT_BOOKS SET update_user = isnull(update_user,dbo.FNADBUser()), update_ts = getdate() where  CLOSE_MEASUREMENT_BOOKS.as_of_date in (select as_of_date from deleted)
GO

ALTER TRIGGER [TRGINS_CLOSE_MEASUREMENT_BOOKS]
ON [dbo].[close_measurement_books]
FOR INSERT
AS
UPDATE CLOSE_MEASUREMENT_BOOKS SET create_user = isnull(create_user,dbo.FNADBUser()), create_ts = getdate() where  CLOSE_MEASUREMENT_BOOKS.as_of_date in (select as_of_date from inserted)
GO

update process_table_archive_policy set dbase_name=null,upto=1,frequency_type='d',archieve_type_id=2152 where tbl_name='source_price_curve' and isnull(prefix_location_table,'')=''
update process_table_archive_policy set dbase_name='FARRMSArchival.TRMTracker_Essent',upto=90,frequency_type='d',archieve_type_id=2152 where tbl_name='source_price_curve' and prefix_location_table='_arch1'
update process_table_archive_policy set dbase_name='FARRMSArchival.TRMTracker_Essent',upto=-1,frequency_type='d',archieve_type_id=2152 where tbl_name='source_price_curve' and prefix_location_table='_arch2'