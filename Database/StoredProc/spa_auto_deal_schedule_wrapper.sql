SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**
	Wrapper sp to call spa_auto_deal_schedule. Pass each deal term in loop to support multi term for creating transportation deal. Called from spa_deal_update_new, triggered while saving deal with delivery path (udf)
	Parameters
	@source_deal_header_id	: Deal ID of updated deal

*/
CREATE OR ALTER PROC [dbo].[spa_auto_deal_schedule_wrapper] 
	@source_deal_header_id VARCHAR(1000)
AS
/*
DECLARE @source_deal_header_id INT

select @source_deal_header_id= 8407

--*/
BEGIN
	
	DECLARE @schedule_path_id INT,
			@header_buy_sell CHAR(1),
			@should_readjust_transport BIT,
			@deal_location_id INT,
			@deal_term_start DATETIME,
			@deal_term_end DATETIME,
			@transport_deal_id INT,
			--@profile_granularity INT,
			@reschedule BIT = 0,
			@flow_date_from DATETIME,
			@flow_date_to DATETIME,
			@path_id VARCHAR(20)
	
	IF EXISTS (SELECT 1
			FROM source_deal_header
			WHERE source_deal_header_id =  @source_deal_header_id 
			AND  header_buy_sell_flag = 'b'
		)
	BEGIN

		IF EXISTS (SELECT 1
					FROM optimizer_detail
					WHERE source_deal_header_id = @source_deal_header_id 
						AND up_down_stream = 'u'
				)
		BEGIN
			SET @reschedule = 1
		END
	END
	ELSE 
	BEGIN
		IF EXISTS (SELECT 1
					FROM optimizer_detail_downstream
					WHERE source_deal_header_id = @source_deal_header_id 
						
				)
		BEGIN
			SET @reschedule = 1
		END
	END 

	--SELECT @profile_granularity = profile_granularity
	--FROM source_deal_header sdh
	--WHERE source_deal_header_id = @source_deal_header_id --7385 -- @source_deal_header_id

	SELECT @deal_location_id = MIN(location_id)
		, @deal_term_start = MIN(term_start)
		, @deal_term_end = MAX(term_end)
	FROM source_deal_detail 
	WHERE source_Deal_header_id = @source_deal_header_id   --8407 -- @source_deal_header_id  
	GROUP BY source_deal_header_id 

	SELECT @header_buy_sell = header_buy_sell_flag
	FROM source_deal_header
	WHERE source_Deal_header_id = @source_deal_header_id  --8407 -- @source_deal_header_id 

	SELECT @path_id = uddf.udf_value
	FROM source_deal_header sdh
	INNER JOIN user_defined_deal_fields_template_main uddft
		ON uddft.template_id = sdh.template_id
	INNER JOIN user_defined_deal_fields uddf
		ON uddf.source_deal_header_id = sdh.source_deal_header_id 
		AND uddf.udf_template_id = uddft.udf_template_id
	INNER JOIN user_defined_fields_template udft
		ON udft.field_id = uddft.field_id
	WHERE sdh.source_deal_header_id = @source_deal_header_id --7385 --
		AND udft.Field_label = 'Delivery Path'
		AND NULLIF(uddf.udf_value, '') IS NOT NULL
		AND ISNULL(sdh.description4, '') <> 'HAS_BEEN_ADJUSTED'

	SELECT @should_readjust_transport = IIF(@deal_location_id = to_location, 1, 0)
	FROM delivery_path dp
	WHERE path_id = @path_id
		AND @header_buy_sell = 'b'


	IF (@should_readjust_transport = 1) 
	BEGIN
		SELECT @schedule_path_id = uddf.udf_value
		FROM source_deal_header sdh
		INNER JOIN user_defined_deal_fields_template_main uddft
			ON uddft.template_id = sdh.template_id
		INNER JOIN user_defined_deal_fields uddf
			ON uddf.source_deal_header_id = sdh.source_deal_header_id 
			AND uddf.udf_template_id = uddft.udf_template_id
		INNER JOIN user_defined_fields_template udft
			ON udft.field_id = uddft.field_id
		WHERE sdh.source_deal_header_id = @source_deal_header_id --8407 
			AND udft.Field_label = 'Delivery Path'	

		SELECT @transport_deal_id = sdh.source_deal_header_id 
		FROM source_deal_header sdh
		INNER JOIN source_deal_detail sdd
			ON sdd.source_deal_header_id = sdh.source_deal_header_id
		INNER JOIN source_deal_type sdt
			ON sdt.source_deal_type_id = sdh.source_deal_type_id
		INNER JOIN user_defined_deal_fields_template_main uddft
			ON uddft.template_id = sdh.template_id
		INNER JOIN user_defined_deal_fields uddf
			ON uddf.source_deal_header_id = sdh.source_deal_header_id 
			AND uddf.udf_template_id = uddft.udf_template_id
		INNER JOIN user_defined_fields_template udft
			ON udft.field_id = uddft.field_id
		WHERE udft.Field_label = 'Delivery Path'
			AND uddf.udf_value = @path_id 
			AND sdd.location_id = @deal_location_id --2853 -- 
			AND sdt.deal_type_id = 'Transportation'
			AND sdd.term_start BETWEEN @deal_term_start AND @deal_term_end
	
		SELECT  @flow_date_from = MIN(flow_date) 
			, @flow_date_to = MAX(flow_date) 
		FROM optimizer_header 
		WHERE transport_deal_id = @transport_deal_id -- 8406
		GROUP BY transport_deal_id

	END
	ELSE 
	BEGIN		
		SELECT @flow_date_from = MIN(term_start)
			, @flow_date_to = MAX(term_end) 
		FROM source_deal_detail
		WHERE source_deal_header_id = @source_deal_header_id
	END

	WHILE (@flow_date_from <= @flow_date_to)
	BEGIN
		EXEC [dbo].[spa_auto_deal_schedule]
			@source_deal_header_id = @source_deal_header_id,
			--@granularity = @profile_granularity,
			@reschedule = @reschedule,
			@flow_date = @flow_date_from,
			@transport_deal_id = @transport_deal_id

		SET @flow_date_from = DATEADD(DAY, 1, @flow_date_from);

	END;

END
GO