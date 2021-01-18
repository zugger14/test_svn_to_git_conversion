IF OBJECT_ID (N'[dbo].[spa_source_deal_header]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_source_deal_header]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
/**
	Deal template privileges

	Parameters 
	@flag : 
			- s - Selects deal template data
			- t - Returns process table with deal template data
			- x - Returns different messages
			- d - Delete deal template and all its dependent data and saves deleted deal template
			- l - Locks or unlocks a deal 
			- m - Changes deal status
			- y - Updates book info of deal
			- z - Returns priviledge info of sub book
			- w - Checks if a user has priviledge of a book
			- f - Returns actualization flag
			- p - Returns counterparty of a sub book
			- h - Checks if a deal template needs comment

	@filter_xml : Filter Xml
	@deal_ids : Deal Ids
	@comments : Comments for deleting deal
	@process_id : Process Id
	@call_from_import : Call From Import flag
	@lock_unlock : Lock Unlock flag
	@deal_status : Deal Status ID
	@sub_book : Sub Book
	@trans_type : Trans Type
	@call_from : Call From
	@function_id : Function Id
	@subsidiary : Subsidiary
	@book : Book 
	@commodity_id : Commodity ID

*/
CREATE PROCEDURE [dbo].[spa_source_deal_header]
	@flag NCHAR(1),
	@filter_xml XML = NULL,
	@deal_ids NVARCHAR(MAX) = NULL,
	@comments NVARCHAR(MAX) = NULL,
	@process_id NVARCHAR(200) = NULL,
	@call_from_import NCHAR(1) = NULL,
	@lock_unlock NCHAR(1) = NULL,
	@deal_status INT = NULL,
	@sub_book INT = NULL,
	@trans_type INT = NULL,
	@call_from NVARCHAR(100) = NULL,
	@function_id INT = NULL,
	@subsidiary NVARCHAR(MAX) = NULL,
	@book NVARCHAR(MAX) = NULL,
	@commodity_id NVARCHAR(MAX) = NULL
AS

/*--------------Debug Section------------
DECLARE @flag NCHAR(1),
		@filter_xml XML = NULL,
		@deal_ids NVARCHAR(MAX) = NULL,
		@comments NVARCHAR(MAX) = NULL,
		@process_id NVARCHAR(200) = NULL,
		@call_from_import NCHAR(1) = NULL,
		@lock_unlock NCHAR(1) = NULL,
		@deal_status INT = NULL,
		@sub_book INT = NULL,
		@trans_type INT = NULL,
		@call_from NVARCHAR(100) = NULL,
		@function_id INT = NULL,
		@subsidiary NVARCHAR(MAX) = NULL,
		@book NVARCHAR(MAX) = NULL
		
SELECT @flag='t'
,@filter_xml='<Root><FormXML filter_mode="a" book_ids="3806,3770,3755,3749,3752,3845,3848,3847,3846,3850,3844,3849,3703,3704,3705,3706,3707,3708,2558,2572,2567,3709,3710,3125,87,3352,2393,2394,2397,2398,3510,3262,3495,3597,3265,51,3071,3366,3367,3368,3369,3370,3371,3372,3373,3374,3375,3376,3632,1329,54,2878,2715,79,1343,47,2877,48,3151,3152,3153,3154,3155,3156,2699,3629,3507,3108,3310,2895,3311,3111,3312,3317,3318,3346,2923,3713,3853,3783,3412,3411,3413,3385,3410,3415,3414,3328,3474,31,2918,73,174,82,3641,3222,3131,2882,3102,143,144,3105,3106,3080,1352,1383,3123,3047,3028,2693,3029,3038,3625,3120,3658,2561,3615,3274,2602,3053,297,300,1317,2678,2681,2684,2685,2687,2688,1318,1331,3361,3638,1349,3358,3050,2718,3035,1378,2920,269,76,3694,2566,3695,119,3651,121,3652,122,3696,3697,3698,3739,3886,3887,3888,3889,3890,2597,147,258,84,4,2585,2702,3252,3116,3117,2588,3228,2915,3056,2696,3606,3635,3793,3618,3644,3726,3809,1364,1361,256,1339,1340,2970,3321,2709,2909,2967,2872,2873,3103,3100,2581,3128,3160,3161,3162,3163,3164,3165,3166,3167,3168,3169,3170,3323,3325,3157,3158,3159,3513,3516,3515,3517,3514,3519,3518,3544,3814,3812,3489,3488,3490,3462,3487,3492,3491,3798,2886,2887,2891,2892,3268,10,3647,3062,3032,41,43,3603,125,3394,3271,241,242,243,244,245,246,247,248,249,2898,3880,3068,3334,2555,3622,3621,2868,3092,3786,3427,3426,3428,3424,3425,3430,3429,275,2822,2823,2825,2826,2827,2828,2829,2830,2831,2832,2833,2834,2835,2836,2837,2838,2839,2840,2841,2842,2843,2844,2845,2846,2848,2849,2850,2851,2852,2853,2854,2855,2856,2857,2858,2859,2860,2861,2862,3588,3547,3571,3225,3450,3451,3452,3453,3454,3455,3456,3343,3661,3691,3349,7,1368,1369,3171,3172,3173,3174,3175,3176,3177,3178,3179,3180,3181,3182,3183,3184,3185,3186,3187,3188,3189,3190,3191,3192,3193,3194,3195,3196,3197,3198,3199,3200,3201,3202,3203,3204,3205,3206,3207,3208,3209,3210,3211,3212,3213,3214,3215,3216,3217,3218,3219,3836,3837,3839,3838,3840,3841,3539,3540,3541,3525,3523,3524,3461,3682,3683,3403,3556,3440,3438,3441,3437,3436,3439,3443,3442,3400,3418,3417,3419,3388,3416,3421,3420,3340,3501,3500,3502,3498,3499,3504,3503,3337,3433,3043,2906,3095,3355,3594,3086,3259,3723,3089,34,2578,2599,1381,2704,2705,3727,3728,2683,3771,2690,1310,2676,3686,2677,2403,2569,3717,2407,3715,2672,3693,3662,1333,1334,3714,3692,2682,2570,2582,2686,1373,2689,3684,3663,2673,2674,2675,2680,2666,3040,2668,2405,1323,3746,3688,1382,3731,3733,1354,2706,1384,1375,2671,2679,3787,3687,3869,3870,3871,3872,3873,3874,3875,3876,3877,3758,3766,3767,3742,3800,3790,3803,3799,3745,3859,3862,3761,3856,3777" sub_book_ids="4162,4148,4143,4141,4142,4181,4180,4110,4111,4112,4113,4114,4115,3308,3344,3315,4116,4117,3591,68,3480,3491,3481,2249,2250,4067,3903,3902,3901,3908,3905,4021,3268,3269,3270,3271,3272,3273,3274,3275,4008,3745,3740,3831,3999,4046,3741,3742,3743,28,3470,26,27,29,3544,3876,3877,3545,3867,3873,3874,3875,3858,3872,3909,3910,3911,3912,3913,3914,3915,3916,3917,3918,3919,4064,4063,3324,2218,3313,3333,3335,3316,3340,3341,3337,30,2238,35,3417,3476,61,60,63,64,3563,3749,37,59,62,2227,22,23,3477,24,25,3594,3595,3596,3597,3598,3599,3600,3601,3406,3407,4062,4007,3580,3489,3754,3581,3755,3756,3757,4139,3823,3508,4124,4127,4118,4119,4182,4153,3933,3932,3934,3922,3931,3936,3935,3894,3895,3896,3897,3898,3899,3886,3990,34,3345,3506,33,185,186,98,66,4068,3700,3593,3484,3572,3573,81,3541,82,3575,3577,3582,3579,3576,3578,3550,3551,2255,2233,2257,2256,3590,3525,3527,3524,3526,3403,3513,3518,4060,3587,3588,3589,4199,4080,4203,4201,4202,4196,4197,4198,4200,3309,4059,4057,3748,3377,3532,197,198,199,200,2211,2212,2213,2214,2219,2220,3907,4066,2232,3906,3528,3529,3418,3517,3348,3311,3347,3310,2248,3490,3360,3338,3323,3512,3507,3540,182,4102,3314,4103,4104,4105,73,4106,74,4107,4108,4109,4136,4206,4207,4208,4209,4210,4211,4212,4213,4214,4215,3759,3365,83,89,88,86,87,84,85,177,67,2,3358,3359,3408,3716,3584,3585,3361,3705,3499,3500,3501,3502,3503,3504,3505,3533,3404,4054,4065,4157,4058,4070,4071,4128,4129,4163,2241,2260,2240,3346,176,2225,2226,3760,3415,3497,3509,3473,3474,3574,3571,3355,3592,3608,3609,3610,3611,3612,3613,3614,3615,3616,3617,3618,3619,3620,3621,3622,3623,3624,3625,3626,3627,3628,3629,3761,3762,3602,3603,3604,3605,3606,3607,4009,4012,4011,4013,4010,4015,4014,4027,4166,4165,3995,3994,3996,3986,3993,3998,3997,4158,3485,3486,3487,3488,3746,6,7,4,5,8,4072,4073,3536,3514,19,21,4050,4051,4052,75,3925,3747,164,163,158,156,157,168,155,160,161,162,169,165,166,167,159,3492,4204,3539,3952,3951,3953,3810,3950,3955,3954,3306,3471,3565,4154,3946,3945,3947,3943,3944,3949,3948,184,3482,3483,3424,3425,3427,3428,3429,3430,3431,3432,3433,3434,3435,3436,3437,3438,3439,3440,3441,3442,3443,3444,3445,3446,3447,3448,3450,3451,3452,3453,3454,4069,3455,3456,3457,3458,3459,3460,3461,3462,3463,3464,4043,4028,4036,3703,3704,3969,3970,3971,3972,3973,3974,3975,3976,3977,3978,3979,3980,3981,3982,3983,3984,3822,4205,4081,4195,4098,3824,69,3535,181,3,2245,154,3630,3631,3632,3633,3634,3635,3636,3637,3638,3639,3640,3641,3642,3643,3644,3645,3646,3647,3648,3649,3650,3651,3652,3653,3654,3655,3656,3657,3658,3659,3660,3661,3662,3663,3664,3665,3666,3667,3668,3669,3670,3671,3672,3673,3674,3675,3676,3677,3678,3679,3680,3681,3682,3683,3684,3685,3686,3687,3688,3689,3690,3691,3692,3693,3694,3695,3696,3697,3698,3699,4172,4173,4175,4174,4176,4177,4024,4025,4026,4018,4016,4017,3985,4091,4092,3928,4083,4082,4031,4038,3965,3963,3966,3962,3964,3968,3967,3927,3939,3938,3940,3923,3937,3942,3941,3821,4003,4002,4004,4000,4001,4006,4005,3815,3956,3957,3959,3960,3958,3523,3496,3515,3516,3520,3521,3549,3566,3904,4053,4045,3553,3562,3554,3555,3556,3557,3558,3559,3560,3561,3736,3737,3738,3739,3744,3758,3820,4126,3564,4020,16,3354,3362,3570,3373,3583,3586,3376,3367,3366,2251,2253,3711,3410,3725,3708,3734,3411,4130,4131,3395,4149,3405,3402,2207,2205,3389,4095,3390,3277,3278,3317,3318,4122,4123,3281,3282,4121,3530,3531,4100,4101,4084,2221,2222,3569,2224,3391,4120,4099,3394,3342,3343,3469,3397,2243,2244,3398,3401,4093,4085,3386,3387,3388,3393,3472,3409,3414,3519,3522,3279,3280,2216,4140,4097,2252,2254,4132,4134,3412,3413,2264,2265,2246,2247,3709,3383,3723,3732,3706,3710,3392,3568,3724,3707,3733,4155,4096,4186,4187,4188,4189,4190,4191,4192,4193,4194,4144,4146,4147,4137,4160,4156,4161,4159,4138,4184,4185,4145,4183,4151" trader_id="" counterparty_id="" contract_id="" broker_id="" generator_id="" source_deal_header_id_from="" source_deal_header_id_to="" deal_id="" source_system_book_id1="" source_system_book_id2="" source_system_book_id3="" source_system_book_id4="" fas_deal_type_value_id="" view_deleted="n" show_unmapped_deals="n" view_voided="n" view_detail="n" location_group_id="" location_id="" curve_id="" Index_group_id="" formula_curve_id="" formula_id="" 
country="1" region="2" province="3" grid_value_id="4" deal_type_id="" deal_sub_type_id="" field_template_id="" template_id="" commodity_id="" physical_financial_id="" product_id="" internal_desk_id="" deal_volume_uom_id="" buy_sell_id="" pricing_type="" deal_date_from="" deal_date_to="" term_start="" term_end="" settlement_date_from="" settlement_date_to="" payment_date_from="" payment_date_to="" deal_status="" confirm_status_type="" calc_status="" invoice_status="" deal_locked="" create_ts_from="" create_ts_to="" create_user="" update_ts_from="" update_ts_to="" update_user=""></FormXML></Root>'
--*/
 
SET NOCOUNT ON
DECLARE @sql                NVARCHAR(MAX),
        @form_xml           NVARCHAR(MAX),
        @xml_table_name     NVARCHAR(500),
        @desc               NVARCHAR(1000),
        @err_no             INT,
        @locked_deals		NVARCHAR(MAX),
		@transfer_offset_deal_ids NVARCHAR(MAX)
DECLARE @after_update_process_table NVARCHAR(300), @job_name NVARCHAR(200), @job_process_id NVARCHAR(200) = dbo.FNAGETNEWID()
DECLARE @user_name NVARCHAR(100) = dbo.FNADBUser()
DECLARE @return_status BIT = 0
DECLARE @sub_privilege NVARCHAR(MAX) 
DECLARE @err_msg NVARCHAR(MAX)
DECLARE @app_admin_role_check BIT
SET @app_admin_role_check = dbo.FNAAppAdminRoleCheck(@user_name)

IF @user_name =  dbo.FNAAppAdminID() 
BEGIN
	SET @app_admin_role_check = 1
END	
	
IF OBJECT_ID('tempdb..#temp_books') IS NOT NULL
	DROP TABLE #temp_books
IF OBJECT_ID('tempdb..#temp_sub_books') IS NOT NULL
	DROP TABLE #temp_sub_books
IF OBJECT_ID('tempdb..#temp_books_ids') IS NOT NULL
	DROP TABLE #temp_books_ids

CREATE TABLE #temp_books_ids(book_id INT)

CREATE TABLE #temp_books(
	source_system_book_id1     INT,
	source_system_book_id2     INT,
	source_system_book_id3     INT,
	source_system_book_id4     INT,
	sub_book_id				   INT
)

CREATE TABLE #temp_sub_books (sub_book_id INT)

IF @filter_xml IS NOT NULL
BEGIN
	SELECT @form_xml = '<Root>'+CAST(col.query('.') AS NVARCHAR(MAX))+'</Root>'
	FROM @filter_xml.nodes('/Root/FormXML') AS xmlData(col)

	IF @form_xml IS NOT NULL
	BEGIN
		IF OBJECT_ID('tempdb..#xml_process_table_name') IS NOT NULL
			DROP TABLE #xml_process_table_name
			
		CREATE TABLE #xml_process_table_name(table_name NVARCHAR(200) COLLATE DATABASE_DEFAULT)
		
		--DECLARE @xml_table_name NVARCHAR(MAX)
		IF @call_from IS NULL OR @call_from <> 'mobile'
		BEGIN
			SET @process_id = dbo.FNAGetNewID()
		END
			
		SET @user_name = dbo.FNADBUser() 
		SET @xml_table_name = dbo.FNAProcessTableName('xml_data_table', @user_name, @process_id)
		EXEC spa_parse_xml_file 'b', NULL, @form_xml, @xml_table_name -- Load data into @xml_table_name directly.
		
	END
END

