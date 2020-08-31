--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104813)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10104813, 'Privilege', 'Privilege Data Import/Export', 10106300, '', NULL, NULL, 0)
	PRINT ' Inserted 10104813 - Privilege.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10104813 - Privilege already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10102512)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10102512, 'Manage Privilege', 'Manage Privilege Setup Location', 10102500, '', NULL, NULL, 0)
	PRINT ' Inserted 10102512 - Manage Privilege.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10102512 - Manage Privilege already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10103012)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10103012, 'Manage Privilege', 'Manage Privilege', 10103000, '', NULL, NULL, 0)
	PRINT ' Inserted 10103012 - Manage Privilege.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10103012 - Manage Privilege already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10102612)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10102612, 'Manage Privilege', 'Manage Privilege Setup Price Curve', 10102600, '', NULL, NULL, 0)
	PRINT ' Inserted 10102612 - Manage Privilege.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10102612 - Manage Privilege already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101020)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10101020, 'Manage Privilege', 'Privilege', 10101000, '', NULL, NULL, 0)
	PRINT ' Inserted 10101020 - Manage Privilege.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101020 - Manage Privilege already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101910)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10101910, 'Add/Save/Delete', 'Add/Save/Delete', 10101900, '', NULL, NULL, 0)
	PRINT ' Inserted 10101910 - Add/Save/Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101910 - Add/Save/Delete already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101162)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10101162, 'Add/Save', 'Add/Save Confirmation Rule', 10101161, '', NULL, NULL, 0)
	PRINT ' Inserted 10101162 - Add/Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101162 - Add/Save already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101163)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10101163, 'Delete', 'Delete Confirmation Rule', 10101161, '', NULL, NULL, 0)
	PRINT ' Inserted 10101163 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101163 - Delete already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10111200)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10111200, 'Setup Workflow', 'Setup Workflow', NULL, '_users_roles/maintain_menu_item/maintain.menu.item.php', NULL, NULL, 0)
	PRINT ' Inserted 10111200 - Setup Workflow.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10111200 - Setup Workflow already EXISTS.'
END

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 10111200 AND sm.product_category = 10000000)
BEGIN
	INSERT INTO setup_menu(function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
	VALUES (10111200, 'Setup Workflow', 10110000, 1, 0, 0, 10000000)
	PRINT ' Setup Menu 10111200 inserted.'
END
ELSE
BEGIN
	PRINT 'Setup Menu 10111200 already EXISTS.'
END

--Update application_functions
UPDATE application_functions
	SET function_name = 'Setup Workflow',
		function_desc = 'Setup Workflow',
		func_ref_id = NULL,
		file_path = '_users_roles/maintain_menu_item/maintain.menu.item.php',
		function_parameter = NULL,
		module_type = NULL,
		book_required = 0
		WHERE [function_id] = 10111200
PRINT 'Updated Application Function.'

--Update setup_menu
UPDATE setup_menu
	SET display_name = 'Setup Workflow',
		parent_menu_id = 10110000,
		menu_type = 0,
		hide_show = 1
		WHERE [function_id] = 10111200
		AND [product_category]= 10000000
PRINT 'Updated Setup Menu.'

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104010)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10104010, 'Add/Save/Delete', '', 10104000, '', NULL, NULL, 0)
	PRINT ' Inserted 10104010 - Add/Save/Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10104010 - Add/Save/Delete already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104011)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10104011, 'Privilege', '', 10104000, '', NULL, NULL, 0)
	PRINT ' Inserted 10104011 - Privilege.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10104011 - Privilege already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131029)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10131029, 'Setup Generation', 'Setup Generation', 10131000, '', NULL, NULL, 0)
	PRINT ' Inserted 10131029 - Setup Generation.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131029 - Setup Generation already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131023)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10131023, 'Trade Ticket Back Office Sign Off', 'Trade Ticket Back Office Sign Off', 10131020, '', NULL, NULL, 0)
	PRINT ' Inserted 10131023 - Trade Ticket Back Office Sign Off.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131023 - Trade Ticket Back Office Sign Off already EXISTS.'
END


