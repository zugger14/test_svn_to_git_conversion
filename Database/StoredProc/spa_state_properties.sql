IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_state_properties]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_state_properties]
GO 
CREATE PROCEDURE [dbo].[spa_state_properties]
	@flag							CHAR(1) = NULL,
	@state_value_id					INT = NULL,
	@duration						INT = NULL,
	@begin_date						DATETIME = NULL,
	@settlement_period				INT = NULL,
	@offset_trade					VARCHAR(1) = NULL,
	@offset_duration				INT = NULL,
	@calendar_from_month			INT = NULL,
	@calendar_to_month				INT = NULL,
	@can_sell_before_certified		VARCHAR(1) = NULL,
	@sale_months_generation			INT = NULL,
	@resale_rec						VARCHAR(1) = NULL,
	@bank_assignment_required		VARCHAR(1) = NULL,
	@banking_period_frequency		INT = NULL,
	@qualifies_for_CO2_offsets		CHAR(1) = NULL,
	@can_unbundle_green_attributes	CHAR(1) = NULL,
	@CO2_offset_conv_factor			FLOAT = NULL

AS
SET NOCOUNT ON

if @flag='s'
begin
	SELECT    state_value_id, duration, dbo.FNADateFormat(begin_date)  begin_date, settlement_period, offset_trade, offset_duration, calendar_from_month, calendar_to_month, 
                      can_sell_before_certified, sale_months_generation, resale_rec, bank_assignment_required,banking_period_frequency 
	FROM       state_properties
end
if @flag='a'
begin
	SELECT    state_value_id, duration,dbo.FNADateFormat(begin_date)  begin_date, settlement_period, v.code, offset_trade, offset_duration, calendar_from_month, calendar_to_month, 
                      can_sell_before_certified, sale_months_generation, resale_rec, bank_assignment_required,banking_period_frequency,
	qualifies_for_CO2_offsets,can_unbundle_green_attributes,CO2_offset_conv_factor
	FROM       state_properties s join static_data_value v on s.state_value_id=v.value_id
	where state_value_id=@state_value_id
end
if @flag='i'
begin
	insert state_properties(
		state_value_id,	
		duration,	
		begin_date,	
		settlement_period,
		 offset_trade,
		 offset_duration, 
		 calendar_from_month,
		 calendar_to_month, 
                            can_sell_before_certified,
	               sale_months_generation,
	              resale_rec,
                           bank_assignment_required,
		banking_period_frequency,
		qualifies_for_CO2_offsets,
		can_unbundle_green_attributes,
		CO2_offset_conv_factor 
	)
	values(
		@state_value_id,
		@duration,
		@begin_date,
		@settlement_period,
		@offset_trade,
		 @offset_duration,
		@calendar_from_month,
		@calendar_to_month,
		@can_sell_before_certified,
		@sale_months_generation,
		@resale_rec,
		@bank_assignment_required,
		@banking_period_frequency,
		@qualifies_for_CO2_offsets,
		@can_unbundle_green_attributes,
		@CO2_offset_conv_factor 
	)

		If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "State Properties", 
				"spa_state_properties", "DB Error", 
			"Error on Inserting State Properties.", ''
	else
		Exec spa_ErrorHandler 0, 'State Properties', 
				'spa_state_properties', 'Success', 
				'State Properties successfully inserted.', ''
end
if @flag='u'
begin
	update state_properties
		set duration=@duration,
		begin_date=@begin_date,
		settlement_period=@settlement_period,
		offset_trade=@offset_trade,
		 offset_duration=@offset_duration,
		calendar_from_month=@calendar_from_month,
		 calendar_to_month=@calendar_to_month,
                  	 can_sell_before_certified=@can_sell_before_certified,
		 sale_months_generation=@sale_months_generation,
		 resale_rec=@resale_rec,
		 bank_assignment_required=@bank_assignment_required,
		banking_period_frequency =@banking_period_frequency, 
		qualifies_for_CO2_offsets=@qualifies_for_CO2_offsets,
		can_unbundle_green_attributes=@can_unbundle_green_attributes,
		CO2_offset_conv_factor=@CO2_offset_conv_factor
	where state_value_id=@state_value_id

	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "State Properties", 
				"spa_state_properties", "DB Error", 
			"Error on Updating State Properties.", ''
	else
		Exec spa_ErrorHandler 0, 'State Properties', 
				'spa_state_properties', 'Success', 
				'State Properties successfully Updated.', ''
end
if @flag='d'
begin
	delete state_properties
	where state_value_id=@state_value_id
end


-- loads dependent combo Tier
ELSE IF @flag = 't' --## To load depenedent combo Tier in Certificate Detail UI
BEGIN
	DECLARE @user_name VARCHAR(100) = dbo.FNADBUser()
	DECLARE @is_app_admin INT = dbo.FNAAppAdminRoleCheck(@user_name)
	
	IF OBJECT_ID('tempdb..#temp_dependen_load') IS NOT NULL
	DROP TABLE #temp_dependen_load		

	create table #temp_dependen_load
	(value_id int, code varchar(1000), state varchar(1000))
	
	INSERT INTO #temp_dependen_load
	SELECT DISTINCT sdv.value_id, sdv.code, 
	CASE WHEN ISNULL(is_enable, 1) = 1 THEN 'enable'
	WHEN sdad.is_active = 1 AND ISNULL(max(is_enable), 1) = 0 
	AND @is_app_admin = 0 THEN 'disable' 
	ELSE 'enable' END [state] 
	FROM static_data_value sdv
	LEFT JOIN static_data_privilege sdp
		ON sdv.value_id = sdp.value_id
	LEFT JOIN application_security_role asr
		ON sdp.role_id = asr.role_id
	LEFT JOIN application_role_user aru
		ON aru.role_id = asr.role_id
	LEFT JOIN state_properties_details spd
		ON spd.tier_id = sdv.value_id
			AND sdv.type_id = 15000	
	LEFT JOIN static_data_active_deactive sdad on sdad.type_id = sdv.type_id
	WHERE sdv.type_id = 15000 AND
		 spd.state_value_id = @state_value_id
		AND (@user_name = sdp.user_id 
			OR @is_app_admin = 1 
			OR sdp.role_id IN (SELECT role_id FROM dbo.FNAGetUserRole(@user_name))
			OR ISNULL(sdad.is_active, 0) = 0
			)
		GROUP BY sdv.value_id, sdv.code, sdad.is_active, is_enable	

		select value_id, code, min(state) state from  #temp_dependen_load Group by value_id, code

END


