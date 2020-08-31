IF EXISTS (SELECT 1
  FROM sys.foreign_keys 
   WHERE object_id = OBJECT_ID(N'FK__fas_books__accou__4691B4CB')
   AND parent_object_id = OBJECT_ID(N'dbo.fas_books')
)
ALTER TABLE fas_books
DROP CONSTRAINT FK__fas_books__accou__4691B4CB

