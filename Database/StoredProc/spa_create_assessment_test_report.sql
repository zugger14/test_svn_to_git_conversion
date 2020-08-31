
/************************************************************
 * Code formatted by SoftTree SQL Assistant © v4.6.12
 * Time: 3/18/2013 3:24:16 PM
 ************************************************************/

IF OBJECT_ID(N'spa_create_assessment_test_report', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_create_assessment_test_report]
 GO 



-- exec spa_create_assessment_test_report 519, 0
-- exec spa_create_assessment_test_report 625, 1
-- exec spa_create_assessment_test_report 525, 1
-- @what_if 1 means yes 0  means  no
CREATE PROCEDURE [dbo].[spa_create_assessment_test_report]
	@eff_test_result_id INT,
	@what_if INT = 0
AS
SET NOCOUNT ON
	-- 1 means yes 0  means  no
	-- DECLARE @what_if INT
	-- DECLARE @eff_test_result_id INT
	--
	-- SET @what_if  = 1
	-- SET @eff_test_result_id = 449
	
	CREATE TABLE #rel_types
	(
		eff_test_profile_id  INT,
		fas_book_id          INT,
		eff_test_name        VARCHAR(100) COLLATE DATABASE_DEFAULT
	)
	
	
	IF @what_if = 0
	    INSERT INTO #rel_types
	    SELECT eff_test_profile_id,
	           fas_book_id,
	           eff_test_name
	    FROM   fas_eff_hedge_rel_type
	    WHERE  eff_test_profile_id IN (SELECT eff_test_profile_id
	                                   FROM   fas_eff_ass_test_results
	                                   WHERE  eff_test_result_id = @eff_test_result_id)
	ELSE
	    INSERT INTO #rel_types
	    SELECT eff_test_profile_id,
	           fas_book_id,
	           eff_test_name
	    FROM   fas_eff_hedge_rel_type_whatif
	    WHERE  eff_test_profile_id IN (SELECT eff_test_profile_id
	                                   FROM   fas_eff_ass_test_results
	                                   WHERE  eff_test_result_id = @eff_test_result_id)
	
	--select * from #rel_types
	
	--If @what_if = 0
	SELECT B.eff_test_result_id [Result ID],
	       CASE 
	            WHEN (
	                     dbo.FNATestAssessment(
	                         B.eff_test_approach_value_id,
	                         B.result_value,
	                         CASE 
	                              WHEN (B.eff_test_approach_value_id IN (305, 306)) THEN CASE 
	                                                                                          WHEN (B.eff_test_approach_value_id IN (305)) THEN 
	                                                                                               td.t_value
	                                                                                          WHEN (B.eff_test_approach_value_id IN (306)) THEN 
	                                                                                               fd.f_value
	                                                                                          ELSE 
	                                                                                               NULL
	                                                                                     END
	                              ELSE fs.test_range_from
	                         END,
	                         fs.test_range_to,
	                         B.additional_result_value,
	                         CASE 
	                              WHEN (
	                                       B.eff_test_approach_value_id IN (307, 308, 309, 310, 311, 312, 313, 314)
	                                   ) THEN CASE 
	                                               WHEN (B.eff_test_approach_value_id IN (307, 309, 311, 313)) THEN 
	                                                    td.t_value
	                                               WHEN (B.eff_test_approach_value_id IN (308, 310, 312, 314)) THEN 
	                                                    fd.f_value
	                                               ELSE NULL
	                                          END
	                              ELSE fs.additional_test_range_from
	                         END,
	                         fs.additional_test_range_to,
	                         B.additional_result_value2,
	                         fs.additional_test_range_from2,
	                         fs.additional_test_range_to2
	                     ) = 1
	                 ) THEN CASE 
	                             WHEN (B.eff_test_approach_value_id <> 317) THEN 
	                                  'Passed'
	                             ELSE 'Passed (Effective)'
	                        END
	            ELSE CASE 
	                      WHEN (B.eff_test_approach_value_id <> 317) THEN 
	                           'Failed'
	                      ELSE 'Failed (Ineffective)'
	                 END
	       END AS [Test],
	       (
	           CAST(B.eff_test_profile_id AS VARCHAR) + '-' + C.eff_test_name
	       ) AS [Rel Type ID],
	       asstype.code AS [Assessment Type],
	       CAST(B.result_value AS VARCHAR) + CASE 
	                                              WHEN (
	                                                       B.eff_test_approach_value_id IN (300, 309, 310, 311, 312, 316)
	                                                   ) THEN ' <span title=' 
	                                                   + '''This test will pass if this value is between Test Range From1 and Test Range To1.'''
	                                                   + '><u>(Correlation)</u></span>'
	                                              WHEN (
	                                                       B.eff_test_approach_value_id IN (301, 304, 307, 308, 313, 314, 315)
	                                                   ) THEN ' <span title='
	                                                   + '''This test will pass if this value is between Test Range From1 and Test Range To1.'''
	                                                    + '><u>(RSQ)</u></span>'
	                                              WHEN (B.eff_test_approach_value_id = 302) THEN 
	                                                   ' <span title='
	                                                   + '''This test will pass if this value is between Test Range From1 and Test Range To1.'''
	                                                   + '><u>(Dollar Offset)</u></span>'
	                                              WHEN (B.eff_test_approach_value_id = 303) THEN 
	                                                   ' <span title='
	                                                   + '''This test will pass if this value is between Test Range From1 and Test Range To1.'''
	                                                   + '><u>(User Defined)</u></span>'
	                                              WHEN (B.eff_test_approach_value_id = 305) THEN 
	                                                   ' <span title='
	                                                   + '''TTest is a two-tail test where it will pass if this value is greater than Test Range From2 or  less than negative of Test Range From2.'''
	                                                   + '><u>(TTest)</u></span>'
	                                              WHEN (B.eff_test_approach_value_id = 306) THEN 
	                                                   ' <span title='
	                                                   + '''FTest is a one-tail test where it will pass if this value is greater than Test Range From2.'''
	                                                   + '><u>(FTest)</u></span>'
	                                              WHEN (B.eff_test_approach_value_id = 317) THEN 
	                                                   ' <span title='
	                                                   + '''If test value is 1 then it means this is an economic hedge using underlying terms as test criteria.'''
	                                                   + '><u>(Underlying Terms)</u></span>'
	                                              ELSE ' (ERROR)'
	                                         END AS [Assessment Value1],
	       CASE 
	            WHEN (B.eff_test_approach_value_id IN (305, 306)) THEN CASE 
	                                                                        WHEN (B.eff_test_approach_value_id IN (305)) THEN 
	                                                                             td.t_value
	                                                                        WHEN (B.eff_test_approach_value_id IN (306)) THEN 
	                                                                             fd.f_value
	                                                                        ELSE 
	                                                                             NULL
	                                                                   END
	            ELSE fs.test_range_from
	       END AS [Test Range From1],
	       CASE 
	            WHEN B.eff_test_approach_value_id IN (305, 306) THEN NULL
	            ELSE fs.test_range_to
	       END [Test Range To1],
	       CAST(
	           CASE 
	                WHEN (
	                         B.additional_result_value = 0
	                         OR B.additional_result_value IS NULL
	                     ) THEN ''
	                ELSE B.additional_result_value
	           END AS VARCHAR
	       ) +
	       CASE 
	            WHEN (B.eff_test_approach_value_id IN (315, 316)) THEN 
	                 ' <span title='
	                 + '''This test will pass if this value is between Test Range From2 and Test Range To2.'''
	                 + '><u>(Slope)</u></span>'
	            WHEN (B.eff_test_approach_value_id IN (307, 309, 311, 313)) THEN 
	                 ' <span title='
	                 + '''TTest is a two-tail test where it will pass if this value is greater than Test Range From2 or  less than negative of Test Range From2.'''
	                 + '><u>(TTest)</u></span>'
	            WHEN (B.eff_test_approach_value_id IN (308, 310, 312, 314)) THEN 
	                 ' <span title='
	                 + '''FTest is a one-tail test where it will pass if this value is greater than Test Range From2.'''
	                 + '><u>(FTest)</u></span>'
	            ELSE ''
	       END AS [Assessment Value2],
	       CAST(
	           CASE 
	                WHEN (
	                         B.eff_test_approach_value_id IN (307, 308, 309, 310, 311, 312, 313, 314)
	                     ) THEN CASE 
	                                 WHEN (B.eff_test_approach_value_id IN (307, 309, 311, 313)) THEN 
	                                      CAST(td.t_value AS VARCHAR) + 
	                                      ' (t value @' + CAST((1 -fs.additional_test_range_from / 2) * 100 AS VARCHAR) 
	                                      + '% DF:' + CAST(D.regression_df AS VARCHAR) 
	                                      + ')'
	                                 WHEN (B.eff_test_approach_value_id IN (308, 310, 312, 314)) THEN 
	                                      CAST(fd.f_value AS VARCHAR) + 
	                                      ' (F value @' + CAST((1 -fs.additional_test_range_from) * 100 AS VARCHAR) 
	                                      + '% DF:' + CAST(D.regression_df AS VARCHAR) 
	                                      + ')'
	                                 ELSE NULL
	                            END
	                ELSE CAST(fs.additional_test_range_from AS VARCHAR)
	           END AS VARCHAR
	       ) AS [Test Range From2],
	       CAST(
	           CASE 
	                WHEN B.eff_test_approach_value_id IN (307, 308, 309, 310, 311, 312, 313, 314) THEN 
	                     NULL
	                ELSE ISNULL(fs.additional_test_range_to, '')
	           END AS VARCHAR
	       ) [Test Range To2],
	       CAST(
	           CASE 
	                WHEN (B.eff_test_approach_value_id IN (311, 312, 313, 314)) THEN 
	                     B.additional_result_value2
	                ELSE NULL
	           END AS VARCHAR
	       ) + ' <span title='
			 + '''This test will pass if this value is between Test Range From3 and Test Range To3.'''
			 + '><u>(Slope)</u></span>' [Assessment Value3],
	       CAST(
	           CASE 
	                WHEN (B.eff_test_approach_value_id IN (311, 312, 313, 314)) THEN 
	                     fs.additional_test_range_from2
	                ELSE NULL
	           END AS VARCHAR
	       ) [Test Range From3],
	       CAST(
	           CASE 
	                WHEN (B.eff_test_approach_value_id IN (311, 312, 313, 314)) THEN 
	                     fs.additional_test_range_to2
	                ELSE NULL
	           END AS VARCHAR
	       ) [Test Range To3],
	       -- 	isnull(cast(CASE 	WHEN (B.eff_test_approach_value_id IN (305, 307, 309, 311, 313)) THEN td.t_value
	       -- 			Else NULL End as varchar), '') As [T-Test Value],
	       --
	       -- 	isnull(cast(CASE WHEN (B.eff_test_approach_value_id IN (306, 308, 310, 312, 314)) THEN fd.f_value
	       -- 		Else NULL END as varchar), '') as [F-Test Value],
	       dbo.FNADateFormat(B.as_of_date) AS [As of Date],
	       --	asstype.code AS [Assessment Type],
	       -- 	D.regression_df as DFreedom,
	       -- 	isnull(CAST(case 	when (B.eff_test_approach_value_id = 305) then fs.test_range_from/2
	       -- 			when (B.eff_test_approach_value_id IN (307, 309)) then fs.additional_test_range_from/2
	       -- 			when (B.eff_test_approach_value_id = 306) then fs.test_range_from
	       -- 			when (B.eff_test_approach_value_id IN (308, 310)) then fs.additional_test_range_from
	       -- 	END AS VARCHAR), '') Alpha,
	       CAST(
	           CASE 
	                WHEN (B.link_id = -1) THEN NULL
	                ELSE B.link_id
	           END AS VARCHAR
	       ) AS [Rel ID]
	       -- 	case when (B.calc_level = 1) then  'RelType' when (B.calc_level = 2) then 'Rel' Else 'Whatif' End As CalcLevel
	       
	       --INTO #ass_info
	FROM   fas_eff_ass_test_results B(NOLOCK)
	       INNER JOIN #rel_types C
	            ON  c.eff_test_profile_id = B.eff_test_profile_id
	       INNER JOIN static_data_value asstype
	            ON  asstype.value_id = B.eff_test_approach_value_id
	       LEFT OUTER JOIN fas_eff_ass_test_results_process_header D
	            ON  D.eff_test_result_id = B.eff_test_result_id
	       INNER  JOIN portfolio_hierarchy book
	            ON  book.entity_id = C.fas_book_id
	       INNER  JOIN fas_strategy fs
	            ON  book.parent_entity_id = fs.fas_strategy_id
	       LEFT OUTER JOIN t_distribution td
	            ON  td.df = CASE 
	                             WHEN (D.regression_df > 1001) THEN 1001
	                             WHEN (D.regression_df BETWEEN 100 AND 1000) THEN 
	                                  100
	                             WHEN (D.regression_df BETWEEN 80 AND 100) THEN 
	                                  80
	                             WHEN (D.regression_df BETWEEN 60 AND 80) THEN 
	                                  60
	                             WHEN (D.regression_df BETWEEN 50 AND 60) THEN 
	                                  50
	                             WHEN (D.regression_df BETWEEN 40 AND 50) THEN 
	                                  40
	                             WHEN (D.regression_df BETWEEN 30 AND 40) THEN 
	                                  30
	                             ELSE D.regression_df
	                        END
	            AND td.alpha = CAST(
	                    CASE 
	                         WHEN (B.eff_test_approach_value_id = 305) THEN fs.test_range_from
	                              / 2
	                         WHEN (B.eff_test_approach_value_id IN (307, 309, 311, 313)) THEN 
	                              fs.additional_test_range_from / 2
	                         WHEN (B.eff_test_approach_value_id = 306) THEN fs.test_range_from
	                         WHEN (B.eff_test_approach_value_id IN (308, 310, 312, 314)) THEN 
	                              fs.additional_test_range_from
	                    END AS VARCHAR
	                )
	       LEFT OUTER JOIN f_distribution fd
	            ON  fd.ndf = 1
	            AND fd.ddf = CASE 
	                              WHEN (D.regression_df > 34) THEN 34
	                              ELSE D.regression_df
	                         END
	            AND fd.alpha = CAST(
	                    CASE 
	                         WHEN (B.eff_test_approach_value_id = 305) THEN fs.test_range_from
	                              / 2
	                         WHEN (B.eff_test_approach_value_id IN (307, 309, 311, 313)) THEN 
	                              fs.additional_test_range_from / 2
	                         WHEN (B.eff_test_approach_value_id = 306) THEN fs.test_range_from
	                         WHEN (B.eff_test_approach_value_id IN (308, 310, 312, 314)) THEN 
	                              fs.additional_test_range_from
	                    END AS VARCHAR
	                )
	WHERE  --B.calc_level IN (1, 2) and 
	       B.eff_test_result_id = @eff_test_result_id
	       
	       -- -- Else
	       -- -- SELECT  B.eff_test_result_id [Result ID],
	       -- -- 	CASE WHEN (dbo.FNATestAssessment(B.eff_test_approach_value_id,
	       -- -- 				B.result_value,
	       -- -- 				CASE WHEN (C.on_eff_test_approach_value_id IN (305, 306)) THEN
	       -- -- 						CASE 	WHEN (B.eff_test_approach_value_id IN (305)) THEN td.t_value
	       -- -- 							WHEN (B.eff_test_approach_value_id IN (306)) THEN fd.f_value
	       -- -- 							Else NULL
	       -- -- 						END
	       -- -- 				     ELSE fs.test_range_from END,
	       -- -- 				fs.test_range_to,
	       -- -- 				B.additional_result_value,
	       -- -- 				CASE WHEN (B.eff_test_approach_value_id IN (307, 308, 309, 310, 311, 312, 313, 314)) THEN
	       -- -- 						CASE 	WHEN (B.eff_test_approach_value_id IN (307, 309, 311, 313)) THEN td.t_value
	       -- -- 							WHEN (B.eff_test_approach_value_id IN (308, 310, 312, 314)) THEN fd.f_value
	       -- -- 							Else NULL
	       -- -- 						END
	       -- -- 				     ELSE fs.additional_test_range_from END,
	       -- -- 				fs.additional_test_range_to,
	       -- -- 				B.additional_result_value2,
	       -- -- 				fs.additional_test_range_from2,
	       -- -- 				fs.additional_test_range_to2) = 1) THEN  'Passed' Else 'Failed' End
	       -- -- 	As [Test],
	       -- -- 	(cast (B.eff_test_profile_id as varchar) + '-' + C.eff_test_name) AS [Rel Type ID],
	       -- -- 	asstype.code AS [Assessment Type],
	       -- -- 	cast(B.result_value as varchar) + case 	when (B.eff_test_approach_value_id IN (300, 309, 310, 311, 312)) then ' (Correlation)'
	       -- -- 		when (B.eff_test_approach_value_id IN (301, 304, 307, 308, 313, 314)) then ' (RSQ)'
	       -- -- 		when (B.eff_test_approach_value_id	= 302) then ' (Dollar Offset)'
	       -- -- 		when (B.eff_test_approach_value_id	= 303) then ' (User Defined)'
	       -- -- 		when (B.eff_test_approach_value_id	= 305) then ' (TTest)'
	       -- -- 		when (B.eff_test_approach_value_id	= 306) then ' (FTest)'
	       -- -- 		else ' (ERROR)'
	       -- -- 	end as [Assessment Value1],
	       -- -- 	CASE WHEN (C.on_eff_test_approach_value_id IN (305,306)) THEN
	       -- -- 						CASE 	WHEN (B.eff_test_approach_value_id IN (305)) THEN td.t_value
	       -- -- 							WHEN (B.eff_test_approach_value_id IN (306)) THEN fd.f_value
	       -- -- 							Else NULL
	       -- -- 						END
	       -- -- 				     ELSE fs.test_range_from END
	       -- -- 	AS [Test Range From1],
	       -- -- 	case when B.eff_test_approach_value_id IN (305, 306) then NULL else fs.test_range_to end [Test Range To1],
	       -- -- 	cast (case when  (B.additional_result_value = 0 OR B.additional_result_value IS NULL) then '' else B.additional_result_value end as varchar) +
	       -- -- 	case 	when (B.eff_test_approach_value_id	= 304) then ' <span title=''This test will pass if this value is between Test Range From2 and Test Range From1.''><u>(Slope)</u></span>'
	       -- -- 		when (B.eff_test_approach_value_id IN ( 307, 309, 311, 313)) then ' <span title=''TTest is a two-tail test where it will pass if this value is greater than Test Range From2 or  less than negative of Test Range From2.''><u>(TTest)</u></span>'
	       -- -- 		when (B.eff_test_approach_value_id IN (308, 310, 312, 314)) then ' <span title=''FTest is a one-tail test where it will pass if this value is greater than Test Range From2.''><u>(FTest)</u></span>'
	       -- -- 		else ''
	       -- -- 	end
	       -- -- 	as [Assessment Value2],
	       -- -- 	cast(CASE WHEN (B.eff_test_approach_value_id IN (307, 308, 309, 310, 311, 312, 313, 314)) THEN
	       -- -- 						CASE 	WHEN (B.eff_test_approach_value_id IN (307, 309, 311, 313)) THEN cast(td.t_value as varchar) + ' (t value @' + cast ((1-fs.additional_test_range_from/2)*100 as varchar) + '% DF:' + CAST(D.regression_df AS VARCHAR) + ')'
	       -- -- 							WHEN (B.eff_test_approach_value_id IN (308, 310, 312, 314)) THEN cast(fd.f_value as varchar) + ' (F value @' + cast ((1-fs.additional_test_range_from)*100 as varchar) + '% DF:' + CAST(D.regression_df AS VARCHAR) + ')'
	       -- -- 							Else NULL
	       -- -- 						END
	       -- -- 				     ELSE cast (fs.additional_test_range_from as varchar) END as varchar)
	       -- -- 	AS [Test Range From2],
	       -- -- 	case when B.eff_test_approach_value_id IN (307, 308, 309, 310, 311, 312, 313, 314) then NULL else isnull (fs.additional_test_range_to, '') end [Additional Test Range To2],
	       -- -- 	cast(CASE WHEN (B.eff_test_approach_value_id IN (311, 312, 313, 314)) then B.additional_result_value2 else NULL end as varchar) + ' (Slope)' [Assessment Value3],
	       -- -- 	cast(CASE WHEN (B.eff_test_approach_value_id IN (311, 312, 313, 314)) then fs.additional_test_range_from2 else NULL end as varchar) [Test Range From3],
	       -- -- 	cast(CASE WHEN (B.eff_test_approach_value_id IN (311, 312, 313, 314)) then fs.additional_test_range_to2 else NULL end as varchar) [Test Range To3],
	       -- --
	       -- -- -- 	isnull(cast(CASE 	WHEN (B.eff_test_approach_value_id IN (305, 307, 309, 311, 313)) THEN td.t_value
	       -- -- -- 			Else NULL End as varchar), '') As [T-Test Value],
	       -- -- --
	       -- -- -- 	isnull(cast(CASE WHEN (B.eff_test_approach_value_id IN (306, 308, 310, 312, 314)) THEN fd.f_value
	       -- -- -- 		Else NULL END as varchar), '') as [F-Test Value],
	       -- -- 	dbo.FNADateFormat(B.as_of_date) AS [As of Date],
	       -- -- --	asstype.code AS [Assessment Type],
	       -- -- -- 	D.regression_df as DFreedom,
	       -- -- -- 	isnull(CAST(case 	when (B.eff_test_approach_value_id = 305) then fs.test_range_from/2
	       -- -- -- 			when (B.eff_test_approach_value_id IN (307, 309)) then fs.additional_test_range_from/2
	       -- -- -- 			when (B.eff_test_approach_value_id = 306) then fs.test_range_from
	       -- -- -- 			when (B.eff_test_approach_value_id IN (308, 310)) then fs.additional_test_range_from
	       -- -- -- 	END AS VARCHAR), '') Alpha,
	       -- --  	cast (case when (B.link_id = -1) then NULL else B.link_id End as varchar) As RelID
	       -- -- -- 	case when (B.calc_level = 1) then  'RelType' when (B.calc_level = 2) then 'Rel' Else 'Whatif' End As CalcLevel
	       -- --
	       -- -- --INTO #ass_info
	       -- -- FROM
	       -- -- fas_eff_ass_test_results B(NOLOCK) INNER JOIN
	       -- -- fas_eff_hedge_rel_type_whatif C ON c.eff_test_profile_id = B.eff_test_profile_id INNER JOIN
	       -- -- static_data_value asstype ON asstype.value_id = B.eff_test_approach_value_id
	       -- -- LEFT OUTER JOIN fas_eff_ass_test_results_process_header D ON D.eff_test_result_id = B.eff_test_result_id
	       -- -- INNER  JOIN portfolio_hierarchy book ON book.entity_id = C.fas_book_id
	       -- -- INNER  JOIN fas_strategy fs ON book.parent_entity_id = fs.fas_strategy_id
	       -- -- LEFT OUTER JOIN t_distribution td ON td.df = D.regression_df AND td.alpha =
	       -- -- 		CAST(case 	when (B.eff_test_approach_value_id = 305) then fs.test_range_from/2
	       -- -- 			when (B.eff_test_approach_value_id IN (307, 309, 311, 313)) then fs.additional_test_range_from/2
	       -- -- 			when (B.eff_test_approach_value_id = 306) then fs.test_range_from
	       -- -- 			when (B.eff_test_approach_value_id IN (308, 310, 312, 314)) then fs.additional_test_range_from
	       -- -- 		end AS VARCHAR)
	       -- -- LEFT OUTER JOIN f_distribution fd ON fd.ndf = 1 AND fd.ddf = D.regression_df AND fd.alpha =
	       -- -- 		CAST(case 	when (B.eff_test_approach_value_id = 305) then fs.test_range_from/2
	       -- -- 			when (B.eff_test_approach_value_id IN (307, 309, 311, 313)) then fs.additional_test_range_from/2
	       -- -- 			when (B.eff_test_approach_value_id = 306) then fs.test_range_from
	       -- -- 			when (B.eff_test_approach_value_id IN (308, 310, 312, 314)) then fs.additional_test_range_from
	       -- -- 		end AS VARCHAR)
	       -- -- WHERE B.calc_level IN (3) and B.eff_test_result_id = @eff_test_result_id
	       










