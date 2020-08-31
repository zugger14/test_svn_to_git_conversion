IF NOT EXISTS(SELECT 1 FROM sys.tables t INNER JOIN sys.columns c ON t.object_id = c.object_id  where t.name = 'pnl_explain_view' AND c.name = 'pnl_Delta1')
BEGIN
	ALTER TABLE dbo.[pnl_explain_view]
	ADD pnl_Delta1 FLOAT
	PRINT 'pnl_Delta1 IS  ADDED'
END
ELSE PRINT 'pnl_Delta1 IS ALready ADDED'


IF NOT EXISTS(SELECT 1 FROM sys.tables t INNER JOIN sys.columns c ON t.object_id = c.object_id  where t.name = 'pnl_explain_view' AND c.name = 'pnl_Delta2')
BEGIN
	ALTER TABLE dbo.[pnl_explain_view]
	ADD pnl_Delta2 FLOAT
	PRINT 'pnl_Delta2 IS  ADDED'
END
ELSE PRINT 'pnl_Delta2 IS ALready ADDED'

IF NOT EXISTS(SELECT 1 FROM sys.tables t INNER JOIN sys.columns c ON t.object_id = c.object_id  where t.name = 'pnl_explain_view' AND c.name = 'pnl_Gamma1')
BEGIN
	ALTER TABLE dbo.[pnl_explain_view]
	ADD pnl_Gamma1 FLOAT
	PRINT 'pnl_Gamma1 IS  ADDED'
END
ELSE PRINT 'pnl_Gamma1 IS ALready ADDED'

IF NOT EXISTS(SELECT 1 FROM sys.tables t INNER JOIN sys.columns c ON t.object_id = c.object_id  where t.name = 'pnl_explain_view' AND c.name = 'pnl_Gamma2')
BEGIN
	ALTER TABLE dbo.[pnl_explain_view]
	ADD pnl_Gamma2 FLOAT
	PRINT 'pnl_Gamma2 IS  ADDED'
END
ELSE PRINT 'pnl_Gamma2 IS ALready ADDED'

IF NOT EXISTS(SELECT 1 FROM sys.tables t INNER JOIN sys.columns c ON t.object_id = c.object_id  where t.name = 'pnl_explain_view' AND c.name = 'pnl_Vega1')
BEGIN
	ALTER TABLE dbo.[pnl_explain_view]
	ADD pnl_Vega1 FLOAT
	PRINT 'pnl_Vega1 IS  ADDED'
END
ELSE PRINT 'pnl_Vega1 IS ALready ADDED'

IF NOT EXISTS(SELECT 1 FROM sys.tables t INNER JOIN sys.columns c ON t.object_id = c.object_id  where t.name = 'pnl_explain_view' AND c.name = 'pnl_Vega2')
BEGIN
	ALTER TABLE dbo.[pnl_explain_view]
	ADD pnl_Vega2 FLOAT
PRINT 'pnl_Vega2 IS  ADDED'
END
ELSE PRINT 'pnl_Vega2 IS ALready ADDED'

IF NOT EXISTS(SELECT 1 FROM sys.tables t INNER JOIN sys.columns c ON t.object_id = c.object_id  where t.name = 'pnl_explain_view' AND c.name = 'pnl_Theta')
BEGIN
	ALTER TABLE dbo.[pnl_explain_view]
	ADD pnl_Theta FLOAT
	PRINT 'pnl_Theta IS  ADDED'
END
ELSE PRINT 'pnl_Theta IS ALready ADDED'

IF NOT EXISTS(SELECT 1 FROM sys.tables t INNER JOIN sys.columns c ON t.object_id = c.object_id  where t.name = 'pnl_explain_view' AND c.name = 'pnl_Rho')
BEGIN
	ALTER TABLE dbo.[pnl_explain_view]
	ADD pnl_Rho FLOAT
	PRINT 'pnl_Rho IS  ADDED'
END
ELSE PRINT 'pnl_Rho IS ALready ADDED'

IF NOT EXISTS(SELECT 1 FROM sys.tables t INNER JOIN sys.columns c ON t.object_id = c.object_id  where t.name = 'pnl_explain_view' AND c.name = 'Method')
BEGIN
	ALTER TABLE dbo.[pnl_explain_view]
	ADD Method FLOAT
	PRINT 'Method IS  ADDED'
END
ELSE PRINT 'Method IS ALready ADDED'

IF NOT EXISTS(SELECT 1 FROM sys.tables t INNER JOIN sys.columns c ON t.object_id = c.object_id  where t.name = 'pnl_explain_view' AND c.name = 'attribute_type')
BEGIN
	ALTER TABLE dbo.[pnl_explain_view]
	ADD attribute_type  VARCHAR(1)
	PRINT 'attribute_type IS  ADDED'
END
ELSE PRINT 'attribute_type IS ALready ADDED'