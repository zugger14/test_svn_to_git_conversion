<?php


$check_expire_function = 1; //!< Specifies the client date expiration.
							//!< Possible Values: 0 - Disable | 1 - Enabled

$login_spChars = "_.-"; //!<Specify the special Characters login name can contain.



$role_spChars = "_,&,-, ,'"; //!< Specify the special Characters role name can contain.



$login_integers = '0,1,2,3,4,5,6,7,8,9'; //!< Specify the integers login name should contain.
										 //!< Also its no. of existence in the login name.

$no_of_login_integers = 0; //!< Number of login integers.


$login_letters = 'a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z'; //!< Specify the letters login name should contain.
//!< Also its no. of exitstence in the login name.



$no_of_login_letters = 1;


$min_char_login_name = 2; //!< Specify the minimum no. of characters the login name should have.
//!< Specify the minimum no. of characters the login name should have.


$max_char_login_name = 32; //!< Specify the maximum no. of characters the login name can have.


$admin_name = 'farrms_admin'; //!< Specify the name of the Admin.


$expire_date = 90; //!< Specify the no. of days for password expiration.


$threshold_date = 7; //!< Specify the reminder no. of days for the password expiration.


$pwd_expire_not_apply_to_user = 'farrms_admin'; //!< Specify to whom the expiration doesn't apply.



$allow_login_name = false; //!< Specify if the password can contain the login name.
						   //!< Possible Values: true - can contain the login name. | false - can't contain the login name.


$allow_first_name = false; //!< Specify if the password can contain the first name of the user.
//!< Possible Values: true - can contain the first name of the user. | false - can't contain the first name of the user.


$allow_last_name = false; //!< Specify if the password can contain the last name of the user.
//!< Possible Values: true - can contain the last name of the user. | false - can't contain the last name of the user.


$pwd_min_char = 8; //!< Specify the minimum no. of characters in the password.


$pwd_max_char = 32; //!< Specify the maximum no. of characters in the password.



$can_contain_login_name = true; //!< Specify if the password can have the login name.
//!< Possible Values: true - can have the login name. | false - can't have the login name.



$allow_space = false; //!< Specify if the user can have spaces in the password.
//!< Possible Values: true - can have Spaces in the password.| false - can't' have Spaces in the password.


$must_contain_char = '0,1,2,3,4,5,6,7,8,9'; //!< Specify the integers, password should contain.
//!< Also its no. of existence in the password.


$number_must_contain = 1;


$must_contain_alphabets = 'a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z'; //!< Specfy the letters password should contain.
//!< Also its no. of exitstence in the password.


$alphabets_must_contain = 1;



$character_can_repeat = false; //!< Specify if character repetition check to be done.
//!< Also the maximum no. of repetition allowed.


$no_of_must_contain_char = 1; //!< Specfy the no of must contain special characters.


$first_letter_can_not = ''; //!< Restricts the first character of the user name as specified.


$character_repeat_number = 4; //!< Restricts the repeatation of character in the user name as the number specified.


$last_letter_can_not = ''; //!< Restricts the last character of the user name as specified.



$account_lockout_number_attempts = 3; //!< Number of attempts of login before locking the account.
//!< Possible Values: 0 - Disabled | 0+ - Number of attemps.


$dont_allow_password_reuse_count = 4; //!< Number of password reuse count.
//!< Possible Value: 0 - Disable | 0+ - Number of count.


$account_lockout_time_range = 24; //!< Number of days in hours for invalid login attempts to be checked
//!< Possible Value: For 1 day value should be 24 (in hrs) 
?>