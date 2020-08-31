--TRMTracker
IF EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20014000 AND sm.product_category = 10000000)
BEGIN
	UPDATE setup_menu SET parent_menu_id = 20014000 WHERE function_id IN (10120000,10200000,10100000,10110000) AND product_category = 10000000 AND parent_menu_id <> 20014000
END

IF EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20014100 AND sm.product_category = 10000000)
BEGIN
	UPDATE setup_menu SET parent_menu_id = 20014100 WHERE function_id IN (10130000,10140000,10150000,10160000) AND product_category = 10000000 AND parent_menu_id <> 20014100
END

IF EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20014200 AND sm.product_category = 10000000)
BEGIN
	UPDATE setup_menu SET parent_menu_id = 20014200 WHERE function_id IN (10190000,10170000,10180000) AND product_category = 10000000 AND parent_menu_id <> 20014200
END

IF EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20014300 AND sm.product_category = 10000000)
BEGIN
	UPDATE setup_menu SET parent_menu_id = 20014300 WHERE function_id IN (15190000,10210000,13240000,10220000) AND product_category = 10000000 AND parent_menu_id <> 20014300
END

--FASTracker
IF EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20014000 AND sm.product_category = 13000000)
BEGIN
	UPDATE setup_menu SET parent_menu_id = 20014000 WHERE function_id IN (10100000,10110000,10120000) AND product_category = 13000000 AND parent_menu_id <> 20014000
END

IF EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20014400 AND sm.product_category = 13000000)
BEGIN
	UPDATE setup_menu SET parent_menu_id = 20014400 WHERE function_id IN (10130000,13180000,13190000) AND product_category = 13000000 AND parent_menu_id <> 20014400
END

IF EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20014500 AND sm.product_category = 13000000)
BEGIN
	UPDATE setup_menu SET parent_menu_id = 20014500 WHERE function_id IN (13200000,13210000,13230000,13121295) AND product_category = 13000000 AND parent_menu_id <> 20014500
END

IF EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20014600 AND sm.product_category = 13000000)
BEGIN
	UPDATE setup_menu SET parent_menu_id = 20014600 WHERE function_id IN (10235499,13220000) AND product_category = 13000000 AND parent_menu_id <> 20014600
END

--RECTracker
IF EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20014000 AND sm.product_category = 14000000)
BEGIN
	UPDATE setup_menu SET parent_menu_id = 20014000 WHERE function_id IN (10200000,10100000,10110000) AND product_category = 14000000 AND parent_menu_id <> 20014000
END

IF EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20014700 AND sm.product_category = 14000000)
BEGIN
	UPDATE setup_menu SET parent_menu_id = 20014700 WHERE function_id IN (14100000,12100000,12130000,10150000,14110000) AND product_category = 14000000 AND parent_menu_id <> 20014700
END

IF EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20014200 AND sm.product_category = 14000000)
BEGIN
	UPDATE setup_menu SET parent_menu_id = 20014200 WHERE function_id IN (10190000,10170000,10180000) AND product_category = 14000000 AND parent_menu_id <> 20014200
END

IF EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20014300 AND sm.product_category = 14000000)
BEGIN
	UPDATE setup_menu SET parent_menu_id = 20014300 WHERE function_id IN (15190000,10210000,13240000,10220000) AND product_category = 14000000 AND parent_menu_id <> 20014300
END

-- SettlementTracker
IF EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20014000 AND sm.product_category = 15000000)
BEGIN
	UPDATE setup_menu SET parent_menu_id = 20014000 WHERE function_id IN (10106699,10221999,10100000,10110000) AND product_category = 15000000 AND parent_menu_id <> 20014000
END

IF EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20014800 AND sm.product_category = 15000000)
BEGIN
	UPDATE setup_menu SET parent_menu_id = 20014800 WHERE function_id IN (10191099,15140000,15130199) AND product_category = 15000000 AND parent_menu_id <> 20014800
END

IF EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20014900 AND sm.product_category = 15000000)
BEGIN
	UPDATE setup_menu SET parent_menu_id = 20014900 WHERE function_id IN (10141399,10222399) AND product_category = 15000000 AND parent_menu_id <> 20014900
END

IF EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20015000 AND sm.product_category = 15000000)
BEGIN
	UPDATE setup_menu SET parent_menu_id = 20015000 WHERE function_id IN (10101399,10202299) AND product_category = 15000000 AND parent_menu_id <> 20015000
END
