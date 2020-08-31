select * from sys.partitions where object_name(object_id)='deal_detail_hour'
SELECT * FROM sys.partition_range_values

-- Crete file groups
ALTER DATABASE TRMTracker_Essent ADD FILEGROUP [FG1]
ALTER DATABASE TRMTracker_Essent ADD FILEGROUP [FG2]
ALTER DATABASE TRMTracker_Essent ADD FILEGROUP [FG3]
ALTER DATABASE TRMTracker_Essent ADD FILEGROUP [FG4]
ALTER DATABASE TRMTracker_Essent ADD FILEGROUP [FG5]
ALTER DATABASE TRMTracker_Essent ADD FILEGROUP [FG6]
ALTER DATABASE TRMTracker_Essent ADD FILEGROUP [FG7]
-- create files
ALTER DATABASE TRMTracker_Essent    
ADD FILE      
   (NAME = N'deal_file1',
        FILENAME = N'D:\SQLDataFiles\Secondary\deal_file1.ndf',
       SIZE = 1GB,
        MAXSIZE = 35GB,
  FILEGROWTH = 1GB) 
TO FILEGROUP [FG1]
GO
- create files
ALTER DATABASE TRMTracker_Essent    
ADD FILE      
   (NAME = N'deal_file2',
        FILENAME = N'D:\SQLDataFiles\Secondary\deal_file2.ndf',
       SIZE = 1GB,
        MAXSIZE = 35GB,
  FILEGROWTH = 1GB) 
TO FILEGROUP [FG2]
GO
-- create files
ALTER DATABASE TRMTracker_Essent    
ADD FILE      
   (NAME = N'deal_file3',
        FILENAME = N'D:\SQLDataFiles\Secondary\deal_file3.ndf',
       SIZE = 1GB,
        MAXSIZE = 35GB,
  FILEGROWTH = 1GB) 
TO FILEGROUP [FG3]
GO
-- create files
ALTER DATABASE TRMTracker_Essent    
ADD FILE      
   (NAME = N'deal_file4',
        FILENAME = N'D:\SQLDataFiles\Secondary\deal_file4.ndf',
       SIZE = 1GB,
        MAXSIZE = 35GB,
  FILEGROWTH = 1GB) 
TO FILEGROUP [FG4]
GO
-- create files
ALTER DATABASE TRMTracker_Essent    
ADD FILE      
   (NAME = N'deal_file5',
        FILENAME = N'D:\SQLDataFiles\Secondary\deal_file5.ndf',
       SIZE = 1GB,
        MAXSIZE = 35GB,
  FILEGROWTH = 1GB) 
TO FILEGROUP [FG5]
GO
--- create files
ALTER DATABASE TRMTracker_Essent    
ADD FILE      
   (NAME = N'deal_file6',
        FILENAME = N'D:\SQLDataFiles\Secondary\deal_file6.ndf',
       SIZE = 1GB,
        MAXSIZE = 35GB,
  FILEGROWTH = 1GB) 
TO FILEGROUP [FG6]
GO

ALTER DATABASE TRMTracker_Essent    
ADD FILE      
   (NAME = N'deal_file7',
        FILENAME = N'D:\SQLDataFiles\Secondary\deal_file7.ndf',
       SIZE = 1GB,
        MAXSIZE = 35GB,
  FILEGROWTH = 1GB) 
TO FILEGROUP [FG7]
GO
--drop PARTITION function [Data Partition Range]
-- create schema
CREATE PARTITION FUNCTION [Data Partition Range](DATETIME)
        AS RANGE LEFT FOR VALUES ('20110101 23:59:59.997',
								  '20110301 23:59:59.997',
								  '20110501 23:59:59.997',
 							      '20110701 23:59:59.997',
								  '20110901 23:59:59.997',
								  '20111101 23:59:59.997',
								  '20120101 23:59:59.997')

-- BInd with the schema
--DROP partition scheme [Data Partition Scheme]

CREATE PARTITION SCHEME [Data Partition Scheme]
        AS PARTITION [Data Partition Range]
        TO ([FG1], [FG2], [FG3],[FG4],[FG5],[FG6],[FG6],[FG7],[Primary]);

CREATE UNIQUE CLUSTERED INDEX IX_deal_detail_hour
	ON deal_detail_hour(term_date,deal_header_hour_id)
ON [Data Partition Scheme] (term_date);
GO

select * from sys.partitions where object_name(object_id)='deal_detail_hour'

-- Move data
Drop index IX_deal_detail_hour on deal_detail_hour with (Move To [Data Partition Scheme] (term_date) )

--DROP INDEX IX_source_deal_detail_id on deal_detail_hour
--
--select count(*) from source_deal_detail where term_start='2011-01-01'
--
--CREATE INDEX IX_source_deal_detail_id
--ON term_date asc, deal_detail_hour(source_deal_detail_id)

GO
