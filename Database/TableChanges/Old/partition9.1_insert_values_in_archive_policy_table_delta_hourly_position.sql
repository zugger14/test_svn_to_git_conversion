-- ===============================================================================================================
-- Create date: 2012-03-01 
-- Description:	This script will insert row in process_table_archive_policy for source_price_curve table
-- THIS IS FOR MAIN SERVER
-- ===============================================================================================================


DECLARE @db_name VARCHAR(100)
SELECT @db_name = var_value FROM adiha_default_codes_values WHERE default_code_id = 46

IF NOT EXISTS(SELECT 1 FROM process_table_archive_policy  WHERE tbl_name = 'delta_report_hourly_position' AND prefix_location_table IS NULL)
BEGIN
INSERT INTO [TRMTracker_Essent].[dbo].[process_table_archive_policy]
           (
           [tbl_name]
           ,[prefix_location_table]
           ,[upto]
           ,[dbase_name]
           ,[fieldlist]
           ,[wherefield]
           ,[frequency_type]
           ,[archieve_type_id]
           ,[partition_status])
     VALUES
           (
           'delta_report_hourly_position'
           ,NULL
           ,1
           ,NULL
           ,'*'
           ,'term_start'
           ,'m'
           ,2152
           ,1)
END

IF NOT EXISTS(SELECT 1 FROM process_table_archive_policy  WHERE tbl_name = 'delta_report_hourly_position' AND prefix_location_table = '_arch1')
BEGIN

INSERT INTO [TRMTracker_Essent].[dbo].[process_table_archive_policy]
           (
           [tbl_name]
           ,[prefix_location_table]
           ,[upto]
           ,[dbase_name]
           ,[fieldlist]
           ,[wherefield]
           ,[frequency_type]
           ,[archieve_type_id]
           ,[partition_status])
     VALUES
           (
           'delta_report_hourly_position'
           ,'_arch1'
           ,90
           ,'FARRMS.ARCH.' +@db_name
           ,'*'
           ,'term_start'
           ,'m'
           ,2152
           ,NULL)
END

IF NOT EXISTS(SELECT 1 FROM process_table_archive_policy  WHERE tbl_name = 'delta_report_hourly_position' AND prefix_location_table = '_arch2')
BEGIN
INSERT INTO [TRMTracker_Essent].[dbo].[process_table_archive_policy]
           (
           [tbl_name]
           ,[prefix_location_table]
           ,[upto]
           ,[dbase_name]
           ,[fieldlist]
           ,[wherefield]
           ,[frequency_type]
           ,[archieve_type_id]
           ,[partition_status])
     VALUES
           (
           'delta_report_hourly_position'
           ,'_arch2'
           ,'-1'
           ,'FARRMS.ARCH.' + @db_name
           ,'*'
           ,'term_start'
           ,'m'
           ,2152
           ,NULL)
END