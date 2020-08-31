IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_ems_demand_side_mgmt]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_ems_demand_side_mgmt]
GO 

CREATE PROCEDURE [dbo].[spa_ems_demand_side_mgmt]
@flag char(1),
@dsm_id int,
@program_name varchar(50),
@city varchar(50),
@state varchar(50),
@country varchar(50),
@date datetime,
@description varchar(5000),
@info_tec_assistance char(1),
@financial_incentives char(1),
@investment char(1),
@non_commercial_serv char (1),
@residential char (1),
@small_industrial char(1),
@commercial char(1),
@other char(1),
@program_evaluation varchar(5000),
@p_name varchar(50),
@p_qualification varchar(50),
@energy_unit varchar(50),
@energy_quality float,
@gas_reduction char(50),
@yes char(1),
@no char(1)
as

							if @flag='s'
							begin

							select 
							dsm_id,
							program_name,
							city,
							state,
							country ,
							date ,
							description ,
							info_tec_assistance ,
							financial_incentives ,
							investment ,
							non_commercial_serv ,
							residential ,
							small_industrial ,
							commercial ,
							other ,
							program_evaluation ,
							p_name ,
							p_qualification ,
							energy_unit ,
							energy_quality ,
							gas_reduction ,
							yes ,
							no 
							 from ems_demand_side_mgmt
							end

else if @flag='i'
begin
	insert into ems_demand_side_mgmt ( 
										dsm_id ,
										program_name ,
										city ,
										state ,
										country ,
										date ,
										description ,
										info_tec_assistance ,
										financial_incentives ,
										investment ,
										non_commercial_serv ,
										residential ,
										small_industrial ,
										commercial ,
										other,
										program_evaluation ,
										p_name ,
										p_qualification ,
										energy_unit ,
										energy_quality ,
										gas_reduction ,
										yes ,
										no  )
	 

	values (
				@dsm_id ,
				@program_name ,
				@city ,
				@state,
				@country ,
				@date ,
				@description ,
				@info_tec_assistance ,
				@financial_incentives ,
				@investment ,
				@non_commercial_serv ,
				@residential ,
				@small_industrial ,
				@commercial ,
				@other ,
				@program_evaluation,
				@p_name,
				@p_qualification ,
				@energy_unit,
				@energy_quality ,
				@gas_reduction,
				@yes ,
				@no  )

end

						else if @flag='u'
						begin
							update ems_demand_side_mgmt 
							set			
										dsm_id= @dsm_id,
										program_name=@program_name ,
										city=@city ,
										state=@state,
										country =@country ,
										date=@date ,
										description=@description ,
										info_tec_assistance =@info_tec_assistance ,
										financial_incentives=@financial_incentives ,
										investment= @investment ,
										non_commercial_serv=@non_commercial_serv ,
										residential=@residential ,
										small_industrial=@small_industrial ,
										commercial =@commercial ,
										other=@other ,
										program_evaluation=@program_evaluation,
										p_name=@p_name,
										p_qualification= @p_qualification ,
										energy_unit=@energy_unit,
										energy_quality=@energy_quality ,
										gas_reduction=@gas_reduction,
										yes=@yes ,
										no=@no
where dsm_id=@dsm_id

						end

else if @flag='d'
begin
	delete from ems_demand_side_mgmt 
	where dsm_id=@dsm_id
end





