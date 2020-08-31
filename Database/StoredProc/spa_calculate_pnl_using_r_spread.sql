IF OBJECT_ID('[dbo].[spa_calculate_pnl_using_R_Spread]') IS NOT NULL
	DROP PROC [dbo].[spa_calculate_pnl_using_R_Spread]
GO
CREATE PROCEDURE [dbo].[spa_calculate_pnl_using_R_Spread]
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

	SET @sql_check  = 'SELECT @re = 1 FROM '+@input_table_name + ' WHERE Method = ''<<value>>'''
	--print('v_bs')
--spa_calculate_options_Vanilla_BS
	SET @sql = '
		INSERT INTO '+@output_table_name+'
		exec sp_execute_external_script  @language =N''R''    
		,@script=N''
		#----------------------------
		npt <- nrow(Option_data);
		#cp <- rep("c",npt);
		#Deals <- c(1:npt);
		#-----------------------------
		 # Plain Vanilla Options 
		 v_gamma2 <- rep("",npt);v_vega2 <- rep("",npt);v_theta2 <- rep("",npt);v_rho2 <- rep("",npt);
		 # General Black- Scholes method 
		VanilaOption <- function(F1, K, v, r, tau, cp,Method,row_id,Attribute_type){ 
  
		  d1 <- (log(F1/K) + (0.5*v^2)*tau)/(v*sqrt(tau)) 
		  d2 <- d1 - v*sqrt(tau) 
  
		  # calculation of options 
		  v_options <- ifelse(cp == "c", (F1*pnorm(d1)*exp(-r*tau) - K*exp(-r*tau)*pnorm(d2)), 
							  (K*exp(-r*tau)*pnorm(-d2) - F1*pnorm(-d1)*exp(-r*tau))) 
  
		  # calculation of Greeks 
  
		  v_delta1 <- ifelse(cp == "c", pnorm(d1)*exp(-r*tau),(-1)*pnorm(-d1)*exp(-r*tau))
  
		  v_delta2 <- ifelse(cp == "c", (-1)*pnorm(d2)*exp(-r*tau),pnorm(-d2)*exp(-r*tau))
  
		  v_gamma <-  dnorm(d1)*exp(-r*tau)/(F1*v*sqrt(tau)) 
  
		  v_vega  <- dnorm(d1)*F1*sqrt(tau)*exp(-r*tau)
  
		 # v_theta <- ifelse(cp == "c", -((-F1*dnorm(d1)*exp(-r*tau)*v)/(2*sqrt(tau)) + r*F1* exp(-r*tau) * pnorm(d1)- r*K* exp(-r*tau) * pnorm(d2)),-((-F1*dnorm(d1)*v*exp(-r*tau))/(2*sqrt(tau))-r*F1* exp(-r*tau) * pnorm(-d1) +r*K* exp(-r*tau) * pnorm(-d2))) 
		 #  v_theta <- ifelse(cp == "c", ((-F1*dnorm(d1)*v)/(2*sqrt(tau))- r*K* exp(-r*tau) * pnorm(d2)),((-F1*dnorm(d1)*v)/(2*sqrt(tau))-r*K* exp(-r*tau) * pnorm(-d2)))
		  v_theta <- ifelse(cp == "c", (-F1*dnorm(d1)*exp(-r*tau)*v)/(2*sqrt(tau)) +r*F1* exp(-r*tau) * pnorm(d1) - r*K* exp(-r*tau) * pnorm(d2),(-F1*dnorm(d1)*v*exp(-r*tau))/(2*sqrt(tau))-r*F1* exp(-r*tau) * pnorm(-d1) +r*K* exp(-r*tau) * pnorm(-d2))
		  v_Rho   <-  ifelse(cp == "c", K*tau*exp(-r*tau)*pnorm(d2),(-K)*tau*exp(-r*tau)*pnorm(-d2))
  
		  v_ops <- data.frame(row_id,v_options,v_delta1,v_gamma,v_vega,v_theta,v_Rho,v_delta2,v_gamma2,v_vega2,v_theta2,v_rho2,Method,Attribute_type)
  
		 # return(v_ops) 
		} 

		#----------------------Performing simulations-------------------
		vspopt <- VanilaOption(Option_data[,1],Option_data[,3],Option_data[,4],Option_data[,6],Option_data[,7],Option_data[,8],Option_data[,9],Option_data[,10],Option_data[,11])
		 Option_data_out <- vspopt
		 ''     
		,@input_data_1 =N''SELECT  
	    S1,S2,X,V1,V2,R,T,CallPutFlag, Method,row_id,Attribute_type
		FROM '+@input_table_name+' 
		WHERE Method = ''''45500'''';''

		,@input_data_1_name = N'' Option_data''
		,@output_data_1_name = N'' Option_data_out'' '
		
		SET @r  = 0 
		SET @sqsl = REPLACE(@sql_check,'<<value>>','45500')
		EXEC sp_executesql @sqsl,@param,@re =@r  OUT
		IF @r = 1 
		BEGIN
			EXEC(@sql)
		END 
	 
--END
--spa_calculate_options_Vanilla_BT
	SET @sql = '
	INSERT INTO '+@output_table_name+'
	exec sp_execute_external_script  @language =N''R''    
	,@script=N''
	#----------------------------

	npt <- nrow(Option_data);
	#cp <- rep("c",npt);
	#Deals <- c(1:npt);
	M = 25  # number of time steps for Binomial Tree 
	#----------------------------------------------------------------
	bt_gamma2 <- rep("",npt);bt_vega2 <- rep("",npt);bt_theta2 <- rep("",npt);bt_rho2 <- rep("",npt)
	BTOption <- function(S0, X, tau, r, sigma, M,cp,Method)
	  {   
	  f7 <- 1;  dt <- tau / M; v <- exp(-r * dt)
	  u  <- exp(sigma * sqrt(dt)); d <- 1 /u
	  p  <- (exp(r * dt) - d) / (u - d)
  
	  # initialise asset prices at maturity (period M)
	  S 		<- numeric(M + 1); 
	  S[f7+0] 	<- S0 * d^M
  
	  for (j in 1:M){
		S[f7+j] <- S[f7+j - 1] * u / d
    
	  }
  
	  # initialise option values at maturity (period M)
	  if (cp == "c") {
		C 		<- pmax(S - X, 0) 
	  }
	  if (cp == "p"){
		C 		<- pmax(X - S, 0) 
	  }
  
	  # step back through the tree
	  for (i in seq(M-1,0,by=-1)){
		C <- v * (p * C[(1+f7):(i+1+f7)] + (1-p) * C[(0+f7):(i+f7)])
		S <- S/d;
		if (i == 2) {
		  # Gamma calculation 
		  t1 <- (C[2+f7]-C[1+f7])/(S[2+f7]-S[1+f7])
		  t2 <- (C[1+f7]-C[0+f7])/(S[1+f7]-S[0+f7])
		  t3 <- 0.5*(S[2+f7]-S[0+f7])
		  GammaE <- (t1-t2)/t3
		  # Theta (aux)
		  ThetaE <- C[1+f7]
		}
		if (i==1){
		  # Delta calculation 
		  DeltaE <- (C[1+f7]-C[0+f7])/(S[1+f7]-S[0+f7])
		}
		if (i == 0){
		  # Calculation of Theta (final)
		  ThetaE <- (ThetaE-C[0+f7])/(2*dt)
		}
	  }
  
	  C0 <- C[f7+0]
	  cout <- c(C0,DeltaE,GammaE,ThetaE)
	}
	#----------------------Performing simulations-------------------
	# This program calculates plain vanila options and greeks using BT method

	BT <-matrix(NA,nrow=npt,ncol=4)
	BT1 <-matrix(NA,nrow=npt,ncol=4);bt_v <-matrix(NA,nrow=npt,ncol=1);bt_kd <-matrix(NA,nrow=npt,ncol=1)
	BT2 <-matrix(NA,nrow=npt,ncol=4);bt_r <-matrix(NA,nrow=npt,ncol=1)
	BT3 <-matrix(NA,nrow=npt,ncol=4)
	del =0.01
	
	for (ik in 1:npt)
	{
	
		F1 <-Option_data[ik,1];K <- Option_data[ik,3]; v<-Option_data[ik,4]; r<-Option_data[ik,6]; tau<-Option_data[ik,7]; cp<-Option_data[ik,8]
        Method <-Option_data[ik,9] 
		#--------------Calculation of premium, delta, gamma and theta
		BT[ik,] <- BTOption(F1, K, tau, r, v, M,cp,Method)
    
		#-----Caculatio of strike delta
		dk <- (K+del) 
		BT3[ik,] <- BTOption(F1, dk, tau, r, v, M,cp,Method)
		bt_kd[ik] <- (BT3[ik,1]-BT[ik,1])/(del)
    
		#-----Caculatio of Vega 
		dv <- (v+del) 
		BT1[ik,] <- BTOption(F1, K, tau, r, dv, M,cp,Method)
		bt_v[ik] <- (BT1[ik,1]-BT[ik,1])/(del)
    
		#-----------------Calculation of Rho
		dr <- (r+del)
		BT2[ik,] <- BTOption(F1, K, tau, dr, v, M,cp,Method)
		bt_r[ik] <- (BT2[ik,1]-BT[ik,1])/(del)
	}

	# Accumulating Results
	 option_BT <- data.frame(Option_data[,10],BT[,1],BT[,2],BT[,3],bt_v,BT[,4],bt_r,bt_kd,bt_gamma2,bt_vega2,bt_theta2,bt_rho2,Method,Option_data[,11])

	 Option_data_out <- option_BT
	 '' 
	,@input_data_1 =N''SELECT  
		S1,S2,X,V1,V2,R,T,CallPutFlag, Method,row_id,Attribute_type
		FROM '+@input_table_name+' 
		WHERE Method = ''''45501'''';''
		,@input_data_1_name = N'' Option_data''
		,@output_data_1_name = N'' Option_data_out'' '
	
	SET @r  = 0 
	SET @sqsl = REPLACE(@sql_check,'<<value>>','45501')
	EXEC sp_executesql @sqsl,@param,@re =@r  OUT
	IF @r = 1 
	BEGIN
		EXEC(@sql)
	END  
	
