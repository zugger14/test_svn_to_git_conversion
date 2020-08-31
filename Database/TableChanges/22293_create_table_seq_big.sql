 IF OBJECT_ID(N'dbo.seq_big', N'U') IS NOT NULL 
    DROP TABLE dbo.seq_big
    
-- Create and populate the sequence table with a million rows
 SELECT TOP 1000000 
        IDENTITY(INT, 1, 1) AS n
INTO dbo.seq_big
FROM Master.dbo.SysColumns sc1, Master.dbo.SysColumns sc2

-- Add a Primary Key to maximize performance
  ALTER TABLE dbo.seq_big
    ADD CONSTRAINT PK_seq_big_n
        PRIMARY KEY CLUSTERED (n) WITH FILLFACTOR = 100