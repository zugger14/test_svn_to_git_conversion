IF OBJECT_ID(N'[dbo].[spa_calc_pending_deal_position]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_calc_pending_deal_position]
GO
  
SET ANSI_NULLS ON
GO
  
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC dbo.spa_calc_pending_deal_position
	@call_from INT = 0 -- 0=call from job;   1 =ad-hoc call: call from event where position dependent parameter changed.
	,@calc_missing_pos BIT = 0
	,@user_login_id VARCHAR(50) = NULL
AS

SET NOCOUNT ON

/*
declare
@call_from int=0 -- 0=call from job;   1 = ad-hoc call: call from event where position dependent parameter changed.
,@user_login_id varchar(50)=null

--*/

DECLARE @threshold_position_calc_for_pending_deals VARCHAR(50)
DECLARE @no_deal_detail_records INT
SET @user_login_id = ISNULL(@user_login_id, dbo.fnadbuser())
declare @report_position varchar(250),@process_id varchar(50),@st varchar(max)
set @process_id=dbo.FNAGetNewID()
SET @report_position = dbo.FNAProcessTableName('report_position', @user_login_id, @process_id)

IF OBJECT_ID(@report_position) IS NOT NULL
	EXEC('DROP TABLE ' + @report_position)

EXEC('CREATE TABLE ' + @report_position + '	(source_deal_header_id int, [Action] varchar(1))'	)
	
IF @calc_missing_pos = 1 AND ISNULL(@call_from,0) = 0

BEGIN
	set @st='
		INSERT INTO ' + @report_position + '(source_deal_header_id, [action])
		SELECT DISTINCT sdh.source_deal_header_id, ''i'' action
		FROM source_deal_header sdh (nolock) 
		inner join source_deal_detail sdd on sdh.source_deal_header_id=sdd.source_deal_header_id
		left join report_hourly_position_deal s on sdh.source_deal_header_id=s.source_deal_header_id
		where (s.source_deal_header_id is null or sdd.total_volume is null)
		and  isnull(sdh.internal_desk_id,17300) in (17300,17302) and  isnull(sdh.product_id,4101) = 4101
		UNION
		SELECT DISTINCT sdh.source_deal_header_id, ''i'' action
		FROM source_deal_header sdh (nolock) 
		inner join source_deal_detail sdd on sdh.source_deal_header_id=sdd.source_deal_header_id
		left join report_hourly_position_profile s on sdh.source_deal_header_id=s.source_deal_header_id
		where (s.source_deal_header_id is null or sdd.total_volume is null)
		and  sdh.internal_desk_id in (17301) and  isnull(sdh.product_id,4101) = 4101
		UNION
		SELECT DISTINCT sdh.source_deal_header_id, ''i'' action
		FROM source_deal_header sdh (nolock)
		inner join source_deal_detail sdd on sdh.source_deal_header_id=sdd.source_deal_header_id
		left join report_hourly_position_fixed s on sdh.source_deal_header_id=s.source_deal_header_id
		where (s.source_deal_header_id is null or sdd.total_volume is null)
		and  sdh.product_id =4100'
	exec(@st)
END
IF ISNULL(@call_from,0) = 1
BEGIN
	SELECT @no_deal_detail_records=count(1) FROM source_deal_detail sdd 
		INNER JOIN ( SELECT DISTINCT source_deal_header_id FROM process_deal_position_breakdown WHERE process_status IN (0, 1, 9)
		) p ON sdd.source_deal_header_id=p.source_deal_header_id

	SELECT @threshold_position_calc_for_pending_deals = var_value FROM dbo.adiha_default_codes_values WHERE default_code_id = 202 AND instance_no = 1 AND seq_no = 1

END

IF ISNULL(@no_deal_detail_records, 0) <= ISNULL(@threshold_position_calc_for_pending_deals, 0)
BEGIN
	UPDATE process_deal_position_breakdown SET process_status = 0 WHERE ISNULL(process_status, 0) = 9 

	EXEC spa_calc_deal_position_breakdown NULL, @process_id, 1

	--EXEC [dbo].[spa_deal_position_breakdown] 'i', NULL, @user_login_id, @process_id
	--SET @st = 'spa_update_deal_total_volume NULL,'''+@process_id+''',0,1,''' + @user_login_id + ''',''n'', 1, NULL'	
	--EXEC(@st)

	-- CALCULATE POSITION DIRECTLY WITHOUT JOB and run for deals of process_deal_position_breakdown table.
	--EXEC [dbo].[spa_update_deal_total_volume] @source_deal_header_ids = NULL, @process_id = NULL, @insert_type = 0, @partition_no = NULL, @user_login_id  = @user_login_id,
	--	@insert_process_table = 'n', @call_from = 1, @call_from_2 = NULL

	EXEC dbo.spa_message_board 'i', @user_login_id, NULL, 'PositionRecalc',  'Position re-calculation of the impacted deal has been run successfully.', '', '', 's', NULL

END
ELSE
	EXEC dbo.spa_message_board 'i', @user_login_id, NULL, 'PositionRecalc',  'Position re-calculation of the impacted deal has been scheduled to run in EOD.', '', '', 's', NULL



/*

INSERT INTO dbo.process_deal_position_breakdown
(source_deal_header_id,create_user,create_ts,process_status,insert_type,deal_type,commodity_id,fixation,internal_deal_type_value_id)
SELECT  sdh.source_deal_header_id,max(sdh.create_user),getdate(),9,0,
	max(isnull(sdh.internal_desk_id,17300)) deal_type ,	max(isnull(spcd.commodity_id,-1)) commodity_id,max(isnull(sdh.product_id,4101)) fixation
	,max(isnull(sdh.internal_deal_type_value_id,-999999))
FROM source_deal_header sdh
	inner join source_deal_detail sdd on sdh.source_deal_header_id=sdd.source_deal_header_id
	left join source_price_curve_def spcd on sdd.curve_id=spcd.source_curve_def_id and sdd.curve_id is not null
group by sdh.source_deal_header_id

*/