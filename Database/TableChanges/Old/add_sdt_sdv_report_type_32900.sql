IF NOT EXISTS ( SELECT 1 FROM static_data_type WHERE [type_id] = 39400)
BEGIN
	INSERT INTO static_data_type ([type_id], [type_name], internal,	[description]) VALUES (39400, 'Report Type', 1,	'Report Type')
END

SET IDENTITY_INSERT static_data_value ON

IF NOT EXISTS ( SELECT 1 FROM static_data_value WHERE [value_Id] = 39400)
BEGIN
	INSERT INTO static_data_value ([value_id], [type_id], code, [description]) VALUES (39400, 39400, 'Non Standard', 'Non Standard')
END

SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON

IF NOT EXISTS ( SELECT 1 FROM static_data_value WHERE [value_Id] = 39401)
BEGIN
	INSERT INTO static_data_value ([value_id], [type_id], code, [description]) VALUES (39401, 39400, 'Standard', 'Standard')
END

SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON

IF NOT EXISTS ( SELECT 1 FROM static_data_value WHERE [value_Id] = 39402)
BEGIN
	INSERT INTO static_data_value ([value_id], [type_id], code, [description]) VALUES (39402, 39400, 'Transport', 'Transport')
END

SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON

IF NOT EXISTS ( SELECT 1 FROM static_data_value WHERE [value_Id] = 39403)
BEGIN
	INSERT INTO static_data_value ([value_id], [type_id], code, [description]) VALUES (39403, 39400, 'Transmission', 'Transmission')
END

SET IDENTITY_INSERT static_data_value OFF

--select * from static_Data_type order by 1 desc