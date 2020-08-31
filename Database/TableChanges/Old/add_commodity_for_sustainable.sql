
IF NOT EXISTS(SELECT 'X' FROM source_commodity where source_commodity_id=-3)
BEGIN
	
	SET IDENTITY_INSERT source_commodity ON
	INSERT INTO source_commodity(source_commodity_id,source_system_id,commodity_id,commodity_desc)
	SELECT -3,2,'Sustainable','Sustainable'
	SET IDENTITY_INSERT source_commodity OFF
END
GO
