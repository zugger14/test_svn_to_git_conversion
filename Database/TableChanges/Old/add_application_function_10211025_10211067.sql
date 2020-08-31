--this is the function id for the dynamiccurve
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211025)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211025, 'Dynamic Curve', 'Dynamic curve', 10211017, 'windowDynamicCurve')
 	PRINT ' Inserted 10211025 - Dynamic Curve.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211025 - Dynamic Curve already EXISTS.'
END

--this is the function id for the Deal Float Price
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211026)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211026, 'Deal Float Price', 'Deal Float Price', 10211017, 'windowDealFloatPrice')
 	PRINT ' Inserted 10211026 - Deal Float Price.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211026 - Deal Float Price already EXISTS.'
END

--this is the function id for the Static Curve
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211027)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211027, 'Static Curve', 'Static Curve', 10211017, 'windowStaticCurve')
 	PRINT ' Inserted 10211027 - Static Curve.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211027 - Static Curve already EXISTS.'
END

--this is the function id for the Average Daily Price
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211028)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211028, 'Average Daily Price', 'Average Daily Price', 10211017, 'windowAverageDailyPrice')
 	PRINT ' Inserted 10211028 - Average Daily Price.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211028 - Average Daily Price already EXISTS.'
END

--this is the function id for the Average Hourly Price
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211029)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211029, 'Average Hourly Price', 'Average Hourly Price', 10211017, 'windowAverageHourlyPrice')
 	PRINT ' Inserted 10211029 - Average Hourly Price.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211029 - Average Hourly Price already EXISTS.'
END

--this is the function id for the Deal Net Price
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211030)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211030, 'Deal Net Price', 'Deal Net Price', 10211017, 'windowDealNetPrice')
 	PRINT ' Inserted 10211030 - Deal Net Price.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211030 - Deal Net Price already EXISTS.'
END

--this is the function id for the Deal CurveH
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211031)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211031, 'CurveH', 'Curve H', 10211017, 'windowCurveH')
 	PRINT ' Inserted 10211031 - CurveH.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211031 - CurveH already EXISTS.'
END

--this is the function id for the Deal CurveH
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211032)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211032, 'Deal Settlement', 'Deal Settlement', 10211017, 'windowDealSettlement')
 	PRINT ' Inserted 10211032 - Deal Settlement.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211032 - Deal Settlement already EXISTS.'
END


--this is the function id for the Deal CurveH
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211033)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211033, 'CurveY', 'CurveY', 10211017, 'windowCurveY')
 	PRINT ' Inserted 10211033 - CurveY.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211033 - CurveY already EXISTS.'
END

--this is the function id for the Fixed Curve
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211034)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211034, 'FixedCurve', 'FixedCurve', 10211017, 'windowFixedCurve')
 	PRINT ' Inserted 10211034 - FixedCurve.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211034 - FixedCurve already EXISTS.'
END

--this is the function id for the DealFVolm
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211035)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211035, 'DealFVolm', 'DealFVolm', 10211017, 'windowDealFVolm')
 	PRINT ' Inserted 10211035 - DealFVolm.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211035 - DealFVolm already EXISTS.'
END

--this is the function id for the curveD
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211036)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211036, 'curveD', 'curveD', 10211017, 'windowCurveD')
 	PRINT ' Inserted 10211036 - curveD.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211036 - curveD already EXISTS.'
END

--this is the function id for the counterPartyMTM
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211037)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211037, 'counterPartyMTM', 'counterPartyMTM', 10211017, 'windowCounterPartyMTM ')
 	PRINT ' Inserted 10211037 - counterPartyMTM.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211037 - counterPartyMTM already EXISTS.'
END

--this is the function id for the MxPrice
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211038)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211038, 'MxPrice', 'MxPrice', 10211017, 'windowMxPrice')
 	PRINT ' Inserted 10211038 - MxPrice.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211038 - MxPrice already EXISTS.'
END

