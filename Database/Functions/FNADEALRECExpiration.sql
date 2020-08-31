IF OBJECT_ID(N'FNADEALRECExpiration', N'FN') IS NOT NULL
DROP FUNCTION [dbo].[FNADEALRECExpiration]
GO

--SELECT DBO.FNADEALRECExpiration(1285, '2004-2-28', 5146)
--SELECT DBO.FNADEALRECExpiration(54150, '2004-2-28', NULL)
--SELECT DBO.FNADEALRECExpiration(1284, '2004-2-28', 5146)
--SELECT DBO.FNADEALRECExpiration(53935, '2004-2-28', NULL)

-- This function returns expiration date for REC deals based on duration in  years
-- Inpute is duration in years and REC generation date

CREATE FUNCTION [dbo].[FNADEALRECExpiration]
(
	@source_deal_header_id  INT,
	@expiration_date        DATETIME,
	@assignment_type        INT
)
RETURNS VARCHAR(50)
AS
BEGIN

	Return dbo.FNADEALRECExpirationState(@source_deal_header_id, @expiration_date, @assignment_type, NULL)

-- 	DECLARE @deal_type int
-- 	DECLARE @deal_type1 int
-- 	Declare @FNADEALRECExpiration Varchar(50)
-- 	
-- 	select 	@deal_type = sdht.internal_deal_type_value_id,
-- 		@deal_type1 = sdh.source_deal_type_id
-- 	from source_deal_header sdh left outer join
-- 		source_deal_header_template sdht on sdht.template_id = sdh.template_id
-- 	where sdh.source_deal_header_id = @source_deal_header_id
-- 
-- 
-- 	If ISNULL(@deal_type, -1) <> 4 AND ISNULL(@deal_type1, -1) NOT IN (53, 55) 
-- 	begin
-- 		set @FNADEALRECExpiration = dbo.FNADateFormat(@expiration_date)
-- 		RETURN(@FNADEALRECExpiration)	
-- 	end
-- 
--  
-- 	 select  @FNADEALRECExpiration  = 
-- 		CASE WHEN (@assignment_type IS NULL AND 
-- 				drp.assignment_type_value_id IS NOT NULL AND 
-- 				drp.compliance_year IS NOT NULL) THEN
-- 			dbo.FNADateFormat(dbo.FNALastDayInDate(cast(sp.calendar_to_month as varchar) + '/01/' + cast(drp.compliance_year as varchar)))
-- --			'12/31/' + cast(drp.compliance_year as varchar)
-- 		ELSE
-- 			
-- 			case when (isnull(spd.banking_period_frequency, isnull(sp.banking_period_frequency, 706)) = 703) then 
-- 				dbo.FNADateFormat(dbo.FNALastDayInDate(  
-- 					dateadd(mm, 
-- 						case when(rg.gen_offset_technology = 'n') then 
-- 							isnull(spd.duration ,isnull(sp.duration, 0)) 
-- 						else isnull(spd.offset_duration ,isnull(sp.offset_duration, 0)) end,
-- 						sdd.term_start)
-- 					))
-- 
-- 			else 	--default is yearly
-- 				dbo.FNADateFormat(dbo.FNALastDayInDate(   
-- 						cast((year(sdd.term_start) + 
-- 						case when(rg.gen_offset_technology = 'n') then 
-- 							isnull(spd.duration ,isnull(sp.duration, 0)) 
-- 						else isnull(spd.offset_duration ,isnull(sp.offset_duration, 0)) end 
-- 						- 1) as varchar) 
-- 						+ '-' + cast(sp.calendar_to_month as varchar) + '-01'
-- 					))
-- 
-- 			end
-- 
-- 		END
-- 
-- 	 from 	 source_deal_detail sdd left outer join
-- 		 deal_rec_properties drp on drp.source_deal_header_id = sdd.source_deal_header_id left outer join
-- 		 rec_generator rg on rg.generator_id = drp.generator_id left outer join
-- 
-- 	  	 state_properties sp on sp.state_value_id = isnull(drp.state_value_id, rg.state_value_id) 
-- 
-- 		 left outer join
-- 		 state_properties_duration spd on spd.state_value_id = sp.state_value_id and
-- 						  spd.technology = rg.technology and
-- 						  isnull(spd.assignment_type_Value_id, -1) = isnull(@assignment_type, -1)
-- 
-- 	where   sdd.source_deal_header_id = @source_deal_header_id
-- 
-- 	RETURN(@FNADEALRECExpiration)
END

