IF @xml_table_name IS NOT NULL
BEGIN
        SET @sql = 'INSERT INTO #temp_books_ids (book_id)
			    SELECT val.item 
			    FROM ' + @xml_table_name + ' temp
			    OUTER APPLY (SELECT item FROM dbo.SplitCommaSeperatedValues(temp.book_ids)) val	
				WHERE NULLIF(temp.sub_book_ids, '''') IS NULL
			    GROUP BY val.item
			   '
	EXEC(@sql)
	SET @sql = 'IF EXISTS(SELECT 1 FROM ' + @xml_table_name + ' temp WHERE NULLIF(temp.sub_book_ids, '''') IS NOT NULL)
				BEGIN			    
					INSERT INTO #temp_sub_books (sub_book_id)
					SELECT val.item 
					FROM ' + @xml_table_name + ' temp
					OUTER APPLY (SELECT item FROM dbo.SplitCommaSeperatedValues(temp.sub_book_ids)) val	
					GROUP BY val.item
					UNION ALL 
					SELECT ssbm.book_deal_type_map_id 
					FROM source_system_book_map ssbm 
						INNER JOIN #temp_books_ids tbi 
							ON ssbm.fas_book_id = tbi.book_id
				END
				ELSE IF EXISTS(SELECT 1 FROM #temp_books_ids temp)
				BEGIN
					INSERT INTO #temp_sub_books (sub_book_id)
					SELECT ssbm.book_deal_type_map_id 
					FROM source_system_book_map ssbm 
					INNER JOIN #temp_books_ids tbi 
						ON ssbm.fas_book_id = tbi.book_id
				END
				ELSE
				BEGIN 
					INSERT INTO #temp_sub_books (sub_book_id)
					SELECT ssbm.book_deal_type_map_id
					FROM source_system_book_map ssbm
				END
			   '
	EXEC(@sql)
	
	SET @sql = 'INSERT INTO #temp_books (source_system_book_id1, source_system_book_id2, source_system_book_id3, source_system_book_id4, sub_book_id)
				SELECT ssbm.source_system_book_id1, ssbm.source_system_book_id2, ssbm.source_system_book_id3, ssbm.source_system_book_id4, ssbm.book_deal_type_map_id
				FROM source_system_book_map ssbm 
				INNER JOIN #temp_sub_books temp ON temp.sub_book_id = book_deal_type_map_id
				WHERE 1 = 1 ' +
				CASE WHEN @trans_type IS NOT NULL THEN ' AND ssbm.fas_deal_type_value_id = ' + CAST(@trans_type AS NVARCHAR(8)) ELSE '' END
				+ ' GROUP BY ssbm.source_system_book_id1, ssbm.source_system_book_id2, ssbm.source_system_book_id3, ssbm.source_system_book_id4, ssbm.book_deal_type_map_id
			   '
	EXEC(@sql)
	CREATE NONCLUSTERED INDEX NCI_SSBM1_TB ON #temp_books (source_system_book_id1)
	CREATE NONCLUSTERED INDEX NCI_SSBM2_TB ON #temp_books (source_system_book_id2)
	CREATE NONCLUSTERED INDEX NCI_SSBM3_TB ON #temp_books (source_system_book_id3)
	CREATE NONCLUSTERED INDEX NCI_SSBM4_TB ON #temp_books (source_system_book_id4)
	CREATE NONCLUSTERED INDEX NCI_SBI_TB ON #temp_books (sub_book_id)
END 

IF @flag = 's' OR @flag = 't'
BEGIN
	DECLARE @filter_mode NCHAR(1)
	DECLARE @view_voided NCHAR(1)
	DECLARE @param NVARCHAR(500)
	
	SELECT @sql = N'SELECT @filter_mode = filter_mode FROM ' + @xml_table_name;  
	SET @param = N'@filter_mode NCHAR(1) OUTPUT';
						
	EXEC sp_executesql @sql, @param, @filter_mode=@filter_mode OUTPUT;
	-- Collects fas link detail percentage included Starts
	declare @sql_pc NVARCHAR(2000),  @link_deal_term_used_per NVARCHAR(200)
	if OBJECT_ID(N'tempdb..#temp_per_used') is not null drop table #temp_per_used
	if OBJECT_ID(N'tempdb..#collect_per_inc') is not null drop table #collect_per_inc
	if OBJECT_ID(@link_deal_term_used_per) is not null exec('drop table '+@link_deal_term_used_per)

	CREATE TABLE #temp_per_used (
		source_deal_header_id int,
		term_start date,
		used_per float
	)

	CREATE TABLE #collect_per_inc (
		source_deal_header_id int,
		percentage_included float
	)

	SET @link_deal_term_used_per = dbo.FNAProcessTableName('link_deal_term_used_per', dbo.FNADBUser(), dbo.fnagetnewid())
		
	exec dbo.spa_get_link_deal_term_used_per @as_of_date =NULL,@link_ids=NULL,@header_deal_id =NULL,@term_start=null
			,@no_include_link_id =NULL,@output_type =1	,@include_gen_tranactions  = 'b',@process_table=@link_deal_term_used_per
		
	SET @sql_pc = 'INSERT INTO #temp_per_used (source_deal_header_id  ,term_start,used_per )	
					SELECT source_deal_header_id,	term_start, ROUND(sum(isnull(percentage_used ,1)),2) percentage_used from ' +@link_deal_term_used_per 
					+ ' GROUP BY source_deal_header_id,term_start	'
					
	EXEC(@sql_pc)			
	
	DECLARE @sql_query NVARCHAR(MAX)
	SET @sql_query = 'INSERT INTO #collect_per_inc(source_deal_header_id, percentage_included)
					   SELECT 
						sdh.source_deal_header_id, 
						1-isnull(avg(tpu.used_per),0)
					 FROM source_deal_header sdh 
						INNER JOIN source_deal_detail sdd
							ON sdh.source_deal_header_id = sdd.source_deal_header_id
						INNER JOIN #temp_per_used tpu
							ON sdd.source_deal_header_id = tpu.source_deal_header_id	
								and sdd.term_start = tpu.term_start			
					 GROUP BY sdh.source_deal_header_id ' + 
					 CASE WHEN @call_from='designation_of_hedge' 
						  THEN 'HAVING (1-ISNULL(avg(tpu.used_per),0)) >= 0' 
						  ELSE '' 
					 END

	--INSERT INTO #collect_per_inc(source_deal_header_id, percentage_included)
	EXEC (@sql_query)
	
	CREATE CLUSTERED INDEX collect_per_inc ON #collect_per_inc (source_deal_header_id)
	
	--SELECT * FROM #collect_per_inc
	-- Collects fas link detail percentage included ends
	
	IF @filter_mode = 'g'
	BEGIN
		DECLARE @search_text NVARCHAR(2000)
		
		SELECT @sql = N'SELECT @search_text = search_text FROM ' + @xml_table_name;  
		SET @param = N'@search_text NCHAR(2000) OUTPUT';
							
		EXEC sp_executesql @sql, @param, @search_text=@search_text OUTPUT;
		
		IF OBJECT_ID('tempdb..#temp_searched_deals') IS NOT NULL	
			DROP TABLE #temp_searched_deals
			
		CREATE TABLE #temp_searched_deals (
			id					INT IDENTITY(1,1),
			process_table_name 	NVARCHAR(300) COLLATE DATABASE_DEFAULT,
			deal_id				INT,
			details				NVARCHAR(MAX) COLLATE DATABASE_DEFAULT
		)
		
		INSERT INTO #temp_searched_deals
		EXEC spa_search_engine @flag='s', @searchString= @search_text, @searchTables='deal', @callFrom='d'

		CREATE NONCLUSTERED INDEX NCI_DEAL_ID_TSD ON #temp_searched_deals (deal_id)
	END
	ELSE
	BEGIN
		DECLARE @show_unmapped_deals NCHAR(1)
	
		SELECT @sql = N'SELECT @show_unmapped_deals = show_unmapped_deals FROM ' + @xml_table_name;  
		SET @param = N'@show_unmapped_deals NCHAR(1) OUTPUT';
							
		EXEC sp_executesql @sql, @param, @show_unmapped_deals=@show_unmapped_deals OUTPUT;
		

		SELECT @sql = N'SELECT @view_voided = view_voided FROM ' + @xml_table_name;  
		SET @param = N'@view_voided NCHAR(1) OUTPUT';
							
		EXEC sp_executesql @sql, @param, @view_voided=@view_voided OUTPUT;

		--select @view_voided

		IF OBJECT_ID('tempdb..#temp_filtered_deals') IS NOT NULL	
			DROP TABLE #temp_filtered_deals
		
		IF OBJECT_ID('tempdb..#temp_xml_table') IS NOT NULL	
			DROP TABLE #temp_xml_table
		
		CREATE TABLE #temp_xml_table(
			deal_id                        NVARCHAR(500) COLLATE DATABASE_DEFAULT ,
			trader_id                      NVARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
			contract_id                    NVARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
			counterparty_id                NVARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
			broker_id                      NVARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
			generator_id                   NVARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
			generator					   NVARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
			jurisdiction_id                NVARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
			tier_id						   NVARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
			generation_state_id            NVARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
			location_group_id              NVARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
			location_id					   NVARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
			curve_id                       NVARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
			formula_curve_id			   NVARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
			Index_group_id                 NVARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
			formula_id                     NVARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
			deal_type_id                   NVARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
			deal_sub_type_id               NVARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
			field_template_id              NVARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
			template_id                    NVARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
			commodity_id                   NVARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
			physical_financial_id          NCHAR(1) COLLATE DATABASE_DEFAULT ,
			product_id                     NVARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
			internal_desk_id               NVARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
			deal_volume_uom_id             NVARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
			buy_sell_id                    NCHAR(1) COLLATE DATABASE_DEFAULT ,
			deal_date_from                 NVARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
			deal_date_to                   NVARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
			term_start                     NVARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
			term_end                       NVARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
			settlement_date_from           NVARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
			settlement_date_to             NVARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
			payment_date_from              NVARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
			payment_date_to                NVARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
			deal_status                    NVARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
			confirm_status_type            NVARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
			calc_status                    NVARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
			invoice_status                 NVARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
			deal_locked                    NCHAR(1) COLLATE DATABASE_DEFAULT ,
			create_ts_from                 NVARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
			create_ts_to                   NVARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
			update_ts_from                 NVARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
			update_ts_to                   NVARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
			create_user                    NVARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
			update_user                    NVARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
			source_deal_header_id_from     INT,
			source_deal_header_id_to       INT,
			view_deleted				   NCHAR(1) COLLATE DATABASE_DEFAULT,

			--variables added for tag filter
			source_system_book_id1			INT,
			source_system_book_id2			INT,
			source_system_book_id3			INT,
			source_system_book_id4			INT,
			view_detail					    NCHAR(1) COLLATE DATABASE_DEFAULT,
			fas_deal_type_value_id			INT,
			pricing_type					VARCHAR(1000) COLLATE DATABASE_DEFAULT

			-- added for location group filters
			, country NVARCHAR(MAX) COLLATE DATABASE_DEFAULT
			, region NVARCHAR(MAX) COLLATE DATABASE_DEFAULT
			, province NVARCHAR(MAX) COLLATE DATABASE_DEFAULT
			, grid_value_id NVARCHAR(MAX) COLLATE DATABASE_DEFAULT
 		)
			
		CREATE TABLE #temp_filtered_deals(
			id                        INT IDENTITY(1, 1),
			source_deal_header_id     INT,
			source_deal_detail_id     INT,
			leg                       INT,
			row_no					  INT
		)

		
