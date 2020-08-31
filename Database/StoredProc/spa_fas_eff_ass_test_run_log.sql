IF OBJECT_ID('spa_fas_eff_ass_test_run_log','p') IS NOT NULL
DROP PROC [dbo].[spa_fas_eff_ass_test_run_log] 
go


-- exec spa_get_import_transactions_log 'A6258AB5_BFCB_4DAB_BC96_43AA9A433AC2'

create PROCEDURE [dbo].[spa_fas_eff_ass_test_run_log]
@process_id varchar(100),@var_calc varchar(1)='n',@err_type varchar(100)=null
AS
declare @url varchar(2000),@user_login_id varchar(50)
set @user_login_id=isnull(@user_login_id,dbo.fnadbuser())
SELECT @url = './spa_html.php?__user_name__=' + @user_login_id + 
	'&spa=exec spa_fas_eff_ass_test_run_log ''' + @process_id + ''''

if @var_calc='y'
begin
	if @err_type is null
	begin
		SELECT    distinct [type] Error_Type, 
		case [type] 
		when   'no_rec'   
			then  '<a target="_blank" href="'+ @url + ',''y'','''+[type]+''''+ '">The deals are not found.</a>'
		when   'Time_Bucket'   then  'Time Bucket Mapping is not found.'
		when   'MTM_Value'   
			then  '<a target="_blank" href="'+ @url + ',''y'','''+[type]+''''+ '">MTM Value is not found.</a>'
		when   'Counterparty'   
			then  '<a target="_blank" href="'+ @url + ',''y'','''+[type]+''''+ '">Counterparty is not found in the Deal.</a>'
		when   'Debate_Rating'   
			then  '<a target="_blank" href="'+ @url + ',''y'','''+[type]+''''+ '">Debt Rating is not found for the Counterparty.</a>'
		when   'Probability_Recovery'  
			 then  '<a target="_blank" href="'+ @url + ',''y'','''+[type]+''''+ '">ProbabilityDefault/RecoveryRate is not found.</a>'
		when   'Probability'  
			 then  '<a target="_blank" href="'+ @url + ',''y'','''+[type]+''''+ '">Default Probability is not found.</a>'
		when   'Price_Curve_Maturity_Date'   
			then  '<a target="_blank" href="'+ @url + ',''y'','''+[type]+''''+ '">Price Curve is not found for the Maturity Date.</a>'
		when   'Price_Curve_As_of_Date'   
			then  '<a target="_blank" href="'+ @url + ',''y'','''+[type]+''''+ '">Price Curve value is not found for the As_of_date.</a>'
		when   'Price_Curve_Risk_As_of_Date'  
			 then  '<a target="_blank" href="'+ @url + ',''y'','''+[type]+''''+ '">Price Curve value is not found for the Risk Bucket.</a>'
		when   'Division_by_ZERO_Return'  
			 then  '<a target="_blank" href="'+ @url + ',''y'','''+[type]+''''+ '">Division by ZERO is found in Return Series.</a>'
		when   'Division_by_ZERO_Cor'  
			 then  '<a target="_blank" href="'+ @url + ',''y'','''+[type]+''''+ '">Division by ZERO is found in Correlation.</a>'
		when   'Vol_Value'  
			 then  '<a target="_blank" href="'+ @url + ',''y'','''+[type]+''''+ '">Volatility Value is not found.</a>'
		when   'Cor_Value'  
			 then  '<a target="_blank" href="'+ @url + ',''y'','''+[type]+''''+ '">Correlation value is not found.</a>'
		when   'Portfolio_Risk'  
			 then  '<a target="_blank" href="'+ @url + ',''y'','''+[type]+''''+ '">Portfolio Risk is found Negative.</a>'
		when	'Curve_Price'
			 then  '<a target="_blank" href="'+ @url + ',''y'','''+[type]+''''+ '">Curve Price is not found.</a>'
		when	'index'
			 then  '<a target="_blank" href="'+ @url + ',''y'','''+[type]+''''+ '">Index is not found.</a>'
		when	'term'
			 then  '<a target="_blank" href="'+ @url + ',''y'','''+[type]+''''+ '">Term/Expiration is not found.</a>'
		when	'Curve_Price'
			 then  '<a target="_blank" href="'+ @url + ',''y'','''+[type]+''''+ '">Curve Price is not found.</a>'
		when	'Risk_free_rate'
			 then  '<a target="_blank" href="'+ @url + ',''y'','''+[type]+''''+ '">Risk free rate value is not found.</a>'
		when	'options'
			 then  '<a target="_blank" href="'+ @url + ',''y'','''+[type]+''''+ '">Options value is not valiad.</a>'
		when	'strike'
			 then  '<a target="_blank" href="'+ @url + ',''y'','''+[type]+''''+ '">Strike Price is not found.</a>'
		when	'primium'
			 then  '<a target="_blank" href="'+ @url + ',''y'','''+[type]+''''+ '">Primium can not be exceeded.</a>'
		when   'Expected_return_As_of_Date'   
			then  '<a target="_blank" href="'+ @url + ',''y'','''+[type]+''''+ '">Expected return value is not found.</a>'
		when   'volatility_As_of_Date'   
			then  '<a target="_blank" href="'+ @url + ',''y'','''+[type]+''''+ '">Volatility value is not found.</a>'
		when   'Cholesky_Correlation'   
			then  '<a target="_blank" href="'+ @url + ',''y'','''+[type]+''''+ '">Correlation value not found.</a>'
		when   'Cholesky_Matrix'   
			then  'Matrix is not square.'
		when   'Cholesky_Positive_Value'   
			then  'Matrix is not positive definite.'
		when   'Matrix_Multiplication'   
			then  '<a target="_blank" href="'+ @url + ',''y'','''+[type]+''''+ '">Correlation Decomposition value not found.</a>'
		when   'Eigen_Matrix'   
			then  '<a target="_blank" href="'+ @url + ',''y'','''+[type]+''''+ '">The matrix is not square.</a>'
		when   'Eigen_Threshold'   
			then  '<a target="_blank" href="'+ @url + ',''y'','''+[type]+''''+ '">The Eigenvalue is less than the threshold defined.</a>'
		when   'Eigen_Correlation'   
			then  '<a target="_blank" href="'+ @url + ',''y'','''+[type]+''''+ '">Correlation value not found.</a>'	
		when   'Eigen Values'   
			then  '<a target="_blank" href="'+ @url + ',''y'','''+[type]+''''+ '">The Eigenvalue is less than the threshold defined.</a>'
		else 
			  '<a target="_blank" href="'+ @url + ',''y'','''+[type]+''''+ '">Error Found.</a>'

		end [Message]
		FROM         fas_eff_ass_test_run_log
		WHERE process_id = @process_id 


	end
	else
	begin
		SELECT     code AS Code, [module] AS Module, source AS Source, 
			type AS Type, description AS Description, nextsteps AS [Next Steps], process_id AS [Process ID]
		FROM         fas_eff_ass_test_run_log
		WHERE process_id = @process_id and [type]=@err_type

	end
END
ELSE if @var_calc='r'
BEGIN
	EXEC('select dbo.FNADateFormat(t.as_of_date) AsOfDate ,spcd.curve_id CurveID , dbo.FNADateFormat(t.term_start) Term
			, t.rnd_value RANDValue,t.curve_value CurveValue,t.exp_rtn_value ExpectedRtn ,t.vol_value Volallity ,spc.curve_value CalcCurveValue
			from '+ @process_id + ' t 
			INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=t.curve_id
			inner join source_price_curve spc on spc.source_curve_def_id=t.curve_id
			and spc.as_of_date=t.as_of_date and spc.maturity_date=t.term_start and spc.curve_source_value_id=4505
			order by t.as_of_date desc,t.curve_id,t.term_start')
			
END
ELSE if @var_calc='m'
BEGIN
	EXEC('SELECT dbo.FNADateFormat([AsOfDate]) [AsOfDate], [MTM] FROM (
		SELECT 	t.pnl_as_of_date [AsOfDate], 
			ROUND(SUM(t.und_pnl), 6) [MTM]  
		FROM '+ @process_id + ' t 
		GROUP BY t.pnl_as_of_date
	    ) p ORDER BY p.AsOfDate DESC')
END

else
SELECT     code AS Code, [module] AS Module, source AS Source, 
	type AS Type, description AS Description, nextsteps AS [Next Steps], process_id AS [Process ID]
FROM         fas_eff_ass_test_run_log
WHERE process_id = @process_id
order by fas_eff_ass_test_run_log_id










