-- ===========================================================================================================
-- Author: bbishural@pioneersolutionsglobal.com
-- Create date: 2012-06-26
-- Description: Static data value for the functions
-- ===========================================================================================================

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -802)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-802, 800, '<', 'This function is used to tell the sql if the variable are Less Than', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -802 - <.'
END
ELSE
BEGIN
	PRINT 'Static data value -802 - < already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

-- Inserting the static data value for the '<='
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -803)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-803, 800, '<=', 'This function is used to tell the sql if the variable are less than or equal to other', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -803 - <=.'
END
ELSE
BEGIN
	PRINT 'Static data value -803 - <= already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

-- inserting the static data value for the '<>'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -804)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-804, 800, '<>', 'This function is used to tell the sql if the variable is not equal to other variable', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -804 - <>.'
END
ELSE
BEGIN
	PRINT 'Static data value -804 - <> already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

-- inserting the static data value for the '='
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -805)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-805, 800, '=', 'This function is used to tell the sql if the variable is equal or not', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -805 - =.'
END
ELSE
BEGIN
	PRINT 'Static data value -805 - = already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

-- inserting the static data value for the '>'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -806)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-806, 800, '> ', 'This function is used to tell the sql if the variable is greater than', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -806 - > .'
END
ELSE
BEGIN
	PRINT 'Static data value -806 - >  already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

-- inserting the static data value for the '24 hr Continuous Rolling Avg'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -807)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-807, 800, '24 hr Continuous Rolling Avg', '24 hr Continuous Rolling Average of CEMS Data', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -807 - 24 hr Continuous Rolling Avg.'
END
ELSE
BEGIN
	PRINT 'Static data value -807 - 24 hr Continuous Rolling Avg already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

-- inserting the static data value for the '24HrsAverage'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -808)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-808, 800, '24HrsAvg', '24 hr Average of CEMS/Ems (Generator/Input) Data', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -808 - 24HrsAvg.'
END
ELSE
BEGIN
	PRINT 'Static data value -808 - 24HrsAvg already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

-- inserting the static data value for the '3Hrs2Samples'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -809)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-809, 800, '3Hrs2Samples', 'This function is used to calculate the Arithmetic Average of three 2 hr samples', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -809 - 3Hrs2Samples.'
END
ELSE
BEGIN
	PRINT 'Static data value -809 - 3Hrs2Samples already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

-- inserting the static data value for the 'ActualTotalVol'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -810)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-810, 800, 'ActualTotalVol', 'This function returns the sum of actual volumes for a contract month that is entered using View Delivery Transactions form.', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -810 - ActualTotalVol.'
END
ELSE
BEGIN
	PRINT 'Static data value -810 - ActualTotalVol already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

-- inserting the static data value for the 'BookMap'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -811)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-811, 800, 'BookMap', 'This function returns the source system book id', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -811 - BookMap.'
END
ELSE
BEGIN
	PRINT 'Static data value -811 - BookMap already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

-- inserting the static data value for the 'CASE condition'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -812)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-812, 800, 'CASE condition', 'This function is the SQL conditional statements used to tell the system to do as defined if a certain condition occurs.', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -812 - CASE condition.'
END
ELSE
BEGIN
	PRINT 'Static data value -812 - CASE condition already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

-- inserting the static data value for the 'CEILING'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -813)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-813, 800, 'CEILING', 'This function is to evaluate the ceiling function', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -813 - CEILING.'
END
ELSE
BEGIN
	PRINT 'Static data value -813 - CEILING already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

-- inserting the static data value for the 'CoIncidentPeak'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -814)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-814, 800, 'CoIncidentPeak', 'Function CoIncidentPeak', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -814 - CoIncidentPeak.'
END
ELSE
BEGIN
	PRINT 'Static data value -814 - CoIncidentPeak already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

-- inserting the static data value for the 'CO2EmissionsValue'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -815)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-815, 800, 'CO2EmissionsValue', 'Function CO2EmissionsValue', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -815 - CO2EmissionsValue.'
END
ELSE
BEGIN
	PRINT 'Static data value -815 - CO2EmissionsValue already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