--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131020)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10131020, 'Trade Ticket', 'Trade Ticket', 10131000, '_deal_capturemaintain_deals	rade.ticket.php', NULL, NULL, 0)
	PRINT ' Inserted 10131020 - Trade Ticket.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131020 - Trade Ticket already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131021)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10131021, 'Trade Ticket Trader Sign Off', 'Trade Ticket Trader Sign Off', 10131020, '', NULL, NULL, 0)
	PRINT ' Inserted 10131021 - Trade Ticket Trader Sign Off.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131021 - Trade Ticket Trader Sign Off already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131022)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10131022, 'Trade Ticket Risk Sign Off', 'Trade Ticket Risk Sign Off', 10131020, '', NULL, NULL, 0)
	PRINT ' Inserted 10131022 - Trade Ticket Risk Sign Off.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131022 - Trade Ticket Risk Sign Off already EXISTS.'
END
--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131022)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10131022, 'Trade Ticket Risk Sign Off', 'Trade Ticket Risk Sign Off', 10131020, '', NULL, NULL, 0)
	PRINT ' Inserted 10131022 - Trade Ticket Risk Sign Off.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131022 - Trade Ticket Risk Sign Off already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131019)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10131019, 'Copy', 'Copy', 10131000, '', NULL, NULL, 1)
	PRINT ' Inserted 10131019 - Copy.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131019 - Copy already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10163603)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10163603, 'Book Out', 'Book Out Deals', 10163600, '', NULL, NULL, 0)
	PRINT ' Inserted 10163603 - Book Out.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10163603 - Book Out already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10164300)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10164300, 'EDI', 'EDI', NULL, '_scheduling_delivery/EDI/edi.php', NULL, NULL, 0)
	PRINT ' Inserted 10164300 - EDI.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10164300 - EDI already EXISTS.'
END

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 10164300 AND sm.product_category = 10000000)
BEGIN
	INSERT INTO setup_menu(function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
	VALUES (10164300, 'Nomination EDI', 10161499, 1, 0, 0, 10000000)
	PRINT ' Setup Menu 10164300 inserted.'
END
ELSE
BEGIN
	PRINT 'Setup Menu 10164300 already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10161810)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10161810, 'Add/Save', 'Power Outage IU', 10161800, '', NULL, NULL, 0)
	PRINT ' Inserted 10161810 - Add/Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10161810 - Add/Save already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10161811)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10161811, 'Delete', 'Power Outage Delete', 10161800, '', NULL, NULL, 0)
	PRINT ' Inserted 10161811 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10161811 - Delete already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101126)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10101126, 'Add/Save', 'Enhancement Tab IU', 10101125, '', NULL, NULL, 0)
	PRINT ' Inserted 10101126 - Add/Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101126 - Add/Save already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101127)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10101127, 'Delete', 'Delete Enhancement Tab', 10101125, '', NULL, NULL, 0)
	PRINT ' Inserted 10101127 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101127 - Delete already EXISTS.'
END

 --Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101130)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10101130, 'Add/Save', 'Add/Save', 10101128, '', NULL, NULL, 0)
	PRINT ' Inserted 10101130 - Add/Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101130 - Add/Save already EXISTS.'
END

 --Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101131)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10101131, 'Delete', 'Delete Limit', 10101128, '', NULL, NULL, 0)
	PRINT ' Inserted 10101131 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101131 - Delete already EXISTS.'
END

 --Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10181210)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10181210, 'Add/Save', 'Run At Risk Measurement IU', 10181200, '', NULL, NULL, 0)
	PRINT ' Inserted 10181210 - Add/Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10181210 - Add/Save already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10181212)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10181212, 'Delete', 'Delete Run At Risk Measurement', 10181200, '', NULL, NULL, 0)
	PRINT ' Inserted 10181212 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10181212 - Delete already EXISTS.'
