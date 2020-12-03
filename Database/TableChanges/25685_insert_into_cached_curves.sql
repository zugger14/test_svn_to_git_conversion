
IF OBJECT_ID('tempdb..#temp') IS NOT NULL
    DROP TABLE #temp

CREATE TABLE #temp (
	row_id INT NOT NULL IDENTITY(1,1) PRIMARY KEY ,
	curve_id VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
	strip_month_from INT,
	lag_months INT, 
	strip_month_to INT,
	expiration_type VARCHAR(30) COLLATE DATABASE_DEFAULT,
	expiration_value VARCHAR(30) COLLATE DATABASE_DEFAULT,
	index_round_value INT,
	fx_round_value INT,
	total_round_value INT,
	fx_curve_id INT,
	operation_type VARCHAR(1) COLLATE DATABASE_DEFAULT,
	bid_ask_round_value INT
	)

INSERT INTO #temp(
	curve_id
	,strip_month_from
	,lag_months
	,strip_month_to
	,expiration_type
	,expiration_value
	,index_round_value
	,fx_round_value
	,total_round_value
	,fx_curve_id
	,operation_type
	,bid_ask_round_value
	)

VALUES('POWER.DE.EEX.Y.BL.12-6-12',0,0,12,NULL,NULL,9,9,9,NULL,NULL,NULL),
	('POWER.DE.EEX.Y.PK.12-6-12',0,0,12,NULL,NULL,9,9,9,NULL,NULL,NULL),
	('POWER.DE.EEX.Y.BL.12-0-12',0,0,12,NULL,NULL,9,9,9,NULL,NULL,NULL),
	('POWER.DE.EEX.Y.PK.12-0-12',0,0,12,NULL,NULL,9,9,9,NULL,NULL,NULL),
	('POWER.DE.EEX.Y.BL.30-6-12',0,0,12,NULL,NULL,9,9,9,NULL,NULL,NULL),
	('POWER.DE.EEX.Y.PK.30-6-12',0,0,12,NULL,NULL,9,9,9,NULL,NULL,NULL),
	('POWER.DE.EEX.Y.BL.11-1-12',0,0,12,NULL,NULL,9,9,9,NULL,NULL,NULL),
	('POWER.DE.EEX.Y.PK.11-1-12',0,0,12,NULL,NULL,9,9,9,NULL,NULL,NULL),
	('POWER.DE.EEX.Y.BL.17-1-12',0,0,12,NULL,NULL,9,9,9,NULL,NULL,NULL),
	('POWER.DE.EEX.Y.PK.17-1-12',0,0,12,NULL,NULL,9,9,9,NULL,NULL,NULL),
	('POWER.DE.EEX.Y.BL.29-1-12',0,0,12,NULL,NULL,9,9,9,NULL,NULL,NULL),
	('POWER.DE.EEX.Y.PK.29-1-12',0,0,12,NULL,NULL,9,9,9,NULL,NULL,NULL),
	('GAS.NCH.EEX.Y.Partner.eCG',0,0,12,NULL,NULL,9,9,9,NULL,NULL,NULL),
	('GAS.NCH.EEX.Y.Partner.GKW',0,0,12,NULL,NULL,9,9,9,NULL,NULL,NULL),
	('GAS.NCH.EEX.Y.Partner.Hessen',0,0,12,NULL,NULL,9,9,9,NULL,NULL,NULL),
	('GAS.NCL.INDEX.Y.Partnergas',0,0,12,NULL,NULL,9,9,9,NULL,NULL,NULL),
	('GAS.NCH.EEX.M.Live',0,0,1,NULL,NULL,9,9,9,NULL,NULL,NULL),
	('POWER.DE.EEX.Y.FutPK',0,0,12,NULL,NULL,9,9,9,NULL,NULL,NULL),
	('POWER.DE.EEX.Y.FutBL',0,0,12,NULL,NULL,9,9,9,NULL,NULL,NULL),
	('POWER.DE.EEX.M.FutBL-LiveStrom',0,0,1,NULL,NULL,9,9,9,NULL,NULL,NULL),
	('POWER.DE.EEX.M.FutPK-LiveStrom',0,0,1,NULL,NULL,9,9,9,NULL,NULL,NULL)

 INSERT INTO cached_curves (
	curve_id
	,strip_month_from
	,lag_months
	,strip_month_to
	,expiration_type
	,expiration_value
	,index_round_value
	,fx_round_value
	,total_round_value
	,fx_curve_id
	,operation_type
	,bid_ask_round_value
	)
SELECT 
	spc.source_curve_def_id
	,t.strip_month_from
	,t.lag_months
	,t.strip_month_to
	,t.expiration_type
	,t.expiration_value
	,t.index_round_value
	,t.fx_round_value
	,t.total_round_value
	,t.fx_curve_id
	,t.operation_type
	,t.bid_ask_round_value 
FROM #temp t
INNER JOIN source_price_curve_def spc
	ON t.curve_id = spc.curve_id
LEFT JOIN cached_curves cc
	ON cc.curve_id = spc.source_curve_def_id
WHERE cc.ROWID IS NULL
