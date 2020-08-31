-- Update querey should be run incase of Foregin Key Conflict occurs
--Verify the data before running this query as it might cause data loss
 

 --Note ::
 --Debt_rating and Risk_rating is only foregin key so we do not need to update Debt_Rating2,Debt_Rating3 AND Debt_Rating4


--UPDATE counterparty_credit_info
--SET Debt_rating =NULL,
----Debt_Rating2 = NULL,
----Debt_Rating3 = NULL,
----Debt_Rating4 = NULL,
--Risk_rating = NULL


-- Delete querey should be run incase of Foregin Key Conflict occurs
--Verify the data before running this query as it might cause data loss


--DELETE drr FROM default_recovery_rate drr INNER JOIN static_data_value sdv ON drr.debt_rating = sdv.value_id 
--WHERE  sdv.type_id IN(10098,11099,11100,11101,11102,10097) 


-- To verify data 
--SELECT * from counterparty_credit_info cci INNER JOIN static_data_value sdv 
--ON cci.Debt_rating = sdv.value_id AND sdv.type_id IN(10098,11099,11100,11101,11102,10097) 

--SELECT * from counterparty_credit_info cci INNER JOIN static_data_value sdv 
--ON cci.Debt_Rating2 = sdv.value_id AND sdv.type_id IN(10098,11099,11100,11101,11102,10097) 


--SELECT * from counterparty_credit_info cci INNER JOIN static_data_value sdv 
--ON cci.Debt_Rating3 = sdv.value_id AND sdv.type_id IN(10098,11099,11100,11101,11102,10097) 

--SELECT * from counterparty_credit_info cci INNER JOIN static_data_value sdv 
--ON cci.Debt_Rating4 = sdv.value_id AND sdv.type_id IN(10098,11099,11100,11101,11102,10097) 

--SELECT * from counterparty_credit_info cci INNER JOIN static_data_value sdv 
--ON cci.Risk_rating = sdv.value_id AND sdv.type_id IN(10098,11099,11100,11101,11102,10097) 


--SELECT *  FROM default_recovery_rate drr INNER JOIN static_data_value sdv ON drr.debt_rating = sdv.value_id 
--WHERE  sdv.type_id IN(10098,11099,11100,11101,11102,10097) 


DELETE FROM static_data_value WHERE type_id IN(10098,11099,11100,11101,11102,10097)
