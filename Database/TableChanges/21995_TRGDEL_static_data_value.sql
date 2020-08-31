-- delete trigger
IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGDEL_static_data_value]'))
    DROP TRIGGER [dbo].[TRGDEL_static_data_value]
GO
 
CREATE TRIGGER [dbo].[TRGDEL_static_data_value]
ON [dbo].[static_data_value]
FOR DELETE
AS
BEGIN
    --release combov2 and UI keys using 'static_data_value's types to load dropdown options.
	DECLARE @cmbobj_source VARCHAR(MAX) = 'static_data_value'
	SELECT  @cmbobj_source =  @cmbobj_source + '||' +'StaticDataValues%h%'  + CAST(d.type_id AS VARCHAR(10))
	FROM DELETED d
	GROUP BY d.type_id

	IF  EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_manage_memcache]') AND TYPE IN (N'P', N'PC'))
	BEGIN	
		EXEC [spa_manage_memcache] @flag = 'd', @key_prefix = NULL, @cmbobj_key_source = @cmbobj_source, @other_key_source=NULL, @source_object = 'TRGDEL_static_data_value'
	END
END