IF not EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[dedesignation_criteria]') AND name = N'indx_dedesignation_criteria1')
begin
	create clustered index indx_dedesignation_criteria1 on dbo.dedesignation_criteria (dedesignation_criteria_id)
	create  index indx_dedesignation_criteria2 on dbo.dedesignation_criteria (fas_sub_id)
	create  index indx_dedesignation_criteria3 on dbo.dedesignation_criteria (fas_stra_id)
	create  index indx_dedesignation_criteria4 on dbo.dedesignation_criteria (fas_book_id)
	create  index indx_dedesignation_criteria5 on dbo.dedesignation_criteria (run_date)
	create clustered index indx_dedesignation_criteria_result1 on dbo.dedesignation_criteria_result (dedesignation_criteria_id,link_id)
end