--END
--spa_calculate_options_Vanilla_EUMC
	SET @sql = '

	INSERT INTO '+@output_table_name+'
	exec sp_execute_external_script  @language =N''R''    
	,@script=N''
	#----------------------------

	npt <- nrow(Option_data);
	#cp <- rep("c",npt);
	#Deals <- c(1:npt);
	#----------------------------------------------------------------

	# EU greeks calculation 
	EU_gamma2 <- rep("",npt);EU_vega2 <- rep("",npt);EU_theta2 <- rep("",npt);EU_rho2 <- rep("",npt);
	EU_greeks_cal <- function(Spot,Strike,s.t,sigma,r,M_T,z,cp)
	{
	  del <- 0.5
  
	  # calculation of delta
	  s11 <- (Spot+del)*exp((r-1/2*sigma^2)*M_T + sigma*(M_T^0.5)*z)
	  s12 <- (Spot-del)*exp((r-1/2*sigma^2)*M_T + sigma*(M_T^0.5)*z)
  
	  if (cp == "c"){
		CC11 <- pmax(s11-Strike,0); CC12 <- pmax(s12-Strike,0);CC <- pmax(s.t-Strike,0) 
	  }
	  if (cp == "p"){
		CC11 <- pmax(Strike-s11,0); CC12 <- pmax(Strike-s12,0);CC <- pmax(Strike-s.t,0) 
	  }
  
	  payoff_s11 <- mean(exp(-r*M_T)*CC11); payoff_s12 <- mean(exp(-r*M_T)*CC12);payoffs <-mean(exp(-r*M_T)*CC)
  
	  mc_d <- (payoff_s11-payoff_s12)/(2*del)
  
	  # calculation of gamma
	  mc_g <- (payoff_s11-2*payoffs + payoff_s12)/(del^2)

	  # calculation of Strike Delta 
	  del = 0.5
	  if (cp == "c"){
		CC11 <- pmax(s.t-(Strike+del),0); CC12 <- pmax(s.t-(Strike-del),0); 
	  }
	  if (cp == "p"){
		CC11 <- pmax((Strike+del)-s.t,0); CC12 <- pmax((Strike-del)-s.t,0);
	  }
  
	  payoff_s11 <- mean(exp(-r*M_T)*CC11); payoff_s12 <- mean(exp(-r*M_T)*CC12);payoffs <-mean(exp(-r*M_T)*CC)
  
	  mc_d2 <- (payoff_s11-payoff_s12)/(2*del)
  
	  # calculation of vega
	  delv <- 0.01
  
	  sv11 <- Spot*exp((r-1/2*(sigma+delv)^2)*M_T + (sigma+delv)*(M_T^0.5)*z)
	  sv12 <- Spot*exp((r-1/2*(sigma-delv)^2)*M_T + (sigma-delv)*(M_T^0.5)*z)
  
	  if (cp == "c"){
		CCv11 <- pmax(sv11-Strike,0); CCv12 <- pmax(sv12-Strike,0)
	  }
	  if (cp == "p"){
		CCv11 <- pmax(Strike-sv11,0); CCv12 <- pmax(Strike-sv12,0)
	  }
  
	  payoff_sv11 <- mean(exp(-r*M_T)*CCv11); payoff_sv12 <- mean(exp(-r*M_T)*CCv12)
  
	  mc_v <- (payoff_sv11-payoff_sv12)/(2*delv)
  
	  # calculation of Theta
  
	  delt <- 0.01
  
	  st11 <- Spot*exp((r-1/2*sigma^2)*(M_T+delt) + sigma*((M_T+delt)^0.5)*z)
	  st12 <- Spot*exp((r-1/2*sigma^2)*(M_T-delt) + sigma*((M_T-delt)^0.5)*z)
  
	  if (cp == "c"){
		CCt11 <- pmax(st11-Strike,0); CCt12 <- pmax(st12-Strike,0)
	  }
	  if (cp == "p"){
		CCt11 <- pmax(Strike-st11,0); CCt12 <- pmax(Strike-st12,0)
	  }
  
	  payoff_st11 <- mean(exp(-r*(M_T+delt))*CCt11); payoff_st12 <- mean(exp(-r*(M_T-delt))*CCt12)
  
	  mc_t <- (-payoff_st11+payoff_st12)/(2*delt)
  
	  # calculation of Rho
	  delr <- 0.01
  
	  sr11 <- Spot*exp(((r+delr)-1/2*sigma^2)*M_T + sigma*(M_T^0.5)*z)
	  sr12 <- Spot*exp(((r-delr)-1/2*sigma^2)*M_T + sigma*(M_T^0.5)*z)
  
	  if (cp == "c"){
		CCr11 <- pmax(sr11-Strike,0); CCr12 <- pmax(sr12-Strike,0)
	  }
	  if (cp == "p"){
		CCr11 <- pmax(Strike-sr11,0); CCr12 <- pmax(Strike-sr12,0)
	  }
  
	  payoff_sr11 <- mean(exp(-(r+delr)*M_T)*CCr11); payoff_sr12 <- mean(exp(-(r-delr)*M_T)*CCr12)
  
	  mc_r <- (payoff_sr11-payoff_sr12)/(2*delr)
  
  
	  # print(cbind(mc_d,mc_d2,mc_g,mc_v,mc_t,mc_r))
	  return(c(mc_d,mc_g,mc_v,mc_t,mc_r,mc_d2))
	}

	# Least square Monte Carlo method of European Put and Call options 
	EuLSM <- function(Spot, sigma, n, Strike, r, M_T,cp,Method)
	{
	  if (cp == "c")
	  {
		z <- matrix(rnorm(n),nrow=1)
		s.t <- Spot*exp((r-1/2*sigma^2)*M_T + sigma*(M_T^0.5)*z)
		CC <- pmax(s.t-Strike,0)
		payoffeu <- exp(-r*M_T)*CC
		payoffeu_mean <- mean(payoffeu)
		mcg  <- EU_greeks_cal(Spot,Strike,s.t,sigma,r,M_T,z,cp)
		mcg1 <- c(payoffeu_mean,mcg)
		return(mcg1)
	  } 
	  if (cp == "p"){
		z <- matrix(rnorm(n),nrow=1)
		s.t <- Spot*exp((r-1/2*sigma^2)*M_T + sigma*(M_T^0.5)*z)
		CC <- pmax(Strike-s.t,0)
		payoffeu <- exp(-r*M_T)*CC
		payoffeu_mean <- mean(payoffeu)
    
		mcg  <- EU_greeks_cal(Spot,Strike,s.t,sigma,r,M_T,z,cp)
		mcg2 <- c(payoffeu_mean,mcg)
		#print(mcg1)
		return(mcg2) 
	  }
	}

	#-----------------Main Program Simulation -----------------------------
	# Monte Carlo parameters
	n <- 10000 # number of generated path
	d <- 10  # number of time steps For Monte carlo 
	#-------------------------------------------------
	npt <-nrow(Option_data)
	EU_MC <-matrix(NA,nrow=npt,ncol=7)
	EU_gamma2 <- rep("",npt);EU_vega2<-rep("",npt);EU_theta2<-rep("",npt);EU_rho2<-rep("",npt);
	for (ik in 1:npt)
	{
	  EUopt <- EuLSM(Option_data[ik,1],Option_data[ik,4],n,Option_data[ik,3],Option_data[ik,6],Option_data[ik,7],Option_data[ik,8],Option_data[ik,9])
	  EU_MC[ik,]<- EUopt
	}
	
	option_EU <- data.frame(Option_data[,10],EU_MC[,1],EU_MC[,2],EU_MC[,4],EU_MC[,5],EU_MC[,6],EU_MC[,7],EU_MC[,3],EU_gamma2,EU_vega2,EU_theta2,EU_rho2,Option_data[,9],Option_data[,11])                       
	Option_data_out <- option_EU''     
	,@input_data_1 =N''SELECT  
		S1,S2,X,V1,V2,R,T,CallPutFlag, Method,row_id,Attribute_type
		FROM '+@input_table_name+' 
		WHERE Method = ''''45502'''';''
		,@input_data_1_name = N'' Option_data''
		,@output_data_1_name = N'' Option_data_out'' '
	SET @r  = 0 
	SET @sqsl = REPLACE(@sql_check,'<<value>>','45502')
	EXEC sp_executesql @sqsl,@param,@re =@r  OUT
	IF @r = 1 
	BEGIN
		EXEC(@sql)
	END  
	
	
