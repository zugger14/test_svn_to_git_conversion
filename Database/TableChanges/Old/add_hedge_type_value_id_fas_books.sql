IF NOT EXISTS(SELECT 'x' FROM sys.[columns] c INNER JOIN sys.tables t ON c.[object_id] = t.[object_id] 
              WHERE t.[name] = 'fas_books' AND c.[name] = 'hedge_type_value_id')
BEGIN 
	ALTER TABLE fas_books ADD hedge_type_value_id INT 
	
END 

IF NOT EXISTS(SELECT 'x' FROM  sys.foreign_keys fk WHERE fk.object_id = object_id(N'[FK_fas_books_static_data_value_value_id]')
AND fk.parent_object_id = object_id(N'[dbo].[fas_books]') )
BEGIN 
ALTER TABLE fas_books WITH NOCHECK ADD CONSTRAINT
	[FK_fas_books_static_data_value_value_id] FOREIGN KEY([hedge_type_value_id])
	REFERENCES [dbo].[static_data_value] ([value_id])

ALTER TABLE [dbo].[fas_books] CHECK CONSTRAINT
[FK_fas_books_static_data_value_value_id]
END 	




