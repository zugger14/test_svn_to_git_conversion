
delete [pricing_period_setup]
INSERT [dbo].[pricing_period_setup] ([pricing_period_value_id], [period_type], [average_period], [skip_period], [delivery_period], [expiration_calendar], [formula_id])
     VALUES
( 106601, N'm', 0, 0, 1, 1, NULL),
( 106607, N'w', 1, 0, 1, 0, NULL),
( 106606, N'm', 1, 0, 1, 0, NULL),
( 106605, N'f', 1, 0, 1, 0, NULL),
( 106604, N'd', NULL, NULL, NULL, 0, NULL),
( 106603, N'm', NULL, NULL, NULL, 1, NULL),
( 106602, N'd', NULL, NULL, NULL, 0, NULL),
( 106600, N'm', 0, 0, 1, 0, NULL),
( 106608, N'd', NULL, NULL, NULL, 0, NULL),
( 106610,'m', 0, 0,1,1,NULL)