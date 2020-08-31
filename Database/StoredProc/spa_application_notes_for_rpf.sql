IF OBJECT_ID('spa_application_notes_for_rpf', 'P') IS NOT NULL 
	DROP PROCEDURE [dbo].[spa_application_notes_for_rpf]
GO  

--exec spa_application_notes_for_rpf 'i', 'D:\FARRMS_APPLICATIONS\DEV\FASTracker_Master\fas2.1\adiha.php.scripts\dev\shared_docs\temp_note\TESTdoc_1193568755.txt'
--exec spa_application_notes_for_rpf 'i',687,'D:\FARRMS_APPLICATIONS\DEV\FASTracker_Master\fas2.1\adiha.php.scripts\dev\shared_docs\temp_note\TESTdoc_1193828559.jpg'
--exec spa_application_notes_for_rpf 'i',660,'D:\FARRMS_APPLICATIONS\DEV\FASTracker_Master\fas2.1\adiha.php.scripts\dev\shared_docs\temp_note\TESTdoc_1193911075.jpg'
CREATE procedure [dbo].[spa_application_notes_for_rpf]
@flag char(1),
@eff_test_profile_id int,
@hedge_doc_temp varchar(5000)=null


as
declare @filepath varchar(500)

if @flag = 'i'
begin
declare @st varchar(5000)
set @st='update fas_eff_hedge_rel_type
set hedge_doc_temp='''+isnull(@hedge_doc_temp,'')+'''
where eff_test_profile_id='+cast(@eff_test_profile_id as varchar)
exec(@st)
If @@ERROR <> 0
	begin
		Exec spa_ErrorHandler @@ERROR, "fas_link_header", 
				"spa_application_notes_for_rpf", "DB Error", 
				"Insert of application notes failed.", ''
		
	end
else
		Exec spa_ErrorHandler 0, 'Appliction Notes', 
				'spa_application_notes_for_rpf', 'Success', 
				'Application notess detail successfully selected.', ''

end
Else if @flag ='a' 
begin
SELECT 
hedge_doc_temp
FROM fas_eff_hedge_rel_type where eff_test_profile_id=@eff_test_profile_id
end
Else if @flag = 'd'
begin
declare @st1 varchar(5000)
set @st1='update fas_eff_hedge_rel_type
set hedge_doc_temp=NULL
where eff_test_profile_id='+cast(@eff_test_profile_id as varchar)
exec(@st1)
	If @@ERROR <> 0
	begin
		Exec spa_ErrorHandler @@ERROR, "Appliction Notes", 
				"spa_application_notes", "DB Error", 
				"Insert of application notes failed.", ''
		end
	

else
		Exec spa_ErrorHandler 0, 'Appliction Notes', 
				'spa_application_notes', 'Success', 
				'Application notess detail successfully selected.', ''


END 















