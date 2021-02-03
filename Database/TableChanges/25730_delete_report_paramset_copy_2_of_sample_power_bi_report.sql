DELETE rp 
FROM report_param rp 
	INNER JOIN  report_dataset_paramset rdp ON rdp.report_dataset_paramset_id = rp.dataset_paramset_id
	INNER JOIN report_paramset rps ON rdp.paramset_id = rps.report_paramset_id
WHERE rps.name ='Copy 2 of Sample Power BI Report'

DELETE rdp 
FROM report_dataset_paramset rdp 
	INNER JOIN report_paramset rps ON rps.report_paramset_id = rdp.paramset_id
WHERE rps.name ='Copy 2 of Sample Power BI Report'
		
DELETE rps 
FROM report_paramset rps
WHERE rps.name ='Copy 2 of Sample Power BI Report'