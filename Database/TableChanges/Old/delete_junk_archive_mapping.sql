DELETE ptl
--SELECT ptl.*
FROM process_table_location ptl
OUTER APPLY (SELECT ptl_arch1.pnl_as_of_date 
             FROM source_deal_pnl_arch1 ptl_arch1 
             WHERE ptl_arch1.pnl_as_of_date = ptl.as_of_date 
             GROUP BY ptl_arch1.pnl_as_of_date) arch1
OUTER APPLY (SELECT ptl_arch2.pnl_as_of_date 
             FROM source_deal_pnl_arch1 ptl_arch2 
             WHERE ptl_arch2.pnl_as_of_date = ptl.as_of_date 
             GROUP BY ptl_arch2.pnl_as_of_date) arch2
WHERE arch1.pnl_as_of_date IS NULL AND arch2.pnl_as_of_date IS NULL
	AND  tbl_name = 'source_deal_pnl'