-- ===============================================================================================================
-- Create date: 2012-03-01
-- Description:	This script will drop all views & tables from ARCHIVE server 
-- IMPORTANT: This script should only run at archive server 
-- ===============================================================================================================


---To Drop All views 
DECLARE @viewName VARCHAR(500)
DECLARE cur CURSOR
      FOR SELECT [name] FROM sys.objects WHERE type = 'v'
      OPEN cur

      FETCH NEXT FROM cur INTO @viewName
      WHILE @@fetch_status = 0
      BEGIN
          --  EXEC('DROP VIEW ' + @viewName) --todo
            FETCH NEXT FROM cur INTO @viewName
      END
      CLOSE cur
      DEALLOCATE cur

-- To Drop All tables 

DECLARE @fkdel varchar(512)
DECLARE FkCrsr CURSOR FOR
SELECT 'ALTER TABLE [' + TABLE_SCHEMA + '].[' + TABLE_NAME +
'] DROP CONSTRAINT [' + CONSTRAINT_NAME +']'
FROM information_schema.table_constraints
WHERE CONSTRAINT_TYPE = 'FOREIGN KEY'

open FkCrsr
fetch next from FkCrsr into @fkdel
while @@FETCH_STATUS = 0
begin
print @fkdel
--exec (@fkdel)  --TODO
fetch next from FkCrsr into @fkdel
end

close FkCrsr
deallocate FkCrsr
go

--EXEC sp_msforeachtable 'DROP TABLE ?' --TODO