--END
--spa_calculate_options_Vanilla_USMC

SET @sql = '

	INSERT INTO '+@output_table_name+'
	exec sp_execute_external_script  @language =N''R''    
	,@script=N''
	#----------------------------
	npt <- nrow(Option_data);
	#cp <- rep("c",npt);
	#Deals <- c(1:npt);
	#----------------------------------------------------------------
	# US Greeks calculation 
	US_gamma2 <- rep("",npt);US_vega2 <- rep("",npt);US_theta2 <- rep("",npt);US_rho2 <- rep("",npt);US_delta2 <- rep("",npt);
	US_greeks_cal <- function(Spot,Strike,s.t,sigma,r,M_T1,z,cp)
	{
  
	  del <- 0.5
  
	  # calculation of delta
	  s11 <- (Spot+del)*exp((r-1/2*sigma^2)*M_T1 + sigma*(M_T1^0.5)*z)
	  s12 <- (Spot-del)*exp((r-1/2*sigma^2)*M_T1 + sigma*(M_T1^0.5)*z)
  
	  if (cp == "c"){
		CC11 <- pmax(s11-Strike,0); CC12 <- pmax(s12-Strike,0);CC <- pmax(s.t-Strike,0) 
	  }
	  if (cp == "p"){
		CC11 <- pmax(Strike-s11,0); CC12 <- pmax(Strike-s12,0);CC <- pmax(Strike-s.t,0) 
	  }
  
	  payoff_s11 <- mean(exp(-r*M_T1)*CC11); payoff_s12 <- mean(exp(-r*M_T1)*CC12);payoffs <-mean(exp(-r*M_T1)*CC)
  
	  mc_d <- (payoff_s11-payoff_s12)/(2*del)
  
	  # calculation of gamma
	  del =2
	  s11 <- (Spot+del)*exp((r-1/2*sigma^2)*M_T1 + sigma*(M_T1^0.5)*z)
	  s12 <- (Spot-del)*exp((r-1/2*sigma^2)*M_T1 + sigma*(M_T1^0.5)*z)
  
	  if (cp == "c"){
		CC11 <- pmax(s11-Strike,0); CC12 <- pmax(s12-Strike,0);CC <- pmax(s.t-Strike,0) 
	  }
	  if (cp == "p"){
		CC11 <- pmax(Strike-s11,0); CC12 <- pmax(Strike-s12,0);CC <- pmax(Strike-s.t,0) 
	  }
  
	  payoff_s11 <- mean(exp(-r*M_T1)*CC11); payoff_s12 <- mean(exp(-r*M_T1)*CC12);payoffs <-mean(exp(-r*M_T1)*CC)
  
	  mc_g <- (payoff_s11-2*payoffs + payoff_s12)/(del^2)

 
	  # calculation of Strike Delta 
	  del <- 0.7
	  if (cp == "c"){
		CC11 <- pmax(s.t-(Strike+del),0); CC12 <- pmax(s.t-(Strike-del),0); 
	  }
	  if (cp == "p"){
		CC11 <- pmax((Strike+del)-s.t,0); CC12 <- pmax((Strike-del)-s.t,0);
	  }
  
	  payoff_s11 <- mean(exp(-r*M_T1)*CC11); payoff_s12 <- mean(exp(-r*M_T1)*CC12);
  
	  mc_d2 <- (payoff_s11-payoff_s12)/(2*del)
  
	  # calculation of vega
	  delv <- 0.01
  
	  sv11 <- Spot*exp((r-1/2*(sigma+delv)^2)*M_T1 + (sigma+delv)*(M_T1^0.5)*z)
	  sv12 <- Spot*exp((r-1/2*(sigma-delv)^2)*M_T1 + (sigma-delv)*(M_T1^0.5)*z)
  
	  if (cp == "c"){
		CCv11 <- pmax(sv11-Strike,0); CCv12 <- pmax(sv12-Strike,0)
	  }
	  if (cp == "p"){
		CCv11 <- pmax(Strike-sv11,0); CCv12 <- pmax(Strike-sv12,0)
	  }
  
	  payoff_sv11 <- mean(exp(-r*M_T1)*CCv11); payoff_sv12 <- mean(exp(-r*M_T1)*CCv12)
  
	  mc_v <- (payoff_sv11-payoff_sv12)/(2*delv)
  
	  # calculation of Theta
  
	  delt <- 0.01
  
	  st11 <- Spot*exp((r-1/2*sigma^2)*(M_T1+delt) + sigma*((M_T1+delt)^0.5)*z)
	  st12 <- Spot*exp((r-1/2*sigma^2)*(M_T1-delt) + sigma*((M_T1-delt)^0.5)*z)
  
	  if (cp == "c"){
		CCt11 <- pmax(st11-Strike,0); CCt12 <- pmax(st12-Strike,0)
	  }
	  if (cp == "p"){
		CCt11 <- pmax(Strike-st11,0); CCt12 <- pmax(Strike-st12,0)
	  }
  
	  payoff_st11 <- mean(exp(-r*(M_T1+delt))*CCt11); payoff_st12 <- mean(exp(-r*(M_T1-delt))*CCt12)
  
	  mc_t <- (-payoff_st11+payoff_st12)/(2*delt)
  
	  # calculation of Rho
	  delr <- 0.01
  
	  sr11 <- Spot*exp(((r+delr)-1/2*sigma^2)*M_T1 + sigma*(M_T1^0.5)*z)
	  sr12 <- Spot*exp(((r-delr)-1/2*sigma^2)*M_T1 + sigma*(M_T1^0.5)*z)
  
	  if (cp == "c"){
		CCr11 <- pmax(sr11-Strike,0); CCr12 <- pmax(sr12-Strike,0)
	  }else{
		CCr11 <- pmax(Strike-sr11,0); CCr12 <- pmax(Strike-sr12,0)
	  }
  
	  payoff_sr11 <- mean(exp(-(r+delr)*M_T1)*CCr11); payoff_sr12 <- mean(exp(-(r-delr)*M_T1)*CCr12)
  
	  mc_r <- (payoff_sr11-payoff_sr12)/(2*delr)
  
  
	  # print(cbind(mc_d,mc_d2,mc_g,mc_v,mc_t,mc_r))
	  return(c(mc_d,mc_g,mc_v,mc_t,mc_r,mc_d2))
	}

	#--------------------------------------------------------------------
	# Least square Monte Carlo method of American Put and  options 
	library(stats)
	library(Matrix)
	USLSM <- function(Spot, sigma, n,d,Strike, r, M_T,cp,Method)
	{
	  if (cp == "p")
	  {
		dt <- M_T/d
		z <- matrix(rnorm(n),nrow=1)
		s.t <- Spot*exp((r-1/2*sigma^2)*M_T + sigma*(M_T^0.5)*z)
		CC <- pmax(Strike-s.t,0)
		payoffeu <- exp(-r*M_T)*CC
		payoffeu_mean <- mean(payoffeu)
    
		for(ii in (d-1):1)
		{
		  z <- matrix(rnorm(n),nrow=1)
		  mean1 <- (log(Spot)+ii*log(s.t))/(ii+1)
		  vol1 <- (ii*dt/(ii+1))^0.5*z
		  s.t_1 <- exp(mean1+sigma*vol1)
      
		  CE <- pmax(Strike-s.t_1,0)
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
		se.c <- sd(payoff.c)/sqrt(n)
		#------------------------------------
		mcg4  <- US_greeks_cal(Spot,Strike,s.t,sigma,r,(M_T-dt),z,cp)
		mcg6 <- c(usprice.c,mcg4)
		#-------------------------------------  
		return(mcg6) 
	  }
	  if (cp == "c")
	  {
		dt <- M_T/d
		z <- matrix(rnorm(n),nrow=1)
		s.t <- Spot*exp((r-1/2*sigma^2)*M_T + sigma*(M_T^0.5)*z)
		CC <- pmax(s.t-Strike,0)
		payoffeu <- exp(-r*M_T)*CC
		payoffeu_mean <- mean(payoffeu)
    
		for(ii in (d-1):1)
		{
		  z <- matrix(rnorm(n),nrow=1)
		  mean1 <- (log(Spot)+ii*log(s.t))/(ii+1)
		  vol1 <- (ii*dt/(ii+1))^0.5*z
		  s.t_1 <- exp(mean1+sigma*vol1)
      
		  CE <- pmax(s.t_1-Strike,0)
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
		se.c <- sd(payoff.c)/sqrt(n)
		#------------------------------------
		mcg4  <- US_greeks_cal(Spot,Strike,s.t,sigma,r,(M_T-dt),z,cp)
		mcg5 <- c(usprice.c,mcg4)
		#-------------------------------------  
		return(mcg5)
	  }
	}

	#-----------------Main Program simulation-----------------------------
	# Monte Carlo parameters
	n <- 10000 # number of generated path
	d <- 10  # number of time steps For Monte carlo 
	#-------------------------------------------------
	
	#npt <- nrow(Option_data);
	#cp <- rep("c",npt);
	#Deals <- c(1:npt);
	US_MC <-matrix(NA,nrow=npt,ncol=7)
	US_gamma2 <- rep("",npt);US_vega2<-rep("",npt);US_theta2<-rep("",npt);US_rho2<-rep("",npt);
	for (ik in 1:npt)
	{
	  USopt <- USLSM(Option_data[ik,1],Option_data[ik,4],n,d,Option_data[ik,3],Option_data[ik,6],Option_data[ik,7],Option_data[ik,8],Option_data[ik,9])
	  US_MC[ik,]<- USopt
 
	}
	option_US <- data.frame(Option_data[,10],US_MC[,1],US_MC[,2],US_MC[,4],US_MC[,5],US_MC[,6],US_MC[,7],US_MC[,3],US_gamma2,US_vega2,US_theta2,US_rho2,Option_data[,9],Option_data[,11])                       
	Option_data_out <- option_US''     
	,@input_data_1 =N''SELECT  
		S1,S2,X,V1,V2,R,T,CallPutFlag, Method,row_id, Attribute_type
		FROM '+@input_table_name+' 
		WHERE Method = ''''45503''''
		AND X IS NOT NULL;''
		,@input_data_1_name = N'' Option_data''
		,@output_data_1_name = N'' Option_data_out'' '
	SET @r  = 0 
	SET @sqsl = REPLACE(@sql_check,'<<value>>','45503')
	EXEC sp_executesql @sqsl,@param,@re =@r  OUT
	IF @r = 1 
	BEGIN
		EXEC(@sql)
	END  
	
	---- Calculate spread options using Kirk approximation method
		SET @sql = '
		INSERT INTO '+@output_table_name+'
		exec sp_execute_external_script  @language =N''R''    
		,@script=N''
		#----------------------------
		set.seed(12345)
		npt <- nrow(Option_data);
		#----------------------------------------------------------------
		KirkSpreadOption <- function(row_id,F1,F2,K,v1,v2,r,tau,rho,cp,Method){ 
			F_combine <- F1/(F2 + K); 
			F3 <- F2/(F2 + K); 
			v <- sqrt(v1^2 + (v2*F3)^2 - 2*rho*v1*v2*F3); 
 
			d1 <- (log(F_combine) + 0.5*v^2*tau)/(v*sqrt(tau)); 
			d2 <- d1 - v*sqrt(tau); 
  
			# calculation of options 
			k_options <- ifelse(cp == "c", (F2 + K)*exp(-r*tau)*(F_combine*pnorm(d1) - pnorm(d2)), 
								(F2 + K)*exp(-r*tau)*(pnorm(-d2) - F_combine*pnorm(-d1)));

			# calculation of Greeks -------------------
  
			k_delta_1 <- ifelse(cp == "c", pnorm(d1)*exp(-r*tau),(-1)*pnorm(d1)*exp(-r*tau));
			k_delta_2 <- ifelse(cp == "c", (-1)*pnorm(d2)*exp(-r*tau),pnorm(-d2)*exp(-r*tau)); 
			k_gamma_1 <-  dnorm(d1)/(F1*v*sqrt(tau)); 
			k_gamma_2 <-  dnorm(d2)/(F2*v*sqrt(tau));
			k_vega_1  <- dnorm(d1)*F1*exp(-r*tau)*sqrt(tau);
			k_vega_2  <- dnorm(d2)*F2*exp(-r*tau)*sqrt(tau);
			k_theta_1 <- ifelse(cp == "c", (-F1*dnorm(d1)*v)/(2*sqrt(tau)) - r*K* exp(-r*tau) * pnorm(d2),(-F1*dnorm(d1)*v)/(2*sqrt(tau)) +r*K* exp(-r*tau) * pnorm(-d2));
			k_theta_2 <- ifelse(cp == "c", (-F2*dnorm(d1)*v)/(2*sqrt(tau)) - r*K* exp(-r*tau) * pnorm(d2),(-F2*dnorm(d1)*v)/(2*sqrt(tau)) +r*K* exp(-r*tau) * pnorm(-d2));
			k_rho_1   <-  ifelse(cp == "c", K*tau*exp(-r*tau)*pnorm(d2),(-K)*tau*exp(-r*tau)*pnorm(-d2));
			k_rho_2   <- rep("",length.out=npt)
			kirk_ops  <- data.frame(row_id,k_options,k_delta_1,k_gamma_1,k_vega_1,k_theta_1,k_rho_1,k_delta_2,k_gamma_2,k_vega_2,k_theta_2,k_rho_2,Method,Option_data[,12]);
			return(kirk_ops)
		}
		#----------------------Performing simulations-------------------
		vspopt <- KirkSpreadOption(Option_data[,11],Option_data[,1],Option_data[,2],Option_data[,3],Option_data[,4],Option_data[,5],Option_data[,6],Option_data[,7],Option_data[,8],Option_data[,9],Option_data[,10])
		Option_data_out <- vspopt''     
		,@input_data_1 =N''SELECT  
			S1,S2,X,V1,V2,R,T,C,CallPutFlag, Method,row_id,attribute_type
			FROM '+@input_table_name+' 
			WHERE Method = ''''45504''''
			AND X IS NOT NULL;''
			,@input_data_1_name = N'' Option_data''
			,@output_data_1_name = N'' Option_data_out'' '
		SET @r  = 0 
		SET @sqsl = REPLACE(@sql_check,'<<value>>','45504')
		EXEC sp_executesql @sqsl,@param,@re =@r  OUT
		IF @r = 1 
		BEGIN
			EXEC(@sql)
		END  
		
	----Calculate spread options using Binomial Tree method
	SET @sql = '
			INSERT INTO '+@output_table_name+'
			exec sp_execute_external_script  @language =N''R''    
			,@script=N''
			#----------------------------
			set.seed(12345)
			npt <- nrow(Option_data);
			#cp <- rep("c",npt);
			#Deals <- c(1:npt);
			#----------------------------------------------------
			# This function calculates the spread options from bionomial tree method
			BTspreadfunctions<- function(S1,S2,K,v1,v2,r,rho,Tim,cp,n,ExerciseType){
  
			#Change variable names to match names in document
			rho_SI=rho;
			sigma_s=v1;
			sigma_I=v2;
			I0=S2;
			dividend1=0; #dividened yield for 1
			dividend2=0; #dividened yield for 2
			dt=Tim/n;
			# cp = "c" # for call and "p" for put options
  
			alpha_s<-r-dividend1-sigma_s*sigma_s*0.5
			alpha_I<-r-dividend2-sigma_I*sigma_I*0.5 #as given in eqn (13)
  
  
			u<-exp(alpha_s*dt+sigma_s*dt^0.5)
			d<-exp(alpha_s*dt-sigma_s*dt^0.5)
  
			#Cal payoff for terminal time 
			i<- n
  
			S1vec <- matrix(0,nrow=(i+1),ncol=1)
			Imat<- matrix(0,nrow=(i+1),ncol=(i+1))# #will contain values of S2
			PayoffMat<- matrix(0,nrow=(i+1),ncol=(i+1))#will contain payoff values 
  
			for (j in 0:i) {
			S1tmp <- S1*u^j * d^(i-j)
			S1vec[j+1] <- S1tmp
			for(k in 0:i) {
				tmp1<- alpha_I*i*dt 
				tmp2 <- rho_SI*(2*j-i)+ ((1-rho_SI*rho_SI)^0.5) * (2*k-i)
				tmp2 <- tmp2*sigma_I*dt^0.5
				Imat[j+1,k+1] <- I0*exp(tmp1+tmp2)  # as given in eqn (14)
				if (cp=="c"){
				PayoffMat[j+1,k+1] <- max(S1tmp-Imat[j+1,k+1]-K,0)
				}
				if (cp=="p"){
				PayoffMat[j+1,k+1] <- max(K-S1tmp+Imat[j+1,k+1],0)
				}
      
			}
			}
			PayoffMatterminal=PayoffMat
  
			#Rollback over time steps 
			for (i in (n-1):0){
			TmpPayoffMat <- matrix(0,nrow=(i+1),ncol=(i+1)) #will contain values of payoff
			for(j in 0:i){
				S1tmp <- S1* u^j * d^(i-j)
				S1vec[j+1]<- S1tmp
				for (k in 0:i){
				tmp1 <- alpha_I*i*dt 
				tmp2 <- rho_SI*(2*j-i)+ ((1-rho_SI*rho_SI)^0.5) * (2*k-i)
				tmp2 <- tmp2*sigma_I*dt^0.5
				Imat[j+1,k+1] <- I0*exp(tmp1+tmp2) #as given in eqn (14)
				TmpPayoffMat[j+1,k+1] <- .25 * ( PayoffMat[j+1,k+1] + PayoffMat[j+2,k+1] +PayoffMat[j+1,k+2] + PayoffMat[j+2,k+2] ) * exp(-r*dt)
				if (ExerciseType=="a"){
					present_payoffvalue <- TmpPayoffMat[j+1,k+1]
					if (cp=="c"){
					intrinsic_value <- S1tmp-Imat[j+1,k+1]-K
					}
					if (cp=="p"){
					intrinsic_value <- K-S1tmp+Imat[j+1,k+1]
					}
          
					TmpPayoffMat[j+1,k+1] <- max(present_payoffvalue,intrinsic_value)
				}
				}
			}
			PayoffMat <- TmpPayoffMat  
			}
			spread_price <- TmpPayoffMat
			return(spread_price)
			#print(spread_price)
			}

			# Option and Greeks calculation
			BT <-matrix(NA,nrow=npt,ncol=1)
			BT1 <-matrix(NA,nrow=npt,ncol=1)
			BT2 <-matrix(NA,nrow=npt,ncol=1)
			BT3 <-matrix(NA,nrow=npt,ncol=1)
			BT4 <-matrix(NA,nrow=npt,ncol=1)
			BT5 <-matrix(NA,nrow=npt,ncol=1)
			BT6 <-matrix(NA,nrow=npt,ncol=1)
			BT7 <-matrix(NA,nrow=npt,ncol=1)
			BT8 <-matrix(NA,nrow=npt,ncol=1)
			BT9 <-matrix(NA,nrow=npt,ncol=1)
			BT10 <-matrix(NA,nrow=npt,ncol=1)
			BT11 <-matrix(NA,nrow=npt,ncol=1)
			BT12 <-matrix(NA,nrow=npt,ncol=1)
			bt_d1 <-matrix(NA,nrow=npt,ncol=1);bt_d2 <-matrix(NA,nrow=npt,ncol=1)
			bt_g1 <-matrix(NA,nrow=npt,ncol=1);bt_g2 <-matrix(NA,nrow=npt,ncol=1)
			bt_v1 <-matrix(NA,nrow=npt,ncol=1);bt_v2 <-matrix(NA,nrow=npt,ncol=1);bt_t2 <-matrix(NA,nrow=npt,ncol=1);
			bt_t <-matrix(NA,nrow=npt,ncol=1);bt_r <-matrix(NA,nrow=npt,ncol=1);bt_r2 <-matrix(NA,nrow=npt,ncol=1)
			#bt_tot <-matrix(NA,nrow=npt,ncol=8)

			for (ik in 1:npt)
			{
			del = 0.01
			m = 5
	
			ExerciseType <- "e"
			#------------------------------------------
			BT[ik]  <-BTspreadfunctions(Option_data[ik,1],Option_data[ik,2],Option_data[ik,3],Option_data[ik,4],Option_data[ik,5],Option_data[ik,6],Option_data[ik,7],Option_data[ik,8],Option_data[ik,9],m,ExerciseType)
			BT1[ik] <- BTspreadfunctions((Option_data[ik,1]+del),Option_data[ik,2],Option_data[ik,3],Option_data[ik,4],Option_data[ik,5],Option_data[ik,6],Option_data[ik,7],Option_data[ik,8],Option_data[ik,9],m,ExerciseType)
			BT2[ik] <- BTspreadfunctions((Option_data[ik,1]-del),Option_data[ik,2],Option_data[ik,3],Option_data[ik,4],Option_data[ik,5],Option_data[ik,6],Option_data[ik,7],Option_data[ik,8],Option_data[ik,9],m,ExerciseType)
			BT3[ik] <- BTspreadfunctions(Option_data[ik,1],(Option_data[ik,2]+del),Option_data[ik,3],Option_data[ik,4],Option_data[ik,5],Option_data[ik,6],Option_data[ik,7],Option_data[ik,8],Option_data[ik,9],m,ExerciseType)
			BT4[ik] <- BTspreadfunctions(Option_data[ik,1],(Option_data[ik,2]-del),Option_data[ik,3],Option_data[ik,4],Option_data[ik,5],Option_data[ik,6],Option_data[ik,7],Option_data[ik,8],Option_data[ik,9],m,ExerciseType)
			BT5[ik] <- BTspreadfunctions(Option_data[ik,1],Option_data[ik,2],Option_data[ik,3],(Option_data[ik,4]+del),Option_data[ik,5],Option_data[ik,6],Option_data[ik,7],Option_data[ik,8],Option_data[ik,9],m,ExerciseType)
			BT6[ik] <- BTspreadfunctions(Option_data[ik,1],Option_data[ik,2],Option_data[ik,3],(Option_data[ik,4]-del),Option_data[ik,5],Option_data[ik,6],Option_data[ik,7],Option_data[ik,8],Option_data[ik,9],m,ExerciseType)
			BT7[ik] <- BTspreadfunctions(Option_data[ik,1],Option_data[ik,2],Option_data[ik,3],Option_data[ik,4],(Option_data[ik,5]+del),Option_data[ik,6],Option_data[ik,7],Option_data[ik,8],Option_data[ik,9],m,ExerciseType)
			BT8[ik] <- BTspreadfunctions(Option_data[ik,1],Option_data[ik,2],Option_data[ik,3],Option_data[ik,4],(Option_data[ik,5]-del),Option_data[ik,6],Option_data[ik,7],Option_data[ik,8],Option_data[ik,9],m,ExerciseType)
			BT9[ik] <- BTspreadfunctions(Option_data[ik,1],Option_data[ik,2],Option_data[ik,3],Option_data[ik,4],Option_data[ik,5],(Option_data[ik,6]+del),Option_data[ik,7],Option_data[ik,8],Option_data[ik,9],m,ExerciseType)
			BT10[ik] <- BTspreadfunctions(Option_data[ik,1],Option_data[ik,2],Option_data[ik,3],Option_data[ik,4],Option_data[ik,5],(Option_data[ik,6]-del),Option_data[ik,7],Option_data[ik,8],Option_data[ik,9],m,ExerciseType)
			BT11[ik] <- BTspreadfunctions(Option_data[ik,1],Option_data[ik,2],Option_data[ik,3],Option_data[ik,4],Option_data[ik,5],Option_data[ik,6],Option_data[ik,7],(Option_data[ik,8]+del),Option_data[ik,9],m,ExerciseType)
			BT12[ik] <- BTspreadfunctions(Option_data[ik,1],Option_data[ik,2],Option_data[ik,3],Option_data[ik,4],Option_data[ik,5],Option_data[ik,6],Option_data[ik,7],(Option_data[ik,8]-del),Option_data[ik,9],m,ExerciseType)
  
			bt_d1[ik] <- (BT1[ik]-BT2[ik])/(2*del)
			bt_d2[ik] <- (BT3[ik]-BT4[ik])/(2*del)
			bt_g1[ik] <- (BT1[ik]-2*BT[ik]+BT2[ik])/(del*del)
			bt_g2[ik] <- (BT3[ik]-2*BT[ik]+BT4[ik])/(del*del)
			bt_v1[ik] <- (BT5[ik]-BT6[ik])/(2*del)
			bt_v2[ik] <- (BT7[ik]-BT8[ik])/(2*del)
			bt_r[ik] <- (BT9[ik]-BT10[ik])/(2*del);	
			bt_t[ik] <- (BT11[ik]-BT12[ik])/(2*del);	
			# bt_tot[ik,] <- c(bt_d1[ik],bt_d2[ik],bt_g1[ik],bt_g2[ik],bt_v1[ik],bt_v2[ik],bt_t[ik],bt_r[ik])
			}
			bt_sp_opt <- data.frame(Option_data[,11],BT,bt_d1,bt_g1,
							bt_v1,bt_t,bt_r,bt_d2,bt_g2,bt_v2,bt_t2,bt_r2,Option_data[,10],Option_data[,12])

				#----------------------Performing simulations-------------------
				Option_data_out <- bt_sp_opt''     
				,@input_data_1 =N''SELECT  
				S1,S2,X,V1,V2,R,T,C,CallPutFlag, Method,row_id,attribute_type
				FROM '+@input_table_name+' 
				WHERE Method = ''''45505''''
				AND X IS NOT NULL;''
				,@input_data_1_name = N'' Option_data''
				,@output_data_1_name = N'' Option_data_out'' '
			SET @r  = 0 
			SET @sqsl = REPLACE(@sql_check,'<<value>>','45505')
			EXEC sp_executesql @sqsl,@param,@re =@r  OUT
			IF @r = 1 
			BEGIN
				EXEC(@sql)
			END  
			
	---- Calculate spread options using Monte Carlo method for European options
	SET @sql = '
		INSERT INTO '+@output_table_name+'
		exec sp_execute_external_script  @language =N''R''    
		,@script=N''
		#----------------------------
		set.seed(12345)
		npt <- nrow(Option_data);
		#----------------------------------------------------
				Simulation_EU_Spark_spread <- function(n,d,s0_1,s0_2,K,sigma1,sigma2,r,M_T,rho,cp1)
				{
				library(Matrix)
				library(stats)
				rho <- 0.9
				correlation_matrix <- matrix(c(1,rep(rho,2),1),nrow=2)
				L <- t(chol(correlation_matrix))
				z <- matrix(rnorm(n*2),nrow=2)
				z <- L%*%z
  
				sp1 <- s0_1*exp((r-1/2*sigma1^2)*M_T + sigma1*(M_T^0.5)*z[1,])
				sp2 <- s0_2*exp((r-1/2*sigma2^2)*M_T + sigma2*(M_T^0.5)*z[2,])

				if (cp1=="c")
				{
					CC <- pmax(sp1-sp2-K,0)
				}
				if (cp1=="p")
				{
					CC <- pmax(K-sp1+sp2,0)
				}
				payoffeu <- exp(-r*M_T)*CC
				payoffeu_mean <- mean(payoffeu)
  
				mcg  <- EU_greeks_cal(s0_1,s0_2,sp1,sp2,sigma1,sigma2,r,K,rho,M_T,z,cp1)
				#mcg <-c(0,0,0,0,0,0,0,0,0,0)
				mcg1 <- c(payoffeu_mean,mcg)
				return(mcg1)
				} 
				
		EU_greeks_cal <- function(s0_1,s0_2,s1.t,s2.t,sigma1,sigma2,r,K,rho1,M_T,z,cp)
			{
			  del <- 1
			  del1 <- 1
  
			  # combined volatility 
			  F_combine <- s0_1/(s0_2 + K) 
			  F3 <- s0_2/(s0_2 + K) 
			  v <- sqrt(sigma1^2 + (sigma2*F3)^2 - 2*rho1*sigma1*sigma2*F3) 
			  v1 <- v; v2<-v
  
			  # calculation of delta1 and delta 2
			  s11 <- (s0_1+del)*exp((r-1/2*sigma1^2)*M_T + sigma1*(M_T^0.5)*z[1,])
			  s12 <- (s0_1-del)*exp((r-1/2*sigma1^2)*M_T + sigma1*(M_T^0.5)*z[1,])
  
			  s21 <- (s0_2+del1)*exp((r-1/2*sigma2^2)*M_T + sigma2*(M_T^0.5)*z[2,])
			  s22 <- (s0_2-del1)*exp((r-1/2*sigma2^2)*M_T + sigma2*(M_T^0.5)*z[2,])
  
			  if (cp == "c")
			  {
				CC11 <- pmax(s11-s2.t-K,0)
				CC12 <- pmax(s12-s2.t-K,0)
				CC21 <- pmax(s1.t-s21-K,0)
				CC22 <- pmax(s1.t-s22-K,0)
				CC   <- pmax(s1.t-s2.t-K,0)
			  }
			  if (cp == "p")
			  {
				CC11 <- pmax(K-s11+s2.t,0)
				CC12 <- pmax(K-s12+s2.t,0)
				CC21 <- pmax(K-s1.t+s21,0)
				CC22 <- pmax(K-s1.t+s22,0)
				CC   <- pmax(K-s1.t+s2.t,0)
			  }
  
			  payoff_s11 <- mean(exp(-r*M_T)*CC11); payoff_s12 <- mean(exp(-r*M_T)*CC12);
			  payoff_s21 <- mean(exp(-r*M_T)*CC21); payoff_s22 <- mean(exp(-r*M_T)*CC22);
			  payoffs <-mean(exp(-r*M_T)*CC)
  
			  mc_d1 <- (payoff_s11-payoff_s12)/(2*del)
			  mc_d2 <- (payoff_s21-payoff_s22)/(2*del1)
  
			  # calculation of gamma
			  mc_g1 <- (payoff_s11-2*payoffs + payoff_s12)/(del^2)
			  mc_g2 <- (payoff_s21-2*payoffs + payoff_s22)/(del1^2)
  
			  # calculation of vega
			  #v1 <- sigma1; v2<- sigma2 
			  del <- 0.01*v
			  del1 <- 0.01*v
			  #v1 <- sigma1; v2<- sigma2 
			  #v1<-v; v2<-v
  
			  sv11 <- (s0_1)*exp((r-1/2*(v1+del)^2)*M_T + (v1+del)*(M_T^0.5)*z[1,])
			  sv12 <- (s0_1)*exp((r-1/2*(v1-del)^2)*M_T + (v1-del)*(M_T^0.5)*z[1,])
  
			  sv21 <- (s0_2)*exp((r-1/2*(v2+del1)^2)*M_T + (v2+del1)*(M_T^0.5)*z[2,])
			  sv22 <- (s0_2)*exp((r-1/2*(v2-del1)^2)*M_T + (v2-del1)*(M_T^0.5)*z[2,])
  
			  if (cp == "c")
			  {
				CCv11 <- pmax(sv11-s2.t-K,0)
				CCv12 <- pmax(sv12-s2.t-K,0)
				CCv21 <- pmax(s1.t-sv21-K,0)
				CCv22 <- pmax(s1.t-sv22-K,0)
			  }
			  if (cp == "p")
			  {
				CCv11 <- pmax(K-sv11+s2.t,0)
				CCv12 <- pmax(K-sv12+s2.t,0)
				CCv21 <- pmax(K-s1.t+sv21,0)
				CCv22 <- pmax(K-s1.t+sv22,0)
			  }
			  payoff_sv11 <- mean(exp(-r*M_T)*CCv11); payoff_sv12 <- mean(exp(-r*M_T)*CCv12);
			  payoff_sv21 <- mean(exp(-r*M_T)*CCv21); payoff_sv22 <- mean(exp(-r*M_T)*CCv22);
  
			  mc_v1 <- abs(payoff_sv11-payoff_sv12)/(2*del)
			  mc_v2 <- abs(payoff_sv21-payoff_sv22)/(2*del1)
			 # mc_v <- (mc_v1 + mc_v2)
  
			  # calculation of Theta
  
			  del <- 1e-4
			  #v1 <- v; v2<- v
			  st11 <- (s0_1)*exp((r-1/2*v1^2)*(M_T+del) + v1 *((M_T+del)^0.5)*z[1,])
			  st12 <- (s0_1)*exp((r-1/2*v1^2)*(M_T-del) + v1 *((M_T-del)^0.5)*z[1,])
  
			  st21 <- (s0_2)*exp((r-1/2*v2^2)*(M_T+del) + v2*((M_T+del)^0.5)*z[2,])
			  st22 <- (s0_2)*exp((r-1/2*v2^2)*(M_T-del) + v2*((M_T-del)^0.5)*z[2,])
  
			  if (cp == "c")
			  {
				CCt11 <- pmax(st11-s2.t-K,0)
				CCt12 <- pmax(st12-s2.t-K,0)
				CCt21 <- pmax(s1.t-st21-K,0)
				CCt22 <- pmax(s1.t-st22-K,0)
			  }
			  if (cp == "p")
			  {
				CCt11 <- pmax(K-st11+s2.t,0)
				CCt12 <- pmax(K-st12+s2.t,0)
				CCt21 <- pmax(K-s1.t+st21,0)
				CCt22 <- pmax(K-s1.t+st22,0)
			  } 
			  payoff_st11 <- mean(exp(-r*(M_T+del))*CCt11); payoff_st12 <- mean(exp(-r*(M_T-del))*CCt12);
			  payoff_st21 <- mean(exp(-r*(M_T+del))*CCt21); payoff_st22 <- mean(exp(-r*(M_T-del))*CCt22);
  
			  mc_t1 <- (payoff_st11-payoff_st12)/(2*del)
			  mc_t2 <- (payoff_st21-payoff_st22)/(2*del)
			  mc_t <- mc_t1 + mc_t2;
  
			  # calculation of Rho
			  del <- 1e-4
			  v1 <- v; v2<- v 
  
			  sr11 <- (s0_1)*exp(((r+del)-1/2*v1^2)*(M_T) + v1 *((M_T)^0.5)*z[1,])
			  sr12 <- (s0_1)*exp(((r-del)-1/2*v1^2)*(M_T) + v1 *((M_T)^0.5)*z[1,])
  
			  sr21 <- (s0_2)*exp(((r+del)-1/2*v2^2)*(M_T) + v2*((M_T)^0.5)*z[2,])
			  sr22 <- (s0_2)*exp(((r-del)-1/2*v2^2)*(M_T) + v2*((M_T)^0.5)*z[2,])
  
			  if (cp == "c")
			  {
				CCr11 <- pmax(sr11-s2.t-K,0)
				CCr12 <- pmax(sr12-s2.t-K,0)
				CCr21 <- pmax(s1.t-sr21-K,0)
				CCr22 <- pmax(s1.t-sr22-K,0)
			  }
			  if (cp == "p")
			  {
				CCr11 <- pmax(K-sr11+s2.t,0)
				CCr12 <- pmax(K-sr12+s2.t,0)
				CCr21 <- pmax(K-s1.t+sr21,0)
				CCr22 <- pmax(K-s1.t+sr22,0)
			  }
			  payoff_sr11 <- mean(exp(-(r+del)*(M_T))*CCr11); payoff_sr12 <- mean(exp(-(r-del)*(M_T))*CCr12);
			  payoff_sr21 <- mean(exp(-(r+del)*(M_T))*CCr21); payoff_sr22 <- mean(exp(-(r-del)*(M_T))*CCr22);
  
			  mc_r1 <- (payoff_sr11-payoff_sr12)/(2*del)
			  mc_r2 <- (payoff_sr21-payoff_sr22)/(2*del)
			  mc_r <- mc_r1 + mc_r2;
  
			  return(c(mc_d1,mc_g1,mc_v1,mc_t1,mc_r1,mc_d2,mc_g2,mc_v2,mc_t2,mc_r2))
			} 
		
		EU_MC=matrix(0,nrow=npt,ncol=11)
		#nobs <-c(1:npt)
		n<-10000 # number of Monte Carlo paths
		d<- 10   # number of steps per path
		#----------------------Performing simulations-------------------
		for (ik in 1:npt)
		{
		  s0_1 <-as.numeric(Option_data[ik,1]);s0_2 <-as.numeric(Option_data[ik,2]);K <-as.numeric(Option_data[ik,3]);sigma1 <-as.numeric(Option_data[ik,4])
		  sigma2 <-as.numeric(Option_data[ik,5]);r <-as.numeric(Option_data[ik,6]);M_T <-as.numeric(Option_data[ik,7]);rho <-as.numeric(Option_data[ik,8]);
		  cp1 <- as.character(Option_data[ik,9])
		 # EUoption <- Simulation_EU_Spark_spread(n,d,Option_data[ik,1],Option_data[ik,2],Option_data[ik,3],Option_data[ik,4],Option_data[ik,5],Option_data[ik,6],Option_data[ik,7],Option_data[ik,8],Option_data[ik,9])
		  EUoption <- Simulation_EU_Spark_spread(n,d,s0_1,s0_2,K,sigma1,sigma2,r,M_T,rho,cp1)
		  EU_MC[ik,] <- EUoption
		}
		option_EU <- data.frame(Option_data[,11],EU_MC[,1],EU_MC[,2],EU_MC[,3],EU_MC[,4], EU_MC[,5],EU_MC[,6],
								EU_MC[,7], EU_MC[,8],EU_MC[,9], EU_MC[,10],EU_MC[,11],Option_data[,10],Option_data[,12])
		#----------------------Performing simulations-------------------
		Option_data_out <- option_EU''     
		,@input_data_1 =N''SELECT  
		S1,S2,X,V1,V2,R,T,C,CallPutFlag,Method,row_id,attribute_type
		FROM '+@input_table_name+' 
		WHERE Method = ''''45506'''';''

		,@input_data_1_name = N'' Option_data''
		,@output_data_1_name = N'' Option_data_out'' '
		
		SET @r  = 0 
		SET @sqsl = REPLACE(@sql_check,'<<value>>','45506')
		EXEC sp_executesql @sqsl,@param,@re =@r  OUT
		IF @r = 1 
		BEGIN
			EXEC(@sql)
		END 
	    
	-- Calculate spread options using Least Square Monte Carlo method for American options
	SET @sql = '
			INSERT INTO '+@output_table_name+'
			exec sp_execute_external_script  @language =N''R''    
			,@script=N''
			#----------------------------
			set.seed(12345)
			npt <- nrow(Option_data);
			#----------------------------------------------------
			Simulation_US_Spark_spread <- function (n,d,s0_1,s0_2,K,sigma1,sigma2,r,M_T,rho,cp1)
			{
			  library(Matrix)
			  library(stats)
				rho <- 0.9
				dt<- M_T/d
				correlation_matrix <- matrix(c(1,rep(rho,2),1),nrow=2)
				L <- t(chol(correlation_matrix))
				z <- matrix(rnorm(n*2),nrow=2)
				z <- L%*%z
				z1 <- z
				sp1 <- s0_1*exp((r-1/2*sigma1^2)*M_T + sigma1*(M_T^0.5)*z[1,])
				sp2 <- s0_2*exp((r-1/2*sigma2^2)*M_T + sigma2*(M_T^0.5)*z[2,])

				if (cp1=="c")
				{
					CC <- pmax(sp1-sp2-K,0)
				}
				if (cp1=="p")
				{
					CC <- pmax(K-sp1+sp2,0)
				}
				payoffeu <- exp(-r*M_T)*CC
				payoffeu_mean <- mean(payoffeu)
  
			  for(ii in (d-1):1)
			  {
			   # correlation_matrix <- matrix(c(1,rep(rho,2),1),nrow=2)
			   #	L <- t(chol(correlation_matrix))
			    z <- matrix(rnorm(n*2),nrow=2)
			    z <- L%*%z
				#z1 <- z
			  mean1 <- (log(s0_1)+ii*log(sp1))/(ii+1)
			  vol1 <- (ii*dt/(ii+1))^0.5*z[1,]
			  s1.t_1 <- exp(mean1+sigma1*vol1)
  
			  mean2 <- (log(s0_2)+ii*log(sp2))/(ii+1)
			  vol2 <- (ii*dt/(ii+1))^0.5*z[2,]
			  s2.t_1 <- exp(mean2+sigma2*vol2)
  
			  if (cp1=="c")
			  {
				CE <- pmax(s1.t_1-s2.t_1-K,0)
			  }
			  if (cp1=="p")
			  {
				CE <- pmax(K-s1.t_1+s2.t_1,0)
			  }
			 
			  idx <- (1:n)[CE>0]
  
			  if (length(idx)> round(0.002*n,0)) # to avoid divergence 
				  {
					discountedCC <- CC[idx]*exp(-r*dt)
					basis1 <- s1.t_1[idx]
					basis2 <- s2.t_1[idx]
					basis3 <- s1.t_1[idx]*s2.t_1[idx]
					basis4 <- s1.t_1[idx]^2
					basis5 <- s2.t_1[idx]^2
					basis6 <- s1.t_1[idx]^2*s2.t_1[idx]
					basis7 <- s1.t_1[idx]*s2.t_1[idx]^2
					basis8 <- s1.t_1[idx]^2*s2.t_1[idx]^2
    
					p <- glm(discountedCC ~ basis1+basis2+basis3+basis4+basis5+basis6+basis7+basis8)$coefficients
					estimatedCC <- p[1]+p[2]*basis1 + p[3]*basis2 + p[4]*basis3 + p[5]*basis4 + p[6]*basis5 + p[7]*basis6 + p[8]*basis7 + p[9]*basis8
					EF <- rep(0,n)
					EF[idx] <- (CE[idx]>estimatedCC)
					CC <- (EF==0)*CC*exp(-r*dt)+(EF==1)*CE
					sp1 <- s1.t_1; sp2 <- s2.t_1
				  }
			  }
  
			  payoff <- CC *exp(-r*dt)
			  payoff.c <- payoff
			  usprice.c <- mean(payoff.c)
			  #se.c <- sd(payoff.c)/sqrt(n)
			  #------------------------------------
			# mcg  <- US_greeks_cal(s0_1,s0_2,sp1,sp2,sigma1,sigma2,r,rho,(M_T-dt),z,cp1)
			  mcg <-c(0,0,0,0,0,0,0,0,0,0)
			  mcg5 <- c(usprice.c,mcg)
				return(mcg5)
			  
			}

      US_greeks_cal <- function(s0_1,s0_2,s1.t,s2.t,sigma1,sigma2,r,K,rho1,M_T,z,cp)
			{
			  del <- 1
			  del1 <- 1
  
			  # combined volatility 
			  F_combine <- s0_1/(s0_2 + K) 
			  F3 <- s0_2/(s0_2 + K) 
			  v <- sqrt(sigma1^2 + (sigma2*F3)^2 - 2*rho1*sigma1*sigma2*F3) 
			  v1 <- v; v2<-v
  
			  # calculation of delta1 and delta 2
			  s11 <- (s0_1+del)*exp((r-1/2*sigma1^2)*M_T + sigma1*(M_T^0.5)*z[1,])
			  s12 <- (s0_1-del)*exp((r-1/2*sigma1^2)*M_T + sigma1*(M_T^0.5)*z[1,])
  
			  s21 <- (s0_2+del1)*exp((r-1/2*sigma2^2)*M_T + sigma2*(M_T^0.5)*z[2,])
			  s22 <- (s0_2-del1)*exp((r-1/2*sigma2^2)*M_T + sigma2*(M_T^0.5)*z[2,])
  
			  if (cp == "c")
			  {
				CC11 <- pmax(s11-s2.t-K,0)
				CC12 <- pmax(s12-s2.t-K,0)
				CC21 <- pmax(s1.t-s21-K,0)
				CC22 <- pmax(s1.t-s22-K,0)
				CC   <- pmax(s1.t-s2.t-K,0)
			  }
			  if (cp == "p")
			  {
				CC11 <- pmax(K-s11+s2.t,0)
				CC12 <- pmax(K-s12+s2.t,0)
				CC21 <- pmax(K-s1.t+s21,0)
				CC22 <- pmax(K-s1.t+s22,0)
				CC   <- pmax(K-s1.t+s2.t,0)
			  }
  
			  payoff_s11 <- mean(exp(-r*M_T)*CC11); payoff_s12 <- mean(exp(-r*M_T)*CC12);
			  payoff_s21 <- mean(exp(-r*M_T)*CC21); payoff_s22 <- mean(exp(-r*M_T)*CC22);
			  payoffs <-mean(exp(-r*M_T)*CC)
  
			  mc_d1 <- (payoff_s11-payoff_s12)/(2*del)
			  mc_d2 <- (payoff_s21-payoff_s22)/(2*del1)
  
			  # calculation of gamma
			  mc_g1 <- (payoff_s11-2*payoffs + payoff_s12)/(del^2)
			  mc_g2 <- (payoff_s21-2*payoffs + payoff_s22)/(del1^2)
  
			  # calculation of vega
			  #v1 <- sigma1; v2<- sigma2 
			  del <- 0.01*v
			  del1 <- 0.01*v
			  #v1 <- sigma1; v2<- sigma2 
			  #v1<-v; v2<-v
  
			  sv11 <- (s0_1)*exp((r-1/2*(v1+del)^2)*M_T + (v1+del)*(M_T^0.5)*z[1,])
			  sv12 <- (s0_1)*exp((r-1/2*(v1-del)^2)*M_T + (v1-del)*(M_T^0.5)*z[1,])
  
			  sv21 <- (s0_2)*exp((r-1/2*(v2+del1)^2)*M_T + (v2+del1)*(M_T^0.5)*z[2,])
			  sv22 <- (s0_2)*exp((r-1/2*(v2-del1)^2)*M_T + (v2-del1)*(M_T^0.5)*z[2,])
  
			  if (cp == "c")
			  {
				CCv11 <- pmax(sv11-s2.t-K,0)
				CCv12 <- pmax(sv12-s2.t-K,0)
				CCv21 <- pmax(s1.t-sv21-K,0)
				CCv22 <- pmax(s1.t-sv22-K,0)
			  }
			  if (cp == "p")
			  {
				CCv11 <- pmax(K-sv11+s2.t,0)
				CCv12 <- pmax(K-sv12+s2.t,0)
				CCv21 <- pmax(K-s1.t+sv21,0)
				CCv22 <- pmax(K-s1.t+sv22,0)
			  }
			  payoff_sv11 <- mean(exp(-r*M_T)*CCv11); payoff_sv12 <- mean(exp(-r*M_T)*CCv12);
			  payoff_sv21 <- mean(exp(-r*M_T)*CCv21); payoff_sv22 <- mean(exp(-r*M_T)*CCv22);
  
			  mc_v1 <- abs(payoff_sv11-payoff_sv12)/(2*del)
			  mc_v2 <- abs(payoff_sv21-payoff_sv22)/(2*del1)
			 # mc_v <- (mc_v1 + mc_v2)
  
			  # calculation of Theta
  
			  del <- 1e-4
			  #v1 <- v; v2<- v
			  st11 <- (s0_1)*exp((r-1/2*v1^2)*(M_T+del) + v1 *((M_T+del)^0.5)*z[1,])
			  st12 <- (s0_1)*exp((r-1/2*v1^2)*(M_T-del) + v1 *((M_T-del)^0.5)*z[1,])
  
			  st21 <- (s0_2)*exp((r-1/2*v2^2)*(M_T+del) + v2*((M_T+del)^0.5)*z[2,])
			  st22 <- (s0_2)*exp((r-1/2*v2^2)*(M_T-del) + v2*((M_T-del)^0.5)*z[2,])
  
			  if (cp == "c")
			  {
				CCt11 <- pmax(st11-s2.t-K,0)
				CCt12 <- pmax(st12-s2.t-K,0)
				CCt21 <- pmax(s1.t-st21-K,0)
				CCt22 <- pmax(s1.t-st22-K,0)
			  }
			  if (cp == "p")
			  {
				CCt11 <- pmax(K-st11+s2.t,0)
				CCt12 <- pmax(K-st12+s2.t,0)
				CCt21 <- pmax(K-s1.t+st21,0)
				CCt22 <- pmax(K-s1.t+st22,0)
			  } 
			  payoff_st11 <- mean(exp(-r*(M_T+del))*CCt11); payoff_st12 <- mean(exp(-r*(M_T-del))*CCt12);
			  payoff_st21 <- mean(exp(-r*(M_T+del))*CCt21); payoff_st22 <- mean(exp(-r*(M_T-del))*CCt22);
  
			  mc_t1 <- (payoff_st11-payoff_st12)/(2*del)
			  mc_t2 <- (payoff_st21-payoff_st22)/(2*del)
			  mc_t <- mc_t1 + mc_t2;
  
			  # calculation of Rho
			  del <- 1e-4
			  v1 <- v; v2<- v 
  
			  sr11 <- (s0_1)*exp(((r+del)-1/2*v1^2)*(M_T) + v1 *((M_T)^0.5)*z[1,])
			  sr12 <- (s0_1)*exp(((r-del)-1/2*v1^2)*(M_T) + v1 *((M_T)^0.5)*z[1,])
  
			  sr21 <- (s0_2)*exp(((r+del)-1/2*v2^2)*(M_T) + v2*((M_T)^0.5)*z[2,])
			  sr22 <- (s0_2)*exp(((r-del)-1/2*v2^2)*(M_T) + v2*((M_T)^0.5)*z[2,])
  
			  if (cp == "c")
			  {
				CCr11 <- pmax(sr11-s2.t-K,0)
				CCr12 <- pmax(sr12-s2.t-K,0)
				CCr21 <- pmax(s1.t-sr21-K,0)
				CCr22 <- pmax(s1.t-sr22-K,0)
			  }
			  if (cp == "p")
			  {
				CCr11 <- pmax(K-sr11+s2.t,0)
				CCr12 <- pmax(K-sr12+s2.t,0)
				CCr21 <- pmax(K-s1.t+sr21,0)
				CCr22 <- pmax(K-s1.t+sr22,0)
			  }
			  payoff_sr11 <- mean(exp(-(r+del)*(M_T))*CCr11); payoff_sr12 <- mean(exp(-(r-del)*(M_T))*CCr12);
			  payoff_sr21 <- mean(exp(-(r+del)*(M_T))*CCr21); payoff_sr22 <- mean(exp(-(r-del)*(M_T))*CCr22);
  
			  mc_r1 <- (payoff_sr11-payoff_sr12)/(2*del)
			  mc_r2 <- (payoff_sr21-payoff_sr22)/(2*del)
			  mc_r <- mc_r1 + mc_r2;
  
			  return(c(mc_d1,mc_g1,mc_v1,mc_t1,mc_r1,mc_d2,mc_g2,mc_v2,mc_t2,mc_r2))
			} 

		US_MC=matrix(0,nrow=npt,ncol=11)
		#nobs <-c(1:npt)
		n<-10000 # number of Monte Carlo paths
		d<- 10   # number of steps per path
		#----------------------Performing simulations-------------------
		for (ik in 1:npt)
		{
		  s0_1 <-as.numeric(Option_data[ik,1]);s0_2 <-as.numeric(Option_data[ik,2]);K <-as.numeric(Option_data[ik,3]);sigma1 <-as.numeric(Option_data[ik,4])
		  sigma2 <-as.numeric(Option_data[ik,5]);r <-as.numeric(Option_data[ik,6]);M_T <-as.numeric(Option_data[ik,7]);rho <-as.numeric(Option_data[ik,8]);
		  cp1 <- as.character(Option_data[ik,9])
		 # EUoption <- Simulation_US_Spark_spread (n,d,Option_data[ik,1],Option_data[ik,2],Option_data[ik,3],Option_data[ik,4],Option_data[ik,5],Option_data[ik,6],Option_data[ik,7],Option_data[ik,8],Option_data[ik,9])
		  USoption <- Simulation_US_Spark_spread (n,d,s0_1,s0_2,K,sigma1,sigma2,r,M_T,rho,cp1)
		  US_MC[ik,] <- USoption
		}
		option_US <- data.frame(Option_data[,11],US_MC[,1],US_MC[,2],US_MC[,3],US_MC[,4], US_MC[,5],US_MC[,6],
								US_MC[,7], US_MC[,8],US_MC[,9], US_MC[,10],US_MC[,11],Option_data[,10],Option_data[,12])
		#----------------------Performing simulations-------------------
		Option_data_out <- option_US''     
		,@input_data_1 =N''SELECT  
		S1,S2,X,V1,V2,R,T,C,CallPutFlag,Method,row_id,attribute_type
		FROM '+@input_table_name+' 
		WHERE Method = ''''45507'''';''

		,@input_data_1_name = N'' Option_data''
		,@output_data_1_name = N'' Option_data_out'' '
		
		SET @r  = 0 
		SET @sqsl = REPLACE(@sql_check,'<<value>>','45507')
		EXEC sp_executesql @sqsl,@param,@re =@r  OUT
		IF @r = 1 
		BEGIN
			EXEC(@sql)
		END 
		
--END



END
