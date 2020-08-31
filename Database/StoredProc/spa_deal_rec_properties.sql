IF OBJECT_ID(N'[dbo].[spa_deal_rec_properties]', N'P') IS NOT NULL
   DROP PROCEDURE [dbo].[spa_deal_rec_properties]
GO




-- exec spa_deal_rec_properties 'a', 57027
-- exec spa_deal_rec_properties 'u', 57027

CREATE PROCEDURE [dbo].[spa_deal_rec_properties]
	@flag char(1),
	@source_deal_header_id int =null,
	@generator_id int=null,
	@gis_cert_number varchar(250)=null,
	@gis_value_id int=null,
	@gis_cert_date datetime=null,
	@gen_cert_number varchar(250)=null,
	@gen_cert_date datetime=null,
	@status_value_id int=null,
	@status_date datetime=null,
	@assignment_type_value_id int=null,
	@compliance_year int=null, 
	@state_value_id int=null,
	@assigned_date datetime=null,
	@assigned_by varchar(50)=null,
	@generation_source varchar(250)=NULL,
	@aggregate_environment char(1)='n',
	@aggregate_envrionment_comment varchar(250)=NULL,
	@rec_price float= null,
	@rec_formula_id int=null
AS
if @flag='s'
begin
       SELECT 	source_deal_header_id, generator_id, gis_cert_number, gis_value_id, dbo.FNADateFormat(gis_cert_date) gis_cert_date, gen_cert_number, 
		dbo.FNADateFormat(gen_cert_date) gen_cert_date, status_value_id, dbo.FNADateFormat(status_date) status_date, assignment_type_value_id, 
		compliance_year, state_value_id, dbo.FNADateFormat(assigned_date) assigned_date, assigned_by
	FROM   deal_rec_properties
END
if @flag='a'
begin  
SELECT 	drp.source_deal_header_id, drp.generator_id, gis_cert_number, drp.gis_value_id, 
	dbo.FNADateFormat(gis_cert_date) gis_cert_date, gen_cert_number,  
		dbo.FNADateFormat(gen_cert_date) gen_cert_date, status_value_id, dbo.FNADateFormat(status_date) status_date,
		assignment_type_value_id, compliance_year, drp.state_value_id,  dbo.FNADateFormat(assigned_date) assigned_date ,
		 assigned_by,generation_source ,
		isnull(drp.aggregate_environment, rg.aggregate_environment) aggregate_environment,
		isnull(drp.aggregate_envrionment_comment, rg.aggregate_envrionment_comment) aggregate_envrionment_comment,
	drp.create_user,drp.create_ts,drp.update_user,drp.update_ts,
	dbo.FNAGetAssignmentDesc(5147) AssignmentDesc1, 
	dbo.FNADEALRECExpiration(drp.source_deal_header_id, '2005-01-01', 5147) DEALRECExpiration1,
	dbo.FNAGetAssignmentDesc(5146) AssignmentDesc2, 
	dbo.FNADEALRECExpiration(drp.source_deal_header_id, '2005-01-01', 5146) DEALRECExpiration2,
	case 	when (sdh.source_deal_type_id <> 55) then NULL
		when (drp.rec_price is null and drp.rec_formula_id is null) then rg.rec_price 
		else drp.rec_price end rec_price,
	case 	when (sdh.source_deal_type_id <> 55) then NULL
		when (drp.rec_price is null and drp.rec_formula_id is null) then rg.rec_formula_id 
		else drp.rec_formula_id end rec_formula_id,
	dbo.FNAFormulaFormat(f.formula, 'r') formula,
	ts.deal_volume block_volume

	from    source_deal_header sdh inner join
		deal_rec_properties drp ON drp.source_deal_header_id = sdh.source_deal_header_id 
		LEFT OUTER JOIN rec_generator rg on drp.generator_id = rg.generator_id
		LEFT OUTER JOIN formula_editor f on 
		case 	when (sdh.source_deal_type_id <> 55) then NULL
			when (drp.rec_price is null and drp.rec_formula_id is null) then rg.rec_formula_id 
			else drp.rec_formula_id end = f.formula_id
		LEFT OUTER JOIN (SELECT     source_deal_header_id, deal_volume
				FROM         Transaction_staging
				WHERE     (source_deal_header_id = @source_deal_header_id)) ts ON
			drp.source_deal_header_id = ts.source_deal_header_id
	 where drp.source_deal_header_id=@source_deal_header_id