--generator
--jurisdiction_id
--tier_id
--generation_state_id
--pricing_type
--country
--region
--province
--grid_value_id

		
		SET @sql = 'INSERT INTO #temp_xml_table (deal_id, trader_id, contract_id, counterparty_id, broker_id, generator_id
						, generator
						, jurisdiction_id
						, tier_id, generation_state_id
						, location_group_id, location_id, curve_id, formula_curve_id, Index_group_id, formula_id, deal_type_id, deal_sub_type_id, field_template_id, template_id, commodity_id, physical_financial_id, product_id, internal_desk_id, deal_volume_uom_id, buy_sell_id, deal_date_from, deal_date_to, term_start, term_end, settlement_date_from, settlement_date_to, payment_date_from, payment_date_to, deal_status, confirm_status_type, calc_status, invoice_status, deal_locked, create_ts_from, create_ts_to, update_ts_from, update_ts_to, create_user, update_user, source_deal_header_id_from, source_deal_header_id_to,view_deleted,source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4,view_detail,fas_deal_type_value_id
						, pricing_type
						, country
						, region
						, province
						, grid_value_id)
					SELECT deal_id, trader_id, contract_id, counterparty_id, broker_id, generator_id
						, ' + CASE WHEN @call_from = 'designation_of_hedge' THEN 'NULL' ELSE 'generator' END + ' generator
						, ' + CASE WHEN @call_from = 'designation_of_hedge' THEN 'NULL' ELSE 'jurisdiction_id' END + ' jurisdiction_id
						, ' + CASE WHEN @call_from = 'designation_of_hedge' THEN 'NULL' ELSE 'tier_id' END + ' tier_id
						, ' + CASE WHEN @call_from = 'designation_of_hedge' THEN 'NULL' ELSE 'generation_state_id' END + ' generation_state_id
						, location_group_id, location_id, curve_id, formula_curve_id, Index_group_id, formula_id, deal_type_id, deal_sub_type_id, field_template_id, template_id, commodity_id, physical_financial_id, product_id, internal_desk_id, deal_volume_uom_id, buy_sell_id, deal_date_from, deal_date_to, term_start, term_end, settlement_date_from, settlement_date_to, payment_date_from, payment_date_to, deal_status, confirm_status_type, calc_status, invoice_status, deal_locked, create_ts_from, create_ts_to, update_ts_from, update_ts_to, create_user, update_user, source_deal_header_id_from, source_deal_header_id_to, view_deleted,source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4,view_detail,fas_deal_type_value_id
						, ' + CASE WHEN @call_from = 'designation_of_hedge' THEN 'NULL' ELSE 'pricing_type' END + ' pricing_type
						, ' + CASE WHEN @call_from = 'designation_of_hedge' THEN 'NULL' ELSE 'country' END + ' country
						, ' + CASE WHEN @call_from = 'designation_of_hedge' THEN 'NULL' ELSE 'region' END + ' region
						, ' + CASE WHEN @call_from = 'designation_of_hedge' THEN 'NULL' ELSE 'province' END + ' province
						, ' + CASE WHEN @call_from = 'designation_of_hedge' THEN 'NULL' ELSE 'grid_value_id' END + ' grid_value_id
					FROM ' + @xml_table_name
		EXEC(@sql)


		--INSERT INTO #temp_xml_table (deal_id, trader_id, contract_id, counterparty_id, broker_id, generator_id, location_group_id, location_id, curve_id, formula_curve_id, Index_group_id, formula_id, deal_type_id, deal_sub_type_id, field_template_id, template_id, commodity_id, physical_financial_id, product_id, internal_desk_id, deal_volume_uom_id, buy_sell_id, deal_date_from, deal_date_to, term_start, term_end, settlement_date_from, settlement_date_to, payment_date_from, payment_date_to, deal_status, confirm_status_type, calc_status, invoice_status, deal_locked, create_ts_from, create_ts_to, update_ts_from, update_ts_to, create_user, update_user, source_deal_header_id_from, source_deal_header_id_to,view_deleted,source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4,view_detail,fas_deal_type_value_id, pricing_type)
		--			SELECT deal_id, trader_id, contract_id, counterparty_id, broker_id, generator_id, location_group_id, location_id, curve_id, formula_curve_id, Index_group_id, formula_id, deal_type_id, deal_sub_type_id, field_template_id, template_id, commodity_id, physical_financial_id, product_id, internal_desk_id, deal_volume_uom_id, buy_sell_id, deal_date_from, deal_date_to, term_start, term_end, settlement_date_from, settlement_date_to, payment_date_from, payment_date_to, deal_status, confirm_status_type, calc_status, invoice_status, deal_locked, create_ts_from, create_ts_to, update_ts_from, update_ts_to, create_user, update_user, source_deal_header_id_from, source_deal_header_id_to, view_deleted,source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4,view_detail,fas_deal_type_value_id, pricing_type 
		--			SELECT * FROM adiha_process.dbo.xml_data_table_sa_E2B1698D_52BA_4DF2_9646_1BCED0F0ABA5


		--SELECT @sql
		--return
		EXEC spa_print @sql 

		DECLARE @deal_id                   NVARCHAR(500),
		        @trader_id                 NVARCHAR(MAX),
		        @contract_id               NVARCHAR(MAX),
		        @counterparty_id           NVARCHAR(MAX),
		        @broker_id                 NVARCHAR(MAX),
		        @generator_id              NVARCHAR(MAX),
				@generator                 NVARCHAR(MAX),
				@jurisdiction_id           NVARCHAR(MAX),
				@tier_id				   NVARCHAR(MAX),
				@generation_state_id	   NVARCHAR(MAX),
		        @location_group_id         NVARCHAR(MAX),
		        @location_id			   NVARCHAR(MAX),
		        @curve_id                  NVARCHAR(MAX),
		        @formula_curve_id          NVARCHAR(MAX),
		        @Index_group_id            NVARCHAR(MAX),
		        @formula_id                NVARCHAR(MAX),
		        @deal_type_id              NVARCHAR(MAX),
		        @deal_sub_type_id          NVARCHAR(MAX),
		        @field_template_id         NVARCHAR(MAX),
		        @template_id               NVARCHAR(MAX),
		        @physical_financial_id     NCHAR(1),
		        @product_id                NVARCHAR(MAX),
		        @internal_desk_id          NVARCHAR(MAX),
		        @deal_volume_uom_id        NVARCHAR(MAX),
		        @buy_sell_id               NCHAR(1),
		        @deal_date_from            NVARCHAR(MAX),
		        @deal_date_to              NVARCHAR(MAX),
		        @term_start                NVARCHAR(MAX),
		        @term_end                  NVARCHAR(MAX),
		        @settlement_date_from      NVARCHAR(MAX),
		        @settlement_date_to        NVARCHAR(MAX),
		        @payment_date_from         NVARCHAR(MAX),
		        @payment_date_to           NVARCHAR(MAX),
		        @confirm_status_type       NVARCHAR(MAX),
		        @calc_status               NCHAR(1),
		        @invoice_status            NVARCHAR(MAX),
		        @deal_locked               NCHAR(1),
		        @create_ts_from            DATETIME,
		        @create_ts_to              DATETIME,
		        @update_ts_from            DATETIME,
		        @update_ts_to              DATETIME,
		        @create_user               NVARCHAR(MAX),
		        @update_user               NVARCHAR(MAX),
		        @sdh_id_from			   INT,
		        @sdh_id_to				   INT,
		        @view_deleted			   NCHAR(1),
		        @deal_status_filter		   NVARCHAR(MAX),
		        --VARIABLE ADDED FOR TAG FILTER
				@source_system_book_id1		INT,
				@source_system_book_id2		INT,
				@source_system_book_id3		INT,
				@source_system_book_id4		INT,
				@view_detail			   NCHAR(1),
				@fas_deal_type_value_id		INT,
				@pricing_type_fil			NVARCHAR(MAX)
				, @country NVARCHAR(MAX)
				, @region NVARCHAR(MAX)
				, @province NVARCHAR(MAX)
				, @grid_value_id NVARCHAR(MAX)
		
		SELECT @deal_id					  = NULLIF(deal_id, ''),
		       @trader_id                 = NULLIF(trader_id, ''),
		       @contract_id               = NULLIF(contract_id, ''),
		       @counterparty_id           = NULLIF(counterparty_id, ''),
		       @broker_id                 = NULLIF(broker_id, ''),
		       @generator_id              = NULLIF(generator_id, ''),
			   @generator                 = NULLIF(generator, ''),
			   @jurisdiction_id           = NULLIF(jurisdiction_id, ''),
			   @tier_id					  = NULLIF(tier_id, ''),
			   @generation_state_id		  = NULLIF(generation_state_id, ''),
		       @location_group_id         = NULLIF(location_group_id, ''),
		       @location_id			      = NULLIF(location_id, ''),
		       @curve_id                  = NULLIF(curve_id, ''),
		       @formula_curve_id          = NULLIF(formula_curve_id, ''),
		       @Index_group_id            = NULLIF(Index_group_id, ''),
		       @formula_id                = NULLIF(formula_id, ''),
		       @deal_type_id              = NULLIF(deal_type_id, ''),
		       @deal_sub_type_id          = NULLIF(deal_sub_type_id, ''),
		       @field_template_id         = NULLIF(field_template_id, ''),
		       @template_id               = NULLIF(template_id, ''),
		       @commodity_id              = NULLIF(commodity_id, ''),
		       @physical_financial_id     = NULLIF(physical_financial_id, ''),
		       @product_id                = NULLIF(product_id, ''),
		       @internal_desk_id          = NULLIF(internal_desk_id, ''),
		       @deal_volume_uom_id        = NULLIF(deal_volume_uom_id, ''),
		       @buy_sell_id               = NULLIF(buy_sell_id, ''),
		       @deal_date_from            = NULLIF(deal_date_from, ''),
		       @deal_date_to              = NULLIF(deal_date_to, ''),
		       @term_start                = NULLIF(term_start, ''),
		       @term_end                  = NULLIF(term_end, ''),
		       @settlement_date_from      = NULLIF(settlement_date_from, ''),
		       @settlement_date_to        = NULLIF(settlement_date_to, ''),
		       @payment_date_from         = NULLIF(payment_date_from, ''),
		       @payment_date_to           = NULLIF(payment_date_to, ''),
		       @deal_status_filter        = NULLIF(deal_status, ''),
		       @confirm_status_type       = NULLIF(confirm_status_type, ''),
		       @calc_status               = NULLIF(calc_status, ''),
		       @invoice_status            = NULLIF(invoice_status, ''),
		       @deal_locked               = NULLIF(deal_locked, ''),
		       @create_ts_from            = NULLIF(create_ts_from, ''),
		       @create_ts_to              = NULLIF(create_ts_to, ''),
		       @update_ts_from            = NULLIF(update_ts_from, ''),
		       @update_ts_to              = NULLIF(update_ts_to, ''),
		       @create_user               = NULLIF(create_user, ''),
		       @update_user               = NULLIF(update_user, ''),
		       @sdh_id_from               = NULLIF(source_deal_header_id_from, ''),
		       @sdh_id_to                 = NULLIF(source_deal_header_id_to, ''),
		       @view_deleted			  = NULLIF(view_deleted, ''),

			   --ADDED FOR TAG FILTER
			   @source_system_book_id1	  = NULLIF(source_system_book_id1, ''),
			   @source_system_book_id2	  = NULLIF(source_system_book_id2, ''),
			   @source_system_book_id3	  = NULLIF(source_system_book_id3, ''),
			   @source_system_book_id4	  = NULLIF(source_system_book_id4, ''),
			   @view_detail				  = NULLIF(view_detail, ''),
			   @fas_deal_type_value_id	  = NULLIF(fas_deal_type_value_id, ''),
			   @pricing_type_fil		  = NULLIF(pricing_type, '')

				, @country = NULLIF(country, '')
				, @region = NULLIF(region, '')
				, @province = NULLIF(province, '')
				, @grid_value_id = NULLIF(grid_value_id, '')

		FROM   #temp_xml_table  

		--SELECT @country, @province return
		
		DECLARE @sql_filter    NVARCHAR(MAX),
		        @sql_where     NVARCHAR(MAX)
		       
		SET @sql_filter = ' INSERT INTO #temp_filtered_deals(source_deal_header_id, source_deal_detail_id, leg, row_no)
							SELECT sdh.source_deal_header_id, sdd.source_deal_detail_id, sdd.leg, ROW_NUMBER() OVER(PARTITION BY sdh.source_deal_header_id ORDER BY sdd.term_start, sdd.leg) row_no		
		                    FROM ' + CASE WHEN @view_deleted = 'y' THEN 'delete_' ELSE '' END + 'source_deal_header sdh '
		                    + CASE WHEN @show_unmapped_deals = 'y' THEN 'LEFT JOIN source_system_book_map ' ELSE ' INNER JOIN #temp_books ' END + ' sbmp 
								ON sdh.source_system_book_id1 = sbmp.source_system_book_id1 
								AND sdh.source_system_book_id2 = sbmp.source_system_book_id2 
								AND sdh.source_system_book_id3 = sbmp.source_system_book_id3 
								AND sdh.source_system_book_id4 = sbmp.source_system_book_id4
		                    INNER JOIN ' + CASE WHEN @view_deleted = 'y' THEN 'delete_' ELSE '' END + 'source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
		                    INNER JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id
		                    LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = sdd.location_id
		                    LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = ISNULL(sdd.curve_id, sml.Pricing_Index)	
		                    LEFT JOIN contract_group cg ON cg.contract_id = sdh.contract_id
							LEFT JOIN deal_price_custom_event dpce ON dpce.source_deal_detail_id = sdd.source_deal_detail_id
							LEFT JOIN deal_price_deemed dpd ON dpd.source_deal_detail_id = sdd.source_deal_detail_id
							LEFT JOIN deal_price_std_event dpse ON dpse.source_deal_detail_id = sdd.source_deal_detail_id 
							LEFT JOIN rec_generator rg ON sdh.generator_id = rg.generator_id ' + 
							CASE WHEN @jurisdiction_id IS NOT NULL OR @tier_id IS NOT NULL THEN  '
							LEFT JOIN Gis_Certificate gc ON sdd.source_deal_detail_id =gc.source_deal_header_id
							LEFT JOIN Gis_Product gp ON sdh.source_deal_header_id = gp.source_deal_header_id
							LEFT JOIN eligibility_mapping_template_detail emtd ON rg.eligibility_mapping_template_id = emtd.template_id
		                    ' ELSE '' END

		-- filter by join	
		IF  @invoice_status IS NOT NULL OR @calc_status IS NOT NULL
			SET @sql_filter += ' OUTER APPLY (
		                    		SELECT ISNULL(MAX(cfv.finalized), ''n'') finalized,
		                    			   MAX(cfv.calc_id) calc_id
		                    		FROM calc_formula_value cfv 
		                    		WHERE cfv.deal_id = sdd.source_deal_detail_id
								) cfv
								LEFT JOIN Calc_invoice_Volume_variance civv ON civv.calc_id = cfv.calc_id '

		
		--filter for enviromental @jurisdiction_id (Certificate Detail)
		--IF @jurisdiction_id IS NOT NULL
		--SET @sql_filter += ' OUTER APPLY(
		--						SELECT MAX(gc.state_value_id) [jurisdiction_id] FROM source_deal_detail sdd INNER JOIN Gis_Certificate gc ON sdd.source_deal_detail_id =gc.source_deal_header_id
		--						INNER JOIN dbo.SplitCommaSeperatedValues(''' + @jurisdiction_id   + ''') jurisdiction ON jurisdiction.item = gc.state_value_id WHERE sdh.source_deal_header_id = sdd.source_deal_header_id 
		--					) env_jud '

		--	--filter for enviromental @tier_id (Certificate Detail)
		--IF @tier_id IS NOT NULL
		--SET @sql_filter += ' OUTER APPLY(
		--						SELECT MAX(gc.state_value_id) [jurisdiction_id] FROM source_deal_detail sdd INNER JOIN Gis_Certificate gc ON sdd.source_deal_detail_id =gc.source_deal_header_id
		--						INNER JOIN dbo.SplitCommaSeperatedValues(''' + @tier_id   + ''') jurisdiction ON jurisdiction.item = gc.state_value_id WHERE sdh.source_deal_header_id = sdd.source_deal_header_id
		--					) env_jud '

				--filter for enviromental @jurisdiction_id (Product Detail)
		IF @jurisdiction_id IS NOT NULL
		SET @sql_filter += ' OUTER APPLY(
								SELECT gp_in.jurisdiction_id [jurisdiction_id] FROM Gis_Product gp_in
								INNER JOIN dbo.SplitCommaSeperatedValues(''' + @jurisdiction_id   + ''') jurisdiction ON jurisdiction.item = gp_in.jurisdiction_id WHERE sdh.source_deal_header_id = gp_in.source_deal_header_id AND gp_in.in_or_not = 1 
									--AND AND gp_in.jurisdiction_id <> (SELECT jurisdiction_id FROM Gis_Product gp_ot WHERE  gp_ot.in_or_not = 0 AND gp_ot.source_Deal_header_id = sdh.source_deal_header_id)
								UNION 
								SELECT sdv.value_id [jurisdiction_id]  FROM dbo.SplitCommaSeperatedValues(''' + @jurisdiction_id   + ''') jurisdiction INNER JOIN static_data_value sdv ON jurisdiction.item = sdv.value_id
								WHERE sdv.type_id = 10002 AND sdv.value_id NOT IN (SELECT jurisdiction_id FROM Gis_Product gp_ot WHERE  gp_ot.in_or_not = 0 AND gp_ot.source_Deal_header_id = sdh.source_deal_header_id)
									AND EXISTS( SELECT 1 FROM Gis_Product gp_ot1 WHERE gp_ot1.source_Deal_header_id = sdh.source_deal_header_id AND gp_ot1.in_or_not = 0) AND NOT EXISTS( SELECT 1 FROM Gis_Product gp_ot1 WHERE gp_ot1.source_Deal_header_id = sdh.source_deal_header_id AND gp_ot1.in_or_not = 1)
								UNION 
								SELECT s.state_value_id [jurisdiction_id] FROM state_properties s
								INNER JOIN dbo.SplitCommaSeperatedValues(''' + @jurisdiction_id   + ''') jurisdiction ON jurisdiction.item = s.state_value_id
								INNER JOIN Gis_Product gp_state on 1 = 1
								CROSS APPLY (
									SELECT * FROM dbo.SplitCommaSeperatedValues(gp_state.region_id) scsv
									WHERE scsv.item = gp_state.region_id
								) aa WHERE gp_state.source_deal_header_id = sdh.source_deal_header_id AND gp_state.region_id IS NOT NULL AND gp_state.in_or_not = 1 AND gp_state.jurisdiction_id IS NULL
								UNION 
								SELECT s.state_value_id [jurisdiction_id] FROM state_properties s
								INNER JOIN dbo.SplitCommaSeperatedValues(''' + @jurisdiction_id   + ''') jurisdiction ON jurisdiction.item = s.state_value_id
								INNER JOIN Gis_Product gp_state on 1 = 1
								CROSS APPLY (
									SELECT * FROM dbo.SplitCommaSeperatedValues(gp_state.region_id) scsv
									WHERE scsv.item <> gp_state.region_id
								) aa WHERE gp_state.source_deal_header_id = sdh.source_deal_header_id AND gp_state.region_id IS NOT NULL AND gp_state.in_or_not = 0 AND gp_state.jurisdiction_id IS NULL
								AND EXISTS(SELECT 1 FROM Gis_Product gp_ot1 WHERE gp_ot1.source_Deal_header_id = sdh.source_deal_header_id AND gp_ot1.in_or_not = 0)
								UNION
								SELECT spd.state_value_id [jurisdiction_id] FROM Gis_Product gp INNER JOIN state_properties_details spd ON spd.tier_id = gp.tier_id 
								INNER JOIN dbo.SplitCommaSeperatedValues(''' + @jurisdiction_id   + ''') jurisdiction ON jurisdiction.item = spd.state_value_id
								WHERE gp.jurisdiction_id IS NULL AND gp.region_id IS NULL AND gp.tier_id IS NOT NULL AND gp.in_or_not = 1 AND gp.source_deal_header_id = sdh.source_deal_header_id 
								UNION
								SELECT sdv.value_id [jurisdiction_id]  FROM dbo.SplitCommaSeperatedValues(''' + @jurisdiction_id   + ''') jurisdiction INNER JOIN static_data_value sdv ON jurisdiction.item = sdv.value_id
								WHERE sdv.type_id = 10002 AND sdv.value_id NOT IN (SELECT state_value_id FROM Gis_Product gp_ot INNER JOIN state_properties_details spd ON gp_ot.tier_id = spd.tier_id WHERE  gp_ot.in_or_not = 0 AND gp_ot.source_deal_header_id = sdh.source_deal_header_id AND gp_ot.jurisdiction_id IS NULL AND gp_ot.region_id IS NULL AND gp_ot.tier_id IS NOT NULL)
									AND EXISTS( SELECT 1 FROM Gis_Product gp_ot1 WHERE gp_ot1.source_deal_header_id = sdh.source_deal_header_id AND gp_ot1.in_or_not = 0 AND gp_ot1.jurisdiction_id IS NULL AND gp_ot1.region_id IS NULL AND gp_ot1.tier_id IS NOT NULL)
								) env_jud '
		
	
		--tier
		--filter for enviromental @tier_id (Product Detail)
		IF @tier_id IS NOT NULL
		SET @sql_filter += ' OUTER APPLY(
								SELECT gp_in.tier_id [tier_id] FROM Gis_Product gp_in
								INNER JOIN dbo.SplitCommaSeperatedValues(''' + @tier_id   + ''') tier ON tier.item = gp_in.tier_id WHERE sdh.source_deal_header_id = gp_in.source_deal_header_id AND gp_in.in_or_not = 1 
								UNION 
								SELECT sdv.value_id [tier_id]  FROM dbo.SplitCommaSeperatedValues(''' + @tier_id   + ''') tier INNER JOIN static_data_value sdv ON tier.item = sdv.value_id
								WHERE sdv.type_id = 15000 AND sdv.value_id NOT IN (SELECT tier_id FROM Gis_Product gp_ot WHERE  gp_ot.in_or_not = 0 AND gp_ot.source_Deal_header_id = sdh.source_deal_header_id)
									AND EXISTS( SELECT 1 FROM Gis_Product gp_ot1 WHERE gp_ot1.source_Deal_header_id = sdh.source_deal_header_id AND gp_ot1.in_or_not = 0) AND NOT EXISTS( SELECT 1 FROM Gis_Product gp_ot1 WHERE gp_ot1.source_Deal_header_id = sdh.source_deal_header_id AND gp_ot1.in_or_not = 1)
								UNION 
								SELECT spd.tier_id [tier_id] FROM state_properties s
								INNER JOIN state_properties_details spd ON spd.state_value_id = s.state_value_id
								INNER JOIN dbo.SplitCommaSeperatedValues(''' + @tier_id   + ''') tier ON tier.item = spd.tier_id
								INNER JOIN Gis_Product gp_state on 1 = 1
								CROSS APPLY (
									SELECT * FROM dbo.SplitCommaSeperatedValues(gp_state.region_id) scsv
									WHERE scsv.item = gp_state.region_id
								) aa WHERE gp_state.source_deal_header_id = sdh.source_deal_header_id AND gp_state.region_id IS NOT NULL AND gp_state.in_or_not = 1 AND gp_state.tier_id IS NULL
								UNION 
								SELECT spd.tier_id [tier_id] FROM state_properties s
								INNER JOIN state_properties_details spd ON spd.state_value_id = s.state_value_id
								INNER JOIN dbo.SplitCommaSeperatedValues(''' + @tier_id   + ''') tier ON tier.item = spd.tier_id
								INNER JOIN Gis_Product gp_state on 1 = 1
								CROSS APPLY (
									SELECT * FROM dbo.SplitCommaSeperatedValues(gp_state.region_id) scsv
									WHERE scsv.item <> gp_state.region_id
								) aa WHERE gp_state.source_deal_header_id = sdh.source_deal_header_id AND gp_state.region_id IS NOT NULL AND gp_state.in_or_not = 0 AND gp_state.tier_id IS NULL
								AND EXISTS(SELECT 1 FROM Gis_Product gp_ot1 WHERE gp_ot1.source_Deal_header_id = sdh.source_deal_header_id AND gp_ot1.in_or_not = 0)
								UNION
								SELECT spd.tier_id [tier_id] FROM Gis_Product gp INNER JOIN state_properties_details spd ON spd.state_value_id = gp.jurisdiction_id 
								INNER JOIN dbo.SplitCommaSeperatedValues(''' + @tier_id   + ''') tier ON tier.item = spd.tier_id
								WHERE gp.tier_id IS NULL AND gp.region_id IS NULL AND gp.tier_id IS NOT NULL AND gp.in_or_not = 1 AND gp.source_deal_header_id = sdh.source_deal_header_id 
								UNION
								SELECT sdv.value_id [tier_id]  FROM dbo.SplitCommaSeperatedValues(''' + @tier_id   + ''') tier INNER JOIN static_data_value sdv ON tier.item = sdv.value_id
								WHERE sdv.type_id = 15000 AND sdv.value_id NOT IN (SELECT spd.tier_id FROM Gis_Product gp_ot INNER JOIN state_properties_details spd ON gp_ot.jurisdiction_id = spd.state_value_id WHERE  gp_ot.in_or_not = 0 AND gp_ot.source_deal_header_id = sdh.source_deal_header_id AND gp_ot.tier_id IS NULL AND gp_ot.region_id IS NULL AND gp_ot.tier_id IS NOT NULL)
									AND EXISTS( SELECT 1 FROM Gis_Product gp_ot1 WHERE gp_ot1.source_deal_header_id = sdh.source_deal_header_id AND gp_ot1.in_or_not = 0 AND gp_ot1.tier_id IS NULL AND gp_ot1.region_id IS NULL AND gp_ot1.tier_id IS NOT NULL)
								) env_tier '


		IF @jurisdiction_id IS NOT NULL
			SET @sql_filter += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @jurisdiction_id   + ''') jurisdiction ON jurisdiction.item = COALESCE(gc.state_value_id, env_jud.jurisdiction_id, sdh.state_value_id, emtd.state_value_id)'
		
		IF @tier_id IS NOT NULL
			SET @sql_filter += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @tier_id   + ''') tier ON tier.item = COALESCE(gc.tier_type, env_tier.tier_id, sdh.tier_value_id, emtd.tier_id)'

		IF @generation_state_id IS NOT NULL
			SET @sql_filter += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @generation_state_id   + ''') gen_state ON gen_state.item =rg.gen_state_value_id'

		IF @generator IS NOT NULL
			SET @sql_filter += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @generator   + ''') rec_generator ON rec_generator.item = sdh.generator_id'

		--	--filter for enviromental @tier_id (Product Detail)
		--IF @tier_id IS NOT NULL
		--SET @sql_filter += ' OUTER APPLY(
		--						SELECT MAX(gc.state_value_id) [jurisdiction_id] FROM source_deal_detail sdd INNER JOIN Gis_Certificate gc ON sdd.source_deal_detail_id =gc.source_deal_header_id
		--						INNER JOIN dbo.SplitCommaSeperatedValues(''' + @tier_id   + ''') jurisdiction ON jurisdiction.item = gc.state_value_id WHERE sdh.source_deal_header_id = sdd.source_deal_header_id
		--					) env_jud '

		IF @trader_id IS NOT NULL
			SET @sql_filter += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @trader_id   + ''') trader ON trader.item = sdh.trader_id'

		IF @contract_id IS NOT NULL
			SET @sql_filter += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @contract_id   + ''') contract ON contract.item = sdh.contract_id'

		IF @counterparty_id IS NOT NULL
			SET @sql_filter += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @counterparty_id   + ''') counterparty ON counterparty.item = sdh.counterparty_id'

		IF @broker_id IS NOT NULL
			SET @sql_filter += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @broker_id   + ''') broker ON broker.item = sdh.broker_id'

		IF @generator_id IS NOT NULL
			SET @sql_filter += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @generator_id   + ''') generator ON generator.item = sdh.generator_id'

		IF @location_group_id IS NOT NULL
			SET @sql_filter += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @location_group_id   + ''') location_group ON location_group.item = sml.source_major_location_ID'
		
		IF @location_id IS NOT NULL
			SET @sql_filter += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @location_id   + ''') location ON location.item = sml.source_minor_location_ID'
			
		IF @curve_id IS NOT NULL
			SET @sql_filter += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @curve_id   + ''') curve ON curve.item = spcd.source_curve_def_id'
		
		IF @formula_curve_id IS NOT NULL
			SET @sql_filter += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @formula_curve_id   + ''') formula_curve ON formula_curve.item IN (sdd.formula_curve_id, dpce.pricing_index, dpd.pricing_index, dpse.pricing_index)'

		IF @Index_group_id IS NOT NULL
			SET @sql_filter += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @Index_group_id   + ''') Index_group ON Index_group.item = spcd.index_group'

		IF @formula_id IS NOT NULL
			SET @sql_filter += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @formula_id   + ''') formula ON formula.item = sdd.formula_id'

		IF @deal_type_id IS NOT NULL
			SET @sql_filter += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @deal_type_id   + ''') deal_type ON deal_type.item = sdh.source_deal_type_id'

		IF @deal_sub_type_id IS NOT NULL
			SET @sql_filter += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @deal_sub_type_id   + ''') deal_sub_type ON deal_sub_type.item = sdh.deal_sub_type_type_id'

		IF @field_template_id IS NOT NULL
			SET @sql_filter += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @field_template_id   + ''') field_template ON field_template.item = sdht.field_template_id'

		IF @template_id IS NOT NULL
			SET @sql_filter += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @template_id   + ''') template ON template.item = sdht.template_id'

		IF @commodity_id IS NOT NULL
			SET @sql_filter += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @commodity_id   + ''') commodity ON (commodity.item = sdh.commodity_id OR commodity.item = sdd.detail_commodity_id)'

		IF @product_id IS NOT NULL
			SET @sql_filter += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @product_id   + ''') product ON product.item = sdh.internal_portfolio_id'

		IF @internal_desk_id IS NOT NULL
			SET @sql_filter += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @internal_desk_id   + ''') internal_desk ON internal_desk.item = sdh.internal_desk_id'

		IF @deal_volume_uom_id IS NOT NULL
			SET @sql_filter += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @deal_volume_uom_id   + ''') deal_volume_uom ON deal_volume_uom.item = sdd.deal_volume_uom_id'

		IF @deal_status_filter IS NOT NULL AND @view_voided = 'n'
			SET @sql_filter += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + CAST(@deal_status_filter  AS NVARCHAR(MAX)) + ''') deal_status   ON deal_status.item = sdh.deal_status'

		IF @confirm_status_type IS NOT NULL
			SET @sql_filter += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @confirm_status_type   + ''') confirm_status ON confirm_status.item = sdh.confirm_status_type'

		IF @invoice_status IS NOT NULL
			SET @sql_filter += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @invoice_status   + ''') invoice_status ON invoice_status.item = civv.invoice_status'

		IF @create_user IS NOT NULL
			SET @sql_filter += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @create_user   + ''') create_user ON create_user.item = sdh.create_user'

		IF @update_user IS NOT NULL
			SET @sql_filter += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @update_user   + ''') update_user ON update_user.item = sdh.update_user'		
		
		IF @pricing_type_fil IS NOT NULL 
			SET @sql_filter += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @pricing_type_fil   + ''') pricing_type ON pricing_type.item = sdh.pricing_type'

		
		-- Added for location froup filter
		IF @country IS NOT NULL
			SET @sql_filter += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + CAST(@country  AS NVARCHAR(MAX)) + ''') c ON c.item = sml.country'
		IF @region IS NOT NULL
			SET @sql_filter += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + CAST(@region  AS NVARCHAR(MAX)) + ''') r ON r.item = sml.region'
		IF @province IS NOT NULL
			SET @sql_filter += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + CAST(@province  AS NVARCHAR(MAX)) + ''') p ON p.item = sml.province'
		IF @grid_value_id IS NOT NULL
			SET @sql_filter += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + CAST(@grid_value_id  AS NVARCHAR(MAX)) + ''') gvi ON gvi.item = sml.grid_value_id'

		-- where starts
		SET @sql_where = ' WHERE 1 = 1 '
		
		IF @show_unmapped_deals = 'y'
			SET @sql_where += ' AND sbmp.book_deal_type_map_id IS NULL '
				
		IF @sdh_id_from IS NOT NULL
			SET @sql_where += ' AND sdh.source_deal_header_id >= ' + CAST(@sdh_id_from AS NVARCHAR(20))
		
		IF @sdh_id_to IS NOT NULL
			SET @sql_where += ' AND sdh.source_deal_header_id <= ' + CAST(@sdh_id_to AS NVARCHAR(20))
		ELSE IF @sdh_id_from IS NOT NULL
			SET @sql_where += ' AND sdh.source_deal_header_id <= ' + CAST(@sdh_id_from AS NVARCHAR(20))	
		
		IF @deal_id IS NOT NULL
			SET @sql_where += ' AND sdh.deal_id LIKE ''%' + @deal_id + '%'''
		
		IF @physical_financial_id IS NOT NULL
			SET @sql_where += ' AND sdh.physical_financial_flag = ''' + @physical_financial_id + ''''	
		
		IF @buy_sell_id IS NOT NULL
			SET @sql_where += ' AND sdh.header_buy_sell_flag = ''' + @buy_sell_id + ''''	
		
		IF @deal_locked IS NOT NULL
			SET @sql_where += ' AND sdh.deal_locked = ''' + @deal_locked + ''''	
		
		IF @calc_status IS NOT NULL
			SET @sql_where += ' AND cfv.finalized = ''' + @calc_status   + ''''
			
		IF @deal_date_from IS NOT NULL
			SET @sql_where += ' AND sdh.deal_date >= ''' + CONVERT(NVARCHAR(10), @deal_date_from, 120) + ''''	
		
		IF @deal_date_to IS NOT NULL
			SET @sql_where += ' AND sdh.deal_date <= ''' + CONVERT(NVARCHAR(10), @deal_date_to, 120) + ''''
		
		IF @term_start IS NOT NULL
			SET @sql_where += ' AND sdd.term_start >= ''' + CONVERT(NVARCHAR(10), @term_start, 120) + ''''	
		
		IF @term_end IS NOT NULL
			SET @sql_where += ' AND sdd.term_end <= ''' + CONVERT(NVARCHAR(10), @term_end, 120) + ''''
			
		IF @settlement_date_from IS NOT NULL
			SET @sql_where += ' AND sdd.settlement_date >= ''' + CONVERT(NVARCHAR(10), @settlement_date_from, 120) + ''''	
		
		IF @settlement_date_to IS NOT NULL
			SET @sql_where += ' AND sdd.settlement_date <= ''' + CONVERT(NVARCHAR(10), @settlement_date_to, 120) + ''''
					
		IF @create_ts_from IS NOT NULL
			SET @sql_where += ' AND CONVERT(NVARCHAR(10), sdh.create_ts, 120) >= ''' + CONVERT(NVARCHAR(10), @create_ts_from, 120) + ''''	
		
		IF @create_ts_to IS NOT NULL
			SET @sql_where += ' AND CONVERT(NVARCHAR(10), sdh.create_ts, 120) <= ''' + CONVERT(NVARCHAR(10), @create_ts_to, 120) + ''''
			
		IF @update_ts_from IS NOT NULL
			SET @sql_where += ' AND CONVERT(NVARCHAR(10), sdh.update_ts, 120) >= ''' + CONVERT(NVARCHAR(10), @update_ts_from, 120) + ''''	
		
		IF @update_ts_to IS NOT NULL
			SET @sql_where += ' AND CONVERT(NVARCHAR(10), sdh.update_ts, 120) <= ''' + CONVERT(NVARCHAR(10), @update_ts_to, 120) + ''''
			
		--ADDED FOR TAG FILTER
		IF @source_system_book_id1 IS NOT NULL
				SET @sql_where += ' AND sdh.source_system_book_id1 ='+ CAST(@source_system_book_id1 AS NVARCHAR(20))	
		IF @source_system_book_id2 IS NOT NULL
				SET @sql_where += ' AND sdh.source_system_book_id2 ='+ CAST(@source_system_book_id2 AS NVARCHAR(20))	
		IF @source_system_book_id3 IS NOT NULL
				SET @sql_where += ' AND sdh.source_system_book_id3 ='+ CAST(@source_system_book_id3 AS NVARCHAR(20))	
		IF @source_system_book_id4 IS NOT NULL
				SET @sql_where += ' AND sdh.source_system_book_id4 ='+ CAST(@source_system_book_id4 AS NVARCHAR(20))
		IF @fas_deal_type_value_id IS NOT NULL
				SET @sql_where +=	' AND sdh.fas_deal_type_value_id ='+ CAST(@fas_deal_type_value_id AS NVARCHAR(20))
			
					
		SET @sql_where += ' GROUP BY sdh.source_deal_header_id, sdd.source_deal_detail_id, sdd.leg, sdd.term_start'
	
		--PRINT(@sql_filter)
		--PRINT(@sql_where)
		EXEC(@sql_filter + @sql_where)

		CREATE NONCLUSTERED INDEX NCI_SOURCE_DEAL_HEADER_ID_TSD ON #temp_filtered_deals (source_deal_header_id)
		CREATE NONCLUSTERED INDEX NCI_SOURCE_DEAL_DETAIL_ID_TSD ON #temp_filtered_deals (source_deal_detail_id)
		CREATE NONCLUSTERED INDEX NCI_SOURCE_DEAL_LEG_TSD ON #temp_filtered_deals (leg)
		CREATE NONCLUSTERED INDEX NCI_SOURCE_DEAL_ROW_NO_TSD ON #temp_filtered_deals (row_no)
	END
	
	
	DECLARE @sql_select NVARCHAR(MAX)
	DECLARE @sql_from NVARCHAR(MAX)
	
	IF OBJECT_ID('tempdb..#temp_calc_formula_value') IS NOT NULL
		DROP TABLE #temp_calc_formula_value

	CREATE TABLE #temp_calc_formula_value (
		finalized NCHAR(1) COLLATE DATABASE_DEFAULT,
		calc_id INT,
		source_deal_header_id INT
	)
	
	IF OBJECT_ID('tempdb..#temp_max_date_pnl') IS NOT NULL
		DROP TABLE #temp_max_date_pnl
	
	CREATE TABLE #temp_max_date_pnl (
		source_deal_header_id INT,
		pnl_as_of_date DATETIME
	)
	
	IF @view_detail = 'y'
	BEGIN
		INSERT INTO #temp_calc_formula_value (finalized, calc_id,source_deal_header_id)
		SELECT finalized, calc_id, source_deal_header_id FROM calc_formula_value WHERE finalized = 'y'
		
		INSERT INTO #temp_max_date_pnl (source_deal_header_id, pnl_as_of_date)
		SELECT source_deal_header_id, MAX(pnl_as_of_date) pnl_as_of_date FROM source_deal_pnl GROUP BY source_deal_header_id
	CREATE NONCLUSTERED INDEX idx_temp_max_date_pnl_pnl_as_of_date ON #temp_max_date_pnl (pnl_as_of_date)
	CREATE NONCLUSTERED INDEX idx_temp_max_date_pnl_source_deal_header_id ON #temp_max_date_pnl (source_deal_header_id)
	END	
    
	IF @call_from = 'mobile'
	BEGIN
		SET @sql_select = CAST('' AS NVARCHAR(MAX)) +  'SELECT  
							dh.source_deal_header_id AS source_deal_header_id,
							dh.deal_id,
							dbo.FNADateFormat(dh.deal_date) deal_date,'
						
		SET @sql_select += ' dh.physical_financial_flag [physical_financial_flag],		
 							CASE WHEN dh.header_buy_sell_flag = ''b'' THEN ''Buy'' ELSE ''Sell''END [buy_sell],					
							CASE WHEN dh.physical_financial_flag =''p'' THEN ''Physical'' ELSE ''Financial'' END as [physical_financial],
 							ISNULL(sdd_co.commodity_name, sco.commodity_name) [commodity],
 							st.trader_name as [trader],
 							sc.counterparty_name [counterparty],
							cg.contract_name [contract],
							dbo.FNADateFormat(dh.entire_term_start) entire_term_start,
							dbo.FNADateFormat(dh.entire_term_end) entire_term_end,
 							dh.header_buy_sell_flag [header_buy_sell_flag],
 							st.source_trader_id [trader_id],
 							sc.source_counterparty_id [counterparty_id],
 							cg.contract_id [contract_id],							
							sdht.template_id [template_id],
							sdht.template_name [template], 
							sdt.source_deal_type_name As deal_type,
							sub_sdt.source_deal_type_name AS deal_sub_type,
							
							sdd.source_minor_location_id [location_id],
							sdd.location_index [location],
							dd.deal_volume_frequency [deal_volume_frequency],							
							case dd.deal_volume_frequency
   							when ''h'' then ''Hourly''
   							when ''d'' then ''Daily''
   							when ''m'' then ''Monthly''
   							when ''a'' then ''Annually''
   							when ''t'' then ''Term''
   							else null
   							  end [deal_volume_frequency_name],
   							  
							[dbo].[FNARemoveTrailingZeroes](dd.deal_volume * CASE WHEN dd.buy_sell_flag=''b'' THEN 1 ELSE -1 END) deal_volume,
							su.source_uom_id [deal_volume_uom_id], 							
							su.uom_name [uom_name],
							
							spcd.source_curve_def_id [curve_id],
							spcd.curve_name [curve_name],
							[dbo].[FNARemoveTrailingZeroes](ABS(ISNULL(dd.fixed_price,(COALESCE(ds.settlement_amount, dp.und_pnl_set)/NULLIF(ISNULL(ds.sds_volume, dp.dp_volume), 0))))) deal_price,
							CASE WHEN ISNULL(dd.fixed_price,(COALESCE(ds.settlement_amount, dp.und_pnl_set)/NULLIF(dd.deal_volume, 0))) IS NULL THEN NULL ELSE scu.currency_name END [Currency],
							STR(COALESCE(ds.settlement_amount, dp.und_pnl_set),20,2) deal_value,
							CASE
								WHEN cfv.finalized = ''y'' THEN ''Final'' 
								ELSE ''Estimate''						
							END estimate_final,
							sdv_ds.code deal_status,
							sdv_confirm.code confirm_status_type,
							CASE WHEN dh.deal_locked = ''y'' THEN ''Yes'' ELSE ''No'' END [deal_lock],
							dh.create_user,
							dbo.FNADateTimeFormat(dh.create_ts,2) create_ts,
							dh.update_user,
							dbo.FNADateTimeFormat(dh.update_ts,2) update_ts,
							sdt.source_deal_type_id,
							sco.source_commodity_id commodity_id,							
							dd.source_deal_detail_id,
							dd.source_deal_group_id group_id,
							sdg11.source_deal_groups_name [deal_group],
							ssbm.logical_name [sub_book_name]				
							'
		
	END
	ELSE
	BEGIN		
		SET @sql_select = CAST('' AS NVARCHAR(MAX)) +  'SELECT  
							dh.source_deal_header_id AS id,
							dh.deal_id,
							dh.deal_date deal_date,
 							CASE WHEN dh.header_buy_sell_flag = ''b'' THEN ''Buy'' ELSE ''Sell''END buy_sell,
							CASE WHEN dh.physical_financial_flag =''p'' THEN ''Physical'' ELSE ''Financial'' END as physical_financial_flag, 
							ISNULL(sdd_co.commodity_name, sco.commodity_name) [commodity],
							st.trader_name as [trader],
							sc.counterparty_name [counterparty],
							cg.contract_name [contract],
							dh.entire_term_start term_start,
							dh.entire_term_end term_end,
							sdht.template_name [Template],
							sdt.source_deal_type_name As deal_type, 
							sub_sdt.source_deal_type_name AS deal_sub_type,
							sdd.location_index,
							[dbo].[FNARemoveTrailingZeroes](dd.deal_volume * CASE WHEN dd.buy_sell_flag=''b'' THEN 1 ELSE -1 END) deal_volume,
							su.uom_name [deal_volume_uom_id],
							spcd.curve_name [formula_curve_id],
							dd.location_id,
		'
		IF @view_detail = 'y'
		BEGIN
			SET @sql_select += '
							[dbo].[FNARemoveTrailingZeroes](ABS(ISNULL(dd.fixed_price,(COALESCE(ds.settlement_amount, dp.und_pnl_set)/NULLIF(ISNULL(ds.sds_volume, dp.dp_volume), 0))))) deal_price,
							CASE WHEN ISNULL(dd.fixed_price,(COALESCE(ds.settlement_amount, dp.und_pnl_set)/NULLIF(ISNULL(ds.sds_volume, dp.dp_volume), 0))) IS NULL THEN NULL ELSE scu.currency_name END [currency],
							STR(COALESCE(ds.settlement_amount, dp.und_pnl_set),20,2) deal_value,
							CASE
								WHEN cfv.finalized = ''y'' THEN ''Final'' 
								ELSE ''Estimate''						
							END estimate_final,
						'
							
		END
		ELSE
		BEGIN
			SET @sql_select += '
							NULL deal_price,
							NULL [currency],
							NULL deal_value,
							NULL estimate_final,
							
						'
		END			
		SET @sql_select += '
							sdv_ds.code deal_status,
							' + CASE WHEN @view_detail = 'y' THEN ' sdv_confirm.code' ELSE ' NULL ' END + ' confirm_status,
							CASE WHEN dh.deal_locked = ''y'' THEN ''Yes'' ELSE ''No'' END [deal_lock],
							dbo.FNADateTimeFormat(dh.create_ts,0) create_date,
							dbo.FNAGetUserName(dh.create_user) create_user,
							dbo.FNADateTimeFormat(dh.update_ts,0) update_date,
							dbo.FNAGetUserName(dh.update_user) update_user '
						
		IF @view_deleted = 'y'
		BEGIN
			SET @sql_select += ', dbo.FNADateTimeFormat(dh.delete_ts,0) delete_ts, dh.delete_user'
		END	
		ELSE 
		BEGIN
			SET @sql_select += ', NULL delete_ts,  NULL delete_user'
		END			
	
		SET @sql_select += CASE WHEN @view_detail = 'y' THEN ', CASE WHEN an.notes_id IS NOT NULL THEN ''Yes'' ELSE ''No'' END [document] ' ELSE ', NULL [document]' END +
							 CASE WHEN @show_unmapped_deals = 'n' THEN ', ssbm.logical_name [sub_book]
																			, subs.[entity_name] [subsidiary]
																			, stra.[entity_name] [strategy]
																			, book.[entity_name] [book]
																			, sdv_fas.[code] [fas_deal_type_value_id]
																			, ISNULL(cpi.percentage_included, 1) [percentage_included] '
									ELSE ', NULL [sub_book], NULL [subsidiary], NULL [strategy], NULL [book], NULL [fas_deal_type_value_id], ISNULL(cpi.percentage_included, 1) [percentage_included]'
								END 
	END
	
	IF @filter_mode = 'g'
	BEGIN	
		SET @sql_from = CAST('' AS NVARCHAR(MAX)) +  ' FROM (SELECT deal_id FROM #temp_searched_deals GROUP BY deal_id) temp 
						  INNER JOIN source_deal_header dh ON dh.source_deal_header_id = temp.deal_id
						  OUTER APPLY (SELECT TOP(1) * FROM source_deal_detail dd WHERE dd.source_deal_header_id = dh.source_deal_header_id AND leg = 1 ORDER BY term_start) dd					  
						'
	END
	ELSE 
	BEGIN
		SET @sql_from = CAST('' AS NVARCHAR(MAX)) +  ' FROM (SELECT * FROM #temp_filtered_deals WHERE row_no = 1 ) temp  
						  INNER JOIN ' + CASE WHEN @view_deleted = 'y' THEN 'delete_' ELSE '' END + 'source_deal_header dh ON dh.source_deal_header_id = temp.source_deal_header_id
						  INNER JOIN ' + CASE WHEN @view_deleted = 'y' THEN 'delete_' ELSE '' END + 'source_deal_detail dd ON dd.source_deal_detail_id = temp.source_deal_detail_id
						'
	END	
	
	SET @sql_from +=  CAST('' AS NVARCHAR(MAX)) +	 CASE WHEN @show_unmapped_deals = 'y' THEN ' LEFT JOIN source_system_book_map ' ELSE ' INNER JOIN #temp_books ' END + '  sbmp 
							ON dh.source_system_book_id1 = sbmp.source_system_book_id1 
							AND dh.source_system_book_id2 = sbmp.source_system_book_id2 
							AND dh.source_system_book_id3 = sbmp.source_system_book_id3 
							AND dh.source_system_book_id4 = sbmp.source_system_book_id4 '
						  + CASE WHEN @show_unmapped_deals = 'y' THEN '' 
							ELSE ' INNER JOIN source_system_book_map ssbm ON sbmp.sub_book_id = ssbm.book_deal_type_map_id 
								  INNER JOIN portfolio_hierarchy book (NOLOCK) ON book.entity_id = ssbm.fas_book_id
								  INNER JOIN portfolio_hierarchy stra (NOLOCK) ON stra.entity_id = book.parent_entity_id
								  INNER JOIN portfolio_hierarchy subs (NOLOCK) ON subs.entity_id = stra.parent_entity_id '
							END + '
						  OUTER APPLY ( 
							SELECT DISTINCT CASE WHEN dh.physical_financial_flag =''p'' THEN sml.location_Name ELSE spcd.curve_name END [location_index],
								   sc.commodity_name,
								   sml.source_major_location_ID,
								   sml.source_minor_location_id
							FROM source_deal_detail sdd 
							LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id
							LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = dd.location_id
							LEFT JOIN source_commodity sc ON sc.source_commodity_id = spcd.commodity_id
							WHERE dd.source_deal_detail_id = sdd.source_deal_detail_id AND dd.leg = 1 
						  ) sdd 
						  INNER JOIN source_deal_header_template sdht ON sdht.template_id = dh.template_id			
						  INNER JOIN source_counterparty sc ON dh.counterparty_id = sc.source_counterparty_id AND sc.int_ext_flag <> ''b''
						  INNER JOIN source_deal_type sdt ON dh.source_deal_type_id = sdt.source_deal_type_id AND sdt.sub_type = ''n''
						  LEFT JOIN source_commodity sco ON sco.source_commodity_id = dh.commodity_id	
						  OUTER APPLY (
						  	SELECT commodity_name 
						  	FROM source_commodity sc 
						  	WHERE sc.source_commodity_id = dd.detail_commodity_id 
						  	AND dd.leg = 1						  	
						  ) sdd_co
						  LEFT JOIN source_currency scu ON scu.source_currency_id = dd.fixed_price_currency_id
						  LEFT JOIN source_uom su ON su.source_uom_id = dd.deal_volume_uom_id
						  LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = dd.formula_curve_id
						  LEFT JOIN source_traders st ON dh.trader_id = st.source_trader_id 
						  LEFT JOIN contract_group cg on cg.contract_id = dh.contract_id
						  LEFT JOIN source_counterparty sc_b ON dh.broker_id = sc_b.source_counterparty_id AND sc_b.int_ext_flag = ''b''
						  LEFT JOIN rec_generator rg ON rg.generator_id = dh.generator_id
						  LEFT JOIN source_deal_type sub_sdt ON dh.deal_sub_type_type_id = sub_sdt.source_deal_type_id AND sub_sdt.sub_type = ''y''
						  LEFT JOIN static_data_value sdv_fas ON dh.fas_deal_type_value_id = sdv_fas.value_id AND sdv_fas.type_id = 400
						 '
						  
	IF @view_detail = 'y'
	BEGIN
		SET @sql_from +=  '
						  LEFT JOIN (
							SELECT sds.source_deal_header_id, 
								   sum(settlement_amount) settlement_amount,
								   SUM(volume) sds_volume
							FROM source_deal_settlement sds 
							GROUP BY sds.source_deal_header_id
						  ) ds ON ds.source_deal_header_id = dh.source_deal_header_id
						  
						  OUTER APPLY (
		                    SELECT ISNULL(MAX(cfv.finalized), ''n'') finalized,
		                    	   MAX(cfv.calc_id) calc_id
		                    FROM #temp_calc_formula_value cfv 
		                    WHERE cfv.source_deal_header_id = ds.source_deal_header_id
						  ) cfv
						  LEFT JOIN (
							SELECT sdp.source_deal_header_id, 
								   sum(und_pnl_set) und_pnl_set,
								   SUM(deal_volume) dp_volume
							FROM source_deal_pnl sdp 
							INNER JOIN #temp_max_date_pnl tmpnl 
								ON tmpnl.pnl_as_of_date = sdp.pnl_as_of_date
								AND tmpnl.source_deal_header_id = sdp.source_deal_header_id
							GROUP BY sdp.source_deal_header_id
						  ) dp ON dp.source_deal_header_id = dh.source_deal_header_id
						  OUTER APPLY (
						  	SELECT TOP(1) 1 [notes_id]
						  	FROM application_notes an 
						  	WHERE an.internal_type_value_id = 33 
						  	AND CASE WHEN an.category_value_id IS NULL THEN an.notes_object_id ELSE '''' END = dh.source_deal_header_id
						  ) an
						  OUTER APPLY (
							SELECT TOP(1) csr.type 
							FROM confirm_status_recent csr
							WHERE csr.source_deal_header_id = dh.source_deal_header_id
							ORDER BY csr.create_ts DESC 
						  ) csr
						  LEFT JOIN static_data_value sdv_confirm ON sdv_confirm.value_id = COALESCE(dh.confirm_status_type,csr.type,17200) 
						  '
						  
	END		  						  
	SET @sql_from +=  '	  LEFT JOIN static_data_value sdv_ds ON sdv_ds.value_id = dh.deal_status
						  
						  
						   LEFT JOIN #collect_per_inc cpi ON cpi.source_deal_header_id = dh.source_deal_header_id

					'
	IF @call_from = 'mobile'
	BEGIN
		SET @sql_from +=  ' LEFT JOIN source_deal_groups sdg11 ON sdg11.source_deal_groups_id = dd.source_deal_group_id'
	END				
	
	SET @sql_from += ' WHERE 1 = 1 ' + CASE WHEN @filter_mode = 'g' THEN ' AND dd.leg = 1  ' ELSE ' AND dd.leg = temp.leg ' END + ''
	
	IF @view_voided = 'y'
	BEGIN
		SET @sql_from += ' AND dh.deal_status = 5607 ' --5607 is internal data type value id which represent deal status Cancelled
	END
	
	-- condition checked for not including canceled when the void deal check box is not checked and deal status combo canceled checked is alos not checked 
	DECLARE @is_canceled_selected NVARCHAR(20) --added to check if the deal status is checked or not in Deal Status combo for option canceled
	IF @deal_status_filter IS NOT NULL
	BEGIN
		SELECT @is_canceled_selected =  CHARINDEX('5607', @deal_status_filter) --if cancelled option is selected on deal status combo @is_canceled_selected will not be zero else zero and 5607 is a static data value for deal ststus canceled 
	END
	ELSE
	BEGIN
		SET @is_canceled_selected = 0
	END
	IF @view_voided = 'n' AND @is_canceled_selected = 0
	BEGIN
		SET @sql_from += ' AND dh.deal_status <> 5607 ' --5607 is internal data type value id which represent deal status Cancelled
	END 
	--IF @call_from = 'mobile'
	--BEGIN
	--	SET @sql_from += ' AND sdht.template_name LIKE ''%mobile%'' '
	--END	
	IF @call_from='designation_of_hedge' 
	BEGIN
		SET @sql_from += ' AND ISNULL(cpi.percentage_included, 1) <> 0 ' --5607 is internal data type value id which represent deal status Cancelled
	END
	
	SET @sql_from += ' ORDER BY dh.source_deal_header_id DESC' 
	
	--PRINT(@sql_select)
	--PRINT(@sql_from)
	--PRINT(SUBSTRING(@sql, 2000, 8000))
	--	
	IF @call_from = 'mobile'
	BEGIN
		DECLARE @mobile_deals_table NVARCHAR(100)
		DECLARE @mobile_user_login_id NVARCHAR(100) = dbo.FNADBUser()
		
		SET @mobile_deals_table = ' INTO ' + dbo.FNAProcessTableName('mobile_deals', @mobile_user_login_id,@process_id) + ' '
	
		EXEC(@sql_select + @mobile_deals_table + @sql_from)
	END
	ELSE
	BEGIN
		IF @flag = 't'
		BEGIN
			DECLARE @paging_process_table  NVARCHAR(200)
			SET @paging_process_table = dbo.FNAProcessTableName('paging_process_table', @user_name, @process_id) 
			
			SET @sql = @sql_select + ' INTO ' + @paging_process_table + @sql_from
			EXEC(@sql)
			SELECT @paging_process_table [process_table]
			RETURN
		END
		ELSE 
		BEGIN
			EXEC(@sql_select + @sql_from)
		END
	END	
