--select * from static_data_type order by type_id desc

--select * from static_data_type where type_name like '%status%'

IF NOT EXISTS ( SELECT 1 FROM static_data_type WHERE [type_id] = 39500)
BEGIN
	INSERT INTO static_data_type ([type_id], [type_name], internal,	[description]) VALUES (39500, 'Remit Status', 1,	'Remit Status')
END

SET IDENTITY_INSERT static_data_value ON

IF NOT EXISTS ( SELECT 1 FROM static_data_value WHERE [value_Id] = 39500)
BEGIN
	INSERT INTO static_data_value ([value_id], [type_id], code, [description]) VALUES (39500, 39500, 'ACER Outstanding', 'ACER Outstanding')
END

SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON

IF NOT EXISTS ( SELECT 1 FROM static_data_value WHERE [value_Id] = 39501)
BEGIN
	INSERT INTO static_data_value ([value_id], [type_id], code, [description]) VALUES (39501, 39500, 'ACER Submitted', 'ACER Submitted')
END

SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON

IF NOT EXISTS ( SELECT 1 FROM static_data_value WHERE [value_Id] = 39502)
BEGIN
	INSERT INTO static_data_value ([value_id], [type_id], code, [description]) VALUES (39502, 39500, 'ACER Verified', 'ACER Verified')
END

SET IDENTITY_INSERT static_data_value OFF