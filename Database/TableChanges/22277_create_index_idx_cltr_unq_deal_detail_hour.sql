IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[deal_detail_hour]') 
					AND NAME = N'idx_cltr_unq_deal_detail_hour')
BEGIN
	CREATE unique CLUSTERED  INDEX idx_cltr_unq_deal_detail_hour ON [dbo].[deal_detail_hour] ([term_date],[profile_id],[period])
END

--select [term_date],[profile_id],[period],count(1) cnt from deal_detail_hour group by [term_date],[profile_id],[period]
--having count(1)>1



--delete top(1) deal_detail_hour where [profile_id]=3 and
--[term_date]='2017-12-01'
-- [term_date]='2018-04-01'
-- [term_date]='2017-10-01'
-- [term_date]='2018-01-01'
-- [term_date]='2018-09-01'
-- [term_date]='2018-06-01'
-- [term_date]='2017-11-01'
-- [term_date]='2018-08-01'
 --[term_date]='2018-10-01'
-- [term_date]='2018-05-01'
-- [term_date]='2018-02-01'
-- [term_date]='2018-03-01'
-- [term_date]='2018-07-01'