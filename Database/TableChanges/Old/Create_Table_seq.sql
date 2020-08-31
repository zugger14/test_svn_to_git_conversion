 
 IF OBJECT_ID(N'dbo.seq', N'U') IS NOT NULL 
	DROP TABLE dbo.seq
	
-- Create and populate the sequence table
 SELECT TOP 11000 --equates to more than 30 years of dates
        IDENTITY(INT, 1, 1) AS n
   INTO dbo.seq
   FROM Master.dbo.SysColumns sc1, Master.dbo.SysColumns sc2

-- Add a Primary Key to maximize performance
  ALTER TABLE dbo.seq
    ADD CONSTRAINT PK_seq_n
        PRIMARY KEY CLUSTERED (n) WITH FILLFACTOR = 100