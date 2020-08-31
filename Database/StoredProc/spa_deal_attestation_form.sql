IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_deal_attestation_form]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_deal_attestation_form]
GO 

CREATE proc [dbo].[spa_deal_attestation_form]
	@flag char(1),
	@attestation_id int=NULL,
	@source_deal_detail_id int=null,
	@generator_id varchar(100)=null,
	@generator_name varchar(500)=null,
	@term_start datetime=null,
	@term_end datetime=null,
	@fuel_type_value_id int=null,
	@volume float=null,
	@generation_date datetime=null,
	@nox_emissions float=null,
	@so2_emissions float=null,
	@co2_emissions float=null,
	@generation_period varchar(100)=null,
	@remarks varchar(500)=null

AS
BEGIN
Declare @sqlstmt varchar(5000)

IF @flag='s'
BEGIN
set @sqlstmt='	select 
		attestation_id as [ID],
		generator_id as [Generator ID],
		generator_name as [Generator Name],
		dbo.fnadateformat(term_start) as [Term Start],
		dbo.fnadateformat(term_end) as [Term End],
		sd.code as [Fuel Type],
		Volume as Volume,
		dbo.fnadateformat(generation_date) [Generation Date],
		nox_emissions [NOx Emissions],
		so2_emissions [SO2 Emissions],
		co2_emissions [CO2 Emissions],
		generation_period [Generation Period]
	from
		deal_attestation_form da left join static_data_value sd
		on da.fuel_type_value_id=sd.value_id
	where
		source_deal_detail_id='+cast(@source_deal_detail_id as varchar)
	+case when @term_start is not null then ' AND dbo.fnagetcontractmonth(term_start)=dbo.fnagetcontractmonth('''+cast(@term_start as varchar)+''')' else '' end
exec(@sqlstmt)
END
ELSE IF @flag='a'
	select 
		attestation_id as [ID],
		generator_id as [Generator ID],
		generator_name as [Generator Name],
		dbo.fnadateformat(term_start) as [Term Start],
		dbo.fnadateformat(term_end) as [Term End],
		fuel_type_value_id,
		Volume as Volume,
		dbo.fnadateformat(generation_date) [Generation Date],
		nox_emissions [NOx Emissions],
		so2_emissions [SO2 Emissions],
		co2_emissions [CO2 Emissions],
		generation_period,
		remarks
	from
		deal_attestation_form da 
	where
		attestation_id=@attestation_id

ELSE IF @flag='i'
BEGIN
	insert into deal_attestation_form
		(
			--attestation_id,
			source_deal_detail_id,
			generator_id,
			generator_name,
			term_start,
			term_end,
			fuel_type_value_id,
			Volume,
			generation_date,
			nox_emissions,
			so2_emissions,
			co2_emissions,
			generation_period,
			remarks
		)
	select
			--@attestation_id,
			@source_deal_detail_id,
			@generator_id,
			@generator_name,
			@term_start,
			@term_end,
			@fuel_type_value_id,
			@Volume,
			@generation_date,
			@nox_emissions,
			@so2_emissions,
			@co2_emissions,
			@generation_period,
			@remarks
	
	If @@ERROR <> 0
				Exec spa_ErrorHandler @@ERROR, "Deal Attestation", 
						"spa_deal_attestation_form", "DB Error", 
					"Error on Inserting Deal Attestation.", ''
	else
				Exec spa_ErrorHandler 0, 'Deal Attestation', 
						'spa_deal_attestation_form', 'Success', 
						'Deal Attestation successfully inserted.',''

END	
ELSE IF @flag='u'
BEGIN
	update deal_attestation_form
		set
			
			generator_id=@generator_id,
			generator_name=@generator_name,
			term_start=@term_start,
			term_end=@term_end,
			fuel_type_value_id=@fuel_type_value_id,
			Volume=@volume,
			generation_date=@generation_date,
			nox_emissions=@nox_emissions,
			so2_emissions=@so2_emissions,
			co2_emissions=@co2_emissions,
			generation_period=@generation_period,
			remarks=@remarks

		where
			attestation_id=@attestation_id

	If @@ERROR <> 0
				Exec spa_ErrorHandler @@ERROR, "Deal Attestation", 
						"spa_deal_attestation_form", "DB Error", 
					"Error on Updating Deal Attestation.", ''
	else
				Exec spa_ErrorHandler 0, 'Deal Attestation', 
						'spa_deal_attestation_form', 'Success', 
						'Deal Attestation successfully updated.',''
END
			
ELSE IF @flag='d'
BEGIN
	DELETE from deal_attestation_form
		where 
			attestation_id=@attestation_id
If @@ERROR <> 0
				Exec spa_ErrorHandler @@ERROR, "Deal Attestation", 
						"spa_deal_attestation_form", "DB Error", 
					"Error on DEleting Deal Attestation.", ''
	else
				Exec spa_ErrorHandler 0, 'Deal Attestation', 
						'spa_deal_attestation_form', 'Success', 
						'Deal Attestation successfully deleted.',''

END
END	