END
ELSE IF @flag = 'x'
BEGIN
	DECLARE @comment_required NCHAR(1) = 'y'	
	DECLARE @offset_deals NVARCHAR(MAX)
	DECLARE @transfer_deals NVARCHAR(MAX)
	DECLARE @fas_link_deals NVARCHAR(MAX)
	DECLARE @locked_message NVARCHAR(MAX)
	DECLARE @offset_message NVARCHAR(MAX)
	DECLARE @transfer_message NVARCHAR(MAX)
	DECLARE @fas_link_message NVARCHAR(MAX)
	DECLARE @gen_link_deals NVARCHAR(MAX)
	DECLARE @offset_deals1 NVARCHAR(MAX)
	DECLARE @transfer_deals1 NVARCHAR(MAX)
	DECLARE @delete_original_deal_msg NVARCHAR(MAX)
	DECLARE @match_deals NVARCHAR(MAX), @match_message NVARCHAR(MAX)
	
	IF EXISTS (
		SELECT 1 
		FROM application_functional_users afu 
		WHERE login_id = @user_name 
			AND afu.function_id = 10131011 
			AND afu.entity_id IS NULL
	)
	BEGIN
		SET @return_status = 0
	END
	ELSE IF EXISTS (
			SELECT 1
		FROM application_functional_users afu 
				LEFT JOIN application_security_role asr
					ON afu.role_id = asr.role_id
				LEFT JOIN application_role_user aru
					ON aru.role_id = asr.role_id
		WHERE role_user_flag = 'r'
			AND aru.user_login_id = @user_name
			AND afu.function_id = 10131011
			AND afu.entity_id IS NULL
			OR  @app_admin_role_check = 1
		)
		BEGIN
			SET @return_status = 0
		END
		ELSE
		BEGIN 
		SELECT @sub_privilege = ISNULL(@sub_privilege + ',', '') + item
		FROM (
			SELECT DISTINCT item
			FROM dbo.SplitCommaSeperatedValues(@book) t
			LEFT JOIN (
				SELECT DISTINCT s.item entity_name
				FROM portfolio_hierarchy book
				INNER JOIN portfolio_hierarchy stra
					ON stra.entity_id = book.parent_entity_id
				INNER JOIN portfolio_hierarchy sub
					ON sub.entity_id = stra.parent_entity_id
				LEFT JOIN application_functional_users afu
					ON ISNULL(afu.entity_id, - 1) IN (
							ISNULL(book.entity_id, - 1),
							ISNULL(stra.entity_id, - 1),
							ISNULL(sub.entity_id, - 1)
							)
				LEFT JOIN application_functions af
					ON af.function_id = afu.function_id
				LEFT JOIN application_security_role asr
					ON afu.role_id = asr.role_id
				LEFT JOIN application_role_user aru
					ON aru.role_id = asr.role_id
				INNER JOIN dbo.SplitCommaSeperatedValues(@book) s
					ON book.entity_name = s.item
						OR afu.entity_id IS NULL
				INNER JOIN dbo.SplitCommaSeperatedValues(@subsidiary) t
					ON sub.entity_name = t.item
						OR afu.entity_id IS NULL
				WHERE (
						(
							afu.login_id = @user_name
							OR aru.user_login_id = @user_name
							)
						AND afu.function_id = 10131011
						)
					OR @app_admin_role_check = 1
					OR (book.create_user = @user_name AND afu.login_id IS NULL)
				) sub
				ON t.item = sub.entity_name
			WHERE sub.entity_name IS NULL
			) aa

		IF (@sub_privilege IS NOT NULL)
			SET @return_status = 1
		END

	SET @err_msg = 'You do not have privilege to delete the deal(s) for the following Books: <b>' + @sub_privilege + '</b>'

	IF @return_status = 1
	BEGIN
		EXEC spa_ErrorHandler 
				-1
				, ''
				, 'spa_sourcedealheader'
				, ''
				, @err_msg
				, ''
		RETURN
	END
	
	IF EXISTS(
		SELECT 1
		FROM dbo.SplitCommaSeperatedValues(@deal_ids) scsv 
		INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = scsv.item
		INNER JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id
		WHERE sdht.comments = 'y'
	)
	BEGIN
		SET @comment_required = 'y'
	END
	
	SELECT @locked_deals = COALESCE(@locked_deals + ',', '') + CAST(sdh.source_deal_header_id AS NVARCHAR(20))
	FROM dbo.SplitCommaSeperatedValues(@deal_ids) scsv 
	INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = scsv.item
	WHERE sdh.deal_locked = 'y'
	
	IF @locked_deals IS NOT NULL
	BEGIN
		SET @locked_message = 'There are locked deal(s). ( ' + @locked_deals + ' ). Please unlock deal(s) to delete.'
	END
	
	SELECT @offset_deals = COALESCE(@offset_deals + ',', '') + CAST(scsv.item AS NVARCHAR(20))
	FROM dbo.SplitCommaSeperatedValues(@deal_ids) scsv 
	INNER JOIN source_deal_header sdh 
		ON sdh.deal_reference_type_id = 12503
		AND sdh.source_deal_header_id = scsv.item
		AND sdh.close_reference_id IS NOT NULL

	SELECT @transfer_deals = COALESCE(@transfer_deals + ',', '') + CAST(scsv.item AS NVARCHAR(20))
	FROM dbo.SplitCommaSeperatedValues(@deal_ids) scsv 
	INNER JOIN source_deal_header sdh1
	ON sdh1.source_deal_header_id = scsv.item
	INNER JOIN source_deal_header sdh 
		ON sdh.deal_reference_type_id = 12503
		AND sdh.close_reference_id = scsv.item
	WHERE ISNULL(sdh1.deal_reference_type_id,-1) = 12500

	SELECT @offset_deals1 = COALESCE(@offset_deals1 + ',', '') + CAST(sdh.source_deal_header_id AS NVARCHAR(20))
	FROM dbo.SplitCommaSeperatedValues(@deal_ids) scsv
	INNER JOIN source_deal_header sdh 
		ON sdh.deal_reference_type_id = 12500
		AND sdh.close_reference_id = scsv.item
		AND sdh.close_reference_id IS NOT NULL

	SELECT @transfer_deals1 = COALESCE(@transfer_deals1 + ',', '') + CAST(sdh.source_deal_header_id AS NVARCHAR(20))
	FROM dbo.SplitCommaSeperatedValues(ISNULL(@offset_deals1,@deal_ids)) scsv 
	INNER JOIN source_deal_header sdh 
		ON sdh.deal_reference_type_id = 12503
		AND sdh.close_reference_id = scsv.item
		AND sdh.close_reference_id IS NOT NULL

	DECLARE @deal_with_schedule_deal NVARCHAR(MAX)
	DECLARE @schedule_deals NVARCHAR(MAX)
	DECLARE @schedule_message NVARCHAR(MAX)
	
	IF OBJECT_ID('tempdb..#schedule_deal') IS NOT NULL
		DROP TABLE #schedule_deal

	CREATE TABLE #schedule_deal (
		source_deal_header_id INT,
		transport_deal_id INT
	)

	INSERT INTO #schedule_deal
	SELECT   scsv.item, od.transport_deal_id
	FROM optimizer_detail od
		INNER JOIN source_deal_header sdh
			ON sdh.source_deal_header_id = od.transport_deal_id 
		INNER JOIN source_deal_type sdt 
			ON sdh.source_deal_type_id = sdt.source_deal_type_id 
			AND sdt.source_deal_type_name = 'Transportation'
		INNER JOIN dbo.SplitCommaSeperatedValues(@deal_ids) scsv 
			ON scsv.item = od.source_deal_header_id
	WHERE  od.up_down_stream = 'U'
	UNION
	SELECT   scsv.item, od1.transport_deal_id
	FROM optimizer_detail od
		INNER join optimizer_detail od1
			ON od.transport_deal_id = od1.source_deal_header_id
		INNER JOIN source_deal_header sdh
			ON sdh.source_deal_header_id = od1.transport_deal_id 
		INNER JOIN source_deal_type sdt 
			ON sdh.source_deal_type_id = sdt.source_deal_type_id 
			AND sdt.source_deal_type_name = 'Transportation'
		INNER JOIN dbo.SplitCommaSeperatedValues(@deal_ids) scsv 
			ON scsv.item = od.source_deal_header_id
	WHERE  od.up_down_stream = 'U'
		AND od1.up_down_stream = 'U'


	SELECT @schedule_deals = ISNULL(@schedule_deals + ', ', '') + CAST( sub.transport_deal_id AS NVARCHAR(10))
	FROM  (
		SELECT DISTINCT TOP 5  transport_deal_id FROM #schedule_deal
	) sub

	SELECT @deal_with_schedule_deal =  ISNULL(@deal_with_schedule_deal + ', ', '') +   CAST(sub.source_deal_header_id AS NVARCHAR(10))
	FROM  (
		SELECT distinct TOP 5  source_deal_header_id FROM #schedule_deal
	) sub


	IF EXISTS(	SELECT  COUNT(1)  transport_deal_id
				FROM (
					SELECT DISTINCT transport_deal_id
					FROM #schedule_deal
				) a
				HAVING  COUNT(1) > 5
			)
	BEGIN
		SET @schedule_deals = @schedule_deals + '...'
	
	END

	IF EXISTS( SELECT  COUNT(1)  source_deal_header_id
				FROM (
					SELECT DISTINCT source_deal_header_id
					FROM #schedule_deal
				) a
				HAVING  COUNT(1) > 5
			)
	BEGIN
		SET @deal_with_schedule_deal = @deal_with_schedule_deal + '...'
	END

	
	DECLARE @deal_check NVARCHAR(500)
	SELECT  @deal_check =  item FROM dbo.SplitCommaSeperatedValues(@deal_ids) scsv 

	IF EXISTS (SELECT 1 FROM calc_formula_value cfv
 		INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = cfv.source_deal_header_id
		WHERE cfv.source_deal_header_id in ('' + @deal_check + '') )
	BEGIN 
		DECLARE @msg1 NVARCHAR(3000) = 'Error while deleting deal: ' + 'Invoice Exists for respective deal.'
			EXEC spa_ErrorHandler 
				-1
				, 'Error while deleting deal: Invoice Exists for respective deal.'
				, 'spa_sourcedealheader'
				, 'DB Error'
				, @msg1
				, ''
	RETURN
	END	
		
	IF @offset_deals IS NOT NULL
	BEGIN
		SET @offset_message = 'There are offset deals(s) for some deal(s). ( ' + @offset_deals + ' ). Deleting these deals will also delete offset deals(s). Do you want to continue?'
	END
	
	IF @transfer_deals IS NOT NULL
	BEGIN
		SET @transfer_message = 'The selected deal(s) cannot be deleted. There are transferred deals(s) for some deal(s). ( ' + @transfer_deals + ' ). Please delete the transferred deal first.'
	END

	IF @offset_deals1 IS NOT NULL OR @transfer_deals1 IS NOT NULL
	BEGIN
		SET @delete_original_deal_msg = 'There are offset/transferred deal(s) for some deal(s). Deleting these deals will also delete offset/transferred deals(s). Do you want to continue?'
	END
	
	SELECT @fas_link_deals = COALESCE(@fas_link_deals + ',', '') + CAST(scsv.item AS NVARCHAR(20))
	FROM dbo.SplitCommaSeperatedValues(@deal_ids) scsv 
	INNER JOIN fas_link_detail fld ON scsv.item = fld.source_deal_header_id
	
	IF @fas_link_deals IS NOT NULL
	BEGIN
		SET @fas_link_message = 'The selected deal(s) cannot be deleted. Some deal(s) are mapped to a hedging relationship. ( ' + @fas_link_deals + ' ).'
	END
	
	SELECT @gen_link_deals = COALESCE(@gen_link_deals + ',', '') + CAST(scsv.item AS NVARCHAR(20))
	FROM dbo.SplitCommaSeperatedValues(@deal_ids) scsv 
	INNER JOIN gen_fas_link_detail gfld ON scsv.item = gfld.deal_number

	IF @gen_link_deals IS NOT NULL
	BEGIN
		SET @fas_link_message = 'The selected deal(s) cannot be deleted. Some deal(s) are mapped to a hedging relationship. ( ' + @gen_link_deals + ' ).'
	END

	SELECT @match_deals = COALESCE(@match_deals + ',', '') + CAST(scsv.item AS NVARCHAR(20))
	FROM dbo.SplitCommaSeperatedValues(@deal_ids) scsv 
	INNER JOIN matching_detail md ON md.source_deal_header_id = scsv.item
	GROUP BY scsv.item

	IF @match_deals IS NOT NULL
	BEGIN
		SET @match_message = 'Failed to delete deal(s). Deal(s) ( ' + @match_deals + ' ) used in match.'
	END
	
	IF @schedule_deals IS NOT NULL
	BEGIN
		SET @schedule_message = 'Deleting deal(s)(<b>' + @deal_with_schedule_deal + '</b>) will also remove scheduled deal(s) (<b>' + @schedule_deals + '</b>). Are you sure you want to continue?'
	END 
	
	SELECT @comment_required [comment_required], @locked_message [locked_message], @offset_message [offset_message], @fas_link_message [fas_link_message], @transfer_message [transfer_message], @deal_ids [deal_ids],  @schedule_message [schedule_message] ,@delete_original_deal_msg [delete_original_deal_msg], @match_message [match_message]