--this is the function id for the MnPrice
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211039)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211039, 'MnPrice', 'MnPrice', 10211017, 'windowMnPrice')
 	PRINT ' Inserted 10211039 - MnPrice.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211039 - MnPrice already EXISTS.'
END

--this is the function id for the Counterparty MTM Net Pwr Purchase
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211040)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211040, 'Counterparty MTM Net Pwr Purchase', 'Counterparty MTM Net Pwr Purchase', 10211017, 'windowCalculateBucketID')
 	PRINT ' Inserted 10211040 - Counterparty MTM Net Pwr Purchase.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211040 - Counterparty MTM Net Pwr Purchase already EXISTS.'
END

--this is the function id for the Counterparty MTM Net Pwr Purchase
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211041)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211041, 'Load Volume', 'Load Volume', 10211017, 'windowCalculateBucketID')
 	PRINT ' Inserted 10211041 - Load Volume.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211041 - Load Volume already EXISTS.'
END

--this is the function id for the Counterparty MTM Net Pwr Purchase
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211042)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211042, 'Interrupt Vol', 'Interrupt Vol', 10211017, 'windowInterruptVol')
 	PRINT ' Inserted 10211042 - Interrupt Vol.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211042 - Interrupt Vol already EXISTS.'
END

--this is the function id for the ExPostPrice
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211043)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211043, 'ExPostPrice', 'ExPostPrice', 10211017, 'windowExPostPrice')
 	PRINT ' Inserted 10211043 - ExPostPrice.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211043 - ExPostPrice already EXISTS.'
END

--this is the function id for the ExAntePrice
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211044)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211044, 'ExAntePrice', 'ExAntePrice', 10211017, 'windowExAntePrice')
 	PRINT ' Inserted 10211044 - ExAntePrice.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211044 - ExAntePrice already EXISTS.'
END

--this is the function id for the Interrupt Calc
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211045)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211045, 'Interrupt Calc', 'Interrupt Calc', 10211017, 'windowInterruptCalc')
 	PRINT ' Inserted 10211045 - Interrupt Calc.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211045 - Interrupt Calc already EXISTS.'
END

--this is the function id for the Settlement Date 
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211046)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211046, 'Settlement Date', 'Settlement Date', 10211017, 'windowSettlementDate')
 	PRINT ' Inserted 10211046 - Settlement Date.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211046 - Settlement Date already EXISTS.'
END

--this is the function id for the Channel 
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211047)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211047, 'Channel', 'Channel', 10211017, 'windowChannel')
 	PRINT ' Inserted 10211047 - Channel.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211047 - Channel already EXISTS.'
END

--this is the function id for the ROW 
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211048)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211048, 'ROW', 'ROW', 10211017, 'windowRow')
 	PRINT ' Inserted 10211048 - ROW.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211048 - ROW already EXISTS.'
END

--this is the function id for the ROlling Avg 
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211049)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211049, 'Rolling Avg', 'Rolling Avg', 10211017, 'windowCalculateRolling')
 	PRINT ' Inserted 10211049 - Rolling Avg.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211049 - Rolling Avg already EXISTS.'
END

--this is the function id for the ROlling Sum
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211050)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211050, 'Rolling Sum', 'Rolling Sum', 10211017, 'windowCalculateRolling')
 	PRINT ' Inserted 10211050 - Rolling Sum.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211050 - Rolling Sum already EXISTS.'
END

--this is the function id for the last Mnth Value
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211051)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211051, 'last Mnth Value', 'last Mnth Value', 10211017, 'windowCalculateRow')
 	PRINT ' Inserted 10211051 - last Mnth Value.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211051 - last Mnth Value already EXISTS.'
END


--this is the function id for the Annual VolCOD
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211052)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211052, 'Annual VolCOD', 'Annual VolCOD', 10211017, 'windowCalculateRow')
 	PRINT ' Inserted 10211052 - Annual VolCOD.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211052 - Annual VolCOD already EXISTS.'
END

