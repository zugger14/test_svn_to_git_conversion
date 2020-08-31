TRUNCATE TABLE [dbo].[setup_menu]

SET IDENTITY_INSERT [dbo].[setup_menu] ON 

GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1, 10000000, NULL, N'TRMTracker', NULL, 1, NULL, 10000000, 1, 1, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (2, 10100000, NULL, N'Setup ', NULL, 1, 10000000, 10000000, 2, 1, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3, 10101099, NULL, N'Reference Data', NULL, 1, 10100000, 10000000, 1, 1, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (4, 10101000, NULL, N'Setup Static Data', NULL, 1, 10101099, 10000000, 2, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (6, 10101200, NULL, N'Setup Book Structure', NULL, 1, 10101099, 10000000, 3, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (7, 10102600, NULL, N'Setup Price Curve', NULL, 1, 10101099, 10000000, 4, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (8, 10102500, NULL, N'Setup Location', NULL, 1, 10101099, 10000000, 5, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (10, 10101300, NULL, N'Setup GL Code', NULL, 1, 15190000, 10000000, 10, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (19, 10101600, NULL, N'View Scheduled Job', NULL, 1, 10100000, 10000000, 19, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (20, 10103000, NULL, N'Setup Meter', NULL, 1, 10101099, 10000000, 20, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (22, 10103399, NULL, N'Setup Contract Components ', NULL, 0, 10100000, 10000000, 21, 1, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (23, 10103300, NULL, N'Setup GL Group', NULL, 1, 15190000, 10000000, 22, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (24, 10103400, NULL, N'Setup Default GL Group', NULL, 1, 15190000, 10000000, 23, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (25, 10104300, NULL, N'Setup Contract Component Mapping', NULL, 1, 10210000, 10000000, 24, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (29, 10102900, NULL, N'Manage Document', NULL, 1, 10100000, 10000000, 27, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (32, 10102400, NULL, N'Formula Builder', NULL, 1, 10104099, 10000000, 29, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (37, 13102000, NULL, N'Generic Mapping', NULL, 1, 10106499, 10000000, 34, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (42, 10110000, NULL, N'User and Role', NULL, 1, 10000000, 10000000, 42, 1, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (43, 10111000, NULL, N'Setup User', NULL, 1, 10110000, 10000000, 40, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (44, 10111100, NULL, N'Setup Role', NULL, 1, 10110000, 10000000, 41, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (45, 10111200, NULL, N'Customize Menu', NULL, 1, 10110000, 10000000, 42, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (57, 10121600, NULL, N'View Compliance Activities', NULL, 0, 10122300, 10000000, 54, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (58, 10121700, NULL, N'View Status On Compliance Activities', NULL, 0, 10122300, 10000000, 55, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (59, 10122200, NULL, N'View Compliance Calendar', NULL, 0, 10122300, 10000000, 56, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (60, 10121800, NULL, N'Run Compliance Activity Audit Report', NULL, 0, 10122300, 10000000, 57, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (61, 10121900, NULL, N'Run Compliance Trend Report', NULL, 0, 10122300, 10000000, 58, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (62, 10122000, NULL, N'Run Compliance Graph Report', NULL, 0, 10122300, 10000000, 59, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (63, 10122100, NULL, N'Run Compliance Status Graph Report', NULL, 0, 10122300, 10000000, 60, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (64, 10122400, NULL, N'Run Compliance Due Date Violation Report', NULL, 0, 10122300, 10000000, 61, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (66, 10130000, NULL, N'Deal Capture', NULL, 1, 10000000, 10000000, 66, 1, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (67, 10131000, NULL, N'Create and View Deal', NULL, 1, 10130000, 10000000, 50, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (81, 10150000, NULL, N'Price Curve/Time Series', NULL, 1, 10000000, 10000000, 81, 1, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (82, 10151000, NULL, N'View Price', NULL, 1, 10150000, 10000000, 62, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (84, 10160000, NULL, N'Scheduling And Delivery', NULL, 1, 10000000, 10000000, 84, 1, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (86, 10161100, NULL, N'Setup Delivery Path', NULL, 1, 10161199, 10000000, 67, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (87, 10162000, NULL, N'Setup Transportation Rate Schedule', NULL, 1, 10161199, 10000000, 68, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (95, 10162300, NULL, N'Setup Storage Asset', NULL, 1, 10161399, 10000000, 72, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (108, 10181100, NULL, N'Run MTM Report', NULL, 0, 10181099, 10000000, 86, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (109, 10182200, NULL, N'Run Counterparty MTM report', NULL, 0, 10181099, 10000000, 87, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (145, 10200000, NULL, N'Reporting', NULL, 1, 10000000, 10000000, 145, 1, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (150, 10201600, NULL, N'Report Manager - Old', NULL, 1, 10200000, 10000000, 125, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (153, 10210000, NULL, N'Contract Administration', NULL, 1, 10000000, 10000000, 153, 1, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (154, 10211200, NULL, N'Setup Standard Contract', NULL, 1, 10210000, 10000000, 135, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (155, 10211400, NULL, N'Setup Transportation Contract', NULL, 1, 10210000, 10000000, 137, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (157, 10211100, NULL, N'Setup Contract Component Template', NULL, 1, 10210000, 10000000, 138, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (158, 10220000, NULL, N'Settlement And Billing', NULL, 1, 10000000, 10000000, 158, 1, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (160, 10221000, NULL, N'Process Invoice', NULL, 1, 10220000, 10000000, 140, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (161, 10222300, NULL, N'Run Deal Settlement', NULL, 1, 10220000, 10000000, 141, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (163, 10221300, NULL, N'View Invoice', NULL, 1, 10220000, 10000000, 143, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (183, 10232000, NULL, N'Run Hedging Relationship Types Report', NULL, 0, 10230098, 10000000, 221, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (184, 10101500, NULL, N'Setup Netting Group', NULL, 1, 15190000, 10000000, 222, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (187, 10232400, NULL, N'View Assessment Results', NULL, 1, 10230096, 10000000, 209, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (193, 10232800, NULL, N'Run Import Audit Report', NULL, 1, 10230097, 10000000, 215, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (200, 10233900, NULL, N'Run Hedging Relationship Report', NULL, 1, 10230095, 10000000, 198, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (203, 10234200, NULL, N'Life Cycle of Hedges', NULL, 1, 10230095, 10000000, 201, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (204, 10234300, NULL, N'Automation of Forecasted Transaction', NULL, 1, 10230095, 10000000, 202, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (216, 10233600, NULL, N'Close Settlement Accounting Period', NULL, 1, 10220000, 10000000, 193, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (250, 13000000, NULL, N'FASTracker', NULL, 1, NULL, 13000000, 1, 1, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (251, 10100000, NULL, N'Setup ', NULL, 1, 13000000, 13000000, 2, 1, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (252, 10101099, NULL, N'Reference Data', NULL, 1, 10100000, 13000000, 3, 1, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (253, 10101000, NULL, N'Setup Static Data', NULL, 1, 10101099, 13000000, 4, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (255, 10101200, NULL, N'Setup Book Structure', NULL, 1, 10101099, 13000000, 6, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (256, 10102600, NULL, N'Setup Price Curve', NULL, 1, 10101099, 13000000, 7, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (257, 10102500, NULL, N'Setup Location', NULL, 1, 10101099, 13000000, 8, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (259, 10101300, NULL, N'Setup GL Code', NULL, 1, 10100000, 13000000, 10, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (261, 10101400, NULL, N'Setup Deal Template', NULL, 1, 10104099, 10000000, 12, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (268, 10101600, NULL, N'View Scheduled Job', NULL, 1, 10100000, 13000000, 19, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (278, 10102900, NULL, N'Manage Document', NULL, 1, 10100000, 13000000, 29, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (281, 10102400, NULL, N'Formula Builder', NULL, 1, 10104099, 13000000, 32, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (283, 10103100, NULL, N'Term Mapping ', NULL, 1, 13170000, 13000000, 34, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (284, 10103200, NULL, N'Pratos Mapping', NULL, 1, 13170000, 13000000, 35, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (285, 13171000, NULL, N'ST Forecast Mapping', NULL, 1, 13170000, 13000000, 36, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (287, 10102700, NULL, N'Archive Data', NULL, 1, 10102799, 13000000, 38, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (288, 10103600, NULL, N'Remove Data', NULL, 1, 10102799, 13000000, 39, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (289, 10110000, NULL, N'User and Role', NULL, 1, 13000000, 13000000, 40, 1, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (290, 10111000, NULL, N'Setup User', NULL, 1, 10110000, 13000000, 41, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (291, 10111100, NULL, N'Setup Role', NULL, 1, 10110000, 13000000, 42, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (292, 10111200, NULL, N'Setup Workflow', NULL, 1, 10110000, 13000000, 43, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (296, 10111600, NULL, N'Maintain Events Rules', NULL, 1, 10110001, 13000000, 47, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (298, 10121300, NULL, N'Maintain Compliance Standards', NULL, 1, 10120000, 13000000, 49, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (299, 10121000, NULL, N'Maintain Compliance Groups', NULL, 0, 10100000, 10000000, 50, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (300, 10121400, NULL, N'Activity Process Map', NULL, 1, 10120000, 13000000, 51, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (301, 10121500, NULL, N'Change Owners', NULL, 1, 10120000, 13000000, 52, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (302, 10121200, NULL, N'Perform Compliance Activities', NULL, 1, 10120000, 13000000, 53, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (303, 10121100, NULL, N'Approve Compliance Activities', NULL, 1, 10120000, 13000000, 54, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (304, 10122300, NULL, N'Reports', NULL, 1, 10120000, 13000000, 55, 1, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (305, 10121600, NULL, N'View Compliance Activities', NULL, 1, 10122300, 13000000, 56, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (306, 10121700, NULL, N'View Status On Compliance Activities', NULL, 1, 10122300, 13000000, 57, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (307, 10122200, NULL, N'View Compliance Calendar', NULL, 1, 10122300, 13000000, 58, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (308, 10121800, NULL, N'Run Compliance Activity Audit Report', NULL, 1, 10122300, 13000000, 59, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (309, 10121900, NULL, N'Run Compliance Trend Report', NULL, 1, 10122300, 13000000, 60, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (310, 10122000, NULL, N'Run Compliance Graph Report', NULL, 1, 10122300, 13000000, 61, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (311, 10122100, NULL, N'Run Compliance Status Graph Report', NULL, 1, 10122300, 13000000, 62, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (312, 10122400, NULL, N'Run Compliance Due Date Violation Report', NULL, 1, 10122300, 13000000, 63, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (313, 10130000, NULL, N'Deal Capture', NULL, 1, 13000000, 13000000, 64, 1, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (321, 10131300, NULL, N'Import Data', NULL, 1, 13180000, 13000000, 72, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (324, 10233000, NULL, N'Delete Voided Deal', NULL, 1, 13180000, 13000000, 75, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (326, 10231997, NULL, N'Hedging Strategy', NULL, 1, 13190000, 13000000, 77, 1, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (327, 10231900, NULL, N'Setup Hedging Relationship Type', NULL, 1, 10231997, 13000000, 78, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (330, 10233700, NULL, N'Designation of a Hedge', NULL, 1, 12192099, 13000000, 81, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (332, 10234300, NULL, N'Automation of Forecasted Transaction', NULL, 1, 12192099, 13000000, 83, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (333, 10234400, NULL, N'Automate Hedge Matching', NULL, 1, 12192099, 13000000, 84, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (334, 10234500, NULL, N'View Outstanding Automation Result', NULL, 1, 12192099, 13000000, 85, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (336, 10234100, NULL, N'Amortize Deferred AOCI', NULL, 1, 12192099, 13000000, 87, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (339, 10234000, NULL, N'Reclassify Hedge De-Designation', NULL, 1, 12193099, 13000000, 90, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (342, 10151000, NULL, N'View Price', NULL, 1, 13200000, 13000000, 93, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (343, 10232300, NULL, N'Hedge Effectiveness Assessment', NULL, 1, 13200000, 13000000, 94, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (345, 10237300, NULL, N'View/Update Cum PNL Series', NULL, 1, 13200000, 13000000, 96, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (349, 10233400, NULL, N'Run Measurement Process', NULL, 1, 13210000, 13000000, 100, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (350, 10181000, NULL, N'Run MTM Process', NULL, 1, 13210000, 13000000, 101, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (353, 10233300, NULL, N'Copy Prior MTM Value', NULL, 1, 13210000, 13000000, 104, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (354, 10234600, NULL, N'First Day Gain/Loss Treatment', NULL, 1, 13210000, 13000000, 105, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (356, 13121295, NULL, N'Reporting', NULL, 1, 13000000, 13000000, 107, 1, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (373, 10201000, NULL, N'Report Writer', NULL, 0, 13121295, 13000000, 124, 1, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (374, 10235499, NULL, N'Accounting', NULL, 1, 13000000, 13000000, 125, 1, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (376, 10237000, NULL, N'Setup Manual Journal Entry', NULL, 1, 10235499, 13000000, 127, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (379, 10237500, NULL, N'Close Accounting Period', NULL, 1, 10235499, 13000000, 130, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (800, 10104200, NULL, N'Setup Deal Field Template', NULL, 1, 10104099, 10000000, 13, 0, N'sa', CAST(0x0000A156013756D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1067, 10122500, NULL, N'Setup Advanced Workflow Rule', NULL, 1, 10106699, 10000000, 48, 0, N'farrms_admin', CAST(0x0000A18C014E57D3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1084, 13141000, NULL, N'Maintain Transactions Tagging', N'', 1, 10230095, 13000000, 0, 0, N'sa', CAST(0x0000A24B012E65F7 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1092, 13180000, NULL, N'ETRM Interface', N'', 1, 13000000, 13000000, 0, 1, N'sa', CAST(0x0000A34700C9F8A3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1093, 13190000, NULL, N'Hedge Management', N'', 1, 13000000, 13000000, 0, 1, N'sa', CAST(0x0000A34700C9F8A3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1094, 13200000, NULL, N'Hedge Effectivenesss Testing', N'', 1, 13000000, 13000000, 0, 1, N'sa', CAST(0x0000A34700C9F8A3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1095, 13210000, NULL, N'Hedge Ineffectivenesss Measurement', N'', 1, 13000000, 13000000, 0, 1, N'sa', CAST(0x0000A34700C9F8A3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1098, 12192099, NULL, N'Hedge Designation', N'', 1, 13190000, 13000000, 0, 1, N'sa', CAST(0x0000A34700C9F8A5 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1099, 12193099, NULL, N'Hedge De-Designation', N'', 1, 13190000, 13000000, 0, 1, N'sa', CAST(0x0000A34700C9F8A5 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1107, 10202200, NULL, N'View Report', N'', 1, 10200000, 10000000, 133, 0, N'sa', CAST(0x0000A43C0178A6F6 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1108, 10101182, NULL, N'Setup UOM Conversion', N'', 1, 10101099, 10000000, 8, 0, N'sa', CAST(0x0000A45F011A8F4C AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1109, 10211300, NULL, N'Setup Non Standard Contract', N'', 1, 10210000, 10000000, 136, 0, N'sa', CAST(0x0000A46F0041E707 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1110, 10105800, NULL, N'Setup Counterparty', N'', 1, 10101099, 10000000, 7, 0, N'Administrator', CAST(0x0000A474008BF423 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1111, 10104900, NULL, N'Compose Email', N'', 1, 10104099, 10000000, 38, 0, N'sa', CAST(0x0000A47500A1C094 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1112, 10211213, NULL, N'Setup Custom Report Template', N'', 1, 10104099, 10000000, 9, 0, N'sa', CAST(0x0000A47D0175B1A8 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1113, 10163400, NULL, N'View Nomination Schedule', NULL, 1, 10161499, 10000000, 65, 0, N'rsa', CAST(0x0000A4AD010C3961 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1114, 10163800, NULL, N'Split Nomination Volume', NULL, 1, 10161499, 10000000, 16, 0, N'rsa', CAST(0x0000A4B200AE5799 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1115, 10164000, NULL, N'Update Wellhead Volume', N'', 1, 10161499, 10000000, 93, 0, N'rsa', CAST(0x0000A4B501224917 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1116, 10165000, NULL, N'Assign Priority to Nomination Group', N'', 1, 10161199, 10000000, 93, 0, N'rsa', CAST(0x0000A4BF00BF456E AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1117, 10163900, NULL, N'Setup Route', N'', 1, 10161199, 10000000, 0, 0, N'Administrator', CAST(0x0000A4C200619FA9 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1118, 10163600, NULL, N'Flow Optimization', NULL, 1, 10161499, 10000000, 111, 0, N'rsa', CAST(0x0000A4C900A1CDB5 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1125, 10164200, NULL, N'Run Auto Nom Process', N'', 1, 10161499, 10000000, 112, 1, N'rsa', CAST(0x0000A4E100C86310 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1126, 10166000, NULL, N'Run Purge Process', NULL, 1, 10161499, 10000000, 135, 0, N'sa', CAST(0x0000A4E300EC11C8 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1128, 10106100, NULL, N'Setup Time Series', N'', 1, 10150000, 10000000, 112, 0, N'Administrator', CAST(0x0000A4EB0126DE20 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1129, 10104100, NULL, N'Setup UDF Template', NULL, 1, 10104099, 10000000, 14, NULL, N'rsa', CAST(0x0000A4ED004E457A AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1138, 10190000, NULL, N'Credit Risk And Analysis', NULL, 1, 10000000, 10000000, 133, 1, N'rsa', CAST(0x0000A50700150B71 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1139, 10191800, NULL, N'Calculate Credit Risk Exposure', NULL, 1, 10190000, 10000000, 112, 0, N'rsa', CAST(0x0000A50700150B72 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1140, 10106300, NULL, N'Data Import/Export', N'', 1, 10106399, 10000000, 112, 0, N'sa', CAST(0x0000A50800ABAEF5 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1142, 10180000, NULL, N'Valuation And Risk Analysis', NULL, 1, 10000000, 10000000, 133, 1, N'sa', CAST(0x0000A50800AC825F AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1143, 10181000, NULL, N'Run MTM Process', NULL, 1, 10181199, 10000000, 133, 0, N'sa', CAST(0x0000A50800AC8451 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1145, 10162500, NULL, N'Run Inventory Calc', N'', 1, 10161399, 10000000, 136, 0, N'sa', CAST(0x0000A50C00448659 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1146, 10101122, NULL, N'Counterparty Credit Information', NULL, 1, 10190000, 10000000, 117, 0, N'sa', CAST(0x0000A528010D2800 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1147, 10231000, NULL, N'Setup Inventory GL Account', NULL, 1, 15190000, 10000000, 40, 0, N'sa', CAST(0x0000A52A00C28B2A AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1148, 10234700, NULL, N'Maintain Deal Transfer', NULL, 1, 10130000, 10000000, 54, 0, N'sa', CAST(0x0000A52A00C2DD65 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1149, 10102800, NULL, N'Setup Profile', NULL, 1, 10101099, 10000000, 6, 0, N'sa', CAST(0x0000A52A00C308EE AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1151, 10183100, NULL, N'Run Monte Carlo Simulation', NULL, 1, 10181199, 10000000, 133, NULL, N'sa', CAST(0x0000A52C00F5D67C AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1152, 10163200, NULL, N'Dispatch Cost Evaluator', N'', 1, 10161299, 10000000, 108, 0, N'sa', CAST(0x0000A52D011C487A AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1153, 10202200, NULL, N'View Report', N'', 1, 13121295, 13000000, 200, 0, N'sa', CAST(0x0000A52D011C4995 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1155, 10163100, NULL, N'Tag', NULL, 1, 10161299, 10000000, 100, 0, N'sa', CAST(0x0000A52D011C5BD7 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1156, 10183000, NULL, N'Setup Risk Factor Model', NULL, 1, 10181099, 10000000, 117, 0, N'sa', CAST(0x0000A52D011C819B AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1157, 10163300, NULL, N'Map Rate Schedule', N'', 1, 10161199, 10000000, 107, 0, N'sa', CAST(0x0000A52D011C8427 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1159, 10183200, NULL, N'Setup Portfolio Group', NULL, 1, 10181099, 10000000, 118, 0, N'sa', CAST(0x0000A53200A02E56 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1160, 10163700, NULL, N'Scheduling Workbench', N'', 1, 10161599, 10000000, 100, 0, N'sa', CAST(0x0000A53200A034A0 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1161, 10181299, NULL, N'Run At Risk', NULL, 0, 10180000, 10000000, 140, 1, N'sa', CAST(0x0000A533005E9C9F AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1162, 10181200, NULL, N'Run At Risk Measurement', NULL, 1, 10181199, 10000000, 8, 0, N'sa', CAST(0x0000A533005E9C9F AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1163, 10183400, NULL, N'Run What If Analysis', NULL, 1, 10181199, 10000000, 27, 0, N'sa', CAST(0x0000A533006D7B58 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1164, 10183499, NULL, N'Run What-If', NULL, 0, 10180000, 10000000, 25, 1, N'sa', CAST(0x0000A533006D8296 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1165, 10164300, NULL, N'Nomination EDI', NULL, 1, 10161499, 10000000, 114, 0, N'sa', CAST(0x0000A533006D84AC AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1166, 10182500, NULL, N'Setup What If Scenario', N'', 1, 10181099, 10000000, 200, 0, N'Administrator', CAST(0x0000A53600509526 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1167, 10181399, NULL, N'Run Limits', NULL, 0, 10180000, 10000000, 100, 1, N'Administrator', CAST(0x0000A536007A3D38 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1168, 10181300, NULL, N'Setup Limit', NULL, 1, 10181099, 10000000, 100, 0, N'Administrator', CAST(0x0000A536007A3D38 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1169, 10161800, NULL, N'Setup Plant Derate/Outage', NULL, 1, 10161299, 10000000, 16, 0, N'Administrator', CAST(0x0000A55400BBD451 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1170, 10164400, NULL, N'View and Edit Nomination', NULL, 1, 10161499, 10000000, 111, 0, N'Administrator', CAST(0x0000A55400BBD454 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1171, 10106400, NULL, N'Template Field Mapping', NULL, 1, 10106499, 10000000, 16, 0, N'sa', CAST(0x0000A556009DBC48 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1174, 10131300, NULL, N'Import Data', N'', 1, 10106399, 10000000, 51, 0, N'sa', CAST(0x0000A563009EB0E9 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1175, 10162100, NULL, N'Run Storage WACOG Calc', NULL, 1, 10161399, 10000000, 137, NULL, N'sa', CAST(0x0000A564014F45F5 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1176, 13102000, NULL, N'Generic Mapping', NULL, 1, 10100000, 13000000, 34, 0, N'sa', CAST(0x0000A56700B0C3E8 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1177, 10101900, NULL, N'Setup Logical Trade Lock', NULL, 1, 10100000, 10000000, 3, 1, N'farrms_admin', CAST(0x0000A56A0121FAE7 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1179, 10106300, NULL, N'Data Import/Export', N'', 1, 13180000, 13000000, 112, 0, N'sa', CAST(0x0000A56B00B65B00 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1181, 10166300, NULL, N'Copy Nomination', N'', 1, 10161499, 10000000, 136, 1, N'sa', CAST(0x0000A57800B15BC0 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1182, 10202500, NULL, N'Report Manager', NULL, 1, 10200000, 10000000, 43, 0, N'sa', CAST(0x0000A57F00A21155 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1183, 10104000, NULL, N'Define Deal Status Privilege', N'', 1, 10110000, 10000000, 225, 1, N'sa', CAST(0x0000A57F0112E744 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1185, 10181400, NULL, N'Calculate Volatility, Correlation and Expected Return', NULL, 1, 10181199, 10000000, 133, 1, N'sa', CAST(0x0000A58700D1BAB1 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1188, 10166100, NULL, N'Setup Fuel Loss Group', N'', 1, 10161199, 10000000, 112, 0, N'sa', CAST(0x0000A5910112A50C AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1189, 10132300, NULL, N'Setup CNG Deal', N'', 1, 10130000, 10000000, 72, 0, N'sa', CAST(0x0000A59800D246CE AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1190, 10131600, NULL, N'Transfer Book Position', NULL, 1, 10130000, 10000000, 3, 1, N'farrms_admin', CAST(0x0000A59900CCACC6 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1191, 10201600, NULL, N'Report Manager - Old', NULL, 1, 13121295, 13000000, 4, NULL, N'sa', CAST(0x0000A59A009DCA9F AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1192, 10101400, NULL, N'Setup Deal Template', NULL, 1, 10104099, 13000000, 4, 0, N'sa', CAST(0x0000A59A009DCAA9 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1193, 10104100, NULL, N'Setup UDF Template', NULL, 1, 10104099, 13000000, 6, NULL, N'sa', CAST(0x0000A59A009DCAAB AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1194, 10104200, NULL, N'Setup Deal Field Template', NULL, 1, 10104099, 13000000, 5, NULL, N'sa', CAST(0x0000A59A009DCAAE AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1195, 10122500, NULL, N'Setup Advanced Workflow Rule', NULL, 1, 10106699, 13000000, 7, 0, N'sa', CAST(0x0000A59A009DCAB0 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1196, 10101182, NULL, N'Setup UOM Conversion', NULL, 1, 10101099, 13000000, 9, NULL, N'sa', CAST(0x0000A59A009DCAB3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1197, 10104900, NULL, N'Compose Email', NULL, 1, 10104099, 13000000, 10, NULL, N'sa', CAST(0x0000A59A009DCAB5 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1198, 10105800, NULL, N'Setup Counterparty', NULL, 1, 10101099, 13000000, 5, NULL, N'sa', CAST(0x0000A59A009DCAB8 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1202, 10201800, NULL, N'Report Group Manager', N'', 1, 10200000, 10000000, 0, 0, N'sa', CAST(0x0000A59A00B96F1F AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1204, 10106600, NULL, N'Setup Workflow/Alerts', N'', 1, 10106699, 10000000, 52, 0, N'sa', CAST(0x0000A59C009D99BE AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1205, 10106700, NULL, N'Manage Approval', N'', 1, 10106699, 10000000, 53, 0, N'sa', CAST(0x0000A59C009DE2FA AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1212, 10234900, NULL, N'Measurement Report', NULL, 0, 10202200, 13000000, 2, NULL, N'sa', CAST(0x0000A5A100D06780 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1213, 10142400, NULL, N'Derivative Position Report', NULL, 0, 10202200, 13000000, 3, NULL, N'sa', CAST(0x0000A5A100D06782 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1214, 10236400, NULL, N'Available Hedge Capacity Exception Report', NULL, 0, 10202200, 13000000, 4, NULL, N'sa', CAST(0x0000A5A100D06787 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1218, 10235200, NULL, N'AOCI Report', NULL, 0, 10202200, 13000000, 8, NULL, N'sa', CAST(0x0000A5A100D0679B AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1219, 10235800, NULL, N'Assessment Report', NULL, 0, 10202200, 13000000, 9, NULL, N'sa', CAST(0x0000A5A100D067A0 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1220, 13160000, NULL, N'Hedging Relationship Audit Report', NULL, 0, 10202200, 13000000, 10, NULL, N'sa', CAST(0x0000A5A100D067A5 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1222, 10235600, NULL, N'Accounting Disclosure Report', NULL, 0, 10202200, 13000000, 12, NULL, N'sa', CAST(0x0000A5A100D067B0 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1223, 10235700, NULL, N'Fair Value Disclosure Report', NULL, 0, 10202200, 13000000, 13, NULL, N'sa', CAST(0x0000A5A100D067B1 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1224, 10235100, NULL, N'Period Change Values Report', NULL, 0, 10202200, 13000000, 14, NULL, N'sa', CAST(0x0000A5A100D067B6 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1227, 10235300, NULL, N'De-designation Values Report', NULL, 0, 10202200, 13000000, 17, NULL, N'sa', CAST(0x0000A5A100D067C5 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1228, 10236100, NULL, N'Missing Assessment Values Report', NULL, 0, 10202200, 13000000, 18, NULL, N'sa', CAST(0x0000A5A100D067CA AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1229, 10236200, NULL, N'Failed Assessment Values Report', NULL, 0, 10202200, 13000000, 19, NULL, N'sa', CAST(0x0000A5A100D067CD AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1231, 10161400, NULL, N'Gas Storage Position Report', NULL, 0, 10202200, 10000000, 1, NULL, N'sa', CAST(0x0000A5A100D1EE5C AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1232, 10162600, NULL, N'Pipeline Imbalance Report', NULL, 0, 10202200, 10000000, 2, NULL, N'sa', CAST(0x0000A5A100D1EE66 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1233, 10202000, NULL, N'User Activity Log Report', NULL, 0, 10202200, 10000000, 3, NULL, N'sa', CAST(0x0000A5A100D1EE6E AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1234, 10202100, NULL, N'Message Board Log Report', NULL, 0, 10202200, 10000000, 4, NULL, N'sa', CAST(0x0000A5A100D1EE75 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1235, 10202201, NULL, N'Export GL Entries', NULL, 1, 10220000, 10000000, 5, 0, N'sa', CAST(0x0000A5A100D1EE7B AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1247, 10101500, NULL, N'Setup Netting Group', NULL, 1, 10100000, 13000000, 8, NULL, N'farrms_admin', CAST(0x0000A5A200D674C7 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1255, 10211213, NULL, N'Setup Custom Report Template', NULL, 1, 10104099, 13000000, 6, NULL, N'farrms_admin', CAST(0x0000A5A200D674DB AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1263, 10232000, NULL, N'Hedging Relationship Types Report', NULL, 0, 10202200, 13000000, 1, NULL, N'farrms_admin', CAST(0x0000A5A600A49CE1 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1264, 10235400, NULL, N'Journal Entries Report', NULL, 0, 10202200, 13000000, 5, 0, N'farrms_admin', CAST(0x0000A5A600A49CE6 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1266, 10236500, NULL, N'Not Mapped Transaction Report', NULL, 0, 10202200, 13000000, 7, NULL, N'farrms_admin', CAST(0x0000A5A600A49CF7 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1267, 10235500, NULL, N'Netted Journal Entry Report', NULL, 0, 10202200, 13000000, 11, 0, N'farrms_admin', CAST(0x0000A5A600A49D02 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1268, 10236600, NULL, N'Tagging Audit Report', NULL, 0, 10202200, 13000000, 15, NULL, N'farrms_admin', CAST(0x0000A5A600A49D0C AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1269, 10232800, NULL, N'Import Audit Report', NULL, 0, 10202200, 13000000, 20, NULL, N'farrms_admin', CAST(0x0000A5A600A49D17 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1270, 10233900, NULL, N'Hedging Relationship Report', NULL, 0, 10202200, 13000000, 6, NULL, N'farrms_admin', CAST(0x0000A5A600AB26A6 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1271, 13121200, NULL, N'Hedge Ineffectiveness Report', NULL, 0, 10202200, 13000000, 16, NULL, N'farrms_admin', CAST(0x0000A5A600B16B82 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1272, 10192200, NULL, N'Calculate Credit Value Adjustment', NULL, 1, 10190000, 10000000, 114, 0, N'sa', CAST(0x0000A5A800A433A0 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1273, 10181800, NULL, N'Run Implied Volatility Calculation', NULL, 1, 10181199, 10000000, 134, 1, N'sa', CAST(0x0000A5AE009E475A AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1274, 10221200, NULL, N'Contract Settlement Report', NULL, 0, 10202200, 10000000, 6, NULL, N'sa', CAST(0x0000A5AE00BDC9AF AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1275, 10222400, NULL, N'Meter Data Report', NULL, 0, 10202200, 10000000, 7, NULL, N'sa', CAST(0x0000A5AE00BDC9D8 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1276, 10111300, NULL, N'Privilege Report', NULL, 0, 10202200, 10000000, 8, NULL, N'sa', CAST(0x0000A5AE00BDC9DD AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1277, 10111400, NULL, N'System Access Log Report', NULL, 0, 10202200, 10000000, 9, NULL, N'sa', CAST(0x0000A5AE00BDC9EC AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1278, 10171100, NULL, N'Transaction Audit Log Report', NULL, 0, 10202200, 10000000, 10, NULL, N'sa', CAST(0x0000A5AE00BDCA02 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1279, 10201500, NULL, N'Static Data Audit Report', NULL, 0, 10202200, 10000000, 11, NULL, N'sa', CAST(0x0000A5AE00BDCA0A AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1280, 10201900, NULL, N'Data Import/Export Audit Report', NULL, 0, 10202200, 10000000, 12, NULL, N'sa', CAST(0x0000A5AE00BDCA32 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1281, 10221900, NULL, N'Deal Settlement Report', NULL, 0, 10202200, 10000000, 13, NULL, N'sa', CAST(0x0000A5AE00BDCA52 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1282, 10184000, NULL, N'Run MTM Simulation', NULL, 1, 10181199, 10000000, 134, 1, N'farrms_admin', CAST(0x0000A5AE00F2051B AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1283, 10201700, NULL, N'Run Report Group', N'', 0, 10200000, 10000000, 0, 0, N'sa', CAST(0x0000A5AF00B55E88 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1284, 10101161, NULL, N'Setup Confirmation Rule', NULL, 1, 10104099, 10000000, 16, 0, N'sa', CAST(0x0000A5AF012E8643 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1285, 10166500, NULL, N'Actualize Schedule', N'', 1, 10161599, 10000000, 243, 0, N'sa', CAST(0x0000A5D800BB9D1E AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1286, 10241100, NULL, N'Apply Cash', NULL, 1, 10220000, 10000000, 111, 0, N'sa', CAST(0x0000A5DE00CE76E9 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1287, 10104600, NULL, N'Setup Settlement Netting Group', NULL, 1, 10220000, 10000000, 17, 0, N'sa', CAST(0x0000A5E000913CB0 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1289, 10166700, NULL, N'Generation Reserve Planner', N'', 1, 10161299, 10000000, 245, 0, N'sa', CAST(0x0000A5E200B8DD94 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1291, 10181499, NULL, N'Run Volatility Calculations', NULL, 0, 10180000, 10000000, 133, 1, N'sa', CAST(0x0000A5E500951DE7 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1292, 13230000, NULL, N'Run Process', NULL, 1, 13000000, 13000000, 70, 1, N'sa', CAST(0x0000A5E900BF34F5 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1293, 13231000, NULL, N'Run FX Ineffectiveness', NULL, 1, 13230000, 13000000, 1, 0, N'sa', CAST(0x0000A5E900BF34F7 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1294, 10166200, NULL, N'Setup Weather Data', N'', 1, 10150000, 10000000, 111, 0, N'sa', CAST(0x0000A5F50110206C AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1295, 10104800, NULL, N'Data Import/Export', NULL, 0, 10100000, 10000000, 41, NULL, N'farrms_admin', CAST(0x0000A5F600B2746D AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1297, 13240000, NULL, N'Derivative Accounting', NULL, 1, 10000000, 10000000, 0, 1, N'dev_admin', CAST(0x0000A5FD0100B14D AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1298, 10235499, NULL, N'Accounting', NULL, 1, 13240000, 10000000, 0, 1, N'dev_admin', CAST(0x0000A5FD0100B14D AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1299, 10237000, NULL, N'Setup Manual Journal Entry', NULL, 1, 10235499, 10000000, 0, 1, N'dev_admin', CAST(0x0000A5FD0100B14D AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1300, 10237500, NULL, N'Close Accounting Period', NULL, 1, 10235499, 10000000, 0, 1, N'dev_admin', CAST(0x0000A5FD0100B14D AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1301, 13200000, NULL, N'Hedge Effectivenesss Testing', NULL, 1, 13240000, 10000000, 0, 1, N'dev_admin', CAST(0x0000A5FD0100B14D AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1302, 10232300, NULL, N'Hedge Effectiveness Assessment', NULL, 1, 13200000, 10000000, 0, 1, N'dev_admin', CAST(0x0000A5FD0100B14D AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1303, 10237300, NULL, N'View/Update Cum PNL Series', NULL, 1, 13200000, 10000000, 0, 1, N'dev_admin', CAST(0x0000A5FD0100B14E AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1304, 10233400, NULL, N'Run Measurement Process', NULL, 1, 13210000, 10000000, 0, 0, N'dev_admin', CAST(0x0000A5FD0100B14E AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1305, 10233300, NULL, N'Copy Prior MTM Value', NULL, 1, 13210000, 10000000, 0, 0, N'dev_admin', CAST(0x0000A5FD0100B14E AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1306, 10234600, NULL, N'First Day Gain/Loss Treatment', NULL, 1, 13210000, 10000000, 0, 0, N'dev_admin', CAST(0x0000A5FD0100B14E AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1307, 13190000, NULL, N'Hedge Management', NULL, 1, 13240000, 10000000, 0, 1, N'dev_admin', CAST(0x0000A5FD0100B14E AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1308, 10233000, NULL, N'Delete Voided Deal', NULL, 1, 13190000, 10000000, 0, 1, N'dev_admin', CAST(0x0000A5FD0100B14F AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1309, 10231900, NULL, N'Setup Hedging Relationship Type', NULL, 1, 13190000, 10000000, 0, 1, N'dev_admin', CAST(0x0000A5FD0100B14F AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1310, 10233700, NULL, N'Designation of a Hedge', NULL, 1, 13190000, 10000000, 0, 0, N'dev_admin', CAST(0x0000A5FD0100B14F AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1311, 10234300, NULL, N'Automation of Forecasted Transaction', NULL, 1, 13190000, 10000000, 0, 0, N'dev_admin', CAST(0x0000A5FD0100B150 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1312, 10234400, NULL, N'Automate Hedge Matching', NULL, 1, 13190000, 10000000, 0, 1, N'dev_admin', CAST(0x0000A5FD0100B150 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1313, 10234500, NULL, N'View Outstanding Automation Result', NULL, 1, 13190000, 10000000, 0, 1, N'dev_admin', CAST(0x0000A5FD0100B150 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1314, 10234100, NULL, N'Amortize Deferred AOCI', NULL, 1, 13190000, 10000000, 0, 1, N'dev_admin', CAST(0x0000A5FD0100B150 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1315, 10234000, NULL, N'Reclassify Hedge De-Designation', NULL, 1, 13190000, 10000000, 0, 1, N'dev_admin', CAST(0x0000A5FD0100B150 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1317, 10181599, NULL, N'Simulation', NULL, 0, 10180000, 10000000, 1, 1, N'sa', CAST(0x0000A60200FBFA60 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1318, 10131018, NULL, N'Update Volume', NULL, 0, 10132000, 10000000, 50, 0, N'dev_admin', CAST(0x0000A60801075306 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1319, 10167000, NULL, N'Forecast Load', NULL, 1, 10161299, 10000000, 111, 1, N'sa', CAST(0x0000A6090092F838 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1320, 10167200, NULL, N'Forecast Parameters Mapping', NULL, 1, 10106499, 10000000, 111, 0, N'sa', CAST(0x0000A6090093146B AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1321, 10166900, NULL, N'Shut In Volume', N'', 1, 10161499, 10000000, 123, 0, N'sa', CAST(0x0000A6090093158A AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1322, 10167100, NULL, N'Forecast Price', NULL, 1, 10150000, 10000000, 111, 1, N'sa', CAST(0x0000A6090093175E AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1323, 10106399, NULL, N'Data Import', N'', 1, 10100000, 10000000, 1, 1, N'sa', CAST(0x0000A60C0109C448 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1324, 10106699, NULL, N'Alert and Workflow', N'', 1, 10100000, 10000000, 1, 1, N'sa', CAST(0x0000A60C0109C448 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1325, 10106499, NULL, N'Mapping Setup', N'', 1, 10100000, 10000000, 1, 1, N'sa', CAST(0x0000A60C0109C449 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1326, 10104099, NULL, N'Template', N'', 1, 10100000, 10000000, 1, 1, N'sa', CAST(0x0000A60C0109C449 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1327, 10161199, NULL, N'Setup', N'', 1, 10160000, 10000000, 1, 1, N'sa', CAST(0x0000A60C0109C44A AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1328, 10161299, NULL, N'Power Operations', N'', 1, 10160000, 10000000, 1, 1, N'sa', CAST(0x0000A60C0109C44A AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1329, 10161399, NULL, N'Inventory', N'', 1, 10160000, 10000000, 1, 1, N'sa', CAST(0x0000A60C0109C44B AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1330, 10161499, NULL, N'Gas Operations', N'', 1, 10160000, 10000000, 1, 1, N'sa', CAST(0x0000A60C0109C44B AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1331, 10161599, NULL, N'Hydrocarbon Operations', N'', 1, 10160000, 10000000, 1, 1, N'sa', CAST(0x0000A60C0109C44C AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1332, 10181099, NULL, N'Setup', N'', 1, 10180000, 10000000, 1, 1, N'sa', CAST(0x0000A60C0109C44C AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1333, 10181199, NULL, N'Run Analytical Process', N'', 1, 10180000, 10000000, 1, 1, N'sa', CAST(0x0000A60C0109C44C AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1334, 15190000, NULL, N'Accounting Setup', N'', 1, 10000000, 10000000, 1, 1, N'sa', CAST(0x0000A60C0109C44D AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1335, 13210000, NULL, N'Hedge Ineffectiveness Measure', N'', 1, 13240000, 10000000, 1, 1, N'sa', CAST(0x0000A60C0109C44E AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1337, 10122512, NULL, N'Export Relationship', NULL, 0, 10122500, 10000000, 111, 0, N'dev_admin', CAST(0x0000A60F00D63877 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1338, 10104099, NULL, N'Template', N'', 1, 10100000, 13000000, 1, 1, N'dev_admin', CAST(0x0000A61100CE7F2A AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1339, 10211200, NULL, N'Setup Standard Contract', NULL, 1, 10101099, 13000000, 2, 0, N'dev_admin', CAST(0x0000A616012471DA AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1340, 10221348, NULL, N'GL Entries Export', NULL, 0, 10221300, 10000000, 111, 0, N'dev_admin', CAST(0x0000A61D00B81BB1 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (2718, 10122600, N'windowSetupAlertsSimple', N'Setup Simple Alert', N'', 1, 10106699, 10000000, 49, 0, N'sa', CAST(0x0000A641009282C5 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (2719, 10131000, N'windowMaintainDeals', N'Create and View Deal', NULL, 1, 10130000, 13000000, 50, 0, N'sa', CAST(0x0000A64100ACFBF9 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (2720, 10202500, NULL, N'Report Manager', NULL, 1, 13121295, 13000000, 145, 1, N'sa', CAST(0x0000A64100ACFBFA AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (2973, 15000000, NULL, N'Settlement Tracker', NULL, 1, NULL, 15000000, 0, 1, N'sa', CAST(0x0000A64200A412ED AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (2974, 10100000, NULL, N'Setup', NULL, 1, 15000000, 15000000, 1, 1, N'sa', CAST(0x0000A64200A412ED AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (2975, 10101099, NULL, N'Reference Data', NULL, 1, 10100000, 15000000, 2, 1, N'sa', CAST(0x0000A64200A412ED AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (2976, 10101000, N'windowMaintainStaticData', N'Setup Static Data', NULL, 1, 10101099, 15000000, 3, 0, N'sa', CAST(0x0000A64200A412ED AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (2977, 10101100, N'windowMaintainDefination', N'Maintain Definition', NULL, 0, 10101099, 15000000, 4, 0, N'sa', CAST(0x0000A64200A412ED AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (2978, 10101200, N'windowSetupHedgingStrategies', N'Setup Book Structure', NULL, 1, 10101099, 15000000, 5, 0, N'sa', CAST(0x0000A64200A412ED AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (2979, 10102500, N'windowSetupLocation', N'Setup Location', NULL, 1, 10101099, 15000000, 7, 0, N'sa', CAST(0x0000A64200A412ED AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (2980, 10102800, N'windowSetupProfile', N'Setup Profile', NULL, 0, 10101099, 15000000, 8, 0, N'sa', CAST(0x0000A64200A412ED AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (2981, 10101499, NULL, N'Setup Deal Templates', NULL, 0, 10100000, 15000000, 10, 1, N'sa', CAST(0x0000A64200A412ED AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (2982, 10101400, N'windowMaintainDealTemplate', N'Setup Deal Field Template', NULL, 1, 10104099, 15000000, 11, 0, N'sa', CAST(0x0000A64200A412EE AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (2983, 10104200, N'windowSetupFieldTemplate', N'Setup Field Template', NULL, 1, 10104099, 15000000, 12, 0, N'sa', CAST(0x0000A64200A412EE AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (2984, 10104100, N'windowSetupUDFTemplate', N'Setup UDF Template', NULL, 1, 10104099, 15000000, 13, 0, N'sa', CAST(0x0000A64200A412EE AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (2985, 10103900, N'windowSetupDealStatusConfirmationRule', N'Setup Deal Status and Confirmation Rule', NULL, 0, 10101499, 15000000, 14, 0, N'sa', CAST(0x0000A64200A412EE AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (2986, 10103500, N'windowSetupHedgingRelationshipsTypesWithReturn', N'Maintain Hedge Deferral Rules', NULL, 0, 10101499, 15000000, 15, 0, N'sa', CAST(0x0000A64200A412EE AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (2987, 10101500, N'windowMaintainNettingGroups', N'Setup Netting Group', NULL, 0, 10100000, 15000000, 17, 0, N'sa', CAST(0x0000A64200A412EE AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (2988, 10101600, N'windowSchedulejob', N'View Scheduled Job', NULL, 1, 10100000, 15000000, 16, 0, N'sa', CAST(0x0000A64200A412EE AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (2989, 10103800, N'windowMaintainSourceGenerator', N'Maintain Source Generator', NULL, 0, 10100000, 15000000, 19, 0, N'sa', CAST(0x0000A64200A412EE AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (2990, 10103399, NULL, N'Setup Contract Components ', NULL, 0, 10100000, 15000000, 20, 1, N'sa', CAST(0x0000A64200A412EE AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (2991, 10101900, N'windowSetupDealLock', N'Setup Logical Trade Lock', NULL, 0, 10100000, 15000000, 23, 0, N'sa', CAST(0x0000A64200A412EE AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (2992, 10102000, N'windowSetupTenorBucketData', N'Setup Tenor Bucket', NULL, 0, 10100000, 15000000, 24, 0, N'sa', CAST(0x0000A64200A412EE AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (2993, 10102900, N'windowManageDocuments', N'Manage Document', NULL, 1, 10100000, 15000000, 20, 0, N'sa', CAST(0x0000A64200A412EE AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (2994, 10102300, N'windowSetupEMSStrategies', N'Setup Emissions Source/Sink Type', NULL, 0, 10100000, 15000000, 26, 0, N'sa', CAST(0x0000A64200A412EE AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (2995, 10102200, N'windowSetupAsOfDate', N'Setup As of Date', NULL, 0, 10100000, 15000000, 27, 0, N'sa', CAST(0x0000A64200A412EE AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (2996, 10102400, N'windowFormulaBuilder', N'Formula Builder', NULL, 1, 10104099, 15000000, 24, 0, N'sa', CAST(0x0000A64200A412EE AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (2997, 13170000, NULL, N'Mapping Setup', NULL, 0, 10100000, 15000000, 29, 1, N'sa', CAST(0x0000A64200A412EE AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (2998, 10103100, N'windowSetupTrayportTermMappingStaging', N'Term Mapping ', NULL, 0, 13170000, 15000000, 30, 0, N'sa', CAST(0x0000A64200A412EE AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (2999, 10103200, N'windowPratosMapping', N'Pratos Mapping', NULL, 0, 13170000, 15000000, 31, 0, N'sa', CAST(0x0000A64200A412EE AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3000, 13171000, N'windowSTForecastMapping', N'ST Forecast Mapping', NULL, 0, 13170000, 15000000, 32, 0, N'sa', CAST(0x0000A64200A412EE AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3001, 10102799, NULL, N'Manage Data', NULL, 0, 10100000, 15000000, 33, 1, N'sa', CAST(0x0000A64200A412EF AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3002, 10102700, N'windowSetupArchiveData', N'Archive Data', NULL, 0, 10102799, 15000000, 34, 0, N'sa', CAST(0x0000A64200A412EF AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3003, 10103600, N'windowRemoveData', N'Remove Data', NULL, 0, 10102799, 15000000, 35, 0, N'sa', CAST(0x0000A64200A412EF AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3004, 10104000, N'windowDefineDealStatusPrivilege', N'Define Deal Status Privilege', NULL, 0, 10100000, 15000000, 36, 0, N'sa', CAST(0x0000A64200A412EF AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3005, 10104300, N'windowSetupContractComponentMapping', N'Setup Contract Component Mapping', NULL, 1, 15140000, 15000000, 18, 0, N'sa', CAST(0x0000A64200A412EF AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3006, 10104400, N'windowSetupContractPrice', N'Setup Contract Price', NULL, 0, 10100000, 15000000, 38, 0, N'sa', CAST(0x0000A64200A412EF AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3007, 10110000, NULL, N'Users and Roles', NULL, 1, 15000000, 15000000, 39, 1, N'sa', CAST(0x0000A64200A412EF AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3008, 10111000, N'windowMaintainUsers', N'Setup User', NULL, 1, 10110000, 15000000, 40, 0, N'sa', CAST(0x0000A64200A412EF AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3009, 10111100, N'windowMaintainRoles', N'Setup Role', NULL, 1, 10110000, 15000000, 41, 0, N'sa', CAST(0x0000A64200A412EF AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3010, 10111200, N'windowCustomizedMenu', N'Setup Workflow', NULL, 1, 10110000, 15000000, 42, 0, N'sa', CAST(0x0000A64200A412EF AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3011, 10111300, N'windowRunPrivilege', N'Run Privilege Report', NULL, 0, 10110000, 15000000, 43, 0, N'sa', CAST(0x0000A64200A412EF AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3012, 10111400, N'windowRunSystemAccessLog', N'Run System Access Log Report', NULL, 0, 10110000, 15000000, 44, 0, N'sa', CAST(0x0000A64200A412EF AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3014, 10121300, N'MaintainComplianceStandards', N'Maintain Compliance Standards', NULL, 0, 10120000, 15000000, 46, 0, N'sa', CAST(0x0000A64200A412EF AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3015, 10121000, N'maintainComplianceProcess', N'Maintain Compliance Groups', NULL, 0, 10120000, 15000000, 47, 0, N'sa', CAST(0x0000A64200A412EF AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3016, 10121400, N'windowActivityProcessMap', N'Activity Process Map', NULL, 0, 10120000, 15000000, 48, 0, N'sa', CAST(0x0000A64200A412F0 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3017, 10121500, N'MaintainChangeOwners', N'Change Owners', NULL, 0, 10120000, 15000000, 49, 0, N'sa', CAST(0x0000A64200A412F0 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3018, 10121200, N'PerformComplianceActivities', N'Perform Compliance Activities', NULL, 0, 10120000, 15000000, 50, 0, N'sa', CAST(0x0000A64200A412F0 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3019, 10121100, N'ApproveComplianceActivities', N'Approve Compliance Activities', NULL, 0, 10120000, 15000000, 51, 0, N'sa', CAST(0x0000A64200A412F0 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3020, 10122300, NULL, N'Reports', NULL, 0, 10120000, 15000000, 52, 1, N'sa', CAST(0x0000A64200A412F0 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3021, 10121600, N'ViewComplianceActivities', N'View Compliance Activities', NULL, 0, 10122300, 15000000, 53, 0, N'sa', CAST(0x0000A64200A412F0 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3022, 10121700, N'ReportComplianceActivities', N'View Status On Compliance Activities', NULL, 0, 10122300, 15000000, 54, 0, N'sa', CAST(0x0000A64200A412F0 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3023, 10122200, N'windowComplianceCalendar', N'View Compliance Calendar', NULL, 0, 10122300, 15000000, 55, 0, N'sa', CAST(0x0000A64200A412F0 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3024, 10121800, N'RunComplianceAuditReport', N'Run Compliance Activity Audit Report', NULL, 0, 10122300, 15000000, 56, 0, N'sa', CAST(0x0000A64200A412F0 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3025, 10121900, N'RunComplianceTrendReport', N'Run Compliance Trend Report', NULL, 0, 10122300, 15000000, 57, 0, N'sa', CAST(0x0000A64200A412F0 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3026, 10122000, N'dashReportPie', N'Run Compliance Graph Report', NULL, 0, 10122300, 15000000, 58, 0, N'sa', CAST(0x0000A64200A412F0 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3027, 10122100, N'dashReportBar', N'Run Compliance Status Graph Report', NULL, 0, 10122300, 15000000, 59, 0, N'sa', CAST(0x0000A64200A412F0 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3028, 10122400, N'RunComplianceDateVoilationReport', N'Run Compliance Due Date Violation Report', NULL, 0, 10122300, 15000000, 60, 0, N'sa', CAST(0x0000A64200A412F0 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3029, 15130199, NULL, N'Define Billing Determinants', NULL, 1, 15000000, 15000000, 61, 1, N'sa', CAST(0x0000A64200A412F0 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3030, 15130100, N'windowMaintainStaticDataContractComponent', N'Setup Contract Component', NULL, 0, 15130199, 15000000, 62, 0, N'sa', CAST(0x0000A64200A412F1 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3031, 10103800, N'windowMaintainSourceGenerator', N'Setup Generators', NULL, 0, 15130199, 15000000, 63, 0, N'sa', CAST(0x0000A64200A412F1 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3032, 10103000, N'windowDefineMeterID', N'Setup Meter', NULL, 1, 15130199, 15000000, 64, 0, N'sa', CAST(0x0000A64200A412F1 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3033, 10102600, N'windowSetupPriceCurves', N'Setup Price Curve', NULL, 1, 15130199, 15000000, 65, 0, N'sa', CAST(0x0000A64200A412F1 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3034, 15140000, NULL, N'Setup Contract Template', NULL, 1, 15000000, 15000000, 66, 1, N'sa', CAST(0x0000A64200A412F1 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3035, 10191099, NULL, N'Setup Contracts ', NULL, 1, 15000000, 15000000, 68, 1, N'sa', CAST(0x0000A64200A412F1 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3036, 10105800, N'windowSetupCounterparty', N'Setup Counterparty', NULL, 1, 10191099, 15000000, 69, 0, N'sa', CAST(0x0000A64200A412F1 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3037, 10211200, N'windowMaintainContract', N'Setup Standard Contract', NULL, 1, 10191099, 15000000, 71, 0, N'sa', CAST(0x0000A64200A412F1 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3038, 10131000, N'windowMaintainDeals', N'Setup Deals', NULL, 0, 10191099, 15000000, 70, 0, N'sa', CAST(0x0000A64200A412F1 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3039, 10141399, NULL, N'Manage Billing Determinants', NULL, 1, 15000000, 15000000, 72, 1, N'sa', CAST(0x0000A64200A412F1 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3040, 10141300, N'windowRunHourlyProductionReport', N'View Position', NULL, 0, 10141399, 15000000, 73, 0, N'sa', CAST(0x0000A64200A412F1 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3041, 10131300, N'windowImportDataDeal', N'Import Meter Data', NULL, 0, 10141399, 15000000, 74, 0, N'sa', CAST(0x0000A64200A412F1 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3042, 10222400, N'windowMeterDataReport', N'Run Meter Data Report', NULL, 0, 10141399, 15000000, 75, 0, N'sa', CAST(0x0000A64200A412F1 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3043, 10131300, N'windowImportDataDeal', N'Price Curves Import', NULL, 0, 10141399, 15000000, 76, 0, N'sa', CAST(0x0000A64200A412F1 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3044, 10151000, N'windowViewPrices', N'View Price', NULL, 1, 10141399, 15000000, 77, 0, N'sa', CAST(0x0000A64200A412F1 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3045, 10222399, NULL, N'Run Settlement Process', NULL, 1, 15000000, 15000000, 78, 1, N'sa', CAST(0x0000A64200A412F1 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3046, 10222300, N'windowRunSettlement', N'Run Deal Settlement', NULL, 1, 10222399, 15000000, 79, 0, N'sa', CAST(0x0000A64200A412F1 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3047, 10221000, N'windowMaintainInvoice', N'Process Invoice', NULL, 1, 10222399, 15000000, 80, 0, N'sa', CAST(0x0000A64200A412F1 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3048, 10221300, N'windowMaintainInvoiceHistory', N'View Invoice', NULL, 1, 10222399, 15000000, 81, 0, N'sa', CAST(0x0000A64200A412F2 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3049, 10181000, N'windowRunMtmCalc', N'Run MTM Process', NULL, 0, 10222399, 15000000, 82, 0, N'sa', CAST(0x0000A64200A412F2 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3050, 10221600, N'windowSettlementAdjustments', N'Compare Prior Settlement for Adjustments', NULL, 0, 10222399, 15000000, 83, 0, N'sa', CAST(0x0000A64200A412F2 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3051, 10221999, NULL, N'Reporting', NULL, 1, 15000000, 15000000, 85, 1, N'sa', CAST(0x0000A64200A412F2 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3052, 10221900, N'windowSettlementReport', N'Run Settlement Report', NULL, 0, 10221999, 15000000, 86, 0, N'sa', CAST(0x0000A64200A412F2 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3053, 10221200, N'windowBrokerFeeReport', N'Run Contract Settlement Report', NULL, 0, 10221999, 15000000, 87, 0, N'sa', CAST(0x0000A64200A412F2 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3054, 10181100, N'windowMTMReport', N'Run Forward Report', NULL, 0, 10221999, 15000000, 88, 0, N'sa', CAST(0x0000A64200A412F2 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3055, 10221800, N'windowSettlementProductionReport', N'Run Settlement Production Report', NULL, 0, 10221999, 15000000, 89, 0, N'sa', CAST(0x0000A64200A412F2 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3056, 10221700, N'windowMarketVarienceReport', N'Market Variance Report', NULL, 0, 10221999, 15000000, 90, 0, N'sa', CAST(0x0000A64200A412F2 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3057, 10201000, N'windowreportwriter', N'Report Writer', NULL, 0, 10221999, 15000000, 91, 0, N'sa', CAST(0x0000A64200A412F2 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3058, 10201100, N'WindowRunDashReport', N'Run Dashboard Report', NULL, 0, 10221999, 15000000, 92, 0, N'sa', CAST(0x0000A64200A412F2 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3059, 10201200, N'WindowDashReportTemplate', N'Dashboard Report Template', NULL, 0, 10221999, 15000000, 93, 0, N'sa', CAST(0x0000A64200A412F2 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3060, 10201300, N'windowMaintainEoDLogStatus', N'Maintain EoD Log Status', NULL, 0, 10221999, 15000000, 94, 0, N'sa', CAST(0x0000A64200A412F2 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3061, 10201400, N'windowRunFilesImportAuditReportPrice', N'Run Import Audit Report', NULL, 0, 10221999, 15000000, 95, 0, N'sa', CAST(0x0000A64200A412F2 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3062, 10101399, NULL, N'Setup Accounts', NULL, 1, 15000000, 15000000, 96, 1, N'sa', CAST(0x0000A64200A412F2 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3063, 10101300, N'windowMapGLCodes', N'Setup GL Code', NULL, 1, 10101399, 15000000, 97, 0, N'sa', CAST(0x0000A64200A412F3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3064, 15190100, N'windowMaintainStaticDataContractComponentGLCode', N'Maintain Contract Components GL Codes Def', NULL, 0, 10101399, 15000000, 98, 0, N'sa', CAST(0x0000A64200A412F3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3065, 10103300, N'windowDefineInvoiceGLCode', N'Setup GL Group', NULL, 1, 10101399, 15000000, 99, 0, N'sa', CAST(0x0000A64200A412F3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3066, 10103400, N'windowSetupDefaultGLCode', N'Setup Default GL Group', NULL, 1, 10101399, 15000000, 100, 0, N'sa', CAST(0x0000A64200A412F3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3068, 10231000, N'windowMaintainManualJournalEntries', N'Add Manual Entries', NULL, 0, 10231099, 15000000, 102, 0, N'sa', CAST(0x0000A64200A412F3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3069, 10231700, N'windowRunInventoryJournalEntryReport', N'Run Accrual Journal Entry Report', NULL, 0, 10231099, 15000000, 103, 0, N'sa', CAST(0x0000A64200A412F3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3070, 10221400, N'windowPostJEReport', N'Post JE Report', NULL, 0, 10231099, 15000000, 104, 0, N'sa', CAST(0x0000A64200A412F3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3071, 10233600, N'windowCloseMeasurement', N'Close Settlement Accounting Period', NULL, 1, 10202299, 15000000, 1, 0, N'sa', CAST(0x0000A64200A412F3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3072, 10240000, NULL, N'Treasury', NULL, 0, 15000000, 15000000, 106, 1, N'sa', CAST(0x0000A64200A412F3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3073, 10241000, N'windowReconcileCashEntriesDerivatives', N'Reconcile Cash Entries for Derivatives', NULL, 0, 10240000, 15000000, 107, 0, N'sa', CAST(0x0000A64200A412F3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3074, 10241100, N'windowApplyCash', N'Apply Cash', NULL, 1, 10222399, 15000000, 108, 0, N'sa', CAST(0x0000A64200A412F3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3075, 10106300, N'windowDataImportExport', N'Data Import/Export', NULL, 1, 10100000, 15000000, 22, 0, N'sa', CAST(0x0000A64200A412F3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3076, 10201900, N'windowDataImportExportAuditReport', N'Run Data Import/Export Audit Report', NULL, 0, 10221999, 15000000, 16, 0, N'sa', CAST(0x0000A64200A412F3 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3077, 10122500, N'windowSetupAlerts', N'Setup Alert', NULL, 1, 10106699, 15000000, 49, 0, N'sa', CAST(0x0000A64200A412F4 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3078, 10101182, N'WindowDefineUOMConversion', N'Setup UOM Conversion', NULL, 1, 10101099, 15000000, 8, 0, N'sa', CAST(0x0000A64200A412F4 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3079, 10211300, N'windowNonStandardContract', N'Setup Non-Standard Contract', NULL, 1, 10191099, 15000000, 136, 0, N'sa', CAST(0x0000A64200A412F4 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3080, 10202200, N'windowViewReport', N'View Report', NULL, 1, 10221999, 15000000, 155, 0, N'sa', CAST(0x0000A64200A412F4 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3081, 10201600, N'windowReportManager', N'Report Manager - Old', NULL, 1, 10221999, 15000000, 156, 0, N'sa', CAST(0x0000A64200A412F4 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3082, 10211100, N'windowContractChargeType', N'Setup Contract Component Template', NULL, 1, 15140000, 15000000, 66, 0, N'sa', CAST(0x0000A64200A412F4 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3083, 10106100, N'windowSetupTimeSeries', N'Setup Time Series', NULL, 1, 15130199, 15000000, 19, 0, N'sa', CAST(0x0000A64200A412F4 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3084, 10211213, N'windowReportTemplateSetup', N'Setup Custom Report Template', NULL, 1, 10104099, 15000000, 23, 0, N'sa', CAST(0x0000A64200A412F4 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3085, 13102000, N'windowGenericMapping', N'Generic Mapping', NULL, 1, 10100000, 15000000, 21, 0, N'sa', CAST(0x0000A64200A412F4 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3086, 10104900, N'windowEmailSetup', N'Compose Email', NULL, 1, 10104099, 15000000, 25, 0, N'sa', CAST(0x0000A64200A412F4 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3087, 10202201, N'windowSAPSettlementExport', N'Export GL Entry', NULL, 1, 10202299, 15000000, 1, 0, N'sa', CAST(0x0000A64200A412F4 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3088, 10131000, N'windowMaintainDeals', N'Create and View Deal', NULL, 1, 10191099, 15000000, 70, 0, N'sa', CAST(0x0000A64200A412F4 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3089, 10106700, N'windowManageApproval', N'Manage Approval', NULL, 1, 10106699, 15000000, 53, 0, N'sa', CAST(0x0000A64200A412F4 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3090, 10106600, N'windowRulesWorkflow', N'Setup Rule Workflow', NULL, 1, 10106699, 15000000, 52, 0, N'sa', CAST(0x0000A64200A412F4 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3091, 10104600, N'windowMaintainNettingGrp', N'Setup Settlement Netting Group', NULL, 1, 15140000, 15000000, 17, 0, N'sa', CAST(0x0000A64200A412F4 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3092, 10104099, NULL, N'Template', NULL, 1, 10100000, 15000000, 1, 1, N'sa', CAST(0x0000A64200A412F6 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3093, 10106699, NULL, N'Alert and Workflow', NULL, 1, 15000000, 15000000, 1, 1, N'sa', CAST(0x0000A64200A412F7 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3094, 10211400, NULL, N'Setup Transportation Contract', NULL, 1, 10191099, 15000000, 1, 0, N'sa', CAST(0x0000A64200A412FA AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3095, 10231000, NULL, N'Setup Inventory GL Account', NULL, 1, 10101399, 15000000, 1, 0, N'sa', CAST(0x0000A64200A412FB AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3096, 10202299, NULL, N'Disclosure', NULL, 1, 15000000, 15000000, 1, 1, N'sa', CAST(0x0000A64200A412FC AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3097, 10201800, NULL, N'Report Group Manager', NULL, 1, 10221999, 15000000, 0, 0, N'sa', CAST(0x0000A64200A412FD AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3098, 10202500, NULL, N'Report Manager', NULL, 1, 10221999, 15000000, 0, 0, N'sa', CAST(0x0000A64200A412FE AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3099, 10106800, NULL, N'Calendar', NULL, 0, 10100000, 10000000, 111, 0, N'sa', CAST(0x0000A64300973B56 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3100, 10106900, NULL, N'Manage Email', NULL, 1, 10100000, 10000000, 51, 0, N'sa', CAST(0x0000A6440094D20A AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3101, 10201800, NULL, N'Report Group Manager', NULL, 1, 13121295, 13000000, 0, 0, N'sa', CAST(0x0000A64801244F8B AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3102, 10106699, NULL, N'Alert and Workflow', NULL, 1, 10100000, 13000000, 0, 1, N'sa', CAST(0x0000A64801244F8B AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3103, 10106600, NULL, N'Setup Workflow/Alert', NULL, 1, 10106699, 13000000, 0, 0, N'sa', CAST(0x0000A64801244F8C AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3104, 10106700, NULL, N'Manage Approval', NULL, 1, 10106699, 13000000, 0, 0, N'sa', CAST(0x0000A64801244F8C AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3105, 10122600, NULL, N'Setup Simple Alert', NULL, 1, 10106699, 13000000, 0, 0, N'sa', CAST(0x0000A64801244F8C AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3106, 12101720, N'windowAssignmentForm', N'Assignment Form', NULL, 0, 12101700, 14000000, 50, 0, N'sa', CAST(0x0000A64B00BBA785 AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3107, 12101712, N'windowSetupSourceGroup', N'Setup Source Group', NULL, 0, 12101700, 14000000, 50, 0, N'sa', CAST(0x0000A64B00BBB2CC AS DateTime), NULL, NULL)
GO
INSERT [dbo].[setup_menu] ([setup_menu_id], [function_id], [window_name], [display_name], [default_parameter], [hide_show], [parent_menu_id], [product_category], [menu_order], [menu_type], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3108, 12101700, N'windowSetupRenewableSource', N'Setup Renewable Source', NULL, 1, 10101099, 10000000, 2, 0, N'sa', CAST(0x0000A64E00AC80D1 AS DateTime), NULL, NULL)
GO
SET IDENTITY_INSERT [dbo].[setup_menu] OFF
GO



IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10202000 AND product_category = 15000000)
INSERT INTO setup_menu(function_id,window_name,display_name,default_parameter,hide_show,parent_menu_id,product_category,menu_order,menu_type)
VALUES(10202000,NULL,'User Activity Log Report',NULL,0,10202200,15000000,3,NULL)

IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10202100 AND product_category = 15000000)
INSERT INTO setup_menu(function_id,window_name,display_name,default_parameter,hide_show,parent_menu_id,product_category,menu_order,menu_type)
VALUES(10202100,NULL,'Message Board Log Report',NULL,0,10202200,15000000,4,NULL)

IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10221200 AND product_category = 15000000)
INSERT INTO setup_menu(function_id,window_name,display_name,default_parameter,hide_show,parent_menu_id,product_category,menu_order,menu_type)
VALUES(10221200,NULL,'Contract Settlement Report',NULL,0,10202200,15000000,6,NULL)

IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10171100 AND product_category = 15000000)
INSERT INTO setup_menu(function_id,window_name,display_name,default_parameter,hide_show,parent_menu_id,product_category,menu_order,menu_type)
VALUES(10171100,NULL,'Transaction Audit Log Report',NULL,0,10202200,15000000,10,NULL)

IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10201500 AND product_category = 15000000)
INSERT INTO setup_menu(function_id,window_name,display_name,default_parameter,hide_show,parent_menu_id,product_category,menu_order,menu_type)
VALUES(10201500,NULL,'Static Data Audit Report',NULL,0,10202200,15000000,11,NULL)

IF NOT EXISTS(SELECT * FROM setup_menu WHERE function_id = 10201900 AND product_category = 15000000)
INSERT INTO setup_menu(function_id,window_name,display_name,default_parameter,hide_show,parent_menu_id,product_category,menu_order,menu_type)
VALUES(10201900,NULL,'Data Import/Export Audit Report',NULL,0,10202200,15000000,12,NULL)

UPDATE setup_menu 
SET display_name = 'Contract Settlement Report'
WHERE display_name = 'Run Contract Settlement Report' AND product_category = 15000000

UPDATE setup_menu 
SET display_name = 'Data Import/Export Audit Report'
WHERE display_name = 'Run Data Import/Export Audit Report' AND product_category = 15000000