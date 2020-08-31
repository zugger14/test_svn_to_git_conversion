IF NOT EXISTS(select 1  from report_status where report_status_id = 1)
BEGIN
INSERT [dbo].[report_status] ([report_status_id], [name], [description], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1, N'Draft', N'Draft', N'farrms_admin', CAST(0x0000A21500ABF6A8 AS DateTime), NULL, NULL)
END
GO
IF NOT EXISTS(select 1  from report_status where report_status_id = 2)
BEGIN
INSERT [dbo].[report_status] ([report_status_id], [name], [description], [create_user], [create_ts], [update_user], [update_ts]) VALUES (2, N'Public', N'Public', N'farrms_admin', CAST(0x0000A21500ABF6A8 AS DateTime), NULL, NULL)
END
GO
IF NOT EXISTS(select 1  from report_status where report_status_id = 3)
BEGIN
INSERT [dbo].[report_status] ([report_status_id], [name], [description], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3, N'Private', N'Private', N'farrms_admin', CAST(0x0000A21500ABF6A9 AS DateTime), NULL, NULL)
END
GO
IF NOT EXISTS(select 1  from report_status where report_status_id = 4)
BEGIN
INSERT [dbo].[report_status] ([report_status_id], [name], [description], [create_user], [create_ts], [update_user], [update_ts]) VALUES (4, N'Hidden', N'Hidden', N'farrms_admin', CAST(0x0000A21500ABF6A9 AS DateTime), NULL, NULL)
END
GO
PRINT 'Inserted [report_status]'