-- inserting the static data value for the 'ContractualOffPeakVolm'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -816)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-816, 800, 'ContractualOffPeakVolm', 'This function returns the total volume of deal for offpeak(as defined in source price curve def) block type.', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -816 - ContractualOffPeakVolm.'
END
ELSE
BEGIN
	PRINT 'Static data value -816 - ContractualOffPeakVolm already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

-- inserting the static data value for the 'ContractualOnPeakVolm'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -817)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-817, 800, 'ContractualOnPeakVolm', 'This function returns the total volume of deal for onpeak(as defined in source price curve def) block type. TRMTracker_Essent', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -817 - ContractualOnPeakVolm.'
END
ELSE
BEGIN
	PRINT 'Static data value -817 - ContractualOnPeakVolm already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

-- inserting the static data value for the 'CurveY'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -818)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-818, 800, 'CurveY', 'This function retrieves the Yearly price for the given price curve', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -818 - CurveY.'
END
ELSE
BEGIN
	PRINT 'Static data value -818 - CurveY already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

-- inserting the static data value for the 'CurveM'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -819)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-819, 800, 'CurveM', 'This function retrieves the Monthly price for the given price curve', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -819 - CurveM.'
END
ELSE
BEGIN
	PRINT 'Static data value -819 - CurveM already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

-- inserting the static data value for the 'CurveD'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -820)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-820, 800, 'CurveD', 'This function retrieves the Daily price for the given price curve', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -820 - CurveD.'
END
ELSE
BEGIN
	PRINT 'Static data value -820 - CurveD already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

-- inserting the static data value for the 'CurveH'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -821)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-821, 800, 'CurveH', 'This function retrieves the Hourly price for the given price curve', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -821 - CurveH.'
END
ELSE
BEGIN
	PRINT 'Static data value -821 - CurveH already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

-- inserting the static data value for the 'CVD'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -822)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-822, 800, 'CVD', 'This is the CVD function', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -822 - CVD.'
END
ELSE
BEGIN
	PRINT 'Static data value -822 - CVD already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

-- inserting the static data value for the 'DailyRollingAveg'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -823)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-823, 800, 'DailyRollingAveg', 'This is the function that returns DailyRollingAveg', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -823 - DailyRollingAveg.'
END
ELSE
BEGIN
	PRINT 'Static data value -823 - DailyRollingAveg already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

-- inserting the static data value for the 'DealVolm'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -824)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-824, 800, 'DealVolm', 'This function returns the volume of deal(s) by summing all the term volumes of a contract month', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -824 - DealVolm.'
END
ELSE
BEGIN
	PRINT 'Static data value -824 - DealVolm already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

-- inserting the static data value for the 'DmdDateTime'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -825)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-825, 800, 'DmdDateTime', 'DmdDateTime', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -825 - DmdDateTime.'
END
ELSE
BEGIN
	PRINT 'Static data value -825 - DmdDateTime already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

-- inserting the static data value for the 'DPrice'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -826)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-826, 800, 'DPrice', 'This function returns the deal price as; (fixed price*price multiplier) + formula + adder 1 + adder2', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -826 - DPrice.'
END
ELSE
BEGIN
	PRINT 'Static data value -826 - DPrice already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

-- inserting the static data value for the 'DutchTOU'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -827)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-827, 800, 'DutchTOU', 'This function returns the time of use', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -827 - DutchTOU.'
END
ELSE
BEGIN
	PRINT 'Static data value -827 - DutchTOU already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

-- inserting the static data value for the 'EDRHeatInpt'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -828)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-828, 800, 'EDRHeatInpt', 'This function is used for calculations of EDR Heat Input', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -828 - EDRHeatInpt.'
END
ELSE
BEGIN
	PRINT 'Static data value -828 - EDRHeatInpt already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

-- inserting the static data value for the 'EDRValue'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -829)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-829, 800, 'EDRValue', 'This function is used to get value from EDR', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -829 - EDRValue.'
END
ELSE
BEGIN
	PRINT 'Static data value -829 - EDRValue already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

