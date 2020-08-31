/*
* Insert data in static_data_type and static_data_value for deal confirm status
*/

IF NOT EXISTS ( SELECT * FROM static_data_type WHERE [type_id] = 17200)
BEGIN
	INSERT INTO static_data_type ([type_id], [type_name], internal,	[description]) VALUES (17200, 'Deal Confirm Status', 0,	'Deal Confirm Status')
END

SET IDENTITY_INSERT static_data_value ON

IF NOT EXISTS ( SELECT * FROM static_data_value WHERE [value_Id] = 17200)
BEGIN
	INSERT INTO static_data_value ([value_id], [type_id], code, [description]) VALUES (17200, 17200, 'Not Confirmed', 'Not Confirmed')
END

IF NOT EXISTS ( SELECT * FROM static_data_value WHERE [value_Id] = 17201)
BEGIN
	INSERT INTO static_data_value ([value_id], [type_id], code, [description]) VALUES (17201, 17200, 'Dispute', 'Dispute')
END

IF NOT EXISTS ( SELECT * FROM static_data_value WHERE [value_Id] = 17202)
BEGIN
	INSERT INTO static_data_value ([value_id], [type_id], code, [description]) VALUES (17202, 17200, 'Confirmation Executed', 'Confirmation Executed')
END

IF NOT EXISTS ( SELECT * FROM static_data_value WHERE [value_Id] = 17203)
BEGIN
	INSERT INTO static_data_value ([value_id], [type_id], code, [description]) VALUES (17203, 17200, 'Updated', 'Updated')
END

IF NOT EXISTS ( SELECT * FROM static_data_value WHERE [value_Id] = 17204)
BEGIN
	INSERT INTO static_data_value ([value_id], [type_id], code, [description]) VALUES (17204, 17200, 'Unknown Status', 'Unknown Status')
END

SET IDENTITY_INSERT static_data_value OFF