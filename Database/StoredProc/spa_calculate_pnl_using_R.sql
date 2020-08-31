IF OBJECT_ID('spa_calculate_pnl_using_R') IS NOT NULL
DROP PROCEDURE [dbo].[spa_calculate_pnl_using_R]
GO

CREATE PROCEDURE [dbo].[spa_calculate_pnl_using_R]
	 @input_table_name VARCHAR(250)
	,@output_table_name VARCHAR(100)
AS
/*
	DECLARE  @input_table_name VARCHAR(250) = 'adiha_process.dbo.pnl_input_approx_farrms_admin_01F096A1_7FFF_4A49_B779_F7A58E3002BC'
	DECLARE  @output_table_name VARCHAR(100)= 'adiha_process.dbo.pnl_output_approx_farrms_admin_01F096A1_7FFF_4A49_B779_F7A58E3002BC'
--*/
	BEGIN
			DECLARE @sql VARCHAR(MAX)
			DECLARE @execute VARCHAR(1)
			DECLARE @sql_check VARCHAR(5000)
			DECLARE @sqsl NVARCHAR(1000)
			DECLARE @r VARCHAR(100)
			DECLARE @param NVARCHAR(500) = '@re VARCHAR(100) OUTPUT'
			--SET @sql_check  = 'SELECT @re = 1 FROM '+@input_table_name + ' WHERE Method = ''<<value>>'' AND attribute_type = ''f'' AND idt = ''3''' 
			SET @sql_check  = 'SELECT @re = 1 FROM '+@input_table_name + ' WHERE Method IN (<<value>>) AND IDT = ''<<IDT>>'' AND attribute_type = ''<<atbt>>'' '
			SET @sql = '
			INSERT INTO '+@output_table_name+'
			exec sp_execute_external_script  @language =N''R''    
			,@script=N''
			#----------------------------
			#--------------------------------------------------------------------------------------------
			# PnL Atrribute calculations

			PnL_explained_approx <- function(vol_prev,prem_prev,prem_cur,del_1_prev,del_2_prev,gamma_prev,vega_prev,theta_prev,rho_prev,v_prev,
						v_cur,exp_time_prev,exp_time_cur,r_prev,r_cur,spot_prev,spot_cur,curve_2,Method,Attribute_type,row_id,source_deal_header_id,
						source_deal_detail_id,curve_id,term_start)
			{
				npt <- nrow(Option_data)
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
				Gamma_pnl1=matrix(0,nrow=npt,ncol=1)
				Gamma_pnl2=matrix(0,nrow=npt,ncol=1)
				Vega_pnl1=matrix(0,nrow=npt,ncol=1)
				Vega_pnl2=matrix(0,nrow=npt,ncol=1)
				
				Price_changed_MTM=matrix(0,nrow=npt,ncol=1)
				for (ii in 1:npt)
				{
					Delta_pnl1[ii] <- price_change[ii]*volume[ii]*del_1_prev[ii]
					Price_changed_MTM[ii] <- Delta_pnl1[ii]
					if (is.null(curve_2[ii])== FALSE)
					{
						Delta_pnl2[ii] <- price_change[ii]*volume[ii]*del_2_prev[ii]
						Price_changed_MTM[ii] <- Delta_pnl1[ii] + Delta_pnl2[ii]
					}
				}
			# Other Greeks
			pnl_all <-matrix(NA,nrow=npt,ncol=1); prev_MTM <-matrix(NA,nrow=npt,ncol=1);
			cur_MTM <-matrix(NA,nrow=npt,ncol=1);bal <-matrix(NA,nrow=npt,ncol=1)
			#-------------------------------------------------------------------
			#Vega_pnl1  <- (v_cur-v_prev)*vega_prev*volume
			Theta_pnl <- (exp_time_cur-exp_time_prev)*theta_prev*volume
			Rho_pnl <- (r_cur-r_prev)*rho_prev*volume
			Gamma_pnl1 <- 0.5*(price_change)^2*gamma_prev*volume
          
			#pnl_all <- Delta_pnl1+Delta_pnl2+Gamma_pnl1+Gamma_pnl2+Vega_pnl1+Vega_pnl2+Theta_pnl+Rho_pnl
            Vega_pnl1 <- prem_change - Price_changed_MTM-Gamma_pnl1-Theta_pnl
			pnl_all <- Delta_pnl1+Delta_pnl2+Gamma_pnl1+Gamma_pnl2+Vega_pnl1+Vega_pnl2+Theta_pnl+Rho_pnl
			#
			prev_MTM <- prem_prev*volume
			cur_MTM <- prem_cur*volume
			bal <- prem_change-pnl_all
          
			PnL_Atrributes <- data.frame(row_id,source_deal_header_id,
						source_deal_detail_id,curve_id,term_start,prev_MTM,rep(0,length.out=npt),rep(0,length.out=npt),rep(0,length.out=npt),rep(0,length.out=npt),
									Price_changed_MTM,Delta_pnl1,Delta_pnl2,Gamma_pnl1,Gamma_pnl2,Vega_pnl1,Vega_pnl2,Theta_pnl,
									Rho_pnl,bal,cur_MTM,rep("USD",length.out=npt),Method,Attribute_type,Option_data[,26],Option_data[,27])
        
			return(PnL_Atrributes)       
			}

			#----------------------Performing simulations-------------------
			vopt <- PnL_explained_approx(Option_data[,1],Option_data[,2],Option_data[,3],Option_data[,4],Option_data[,5],
							Option_data[,6],Option_data[,7],Option_data[,8],Option_data[,9],Option_data[,10],
							Option_data[,11],Option_data[,12],Option_data[,13],Option_data[,14],Option_data[,15],
							Option_data[,16],Option_data[,17],Option_data[,18],Option_data[,19],Option_data[,20],Option_data[,21],
							Option_data[,22],Option_data[,23],Option_data[,24],Option_data[,25])
							
			Option_data_out <- vopt''   
			,@input_data_1 =N''SELECT  
			vol_prev,prem_prev,prem_cur,del_1_prev,del_2_prev,gamma_prev,vega_prev,theta_prev,rho_prev,v_prev,
			v_cur,exp_time_prev,exp_time_cur,r_prev,r_cur,spot_prev,spot_cur,curve_2,Method,Attribute_type,row_id,source_deal_header_id,
						source_deal_detail_id,curve_id,term_start,idt,excercise_type
			FROM ' +  @input_table_name
			 + '
			WHERE Method IN (''''45500'''',''''45501'''',''''45502'''') AND IDT = ''''2'''' AND Attribute_type = ''''a''''; '' 
			,@input_data_1_name = N'' Option_data''
			,@output_data_1_name = N'' Option_data_out'' '
			SET @r  = 0 
			SET @sqsl = REPLACE(@sql_check,'<<value>>','45500,45501,45502')
			SET @sqsl = REPLACE(@sqsl,'<<IDT>>','2')
			SET @sqsl = REPLACE(@sqsl,'<<atbt>>','a')
			
			EXEC sp_executesql @sqsl,@param,@re =@r  OUT
			IF @r = 1 
			BEGIN
			
				EXEC(@sql)
			END 

			
			
			---- spa_calculate_Pnl_full_evalualtion_vanill_BS76

			SET @sql_check  = 'SELECT @re = 1 FROM '+@input_table_name + ' WHERE Method IN (<<value>>) AND IDT =''<<IDT>>'' AND attribute_type = ''<<atbt>>'' AND excercise_type = ''<<oet>>'' '
			SET @sql = '
		
			INSERT INTO '+@output_table_name+'
			exec sp_execute_external_script  @language =N''R''    
			,@script=N''
			#----------------------------
			#--------------------------------------------------------------------------------------------
			# PnL Atrribute calculations

			PnL_explained_full_evaluation_vanilla <- function(vol_prev,prem_prev,prem_cur,del_1_prev,del_2_prev,gamma_prev,vega_prev,theta_prev,rho_prev,v_prev,
							v_cur,exp_time_prev,exp_time_cur,r_prev,r_cur,spot_prev,spot_cur,strike_prev,cp,curve_2,Method,Attribute_type,row_id,source_deal_header_id,
						    source_deal_detail_id,curve_id,term_start)
			{
			npt <- nrow(Option_data)
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
		    Gamma_pnl1=matrix(0,nrow=npt,ncol=1)
			Gamma_pnl2=matrix(0,nrow=npt,ncol=1)
			Vega_pnl1=matrix(0,nrow=npt,ncol=1)
			Vega_pnl2=matrix(0,nrow=npt,ncol=1)
			Theta_pnl=matrix(0,nrow=npt,ncol=1)
			Rho_pnl=matrix(0,nrow=npt,ncol=1)
			Price_changed_MTM=matrix(0,nrow=npt,ncol=1)
					for (ii in 1:npt)
					{
					Delta_pnl1[ii] <- price_change[ii]*volume[ii]*del_1_prev[ii]
					Price_changed_MTM[ii] <- Delta_pnl1[ii]
					if (is.null(curve_2[ii])== FALSE)
					{
						Delta_pnl2[ii] <- price_change[ii]*volume[ii]*del_2_prev[ii]
						Price_changed_MTM[ii] <- Delta_pnl1[ii] + Delta_pnl2[ii]
					}
					}			
			#------------------------------------------------------
			# Functions related to single asset option calculation 
			# Black- Scholes 76 method 
					VanilaOption <- function(F1, K, v, r, tau, cp){ 
                      
						d1 <- (log(F1/K) + (0.5*v^2)*tau)/(v*sqrt(tau)) 
						d2 <- d1 - v*sqrt(tau) 
                      
						# calculation of options 
						v_options <- ifelse(cp == "c", (F1*pnorm(d1)*exp(-r*tau) - K*exp(-r*tau)*pnorm(d2)), 
											(K*exp(-r*tau)*pnorm(-d2) - F1*pnorm(-d1)*exp(-r*tau))) 
						return(v_options) 
					} 
			#-----------------------------------------------------
			pnl_all <-matrix(NA,nrow=npt,ncol=1); prev_MTM <-matrix(NA,nrow=npt,ncol=1);
			cur_MTM <-matrix(NA,nrow=npt,ncol=1);bal <-matrix(NA,nrow=npt,ncol=1)
			
			#-------------Calculation of Gamma_Pnl---------------------------
			P1_prem_g <- prem_prev
			F1 <-as.numeric(spot_cur);K<-as.numeric(strike_prev);v<-as.numeric(v_prev); r<-as.numeric(r_prev); tau<-as.numeric(exp_time_prev) 
			vspopt <- VanilaOption(F1, K, v, r, tau, cp)
        
			P2_prem_g<- vspopt 
			Gamma_pnl1 <- (P2_prem_g-P1_prem_g)*volume-Price_changed_MTM
        
			#-------------Calculation of Theta_Pnl----------------------------
			F1 <-as.numeric(spot_cur);K<-as.numeric(strike_prev);v<-as.numeric(v_prev); r<-as.numeric(r_prev); tau<-as.numeric(exp_time_cur)
			vspopt <- VanilaOption(F1, K, v, r, tau, cp)
			P2_prem_t <- vspopt
			P1_prem_t <- P2_prem_g # P1 of 
			Theta_pnl <- (P2_prem_t-P1_prem_t)*volume
        
			#-------------Calculation of Vega_Pnl----------------------------
			P1_prem_v <- P2_prem_t # P1 of Vega is P2 of Theta
			P2_prem_v <- prem_cur
			Vega_pnl1 <- (P2_prem_v-P1_prem_v)*volume
        
			#-------------Calculation of Rho_Pnl----------------------------
			P1_prem_r <- prem_prev
			#F1 <-as.numeric(spot_prev);K<-as.numeric(strike_prev);v<-as.numeric(v_prev); r<-as.numeric(r_cur); tau<-as.numeric(exp_time_prev)
			#vspopt <- VanilaOption(F1, K, v, r, tau, cp)
			# P2_prem_r<- vspopt 
			P2_prem_r<- prem_prev
        
			#Rho_pnl <- round((P2_prem_r-P1_prem_r)*volume,digits=3)
			Rho_pnl <- (r_cur-r_prev)*rho_prev*volume
			#--------------------------------------------
        
			pnl_all <- Delta_pnl1+Delta_pnl2+Gamma_pnl1+Gamma_pnl2+Vega_pnl1+Vega_pnl2+Theta_pnl+Rho_pnl
        
			prev_MTM <- prem_prev*volume
			cur_MTM <- prem_cur*volume
			bal <- round(prem_change-pnl_all,digits=3)

			PnL_Atrributes <- data.frame(row_id,source_deal_header_id,
						source_deal_detail_id,curve_id,term_start,prev_MTM,rep(0,length.out=npt),rep(0,length.out=npt),rep(0,length.out=npt),rep(0,length.out=npt),
				        Price_changed_MTM,Delta_pnl1,Delta_pnl2,Gamma_pnl1,Gamma_pnl2,Vega_pnl1,Vega_pnl2,Theta_pnl,
				        Rho_pnl,bal,cur_MTM,rep("USD",length.out=npt),Method,Attribute_type,
						Option_data[,28],Option_data[,29])   
				return(PnL_Atrributes)
			#}
			}

			#----------------------Performing simulations-------------------
			vopt <- PnL_explained_full_evaluation_vanilla(Option_data[,1],Option_data[,2],Option_data[,3],Option_data[,4],Option_data[,5],
								Option_data[,6],Option_data[,7],Option_data[,8],Option_data[,9],Option_data[,10],
								Option_data[,11],Option_data[,12],Option_data[,13],Option_data[,14],Option_data[,15],
								Option_data[,16],Option_data[,17],Option_data[,18],Option_data[,19],Option_data[,20],Option_data[,21],
								Option_data[,22],Option_data[,23],Option_data[,24],Option_data[,25],Option_data[,26],Option_data[,27])
			Option_data_out <- vopt''   
			,@input_data_1 =N''SELECT  
			vol_prev,prem_prev,prem_cur,del_1_prev,del_2_prev,gamma_prev,vega_prev,theta_prev,rho_prev,v_prev,
			v_cur,exp_time_prev,exp_time_cur,r_prev,r_cur,spot_prev,spot_cur,strike_prev,cp,curve_2,Method,Attribute_type,row_id,source_deal_header_id,
						source_deal_detail_id,curve_id,term_start,idt,excercise_type
			FROM  '+@input_table_name+'
			WHERE Method = ''''45500'''' AND idt = ''''2'''' 
			AND Attribute_type = ''''f'''' AND excercise_type = ''''e'''' ;'' 
			,@input_data_1_name = N'' Option_data''
			,@output_data_1_name = N'' Option_data_out'' '

			SET @r  = 0 
			SET @sqsl = REPLACE(@sql_check,'<<value>>','45500')
			SET @sqsl = REPLACE(@sqsl,'<<IDT>>','2')
			SET @sqsl = REPLACE(@sqsl,'<<atbt>>','f')
			SET @sqsl = REPLACE(@sqsl,'<<oet>>','e')	
			EXEC sp_executesql @sqsl,@param,@re =@r  OUT
			IF @r = 1 
			BEGIN
				EXEC(@sql)
			END 
			

			-- spa_calculate_Pnl_full_evalualtion_vanill_BT
			SET @sql_check  = 'SELECT @re = 1 FROM '+@input_table_name + ' WHERE Method IN (<<value>>) AND IDT =''<<IDT>>'' AND attribute_type = ''<<atbt>>'' '
			SET @sql = '
		
			INSERT INTO '+@output_table_name+'
			exec sp_execute_external_script  @language =N''R''    
			,@script=N''
			#----------------------------
			#--------------------------------------------------------------------------------------------
			# PnL Atrribute calculations
		
			PnL_explained_full_evaluation_vanilla_BT <- function(vol_prev,prem_prev,prem_cur,del_1_prev,del_2_prev,gamma_prev,vega_prev,theta_prev,rho_prev,v_prev,
			v_cur,exp_time_prev,exp_time_cur,r_prev,r_cur,spot_prev,spot_cur,strike_prev,cp,curve_2)
			{
			npt <- nrow(Option_data)
			M <- 25 # Binomial Steps
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
		    Gamma_pnl1=matrix(0,nrow=npt,ncol=1)
			Gamma_pnl2=matrix(0,nrow=npt,ncol=1)
			Vega_pnl1=matrix(0,nrow=npt,ncol=1)
			Vega_pnl2=matrix(0,nrow=npt,ncol=1)
			Theta_pnl=matrix(0,nrow=npt,ncol=1)
			Rho_pnl=matrix(0,nrow=npt,ncol=1)
			Price_changed_MTM=matrix(0,nrow=npt,ncol=1)
					for (ii in 1:npt)
					{
					Delta_pnl1[ii] <- price_change[ii]*volume[ii]*del_1_prev[ii]
					Price_changed_MTM[ii] <- Delta_pnl1[ii]
					if (is.null(curve_2[ii])== FALSE)
					{
						Delta_pnl2[ii] <- price_change[ii]*volume[ii]*del_2_prev[ii]
						Price_changed_MTM[ii] <- Delta_pnl1[ii] + Delta_pnl2[ii]
					}
					}

			#------------------------------------------------------
			# Functions related to single asset option calculation 
			BTOption <- function(F1, K, tau,r, v, M, cp1)
			{   
			f7 <- 1;  dt <- tau / M; v <- exp(-r * dt)
			u  <- exp(v * sqrt(dt)); d <- 1 /u
			p1  <- (exp(r * dt) - d) / (u - d)
          
			# initialise asset prices at maturity (period M)
			S <- numeric(M + 1);C1 <- numeric(M + 1) 
			S[f7+0] 	<- F1 * d^M
			for (j in 1:M){
			S[f7+j] <- S[f7+j - 1] * u / d
			}
          
			# initialise option values at maturity (period M)
			if (cp1 == "c") {
			C1 	<- pmax(S - K, 0) 
			}
			if (cp1 == "p"){
			C1 	<- pmax(K - S, 0) 
			}
          
			# step back through the tree
			for (i in seq(M-1,0,by=-1)){
			C1 <- v * (p1 * C1[(1+f7):(i+1+f7)] + (1-p1) * C1[(0+f7):(i+f7)])
			}
          
			C0 <- C1[f7+0]
			return(C0)
			}
			#-----------------------------------------------------
            pnl_all <-matrix(NA,nrow=npt,ncol=1); prev_MTM <-matrix(NA,nrow=npt,ncol=1);
			cur_MTM <-matrix(NA,nrow=npt,ncol=1);bal <-matrix(NA,nrow=npt,ncol=1)
			#-------------Calculation of Gamma_Pnl----------------------------
			for (ik in 1:npt)
			{
			P1_prem_g <- prem_prev[ik]
			F1 <-as.numeric(spot_cur[ik]);K <- as.numeric(strike_prev[ik]); v<-as.numeric(v_prev[ik]); r<-as.numeric(r_prev[ik]); tau<-as.numeric(exp_time_prev[ik]); cp1 <- cp[ik]
			BTopt <- BTOption(F1, K, tau,r, v, M, cp1)
			P2_prem_g<- BTopt;  
			Gamma_pnl1[ik] <- (P2_prem_g-P1_prem_g)*volume[ik]-Price_changed_MTM[ik]
            
			#-------------Calculation of Theta_Pnl----------------------------
			F1 <-as.numeric(spot_cur[ik]);K <- as.numeric(strike_prev[ik]); v<-as.numeric(v_prev[ik]); r<-as.numeric(r_prev[ik]); tau<-as.numeric(exp_time_cur[ik]); cp1 <- cp[ik]
			BTopt <- BTOption(F1, K, tau,r, v, M, cp1)
			P2_prem_t <- BTopt
			P1_prem_t <- P2_prem_g 
			Theta_pnl[ik] <- (P2_prem_t-P1_prem_t)*volume[ik]
          
			#-------------Calculation of Vega_Pnl----------------------------
			P1_prem_v <- P2_prem_t # P1 of Vega is P2 of Theta
			P2_prem_v <- prem_cur[ik]
			Vega_pnl1[ik] <- (P2_prem_v-P1_prem_v)*volume[ik]
          
			#-------------Calculation of Rho_Pnl----------------------------
			P1_prem_r <- prem_prev[ik]
			F1 <-as.numeric(spot_prev[ik]);K <- as.numeric(strike_prev[ik]); v<-as.numeric(v_prev[ik]); r<-as.numeric(r_cur[ik]); tau<-as.numeric(exp_time_prev[ik]);cp1 <- cp[ik]
			BTopt <- BTOption(F1, K, tau,r, v, M, cp1)
			#P2_prem_r <- BTopt 
			P2_prem_r <- prem_prev[ik] 
			#Rho_pnl[ik] <- round((P2_prem_r-P1_prem_r)*volume[ik],digits=3)
			Rho_pnl[ik] <- (r_cur-r_prev)*rho_prev*volume[ik]
			#--------------------------------------------
          
			pnl_all[ik] <- Delta_pnl1[ik]+Delta_pnl2[ik]+Gamma_pnl1[ik]+Gamma_pnl2[ik]+Vega_pnl1[ik]+Vega_pnl2[ik]+Theta_pnl[ik]+Rho_pnl[ik]
          
			prev_MTM[ik] <- prem_prev[ik]*volume[ik]
			cur_MTM[ik] <- prem_cur[ik]*volume[ik]
			bal[ik] <- round(prem_change[ik]-pnl_all[ik],digits=3)
			}
			PnL_Atrributes <- data.frame(Option_data[,23],Option_data[,24],Option_data[,25],Option_data[,26],Option_data[,27],prev_MTM,rep(0,length.out=npt),rep(0,length.out=npt),rep(0,length.out=npt),rep(0,length.out=npt),
				Price_changed_MTM,Delta_pnl1,Delta_pnl2,Gamma_pnl1,Gamma_pnl2,Vega_pnl1,Vega_pnl2,Theta_pnl,
				Rho_pnl,bal,cur_MTM,rep("USD",length.out=npt),Option_data[,21],Option_data[,22],Option_data[,28],Option_data[,29])  
				return(PnL_Atrributes)
			}

			#----------------------Performing simulations-------------------
			vopt <- PnL_explained_full_evaluation_vanilla_BT(Option_data[,1],Option_data[,2],Option_data[,3],Option_data[,4],Option_data[,5],
								Option_data[,6],Option_data[,7],Option_data[,8],Option_data[,9],Option_data[,10],
								Option_data[,11],Option_data[,12],Option_data[,13],Option_data[,14],Option_data[,15],
								Option_data[,16],Option_data[,17],Option_data[,18],Option_data[,19],Option_data[,20])
			Option_data_out <- vopt''   
			,@input_data_1 =N''SELECT  
			vol_prev,prem_prev,prem_cur,del_1_prev,del_2_prev,gamma_prev,vega_prev,theta_prev,rho_prev,v_prev,
			v_cur,exp_time_prev,exp_time_cur,r_prev,r_cur,spot_prev,spot_cur,strike_prev,cp,curve_2,Method,Attribute_type,row_id,source_deal_header_id,
						source_deal_detail_id,curve_id,term_start,idt,excercise_type
			FROM  '+@input_table_name+'
			WHERE Method=''''45501'''' AND idt = ''''2''''
			AND Attribute_type=''''f'''';'' 
			,@input_data_1_name = N'' Option_data''
			,@output_data_1_name = N'' Option_data_out'' '

			SET @r  = 0 

			SET @sqsl = REPLACE(@sql_check,'<<value>>','45501')
			SET @sqsl = REPLACE(@sqsl,'<<IDT>>','2')
			SET @sqsl = REPLACE(@sqsl,'<<atbt>>','f')
			
			EXEC sp_executesql @sqsl,@param,@re =@r  OUT
			IF @r = 1 
			BEGIN
				EXEC(@sql)
			END 
			
	--			ELSE PRINT 1
		
			-- spa_calculate_Pnl_full_evalualtion_vanill_EUMC
			
			SET @sql_check  = 'SELECT @re = 1 FROM '+@input_table_name + ' WHERE Method IN (<<value>>) AND IDT =''<<IDT>>'' AND attribute_type = ''<<atbt>>'' AND excercise_type = ''<<oet>>'' '
			SET @sql = '
		
			INSERT INTO '+@output_table_name+'
			exec sp_execute_external_script  @language =N''R''    
			,@script=N''
			#----------------------------
			#--------------------------------------------------------------------------------------------
			# PnL Atrribute calculations
		
			PnL_explained_full_evaluation_vanilla_EUMC <- function(vol_prev,prem_prev,prem_cur,del_1_prev,del_2_prev,gamma_prev,vega_prev,theta_prev,rho_prev,v_prev,
							v_cur,exp_time_prev,exp_time_cur,r_prev,r_cur,spot_prev,spot_cur,strike_prev,cp,curve_2,Method,Attribute_type,row_id,source_deal_header_id,
						source_deal_detail_id,curve_id,term_start)
			{
			npt <- nrow(Option_data)
			n<- 10000; # Number of generated paths for Monte Carlo
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
		    Gamma_pnl1=matrix(0,nrow=npt,ncol=1)
			Gamma_pnl2=matrix(0,nrow=npt,ncol=1)
			Vega_pnl1=matrix(0,nrow=npt,ncol=1)
			Vega_pnl2=matrix(0,nrow=npt,ncol=1)
			Theta_pnl=matrix(0,nrow=npt,ncol=1)
			Rho_pnl=matrix(0,nrow=npt,ncol=1)
			Price_changed_MTM=matrix(0,nrow=npt,ncol=1)
					for (ii in 1:npt)
					{
					Delta_pnl1[ii] <- price_change[ii]*volume[ii]*del_1_prev[ii]
					Price_changed_MTM[ii] <- Delta_pnl1[ii]
					if (is.null(curve_2[ii])== FALSE)
					{
						Delta_pnl2[ii] <- price_change[ii]*volume[ii]*del_2_prev[ii]
						Price_changed_MTM[ii] <- Delta_pnl1[ii] + Delta_pnl2[ii]
					}
					}
			#------------------------------------------------------
			# Functions related to single asset option calculation 
			# Monte Carlo method of European Put and Call options 
			EuLSM <- function(F1, v, n, K, r, tau,cp1)
			{
			if (cp1 == "p")
			{
			z <- matrix(rnorm(n),nrow=1)
			s.t <- F1*exp((r-1/2*v^2)*tau + v*(tau^0.5)*z)
			CC <- pmax(K-s.t,0)
			payoffeu <- exp(-r*tau)*CC
			payoffeu_mean <- mean(payoffeu)
			}
			if (cp1 == "c")
			{
			z <- matrix(rnorm(n),nrow=1)
			s.t <- F1*exp((r-1/2*v^2)*tau + v*(tau^0.5)*z)
			CC <- pmax(s.t-K,0)
			payoffeu <- exp(-r*tau)*CC
			payoffeu_mean <- mean(payoffeu)
			}
			return(payoffeu_mean)
			}
			#-----------------------------------------------------
        
			pnl_all <-matrix(NA,nrow=npt,ncol=1); prev_MTM <-matrix(NA,nrow=npt,ncol=1);
			cur_MTM <-matrix(NA,nrow=npt,ncol=1);bal <-matrix(NA,nrow=npt,ncol=1)
			#-------------Calculation of Gamma_Pnl----------------------------
			for (ik in 1:npt)
			{
			P1_prem_g <- prem_prev[ik]
			F1 <-as.numeric(spot_cur[ik]);K <- as.numeric(strike_prev[ik]); v<-as.numeric(v_prev[ik]); r<-as.numeric(r_prev[ik]); tau<-as.numeric(exp_time_prev[ik])
			Euopt <- EuLSM(F1, v, n, K, r, tau,cp[ik])
			P2_prem_g<- Euopt; 
			Gamma_pnl1[ik] <- (P2_prem_g-P1_prem_g)*volume[ik]-Price_changed_MTM[ik]
          
			#-------------Calculation of Theta_Pnl----------------------------
			F1 <-as.numeric(spot_cur[ik]);K <- as.numeric(strike_prev[ik]); v<-as.numeric(v_prev[ik]); r<-as.numeric(r_prev[ik]); tau<-as.numeric(exp_time_cur[ik])
			Euopt <- EuLSM(F1, v, n, K, r, tau,cp[ik])
			P2_prem_t <- Euopt
			P1_prem_t <- P2_prem_g # P1 of 
			Theta_pnl[ik] <- (P2_prem_t-P1_prem_t)*volume[ik]
          
			#-------------Calculation of Vega_Pnl----------------------------
			P1_prem_v <- P2_prem_t # P1 of Vega is P2 of Theta
			P2_prem_v <- prem_cur[ik]
			Vega_pnl1[ik] <- (P2_prem_v-P1_prem_v)*volume[ik]
          
			#-------------Calculation of Rho_Pnl----------------------------
			P1_prem_r <- prem_prev[ik]
			P2_prem_r <- prem_prev[ik] # There is no interest rate change so that the Rho_pnl is zero. 
			
			# F1 <-spot_prev[ik];K <- strike_prev[ik]; v<-v_prev[ik]; r<-r_prev[ik]; tau<-exp_time_prev[ik]
			# Euopt <- EuLSM(F1, v, n, K, r, tau,cp[ik])
			# P2_prem_r<- Euopt 
			# 
			# F1 <-spot_prev[ik];K <- strike_prev[ik]; v<-v_prev[ik]; r<-r_cur[ik]; tau<-exp_time_prev[ik]
			# Euopt <- EuLSM(F1, v, n, K, r, tau,cp[ik])
			# P1_prem_r<- Euopt 
          
			#Rho_pnl[ik] <- round(P2_prem_r-P1_prem_r,digits=3)*volume[ik]
			Rho_pnl[ik] <- (r_cur-r_prev)*rho_prev*volume[ik]
			#--------------------------------------------
          
			pnl_all[ik] <- Delta_pnl1[ik]+Delta_pnl2[ik]+Gamma_pnl1[ik]+Gamma_pnl2[ik]+Vega_pnl1[ik]+Vega_pnl2[ik]+Theta_pnl[ik]+Rho_pnl[ik]
          
			prev_MTM[ik] <- prem_prev[ik]*volume[ik]
			cur_MTM[ik] <- prem_cur[ik]*volume[ik]
			bal[ik] <- round(prem_change[ik]-pnl_all[ik],digits=3)
			}
			PnL_Atrributes <- data.frame(row_id,source_deal_header_id,
						source_deal_detail_id,curve_id,term_start,prev_MTM,rep(0,length.out=npt),rep(0,length.out=npt),rep(0,length.out=npt),rep(0,length.out=npt),
				Price_changed_MTM,Delta_pnl1,Delta_pnl2,Gamma_pnl1,Gamma_pnl2,Vega_pnl1,Vega_pnl2,Theta_pnl,
				Rho_pnl,bal,cur_MTM,rep("USD",length.out=npt),Method,Attribute_type,Option_data[,28],Option_data[,29])   
				return(PnL_Atrributes)
			}

			#----------------------Performing simulations-------------------
			vopt <- PnL_explained_full_evaluation_vanilla_EUMC(Option_data[,1],Option_data[,2],Option_data[,3],Option_data[,4],Option_data[,5],
								Option_data[,6],Option_data[,7],Option_data[,8],Option_data[,9],Option_data[,10],
								Option_data[,11],Option_data[,12],Option_data[,13],Option_data[,14],Option_data[,15],
								Option_data[,16],Option_data[,17],Option_data[,18],Option_data[,19],Option_data[,20],Option_data[,21],
								Option_data[,22],Option_data[,23],Option_data[,24],Option_data[,25],Option_data[,26],Option_data[,27])
			Option_data_out <- vopt''   
			,@input_data_1 =N''SELECT  
			vol_prev,prem_prev,prem_cur,del_1_prev,del_2_prev,gamma_prev,vega_prev,theta_prev,rho_prev,v_prev,
			v_cur,exp_time_prev,exp_time_cur,r_prev,r_cur,spot_prev,spot_cur,strike_prev,cp,curve_2,Method,Attribute_type,row_id,source_deal_header_id,
						source_deal_detail_id,curve_id,term_start,idt,excercise_type
			FROM  '+@input_table_name+'
			WHERE Method = ''''45502'''' AND idt = ''''2'''' AND excercise_type = ''''e'''' 
			AND Attribute_type=''''f'''';'' 
			,@input_data_1_name = N'' Option_data''
			,@output_data_1_name = N'' Option_data_out'' '

			SET @r  = 0 
			SET @sqsl = REPLACE(@sql_check,'<<value>>','45502')
			SET @sqsl = REPLACE(@sqsl,'<<IDT>>','2')
			SET @sqsl = REPLACE(@sqsl,'<<atbt>>','f')
			SET @sqsl = REPLACE(@sqsl,'<<oet>>','e')
			EXEC sp_executesql @sqsl,@param,@re =@r  OUT
			IF @r = 1 
			BEGIN
				EXEC(@sql)
			END 
			
			-- spa_calculate_Pnl_full_evalualtion_vanill_USMC
			SET @sql_check  = 'SELECT @re = 1 FROM '+@input_table_name + ' WHERE Method IN (<<value>>) AND IDT =''<<IDT>>'' AND attribute_type = ''<<atbt>>'' AND excercise_type = ''<<oet>>'' '
			SET @sql = '
		
			INSERT INTO '+@output_table_name+'
			exec sp_execute_external_script  @language =N''R''    
			,@script=N''
			#----------------------------
			#--------------------------------------------------------------------------------------------
			# PnL Atrribute calculations
		
			PnL_explained_full_evaluation_vanilla_USMC <- function(vol_prev,prem_prev,prem_cur,del_1_prev,del_2_prev,gamma_prev,vega_prev,theta_prev,rho_prev,v_prev,
						v_cur,exp_time_prev,exp_time_cur,r_prev,r_cur,spot_prev,spot_cur,strike_prev,cp,curve_2,Method,Attribute_type,row_id,source_deal_header_id,
						source_deal_detail_id,curve_id,term_start)
			{
			npt <- nrow(Option_data)
			n<- 10000; # Number of generated paths for Monte Carlo
			d<- 10 # number of time steps per path
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
		    Gamma_pnl1=matrix(0,nrow=npt,ncol=1)
			Gamma_pnl2=matrix(0,nrow=npt,ncol=1)
			Vega_pnl1=matrix(0,nrow=npt,ncol=1)
			Vega_pnl2=matrix(0,nrow=npt,ncol=1)
			Theta_pnl=matrix(0,nrow=npt,ncol=1)
			Rho_pnl=matrix(0,nrow=npt,ncol=1)
			Price_changed_MTM=matrix(0,nrow=npt,ncol=1)
					for (ii in 1:npt)
					{
					Delta_pnl1[ii] <- price_change[ii]*volume[ii]*del_1_prev[ii]
					Price_changed_MTM[ii] <- Delta_pnl1[ii]
					if (is.null(curve_2[ii])== FALSE)
					{
						Delta_pnl2[ii] <- price_change[ii]*volume[ii]*del_2_prev[ii]
						Price_changed_MTM[ii] <- Delta_pnl1[ii] + Delta_pnl2[ii]
					}
					}
			#------------------------------------------------------
			# Function related to single asset option calculation 
			library(stats)
			library(Matrix)
			# Least square Monte Carlo method of American Put and call options 
			USLSM <- function(F1, v, n,d,K, r, M_T,cp1)
			{
				if (cp1 == "p")
				{
				dt <- M_T/d
				z <- matrix(rnorm(n),nrow=1)
				s.t <- F1*exp((r-1/2*v^2)*M_T + v*(M_T^0.5)*z)
				CC <- pmax(K-s.t,0)
				#payoffeu <- exp(-r*M_T)*CC
				#payoffeu_mean <- mean(payoffeu)
            
					for(ii in (d-1):1)
					{
						z <- matrix(rnorm(n),nrow=1)
						mean1 <- (log(K)+ii*log(s.t))/(ii+1)
						vol1 <- (ii*dt/(ii+1))^0.5*z
						s.t_1 <- exp(mean1+v*vol1)
              
						CE <- pmax(K-s.t_1,0)
						idx <- (1:n)[CE>0]
              
						if (length(idx)> round(0.002*n,0)) # to avoid divergence 
						{
						discountedCC <- CC[idx]*exp(-r*dt)
						basis1 <- s.t_1[idx]
						basis2 <- s.t_1[idx]^2
                
						p <- glm(discountedCC ~ basis1+basis2)$coefficients
						estimatedCC <- p[1]+p[2]*basis1 + p[3]*basis2 
						EF <- rep(0,n)
						EF[idx] <- (CE[idx]>estimatedCC)
						CC <- (EF==0)*CC*exp(-r*ii*dt)+(EF==1)*CE
                
						s.t <- s.t_1
					}
              
				}
					payoff <- CC *exp(-r*dt)
					payoff.c <- payoff
					usprice.c <- mean(payoff.c)
					#se.c <- sd(payoff.c)/sqrt(n)
					return(usprice.c) 
				}
				if (cp1 == "c")
				{
				dt <- M_T/d
				z <- matrix(rnorm(n),nrow=1)
				s.t <- K*exp((r-1/2*v^2)*M_T + v*(M_T^0.5)*z)
				CC <- pmax(s.t-K,0)
				#payoffeu <- exp(-r*M_T)*CC
				#payoffeu_mean <- mean(payoffeu)
            
					for(ii in (d-1):1)
					{
						z <- matrix(rnorm(n),nrow=1)
						mean1 <- (log(F1)+ii*log(s.t))/(ii+1)
						vol1 <- (ii*dt/(ii+1))^0.5*z
						s.t_1 <- exp(mean1+v*vol1)
              
						CE <- pmax(s.t_1-K,0)
						idx <- (1:n)[CE>0]
              
							if (length(idx)> round(0.002*n,0)) # to avoid divergence 
							{
							discountedCC <- CC[idx]*exp(-r*dt)
							basis1 <- s.t_1[idx]
							basis2 <- s.t_1[idx]^2
                
							p <- glm(discountedCC ~ basis1+basis2)$coefficients
							estimatedCC <- p[1]+p[2]*basis1 + p[3]*basis2 
							EF <- rep(0,n)
							EF[idx] <- (CE[idx]>estimatedCC)
							CC <- (EF==0)*CC*exp(-r*ii*dt)+(EF==1)*CE
                
							s.t <- s.t_1
							}
              
					 }
					payoff <- CC *exp(-r*dt)
					payoff.c <- payoff
					usprice.c <- mean(payoff.c)
					#se.c <- sd(payoff.c)/sqrt(n)
					#-------------------------------------  
					return(usprice.c)
				}
			}
			#-----------------------------------------------------
        
			pnl_all <-matrix(NA,nrow=npt,ncol=1); prev_MTM <-matrix(NA,nrow=npt,ncol=1);
			cur_MTM <-matrix(NA,nrow=npt,ncol=1);bal <-matrix(NA,nrow=npt,ncol=1)
			#-------------Calculation of Gamma_Pnl----------------------------
				for (ik in 1:npt)
				{
				P1_prem_g <- prem_prev[ik]
				F1 <-as.numeric(spot_cur[ik]);K <- as.numeric(strike_prev[ik]); v<-as.numeric(v_prev[ik]); r<-as.numeric(r_prev[ik]); tau<-as.numeric(exp_time_prev[ik])
				usopt <- USLSM(F1, v, n, d, K, r, tau,cp[ik])
				P2_prem_g<- usopt; 
				Gamma_pnl1[ik] <- (P2_prem_g-P1_prem_g)*volume[ik]-Price_changed_MTM[ik]
          
				#-------------Calculation of Theta_Pnl----------------------------
				F1 <-as.numeric(spot_cur[ik]);K <- as.numeric(strike_prev[ik]); v<-as.numeric(v_prev[ik]); r<-as.numeric(r_prev[ik]); tau<-as.numeric(exp_time_cur[ik])
				usopt <- USLSM(F1, v, n, d, K, r, tau,cp[ik])
				P2_prem_t <- usopt
				P1_prem_t <- P2_prem_g # P1 of 
				Theta_pnl[ik] <- (P2_prem_t-P1_prem_t)*volume[ik]
          
				#-------------Calculation of Vega_Pnl----------------------------
				P1_prem_v <- P2_prem_t # P1 of Vega is P2 of Theta
				P2_prem_v <- prem_cur[ik]
				Vega_pnl1[ik] <- (P2_prem_v-P1_prem_v)*volume[ik]
          
				#-------------Calculation of Rho_Pnl----------------------------
				P1_prem_r <- prem_prev[ik]
				P2_prem_r <- prem_prev[ik] # There is no interest rate change so that the Rho_pnl is zero. 
				# F1 <-spot_prev[ik];K <- strike_prev[ik]; v<-v_prev[ik]; r<-r_prev[ik]; tau<-exp_time_prev[ik]
				# usopt <- USLSM(F1, v, n, d, K, r, tau,cp[ik])
				# P2_prem_r<- usopt 
				# 
				# F1 <-spot_prev[ik];K <- strike_prev[ik]; v<-v_prev[ik]; r<-r_cur[ik]; tau<-exp_time_prev[ik]
				# usopt <- USLSM(F1, v, n, d, K, r, tau,cp[ik])
				# P1_prem_r<- usopt 
          
				# Rho_pnl[ik] <- round(P2_prem_r-P1_prem_r,digits=3)*volume[ik]
				Rho_pnl[ik] <- (r_cur-r_prev)*rho_prev*volume[ik]
				#--------------------------------------------
          
				pnl_all[ik] <- Delta_pnl1[ik]+Delta_pnl2[ik]+Gamma_pnl1[ik]+Gamma_pnl2[ik]+Vega_pnl1[ik]+Vega_pnl2[ik]+Theta_pnl[ik]+Rho_pnl[ik]
          
				prev_MTM[ik] <- prem_prev[ik]*volume[ik]
				cur_MTM[ik] <- prem_cur[ik]*volume[ik]
				bal[ik] <- round(prem_change[ik]-pnl_all[ik],digits=3)
			}
			PnL_Atrributes <- data.frame(row_id,source_deal_header_id,
						source_deal_detail_id,curve_id,term_start,prev_MTM,rep(0,length.out=npt),rep(0,length.out=npt),rep(0,length.out=npt),rep(0,length.out=npt),
				Price_changed_MTM,Delta_pnl1,Delta_pnl2,Gamma_pnl1,Gamma_pnl2,Vega_pnl1,Vega_pnl2,Theta_pnl,
				Rho_pnl,bal,cur_MTM,rep("USD",length.out=npt),Method,Attribute_type,Option_data[,28],Option_data[,29])   
				return(PnL_Atrributes)
		}

			#----------------------Performing simulations-------------------
			vopt <- PnL_explained_full_evaluation_vanilla_USMC(Option_data[,1],Option_data[,2],Option_data[,3],Option_data[,4],Option_data[,5],
								Option_data[,6],Option_data[,7],Option_data[,8],Option_data[,9],Option_data[,10],
								Option_data[,11],Option_data[,12],Option_data[,13],Option_data[,14],Option_data[,15],
								Option_data[,16],Option_data[,17],Option_data[,18],Option_data[,19],Option_data[,20],Option_data[,21],
								Option_data[,22],Option_data[,23],Option_data[,24],Option_data[,25],Option_data[,26],Option_data[,27])
			Option_data_out <- vopt''   
			,@input_data_1 =N''SELECT  
			vol_prev,prem_prev,prem_cur,del_1_prev,del_2_prev,gamma_prev,vega_prev,theta_prev,rho_prev,v_prev,
							v_cur,exp_time_prev,exp_time_cur,r_prev,r_cur,spot_prev,spot_cur,strike_prev,cp,curve_2,Method,Attribute_type,row_id,source_deal_header_id,
						source_deal_detail_id,curve_id,term_start,idt,excercise_type
			FROM  '+@input_table_name+'
			WHERE Method = ''''45502''''  AND idt = ''''2'''' AND excercise_type = ''''a'''' 
			AND Attribute_type=''''f'''';'' 
			,@input_data_1_name = N'' Option_data''
			,@output_data_1_name = N'' Option_data_out'' '
			
			SET @r  = 0 
			SET @sqsl = REPLACE(@sql_check,'<<value>>','45502')
			SET @sqsl = REPLACE(@sqsl,'<<IDT>>','2')
			SET @sqsl = REPLACE(@sqsl,'<<atbt>>','f')
			SET @sqsl = REPLACE(@sqsl,'<<oet>>','a')
			EXEC sp_executesql @sqsl,@param,@re =@r  OUT
			IF @r = 1 
			BEGIN
			EXEC(@sql)
			END
			

END




	