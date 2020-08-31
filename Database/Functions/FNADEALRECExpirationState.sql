/****** Object:  UserDefinedFunction [dbo].[FNADEALRECExpirationState]    Script Date: 11/12/2009 01:33:57 ******/
IF EXISTS (
		SELECT * FROM sys.objects
		WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[FNADEALRECExpirationState]')
		AND TYPE IN (N'FN', N'IF', N'TF', N'FS', N'FT')
) DROP FUNCTION [dbo].[FNADEALRECExpirationState]
/****** Object:  UserDefinedFunction [dbo].[FNADEALRECExpirationState]    Script Date: 11/12/2009 01:34:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
 
--SELECT DBO.FNADEALRECExpirationState(1285, '2004-2-28', 5146, 5118)
--SELECT DBO.FNADEALRECExpirationState(54150, '2004-2-28', NULL, 5118)
--SELECT DBO.FNADEALRECExpirationState(1284, '2004-2-28', 5146)
-- SELECT DBO.FNADEALRECExpirationState(28,'2008-05-01', NULL,291156)

-- select dbo.FNADEALRECExpirationState(1283, '10/31/2006',2 null, 5118)
-- 
-- -- This function returns expiration date for REC deals based on duration in  years
-- -- Inpute is duration in years and REC generation date
-- 
CREATE FUNCTION [dbo].[FNADEALRECExpirationState]
(
	@source_deal_header_id  INT,
	@expiration_date        DATETIME,
	@assignment_type        INT,
	@state_id               INT
)
RETURNS VARCHAR(50)
AS
BEGIN
	-- DECLARE @source_deal_header_id int, @expiration_date datetime, @assignment_type int,@state_id int
	-- set @source_deal_header_id = 53935
	-- set @expiration_date = '02/01/2004'
	-- set @assignment_type = null
	-- set @state_id = 5124
	
	DECLARE @deal_type                  INT
	DECLARE @deal_type1                 INT
	DECLARE @buy_sell_flag              VARCHAR(1)
	DECLARE @deal_date                  DATETIME
	DECLARE @FNADEALRECExpirationState  VARCHAR(50)
	DECLARE @generator_id               INT
	DECLARE @expiration_applies         VARCHAR(1)
	
	SELECT @deal_type = sdht.internal_deal_type_value_id,
	       @deal_type1 = sdh.source_deal_type_id,
	       @buy_sell_flag = sdd.buy_sell_flag,
	       @deal_date = sdh.deal_date,
	       @generator_id = sdh.generator_id,
	       @expiration_applies = ISNULL(sdt.expiration_applies, 'n')
	FROM   source_deal_header sdh
	       INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	       LEFT OUTER JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id
	       LEFT OUTER JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id
	WHERE  sdd.source_deal_header_id = @source_deal_header_id
	
	
	IF @expiration_applies = 'n' OR @generator_id IS NULL --or (ISNULL(@deal_type, -1) <> 4 AND ISNULL(@deal_type1, -1) NOT IN (53, 55))
	BEGIN
	    SET @FNADEALRECExpirationState = dbo.FNADateFormat(@expiration_date)
	    RETURN(@FNADEALRECExpirationState)
	END
	
	SELECT @FNADEALRECExpirationState = CASE 
	                                         WHEN spd.cert_entity = 3500 THEN --- Green-E Expiration logic
	                                              CASE 
	                                                   WHEN MONTH(sdd.term_start) BETWEEN 1 AND 6 THEN 
	                                                        dbo.FNADateFormat(
	                                                            dbo.FNALastDayInDate(CAST(YEAR(sdd.term_start) + 1 AS VARCHAR) + '-03-01')
	                                                        )
	                                                   ELSE dbo.FNADateFormat(
	                                                            dbo.FNALastDayInDate(CAST(YEAR(sdd.term_start) + 2 AS VARCHAR) + '-03-01')
	                                                        )
	                                              END
	                                         ELSE CASE 
	                                                   WHEN (
	                                                            --@assignment_type IS NULL AND  --commented and added 's' logic on 06/05/06.  
	                                                            @buy_sell_flag =  's' OR ( sdh.assignment_type_value_id IS NOT  NULL AND sdh.compliance_year IS NOT NULL )
	                                                        ) THEN dbo.FNADateFormat(
	                                                            dbo.FNALastDayInDate(
	                                                                CAST(ISNULL(sp.calendar_to_month, 12) AS VARCHAR) 
	                                                                + '/01/' +
	                                                                CASE 
	                                                                     WHEN (@buy_sell_flag = 's') THEN 
	                                                                          CAST(
	                                                                              CASE 
	                                                                                   WHEN (ISNULL(sdh.assignment_type_value_id, 5173) = 5173) THEN 
	                                                                                        YEAR(@deal_date)
	                                                                                   ELSE 
	                                                                                        sdh.compliance_year
	                                                                              END 
	                                                                              AS 
	                                                                              VARCHAR
	                                                                          )
	                                                                     ELSE 
	                                                                          CAST(sdh.compliance_year AS VARCHAR)
	                                                                END
	                                                            )
	                                                        )
	                                                        --'12/31/' + cast(sdh.compliance_year as varchar)
	                                                   ELSE CASE 
	                                                             WHEN (
	                                                                    ISNULL( spd.banking_period_frequency, ISNULL(sp.banking_period_frequency, 706)) = 703
	                                                                  ) THEN dbo.FNADateFormat(
	                                                                      dbo.FNALastDayInDate(
	                                                                          DATEADD(
	                                                                              mm,
	                                                                              CASE 
	                                                                                   WHEN (ISNULL(rg.gen_offset_technology, 'n') = 'n') THEN 
	                                                                                        ISNULL(spd.duration, ISNULL(sp.duration, 0))
	                                                                                   ELSE 
	                                                                                        ISNULL(spd.offset_duration, ISNULL(sp.offset_duration, 0))
	                                                                              END,
	                                                                              sdd.term_start
	                                                                          )
	                                                                      )
	                                                                  )
	                                                             ELSE --default is yearly
	                                                                  dbo.FNADateFormat(
	                                                                      dbo.FNALastDayInDate(
	                                                                          CAST(
	                                                                              ( YEAR(sdd.term_start) +
	                                                                                  CASE 
	                                                                                       WHEN (ISNULL(rg.gen_offset_technology, 'n') = 'n') THEN 
	                                                                                            ISNULL(spd.duration, ISNULL(sp.duration, 0))
	                                                                                       ELSE 
	                                                                                            ISNULL(spd.offset_duration, ISNULL(sp.offset_duration, 0))
	                                                                                  END  - 1
	                                                                              ) AS VARCHAR
	                                                                          ) + '-' + CAST(ISNULL(sp.calendar_to_month, 12) AS VARCHAR) 
	                                                                          + '-01'
	                                                                      )
	                                                                  )
	                                                        END
	                                              END
	                                    END
	FROM   source_deal_detail sdd
	LEFT OUTER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
	LEFT OUTER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
	LEFT OUTER JOIN state_properties sp ON sp.state_value_id = ISNULL(sdh.state_value_id, ISNULL(@state_id, rg.state_value_id))
	LEFT OUTER JOIN state_properties_duration spd ON spd.gen_code_value = sp.state_value_id
	AND spd.technology = rg.technology
    AND (
            ISNULL(spd.assignment_type_Value_id, 5149) = ISNULL(@assignment_type, 5149)
            OR spd.assignment_type_Value_id IS NULL
        )
	WHERE  sdd.source_deal_detail_id = @source_deal_header_id
	
	-- 	select @FNADEALRECExpirationState
	RETURN(@FNADEALRECExpirationState)
END













