END
ELSE IF @flag = 'd'
BEGIN
	DECLARE @delete_deals_table NVARCHAR(100)
	DECLARE @user_login_id NVARCHAR(100) = dbo.FNADBUser()
	
	IF @process_id IS NULL
		SET @process_id = dbo.FNAGetNewID()
		
	SET @delete_deals_table = dbo.FNAProcessTableName('delete_deals', @user_login_id,@process_id)
	
	IF OBJECT_ID(@delete_deals_table) IS NULL
	BEGIN
		EXEC('CREATE TABLE ' + @delete_deals_table + '(source_deal_header_id INT, status NVARCHAR(20), description NVARCHAR(500))')
		
		IF @deal_ids IS NOT NULL
		BEGIN
			SET @sql = 'INSERT INTO ' + @delete_deals_table +  ' (source_deal_header_id)
						SELECT scsv.item
						FROM dbo.SplitCommaSeperatedValues(''' + @deal_ids + ''') scsv'
			EXEC(@sql)
		END
	END
	
	IF OBJECT_ID('tempdb..#temp_deal_delete') IS NOT NULL
		DROP TABLE #temp_deal_delete

	IF OBJECT_ID('tempdb..#temp_deal_header_delete') IS NOT NULL
		DROP TABLE #temp_deal_header_delete
			

	CREATE TABLE #temp_deal_delete(source_deal_detail_id INT,source_deal_header_id INT, deal_type NVARCHAR(50) COLLATE DATABASE_DEFAULT)
	CREATE TABLE #temp_deal_header_delete(source_deal_header_id INT)

	SET @sql = '
				INSERT INTO #temp_deal_delete
				SELECT source_deal_detail_id,
						a.source_deal_header_id AS source_deal_header_id,
						NULL
				FROM ' + @delete_deals_table + ' a
				LEFT JOIN source_deal_detail sdd ON  a.source_deal_header_id = sdd.source_deal_header_id
				--Delete all offset deal of parent deal
				UNION
				SELECT source_deal_detail_id, sdh_offset.source_deal_header_id, NULL
				FROM ' + @delete_deals_table + ' a
				INNER JOIN source_deal_header sdh 
					ON sdh.source_deal_header_id = a.source_deal_header_id
					AND sdh.close_reference_id IS NULL
				INNER JOIN source_deal_header sdh_transfer
					ON sdh_transfer.close_reference_id = sdh.source_deal_header_id
				INNER JOIN source_deal_header sdh_offset
					ON sdh_offset.close_reference_id = sdh_transfer.source_deal_header_id
				LEFT JOIN source_deal_detail sdd 
					ON sdh_offset.source_deal_header_id = sdd.source_deal_header_id
				--Delete all transfer deal of parent deal
				UNION 
				SELECT source_deal_detail_id, sdh_transfer.source_deal_header_id, NULL
				FROM ' + @delete_deals_table + ' a
				INNER JOIN source_deal_header sdh 
					ON sdh.source_deal_header_id = a.source_deal_header_id
					AND sdh.close_reference_id IS NULL
				INNER JOIN source_deal_header sdh_transfer
					ON sdh_transfer.close_reference_id = sdh.source_deal_header_id
				LEFT JOIN source_deal_detail sdd 
					ON sdh_transfer.source_deal_header_id = sdd.source_deal_header_id
				UNION
				SELECT source_deal_detail_id, sdh.close_reference_id AS source_deal_header_id, NULL
				FROM ' + @delete_deals_table + ' a
				INNER JOIN source_deal_header sdh 
					ON sdh.deal_reference_type_id = 12503
					AND sdh.source_deal_header_id = a.source_deal_header_id
					AND sdh.close_reference_id IS NOT NULL
				INNER JOIN source_deal_header sdh_off 
					ON sdh_off.source_deal_header_id = sdh.close_reference_id
					AND sdh_off.close_reference_id IS NOT NULL
				LEFT JOIN source_deal_detail sdd 
					ON sdh_off.source_deal_header_id = sdd.source_deal_header_id
				UNION
				SELECT sdd.source_deal_detail_id, od.transport_deal_id, ''Schedule''
				FROM optimizer_detail od
					INNER JOIN source_deal_header sdh
						ON sdh.source_deal_header_id = od.transport_deal_id 
					INNER JOIN source_deal_detail sdd
						ON sdh.source_deal_header_id = sdd.source_deal_header_id
					INNER JOIN source_deal_type sdt 
						ON sdh.source_deal_type_id = sdt.source_deal_type_id 
						AND sdt.source_deal_type_name = ''Transportation''
					INNER JOIN ' + @delete_deals_table + ' a
						ON od.source_deal_header_id = a.source_deal_header_id
				WHERE od.up_down_stream = ''U''
				UNION
				SELECT sdd.source_deal_detail_id, od1.transport_deal_id , ''Schedule''
				FROM optimizer_detail od
					INNER join optimizer_detail od1
						ON od.transport_deal_id = od1.source_deal_header_id
					INNER JOIN source_deal_header sdh
						ON sdh.source_deal_header_id = od1.transport_deal_id 
					INNER JOIN source_deal_detail sdd
						ON sdh.source_deal_header_id = sdd.source_deal_header_id
					INNER JOIN source_deal_type sdt 
						ON sdh.source_deal_type_id = sdt.source_deal_type_id 
						AND sdt.source_deal_type_name = ''Transportation''
					INNER JOIN ' + @delete_deals_table + ' a
						ON od.source_deal_header_id = a.source_deal_header_id
				WHERE od.up_down_stream = ''U''
					AND od1.up_down_stream = ''U''
	
				'
	EXEC(@sql)
		
	INSERT INTO #temp_deal_header_delete
	SELECT DISTINCT source_deal_header_id FROM #temp_deal_delete
	
	BEGIN TRY
		BEGIN TRAN

		DELETE sdp 
		FROM #temp_deal_delete t
		INNER JOIN source_deal_prepay sdp
			ON t.source_deal_header_id = sdp.source_deal_header_id

		DELETE assignment_audit 
		FROM assignment_audit a 
		INNER JOIN #temp_deal_delete d 
			ON a.source_deal_header_id_from = d.source_deal_detail_id 
			AND assigned_volume = 0
												
		DELETE ua
		FROM assignment_audit ua
		INNER JOIN #temp_deal_delete d ON ua.source_deal_header_id = d.source_deal_detail_id
		
		DELETE unassignment_audit FROM unassignment_audit a 
		INNER JOIN #temp_deal_delete d 
			ON a.source_deal_header_id_from = d.source_deal_detail_id 
			AND assigned_volume = 0
		
		DELETE ua
		FROM unassignment_audit ua
		INNER JOIN #temp_deal_delete d ON ua.source_deal_header_id = d.source_deal_detail_id
			
		DELETE ua
		FROM gis_certificate ua
		INNER JOIN #temp_deal_delete d ON ua.source_deal_header_id = d.source_deal_detail_id

		--udf records to respective delete table
		INSERT INTO [dbo].[delete_user_defined_deal_fields](
			[udf_deal_id],[source_deal_header_id],[udf_template_id],
			[udf_value],[create_user],[create_ts],[update_user],[update_ts]
		)
		SELECT udf.[udf_deal_id],
			   udf.[source_deal_header_id],
			   udf.[udf_template_id],
			   udf.[udf_value],
			   dbo.FNADBUser() [create_user],
			   GETDATE() [create_ts],
			   [update_user],
			   udf.[update_ts]
		FROM [dbo].[user_defined_deal_fields] udf 
		INNER JOIN #temp_deal_header_delete d ON udf.source_deal_header_id = d.source_deal_header_id
			
		INSERT INTO [dbo].[delete_user_defined_deal_detail_fields] (
			[udf_deal_id],[source_deal_detail_id],[udf_template_id],
			[udf_value],[create_user],[create_ts],[update_user],[update_ts]
		)
		SELECT uddf.udf_deal_id, uddf.source_deal_detail_id, uddf.udf_template_id,
				uddf.udf_value, uddf.create_user, uddf.create_ts, uddf.update_user,
				uddf.update_ts
		FROM [user_defined_deal_detail_fields] uddf
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = uddf.source_deal_detail_id
		INNER JOIN #temp_deal_header_delete d ON sdd.source_deal_header_id = d.source_deal_header_id
			
		DELETE udf 
		FROM user_defined_deal_fields udf 
		INNER JOIN #temp_deal_header_delete d ON udf.source_deal_header_id = d.source_deal_header_id

		DELETE dr 
		FROM deal_remarks dr 
		INNER JOIN #temp_deal_header_delete d ON dr.source_deal_header_id = d.source_deal_header_id

		DELETE dr 
		FROM deal_required_document dr 
		INNER JOIN #temp_deal_header_delete d ON dr.source_deal_header_id = d.source_deal_header_id
			
		DELETE udf 
		FROM user_defined_deal_detail_fields udf 
		INNER JOIN #temp_deal_delete d ON udf.source_deal_detail_id = d.source_deal_detail_id
			
		DELETE udf 
		FROM deal_exercise_detail udf 
		INNER JOIN #temp_deal_delete d ON udf.source_deal_detail_id = d.source_deal_detail_id
				
		DELETE udf 
		FROM deal_exercise_detail udf 
		INNER JOIN #temp_deal_delete d ON udf.exercise_deal_id = d.source_deal_detail_id
				
		DELETE udf 
		FROM confirm_status_recent udf 
		INNER JOIN #temp_deal_header_delete d ON udf.source_deal_header_id = d.source_deal_header_id
			
		DELETE udf 
		FROM confirm_status udf 
		INNER JOIN #temp_deal_header_delete d ON udf.source_deal_header_id = d.source_deal_header_id
			
		DELETE udf 
		FROM first_day_gain_loss_decision udf 
		INNER JOIN  #temp_deal_header_delete d ON udf.source_deal_header_id = d.source_deal_header_id

		DELETE udf 
		FROM deal_tagging_audit udf 
		INNER JOIN  #temp_deal_header_delete d ON udf.source_deal_header_id = d.source_deal_header_id
	
		DELETE deal_attestation_form
		FROM deal_attestation_form daf
		INNER JOIN #temp_deal_delete d ON daf.source_deal_detail_id = d.source_deal_detail_id
			
		DELETE embedded_deal
		FROM embedded_deal ed
		INNER JOIN #temp_deal_header_delete d ON ed.source_deal_header_id = d.source_deal_header_id
			
		DELETE inventory_cost_override
		FROM inventory_cost_override ico
		INNER JOIN #temp_deal_header_delete d ON ico.source_deal_header_id = d.source_deal_header_id
			
		DELETE source_deal_detail_lagging
		FROM source_deal_detail_lagging sddlag
		INNER JOIN #temp_deal_header_delete d ON sddlag.source_deal_header_id = d.source_deal_header_id	
		
		-- delete required_documents
		DELETE an
		FROM application_notes an
		INNER JOIN deal_required_document drd ON an.notes_object_id = drd.deal_required_document_id
		INNER JOIN #temp_deal_header_delete d ON drd.source_deal_header_id = d.source_deal_header_id
		WHERE an.category_value_id = 42003
	
		DELETE drd
		FROM deal_required_document drd
		INNER JOIN #temp_deal_header_delete d ON drd.source_deal_header_id = d.source_deal_header_id 

		DELETE ded
		FROM deal_exercise_detail ded
		INNER JOIN #temp_deal_header_delete d ON ded.exercise_deal_id = d.source_deal_header_id	

		DELETE an
		FROM application_notes an
		INNER JOIN #temp_deal_header_delete d 
			ON d.source_deal_header_id = ISNULL(an.parent_object_id, an.notes_object_id)
		WHERE --category_value_id = 42018 AND
			 internal_type_value_id = 33
		
		DECLARE @report_position_process_id NVARCHAR(500)
		DECLARE @report_position_deals NVARCHAR(300)
		SET @report_position_process_id = REPLACE(newid(),'-','_')

		SET @report_position_deals = dbo.FNAProcessTableName('report_position', @user_login_id,@report_position_process_id)
		EXEC ('CREATE TABLE ' + @report_position_deals + '( source_deal_header_id INT, source_deal_detail_id INT, action NCHAR(1) COLLATE DATABASE_DEFAULT)')
				
		EXEC ( 'INSERT INTO ' + @report_position_deals +  ' (source_deal_header_id, source_deal_detail_id, action)
				SELECT source_deal_header_id,
					   source_deal_detail_id,
					   ''d'' [action]
				FROM #temp_deal_delete '
		)
			
		EXEC dbo.spa_maintain_transaction_job @report_position_process_id, 7, NULL, @user_login_id		
			
		DELETE sddh 
		FROM source_deal_detail_hour sddh INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id=sddh.source_deal_detail_id
		INNER JOIN #temp_deal_header_delete d ON sdd.source_deal_header_id = d.source_deal_header_id		
			
			
		--DELETE rhpd 
		--FROM report_hourly_position_deal_main rhpd 
		--INNER JOIN #temp_deal_header_delete d ON rhpd.source_deal_header_id = d.source_deal_header_id
			 
		--DELETE rhpf 
		--FROM report_hourly_position_profile_main rhpf 
		--INNER JOIN #temp_deal_header_delete d ON rhpf.source_deal_header_id = d.source_deal_header_id 
		
		--DELETE rhpd 
		--FROM report_hourly_position_breakdown_main rhpd 
		--INNER JOIN #temp_deal_header_delete d ON rhpd.source_deal_header_id = d.source_deal_header_id 

		DELETE dpbd
		FROM deal_position_break_down dpbd 
		INNER JOIN #temp_deal_header_delete d ON dpbd.source_deal_header_id = d.source_deal_header_id

		UPDATE en 
			SET notes_object_id = NULL
		FROM email_notes en 
			INNER JOIN #temp_deal_header_delete d 
				ON en.notes_object_id = d.source_deal_header_id
		WHERE internal_type_value_id = 33
		
		insert into [dbo].[delete_source_deal_header]
			([source_deal_header_id],[source_system_id],[deal_id],[deal_date]
			,[ext_deal_id],[physical_financial_flag],[structured_deal_id]
			,[counterparty_id],[entire_term_start],[entire_term_end]
			,[source_deal_type_id],[deal_sub_type_type_id],[option_flag]
			,[option_type],[option_excercise_type],[source_system_book_id1]
			,[source_system_book_id2],[source_system_book_id3],[source_system_book_id4]
			,[description1],[description2],[description3],[deal_category_value_id]
			,[trader_id],[internal_deal_type_value_id],[internal_deal_subtype_value_id]
			,[template_id],[header_buy_sell_flag],[broker_id],[generator_id],[status_value_id]
			,[status_date],[assignment_type_value_id],[compliance_year],[state_value_id]
			,[assigned_date],[assigned_by],[generation_source],[aggregate_environment]
			,[aggregate_envrionment_comment],[rec_price],[rec_formula_id],[rolling_avg]
			,[contract_id],[create_user],[create_ts],[update_user],[update_ts],[legal_entity]
			,[internal_desk_id],[product_id],[internal_portfolio_id],[commodity_id]
			,[reference],[deal_locked],[close_reference_id],[block_type],[block_define_id]
			,[granularity_id],[Pricing],[deal_reference_type_id],[unit_fixed_flag]
			,[broker_unit_fees],[broker_fixed_cost],[broker_currency_id],[deal_status]
			,[term_frequency],[option_settlement_date],[verified_by],[verified_date]
			,[risk_sign_off_by],[risk_sign_off_date],[back_office_sign_off_by]
			,[back_office_sign_off_date],[book_transfer_id],[confirm_status_type],delete_ts,delete_user,timezone_id, counterparty_id2,
			trader_id2, inco_terms, governing_law, payment_days, payment_term,
			sample_control, scheduler, arbitration, counterparty2_trader, 
			underlying_options, clearing_counterparty_id, pricing_type, confirmation_type, 
			confirmation_template, sdr, profile_granularity, [certificate], tier_value_id
			,holiday_calendar ,collateral_amount ,collateral_req_per ,collateral_months ,fx_conversion_market, match_type
			,fas_deal_type_value_id
			,reporting_tier_id
			,reporting_jurisdiction_id
			, reporting_group1 
			, reporting_group2 
			, reporting_group3 
			, reporting_group4 
			, reporting_group5 

			)
		SELECT 
			sdh.[source_deal_header_id],sdh.[source_system_id],sdh.[deal_id],sdh.[deal_date]
			,sdh.[ext_deal_id],sdh.[physical_financial_flag],sdh.[structured_deal_id]
			,sdh.[counterparty_id],sdh.[entire_term_start],sdh.[entire_term_end]
			,sdh.[source_deal_type_id],sdh.[deal_sub_type_type_id],sdh.[option_flag]
			,sdh.[option_type],sdh.[option_excercise_type],sdh.[source_system_book_id1]
			,sdh.[source_system_book_id2],sdh.[source_system_book_id3],sdh.[source_system_book_id4]
			,sdh.[description1],sdh.[description2],sdh.[description3],sdh.[deal_category_value_id]
			,sdh.[trader_id],sdh.[internal_deal_type_value_id],sdh.[internal_deal_subtype_value_id]
			,sdh.[template_id],sdh.[header_buy_sell_flag],sdh.[broker_id],sdh.[generator_id],sdh.[status_value_id]
			,sdh.[status_date],sdh.[assignment_type_value_id],sdh.[compliance_year],sdh.[state_value_id]
			,sdh.[assigned_date],sdh.[assigned_by],sdh.[generation_source],sdh.[aggregate_environment]
			,sdh.[aggregate_envrionment_comment],sdh.[rec_price],sdh.[rec_formula_id],sdh.[rolling_avg]
			,sdh.[contract_id],sdh.[create_user], sdh.[create_ts],[update_user],sdh.[update_ts],sdh.[legal_entity]
			,sdh.[internal_desk_id],sdh.[product_id],sdh.[internal_portfolio_id],sdh.[commodity_id]
			,sdh.[reference],sdh.[deal_locked],sdh.[close_reference_id],sdh.[block_type],sdh.[block_define_id]
			,sdh.[granularity_id],sdh.[Pricing],sdh.[deal_reference_type_id],sdh.[unit_fixed_flag]
			,sdh.[broker_unit_fees],sdh.[broker_fixed_cost],sdh.[broker_currency_id],5611--sdh.[deal_status]
			,sdh.[term_frequency],sdh.[option_settlement_date],sdh.[verified_by],sdh.[verified_date]
			,sdh.[risk_sign_off_by],sdh.[risk_sign_off_date],sdh.[back_office_sign_off_by]
			,sdh.[back_office_sign_off_date],sdh.[book_transfer_id],sdh.[confirm_status_type],GETDATE() [delete_ts],dbo.FNADBUser() [delete_user]
			,sdh.timezone_id, sdh.counterparty_id2, sdh.trader_id2, sdh.inco_terms, sdh.governing_law, sdh.payment_days, sdh.payment_term,
			sdh.sample_control, sdh.scheduler, sdh.arbitration, sdh.counterparty2_trader, 
			sdh.underlying_options, sdh.clearing_counterparty_id, sdh.pricing_type, sdh.confirmation_type, 
			sdh.confirmation_template, sdh.sdr, sdh.profile_granularity, sdh.[certificate], sdh.tier_value_id
			, sdh.holiday_calendar ,sdh.collateral_amount ,sdh.collateral_req_per ,sdh.collateral_months ,sdh.fx_conversion_market, sdh.match_type
			, sdh.fas_deal_type_value_id
			, sdh.reporting_tier_id
			, sdh.reporting_jurisdiction_id
			, sdh.reporting_group1 
			, sdh.reporting_group2 
			, sdh.reporting_group3 
			, sdh.reporting_group4 
			, sdh.reporting_group5 
		FROM [dbo].[source_deal_header] sdh 
		INNER JOIN (SELECT DISTINCT source_deal_header_id FROM #temp_deal_delete) d ON sdh.source_deal_header_id = d.source_deal_header_id
				
		INSERT INTO delete_source_deal_groups (
			source_deal_groups_id,
			source_deal_groups_name,
			source_deal_header_id,
			static_group_name,
			quantity
		)
		SELECT 
			sdg.source_deal_groups_id,
			sdg.source_deal_groups_name,
			sdg.source_deal_header_id,
			sdg.static_group_name,
			sdg.quantity
		FROM source_deal_groups sdg 
		INNER JOIN #temp_deal_header_delete d ON sdg.source_deal_header_id = d.source_deal_header_id
		
		insert into [dbo].[delete_source_deal_detail] (
			[source_deal_detail_id],[source_deal_header_id]
			,[term_start],[term_end],[Leg],[contract_expiration_date]
			,[fixed_float_leg],[buy_sell_flag],[curve_id],[fixed_price]
			,[fixed_price_currency_id],[option_strike_price],[deal_volume]
			,[deal_volume_frequency],[deal_volume_uom_id],[block_description]
			,[deal_detail_description],[formula_id],[volume_left],[settlement_volume]
			,[settlement_uom],[create_user],[create_ts],[update_user],[update_ts]
			,[price_adder],[price_multiplier],[settlement_date],[day_count_id]
			,[location_id],[meter_id],[physical_financial_flag],[Booked]
			,[process_deal_status],[fixed_cost],[multiplier],[adder_currency_id]
			,[fixed_cost_currency_id],[formula_currency_id],[price_adder2]
			,[price_adder_currency2],[volume_multiplier2],[total_volume]
			,[pay_opposite],[capacity],delete_ts,delete_user, formula_curve_id, pricing_type
			,pricing_period
			,event_defination
			,apply_to_all_legs
			, source_deal_group_id, detail_commodity_id, detail_pricing
			, actual_volume, contractual_volume, contractual_uom_id, pricing_start, pricing_end, cycle, schedule_volume
			, origin, organic, form, attribute1, attribute2, attribute3, attribute4, attribute5,
			standard_yearly_volume, settlement_currency, price_uom_id, category, profile_code, pv_party, [status], lock_deal_detail
			, position_uom, detail_inco_terms, batch_id, detail_sample_control,
			crop_year, lot, buyer_seller_option, product_description, pricing_type2, position_formula_id,
			fx_conversion_rate, upstream_counterparty, upstream_contract, vintage, shipper_code1, shipper_code2
		)
		SELECT 
			sdd.[source_deal_detail_id],sdd.[source_deal_header_id]
			,sdd.[term_start],sdd.[term_end],sdd.[Leg],sdd.[contract_expiration_date]
			,sdd.[fixed_float_leg],sdd.[buy_sell_flag],sdd.[curve_id],sdd.[fixed_price]
			,sdd.[fixed_price_currency_id],sdd.[option_strike_price],sdd.[deal_volume]
			,sdd.[deal_volume_frequency],sdd.[deal_volume_uom_id],sdd.[block_description]
			,sdd.[deal_detail_description],sdd.[formula_id],sdd.[volume_left],sdd.[settlement_volume]
			,sdd.[settlement_uom],sdd.[create_user],sdd.[create_ts],sdd.[update_user],sdd.[update_ts]
			,sdd.[price_adder],sdd.[price_multiplier],sdd.[settlement_date],sdd.[day_count_id]
			,sdd.[location_id],sdd.[meter_id],sdd.[physical_financial_flag],sdd.[Booked]
			,sdd.[process_deal_status],sdd.[fixed_cost],sdd.[multiplier],sdd.[adder_currency_id]
			,sdd.[fixed_cost_currency_id],sdd.[formula_currency_id],sdd.[price_adder2]
			,sdd.[price_adder_currency2],sdd.[volume_multiplier2],sdd.[total_volume]
			,sdd.[pay_opposite],sdd.[capacity],GETDATE() [delete_ts],dbo.FNADBUser() [delete_user], sdd.formula_curve_id, pricing_type
			,sdd.pricing_period
			,sdd.event_defination
			,sdd.apply_to_all_legs
			,sdd.source_deal_group_id
			,sdd.detail_commodity_id ,sdd.detail_pricing
			,sdd.actual_volume, sdd.contractual_volume, sdd.contractual_uom_id, sdd.pricing_start, sdd.pricing_end, sdd.cycle, sdd.schedule_volume
			, sdd.origin, sdd.organic, sdd.form, sdd.attribute1, sdd.attribute2, sdd.attribute3, sdd.attribute4, sdd.attribute5, sdd.standard_yearly_volume
			, sdd.settlement_currency, sdd.price_uom_id, sdd.category, sdd.profile_code, sdd.pv_party, sdd.[status], sdd.lock_deal_detail
			, sdd.position_uom, sdd.detail_inco_terms, sdd.batch_id, sdd.detail_sample_control,
			sdd.crop_year, sdd.lot, sdd.buyer_seller_option, sdd.product_description, pricing_type2, position_formula_id,
			sdd.fx_conversion_rate, sdd.upstream_counterparty, sdd.upstream_contract, sdd.vintage, sdd.shipper_code1, sdd.shipper_code2
		from [dbo].[source_deal_detail] sdd INNER JOIN #temp_deal_delete d ON sdd.source_deal_detail_id = d.source_deal_detail_id
			
		--delete source_deal_detail from delivery status table.
		DELETE ds 
		FROM delivery_status ds 
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = ds.source_deal_detail_id
		INNER JOIN #temp_deal_header_delete d ON sdd.source_deal_header_id = d.source_deal_header_id

		DELETE dpce
		FROM deal_price_custom_event dpce
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = dpce.source_deal_detail_id
		INNER JOIN #temp_deal_header_delete d ON sdd.source_deal_header_id = d.source_deal_header_id
		
		DELETE dpse
		FROM deal_price_std_event dpse
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = dpse.source_deal_detail_id
		INNER JOIN #temp_deal_header_delete d ON sdd.source_deal_header_id = d.source_deal_header_id
		
		DELETE dpd
		FROM deal_price_deemed dpd
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = dpd.source_deal_detail_id
		INNER JOIN #temp_deal_header_delete d ON sdd.source_deal_header_id = d.source_deal_header_id		
			 
		DELETE ddfu
		FROM deal_detail_formula_udf ddfu
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = ddfu.source_deal_detail_id
		INNER JOIN #temp_deal_header_delete d ON sdd.source_deal_header_id = d.source_deal_header_id	
			 
		DELETE source_deal_detail 
		from source_deal_detail sdd 
		INNER JOIN #temp_deal_delete d ON sdd.source_deal_detail_id = d.source_deal_detail_id
		
		DELETE sdg 
		FROM source_deal_groups sdg
		INNER JOIN  #temp_deal_header_delete d ON sdg.source_deal_header_id = d.source_deal_header_id
			
		DELETE source_deal_header 
		FROM source_deal_header sdh 
		INNER JOIN  #temp_deal_header_delete d ON sdh.source_deal_header_id = d.source_deal_header_id
			 
		--update table deal_voided_in_external with status 'd'
		UPDATE dvie 
		SET tran_status = 'd'
		FROM deal_voided_in_external dvie 
		INNER JOIN #temp_deal_header_delete d ON dvie.source_deal_header_id = d.source_deal_header_id
	
		DECLARE @deleted_deals NVARCHAR(MAX)
		SELECT @deleted_deals = COALESCE(@deleted_deals + ',', '') + CAST(source_deal_header_id AS NVARCHAR(10))
		FROM #temp_deal_delete
		GROUP BY source_deal_header_id
		
		EXEC spa_insert_update_audit 'd', @deleted_deals, @comments
		EXEC spa_master_deal_view 'd', @deleted_deals
		
		--deleting product data 
		DELETE gp 
		FROM gis_product gp 
		INNER JOIN  #temp_deal_header_delete d ON gp.source_deal_header_id = d.source_deal_header_id
		 
		COMMIT TRAN

		IF ISNULL(@call_from_import, 'n') = 'n' OR ISNULL(@call_from, 'n') = 'n'
		BEGIN
			EXEC spa_ErrorHandler 0
				, 'Source Deal Header'
				, 'spa_source_deal_header'
				, 'Success'
				, 'Deal deleted successfully.'
				, ''
		END
	END TRY
	BEGIN CATCH
		IF ISNULL(@call_from_import, 'n') = 'n' OR ISNULL(@call_from, 'n') = 'n'
		BEGIN
			DECLARE @msg NVARCHAR(3000)
			SET @msg = 'Error while deleting deal: ' + ERROR_MESSAGE()
			
			EXEC spa_ErrorHandler 
				-1
				, 'Source Deal Header'
				, 'spa_sourcedealheader'
				, 'DB Error'
				, @msg
				, ''
		END
			
		IF @@TRANCOUNT > 0	
			ROLLBACK TRAN
			
		RETURN
	END CATCH
END
ELSE IF @flag = 'l' -- lock/unlock deals
BEGIN
	BEGIN TRY
		IF OBJECT_ID('tempdb..#temp_deals') IS NOT NULL
			DROP TABLE #temp_deals
		CREATE TABLE #temp_deals (deal_ids INT)
		
		SELECT @transfer_offset_deal_ids = STUFF((SELECT DISTINCT ',' +  CAST(source_deal_header_id AS NVARCHAR(20))
							FROM(
							SELECT sdh_t.source_deal_header_id
							FROM dbo.SplitCommaSeperatedValues(@deal_ids) scsv
							INNER JOIN source_deal_header sdh
								ON sdh.source_deal_header_id = scsv.item
								AND sdh.close_reference_id IS NULL
							INNER JOIN source_deal_header sdh_t
								ON sdh_t.close_reference_id = sdh.source_deal_header_id
							UNION 
							SELECT sdh_o.source_deal_header_id 
							FROM dbo.SplitCommaSeperatedValues(@deal_ids) scsv
							INNER JOIN source_deal_header sdh
								ON sdh.source_deal_header_id = scsv.item
								AND sdh.close_reference_id IS NULL
							INNER JOIN source_deal_header sdh_t
								ON sdh_t.close_reference_id = sdh.source_deal_header_id
							INNER JOIN source_deal_header sdh_o
								ON sdh_o.close_reference_id = sdh_t.source_deal_header_id) tbl
							FOR XML PATH('')), 1, 1, '')

		SELECT @deal_ids = CONCAT(@deal_ids,',' + @transfer_offset_deal_ids)

		UPDATE sdh
		SET deal_locked = @lock_unlock
		OUTPUT INSERTED.source_deal_header_id INTO #temp_deals(#temp_deals.deal_ids)
		FROM source_deal_header sdh
		INNER JOIN dbo.SplitCommaSeperatedValues(@deal_ids) scsv ON sdh.source_deal_header_id = scsv.item
		WHERE ISNULL(sdh.deal_locked, 'n') <> @lock_unlock
		
		DECLARE @audit_ids NVARCHAR(MAX)
		SELECT @audit_ids = COALESCE(@audit_ids + ',', '') + CAST(deal_ids AS NVARCHAR(10))
		FROM #temp_deals
		
		DECLARE @deal_lock_process_id VARCHAR(200) = dbo.FNAGETNEWID()
		DECLARE @alert_process_table VARCHAR(500)
		SET @alert_process_table = 'adiha_process.dbo.alert_deal_' + @deal_lock_process_id + '_ad'
		EXEC ('
			CREATE TABLE ' + @alert_process_table + '(
				source_deal_header_id VARCHAR(1000)
			)
		')
		SET @sql = '
			INSERT INTO ' + @alert_process_table + ' (source_deal_header_id)
 			SELECT td.deal_ids
 			FROM #temp_deals td
		'
		EXEC(@sql)

		EXEC spa_register_event 20601, 10000322, @alert_process_table, 0, @deal_lock_process_id
		
		SET @after_update_process_table = dbo.FNAProcessTableName('after_insert_process_table', @user_name, @job_process_id)
		
		IF OBJECT_ID(@after_update_process_table) IS NOT NULL
		BEGIN
			EXEC('DROP TABLE ' + @after_update_process_table)
		END
				
		EXEC ('CREATE TABLE ' + @after_update_process_table + '(source_deal_header_id INT)')

		SET @sql = 'INSERT INTO ' + @after_update_process_table + '(source_deal_header_id) 
					SELECT item
					FROM dbo.SplitCommaSeperatedValues(''' + @deal_ids + ''')'
		EXEC(@sql)
			
		SET @sql = 'spa_deal_insert_update_jobs ''u'', ''' + @after_update_process_table + ''', ''1,2,3,5,6'''
		SET @job_name = 'spa_deal_insert_update_jobs_' + @job_process_id
 		
		EXEC spa_run_sp_as_job @job_name, @sql, 'spa_deal_insert_update_jobs', @user_name

		SET @desc = 'Deal(s) successfully ' + CASE WHEN @lock_unlock = 'y' THEN ' locked. ' ELSE ' unlocked.' END		
		EXEC spa_ErrorHandler 0
			, 'source_deal_header'
			, 'spa_source_deal_header'
			, 'Success' 
			, @desc
			, ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
 
		SET @desc = 'Fail to ' + CASE WHEN @lock_unlock = 'y' THEN 'lock' ELSE 'unlock' END + ' deal(s). ( Errr Description:' + ERROR_MESSAGE() + ').'
 
		SELECT @err_no = ERROR_NUMBER()
 
		EXEC spa_ErrorHandler @err_no
		   , 'source_deal_header'
		   , 'spa_source_deal_header'
		   , 'Error'
		   , @DESC
		   , ''
	END CATCH
END
ELSE IF @flag = 'm' -- change deal status
BEGIN
	BEGIN TRY
		SELECT @locked_deals = COALESCE(@locked_deals + ',', '') + CAST(sdh.source_deal_header_id AS NVARCHAR(20))
		FROM dbo.SplitCommaSeperatedValues(@deal_ids) scsv 
		INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = scsv.item
		WHERE sdh.deal_locked = 'y'
	
		IF @locked_deals IS NOT NULL
		BEGIN
			SET @locked_message = 'There are locked deal(s). ( ' + @locked_deals + ' ). Please unlock deal(s) to change deal status.'
			EXEC spa_ErrorHandler -1
			   , 'source_deal_header'
			   , 'spa_source_deal_header'
			   , 'Error'
			   , @locked_message
			   , ''
			RETURN
		END
		
		SELECT @transfer_offset_deal_ids = STUFF((SELECT DISTINCT ',' +  CAST(source_deal_header_id AS NVARCHAR(20))
							FROM(
							SELECT sdh_t.source_deal_header_id
							FROM dbo.SplitCommaSeperatedValues(@deal_ids) scsv
							INNER JOIN source_deal_header sdh
								ON sdh.source_deal_header_id = scsv.item
								AND sdh.close_reference_id IS NULL
							INNER JOIN source_deal_header sdh_t
								ON sdh_t.close_reference_id = sdh.source_deal_header_id
							UNION 
							SELECT sdh_o.source_deal_header_id 
							FROM dbo.SplitCommaSeperatedValues(@deal_ids) scsv
							INNER JOIN source_deal_header sdh
								ON sdh.source_deal_header_id = scsv.item
								AND sdh.close_reference_id IS NULL
							INNER JOIN source_deal_header sdh_t
								ON sdh_t.close_reference_id = sdh.source_deal_header_id
							INNER JOIN source_deal_header sdh_o
								ON sdh_o.close_reference_id = sdh_t.source_deal_header_id) tbl
							FOR XML PATH('')), 1, 1, '')

		SELECT @deal_ids = CONCAT(@deal_ids,',' + @transfer_offset_deal_ids)

		UPDATE sdh
		SET deal_status = @deal_status
		FROM source_deal_header sdh
		INNER JOIN dbo.SplitCommaSeperatedValues(@deal_ids) scsv ON sdh.source_deal_header_id = scsv.item

		-- Update Deal Status in Position Tables
		EXEC spa_update_rowid_position @deal_header_ids = @deal_ids
		
		--EXEC spa_insert_update_audit 'u', @deal_ids	
		
		SET @after_update_process_table = dbo.FNAProcessTableName('after_insert_process_table', @user_name, @job_process_id)
		
		IF OBJECT_ID(@after_update_process_table) IS NOT NULL
		BEGIN
			EXEC('DROP TABLE ' + @after_update_process_table)
		END
				
		EXEC ('CREATE TABLE ' + @after_update_process_table + '(source_deal_header_id INT)')

		SET @sql = 'INSERT INTO ' + @after_update_process_table + '(source_deal_header_id) 
					SELECT item
					FROM dbo.SplitCommaSeperatedValues(''' + @deal_ids + ''')'
		EXEC(@sql)
		
		--avoid position calculation step
		SET @sql = 'spa_deal_insert_update_jobs ''u'', ''' + @after_update_process_table + ''', ''3'''

		SET @job_name = 'spa_deal_insert_update_jobs_' + @job_process_id
 		
		EXEC spa_run_sp_as_job @job_name, @sql, 'spa_deal_insert_update_jobs', @user_name

		SET @desc = 'Deal status successfully updated for selected deals.'		
		EXEC spa_ErrorHandler 0
			, 'source_deal_header'
			, 'spa_source_deal_header'
			, 'Success' 
			, @desc
			, ''

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
 
		SET @desc = 'Fail to update deal status for selected deal(s). ( Errr Description:' + ERROR_MESSAGE() + ').'
 
		SELECT @err_no = ERROR_NUMBER()
 
		EXEC spa_ErrorHandler @err_no
		   , 'source_deal_header'
		   , 'spa_source_deal_header'
		   , 'Error'
		   , @DESC
		   , ''
	END CATCH
END

ELSE IF @flag = 'y'
BEGIN
	BEGIN TRY
		DECLARE @book_id NVARCHAR(2500), @sub_id NVARCHAR(2500), @sub_name NVARCHAR(MAX), @book_name NVARCHAR(MAX)

		IF OBJECT_ID('tempdb..#deal_sub_books') IS NOT NULL
			DROP TABLE #deal_sub_books

		CREATE TABLE #deal_sub_books (sub_book_id INT, book_id INT,stra_id INT, sub_id INT,has_privileges INT, flag NCHAR(1) COLLATE DATABASE_DEFAULT, book_name NVARCHAR(200) COLLATE DATABASE_DEFAULT)

		-- collect information for current book 
		INSERT INTO #deal_sub_books(sub_book_id, book_id, stra_id, sub_id, flag, book_name)
		SELECT ssbm.book_deal_type_map_id, book.entity_id, stra.entity_id, subs.entity_id, 'o', ssbm.logical_name
		FROM source_deal_header sdh
		INNER JOIN dbo.SplitCommaSeperatedValues(@deal_ids) scsv ON scsv.item = sdh.source_deal_header_id
		INNER JOIN source_system_book_map ssbm
			ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
			AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
			AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
			AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
		INNER JOIN portfolio_hierarchy book (NOLOCK) ON book.entity_id = ssbm.fas_book_id
		INNER JOIN portfolio_hierarchy stra (NOLOCK) ON stra.entity_id = book.parent_entity_id
		INNER JOIN portfolio_hierarchy subs (NOLOCK) ON subs.entity_id = stra.parent_entity_id
		GROUP BY ssbm.book_deal_type_map_id, book.entity_id, stra.entity_id, subs.entity_id, ssbm.logical_name

		-- collect information for new book
		INSERT INTO #deal_sub_books(sub_book_id, book_id, stra_id, sub_id, flag, book_name)
		SELECT ssbm.book_deal_type_map_id, book.entity_id, stra.entity_id, subs.entity_id, 'n', ssbm.logical_name
		FROM source_system_book_map ssbm
		INNER JOIN portfolio_hierarchy book (NOLOCK) ON book.entity_id = ssbm.fas_book_id
		INNER JOIN portfolio_hierarchy stra (NOLOCK) ON stra.entity_id = book.parent_entity_id
		INNER JOIN portfolio_hierarchy subs (NOLOCK) ON subs.entity_id = stra.parent_entity_id
		WHERE ssbm.book_deal_type_map_id = @sub_book
		GROUP BY ssbm.book_deal_type_map_id, book.entity_id, stra.entity_id, subs.entity_id, ssbm.logical_name

		SET @app_admin_role_check = dbo.FNAAppAdminRoleCheck(@user_name)

		-- if admin, give permission
		IF @app_admin_role_check = 1
		BEGIN
			UPDATE #deal_sub_books 
			SET has_privileges = 1
		END
		-- check permission 
		ELSE
		BEGIN
			IF OBJECT_ID('tempdb..#temp_update_roles') IS NOT NULL
				DROP TABLE #temp_update_roles

			-- if any role is provided the privilege to update, provide permission
			UPDATE temp
			SET has_privileges = ISNULL(temp_r.has_privilege, 0)
			FROM #deal_sub_books temp
			OUTER APPLY (
				SELECT 1 has_privilege
				FROM application_role_user aru
				INNER JOIN application_security_role asr ON asr.role_id = aru.role_id
				INNER JOIN application_functional_users afu 
					ON afu.role_id = aru.role_id
					AND afu.function_id = 10131010
				WHERE aru.user_login_id = @user_name 
				AND	(
						(
							(afu.entity_id = temp.book_id OR afu.entity_id = temp.stra_id OR afu.entity_id = temp.sub_id) 
							AND afu.entity_id IS NOT NULL
						)
					OR afu.entity_id IS NULL
				)
			) temp_r

			-- if any role is not provided the privilege to update, check if user has explicit privilege to update and provide permission
			UPDATE temp
			SET has_privileges = ISNULL(temp_r.has_privilege, 0)
			FROM #deal_sub_books temp
			OUTER APPLY (
				SELECT 1 has_privilege
				FROM application_functional_users afu 
				WHERE afu.function_id = 10131010
				AND afu.login_id = @user_name
				AND	(
						(
							(afu.entity_id = temp.book_id OR afu.entity_id = temp.stra_id OR afu.entity_id = temp.sub_id) 
							AND afu.entity_id IS NOT NULL
						)
					OR afu.entity_id IS NULL
				)
			) temp_r
			WHERE ISNULL(temp.has_privileges, 0) = 0
		END

		-- return if user do not have permission to update deal in current book
		IF EXISTS (SELECT 1 FROM #deal_sub_books WHERE has_privileges = 0 AND flag = 'o')
		BEGIN
			SELECT @sub_name = book_name FROM #deal_sub_books WHERE has_privileges = 0 AND flag = 'o'
			SET @err_msg = 'You do not have privilege to transfer the deals for <b>' + @sub_name + '</b>.'
			EXEC spa_ErrorHandler -1
					, 'spa_source_deal_header'
					, 'spa_source_deal_header'
					, 'Error' 
					, @err_msg
					, ''
			RETURN
		END

		-- return if user do not have permission to update deal in new book
		IF EXISTS (SELECT 1 FROM #deal_sub_books WHERE has_privileges = 0 AND flag = 'n')
		BEGIN
			SELECT @sub_name = book_name FROM #deal_sub_books WHERE has_privileges = 0 AND flag = 'n'
			SET @err_msg = 'You do not have privilege to transfer the deals to <b>' + @sub_name + '</b>.'
			EXEC spa_ErrorHandler -1
					, 'spa_source_deal_header'
					, 'spa_source_deal_header'
					, 'Error' 
					, @err_msg
					, ''
			RETURN
		END

		IF OBJECT_ID('tempdb..#temp_deal_ids') IS NOT NULL
			DROP TABLE #temp_deal_ids
		
		CREATE TABLE #temp_deal_ids (source_deal_header_id INT)
		
		INSERT INTO #temp_deal_ids (source_deal_header_id)
		SELECT scsv.item 
		FROM dbo.SplitCommaSeperatedValues(@deal_ids) scsv	
		INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = scsv.item
		LEFT JOIN source_system_book_map ssbm
			ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
			AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
			AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
			AND ssbm.source_system_book_id4 = sdh.source_system_book_id4			
		WHERE ISNULL(ssbm.book_deal_type_map_id, -1) <> @sub_book
	
		INSERT INTO deal_tagging_audit(source_deal_header_id,
                                           source_system_book_id1,
                                           source_system_book_id2,
                                           source_system_book_id3,
                                           source_system_book_id4
                                          )                                            
		SELECT sdh.source_deal_header_id,
            a.source_system_book_id1,
            a.source_system_book_id2,
            a.source_system_book_id3,
            a.source_system_book_id4
		FROM #temp_deal_ids temp 
		INNER JOIN source_deal_header sdh ON  sdh.source_deal_header_id = temp.source_deal_header_id
		OUTER APPLY (
			SELECT ssbm.source_system_book_id1,
				   ssbm.source_system_book_id2,
				   ssbm.source_system_book_id3,
				   ssbm.source_system_book_id4,
				   ssbm.book_deal_type_map_id
			FROM   source_system_book_map ssbm
			WHERE ssbm.book_deal_type_map_id = @sub_book
		) a		

		UPDATE sdh
		SET    source_system_book_id1 = a.source_system_book_id1,
			   source_system_book_id2 = a.source_system_book_id2,
			   source_system_book_id3 = a.source_system_book_id3,
			   source_system_book_id4 = a.source_system_book_id4,
			   sub_book = a.book_deal_type_map_id,
			   update_user = dbo.FNADBUser(),
			   update_ts = GETDATE()
		FROM #temp_deal_ids temp
		INNER JOIN source_deal_header sdh ON  sdh.source_deal_header_id = temp.source_deal_header_id
		OUTER APPLY (
			SELECT ssbm.source_system_book_id1,
				   ssbm.source_system_book_id2,
				   ssbm.source_system_book_id3,
				   ssbm.source_system_book_id4,
				   ssbm.book_deal_type_map_id
			FROM   source_system_book_map ssbm
			WHERE ssbm.book_deal_type_map_id = @sub_book
		) a	

		SET @after_update_process_table = dbo.FNAProcessTableName('after_insert_process_table', @user_name, @job_process_id)
			
		IF OBJECT_ID(@after_update_process_table) IS NOT NULL
		BEGIN
			EXEC('DROP TABLE ' + @after_update_process_table)
		END
				
		EXEC ('CREATE TABLE ' + @after_update_process_table + '(source_deal_header_id INT)')

		SET @sql = 'INSERT INTO ' + @after_update_process_table + '(source_deal_header_id) 
					SELECT source_deal_header_id FROM #temp_deal_ids'
		EXEC(@sql)
		
		--avoid position calculation step
		SET @sql = 'spa_deal_insert_update_jobs ''u'', ''' + @after_update_process_table + ''', ''3'''

		SET @job_name = 'spa_deal_insert_update_jobs_' + @job_process_id
 		
		EXEC spa_run_sp_as_job @job_name, @sql, 'spa_deal_insert_update_jobs', @user_name

		EXEC spa_ErrorHandler 0
			, 'spa_source_deal_header'
			, 'spa_source_deal_header'
			, 'Success' 
			, 'Changes have been saved successfully'
			, ''
	END TRY
	BEGIN CATCH 
		IF @@TRANCOUNT > 0
		   ROLLBACK
 
		SET @DESC = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'
 
		SELECT @err_no = ERROR_NUMBER()
 
		EXEC spa_ErrorHandler @err_no
		   , 'spa_source_deal_header'
		   , 'spa_source_deal_header'
		   , 'Error'
		   , @DESC
		   , ''
	END CATCH		
END
ELSE IF @flag = 'z'
BEGIN
	IF @app_admin_role_check = 1
	BEGIN
		SELECT 1 has_privilege
		RETURN
	END
	
	IF @deal_ids IS NULL AND @sub_book IS NULL
	BEGIN
		SELECT 1 has_privilege
		RETURN
	END

	IF NULLIF(@sub_book, '') IS NULL AND @deal_ids IS NOT NULL
	BEGIN
		SELECT @sub_book = ssbm.book_deal_type_map_id 
		FROM dbo.SplitCommaSeperatedValues(@deal_ids) scsv	
		INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = scsv.item
		LEFT JOIN source_system_book_map ssbm
			ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
			AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
			AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
			AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
	END

	IF OBJECT_ID('tempdb..#deal_sub_books_privilege') IS NOT NULL
		DROP TABLE #deal_sub_books_privilege

	CREATE TABLE #deal_sub_books_privilege (sub_book_id INT, book_id INT,stra_id INT, sub_id INT,has_privileges INT, flag NCHAR(1) COLLATE DATABASE_DEFAULT, book_name NVARCHAR(200) COLLATE DATABASE_DEFAULT)

	INSERT INTO #deal_sub_books_privilege(sub_book_id, book_id, stra_id, sub_id, flag, book_name)
	SELECT ssbm.book_deal_type_map_id, book.entity_id, stra.entity_id, subs.entity_id, 'n', ssbm.logical_name
	FROM source_system_book_map ssbm
	INNER JOIN portfolio_hierarchy book (NOLOCK) ON book.entity_id = ssbm.fas_book_id
	INNER JOIN portfolio_hierarchy stra (NOLOCK) ON stra.entity_id = book.parent_entity_id
	INNER JOIN portfolio_hierarchy subs (NOLOCK) ON subs.entity_id = stra.parent_entity_id
	WHERE ssbm.book_deal_type_map_id = @sub_book
	GROUP BY ssbm.book_deal_type_map_id, book.entity_id, stra.entity_id, subs.entity_id, ssbm.logical_name

	-- if any role is provided the privilege to update, provide permission
	UPDATE temp
	SET has_privileges = ISNULL(temp_r.has_privilege, 0)
	FROM #deal_sub_books_privilege temp
	OUTER APPLY (
		SELECT 1 has_privilege
		FROM application_role_user aru
		INNER JOIN application_security_role asr ON asr.role_id = aru.role_id
		INNER JOIN application_functional_users afu 
			ON afu.role_id = aru.role_id
			AND afu.function_id = @function_id
		WHERE aru.user_login_id = @user_name 
		AND	(
				(
					(afu.entity_id = temp.book_id OR afu.entity_id = temp.stra_id OR afu.entity_id = temp.sub_id) 
					AND afu.entity_id IS NOT NULL
				)
			OR afu.entity_id IS NULL
		)
	) temp_r

	-- if any role is not provided the privilege to update, check if user has explicit privilege to update and provide permission
	UPDATE temp
	SET has_privileges = COALESCE(temp_r.has_privilege,CASE WHEN ssbm.book_deal_type_map_id IS NULL THEN 0 ELSE 1 END, 0)
	FROM #deal_sub_books_privilege temp
	LEFT JOIN source_system_book_map ssbm ON ssbm.book_deal_type_map_id= temp.sub_book_id AND ssbm.create_user = @user_name
	OUTER APPLY (
		SELECT 1 has_privilege
		FROM application_functional_users afu 
		WHERE afu.function_id = @function_id
		AND afu.login_id = @user_name
		AND	(
				(
					(afu.entity_id = temp.book_id OR afu.entity_id = temp.stra_id OR afu.entity_id = temp.sub_id) 
					AND afu.entity_id IS NOT NULL
				)
			OR afu.entity_id IS NULL
		)
	) temp_r
	WHERE ISNULL(temp.has_privileges, 0) = 0

	SELECT NULLIF(has_privileges, 0) FROM #deal_sub_books_privilege temp	--@sub_book
	
	RETURN
END
ELSE IF @flag = 'w'
BEGIN
	SET @book = ISNULL(@book, (SELECT fas_book_id FROM source_system_book_map WHERE book_deal_type_map_id = @sub_book))

	SELECT DISTINCT 1 has_privilege
	FROM portfolio_hierarchy book
	INNER JOIN portfolio_hierarchy stra
		ON stra.entity_id = book.parent_entity_id
	INNER JOIN portfolio_hierarchy sub
		ON sub.entity_id = stra.parent_entity_id
	INNER JOIN application_functional_users afu
		ON afu.entity_id IN (book.entity_id, stra.entity_id, sub.entity_id)
	INNER JOIN application_functions af
		ON af.function_id = afu.function_id
	LEFT JOIN application_security_role asr
		ON afu.role_id = asr.role_id
	LEFT JOIN application_role_user aru
		ON aru.role_id = asr.role_id
	INNER JOIN dbo.SplitCommaSeperatedValues(@book) t
		ON t.item IN (book.entity_id, stra.entity_id, sub.entity_id)
	WHERE (
			(
				afu.login_id = @user_name
				OR aru.user_login_id = @user_name
				)
			AND afu.function_id = @function_id
			)
		OR @app_admin_role_check = 1
	UNION ALL
	SELECT 1 
	FROM application_functional_users afu
	WHERE login_id = @user_name
		AND afu.function_id = @function_id
		AND afu.entity_id IS NULL
	UNION ALL
	SELECT 1
	FROM application_functional_users afu
	LEFT JOIN application_security_role asr
		ON afu.role_id = asr.role_id
	LEFT JOIN application_role_user aru
		ON aru.role_id = asr.role_id
	WHERE role_user_flag = 'r'
		AND aru.user_login_id = @user_name
		AND afu.function_id = @function_id
		AND afu.entity_id IS NULL
END 
IF @flag = 'f'
BEGIN
	DECLARE @actual_granularity INT,
	        @deal_type          INT,
	        @commodity          INT,
	        @pricing_type		INT,
	        @term_freq			NCHAR(1),
	        @vol_type			INT
	        
	        
	SELECT @actual_granularity = sdht.actual_granularity,
	       @deal_type        = sdh.source_deal_type_id,
	       @commodity        = sdh.commodity_id,
	       @pricing_type     = sdh.pricing_type,
	       @term_freq        = sdh.term_frequency,
	       @vol_type		 = sdh.internal_desk_id
	FROM source_deal_header sdh
	INNER JOIN source_deal_header_template sdht On sdht.template_id = sdh.template_id
	INNER JOIN dbo.SplitCommaSeperatedValues(@deal_ids) scsv ON scsv.item = sdh.source_deal_header_id

	IF EXISTS(SELECT 1 FROM deal_default_value WHERE deal_type_id = @deal_type AND commodity = @commodity AND ((pricing_type IS NULL AND @pricing_type IS NULL) OR pricing_type = @pricing_type))
	BEGIN
		SELECT @actual_granularity = ISNULL(actual_granularity, @actual_granularity)
		FROM deal_default_value 
		WHERE deal_type_id = @deal_type 
		AND ((pricing_type IS NULL AND @pricing_type IS NULL) OR pricing_type = @pricing_type)
		AND commodity = @commodity
	END
	
	DECLARE @term_freq_int INT
	SET @term_freq_int = CASE @term_freq
	                          WHEN 'm' THEN 980
	                          WHEN 'q' THEN 991
	                          WHEN 'h' THEN 982
	                          WHEN 's' THEN 992
	                          WHEN 'a' THEN 993
	                          WHEN 'd' THEN 981
	                          WHEN 'z' THEN 0
	                     END
	                     
	SELECT CASE 
	            WHEN @actual_granularity IS NULL THEN NULL
	            ELSE CASE 
	                      WHEN @vol_type = 17301 THEN 'm'
	                      WHEN @vol_type = 17302 THEN 's'
	                      ELSE CASE 
	                                WHEN @term_freq_int = @actual_granularity THEN 
	                                     'd'
	                                ELSE 's'
	                           END
	                 END
	       END [actualization_flag]
END
ELSE IF @flag = 'p'
BEGIN
	DECLARE @transfer_rules_cpty INT
	SELECT @transfer_rules_cpty = counterparty_id_to FROM deal_transfer_mapping 
		WHERE source_book_mapping_id_from = @sub_book

	SELECT coalesce(@transfer_rules_cpty, ssbm.primary_counterparty_id, fs.counterparty_id, -1) [Counterparty ID]
	FROM source_system_book_map ssbm
	INNER JOIN fas_books fb ON fb.fas_book_id = ssbm.fas_book_id
	INNER JOIN portfolio_hierarchy ph_book ON ph_book.[entity_id] = fb.fas_book_id
	INNER JOIN portfolio_hierarchy ph_st ON ph_st.[entity_id] = ph_book.parent_entity_id
	INNER JOIN portfolio_hierarchy ph_sub ON ph_sub.[entity_id] = ph_st.parent_entity_id
	INNER JOIN fas_subsidiaries fs ON ph_sub.[entity_id] = fs.fas_subsidiary_id
	WHERE ssbm.book_deal_type_map_id = @sub_book
END
ELSE IF @flag = 'h'
BEGIN
	SELECT DISTINCT 1 flag
	FROM source_deal_header sdh
	INNER JOIN source_deal_header_template sdht
		ON sdh.template_id = sdht.template_id
	INNER JOIN dbo.SplitCommaSeperatedValues(@deal_ids) t
		ON t.item = sdh.source_deal_header_id
	WHERE sdht.comments = 'y'
		
END
ElSE IF @flag = 'r'
BEGIN
	SELECT DISTINCT sdd.location_id receipt_loc_id
				, sdd.from_loc_grp_id
				, dp.to_location delivery_loc_id
				, sjl.source_major_location_ID to_loc_grp_id
	FROM delivery_path dp 
	INNER JOIN
	(
		SELECT max(sdd.location_id) location_id
			, max(m.source_major_location_ID) from_loc_grp_id
			, MIN(term_start) term_start
			, MAX(term_end) term_end
		FROM source_deal_detail sdd
		INNER JOIN source_minor_location m
			ON m.source_minor_location_id = sdd.location_id
		WHERE source_deal_header_id = @deal_ids
		group by source_deal_header_id
	) sdd
		ON sdd.location_id = dp.from_location
	INNER JOIN source_deal_detail sdd_to
		ON sdd_to.location_id = to_location
		--AND sdd_to.term_start BETWEEN sdd.term_start AND sdd.term_end
	INNER JOIN source_minor_location sml
		ON sml.source_minor_location_id = dp.to_location
	INNER JOIN source_major_location sjl
		ON sjl.source_major_location_id = sml.source_major_location_id
END
ELSE IF @flag = 'q'
BEGIN
	IF NULLIF(@deal_ids,'') IS NOT NULL
	BEGIN
		SELECT @commodity_id = commodity_id
		FROM source_deal_header
		WHERE source_deal_header_id = @deal_ids
	END
	
	
	DECLARE @valuation_index_json VARCHAR(MAX)
	SET @valuation_index_json = '{"location": {'
	SELECT @valuation_index_json += STUFF((SELECT DISTINCT ',' +  '"'  + CAST(sml.source_minor_location_id AS VARCHAR(20)) + '"' + ': "' + CAST(COALESCE(lpi.curve_id,sml.term_pricing_index) AS VARCHAR(20)) + '"'
									 FROM source_minor_location sml
									 LEFT JOIN location_price_index lpi
											ON lpi.location_id = sml.source_minor_location_id
											AND CAST(lpi.commodity_id AS VARCHAR(20)) = ISNULL(NULLIF(@commodity_id,''),-111)
									WHERE COALESCE(lpi.curve_id,sml.term_pricing_index) IS NOT NULL
								FOR XML PATH('')), 1, 1, '') 

	SET @valuation_index_json += ' } }'
	SELECT @valuation_index_json [valuation_index_json]
END