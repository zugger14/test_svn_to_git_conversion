IF OBJECT_ID(N'[dbo].[spa_calculate_pnL_approx_vanilla]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_calculate_pnL_approx_vanilla]
GO
 
CREATE PROCEDURE  [dbo].[spa_calculate_pnL_approx_vanilla]
	@input_table_name VARCHAR(250),
	@output_table_name VARCHAR(100)
AS
BEGIN
	DECLARE @sql VARCHAR(MAX)

	SET @sql = '

	INSERT INTO '+@output_table_name+'
	exec sp_execute_external_script  @language =N''R''    
	,@script=N''
	#----------------------------
	#--------------------------------------------------------------------------------------------
	# PnL Atrribute calculations

	PnL_explained_approx <- function(vol_prev,prem_prev,prem_cur,del_1_prev,del_2_prev,gamma_prev,vega_prev,theta_prev,rho_prev,v_prev,
							  v_cur,exp_time_prev,exp_time_cur,r_prev,r_cur,spot_prev,spot_cur,DI)
	{
			  npt <- nrow(vol_prev)
		  # Change in price calculation
			  price_change=matrix(0,nrow=npt,ncol=1)
			  prem_change=matrix(0,nrow=npt,ncol=1)
			  volume <- vol_prev
			  price_change <- spot_cur-spot_prev

			  # change in premium calculation
			  prem_change <-(prem_cur-prem_prev)*volume

			  # change in greeks calculation
          
			  Delta_pnl1=matrix(0,nrow=npt,ncol=1)
			  Delta_pnl2=matrix(0,nrow=npt,ncol=1)
			  Delta_pnl=matrix(0,nrow=npt,ncol=1)
					  for (ii in 1:npt)
					  {
						Delta_pnl1[ii] <- price_change[ii]*volume[ii]*del_1_prev[ii]
						Delta_pnl[ii] <- Delta_pnl1[ii]
						if (DI[ii]>= 40084 & DI[ii]<= 40133)
						{
						  Delta_pnl2[ii] <- price_change[ii]*volume[ii]*del_2_prev[ii]
						  Delta_pnl[ii] <- Delta_pnl1[ii] + Delta_pnl2[ii]
						}
					  }
		  # Other Greeks
			  Vega_pnl  <- (v_cur-v_prev)*vega_prev*volume
			  Theta_pnl <- (exp_time_cur-exp_time_prev)*theta_prev*volume
			  Rho_pnl <- (r_cur-r_prev)*rho_prev*volume
			  Gamma_pnl <- 0.5*(price_change)^2*gamma_prev*volume
          
			  pnl_all <- Delta_pnl+Vega_pnl+Gamma_pnl+Theta_pnl+Rho_pnl
          
			  prev_MTM <- prem_prev*volume
			  cur_MTM <- prem_cur*volume
			  bal <- prem_change-pnl_all
          
			  PnL_Atrributes <- data.frame(Begining_MTM = prev_MTM,New_MTM=rep(0,length.out=npt),Deleted_MTM=rep(0,length.out=npt),Delivered_MTM=rep(0,length.out=npt),
										 Delta_pnl = Delta_pnl,Gamma_PnL=Gamma_pnl,Vega_PnL=Vega_pnl,Theta_PnL=Theta_pnl,
										 Rho_PnL=Rho_pnl,PnL_Unexplained=bal,Ending_MTM =cur_MTM,Currency =rep("USD",length.out=npt) )
        
			return(PnL_Atrributes)       
	}


	#----------------------Performing simulations-------------------
	 vopt <- PnL_explained_approx(Option_data[,1],Option_data[,2],Option_data[,3],Option_data[,4],Option_data[,5],
									Option_data[,6],Option_data[,7],Option_data[,8],Option_data[,9],Option_data[,10],
					Option_data[,11],Option_data[,12],Option_data[,13],Option_data[,14],Option_data[,15],
					Option_data[,16],Option_data[,17],Option_data[,18])
	 Option_data_out <- vopt''   
	,@input_data_1 =N''SELECT  
		vol_prev,prem_prev,prem_cur,del_1_prev,del_2_prev,gamma_prev,vega_prev,theta_prev,rho_prev,v_prev,
			v_cur,exp_time_prev,exp_time_cur,r_prev,r_cur,spot_prev,spot_cur,DI
		FROM '+@input_table_name+' 
		-- WHERE Method = ''''BS'''';''
		,@input_data_1_name = N'' Option_data''
		,@output_data_1_name = N'' Option_data_out'' '
	
	EXEC(@sql)   
END

