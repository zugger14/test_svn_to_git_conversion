

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--drop proc spa_edr_file_import_prototype
--go

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_edr_file_map]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_edr_file_map]
GO 

CREATE proc [dbo].[spa_edr_file_map]
	@flag char(1)='s'
as

if @flag='a' -- to display in Combo Box
begin
	select record_type_code [Code],record_type_desc [Desc]
	from edr_file_map
end
else
begin
	select edr_file_map.record_type_code,date_start_position,date_length,hr_start_position,hr_length,curve_id,
	sno,sub_type_id,start_position,data_length,uom_id,uom_id1 
	from edr_file_map inner join edr_file_map_detail 
	on edr_file_map.record_type_code=edr_file_map_detail.record_type_code 
	order by edr_file_map_detail.record_type_code,sno

end




