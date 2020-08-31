
PRINT 'Script 1: Table changes....'


--Deleting Column temp_id from source_price_curve table
IF EXISTS(SELECT * FROM   sys.columns WHERE  [OBJECT_ID] = OBJECT_ID('source_price_curve') AND [name] = 'temp_id')
   ALTER TABLE source_price_curve
   DROP COLUMN temp_id
GO
------------------

---Alter Table process_table_archive_policy add columns fieldlist, wherefield, frequency_type, archieve_type_id
---Alter Column name upto_month to upto

IF EXISTS(SELECT * FROM   sys.columns WHERE  [name] = 'fieldlist' AND OBJECT_NAME([OBJECT_ID]) = 'process_table_archive_policy')
	ALTER TABLE dbo.process_table_archive_policy
	DROP COLUMN  fieldlist
GO
	ALTER TABLE dbo.process_table_archive_policy ADD  fieldlist VARCHAR(500)
GO

IF EXISTS(SELECT * FROM   sys.columns WHERE  [name] = 'wherefield' AND OBJECT_NAME([OBJECT_ID]) = 'process_table_archive_policy')
	ALTER TABLE dbo.process_table_archive_policy
	DROP COLUMN  wherefield
GO
	ALTER TABLE dbo.process_table_archive_policy ADD  wherefield VARCHAR(100)
GO

IF EXISTS(SELECT * FROM   sys.columns WHERE  [name] = 'frequency_type' AND OBJECT_NAME([OBJECT_ID]) = 'process_table_archive_policy')
    ALTER TABLE dbo.process_table_archive_policy
	DROP COLUMN  frequency_type
GO
	ALTER TABLE dbo.process_table_archive_policy ADD  frequency_type VARCHAR(1)
GO

IF EXISTS(SELECT * FROM   sys.columns WHERE  [name] = 'archieve_type_id' AND OBJECT_NAME([OBJECT_ID]) = 'process_table_archive_policy')
    ALTER TABLE dbo.process_table_archive_policy
	DROP COLUMN  archieve_type_id
GO
	ALTER TABLE dbo.process_table_archive_policy ADD  archieve_type_id INT
GO


--------------------------
IF NOT EXISTS(SELECT 'X' FROM static_data_type where type_id=2175)
begin
	INSERT INTO static_data_type(type_id,type_name,internal,description) values ('2175','Dump Data','0','Dump Data')


	DELETE static_data_value where value_id IN(2151,2152,2153)

	set identity_insert static_data_value on
	insert into static_data_value(value_id,type_id,code,description) values(2175,2175,'source_price_curve','source_price_curve')
	set identity_insert static_data_value OFF
	

END 
-----------------------


--Insert Update Data in process_table_archive_policy
IF NOT EXISTS(select 1 from process_table_archive_policy WHERE tbl_name='source_price_curve' )
BEGIN
	INSERT INTO process_table_archive_policy
  (
    tbl_name,
    prefix_location_table,
    upto_month,
    dbase_name,
    fieldlist,
    wherefield,
    frequency_type,
    archieve_type_id
  )
VALUES
  (
    'source_price_curve',
    null,
    0,
    NULL,
    '*',
    'as_of_date',
    'm',
    2175
  )
  INSERT INTO process_table_archive_policy
  (
    tbl_name,
    prefix_location_table,
    upto_month,
    dbase_name,
    fieldlist,
    wherefield,
    frequency_type,
    archieve_type_id
  )
VALUES
  (
    'source_price_curve',
    '_arch1',
    0,
    NULL,
    '*',
    'as_of_date',
    'm',
    2175
  )
  INSERT INTO process_table_archive_policy
  (
    tbl_name,
    prefix_location_table,
    upto_month,
    dbase_name,
    fieldlist,
    wherefield,
    frequency_type,
    archieve_type_id
  )
VALUES
  (
    'source_price_curve',
    '_arch2',
    0,
    NULL,
    '*',
    'as_of_date',
    'm',
    2175
  )
  
END


GO
