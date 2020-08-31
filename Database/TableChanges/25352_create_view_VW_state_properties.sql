IF OBJECT_ID('[dbo].[VW_state_properties]') IS NOT NULL
    DROP VIEW [dbo].[VW_state_properties]
GO
/**
	Data from state_properties, static_data_value and state_properties_details

	Columns
	state_value_id : Primary key of table state_properties
	code : Column of static_data_value
	description : Column of static_data_value
	region_id : Column of state_properties
	begin_date : Column of state_properties
	program_scope : Column of state_properties
	calendar_from_month : Column of state_properties
	calendar_to_month : Column of state_properties
	detail : Column of state_properties
	tier_id : Column of state_properties_details
	technology_id : Column of state_properties_details
	technology_subtype_id : Column of state_properties_details
	price_index : Column of state_properties_details
	effective_date : Column of state_properties_details
	banking_years : Column of state_properties_details
*/
CREATE VIEW [dbo].[VW_state_properties]
AS
   SELECT sp.state_value_id
		, sdv.code
		, sdv.description
		, sp.region_id
		, sp.begin_date
		, sp.program_scope
		, sp.calendar_from_month
		, sp.calendar_to_month
		, sp.detail
		, sp.current_next_year
		FROM static_data_value sdv
		INNER JOIN state_properties sp ON sp.state_value_id = sdv.value_id
GO