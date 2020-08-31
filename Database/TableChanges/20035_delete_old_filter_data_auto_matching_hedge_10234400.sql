SELECT  auf.application_ui_filter_id
INTO #filter_ids
FROM application_ui_filter auf 
OUTER APPLY (SELECT application_ui_filter_id, MAX(layout_grid_id) layout_grid_id from application_ui_filter_details 
             WHERE application_ui_filter_id = auf.application_ui_filter_id GROUP BY  application_ui_filter_id) rs_outer
WHERE auf.application_function_id = 10234400 AND rs_outer.layout_grid_id IS  NULL


DELETE aufd
FROM #filter_ids tmp
INNER JOIN application_ui_filter_details aufd ON aufd.application_ui_filter_id = tmp.application_ui_filter_id

DELETE auf
FROM #filter_ids tmp
INNER JOIN application_ui_filter auf ON auf.application_ui_filter_id = tmp.application_ui_filter_id