IF NOT EXISTS (SELECT 1 FROM ice_interface_data WHERE data_type = 'ICE Trade')
BEGIN
	INSERT INTO ice_interface_data (ice_interface_data_id, data_type, description)
	SELECT 1,'ICE Trade','Trade Captured from ICE'
END

IF NOT EXISTS (SELECT 1 FROM ice_interface_data WHERE data_type = 'ICE Security Definition')
BEGIN
	INSERT INTO ice_interface_data (ice_interface_data_id, data_type, description)
	SELECT 2,'ICE Security Definition','Product Captured from ICE'
END	