END
if @flag='i'
begin
	INSERT  deal_rec_properties(
			source_deal_header_id, 
			generator_id, 
			gis_cert_number, 
			gis_value_id, 
			gis_cert_date, 
			gen_cert_number, 
			gen_cert_date, 
			status_value_id, 
			status_date,
			assignment_type_value_id, 
			compliance_year, 
			state_value_id, 
			assigned_date, 
			assigned_by,
			generation_source,
			aggregate_environment,
			aggregate_envrionment_comment,
			rec_price,
			rec_formula_id
			)
			
		VALUES(
			@source_deal_header_id,
			@generator_id,
			@gis_cert_number,
			@gis_value_id,
			@gis_cert_date,
			@gen_cert_number,
			@gen_cert_date,
			@status_value_id,
			@status_date,
			@assignment_type_value_id,
			@compliance_year, 
			@state_value_id,
			@assigned_date,
			@assigned_by,
			@generation_source,
			@aggregate_environment,
			@aggregate_envrionment_comment,
			@rec_price,
			@rec_formula_id)
			
SET @source_deal_header_id= SCOPE_IDENTITY() 
		If @@ERROR <> 0
				Exec spa_ErrorHandler @@ERROR, "Source deal header", 
						"spa_deal_rec_properties", "DB Error", 
					"Error on Inserting Source deal header.", ''
			else
				Exec spa_ErrorHandler 0, 'Source deal header', 
						'spa_deal_rec_properties', 'Success', 
						'Source deal header successfully inserted.', @source_deal_header_id
END

if @flag='u'
begin


-- DECLARE @ref_id varchar(50)
-- set @ref_id = NULL
-- 
-- set @ref_id = dbo.FNARECUpdateAll(@source_deal_header_id)

-- select  @ref_id
-- return
--set @ref_id = NULL
-- 
-- if @ref_id IS NULL
	UPDATE deal_rec_properties
		   set 	generator_id=@generator_id, 
			gis_cert_number=@gis_cert_number, 
			gis_value_id=@gis_value_id, 
			gis_cert_date=@gis_cert_date, 
			gen_cert_number=@gen_cert_number, 
			gen_cert_date=@gen_cert_date, 
			status_value_id=@status_value_id, 
			status_date=@status_date,
			assignment_type_value_id=@assignment_type_value_id, 
			compliance_year=@compliance_year, 
			state_value_id=@state_value_id, 
			assigned_date=@assigned_date, 
			assigned_by=@assigned_by,
			generation_source=@generation_source,
			aggregate_environment=@aggregate_environment,
			aggregate_envrionment_comment=@aggregate_envrionment_comment,
			rec_price=@rec_price,
			rec_formula_id=@rec_formula_id
			where source_deal_header_id = @source_deal_header_id 
-- else
-- 	UPDATE deal_rec_properties
-- 		   set 	generator_id=@generator_id, 
-- 			gis_cert_number=@gis_cert_number, 
-- 			gis_value_id=@gis_value_id, 
-- 			gis_cert_date=@gis_cert_date, 
-- 			gen_cert_number=@gen_cert_number, 
-- 			gen_cert_date=@gen_cert_date, 
-- 			status_value_id=@status_value_id, 
-- 			status_date=@status_date,
-- 			assignment_type_value_id=@assignment_type_value_id, 
-- 			compliance_year=@compliance_year, 
-- 			state_value_id=@state_value_id, 
-- 			assigned_date=@assigned_date, 
-- 			assigned_by=@assigned_by,
-- 			generation_source=@generation_source,
-- 			aggregate_environment=@aggregate_environment,
-- 			aggregate_envrionment_comment=@aggregate_envrionment_comment,
-- 			rec_price=@rec_price,
-- 			rec_formula_id=@rec_formula_id
-- 			where source_deal_header_id IN 
-- 				(SELECT source_deal_header_id from source_deal_header where structured_deal_id = @ref_id) 

	
		If @@ERROR <> 0
				Exec spa_ErrorHandler @@ERROR, "Source deal header", 
						"spa_deal_rec_properties", "DB Error", 
					"Error on updating Source deal header.", ''
				Exec spa_ErrorHandler 0, 'Source deal header', 
						'spa_deal_rec_properties', 'Success', 
						'Source deal header successfully updated.', ''
end
if @flag='d'
begin
	delete deal_rec_properties
	where source_deal_header_id=@source_deal_header_id
	If @@ERROR <> 0
				Exec spa_ErrorHandler @@ERROR, "Source deal header", 
						"spa_deal_rec_properties", "DB Error", 
					"Error on deleting Source deal header.", ''
	else
				Exec spa_ErrorHandler 0, 'Source deal header', 
						'spa_deal_rec_properties', 'Success', 
						'Source deal header deleted successfully.',''
end











