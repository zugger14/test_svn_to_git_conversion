/*
* Delete unused user defined functions from static data value.
*/

--PeakDemand15MinsMeter
DELETE FROM static_data_value  WHERE value_id = 856 AND code = 'PeakDemand15MinsMeter'

--TotSumMthRo
DELETE FROM static_data_value  WHERE value_id = 878 AND code = 'TotSumMthRo'

--PriceMultiplier
DELETE FROM static_data_value  WHERE value_id = 869 AND code = 'PriceMultiplier'

--PriceAdder
DELETE FROM static_data_value  WHERE value_id = 868 AND code = 'PriceAdder'

--6MinsBlockAvg
DELETE FROM static_data_value  WHERE value_id = 888 AND code = '6MinsBlockAvg'

--Rprice
DELETE FROM static_data_value  WHERE value_id = 841 AND code = 'Rprice'

--GranularityMnth
DELETE FROM static_data_value  WHERE value_id = 840 AND code = 'GranularityMnth'

--TotalMxHour
DELETE FROM static_data_value  WHERE value_id = 831 AND code = 'TotalMxHour'

--TotalPeriodHour
DELETE FROM static_data_value  WHERE value_id = 830 AND code = 'TotalPeriodHour'

--OffPeakMxHour
DELETE FROM static_data_value WHERE value_id = 827 AND code = 'OffPeakMxHour'

--OffPeakPeriodHour
DELETE FROM static_data_value  WHERE value_id = 825 AND code = 'OffPeakPeriodHour'
 
--OnPeakPeriodHour
DELETE FROM static_data_value  WHERE value_id = 824 AND code = 'OnPeakPeriodHour' 

--RollingAVG
DELETE FROM static_data_value  WHERE value_id = 821 AND code = 'RollingAVG'

--SumVolume
DELETE FROM static_data_value  WHERE value_id = 814 AND code = 'SumVolume'

--24HrsAvg
DELETE FROM static_data_value  WHERE value_id = -808 AND code = '24HrsAvg'

--3Hrs2Samples
DELETE FROM static_data_value  WHERE value_id = -809 AND code = '3Hrs2Samples'

--BilateralVolm
DELETE FROM static_data_value  WHERE value_id = 867 AND code = 'BilateralVolm'

--Settlement
DELETE FROM static_data_value  WHERE value_id = -840 AND code = 'Settlement'

--DateTimeDemand15Mins
DELETE FROM static_data_value  WHERE value_id = 855 AND code = 'DateTimeDemand15Mins'

--15MinInterrupt 
DELETE FROM static_data_value  WHERE value_id = 849 AND code = '15MinInterrupt'

--PeakDemand60Mins  
DELETE FROM static_data_value  WHERE value_id = 846 AND code = 'PeakDemand60Mins'

--PeakDemand30Mins   
DELETE FROM static_data_value  WHERE value_id = 845 AND code = 'PeakDemand30Mins'

--PeakDemand15Mins   
DELETE FROM static_data_value  WHERE value_id = 844 AND code = 'PeakDemand15Mins'

--IntEndMnth    
DELETE FROM static_data_value  WHERE value_id = -833 AND code = 'IntEndMnth'

--SourceInput
DELETE FROM static_data_value  WHERE value_id = 882 AND code = 'SourceInput'

--RowSum
DELETE FROM static_data_value  WHERE value_id = -859 AND code = 'RowSum'

--Price
DELETE FROM static_data_value  WHERE value_id = 837 AND code = 'Price'