-- inserting the static data value for the 'EMSCoeff'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -830)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-830, 800, 'EMSCoeff', 'This function is used to find Emissions Coeffecient Factor. It takes following parameters(Input,Conversion type,source)', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -830 - EMSCoeff.'
END
ELSE
BEGIN
	PRINT 'Static data value -830 - EMSCoeff already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

-- inserting the static data value for the 'ImbalanceTotalVol'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -831)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-831, 800, 'ImbalanceTotalVol', 'This function returns the sum of total imbalances in a contract month.', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -831 - ImbalanceTotalVol.'
END
ELSE
BEGIN
	PRINT 'Static data value -831 - ImbalanceTotalVol already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

-- inserting the static data value for the 'IntCumulativeMnth'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -832)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-832, 800, 'IntCumulativeMnth', 'IntCumulativeMnth', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -832 - IntCumulativeMnth.'
END
ELSE
BEGIN
	PRINT 'Static data value -832 - IntCumulativeMnth already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

-- inserting the static data value for the 'IntEndMnth'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -833)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-833, 800, 'IntEndMnth', 'IntEndMnth', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -833 - IntEndMnth.'
END
ELSE
BEGIN
	PRINT 'Static data value -833 - IntEndMnth already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

-- inserting the static data value for the 'InterruptCalc'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -834)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-834, 800, 'InterruptCalc', 'InterruptCalc', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -834 - InterruptCalc.'
END
ELSE
BEGIN
	PRINT 'Static data value -834 - InterruptCalc already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

-- inserting the static data value for the 'IntStartMnth'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -835)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-835, 800, 'IntStartMnth', 'IntStartMnth', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -835 - IntStartMnth.'
END
ELSE
BEGIN
	PRINT 'Static data value -835 - IntStartMnth already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

-- inserting the static data value for the 'IsInterrupt'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -836)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-836, 800, 'IsInterrupt', 'IsInterrupt', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -836 - IsInterrupt.'
END
ELSE
BEGIN
	PRINT 'Static data value -836 - IsInterrupt already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

-- inserting the static data value for the 'IsSingleStackBoiler'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -837)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-837, 800, 'IsSingleStackBoiler', 'This function Check if this is a Single Stack Boiler or not', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -837 - IsSingleStackBoiler.'
END
ELSE
BEGIN
	PRINT 'Static data value -837 - IsSingleStackBoiler already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

-- inserting the static data value for the 'MnPrice'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -838)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-838, 800, 'MnPrice', 'This function returns the smallest price in a curve for given granularity.', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -838 - MnPrice.'
END
ELSE
BEGIN
	PRINT 'Static data value -838 - MnPrice already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

-- inserting the static data value for the 'NOXEmissionsValue'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -839)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-839, 800, 'NOXEmissionsValue', 'This function returns the SO2 Mass Emissions Value', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -839 - NOXEmissionsValue.'
END
ELSE
BEGIN
	PRINT 'Static data value -839 - NOXEmissionsValue already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

-- inserting the static data value for the 'Settlement'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -840)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-840, 800, 'Settlement', 'Settlement', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -840 - Settlement.'
END
ELSE
BEGIN
	PRINT 'Static data value -840 - Settlement already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

-- inserting the static data value for the 'SettlementDate'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -841)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-841, 800, 'SettlementDate', 'SettlementDate', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -841 - SettlementDate.'
END
ELSE
BEGIN
	PRINT 'Static data value -841 - SettlementDate already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

-- inserting the static data value for the 'SO2EmissionsValue'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -842)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-842, 800, 'SO2EmissionsValue', 'SO2EmissionsValue', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -842 - SO2EmissionsValue.'
END
ELSE
BEGIN
	PRINT 'Static data value -842 - SO2EmissionsValue already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

-- inserting the static data value for the 'FixedCurve'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -843)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-843, 800, 'FixedCurve', 'Functions FixedCurve', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -843 - FixedCurve.'
END
ELSE
BEGIN
	PRINT 'Static data value -843 - FixedCurve already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

-- inserting the static data value for the 'MxPrice'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -844)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-844, 800, 'MxPrice', 'This function returns the greatest price in a curve for given granularity.', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -844 - MxPrice.'
END
ELSE
BEGIN
	PRINT 'Static data value -844 - MxPrice already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

