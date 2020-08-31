/**********************************************MODIFICATION HISTORY***********************************/
/*MODIFIED BY : Vishwas Khanal																		 */
/*DATE		  : 16 Jan 2008																			 */
/*DESCRIPTION : Displayed the columns Debt Rating2,Debt Rating3,Debt Rating4,Debt Rating5 when @flag */
/*				= 's' and @report_type = 'c'														 */
/*PURPOSE	  : Requirement Change as on  14 Jan 2008												 */
/*****************************************************************************************************/
/****** Object:  StoredProcedure [dbo].[spa_get_counterparty_credit_report]    Script Date: 03/05/2009 18:31:41 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_get_counterparty_credit_report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_get_counterparty_credit_report]
GO
CREATE PROCEDURE [dbo].[spa_get_counterparty_credit_report]
		@flag as Char(1),--'r' for drill down
		@Counterparty_id VARCHAR(MAX)= NULL,
		@parent_couinterparty INT=NULL,
		@limit_expiration datetime= NULL,
		@Industry_type1 int =NULL,
		@Industry_type2 int= NULL,
		@SIC_Code int =NULL,
		@Risk_rating int= NULL,
		@Debt_rating int =null,
		@report_type CHAR(1)='e',
		-- for drill down 
		@drill_counterparty_name VARCHAR(100)=NULL
		
AS
SET NOCOUNT ON 
declare @sql varchar(5000)

if @flag='s' AND (@report_type='c')
Begin
			set @sql='
					select 
						dbo.FNAHyperLinkText(10101122,sc.counterparty_name,cci.counterparty_id) [Counterparty],
						sdv.code [Risk Rating],
						sdv1.code [Debt Rating],
						sdv5.code [Debt Rating2],
						sdv6.code [Debt Rating3],
						sdv7.code [Debt Rating4],
						sdv8.code [Debt Rating5],
						sdv2.code [Industry Type1],
						sdv3.code [Industry Type2], 
						sdv4.code [SIC Code],
						amount+cci.credit_limit as [Credit Limit],
						cce.amount [Enhancement Provided],
						tenor_limit [Tenor Limit],
						dbo.fnadateformat(limit_expiration)[Limit Expiration],scu.currency_name [Currency],
						dbo.fnadateformat(customer_since) [Customer Since]												
					from 
						counterparty_credit_info cci 
						left join source_counterparty sc on sc.source_counterparty_id=cci.counterparty_id
						LEFT JOIN (select counterparty_credit_info_id,sum(amount) amount from counterparty_credit_enhancements group by counterparty_credit_info_id) cce on cce.counterparty_credit_info_id=cci.counterparty_credit_info_id
						left join static_data_value sdv on sdv.value_id=cci.risk_rating
						left join static_data_value sdv1 on sdv1.value_id=cci.debt_rating
						left join static_data_value sdv2 on sdv2.value_id=cci.industry_type1
						left join static_data_value sdv3 on sdv3.value_id=cci.industry_type2
						left join static_data_value sdv4 on sdv4.value_id=cci.sic_code 
						left join static_data_value sdv5 on sdv5.value_id=cci.Debt_Rating2
						left join static_data_value sdv6 on sdv6.value_id=cci.Debt_Rating3
						left join static_data_value sdv7 on sdv7.value_id=cci.Debt_Rating4
						left join static_data_value sdv8 on sdv8.value_id=cci.Debt_Rating5
						left join source_currency scu on scu.source_currency_id=cci.curreny_code where 1=1'
				+CASE WHEN  @Counterparty_id is not null THEN  ' and cci.counterparty_id IN (' + cast(@Counterparty_id AS VARCHAR) + ')' ELSE '' END
				+CASE WHEN  @limit_expiration is not null THEN  ' and cci.limit_expiration=' + cast (dbo.fnadateformat(@limit_expiration )as varchar) ELSE '' END
				+CASE WHEN  @Debt_rating is not null THEN  ' and cci.debt_rating=' + cast(@Debt_rating AS VARCHAR) ELSE '' END
				+CASE WHEN  @Risk_rating is not null THEN ' and cci.risk_rating=' + cast(@Risk_rating AS VARCHAR) ELSE '' END
				+CASE WHEN  @Industry_type1 is not null THEN ' and cci.Industry_type1=' + cast(@Industry_type1 AS VARCHAR) ELSE '' END
				+CASE WHEN  @Industry_type2 is not null THEN ' and cci.Industry_type2=' + cast(@Industry_type2 AS VARCHAR) ELSE '' END
				+CASE WHEN  @SIC_Code is not null THEN ' and cci.SIC_Code=' + cast(@SIC_Code AS VARCHAR) ELSE '' END
		
	
		SET @sql=@sql+' ORDER BY sc.counterparty_name'
	EXEC(@sql)
End
else if @flag='s' AND @report_type='d'
	Begin
		set @sql='
				SELECT 
					dbo.fnadateformat(d.effective_date) AS [Effective Date],
					sd.code AS [Debt Rating],

					d.months AS [Months],
					d.probability AS [Probability]
				FROM
					default_probability d
					LEFT JOIN static_data_value sd on sd.value_id=d.debt_rating
				WHERE 1=1 '				
				+CASE WHEN  @Debt_rating IS NOT NULL THEN ' and d.debt_rating=' + cast(@Debt_rating as varchar) ELSE '' END

		EXEC(@sql)
	END

else if @flag='s' AND @report_type='r'
	Begin
		set @sql='
				SELECT 
					dbo.fnadateformat(d.effective_date) AS [Effective Date],
					sd.code AS [Debt Rating],
					d.months AS [Months],
					d.rate AS [Recovery Rate]
				FROM
					default_recovery_rate d
					LEFT JOIN static_data_value sd on sd.value_id=d.debt_rating
				WHERE 1=1 '				
				+CASE WHEN  @Debt_rating IS NOT NULL THEN ' and d.debt_rating=' + cast(@Debt_rating as varchar) ELSE '' END
		EXEC(@sql)
	END


else if @flag='r'
	Begin
		select 
			sdv.code [Enhance Type],
			sc.counterparty_name [Guarantee Counterparty],
			cce.comment [Comment],
			amount [Enahancement],
			--cci.credit_limit[Enahancement Provided],
			scu.currency_name [Currency],dbo.fnadateformat(cce.eff_date) [Effective Date],
			cce.approved_by [Approved By]

			from counterparty_credit_enhancements  cce 
			join counterparty_credit_info cci on cci.counterparty_credit_info_id=cce.counterparty_credit_info_id 
			LEFT join source_counterparty sc on sc.source_counterparty_id=cci.counterparty_id
			LEFT join static_data_value sdv on sdv.value_id=cce.enhance_type
			LEFT join source_currency scu on source_currency_id=cce.currency_code
			where sc.counterparty_name=@drill_counterparty_name
End
