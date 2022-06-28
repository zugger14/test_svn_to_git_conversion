IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[application_notes]') 
					AND name = N'IDX_application_notes_internal_type_value_id_category_value_id')
BEGIN
     CREATE NONCLUSTERED INDEX [IDX_application_notes_internal_type_value_id_category_value_id] ON [dbo].[application_notes] (internal_type_value_id, category_value_id)
	 INCLUDE(notes_id, notes_object_id, parent_object_id)
END
GO
 