--this is the function id for the Annual VolCOD
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211053)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211053, 'GeneratorMxHour', 'GeneratorMxHour', 10211017, 'windowCalculateRow')
 	PRINT ' Inserted 10211053 - GeneratorMxHour.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211053 - GeneratorMxHour already EXISTS.'
END

--this is the function id for the Annual VolCOD
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211054)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211054, 'CorresMnthValue', 'CorresMnthValue', 10211017, 'windowCalculateRolling')
 	PRINT ' Inserted 10211054 - CorresMnthValue.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211054 - CorresMnthValue already EXISTS.'
END

--this is the function id for the MnthlyRollingAvg
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211055)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211055, 'MnthlyRollingAvg', 'MnthlyRollingAvg', 10211017, 'windowCalculateRolling')
 	PRINT ' Inserted 10211055 - MnthlyRollingAvg.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211055 - MnthlyRollingAvg already EXISTS.'
END

--this is the function id for the MxRwValue
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211056)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211056, 'MxRwValue', 'MxRwValue', 10211017, 'windowCalculateRolling')
 	PRINT ' Inserted 10211056 - MxRwValue.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211056 - MxRwValue already EXISTS.'
END

--this is the function id for the ContractVol
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211057)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211057, 'ContractVol', 'ContractVol', 10211017, 'windowContractVolume')
 	PRINT ' Inserted 10211057 - ContractVol.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211057 - ContractVol already EXISTS.'
END

--this is the function id for the MxRwValue
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211058)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211058, 'MeterVol', 'MeterVol', 10211017, 'windowMeterVol')
 	PRINT ' Inserted 10211058 - MeterVol.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211058 - MeterVol already EXISTS.'
END

--this is the function id for the MxRwValue
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211059)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211059, 'WACOG Sale', 'WACOG Sale', 10211017, 'windowWacogSale')
 	PRINT ' Inserted 10211059 - WACOG Sale.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211059 - WACOG Sale already EXISTS.'
END

--this is the function id for the WACOG Buy
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211060)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211060, 'WACOG Buy', 'WACOG Buy', 10211017, 'windowWacogBuy')
 	PRINT ' Inserted 10211060 - WACOG Buy.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211060 - WACOG Buy already EXISTS.'
END

--this is the function id for the Prior Curve
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211061)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211061, 'Prior Curve', 'Prior Curve', 10211017, 'windowPriorCurve')
 	PRINT ' Inserted 10211061 - Prior Curve.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211061 - Prior Curve already EXISTS.'
END

--this is the function id for the DailyRollingAveg
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211062)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211062, 'DailyRollingAveg', 'DailyRollingAveg', 10211017, 'windowDailyRollingAveg')
 	PRINT ' Inserted 10211062 - DailyRollingAveg.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211062 - DailyRollingAveg already EXISTS.'
END

--this is the function id for the CVD
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211063)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211063, 'CVD', 'CVD', 10211017, 'windowCVD')
 	PRINT ' Inserted 10211063 - CVD.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211063 - CVD already EXISTS.'
END

--this is the function id for the Peak Hours
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211064)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211064, 'Peak Hours', 'Peak Hours', 10211017, 'windowPeakHours')
 	PRINT ' Inserted 10211064 - Peak Hours.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211064 - Peak Hours already EXISTS.'
END

--this is the function id for the Relative Period
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211065)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211065, 'Relative Period', 'Relative Period', 10211017, 'windowRelativePeriod')
 	PRINT ' Inserted 10211065 - Relative Period.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211065 - Relative Period already EXISTS.'
END

--this is the function id for the Relative Period
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211066)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211066, '3Hrs2Samples', '3Hrs2Samples', 10211017, 'window3Hrs2Samples')
 	PRINT ' Inserted 10211066 - 3Hrs2Samples.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211066 - 3Hrs2Samples already EXISTS.'
END

--this is the function id for the Relative Period
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211067)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211067, '24HrsAvg', '24HrsAvg', 10211017, 'window24HrsAvg')
 	PRINT ' Inserted 10211067 - 24HrsAvg.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211067 - 24HrsAvg already EXISTS.'
END