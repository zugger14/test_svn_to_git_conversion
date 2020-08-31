IF OBJECT_ID(N'spa_convert_to_afas_json', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_convert_to_afas_json]
GO 
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: ashakya@pioneersolutionsglobal.com
-- Create date: 2017-08-23
 
-- Params:
-- @flag CHAR(1)
-- @process_table_name  VARCHAR(100) - Process table name
-- ===========================================================================================================

CREATE PROCEDURE [dbo].[spa_convert_to_afas_json]
	@process_table_name VARCHAR(500) = NULL
AS
SET NOCOUNT ON
/*
--drop table #test
	create table #test(Year VARCHAR(20)
	, Peri VARCHAR(20)
	, UnId VARCHAR(20)
	, JoCo VARCHAR(20)
	, VaAs VARCHAR(20)
	, AcNr VARCHAR(20)
	, EnDa VARCHAR(20)
	, BpDa VARCHAR(20)
	, BpNr VARCHAR(20)
	, Ds VARCHAR(20)
	, AmDe VARCHAR(20)
	, U74D074944DB70225689641899DF32441 VARCHAR(20)
	, U5E53591548A7A7DDF601A0A42217039E VARCHAR(20)
	, DiC1 VARCHAR(20)
	, DiC2 VARCHAR(20)
	, Quan VARCHAR(20)
	)

insert into #test
select '2017', '6', '1', '92', '1', '904000', '2017-06-10', '2017-06-10', 'MEMO01', 'Test', '100', '2017', '02', '141', '1714100000', '2'
insert into #test
select '2017', '6', '1', '92', '1', '5000', '2017-06-10', '2017-06-10', 'MEMO3301', 'Te22st', '100', '2017', '02', '141', '171410045000', '2'
--select * from #test

*/
EXEC  ('
DECLARE @json VARCHAR(MAX)
select @json = COALESCE(@json + '', '', '''') + 
	''{
            ''''Fields'''': {
              ''''VaAs'''': '''''' + CAST(VaAs AS VARCHAR(2)) + '''''',
              ''''AcNr'''': '''''' + CAST(AcNr AS VARCHAR(10)) + '''''',
              ''''EnDa'''': '''''' + EnDa + '''''',
              ''''BpDa'''': '''''' + BpDa + '''''',
              ''''BpNr'''': '''''' + BpNr + '''''',
              ''''Ds'''': '''''' + Ds + '''''',
              ''''AmDe'''': '' + LTRIM(STR(ISNULL(AmDe, 0), 25, 2)) + '',
              ''''U74D074944DB70225689641899DF32441'''': '''''' + CAST(U74D074944DB70225689641899DF32441 AS VARCHAR(5)) + '''''',
              ''''U5E53591548A7A7DDF601A0A42217039E'''': ''''0'' + CAST(U5E53591548A7A7DDF601A0A42217039E AS VARCHAR(5)) + '''''',
			  ''''UCCCB937840365B8C72F798B019A38361'''': '''''' + CAST(UCCCB937840365B8C72F798B019A38361 AS VARCHAR(20)) + ''''''			  
            },
            ''''Objects'''': {
              ''''FiDimEntries'''': {
                ''''Element'''': {
                  ''''Fields'''': {
                    ''''DiC1'''': '''''' + CAST(DiC1 AS VARCHAR(20)) + '''''',
                    ''''DiC2'''': '''''' + CAST(DiC2 AS VARCHAR(20)) + '''''',
                    ''''AmDe'''': '' + LTRIM(STR(ISNULL(AmDe, 0), 25, 2)) + '',
                    ''''Quan'''': '' + LTRIM(STR(ISNULL(QUAN, 0), 25, 2)) + ''
                  }
                }
              }
            }
          },
		  {
            ''''Fields'''': {
              ''''VaAs'''': '''''' + CAST(VaAs AS VARCHAR(2)) + '''''',
              ''''AcNr'''': '''''' + CAST(AcNr_cr AS VARCHAR(10)) + '''''',
              ''''EnDa'''': '''''' + EnDa + '''''',
              ''''BpDa'''': '''''' + BpDa + '''''',
              ''''BpNr'''': '''''' + BpNr + '''''',
              ''''Ds'''': '''''' + Ds + '''''',
              ''''AmCr'''': '' + LTRIM(STR(ISNULL(AmDe, 0), 25, 2)) + '',
              ''''U74D074944DB70225689641899DF32441'''': '''''' + CAST(U74D074944DB70225689641899DF32441 AS VARCHAR(5)) + '''''',
              ''''U5E53591548A7A7DDF601A0A42217039E'''': ''''0'' + CAST(U5E53591548A7A7DDF601A0A42217039E AS VARCHAR(5)) + '''''',
			  ''''UCCCB937840365B8C72F798B019A38361'''': '''''' + CAST(UCCCB937840365B8C72F798B019A38361 AS VARCHAR(20)) + ''''''			  

            },
            ''''Objects'''': {
              ''''FiDimEntries'''': {
                ''''Element'''': {
                  ''''Fields'''': {
                    ''''DiC1'''': '''''' + CAST(DiC1 AS VARCHAR(20)) + '''''',
                    ''''DiC2'''': '''''' + CAST(DiC2 AS VARCHAR(20)) + '''''',
                    ''''AmCr'''': '' + LTRIM(STR(ISNULL(AmDe, 0), 25, 2)) + '',
                    ''''Quan'''': '' + LTRIM(STR(ISNULL(CASE WHEN CHARINDEX(''-'', QUAN, 0) > 0 THEN REPLACE(QUAN, ''-'' ,'''') ELSE CONCAT(''-'', QUAN) END, 0), 25, 2)) + ''
                  }
                }
              }
            }
          }	''
	From ' + @process_table_name + '
	--select @json
	
SELECT TOP 1 ''{
  ''''FiEntryPar'''': {
    ''''Element'''': {
      ''''Fields'''': {
        ''''Year'''': '' + CAST([Year] AS VARCHAR(5)) + '',
        ''''Peri'''': '' + CAST([month] AS VARCHAR(5)) + '',
        ''''UnId'''': 1,
        ''''JoCo'''': ''''92''''
      },
      ''''Objects'''': {
        ''''FiEntries'''': {
          ''''Element'''': [
		   '' + @json + ''
		]
        }
      }
    }
  }
}'' json_data
FROM '+ @process_table_name +' ')