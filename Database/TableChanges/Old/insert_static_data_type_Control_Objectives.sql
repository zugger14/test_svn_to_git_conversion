
IF NOT EXISTS (SELECT TOP 1 1 FROM static_data_type WHERE TYPE_ID = 16300)
	INSERT INTO  static_data_type (type_id, type_name, internal, description) VALUES (16300, 'Controls objectives', 0, 'Controls objectives')
GO