-- inserting the static data value for the 'PeakDmd'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -845)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-845, 800, 'PeakDmd', 'Function PeakDmd', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -834 - PeakDmd.'
END
ELSE
BEGIN
	PRINT 'Static data value -845 - PeakDmd already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

-- inserting the static data value for the 'PeakPeakDmndMeter'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -846)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-846, 800, 'PeakPeakDmndMeter', 'Function PeakPeakDmndMeter', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -846 - PeakPeakDmndMeter.'
END
ELSE
BEGIN
	PRINT 'Static data value -846 - PeakPeakDmndMeter already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

-- inserting the static data value for the 'AllocVolm'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -847)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-847, 800, 'AllocVolm', 'Function AllocVolm', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -847 - AllocVolm.'
END
ELSE
BEGIN
	PRINT 'Static data value -847 - AllocVolm already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


-- inserting the static data value for the 'FNACptMeterVolm'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -848)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-848, 800, 'FNACptMeterVolm', 'Function FNACptMeterVolm', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -848 - FNACptMeterVolm.'
END
ELSE
BEGIN
	PRINT 'Static data value -848 - FNACptMeterVolm already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

-- inserting the static data value for the 'DealFVolm'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -849)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-849, 800, 'DealFVolm', 'Function DealFVolm', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -849 - DealFVolm.'
END
ELSE
BEGIN
	PRINT 'Static data value -849 - DealFVolm already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

-- inserting the static data value for the 'StaticCurve'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -851)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-851, 800, 'StaticCurve', 'Function StaticCurve', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -851 - StaticCurve.'
END
ELSE
BEGIN
	PRINT 'Static data value -851 - StaticCurve already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


-- inserting the static data value for the 'DealNetPrice'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -852)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-852, 800, 'DealNetPrice', 'Function DealNetPrice', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -852 - DealNetPrice.'
END
ELSE
BEGIN
	PRINT 'Static data value -852 - DealNetPrice already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

-- inserting the static data value for the 'DealFloatPrice'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -853)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-853, 800, 'DealFloatPrice', 'Function DealFloatPrice', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -853 - DealFloatPrice.'
END
ELSE
BEGIN
	PRINT 'Static data value -853 - DealFloatPrice already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

-- inserting the static data value for the 'LocationGrid'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -854)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-854, 800, 'LocationGrid', 'Function LocationGrid', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -854 - LocationGrid.'
END
ELSE
BEGIN
	PRINT 'Static data value -854 - LocationGrid already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

-- inserting the static data value for the 'DynamicCurve'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -855)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-855, 800, 'DynamicCurve', 'Function DynamicCurve', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -855 - DynamicCurve.'
END
ELSE
BEGIN
	PRINT 'Static data value -855 - DynamicCurve already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

-- inserting the static data value for the 'DaysInMnth'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -856)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-856, 800, 'DaysInMnth', 'This function returns the number of days in month', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -856 - DaysInMnth.'
END
ELSE
BEGIN
	PRINT 'Static data value -856 - DaysInMnth already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

-- inserting the static data value for the 'PrevEvents'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -857)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-857, 800, 'PrevEvents', 'PrevEvents', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -857 - PrevEvents.'
END
ELSE
BEGIN
	PRINT 'Static data value -857 - PrevEvents already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -858)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-858, 800, 'EODHours', 'EODHours', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -858 - EODHours.'
END
ELSE
BEGIN
	PRINT 'Static data value -858 - EODHours already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -859)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-859, 800, 'RowSum', 'RowSum', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -859 - RowSum.'
END
ELSE
BEGIN
	PRINT 'Static data value -859 - RowSum already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO



SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -860)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-860, 800, 'RateScheduleFee', 'RateScheduleFee', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -860 - RateScheduleFee.'
END
ELSE
BEGIN
	PRINT 'Static data value -860 - RateScheduleFee already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -861)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-861, 800, 'RelativeCurveD', 'RelativeCurveD', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -861 - RelativeCurveD.'
END
ELSE
BEGIN
	PRINT 'Static data value -861 - RelativeCurveD already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

























