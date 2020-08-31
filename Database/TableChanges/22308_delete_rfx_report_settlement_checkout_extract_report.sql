--delete settlement checkout extract report
IF EXISTS (
		SELECT 1
		FROM report
		WHERE report_hash = 'EDFBEFF6_1A56_4C52_95CB_EC8285B6C4C0'
		)
BEGIN
	DECLARE @report_id VARCHAR(10)

	SELECT @report_id = report_id
	FROM report
	WHERE report_hash = 'EDFBEFF6_1A56_4C52_95CB_EC8285B6C4C0'

	EXEC spa_rfx_report @flag = 'd'
		,@report_id = @report_id
		,@process_id = NULL
END
ELSE
	PRINT '''Settlement Checkout Extract Report'' (EDFBEFF6_1A56_4C52_95CB_EC8285B6C4C0) does not exists.'