END

  --Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10181213)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10181213, 'Run', 'Run - Run At Risk Measurement', 10181200, '', NULL, NULL, 0)
	PRINT ' Inserted 10181213 - Run.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10181213 - Run already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10181310)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10181310, 'Add/Save', 'Maintain Limits IU', 10181300, '', NULL, NULL, 0)
	PRINT ' Inserted 10181310 - Add/Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10181310 - Add/Save already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10181315)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10181315, 'Delete', 'Delete Maintain Limits', 10181300, '', NULL, NULL, 0)
	PRINT ' Inserted 10181315 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10181315 - Delete already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10183210)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10183210, 'Add/Save', 'Setup Portfolio Group IU', 10183200, '', NULL, NULL, 1)
	PRINT ' Inserted 10183210 - Add/Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10183210 - Add/Save already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10183211)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10183211, 'Delete', 'Setup Portfolio Group Delete', 10183200, '', NULL, NULL, 1)
	PRINT ' Inserted 10183211 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10183211 - Delete already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10183010)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10183010, 'Add/Save', 'Maintain Monte Carlo Models', 10183000, '', NULL, NULL, 0)
	PRINT ' Inserted 10183010 - Add/Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10183010 - Add/Save already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10183011)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10183011, 'Delete', 'Maintain Monte Carlo Models', 10183000, '', NULL, NULL, 0)
	PRINT ' Inserted 10183011 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10183011 - Delete already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10182510)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10182510, 'Add/Save', 'Maintain What-If scenario IU', 10182500, '', NULL, NULL, 0)
	PRINT ' Inserted 10182510 - Add/Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10182510 - Add/Save already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10182511)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10182511, 'Delete', 'Delete Maintain What-If scenario', 10182500, '', NULL, NULL, 0)
	PRINT ' Inserted 10182511 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10182511 - Delete already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10183410)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10183410, 'Add/Save', 'Setup What if Criteria IU', 10183400, '', NULL, NULL, 0)
	PRINT ' Inserted 10183410 - Add/Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10183410 - Add/Save already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10183411)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10183411, 'Delete', 'Delete Setup What if Criteria', 10183400, '', NULL, NULL, 0)
	PRINT ' Inserted 10183411 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10183411 - Delete already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10183412)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10183412, 'Run', 'Run Setup What if Criteria', 10183400, '', NULL, NULL, 0)
	PRINT ' Inserted 10183412 - Run.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10183412 - Run already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10183412)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10183412, 'Run', 'Run Setup What if Criteria', 10183400, '', NULL, NULL, 0)
	PRINT ' Inserted 10183412 - Run.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10183412 - Run already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10183413)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10183413, 'Hypothetical', 'Hypothetical Setup What if Criteria', 10183400, '', NULL, NULL, 0)
	PRINT ' Inserted 10183413 - Hypothetical.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10183413 - Hypothetical already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10183414)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10183414, 'Add/Save', 'Hypothetical Add/save', 10183413, '', NULL, NULL, 0)
	PRINT ' Inserted 10183414 - Add/Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10183414 - Add/Save already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10183415)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10183415, 'Delete', 'Hypothetical Delete', 10183413, '', NULL, NULL, 0)
	PRINT ' Inserted 10183415 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10183415 - Delete already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101510)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10101510, 'Add/Save', 'Parent Netting Group IU', 10101500, '', NULL, NULL, 0)
	PRINT ' Inserted 10101510 - Add/Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101510 - Add/Save already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101511)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10101511, 'Delete', 'Delete Parent Netting Group', 10101500, '', NULL, NULL, 0)
	PRINT ' Inserted 10101511 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101511 - Delete already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211220)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10211220, 'Maintain Privilege', 'Maintain Privilege', 10211200, '', NULL, NULL, 0)
	PRINT ' Inserted 10211220 - Maintain Privilege.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211220 - Maintain Privilege already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10241110)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10241110, 'Add/Save', 'Apply Cash IU', 10241100, '', NULL, NULL, 0)
	PRINT ' Inserted 10241110 - Add/Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10241110 - Add/Save already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10241111)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10241111, 'Delete', 'Delete Apply Cash', 10241100, '', NULL, NULL, 0)
	PRINT ' Inserted 10241111 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10241111 - Delete already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10241112)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10241112, 'Write Off', 'Write Off Apply Cash', 10241100, '', NULL, NULL, 0)
	PRINT ' Inserted 10241112 - Write Off.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10241112 - Write Off already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10221315)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10221315, 'Finalize', 'invoice finalize privilege', 10221300, '', NULL, NULL, 0)
	PRINT ' Inserted 10221315 - Finalize.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10221315 - Finalize already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10237310)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10237310, 'Add/Save', 'View/Update Cum PNL Series IU', 10237300, '', NULL, NULL, 0)
	PRINT ' Inserted 10237310 - Add/Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10237310 - Add/Save already EXISTS.'
