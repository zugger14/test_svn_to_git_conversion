UPDATE mfc
	SET mfc.is_active = 0
FROM static_data_value sdv
INNER JOIN map_function_category mfc
	ON mfc.function_id = sdv.value_id
WHERE sdv.TYPE_ID = 800
AND code IN
(
'DealFloatPrice' 
,'DPrice' 
,'AllocVolm' 
,'PrevEvents' 
,'DeriveDayAhead'  
,'GetGMContractFee' 
,'GetWACOGPoolPrice' 
,'Netback' 
,'On Peak H08-H16' 
,'StorageContractPrice' 
,'AnnualVolCOD' 
,'CRR Obligations' 
,'MDQ' 
,'MnthlyRollingAveg'  
,'UDFDetailValue' 
)
