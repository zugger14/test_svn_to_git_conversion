IF OBJECT_ID(N'[dbo].[spa_ems_generator]', N'P') IS NOT NULL
   DROP PROCEDURE [dbo].[spa_ems_generator]
GO


CREATE PROCEDURE [dbo].[spa_ems_generator] 
@flag char(1),
@generator_id int=NULL
as
declare @url varchar(1000)
if @flag='a' 
begin
	SELECT r.generator_id, Name , esm.ems_source_model_id,esm.ems_source_model_name,input_frequency,forecast_input_frequency
	FROM rec_generator  r  
left join ems_source_model_effective esme on esme.generator_id=r.generator_id
	left join (select max(isnull(effective_date,'1900-01-01')) effective_date,generator_id from 
				ems_source_model_effective where 1=1 group by generator_id) ab
	on esme.generator_id=ab.generator_id and isnull(esme.effective_date,'1900-01-01')=ab.effective_date	
	left join ems_source_model esm on esme.ems_source_model_id=esm.ems_source_model_id
	where generator_type='e' and r.generator_id=@generator_id
END