END
                                                                                                                                     --Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10237311)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10237311, 'Delete', 'Delete Cum PNL Series', 10237300, '', NULL, NULL, 0)
	PRINT ' Inserted 10237311 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10237311 - Delete already EXISTS.'
END
                                                       
--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10234610)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10234610, 'Run', 'Process First Day Gain/Loss Treatment', 10234600, '', NULL, NULL, 0)
	PRINT ' Inserted 10234610 - Run.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10234610 - Run already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10234612)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10234612, 'Revert', 'Delete First Day Gain/Loss Treatment', 10234600, '', NULL, NULL, 0)
	PRINT ' Inserted 10234612 - Revert.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10234612 - Revert already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10234110)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10234110, 'Delete', 'Delete Amortize Deferred AOCI', 10234100, '', NULL, NULL, 0)
	PRINT ' Inserted 10234110 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10234110 - Delete already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10234111)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10234111, 'Run', 'Amortize Amortize Deferred AOCI', 10234100, '', NULL, NULL, 0)
	PRINT ' Inserted 10234111 - Run.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10234111 - Run already EXISTS.'
END


--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10233010)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10233010, 'Delete', 'Delete Void Deal Data', 10233000, '', NULL, NULL, 0)
	PRINT ' Inserted 10233010 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10233010 - Delete already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10233718)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10233718, 'Delete', 'Delete Hedging RelationShip', 10233700, '', NULL, NULL, 0)
	PRINT ' Inserted 10233718 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10233718 - Delete already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10233720)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10233720, 'Copy', 'Copy Hedging RelationShip', 10233700, '', NULL, NULL, 0)
	PRINT ' Inserted 10233720 - Copy.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10233720 - Copy already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10233719)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10233719, 'Dedesignate', 'Dedesignate Hedging RelationShip', 10233700, '', NULL, NULL, 0)
	PRINT ' Inserted 10233719 - Dedesignate.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10233719 - Dedesignate already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10234010)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10234010, 'Revert', 'Delete Reclassify Hedge De-Designation', 10234000, '', NULL, NULL, 0)
	PRINT ' Inserted 10234010 - Revert.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10234010 - Revert already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10234011)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10234011, 'Run', 'Reclassify Date', 10234000, '', NULL, NULL, 0)
	PRINT ' Inserted 10234011 - Run.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10234011 - Run already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10231912)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10231912, 'Delete', 'Delete Setup Hedging Relationship Types', 10231900, '', NULL, NULL, 0)
	PRINT ' Inserted 10231912 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10231912 - Delete already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10234511)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10234511, 'Delete', 'Delete View Outstanding Automation Results', 10234500, '', NULL, NULL, 0)
	PRINT ' Inserted 10234511 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10234511 - Delete already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10234512)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10234512, 'Approve', 'Approve Relationships View Outstanding Automation Results', 10234500, '', NULL, NULL, 0)
	PRINT ' Inserted 10234512 - Approve.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10234512 - Approve already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10234514)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10234514, 'Finalize', 'Finalized Approved Transactions', 10234500, '', NULL, NULL, 0)
	PRINT ' Inserted 10234514 - Finalize.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10234514 - Finalize already EXISTS.'
END

UPDATE 
application_functions 
SET
function_name = 'Regulatory Submission'
WHERE
function_id = 10164300



--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 12101724)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (12101724, 'Map Meter ID', 'MAP Meter ID', 12101700, '', NULL, NULL, 0)
	PRINT ' Inserted 12101700 - Map Meter ID.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 12101700 - Map Meter ID already EXISTS.'
END

Update
application_functions
set
func_ref_id = 12101724,
function_name = 'Add/Save'
where
function_id = 12101725


Update
application_functions
set
func_ref_id = 12101724,
function_name = 'Delete'
where
function_id = 12101726




