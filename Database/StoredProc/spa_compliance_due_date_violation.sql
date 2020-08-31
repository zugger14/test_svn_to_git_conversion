--***************************--
--Author: Tara Nath Subedi
--Dated: June 30, 2010
--Issue Against: 2940 , Adding "Compliance Due Date Violation" screen
--						This will return date vs activity.
--***************************--

IF OBJECT_ID(N'[dbo].[spa_compliance_due_date_violation]', N'p') IS NOT NULL 
    DROP PROCEDURE [dbo].[spa_compliance_due_date_violation]

GO

CREATE PROC [dbo].[spa_compliance_due_date_violation]
    @as_of_date_from VARCHAR(10),
    @as_of_date_to VARCHAR(10)
AS 
    BEGIN

        SELECT  prc.risk_control_description AS [Activity],
                CONVERT(VARCHAR, prca.actualRunDate, 101) AS [Due Date] --101 mm/dd/yyyy flex datetimeaxis format.
        FROM    process_risk_controls prc
                LEFT JOIN process_risk_controls_activities_audit prcaa ON prc.risk_control_id = prcaa.risk_control_id
				LEFT JOIN process_risk_controls_activities prca ON prc.risk_control_id=prca.risk_control_id
        WHERE   prcaa.activity_desc = 'Activity is Pending for Mitigation.'
                AND dbo.FNAGetSQLStandardDate(prca.actualRunDate) BETWEEN @as_of_date_from
                                                                AND     @as_of_date_to

    END