 IF OBJECT_ID(N'[dbo].[spa_stmt_checkout]', N'P') IS NOT NULL
     DROP PROCEDURE [dbo].[spa_stmt_checkout]
 GO
   
 SET ANSI_NULLS ON
 GO
   
 SET QUOTED_IDENTIFIER ON
 GO
  
  /**
	Operations for Settlement Checkout and Run Accrual

	Parameters :
	@flag : Flag
		  @flag = 'grid' -> Load data in the grid
		  @flag = 'checkout'	-> Triggers when the Settlement is ready for invoice(finalized) or Accrual is posted. In both case data in inserted into settlement checkout with difference in accrual_or_final column
		  @flag = 'checkout_revert' -> Deletes the data from the settlement checkout
		  @flag = 'prepare_invoice' -> Logic to create the invoice
		  @flag = 'accrual_final_gl' -> Logic for Accural GL Report and Final GL Report. If called from Run Accural Screen 'a' flag and run from settlement checkout screen then 'f' is passed in @accrual_or_final_flag
		  @flag = 'submitted_accrual' -> Shows submitted accrual report, from Run Accrual screen.
		  @flag = 'price_report' -> Report for price drilldown in settlement checkout grid.
		  @flag = 'manual_adjustment' -> Directly insert adjustment value into index_fee_breakdown_table.
		  @flag = 'volume_report' -> Report for volume drilldown in settlement checkout grid.
		  @flag = 'amount_report' -> Report for amount drilldown in settlement checkout grid.
		  @flag = 'y' -> Check if accounting period is closed or not.
		  @flag = 'z' -> Check if UDF template or not
		  @flag = 'delete_adjustment' -> Delete the adjustment
	@accrual_or_final_flag : Accrual or Final Flag  'a' -> Run Accrual Screen, 'f' -> Settlement Checkout Screen 
	@subsidiary_id : Subsidiary Id Filter
	@strategy_id : Strategy Id Filter
	@book_id : Book Id Filter
	@sub_book_id : Sub Book Id Filter
	@counterparty_id : Counterparty Id Filter
	@contract_id : Contract Id Filter
	@charge_type : Charge Type Filter
	@commodity_group : Commodity Group Filter
	@commodity : Commodity Filter
	@date_from : Date From Filter
	@date_to : Date To Filter
	@invoice_status : 1 -> Unprocessed, 2 -> Processed, 3 -> Ready for Invoice, 4 -> Invoiced, 5 -> Posted GL, 6 -> Ignored
	@buy_sell : Buy Sell Filter
	@deal_type : Deal Type Filter
	@match_group_id : Match Group Id Filter
	@shipment_id : Shipment Id Filter
	@ticket_id : Ticket Id Filter
	@source_deal_header_id : Source Deal Header Id Filter
	@deal_reference_id : Deal Reference Id Filter
	@xml : Xml Data
	@rounding : Rounding
	@delivery_month : Delivery Month Filter
	@payable_receivable : Payable Receivable Filter
	@view_type : 1 -> Shipment, 2 -> Counterparty, 3 -> Invoice
	@prior_period : 'n' - Show just current period, 'y' - show prior period data also
	@deal_ids : Deal Ids Filter
	@source_deal_detail_id : Source Deal Detail Id Filter
	@udf_template_id : Udf Template Id Filter
	@row_id : Row Id 
	@term_filter : Term Filter Filter
	@cal_type_filter : Cal Type Filter
	@filter_as_of_date : Run As Of Date Filter for Price Report
	@as_of_date : As Of Date
	@accounting_date : Accounting Date Filter
	@deal_id : Deal Id Filter
	@index_fees_id : Index Fees Id Filter
	@stmt_checkout_ids : Ids of stmt_checkout
	@term_date : Term Date
	@counterparty_type : Counterparty Type Filter
    @deal_charge_type_id : Deal Charge Type ID
	@counterparty_entity_type : Counterparty Entity Type
	@contract_category : Contract Category
 */
   
CREATE PROCEDURE [dbo].[spa_stmt_checkout]
	@flag VARCHAR(1000),
	@accrual_or_final_flag CHAR(1) = NULL, -- 'a' -> Run Accrual Screen, 'f' -> Settlement Checkout Screen 
	@subsidiary_id VARCHAR(MAX) = NULL,
	@strategy_id VARCHAR(MAX) = NULL,
	@book_id VARCHAR(MAX) = NULL,
	@sub_book_id VARCHAR(MAX) = NULL,
	@counterparty_id VARCHAR(2048) = NULL,
	@contract_id VARCHAR(2048) = NULL,
	@charge_type VARCHAR(2048) = NULL,
	@commodity_group VARCHAR(2048) = NULL,
	@commodity VARCHAR(2048) = NULL,
	@date_from DATETIME = NULL,
	@date_to DATETIME = NULL,
	@invoice_status VARCHAR(512) = NULL, -- 1 -> Unprocessed, 2 -> Processed, 3 -> Ready for Invoice, 4 -> Invoiced, 5 -> Posted GL, 6 -> Ignored
	@buy_sell VARCHAR(128) = NULL,
	@deal_type VARCHAR(1034) = NULL,
	@match_group_id INT = NULL,
	@shipment_id VARCHAR(1024) = NULL,
	@ticket_id INT = NULL,
	@source_deal_header_id INT = NULL,
	@deal_reference_id VARCHAR(2000) = NULL,
	@xml XML =  NULL,
	@rounding INT = 2,
	@delivery_month DATETIME = NULL,
	@payable_receivable CHAR(1) = NULL,
	@view_type INT = NULL, -- 1 -> Shipment, 2 -> Counterparty, 3 -> Invoice
	@prior_period CHAR(1) = NULL,
	@deal_ids VARCHAR(200) = NULL,
	@source_deal_detail_id VARCHAR(2000) = NULL,
	@udf_template_id INT = NULL,
	@row_id INT = NULL,
	@term_filter DATETIME = NULL,
	@cal_type_filter CHAR(1) = NULL, 
	@filter_as_of_date DATETIME = NULL,
	@as_of_date DATETIME = NULL,
	@accounting_date DATETIME = NULL,
	@deal_id VARCHAR(MAX) = NULL,
	@index_fees_id VARCHAR(2000) = NULL,
	@stmt_checkout_ids VARCHAR(2000) = NULL,
	@term_date VARCHAR(MAX) = NULL,
	@counterparty_type CHAR(1) = NULL,
    @deal_charge_type_id VARCHAR(400) = NULL,
	@counterparty_entity_type NVARCHAR(MAX) = NULL,
	@contract_category NVARCHAR(MAX) = NULL


AS

SET NOCOUNT ON

/** * DEBUG QUERY START *
	SET NOCOUNT ON

	DECLARE @flag VARCHAR(1000),
		@accrual_or_final_flag CHAR(1) = NULL, -- 'a' -> Run Accrual Screen, 'f' -> Settlement Checkout Screen 
		@subsidiary_id VARCHAR(MAX) = NULL,
		@strategy_id VARCHAR(MAX) = NULL,
		@book_id VARCHAR(MAX) = NULL,
		@sub_book_id VARCHAR(MAX) = NULL,
		@counterparty_id VARCHAR(2048) = NULL,
		@contract_id VARCHAR(2048) = NULL,
		@charge_type VARCHAR(2048) = NULL,
		@commodity_group VARCHAR(2048) = NULL,
		@commodity VARCHAR(2048) = NULL,
		@date_from DATETIME = NULL,
		@date_to DATETIME = NULL,
		@invoice_status VARCHAR(512) = NULL, -- 1 -> Unprocessed, 2 -> Processed, 3 -> Ready for Invoice, 4 -> Invoiced, 5 -> Posted GL, 6 -> Ignored
		@buy_sell VARCHAR(128) = NULL,
		@deal_type VARCHAR(1034) = NULL,
		@match_group_id INT = NULL,
		@shipment_id VARCHAR(1024) = NULL,
		@ticket_id INT = NULL,
		@source_deal_header_id INT = NULL,
		@deal_reference_id VARCHAR(2000) = NULL,
		@xml XML =  NULL,
		@rounding INT = 2,
		@delivery_month DATETIME = NULL,
		@payable_receivable CHAR(1) = NULL,
		@view_type INT = NULL, -- 1 -> Shipment, 2 -> Counterparty, 3 -> Invoice
		@prior_period CHAR(1) = NULL,
		@deal_ids VARCHAR(200) = NULL,
		@source_deal_detail_id VARCHAR(2000) = NULL,
		@udf_template_id INT = NULL,
		@row_id INT = NULL,
		@term_filter DATETIME = NULL,
		@cal_type_filter CHAR(1) = NULL, 
		@filter_as_of_date DATETIME = NULL,
		@as_of_date DATETIME = NULL,
		@accounting_date DATETIME = NULL,
		@deal_id VARCHAR(MAX) = NULL,
		@index_fees_id VARCHAR(2000) = NULL,
		@stmt_checkout_ids VARCHAR(2000) = NULL,
		@term_date VARCHAR(MAX) = NULL,
		@counterparty_type CHAR(1) = NULL,
        @deal_charge_type_id VARCHAR(400) = NULL
    

	SELECT @flag='grid'
		, @accrual_or_final_flag='f'
		, @subsidiary_id='3804,3768,3753,3747,3750,3842,2556,85,3350,2391,2395,3508,3260,3493,3595,3263,49,3069,3362,3363,3630,1327,52,2713,77,1341,44,3132,2697,3627,3505,2893,3109,3307,3313,3314,3344,2921,3012,3025,3711,3024,3851,3781,3383,3326,3472,29,2916,71,170,80,3639,3220,3129,2880,141,3078,1350,3121,3045,2691,3026,3036,3118,3656,2559,3613,3272,2600,3051,215,298,3359,3636,1347,3356,3048,2716,3033,1376,74,3737,2595,145,2,2583,2700,3250,3112,3113,2586,3226,2913,3054,2694,3604,3633,3791,3616,3642,3724,3807,1362,1359,3564,254,1335,1336,2968,3319,2707,2907,2965,2869,3098,2579,3126,3134,3135,3136,3133,3511,3542,3458,3794,2883,2888,3266,3072,8,3645,3060,3030,39,3601,123,3392,3269,201,2896,3066,3332,2548,3619,2866,3090,3784,3422,273,3560,2724,2725,2727,2728,2729,2730,2731,2732,2733,2734,2735,2736,2737,2738,2739,2740,2741,2742,2743,2744,2745,2746,2747,2748,2750,2751,2752,2753,2754,2755,2756,2757,2758,2759,2760,2761,2762,2763,2764,3551,3586,3545,3548,3567,3557,3572,3223,3444,3341,3659,3689,3347,5,1365,3137,3834,3535,3457,3679,3401,3554,3434,3398,3386,3338,3496,3335,3431,3041,2904,3093,3353,3592,3084,3257,3721,3087,32,2576,1308,3863,3756,3762,3763,3740,3788,3801,3795,3743,3857,3860,3759,3854,3775'
		, @strategy_id='3805,3769,3754,3748,3751,3843,3699,3700,3701,2557,2571,2565,3702,3124,86,3351,2392,2396,3509,3261,3494,3596,3264,50,3070,3364,3365,3631,1328,53,2714,78,1342,45,46,3138,3139,2698,3628,3506,3107,2894,3308,3110,3309,3315,3316,3345,2922,3712,3852,3782,3384,3327,3473,30,2917,72,172,81,3640,3221,3130,2881,3101,142,3104,3079,1351,3122,3046,2692,3027,3037,3623,3119,3657,2560,3614,3273,2601,3052,296,299,1330,3360,3637,1348,3357,3049,2717,3034,1377,2919,268,75,117,120,3648,3649,3738,2596,146,257,83,3,2584,2701,3251,3114,3115,2587,3227,2914,3055,2695,3605,3634,3792,3617,3643,3725,3808,1363,1360,255,1337,1338,2969,3320,2708,2908,2966,2870,2871,3099,2580,3127,3141,3142,3143,3322,3324,3140,3512,3543,3813,3811,3483,3482,3484,3460,3481,3486,3485,3796,2884,2885,2889,2890,3267,9,3646,3061,3031,40,42,3602,124,3393,3270,237,238,239,240,2897,3067,3333,2552,3620,2867,3091,3785,3423,274,3562,3561,2773,2774,2776,2777,2778,2779,2780,2781,2782,2783,2784,2785,2786,2787,2788,2789,2790,2791,2792,2793,2794,2795,2796,2797,2799,2800,2801,2802,2803,2804,2805,2806,2807,2808,2809,2810,2811,2812,2813,3587,3546,3549,3570,3558,3224,3445,3446,3447,3448,3449,3342,3660,3690,3348,6,1366,1367,3144,3145,3146,3147,3148,3149,3150,3835,3536,3537,3538,3522,3520,3521,3459,3680,3681,3402,3555,3435,3399,3387,3339,3497,3336,3432,3042,2905,3094,3354,3593,3085,3258,3722,3088,33,2577,2598,1379,2703,2661,1309,2665,2664,2402,2568,3716,2406,1332,2662,2655,2656,2663,2658,3039,2660,2404,1322,1380,3729,1353,1374,3864,3865,3866,3867,3868,3757,3764,3765,3741,3789,3802,3797,3744,3858,3861,3760,3855,3776'
		, @book_id='3806,3770,3755,3749,3752,3845,3848,3847,3846,3850,3844,3849,3703,3704,3705,3706,3707,3708,2558,2572,2567,3709,3710,3125,87,3352,2393,2394,2397,2398,3510,3262,3495,3597,3265,51,3071,3366,3367,3368,3369,3370,3371,3372,3373,3374,3375,3376,3632,1329,54,2878,2715,79,1343,47,2877,48,3151,3152,3153,3154,3155,3156,2699,3629,3507,3108,3310,2895,3311,3111,3312,3317,3318,3346,2923,3713,3853,3783,3412,3411,3413,3385,3410,3415,3414,3328,3474,31,2918,73,174,82,3641,3222,3131,2882,3102,143,144,3105,3106,3080,1352,1383,3123,3047,3028,2693,3029,3038,3625,3120,3658,2561,3615,3274,2602,3053,297,300,1317,2678,2681,2684,2685,2687,2688,1318,1331,3361,3638,1349,3358,3050,2718,3035,1378,2920,269,76,3694,2566,3695,119,3651,121,3652,122,3696,3697,3698,3739,2597,147,258,84,4,2585,2702,3252,3116,3117,2588,3228,2915,3056,2696,3606,3635,3793,3618,3644,3726,3809,1364,1361,256,1339,1340,2970,3321,2709,2909,2967,2872,2873,3103,3100,2581,3128,3160,3161,3162,3163,3164,3165,3166,3167,3168,3169,3170,3323,3325,3157,3158,3159,3513,3516,3515,3517,3514,3519,3518,3544,3814,3812,3489,3488,3490,3462,3487,3492,3491,3798,2886,2887,2891,2892,3268,10,3647,3062,3032,41,43,3603,125,3394,3271,241,242,243,244,245,246,247,248,249,2898,3068,3334,2555,3622,3621,2868,3092,3786,3427,3426,3428,3424,3425,3430,3429,275,2822,2823,2825,2826,2827,2828,2829,2830,2831,2832,2833,2834,2835,2836,2837,2838,2839,2840,2841,2842,2843,2844,2845,2846,2848,2849,2850,2851,2852,2853,2854,2855,2856,2857,2858,2859,2860,2861,2862,3588,3547,3571,3225,3450,3451,3452,3453,3454,3455,3456,3343,3661,3691,3349,7,1368,1369,3171,3172,3173,3174,3175,3176,3177,3178,3179,3180,3181,3182,3183,3184,3185,3186,3187,3188,3189,3190,3191,3192,3193,3194,3195,3196,3197,3198,3199,3200,3201,3202,3203,3204,3205,3206,3207,3208,3209,3210,3211,3212,3213,3214,3215,3216,3217,3218,3219,3836,3837,3839,3838,3840,3841,3539,3540,3541,3525,3523,3524,3461,3682,3683,3403,3556,3440,3438,3441,3437,3436,3439,3443,3442,3400,3418,3417,3419,3388,3416,3421,3420,3340,3501,3500,3502,3498,3499,3504,3503,3337,3433,3043,2906,3095,3355,3594,3086,3259,3723,3089,34,2578,2599,1381,2704,2705,3727,3728,2683,3771,2690,1310,2676,3686,2677,2403,2569,3717,2407,3715,2672,3693,3662,1333,1334,3714,3692,2682,2570,2582,2686,1373,2689,3684,3663,2673,2674,2675,2680,2666,3040,2668,2405,1323,3746,3688,1382,3731,3733,1354,2706,1384,1375,2671,2679,3787,3687,3869,3870,3871,3872,3873,3874,3875,3876,3877,3758,3766,3767,3742,3800,3790,3803,3799,3745,3859,3862,3761,3856,3777'
		, @sub_book_id='4162,4148,4143,4141,4142,4181,4180,4110,4111,4112,4113,4114,4115,3308,3344,3315,4116,4117,3591,68,3480,3491,3481,2249,2250,4067,3903,3902,3901,3908,3905,4021,3268,3269,3270,3271,3272,3273,3274,3275,4008,3745,3740,3831,3999,4046,3741,3742,3743,28,3470,26,27,29,3544,3876,3877,3545,3867,3873,3874,3875,3858,3872,3909,3910,3911,3912,3913,3914,3915,3916,3917,3918,3919,4064,4063,3324,2218,3313,3333,3335,3316,3340,3341,3337,30,2238,35,3417,3476,61,60,63,64,3563,3749,37,59,62,2227,22,23,3477,24,25,3594,3595,3596,3597,3598,3599,3600,3601,3406,3407,4062,4007,3580,3489,3754,3581,3755,3756,3757,4139,3823,3508,4124,4127,4118,4119,4182,4153,3933,3932,3934,3922,3931,3936,3935,3894,3895,3896,3897,3898,3899,3886,3990,34,3345,3506,33,185,186,98,66,4068,3700,3593,3484,3572,3573,81,3541,82,3575,3577,3582,3579,3576,3578,3550,3551,2255,2233,2257,2256,3590,3525,3527,3524,3526,3403,3513,3518,4060,3587,3588,3589,4199,4080,4203,4201,4202,4196,4197,4198,4200,3309,4059,4057,3748,3377,3532,197,198,199,200,2211,2212,2213,2214,2219,2220,3907,4066,2232,3906,3528,3529,3418,3517,3348,3311,3347,3310,2248,3490,3360,3338,3323,3512,3507,3540,182,4102,3314,4103,4104,4105,73,4106,74,4107,4108,4109,4136,3759,3365,83,89,88,86,87,84,85,177,67,2,3358,3359,3408,3716,3584,3585,3361,3705,3499,3500,3501,3502,3503,3504,3505,3533,3404,4054,4065,4157,4058,4070,4071,4128,4129,4163,2241,2260,2240,3346,176,2225,2226,3760,3415,3497,3509,3473,3474,3574,3571,3355,3592,3608,3609,3610,3611,3612,3613,3614,3615,3616,3617,3618,3619,3620,3621,3622,3623,3624,3625,3626,3627,3628,3629,3761,3762,3602,3603,3604,3605,3606,3607,4009,4012,4011,4013,4010,4015,4014,4027,4166,4165,3995,3994,3996,3986,3993,3998,3997,4158,3485,3486,3487,3488,3746,6,7,4,5,8,4072,4073,3536,3514,19,21,4050,4051,4052,75,3925,3747,164,163,158,156,157,168,155,160,161,162,169,165,166,167,159,3492,3539,3952,3951,3953,3810,3950,3955,3954,3306,3471,3565,4154,3946,3945,3947,3943,3944,3949,3948,184,3482,3483,3424,3425,3427,3428,3429,3430,3431,3432,3433,3434,3435,3436,3437,3438,3439,3440,3441,3442,3443,3444,3445,3446,3447,3448,3450,3451,3452,3453,3454,4069,3455,3456,3457,3458,3459,3460,3461,3462,3463,3464,4043,4028,4036,3703,3704,3969,3970,3971,3972,3973,3974,3975,3976,3977,3978,3979,3980,3981,3982,3983,3984,3822,4081,4195,4098,3824,69,3535,181,3,2245,154,3630,3631,3632,3633,3634,3635,3636,3637,3638,3639,3640,3641,3642,3643,3644,3645,3646,3647,3648,3649,3650,3651,3652,3653,3654,3655,3656,3657,3658,3659,3660,3661,3662,3663,3664,3665,3666,3667,3668,3669,3670,3671,3672,3673,3674,3675,3676,3677,3678,3679,3680,3681,3682,3683,3684,3685,3686,3687,3688,3689,3690,3691,3692,3693,3694,3695,3696,3697,3698,3699,4172,4173,4175,4174,4176,4177,4024,4025,4026,4018,4016,4017,3985,4091,4092,3928,4083,4082,4031,4038,3965,3963,3966,3962,3964,3968,3967,3927,3939,3938,3940,3923,3937,3942,3941,3821,4003,4002,4004,4000,4001,4006,4005,3815,3956,3957,3959,3960,3958,3523,3496,3515,3516,3520,3521,3549,3566,3904,4053,4045,3553,3562,3554,3555,3556,3557,3558,3559,3560,3561,3736,3737,3738,3739,3744,3758,3820,4126,3564,4020,16,3354,3362,3570,3373,3583,3586,3376,3367,3366,2251,2253,3711,3410,3725,3708,3734,3411,4130,4131,3395,4149,3405,3402,2207,2205,3389,4095,3390,3277,3278,3317,3318,4122,4123,3281,3282,4121,3530,3531,4100,4101,4084,2221,2222,3569,2224,3391,4120,4099,3394,3342,3343,3469,3397,2243,2244,3398,3401,4093,4085,3386,3387,3388,3393,3472,3409,3414,3519,3522,3279,3280,2216,4140,4097,2252,2254,4132,4134,3412,3413,2264,2265,2246,2247,3709,3383,3723,3732,3706,3710,3392,3568,3724,3707,3733,4155,4096,4186,4187,4188,4189,4190,4191,4192,4193,4194,4144,4146,4147,4137,4160,4156,4161,4159,4138,4184,4185,4145,4183,4151'
		, @date_from='2019-01-01'
		, @date_to='2019-02-28'
		, @invoice_status=1
		, @source_deal_header_id=219911
		, @rounding=2
		, @view_type=2
		, @prior_period='y'
		, @counterparty_type='e'

-- * DEBUG QUERY END * */



DECLARE @sql		VARCHAR(MAX)
DECLARE @idoc		INT
DECLARE @accounting_month DATETIME
SELECT @accounting_month = dbo.FNAGetContractMonth(ISNULL(DATEADD(mm,1,MAX(as_of_date)),GETDATE())) FROM close_measurement_books

--IF NULLIF(@date_from,'') IS NULL
--	SET @date_from = DATEADD(month, DATEDIFF(month, 0, CAST(@delivery_month AS DATETIME)), 0)

--IF NULLIF(@date_to,'') IS NULL
--	SET @date_to = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@delivery_month)+1,0))
SET @date_from = NULLIF(@date_from, '')
SET @date_to = NULLIF(@date_to, '')
SET @delivery_month = NULLIF(@delivery_month, '')

SET @shipment_id = NULLIF(@shipment_id, 0)
SET @ticket_id = NULLIF(@ticket_id, 0)

IF @flag = 'grid'
BEGIN
	IF OBJECT_ID('tempdb..#books') IS NOT NULL
		DROP TABLE #books

	CREATE TABLE #books (
		[entity_id] INT,
		source_system_book_id1 INT,
		source_system_book_id2 INT,
		source_system_book_id3 INT,
		source_system_book_id4 INT
	)

	SET @sql = '
		INSERT INTO #books
		SELECT DISTINCT book.entity_id,
			ssbm.source_system_book_id1,
			ssbm.source_system_book_id2,
			ssbm.source_system_book_id3,
			ssbm.source_system_book_id4
		FROM portfolio_hierarchy book(NOLOCK)
			INNER JOIN Portfolio_hierarchy stra(NOLOCK)
				ON  book.parent_entity_id = stra.entity_id
			INNER JOIN source_system_book_map ssbm
				ON  ssbm.fas_book_id = book.entity_id
		WHERE (fas_deal_type_value_id IS NULL OR fas_deal_type_value_id BETWEEN 400 AND 401)
	' 

	DECLARE @where_subsidiary VARCHAR(MAX)
	DECLARE @where_strategy VARCHAR(MAX)
	DECLARE @where_book VARCHAR(MAX)
	DECLARE @where_sub_book VARCHAR(MAX)

	SET @where_subsidiary = '' + CASE WHEN @subsidiary_id IS NOT NULL THEN ' AND stra.parent_entity_id IN  (' + @subsidiary_id + ') ' ELSE '' END 
	SET @where_strategy = '' + CASE WHEN @strategy_id IS NOT NULL THEN ' AND stra.entity_id IN(' + @strategy_id  + ')' ELSE '' END 
	SET @where_book = '' + CASE WHEN @book_id IS NOT NULL THEN ' AND book.entity_id IN(' + @book_id  + ')' ELSE '' END 
	SET @where_sub_book = '' + CASE WHEN @sub_book_id IS NOT NULL THEN ' AND ssbm.book_deal_type_map_id IN (' + @sub_book_id  + ')' ELSE '' END 

	EXEC(@sql + @where_subsidiary + @where_strategy + @where_book + @where_sub_book)


	IF OBJECT_ID('tempdb..#All_Collected_Data') IS NOT NULL
		DROP TABLE #All_Collected_Data

	CREATE TABLE #All_Collected_Data (
		Match_Group_ID			INT,
		Shipment_ID				INT,
		Source_Deal_Header_ID	INT,
		Source_Deal_Detail_ID	INT,
		Ticket_ID				INT,
		Ticket_Detail_ID		INT,
		Counterparty_ID			INT,
		Contract_ID				INT,
		Deal_Charge_Type_ID		INT,
		Deal_Charge_Name		VARCHAR(100) COLLATE DATABASE_DEFAULT,
		Contract_Charge_Type_ID	INT,
		Currency_ID				INT,
		Term_Start				DATETIME,
		Term_End				DATETIME,
		[Type]					VARCHAR(100) COLLATE DATABASE_DEFAULT,
		[movement_date]			DATETIME,
		tkt_schedule_volume		FLOAT,
		tkt_actual_volume		FLOAT,
		[Leg]					INT,
		match_info_id			INT
	)

	/* 
	 * [Collect the Deal for Commodity Charge]
	 */
	IF OBJECT_ID('tempdb..#Collected_Deals_Pre') IS NOT NULL
		DROP TABLE #Collected_Deals_Pre
	

	SELECT	mg.match_group_id			[Match_Group_ID],
			mgs.match_group_shipment_id [Shipment_ID],
			sdh.source_deal_header_id	[Source_Deal_Header_ID],
			ISNULL(sdd.source_deal_detail_id, detail_id)	[Source_Deal_Detail_ID],
			th.ticket_header_id			[Ticket_ID],
			td.ticket_detail_id			[Ticket_Detail_ID],
			sdh.counterparty_id			[Counterparty_ID],
			sdh.contract_id				[Contract_ID],
			sdh.template_id				[Template_ID],
			sdd.fixed_price_currency_id	[Currency_ID],
			COALESCE(mhdi.delivery_date,sdd.actual_delivery_date,sdd.delivery_date,sdd.term_start,dbo.FNAGetContractMonth(sdh.deal_date)) [Term_Start],
			COALESCE(mhdi.delivery_date,sdd.actual_delivery_date,sdd.delivery_date_to,sdd.delivery_date,sdd.term_end,EOMONTH(sdh.deal_date))		[Term_End],
			'Commodity Charges'			[Type],
			td.movement_date_time		[movement_date],
			mgd.bookout_split_volume	[tkt_schedule_volume],
			ISNULL(td.net_quantity,td.gross_quantity) [tkt_actual_volume],
			sdd.leg						[Leg],
			mhdi.match_info_id
	INTO #Collected_Deals_Pre
 FROM source_deal_header sdh 
	INNER JOIN #books b on sdh.source_system_book_id1=b.source_system_book_id1 
		AND sdh.source_system_book_id2=b.source_system_book_id2 
		AND sdh.source_system_book_id3=b.source_system_book_id3 
		AND sdh.source_system_book_id4=b.source_system_book_id4
	LEFT JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id 
					AND  CASE WHEN ISNULL(@prior_period,'n') = 'y' AND @invoice_status IN ('2','3') THEN COALESCE(sdd.actual_delivery_date,sdd.delivery_date,sdd.term_start) ELSE COALESCE(@date_from,sdd.actual_delivery_date,sdd.delivery_date,sdd.term_start) END <= COALESCE(sdd.actual_delivery_date,sdd.delivery_date,sdd.term_start)
				AND COALESCE(@date_to,sdd.actual_delivery_date,sdd.delivery_date_to,sdd.delivery_date,sdd.term_end) >= COALESCE(sdd.actual_delivery_date,sdd.delivery_date_to,sdd.delivery_date,sdd.term_end)

	OUTER APPLY (SELECT DISTINCT id AS match_info_id, mhdi.delivery_date, mhdi.source_deal_detail_id AS detail_id
		FROM source_deal_detail sdd1 
		INNER JOIN matching_header_detail_info mhdi ON sdh.source_deal_header_id = sdd1.source_deal_header_id
		WHERE mhdi.source_deal_header_id = sdh.source_deal_header_id
		AND mhdi.source_deal_detail_id = sdd1.source_deal_detail_id
		AND (sdd.source_deal_header_id IS NULL OR sdd1.source_deal_detail_id = sdd.source_deal_detail_id)) mhdi

	INNER JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id
	LEFT JOIN match_group_detail mgd ON mgd.source_deal_detail_id = sdd.source_deal_detail_id
	LEFT JOIN match_group_header mgh ON mgh.match_group_header_id = mgd.match_group_header_id
	LEFT JOIN match_group_shipment mgs ON mgs.match_group_shipment_id = mgh.match_group_shipment_id
	LEFT JOIN match_group mg ON mg.match_group_id = mgs.match_group_id
	LEFT JOIN ticket_match tm ON tm.match_group_detail_id = mgd.match_group_detail_id
	LEFT JOIN ticket_detail td ON td.ticket_detail_id = tm.ticket_detail_id
	LEFT JOIN ticket_header th ON th.ticket_header_id = td.ticket_header_id
	
	LEFT JOIN dbo.SplitCommaSeperatedValues(@contract_id) con ON con.item = sdh.contract_id
	LEFT JOIN source_commodity scm ON scm.source_commodity_id = ISNULL(sdd.detail_commodity_id,sdh.commodity_id)
    LEFT JOIN dbo.SplitCommaSeperatedValues(@commodity_group) comg ON comg.item = scm.commodity_group1
	LEFT JOIN dbo.SplitCommaSeperatedValues(@commodity) com ON com.item = ISNULL(sdd.detail_commodity_id,sdh.commodity_id)
	LEFT JOIN dbo.SplitCommaSeperatedValues(@buy_sell) bs ON bs.item = sdh.header_buy_sell_flag
	LEFT JOIN dbo.SplitCommaSeperatedValues(@deal_type) dt ON dt.item = sdh.source_deal_type_id
	LEFT JOIN dbo.SplitCommaSeperatedValues(@shipment_id) shp ON shp.item = mgs.match_group_shipment_id
	LEFT JOIN dbo.SplitCommaSeperatedValues(@deal_id) dd ON dd.item = sdh.source_deal_header_id
	LEFT JOIN source_counterparty sc1 ON sc1.source_counterparty_id = sdh.counterparty_id
	LEFT JOIN dbo.SplitCommaSeperatedValues(@counterparty_entity_type) cet ON cet.item = sc1.type_of_entity 
	WHERE 1=1 AND sdh.deal_status <> 5607
	AND (mhdi.delivery_date IS NULL OR mhdi.delivery_date BETWEEN ISNULL(@date_from, mhdi.delivery_date) AND ISNULL(@date_to, mhdi.delivery_date))
	AND ISNULL(NULLIF(@source_deal_header_id,''),sdh.source_deal_header_id) = sdh.source_deal_header_id
	AND ISNULL(NULLIF(@deal_reference_id,''),sdh.deal_id) = sdh.deal_id
	AND CASE WHEN NULLIF(@contract_id,'') IS NULL THEN 1 ELSE con.item END IS NOT NULL
	AND CASE WHEN NULLIF(@commodity,'') IS NULL THEN 1 ELSE com.item END IS NOT NULL
	AND CASE WHEN NULLIF(@commodity_group,'') IS NULL THEN 1 ELSE comg.item END IS NOT NULL
	AND CASE WHEN NULLIF(@buy_sell,'') IS NULL THEN '1' ELSE bs.item END IS NOT NULL
	AND CASE WHEN NULLIF(@deal_type,'') IS NULL THEN 1 ELSE dt.item END IS NOT NULL
	AND CASE WHEN NULLIF(@shipment_id,'') IS NULL THEN 1 ELSE shp.item END IS NOT NULL
	AND COALESCE(NULLIF(@match_group_id,''),mg.match_group_id,-1) = ISNULL(mg.match_group_id,-1)
	AND COALESCE(NULLIF(@ticket_id,''),th.ticket_header_id,1) = ISNULL(th.ticket_header_id,1)
	AND CASE WHEN NULLIF(@deal_id,'') IS NULL THEN '1' ELSE dd.item END IS NOT NULL
	AND CASE WHEN NULLIF(@counterparty_entity_type,'') IS NULL THEN '1' ELSE cet.item END IS NOT NULL
	AND CASE WHEN ISNULL(sdd.source_deal_detail_id, mhdi.match_info_id ) IS NULL AND sdh.broker_id IS NULL THEN 1 ELSE -1 END = -1


	IF OBJECT_ID('tempdb..#Collected_Deals') IS NOT NULL
		DROP TABLE #Collected_Deals
	
	SELECT * INTO #Collected_Deals 
	FROM #Collected_Deals_Pre cdp
	WHERE CASE WHEN ISNULL(@prior_period,'n') = 'y' AND @invoice_status IN ('2','3') THEN cdp.term_start ELSE ISNULL(@date_from,cdp.term_start) END <= cdp.term_start
			AND ISNULL(@date_to,cdp.term_end) >= cdp.term_end

	INSERT INTO #All_Collected_Data (
		Match_Group_ID,
		Shipment_ID,
		Source_Deal_Header_ID,
		Source_Deal_Detail_ID,
		Ticket_ID,
		Ticket_Detail_ID,
		Counterparty_ID,
		Contract_ID,
		Deal_Charge_Type_ID,
		[Deal_Charge_Name],
		[Currency_ID],
		Term_Start,
		Term_End,
		[Type],
		[movement_date],
		[tkt_schedule_volume],
		[tkt_actual_volume],
		match_info_id
	)
	SELECT	cd.Match_Group_ID,
			cd.Shipment_ID,
			cd.Source_Deal_Header_ID,
			cd.Source_Deal_Detail_ID,
			cd.Ticket_ID,
			cd.Ticket_Detail_ID,
			cd.Counterparty_ID,
			cd.Contract_ID,
			-5500 [Deal_Charge_Type_ID],
			CASE WHEN cd.Source_Deal_Detail_ID IS NULL THEN 'Fees' ELSE 'Commodity Charge' END	[Deal_Charge_Name],
			cd.[Currency_ID],
			cd.Term_Start,
			cd.Term_End,
			'Commodity Charge'	[Type],
			cd.[movement_date],
			cd.[tkt_schedule_volume],
			cd.[tkt_actual_volume],
			cd.match_info_id
	FROM #Collected_Deals cd
	LEFT JOIN dbo.SplitCommaSeperatedValues(@counterparty_id) cpt ON cpt.item = cd.Counterparty_ID
	WHERE 
	CASE WHEN NULLIF(@counterparty_id,'') IS NULL THEN 1 ELSE cpt.item END IS NOT NULL


	/*
	 * [Collect the adjustments]
	 */
	
	INSERT INTO #All_Collected_Data (
		Match_Group_ID,
		Shipment_ID,
		Source_Deal_Header_ID,
		Source_Deal_Detail_ID,
		Ticket_Detail_ID,
		Ticket_ID,
		Counterparty_ID,
		Contract_ID,
		Deal_Charge_Type_ID,
		[Deal_Charge_Name],
		[Currency_ID],
		Term_Start,
		Term_End,
		[Type],
		[movement_date],
		[tkt_schedule_volume],
		[tkt_actual_volume],
		match_info_id
	)
	SELECT DISTINCT 
			pre.Match_Group_ID,
			adj.shipment_id,
			pre.source_deal_header_id,
			pre.source_deal_detail_id,
			adj.ticket_detail_id,
			cd.Ticket_ID,
			pre.Counterparty_ID,
			pre.Contract_ID,
			adj.charge_type_id,
			CASE WHEN udft.field_name = -5500 THEN 'Commodity Charge' ELSE udft.field_label END  [Deal_Charge_Name],
			pre.[Currency_ID],
			adj.term_start,
			adj.term_end,
			'Adjustment' [Type],
			cd.[movement_date],
			cd.[tkt_schedule_volume],
			cd.[tkt_actual_volume],
			adj.match_info_id
	FROM #Collected_Deals_Pre pre
	INNER JOIN stmt_adjustments adj ON ISNULL(pre.Shipment_ID,-1) = ISNULL(adj.[shipment_id],-1)
										AND ISNULL(pre.Ticket_Detail_ID,-1) = ISNULL(adj.[ticket_detail_id],-1)
										AND pre.Source_Deal_Header_ID = adj.source_deal_header_id
										AND pre.leg = adj.leg
    LEFT JOIN  #Collected_Deals cd ON ISNULL(cd.Shipment_ID,-1) = ISNULL(adj.[shipment_id],-1)
										AND ISNULL(cd.Ticket_Detail_ID,-1) = ISNULL(adj.[ticket_detail_id],-1)
										AND cd.Source_Deal_Header_ID = adj.source_deal_header_id
										AND cd.leg = adj.leg
	LEFT JOIN user_defined_fields_template udft ON udft.field_name = adj.charge_type_id
	WHERE CASE WHEN ISNULL(@prior_period,'n') = 'y' AND @invoice_status IN ('2','3') THEN adj.term_start ELSE ISNULL(@date_from,adj.term_start) END <= adj.term_start
			AND ISNULL(@date_to,adj.term_end) >= adj.term_end


	/* 
	 * [Collect the Contract Charges]
	 */
	INSERT INTO #All_Collected_Data (
		Counterparty_ID,
		Contract_ID,
		Contract_Charge_Type_ID,
		Currency_ID,
		Term_Start,
		Term_End,
		[Type]
	)
	SELECT	sc.source_counterparty_id	[Counterparty_ID],
			cg.contract_id				[Contract_ID],
			cgd.invoice_line_item_id	[Contract_Charge_Type_ID],
			cg.currency					[Currency_ID],
			term.term_start				[Term_Start],	
			term.term_start				[Term_End],
			'Complex Contract Charges'	[Type]
	FROM source_counterparty sc 
		INNER JOIN counterparty_contract_address cca ON cca.counterparty_id = sc.source_counterparty_id 
		INNER JOIN contract_group cg ON cg.contract_id = cca.contract_id
		LEFT JOIN contract_group_detail cgd ON cgd.contract_id = cg.contract_id
		OUTER APPLY (SELECT term_start,term_end FROM dbo.FNATermBreakdown('m',@date_from,@date_to)) term
		LEFT JOIN dbo.SplitCommaSeperatedValues(@counterparty_id) cpt ON cpt.item = sc.source_counterparty_id
		LEFT JOIN dbo.SplitCommaSeperatedValues(@contract_id) con ON con.item = cg.contract_id
		INNER JOIN #Collected_Deals_Pre cdp ON cdp.counterparty_id = sc.source_counterparty_id AND cdp.contract_id = cg.contract_id
	WHERE 1=1 
		AND CASE WHEN NULLIF(@counterparty_id,'') IS NULL THEN 1 ELSE cpt.item END IS NOT NULL
		AND CASE WHEN NULLIF(@contract_id,'') IS NULL THEN 1 ELSE con.item END IS NOT NULL
		AND CASE WHEN NULLIF(@counterparty_type,'') IS NULL THEN '1' ELSE sc.int_ext_flag END = CASE WHEN NULLIF(@counterparty_type,'') IS NULL THEN '1' ELSE @counterparty_type END
		AND cgd.invoice_line_item_id IS NOT NULL

	/*
	 * [Collect the Deal Cost]
	 */
	IF @invoice_status <> 1
	BEGIN
		INSERT INTO #All_Collected_Data (
			Match_Group_ID,
			Shipment_ID,
			Source_Deal_Header_ID,
			Source_Deal_Detail_ID,
			Ticket_ID,
			Ticket_Detail_ID,
			Counterparty_ID,
			Contract_ID,
			Deal_Charge_Type_ID,
			[Deal_Charge_Name],
			Currency_ID,
			Term_Start,
			Term_End,
			[Type],
			match_info_id
		)
		SELECT	cd.Match_Group_ID,
				cd.Shipment_ID,
				sdh.Source_Deal_Header_ID,
				sdd.Source_Deal_Detail_ID,
				cd.Ticket_ID,
				cd.Ticket_Detail_ID,
				COALESCE(scf_c.source_counterparty_id,scf.source_counterparty_id,cd.Counterparty_ID),
				ISNULL(cg.contract_id,cd.Contract_ID),
				ifbs.field_id	[Deal_Charge_Type_ID],
				ifbs.field_name	[Deal_Charge_Name],
				COALESCE(uddf.currency_id,uddf.currency_id,cd.Currency_ID) [Currency_ID],
				CASE WHEN ISNULL(ifbs.internal_type,-1) IN (18723,18722,18733,18740) THEN IIF(@invoice_status = '1', dbo.FNAGetContractMonth(sdd.term_start),ISNULL(dbo.FNAGetContractMonth(sdh.deal_date),-1)) ELSE ISNULL(sdd.term_start,-1) END [Term_Start],
				IIF(@invoice_status = '1',sdd.term_end,ISNULL(ifbs.term_end,sdd.term_end))	[Term_End],
				'Cost'			[Type],   
				ifbs.match_info_id
		FROM  #Collected_Deals cd
		INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = cd.source_deal_header_id
		LEFT JOIN source_deal_detail sdd ON cd.source_deal_detail_id = sdd.source_deal_detail_id
		INNER JOIN index_fees_breakdown_settlement ifbs 
			ON sdh.source_deal_header_id = ifbs.source_deal_header_id 
			AND ISNULL(sdd.leg,1)= ISNULL(ifbs.leg,1)
			--AND ifbs.ticket_detail_id=cd.ticket_detail_id
			AND IIF(ISNULL(ifbs.ticket_detail_id, cd.ticket_detail_id) IS NOT  NULL, ISNULL(ifbs.ticket_detail_id, cd.ticket_detail_id), -1 ) = IIF(ISNULL(ifbs.ticket_detail_id, cd.ticket_detail_id) IS NOT  NULL , ISNULL(cd.ticket_detail_id,ifbs.ticket_detail_id), -1)
			AND ISNULL(ifbs.match_info_id, -1) = ISNULL(cd.match_info_id, -1)
			AND ifbs.term_start = CASE WHEN ISNULL(ifbs.internal_type,-1) IN (18723,18722,18733,18740) THEN ISNULL(dbo.FNAGetContractMonth(sdh.deal_date),-1) ELSE ISNULL(sdd.term_start,-1) END AND ifbs.internal_type <> -1 AND ifbs.internal_type IS NOT NULL AND ifbs.value IS NOT NULL
		LEFT JOIN user_defined_deal_fields_template uddft ON uddft.template_id=cd.template_id AND uddft.field_name = ifbs.field_id
		LEFT JOIN user_defined_fields_template udft ON udft.field_name = ifbs.field_id
		LEFT JOIN user_defined_deal_fields uddf ON uddf.source_deal_header_id = cd.source_deal_header_id AND uddf.udf_template_id = uddft.udf_template_id
		LEFT JOIN user_defined_deal_detail_fields udddf ON udddf.source_deal_detail_id = sdd.source_deal_detail_id AND udddf.udf_template_id = uddft.udf_template_id
		LEFT JOIN source_counterparty scf ON scf.source_counterparty_id = CASE WHEN ISNULL(ifbs.internal_type,-1) IN (18723,18733,18739) THEN sdh.broker_id ELSE ISNULL(uddf.counterparty_id, udddf.counterparty_id) END
		
		LEFT JOIN user_defined_deal_fields_template uddft_c ON uddft_c.template_id=cd.template_id AND uddft_c.field_name = -5658
		LEFT JOIN user_defined_deal_fields uddf_c ON uddf_c.source_deal_header_id = cd.source_deal_header_id AND uddf_c.udf_template_id = uddft_c.udf_template_id
		LEFT JOIN source_counterparty scf_c ON scf_c.source_counterparty_id = CASE WHEN ISNULL(ifbs.internal_type,-1) IN (18740,18741) THEN uddf_c.udf_value ELSE -1 END
		
		LEFT JOIN user_defined_deal_fields_template uddft_b ON uddft_b.template_id=cd.template_id AND uddft_b.field_name = -5604
		LEFT JOIN user_defined_deal_fields uddf_b ON uddf_b.source_deal_header_id = cd.source_deal_header_id AND uddf_b.udf_template_id = uddft_b.udf_template_id

		LEFT JOIN user_defined_deal_fields_template uddft_co ON uddft_co.template_id=cd.template_id AND uddft_co.field_name = -10000261
		LEFT JOIN user_defined_deal_fields uddf_co ON uddf_co.source_deal_header_id = cd.source_deal_header_id AND uddft_co.udf_template_id = uddf_co.udf_template_id

		LEFT JOIN contract_group cg ON cg.contract_id = CASE WHEN ISNULL(ifbs.internal_type,-1) IN (18723,18733,18739) THEN ISNULL(uddf_b.udf_value,uddf.contract_id) WHEN ISNULL(ifbs.internal_type,-1) IN (18740,18741) THEN ISNULL(uddf_co.udf_value,uddf.contract_id) ELSE ISNULL(uddf.contract_id, udddf.contract_id) END 
		LEFT JOIN dbo.SplitCommaSeperatedValues(@counterparty_id) cpt ON cpt.item = ISNULL(scf.source_counterparty_id,cd.Counterparty_ID)
		WHERE 
		CASE WHEN NULLIF(@counterparty_id,'') IS NULL THEN 1 ELSE cpt.item END IS NOT NULL 
	END

	/*
	 * [Collect the Deal Pre Pay]
	 */
	INSERT INTO #All_Collected_Data (
		Match_Group_ID,
		Shipment_ID,
		Source_Deal_Header_ID,
		Source_Deal_Detail_ID,
		Ticket_ID,
		Ticket_Detail_ID,
		Counterparty_ID,
		Contract_ID,
		Deal_Charge_Type_ID,
		[Deal_Charge_Name],
		[Currency_ID],
		Term_Start,
		Term_End,
		[Type],
		[movement_date],
		[tkt_schedule_volume],
		[tkt_actual_volume],
		match_info_id
	)
	SELECT	DISTINCT cd.Match_Group_ID,
			cd.Shipment_ID,
			cd.Source_Deal_Header_ID,
			NULL Source_Deal_Detail_ID,
			cd.Ticket_ID,
			cd.Ticket_Detail_ID,
			cd.Counterparty_ID,
			cd.Contract_ID,
			-6600 [Deal_Charge_Type_ID],
			'Prepay' [Deal_Charge_Name],
			cd.[Currency_ID],
			dbo.fnagetcontractmonth(sdp.settlement_date) Term_Start,
			eomonth(sdp.settlement_date) Term_End,
			'Prepay' [Type],
			cd.[movement_date],
			cd.[tkt_schedule_volume],
			cd.[tkt_actual_volume],
			cd.match_info_id
	FROM #Collected_Deals cd
	INNER JOIN source_deal_prepay sdp ON cd.Source_Deal_Header_ID = sdp.source_deal_header_id
	OUTER APPLY (SELECT SUM(amount) amount FROM stmt_prepay sp WHERE sp.source_deal_header_id = cd.Source_Deal_Header_ID AND dbo.fnagetcontractmonth(sp.settlement_date) = dbo.fnagetcontractmonth(sdp.settlement_date)) pr
	WHERE ISNULL(pr.amount,-1) <> 0 

	/*
	 * [Collect the Deal Pre Pay to be applied]
	 */
	INSERT INTO #All_Collected_Data (
		Match_Group_ID,
		Shipment_ID,
		Source_Deal_Header_ID,
		Source_Deal_Detail_ID,
		Ticket_ID,
		Ticket_Detail_ID,
		Counterparty_ID,
		Contract_ID,
		Deal_Charge_Type_ID,
		[Deal_Charge_Name],
		[Currency_ID],
		Term_Start,
		Term_End,
		[Type],
		[movement_date],
		[tkt_schedule_volume],
		[tkt_actual_volume],
		match_info_id
	)
	SELECT	MAX(cd.Match_Group_ID),
			MAX(cd.Shipment_ID),
			cd.Source_Deal_Header_ID,
			NULL Source_Deal_Detail_ID,
			MAX(cd.Ticket_ID),
			MAX(cd.Ticket_Detail_ID),
			MAX(cd.Counterparty_ID),
			MAX(cd.Contract_ID),
			-6600 [Deal_Charge_Type_ID],
			'Prepay Apply' [Deal_Charge_Name],
			MAX(cd.[Currency_ID]),
			@date_from Term_Start,
			@date_to Term_End,
			'Prepay_Apply' [Type],
			MAX(cd.[movement_date]),
			MAX(cd.[tkt_schedule_volume]),
			MAX(cd.[tkt_actual_volume]),
			MAX(cd.match_info_id)
	FROM #Collected_Deals cd
	INNER JOIN [stmt_prepay] sp ON cd.Source_Deal_Header_ID = sp.source_deal_header_id
	GROUP BY cd.Source_Deal_Header_ID
	HAVING SUM(sp.amount) <> 0 OR MIN(ISNULL(stmt_invoice_detail_id,-111)) > -111

	IF OBJECT_ID('tempdb..#mx_asofdate') IS NOT NULL
		DROP TABLE #mx_asofdate

	SELECT source_deal_header_id,leg,term_start, term_end, field_id, counterparty_id, contract_id, contract_charge_type_id, shipment_id, ticket_detail_id, match_info_id, [type], 
	MAX(as_of_date) [as_of_date] 
	INTO #mx_asofdate
	FROM vwIndexFeesBreakdownStmt
	GROUP BY source_deal_header_id,leg,term_start, term_end, field_id, counterparty_id, contract_id, contract_charge_type_id, shipment_id, ticket_detail_id, match_info_id, [type]


	IF OBJECT_ID('tempdb..#vwIndexFeesBreakdownStmt ') IS NOT NULL
		DROP TABLE #vwIndexFeesBreakdownStmt 

	SELECT ifbs.* 
	INTO #vwIndexFeesBreakdownStmt 
	FROM vwIndexFeesBreakdownStmt ifbs
	INNER JOIN #mx_asofdate mx ON 
		ISNULL(mx.source_deal_header_id,-1) = ISNULL(ifbs.source_deal_header_id,-1)
			AND ISNULL(mx.leg,1) = ISNULL(ifbs.leg,1)
			AND ISNULL(ifbs.term_end,-1) = ISNULL(mx.term_end,-1)
			AND ISNULL(ifbs.field_id,-1) = ISNULL(mx.field_id,-1)
			AND ISNULL(ifbs.contract_charge_type_id,-1) = ISNULL(mx.contract_charge_type_id,-1)
			AND ISNULL(ifbs.counterparty_id,-1) = ISNULL(mx.Counterparty_ID,-1)
			AND ISNULL(ifbs.contract_id,-1) = ISNULL(mx.Contract_ID,-1)
			AND ISNULL(ifbs.shipment_id, -1) = ISNULL(mx.Shipment_ID,-1)	
			AND ISNULL(ifbs.ticket_detail_id, -1) = ISNULL(mx.Ticket_Detail_ID,-1)
			AND ISNULL(ifbs.match_info_id, -1) = ISNULL(mx.match_info_id,-1)
			AND ifbs.[Type] = mx.[Type]
			AND ifbs.as_of_date = mx.as_of_date

	/*
	 * FINAL OUTPUT QUERY
	 */
	SELECT 
		CASE 
			WHEN @view_type = 1 THEN 'SHP - ' + CAST(acd.Shipment_ID AS VARCHAR)	
			ELSE sc.counterparty_name			
		END								[Group1],
		CASE 
			WHEN @view_type = 1 THEN sdh.deal_id	
			ELSE cg.[contract_name]
		END								[Group2],
		CASE 
			WHEN @view_type = 3 THEN sti.invoice_number +
					'<img src="../../../adiha.php.scripts/adiha_pm_html/process_controls/stmt_checkout_icons/stmt_apply_cash_full.png" id= "apply_cash_full" class = "apply_cash_icons" onclick = "apply_cash_full(' + CAST(sti.invoice_number AS VARCHAR) + ')" ></img>' +
					'<img src="../../../adiha.php.scripts/adiha_pm_html/process_controls/stmt_checkout_icons/stmt_apply_cash_partial.png" id= "apply_cash_partial" class = "apply_cash_icons" onclick = "apply_cash_partial(' + CAST(sti.invoice_number AS VARCHAR) + ')" ></img>'+
					'<img src="../../../adiha.php.scripts/adiha_pm_html/process_controls/stmt_checkout_icons/stmt_apply_cash_delete.png" id= "apply_cash_delete" class = "apply_cash_icons" onclick = "apply_cash_delete(' + CAST(sti.invoice_number AS VARCHAR) + ')" ></img>'
			ELSE ISNULL([Deal_Charge_Name],charges.code)
		END								[Group3],
		CASE 
			WHEN @view_type = 3 THEN ISNULL([Deal_Charge_Name],charges.code)
			ELSE ''
		END								[Group4],
		''								[Group5],
		''								[Validation_Status],
		sc.counterparty_id				[Counterparty],
		'<a onclick = "open_deal_screen(' + CAST(sdh.source_deal_header_id AS VARCHAR) + ')" href = "#"/>' + sdh.deal_id + '</a>'	[Deal_Reference],
		IIF(CAST(th.ticket_number AS VARCHAR(1000)) IS NOT NULL, '<a onclick = "open_grid_ticket_hyperlink(' + CAST(ISNULL(th.ticket_header_id,'') AS VARCHAR) + ', ''Ticket_Number'')" href = "#"/>' + CAST(th.ticket_number AS VARCHAR(1000)) + '</a>', NULL) [Ticket_Number],
		--th.ticket_number				[Ticket_Number],
		sdd.Leg							[Leg],
		acd.Match_Group_ID				[Match_Group_ID],
		acd.Shipment_ID					[Shipment_ID],
		CASE WHEN ifbs.[Type] = 'Complex Contract Charges' THEN ISNULL(ifbs.source_deal_header_id,acd.source_deal_header_id) ELSE acd.Source_Deal_Header_ID END	[Deal_ID],
		CASE WHEN ifbs.[Type] = 'Complex Contract Charges' THEN COALESCE(ifbs.source_deal_detail_id,acd.Source_Deal_Detail_ID, acd.Source_Deal_Header_ID * -1) ELSE ISNULL(acd.Source_Deal_Detail_ID, acd.Source_Deal_Header_ID * -1) END	[Deal_Detail_ID],
		acd.Ticket_ID					[Ticket_ID],
		acd.Counterparty_ID				[Counterparty_ID],
		ISNULL(sti.contract_id,acd.Contract_ID)					[Contract_ID],
		acd.Deal_Charge_Type_ID			[Deal_Charge_Type_ID],
		acd.[Contract_Charge_Type_ID]	[Contract_Charge_Type_ID],
		cur.source_currency_id			[Currency_ID],
		su.source_uom_id				[Volume_UOM_ID],
		cg.[contract_name]				[Contract],
		sdt.source_deal_type_name		[Deal_Type],
		ifbs.as_of_date					[As_of_Date],
		acd.Term_Start					[Term_Start],
		CASE WHEN YEAR(acd.Term_End) = 1900 THEN NULL ELSE acd.Term_End END [Term_End],
		dbo.FNADateFormat(acd.movement_date)			[Movement_Date],
		CASE WHEN ISNULL(sdd.buy_sell_flag,sdh.header_buy_sell_flag) = 'b' THEN 'Buy' WHEN ISNULL(sdd.buy_sell_flag,sdh.header_buy_sell_flag) = 's' THEN 'Sell'ELSE NULL END				[Buy_Sell],		
		ABS(ISNULL(mhdi.assigned_vol, CAST(sdd.total_volume AS NUMERIC(32,4))))			[Deal_Volume],
		ABS(CAST(CASE WHEN acd.match_info_id IS NOT NULL THEN NULL ELSE COALESCE(tkt_schedule_volume,sdd.schedule_volume) END AS NUMERIC(32,4)))		[Schedule_Volume],
		ABS(CAST(CASE WHEN acd.match_info_id IS NOT NULL THEN NULL ELSE COALESCE(tkt_actual_volume,sdd.actual_volume) END AS NUMERIC(32,4)))		[Actual_Volume],
		ABS(IIF(CAST(ifbs.volume AS VARCHAR(1000)) IS NOT NULL,  CONVERT(NUMERIC(32,4),ifbs.volume), NULL))  [Settlement_Volume],
		  su.uom_name						[Volume_UOM],
   
        CASE WHEN Deal_Charge_Name = 'Positive Price Commodity' OR Deal_Charge_Name = 'Negative Price Commodity' THEN
	     ABS(IIF(CAST(ifbs.value AS VARCHAR(1000)) IS NOT NULL, CONVERT(varchar,CAST(ROUND(ifbs.value, 2) AS NUMERIC(32,4)),1), NULL)/ISNULL(NULLIF(ABS(IIF(CAST(ifbs.volume AS VARCHAR(1000)) IS NOT NULL,  CONVERT(NUMERIC(32,4),ifbs.volume), NULL)),0),1)) ELSE IIF(CAST(ifbs.price AS VARCHAR(1000)) IS NOT NULL, CONVERT(NUMERIC(32,4),ABS(ifbs.price)), NULL) END [Price],

		CASE WHEN ISNULL(stmt.[type],'x') = 'Prepay_Apply' THEN  CONVERT(varchar,CAST(ROUND(ISNULL(stid.value, ifbs.value), 2) AS NUMERIC(32,4)),1) 
		ELSE
		IIF(CAST(ifbs.value AS VARCHAR(1000)) IS NOT NULL, CONVERT(varchar,CAST(ROUND(ifbs.value, 2) AS NUMERIC(32,4)),1), NULL)	END [Amount],
		sdv4.code					[Status],
		cur.currency_name				[Currency],
		'Complete'						[Pricing_Status],
		scm.commodity_name				[Product],
		sdv1.code						[Charge_Type_Alias],
		CASE WHEN @invoice_status = 1 THEN '' ELSE sdv2.code END [PNL_Line_Item],
		sdv3.code [Invoicing_Charge_Type],
		acc.charge_type_alias			[Charge_Type_Alias_ID],
		acc.pnl_line_item_id			[PNL_Line_Item_ID],
		acc.invoicing_charge_type_id    [Invoicing_Charge_Type_ID],
		CASE WHEN @invoice_status = 1 THEN '' ELSE ISNULL(stmt.debit_gl_number,gsm.gl_account_number) END [Debit_GL_Number],
		CASE WHEN @invoice_status = 1 THEN '' ELSE ISNULL(stmt.credit_gl_number,gsm1.gl_account_number) END [Credit_GL_Number],
		CASE WHEN ifbs.value > 0 THEN gsm_d.gl_account_number ELSE gsm_d_minus.gl_account_number END [Payment_Dr_GL_Code],  
		CASE WHEN ifbs.value > 0 THEN gsm_c.gl_account_number ELSE gsm_c.gl_account_number END [Payment_Cr_GL_Code], 
		sti.invoice_number				[Invoice],
		CAST(CONVERT(NUMERIC(32,4),ifbs.price) AS VARCHAR(1000))		[Price_Value],
		CAST(CONVERT(NUMERIC(32,4),ifbs.value) AS VARCHAR(1000))		[Amount_Value],
		CAST(CONVERT(NUMERIC(32,4),ifbs.volume) AS VARCHAR(1000))		[Settlement_Volume_Value],
		CASE 
			WHEN acd.[Type] = 'Commodity Charge' THEN ifbs.source_deal_settlement_id 	
			WHEN acd.[Type] = 'Cost' THEN 	ifbs.index_fees_id
			WHEN acd.[Type] = 'Complex Contract Charges' THEN ifbs.stmt_contract_settlement_id	
			WHEN acd.[Type] = 'Adjustment' THEN ifbs.stmt_adjustments_id	
			WHEN acd.[Type] = 'Prepay' THEN ifbs.source_deal_prepay_id
			WHEN acd.[Type] = 'Prepay_Apply' THEN -1
		END	[Index_Fees_ID],
		stmt.stmt_checkout_id			[Stmt_Checkout_ID],
		stmt_est.stmt_checkout_id		[Est_Post_GL_ID],
		sti.stmt_invoice_id				[Stmt_Invoice_ID],
		acd.[Type]						[Type],
		CONVERT(NUMERIC(32,4),CASE WHEN sacd.settle_status IS NULL AND sac.settle_status = 'Partially Paid' THEN 0 ELSE ISNULL(sacd.cash_received, CASE WHEN sac.stmt_invoice_detail_id IS NOT NULL THEN ifbs.value ELSE '' END) END
		- CASE WHEN sac.settle_status = 'Fully Paid' AND sacd.settle_status IS NULL THEN ISNULL(sacd.variance_amount, sac.variance_amount) ELSE 0 END)	[Apply_Cash_Received],
		CASE WHEN sacd.settle_status IS NULL AND sac.settle_status = 'Partially Paid' THEN 'Not Paid' WHEN sac.settle_status = 'Fully Paid' THEN 'Fully Paid' ELSE COALESCE(sacd.settle_status, sac.settle_status, 'Not Paid') END																[Apply_Cash_Status],
		CONVERT(NUMERIC(32,4),CASE WHEN sacd.settle_status IS NULL AND sac.settle_status = 'Partially Paid' THEN ISNULL(stmt.settlement_amount,stmt_est.settlement_amount) ELSE ISNULL(sacd.variance_amount, sac.variance_amount) END )	[Apply_Cash_Variance],
		sac.received_date [payment_date],
		acm.[reversal_required] [reversal_required],
		--acd.match_info_id,
        CASE WHEN @invoice_status = 4 AND sti.invoice_type = 'r'
				THEN  'Remittance'
             WHEN @invoice_status = 4 AND sti.invoice_type = 'i'
				THEN 'Invoice'
        ELSE '' END [invoice_type]
 FROM #All_Collected_Data acd
	LEFT JOIN source_deal_header sdh ON sdh.source_deal_header_id = acd.Source_Deal_Header_ID
	LEFT JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = acd.Source_Deal_Detail_ID
	LEFT JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id
	LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = acd.Counterparty_ID
	LEFT JOIN static_data_value charges ON charges.value_id = acd.Contract_Charge_Type_ID
	LEFT JOIN source_commodity scm ON scm.source_commodity_id = sdh.commodity_id
	LEFT JOIN ticket_header th ON acd.Ticket_ID = th.ticket_header_id
	LEFT JOIN matching_header_detail_info mhdi ON mhdi.id = acd.match_info_id
	LEFT JOIN stmt_netting_group sng ON sng.counterparty_id = acd.counterparty_id AND sng.netting_type IN (109801,109802) AND sng.effective_date = ISNULL((
			SELECT MAX(effective_date) effective_date FROM stmt_netting_group sng
			WHERE sng.counterparty_id = acd.counterparty_id AND sng.netting_type IN (109801,109802) AND sng.effective_date <= GETDATE()
		),-1)
	LEFT JOIN stmt_netting_group_detail sngd ON sngd.contract_detail_id = acd.contract_id AND sng.netting_group_id = sngd.netting_group_id

	LEFT JOIN #vwIndexFeesBreakdownStmt ifbs ON 
		ISNULL(sdh.source_deal_header_id,-1) = CASE WHEN ifbs.[Type] = 'Complex Contract Charges' THEN -1 ELSE ISNULL(ifbs.source_deal_header_id,-1) END
		AND ISNULL(sdd.leg,1) = ISNULL(ifbs.leg,1)
		--AND ISNULL(ifbs.term_start,-1) =  CASE WHEN ISNULL(ifbs.internal_type,-1) IN (18723,18722,18733) THEN ISNULL(dbo.FNAGetContractMonth(sdh.deal_date),-1) ELSE ISNULL(acd.Term_Start,-1) END
		AND COALESCE(ifbs.term_end,acd.Term_End,-1) =  ISNULL(acd.Term_End,-1)
		AND ISNULL(ifbs.field_id,-1) = ISNULL(acd.Deal_Charge_Type_ID,-1)
		AND ISNULL(ifbs.contract_charge_type_id,-1) = ISNULL(acd.Contract_Charge_Type_ID,-1)
		AND ISNULL(ifbs.counterparty_id,acd.Counterparty_ID) = ISNULL(acd.Counterparty_ID,-1)
		AND COALESCE(ifbs.contract_id,acd.Contract_ID,-1) = ISNULL(acd.Contract_ID,-1)
		AND COALESCE(ifbs.shipment_id, acd.Shipment_ID, -1) = ISNULL(acd.Shipment_ID,-1)	
		AND COALESCE(ifbs.ticket_detail_id, acd.Ticket_Detail_ID, -1) = ISNULL(acd.Ticket_Detail_ID,-1)
		AND COALESCE(ifbs.match_info_id, acd.match_info_id, -1) = ISNULL(acd.match_info_id,-1)
		AND CASE WHEN ifbs.[Type] = 'Fees Calc Flag' THEN 'Commodity Charge' ELSE ifbs.[Type] END = acd.[Type]
		--AND ifbs.as_of_date = (SELECT ISNULL(MAX(as_of_date),ifbs.as_of_date) FROM vwIndexFeesBreakdownStmt mx
		--						WHERE	ISNULL(mx.source_deal_header_id,-1) = ISNULL(ifbs.source_deal_header_id,-1)
		--								AND ISNULL(mx.leg,1) = ISNULL(ifbs.leg,1)
		--								AND ISNULL(ifbs.term_end,-1) = ISNULL(mx.term_end,-1)
		--								AND ISNULL(ifbs.field_id,-1) = ISNULL(mx.field_id,-1)
		--								AND ISNULL(ifbs.contract_charge_type_id,-1) = ISNULL(mx.contract_charge_type_id,-1)
		--								AND ISNULL(ifbs.counterparty_id,-1) = ISNULL(mx.Counterparty_ID,-1)
		--								AND ISNULL(ifbs.contract_id,-1) = ISNULL(mx.Contract_ID,-1)
		--								AND COALESCE(ifbs.shipment_id, acd.Shipment_ID, -1) = ISNULL(acd.Shipment_ID,-1)	
		--								AND COALESCE(ifbs.ticket_detail_id, acd.Ticket_Detail_ID, -1) = ISNULL(acd.Ticket_Detail_ID,-1)
		--								AND COALESCE(ifbs.match_info_id, mx.match_info_id, -1) = ISNULL(mx.match_info_id,-1)
		--								AND CASE WHEN ifbs.[Type] = 'Fees Calc Flag' THEN 'Commodity Charge' ELSE ifbs.[Type] END = acd.[Type]
		--						)

	LEFT JOIN stmt_checkout stmt ON stmt.accrual_or_final = 'f'   AND stmt.index_fees_id = CASE WHEN ifbs.[Type] = 'Commodity Charge' THEN ifbs.source_deal_settlement_id WHEN ifbs.[Type] = 'Adjustment' THEN ifbs.stmt_adjustments_id WHEN ifbs.[Type] = 'Prepay' THEN ifbs.source_deal_prepay_id WHEN ifbs.[Type] = 'Prepay_Apply' THEN ifbs.stmt_prepay_id WHEN ifbs.[Type] = 'Complex Contract Charges' THEN ifbs.stmt_contract_settlement_id ELSE ifbs.index_fees_id END AND ifbs.[Type] = stmt.[type]
	OUTER APPLY (
		SELECT MAX(stmt_checkout_id) stmt_checkout_id 
		FROM stmt_checkout stmt_est
		WHERE stmt_est.accrual_or_final = 'a' AND stmt_est.index_fees_id = CASE WHEN ifbs.[Type] = 'Commodity Charge' THEN ifbs.source_deal_settlement_id WHEN ifbs.[Type] = 'Adjustment' THEN ifbs.stmt_adjustments_id WHEN ifbs.[Type] = 'Prepay' THEN ifbs.source_deal_prepay_id WHEN ifbs.[Type] = 'Prepay_Apply' THEN ifbs.stmt_prepay_id WHEN ifbs.[Type] = 'Complex Contract Charges' THEN ifbs.stmt_contract_settlement_id ELSE ifbs.index_fees_id END AND ifbs.[Type] = stmt.[type] 
		GROUP BY stmt_est.index_fees_id
	) stmt_est_mx
	
	LEFT JOIN stmt_checkout stmt_est ON stmt_est.stmt_checkout_id = stmt_est_mx.stmt_checkout_id 
	LEFT JOIN stmt_invoice_detail stid_est ON stid_est.stmt_invoice_detail_id = stmt_est.stmt_invoice_detail_id
	LEFT JOIN stmt_invoice_detail stid ON stid.stmt_invoice_detail_id = stmt.stmt_invoice_detail_id
	LEFT JOIN stmt_invoice sti ON sti.stmt_invoice_id = stid.stmt_invoice_id AND ISNULL(sti.is_voided,'n') <> 'v'
	LEFT JOIN stmt_invoice stii ON stii.stmt_invoice_id = stid.stmt_invoice_id AND ISNULL(stii.is_voided,'n') <> 'v'
	LEFT JOIN contract_group cg ON cg.contract_id = ISNULL(sti.contract_id,acd.Contract_ID)
	OUTER APPLY (
					SELECT MAX(contract_detail_id) contract_detail_id 
					FROM stmt_netting_group ng
					INNER JOIN stmt_netting_group_detail ngd ON ng.netting_group_id = ngd.netting_group_id
					WHERE ng.netting_contract_id = ISNULL(sti.contract_id,acd.Contract_ID)
	) nett
	LEFT JOIN contract_group cg1 ON cg1.contract_id = nett.contract_detail_id
	LEFT JOIN counterparty_contract_address cca 
		ON cca.counterparty_id = sc.source_counterparty_id
		AND cca.contract_id = ISNULL(cg1.contract_id,cg.contract_id)
	LEFT JOIN dbo.SplitCommaSeperatedValues(@contract_category) cc_csv ON cc_csv.item = cca.contract_category 
	LEFT JOIN source_uom su ON su.source_uom_id = cg.volume_uom
	LEFT JOIN source_currency cur ON cur.source_currency_id = ISNULL(ifbs.currency_id,acd.Currency_ID)
	LEFT JOIN static_data_value sdv4 ON sdv4.value_id = stmt.status and sdv4.type_id = 112900

	LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = sdd.location_id
	OUTER APPLY ( SELECT max(acm.stmt_account_code_mapping_id) stmt_account_code_mapping_id,  max(acm.reversal_required) reversal_required, max(is_hide) is_hide from stmt_account_code_mapping acm where 
		COALESCE(acm.buy_sell_flag,sdd.buy_sell_flag,'1') = ISNULL(sdd.buy_sell_flag,'1')
		AND COALESCE(acm.source_deal_type_id,sdh.source_deal_type_id,-1) = ISNULL(sdh.source_deal_type_id,-1)
		AND COALESCE(acm.source_deal_sub_type_id,sdh.deal_sub_type_type_id,-1) = ISNULL(sdh.deal_sub_type_type_id,-1)
		AND COALESCE(acm.commodity_id,sdh.commodity_id,-1) = ISNULL(sdh.commodity_id,-1)
		AND COALESCE(acm.location_id,sdd.location_id,-1) = ISNULL(sdd.location_id,-1)
		AND COALESCE(acm.location_group_id,sml.source_major_location_ID,-1) = ISNULL(sml.source_major_location_ID,-1)
		AND COALESCE(acm.template_id,sdh.template_id,-1) = ISNULL(sdh.template_id,-1)
		AND COALESCE(acm.currency_id,cur.source_currency_id,-1) = ISNULL(cur.source_currency_id,-1)
		AND COALESCE(acm.counterparty_group,sc.type_of_entity,-1) = ISNULL(sc.type_of_entity,-1)
		AND COALESCE(acm.region,sc.region,-1) = ISNULL(sc.region,-1)
		AND COALESCE(acm.contract_id,cg.contract_id,-1) = ISNULL(cg.contract_id,-1)
		AND COALESCE(acm.counterparty_type,sc.int_ext_flag,'-1') = ISNULL(sc.int_ext_flag,'-1') ) acm
	LEFT JOIN stmt_account_code_chargetype acc ON acc.stmt_account_code_mapping_id = acm.stmt_account_code_mapping_id
		AND (acc.deal_charge_type_id = acd.Deal_Charge_Type_ID OR acc.contract_charge_type_id = acd.Contract_Charge_Type_ID)
	OUTER APPLY(SELECT MAX(ISNULL(effective_date,'9999-12-31')) effective_date 
		FROM stmt_account_code_gl WHERE stmt_account_code_chargetype_id = acc.stmt_account_code_chargetype_id AND effective_date <= ISNULL(sdd.term_start,sdh.entire_term_start)
	) acg1
   
	LEFT JOIN stmt_account_code_gl acg ON acg.stmt_account_code_chargetype_id = acc.stmt_account_code_chargetype_id AND ISNULL(acg.effective_date,'9999-12-31') = ISNULL(acg1.effective_date,'9999-12-31')
	LEFT JOIN adjustment_default_gl_codes adgc2 ON adgc2.default_gl_id  = acg.payment_gl_group
	LEFT JOIN gl_system_mapping gsm_c ON gsm_c.gl_number_id = CASE WHEN sngd.netting_group_detail_id IS NULL THEN adgc2.credit_gl_number ELSE adgc2.netting_credit_gl_number END 
	LEFT JOIN gl_system_mapping gsm_c_minus ON gsm_c_minus.gl_number_id = CASE WHEN sngd.netting_group_detail_id IS NULL THEN adgc2.credit_gl_number_minus ELSE adgc2.netting_credit_gl_number_minus END
	LEFT JOIN gl_system_mapping gsm_d ON gsm_d.gl_number_id = CASE WHEN sngd.netting_group_detail_id IS NULL THEN adgc2.debit_gl_number ELSE adgc2.netting_debit_gl_number END
	LEFT JOIN gl_system_mapping gsm_d_minus ON gsm_d_minus.gl_number_id = CASE WHEN sngd.netting_group_detail_id IS NULL THEN adgc2.debit_gl_number_minus ELSE adgc2.netting_debit_gl_number_minus END

	LEFT JOIN static_data_value sdv1 ON sdv1.value_id = acc.charge_type_alias
	LEFT JOIN static_data_value sdv2 ON sdv2.value_id = acc.pnl_line_item_id 
	LEFT JOIN static_data_value sdv3 ON sdv3.value_id = acc.invoicing_charge_type_id 
	LEFT JOIN adjustment_default_gl_codes adgc ON adgc.default_gl_id = CASE WHEN ISNULL(@accrual_or_final_flag,'f') = 'a' THEN acg.estimate_gl ELSE acg.final_gl END
	LEFT JOIN gl_system_mapping gsm ON gsm.gl_number_id = CASE WHEN ifbs.value >= 0 
		THEN CASE WHEN sngd.netting_group_detail_id IS NULL THEN adgc.debit_gl_number ELSE adgc.netting_debit_gl_number END
		ELSE CASE WHEN sngd.netting_group_detail_id IS NULL THEN adgc.debit_gl_number_minus ELSE adgc.netting_debit_gl_number_minus END 
	END 
	LEFT JOIN gl_system_mapping gsm1 ON gsm1.gl_number_id = CASE WHEN ifbs.value >= 0 
		THEN CASE WHEN sngd.netting_group_detail_id IS NULL THEN adgc.credit_gl_number  ELSE adgc.netting_credit_gl_number END
		ELSE CASE WHEN sngd.netting_group_detail_id IS NULL THEN adgc.credit_gl_number_minus  ELSE adgc.netting_credit_gl_number_minus END 
	END 
	LEFT JOIN adjustment_default_gl_codes adgc1 ON adgc1.default_gl_id = acg.prior_period_gl
	LEFT JOIN gl_system_mapping gsm2 ON gsm2.gl_number_id = CASE WHEN ifbs.value >= 0 
		THEN CASE WHEN sngd.netting_group_detail_id IS NULL THEN adgc1.debit_gl_number  ELSE adgc1.netting_debit_gl_number END
		ELSE CASE WHEN sngd.netting_group_detail_id IS NULL THEN adgc1.debit_gl_number_minus  ELSE adgc1.netting_debit_gl_number_minus END 
	END 
	LEFT JOIN gl_system_mapping gsm3 ON gsm3.gl_number_id = CASE WHEN ifbs.value >= 0 
		THEN CASE WHEN sngd.netting_group_detail_id IS NULL THEN adgc1.credit_gl_number  ELSE adgc1.netting_credit_gl_number END
		ELSE CASE WHEN sngd.netting_group_detail_id IS NULL THEN adgc1.credit_gl_number_minus  ELSE adgc1.netting_credit_gl_number_minus END
	END 

	OUTER APPLY (SELECT sac.stmt_invoice_detail_id, 
						SUM(sac.cash_received) [cash_received], 
						CASE WHEN MIN(sac.settle_status) = 's' THEN 'Fully Paid' ELSE 'Partially Paid' END [settle_status], 
						SUM(sac.variance_amount) [variance_amount],
						dbo.FNADATEFORMAT(MAX(sac.received_date)) [received_date]
				FROM stmt_apply_cash sac
				WHERE sac.stmt_invoice_detail_id = stid.stmt_invoice_detail_id
				GROUP BY sac.stmt_invoice_detail_id ) sac

	OUTER APPLY (SELECT sacd.stmt_invoice_detail_id, 
						sacd.stmt_checkout_id, 
						sacd.cash_received, 
						CASE WHEN sacd.settle_status = 's' THEN 'Fully Paid' ELSE 'Partially Paid' END  [settle_status], 
						sacd.variance_amount 
				FROM stmt_apply_cash_detail sacd
				WHERE sacd.stmt_invoice_detail_id = sac.stmt_invoice_detail_id AND (sac.settle_status = 'Partially Paid' OR sac.variance_amount <> 0) AND sacd.stmt_checkout_id = stmt.stmt_checkout_id
				) sacd
               	LEFT JOIN dbo.SplitCommaSeperatedValues(@deal_charge_type_id) dcti ON dcti.item = 
                ISNULL(acd.Deal_Charge_Type_ID,charges.value_id) 
	WHERE 1=1
        	
	AND CASE WHEN @view_type = 1 THEN acd.Shipment_ID ELSE sc.source_counterparty_id END IS NOT NULL
	--AND acc.stmt_account_code_chargetype_id IS NOT NULL
	AND CASE 
			 --Unprocessed from both Settlement Checkout and Run Accrual
			 --Show data that not exists in index_fees_breakdown_settlement
			WHEN @invoice_status = 1 AND ifbs.index_fees_id IS NULL THEN -1
			
			-- Processed from Settlement Checkout
			-- Show data that exists in index_fees_breakdown_settlement and dont exists in stmt_checkout with 'f' in accrual_or_final column
			WHEN @invoice_status = 2 AND @accrual_or_final_flag = 'f' AND ifbs.index_fees_id IS NOT NULL AND stmt.stmt_checkout_id IS NULL AND ISNULL(stmt.is_ignore, 0) <> 1 THEN -1 
			
			-- Processed from Run Accural
			-- Show data that exists in index_fees_breakdown_settlement and dont exists in stmt_checkout with 'a' in accrual_or_final column
			WHEN @invoice_status = 2 AND @accrual_or_final_flag = 'a' AND ifbs.index_fees_id IS NOT NULL AND stid_est.stmt_invoice_detail_id IS NULL AND stid.stmt_invoice_detail_id IS NULL AND ISNULL(stmt.is_ignore, 0) <> 1 THEN -1
			
			 --Ready For Invoice from Settlement Checkout
			 --Show data that exists in exists in stmt_checkout with 'a' in accrual_or_final column and dont exists in stmt_invoice
			WHEN @invoice_status = 3 AND @accrual_or_final_flag = 'f' AND stmt.stmt_checkout_id IS NOT NULL AND sti.stmt_invoice_id IS NULL 
			AND stmt.is_ignore <> 1 THEN -1 
			
			-- Invoiced from Settlement Checkout
			-- Show data that exists in exists in stmt_invoice
			WHEN @invoice_status = 4 AND @accrual_or_final_flag = 'f' AND sti.stmt_invoice_id IS NOT NULL THEN -1 

			--Ingnored data
			WHEN @invoice_status = 6 AND @accrual_or_final_flag IN ('f', 'a')  AND stmt.is_ignore= 1 THEN -1  
			
			-- Posted GL from Run Accrual 
			-- Show data that exists in exists in stmt_checkout with 'a' in accrual_or_final column
			WHEN @invoice_status = 5 AND @accrual_or_final_flag = 'a' AND stmt_est.stmt_checkout_id IS NOT NULL THEN -1 
			ELSE 1 
		END = -1
	AND CASE 
			WHEN ISNULL(@prior_period,'n') = 'y' AND @invoice_status IN ('2') AND @accrual_or_final_flag='a' THEN ISNULL(@date_from,acd.Term_Start) 
			WHEN ISNULL(@prior_period,'n') = 'y' AND @invoice_status IN ('2','3') THEN acd.term_start 
			ELSE ISNULL(@date_from,acd.Term_Start) 
		END <= acd.Term_Start
	AND ISNULL(@date_to,acd.Term_End) >= acd.Term_End
	AND ISNULL(ifbs.[Type],'x') <> 'Fees Calc Flag'  -- For Handing Broker Calculation in Grid
	AND acd.term_start <= CASE WHEN @accrual_or_final_flag = 'a' THEN ISNULL(@accounting_date, acd.term_start) ELSE acd.term_start END
	AND CASE WHEN @view_type = 5 THEN 'n' WHEN ISNULL(acm.is_hide,'n') = 'n' THEN ISNULL(acc.is_hide,'n') ELSE acm.is_hide END = 'n'
	AND CASE WHEN ISNULL([Deal_Charge_Name],charges.code) = 'Prepay Apply' THEN ISNULL(stid.value, ifbs.value) ELSE -1 END <> 0
    AND CASE WHEN NULLIF(@deal_charge_type_id,'') IS NULL THEN 1 ELSE dcti.item END IS NOT NULL
	AND CASE WHEN NULLIF(@counterparty_type,'') IS NULL THEN '1' ELSE sc.int_ext_flag END = CASE WHEN NULLIF(@counterparty_type,'') IS NULL THEN '1' ELSE @counterparty_type END
	AND CASE WHEN @invoice_status = 1 THEN 1 ELSE ISNULL(ifbs.value,0) END <> 0
	AND CASE WHEN NULLIF(@contract_category,'') IS NULL THEN '1' ELSE cc_csv.item END IS NOT NULL
    

END

ELSE IF @flag IN ('checkout', 'ignore', 'auto_checkout')
BEGIN
	BEGIN TRY
		DECLARE @require_reversal INT = 1
		IF @flag = 'ignore' SET @require_reversal = 0
		IF @accrual_or_final_flag = 'f' SET @require_reversal = 0

		EXEC sp_xml_preparedocument @idoc OUTPUT,@xml
		
		IF OBJECT_ID('tempdb..#temp_checkouts') IS NOT NULL
			DROP TABLE #temp_checkouts

		CREATE TABLE #temp_checkouts (
			source_deal_detail_id		INT
			,shipment_id				INT
			,ticket_id					INT
			,deal_charge_type_id		INT
			,contract_charge_type_id	INT
			,counterparty_id			INT
			,counterparty_name			VARCHAR(500) COLLATE DATABASE_DEFAULT
			,contract_id				INT
			,as_of_date					DATETIME			
			,term_start					DATETIME	
			,term_end					DATETIME
			,currency_id				INT
			,uom_id						INT
			,settlement_amount			VARCHAR(100) COLLATE DATABASE_DEFAULT
			,settlement_volume			VARCHAR(100) COLLATE DATABASE_DEFAULT
			,settlement_price			VARCHAR(100) COLLATE DATABASE_DEFAULT
			,scheduled_volume			VARCHAR(100) COLLATE DATABASE_DEFAULT
			,acutal_volume				VARCHAR(100) COLLATE DATABASE_DEFAULT
			,[status]					INT
			,index_fees_id				INT		
			,debit_gl_number			VARCHAR(100) COLLATE DATABASE_DEFAULT
			,credit_gl_number			VARCHAR(100) COLLATE DATABASE_DEFAULT
			,pnl_line_item_id			INT
			,charge_type_alias			VARCHAR(500) COLLATE DATABASE_DEFAULT
			,invoicing_charge_type_id	INT
			,invoice_frequency			VARCHAR(100) COLLATE DATABASE_DEFAULT
			,[type]						VARCHAR(100) COLLATE DATABASE_DEFAULT
			,is_reversal_required		CHAR(1) COLLATE DATABASE_DEFAULT
			,match_info_id				INT
		)

		CREATE TABLE #temp_settlement_checkout(stmt_checkout_id INT)

		IF @flag = 'auto_checkout'
		BEGIN
			IF OBJECT_ID('tempdb..#temp_all_grid_data') IS NOT NULL
				DROP TABLE #temp_all_grid_data
			
			CREATE TABLE #temp_all_grid_data (
				Group1						VARCHAR(1000) COLLATE DATABASE_DEFAULT,
				Group2						VARCHAR(1000) COLLATE DATABASE_DEFAULT,
				Group3						VARCHAR(1000) COLLATE DATABASE_DEFAULT,
				Group4						VARCHAR(1000) COLLATE DATABASE_DEFAULT,
				Group5						VARCHAR(1000) COLLATE DATABASE_DEFAULT,
				Validation_Status			VARCHAR(1000) COLLATE DATABASE_DEFAULT,
				Counterparty				VARCHAR(1000) COLLATE DATABASE_DEFAULT,
				Deal_Reference				VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
				Ticket_Number				INT,
				Leg							INT,
				Match_Group_ID				INT,
				Shipment_ID					INT,
				Deal_ID						INT,
				Deal_Detail_ID				INT,
				Ticket_ID					INT,
				Counterparty_ID				INT,
				Contract_ID					INT,
				Deal_Charge_Type_ID			INT,
				Contract_Charge_Type_ID		INT,
				Currency_ID					INT,
				Volume_UOM_ID				INT,
				[Contract]					VARCHAR(1000) COLLATE DATABASE_DEFAULT,
				Deal_Type					VARCHAR(1000) COLLATE DATABASE_DEFAULT,
				As_of_Date					DATETIME,
				Term_Start					DATETIME,
				Term_End					DATETIME,
				Movement_Date				DATETIME,
				Buy_Sell					VARCHAR(1000) COLLATE DATABASE_DEFAULT,
				Deal_Volume					NUMERIC(32,20),
				Schedule_Volume				NUMERIC(32,20),
				Actual_Volume				NUMERIC(32,20),
				Settlement_Volume			NUMERIC(32,20),
				Volume_UOM					VARCHAR(1000) COLLATE DATABASE_DEFAULT,
				Price						VARCHAR(1000) COLLATE DATABASE_DEFAULT,
				Amount						VARCHAR(1000) COLLATE DATABASE_DEFAULT,
				[Status]					VARCHAR(1000) COLLATE DATABASE_DEFAULT,
				Currency					VARCHAR(1000) COLLATE DATABASE_DEFAULT,
				Pricing_Status				VARCHAR(1000) COLLATE DATABASE_DEFAULT,
				Product						VARCHAR(1000) COLLATE DATABASE_DEFAULT,
				Charge_Type_Alias			VARCHAR(1000) COLLATE DATABASE_DEFAULT,
				PNL_Line_Item				VARCHAR(1000) COLLATE DATABASE_DEFAULT,
				Invoicing_Charge_Type		VARCHAR(1000) COLLATE DATABASE_DEFAULT,
				Charge_Type_Alias_ID		INT,
				PNL_Line_Item_ID			INT,
				Invoicing_Charge_Type_ID	INT,
				Debit_GL_Number				VARCHAR(1000) COLLATE DATABASE_DEFAULT,
				Credit_GL_Number			VARCHAR(1000) COLLATE DATABASE_DEFAULT,
				Payment_Dr_GL_Code			VARCHAR(1000) COLLATE DATABASE_DEFAULT,
				Payment_Cr_GL_Code			VARCHAR(1000) COLLATE DATABASE_DEFAULT,
				Invoice						INT,
				Price_Value					NUMERIC(32,20),
				Amount_Value				NUMERIC(32,20),
				Settlement_Volume_Value		NUMERIC(32,20),
				Index_Fees_ID				INT,
				Stmt_Checkout_ID			INT,
				Est_Post_GL_ID				INT,
				Stmt_Invoice_ID				INT,
				[Type]						VARCHAR(1000) COLLATE DATABASE_DEFAULT,
				Apply_Cash_Received			NUMERIC(32,20),
				Apply_Cash_Status			VARCHAR(1000) COLLATE DATABASE_DEFAULT,
				Apply_Cash_Variance			NUMERIC(32,20),
				payment_date				DATETIME,
				reversal_required			VARCHAR(1000) COLLATE DATABASE_DEFAULT,
				match_info_id				INT
			)

			INSERT INTO #temp_all_grid_data
			EXEC spa_stmt_checkout @flag = 'grid',@accrual_or_final_flag = 'f',@source_deal_header_id = @source_deal_header_id, @invoice_status = 2,@deal_id = @deal_id, @view_type = 5

			INSERT INTO #temp_checkouts 
			SELECT	Deal_Detail_ID
				,shipment_id
				,ticket_id
				,deal_charge_type_id
				,contract_charge_type_id
				,counterparty_id
				,Counterparty
				,contract_id
				,as_of_date
				,term_start
				,term_end
				,currency_id
				,Volume_UOM_ID
				,Amount_Value
				,Settlement_Volume_Value
				,Price_Value
				,Schedule_Volume
				,Actual_Volume
				,[status]
				,index_fees_id
				,debit_gl_number
				,credit_gl_number
				,pnl_line_item_id
				,charge_type_alias_id
				,invoicing_charge_type_id
				,'' invoice_frequency
				,[type]
				,reversal_required 
				,match_info_id
			FROM #temp_all_grid_data

		END
		ELSE
		BEGIN
		-- Execute a SELECT statement that uses the OPENXML rowset provider.

		INSERT INTO #temp_checkouts
		SELECT	source_deal_detail_id
				,shipment_id
				,ticket_id
				,deal_charge_type_id
				,contract_charge_type_id
				,counterparty_id
				,counterparty_name
				,contract_id
				,as_of_date
				,term_start
				,term_end
				,currency_id
				,uom_id
				,settlement_amount
				,settlement_volume
				,settlement_price
				,scheduled_volume
				,acutal_volume
				,[status]
				,index_fees_id
				,debit_gl_number
				,credit_gl_number
				,pnl_line_item_id
				,charge_type_alias
				,invoicing_charge_type_id
				,invoice_frequency
				,[type]
				,is_reversal_required 
				,match_info_id
		FROM OPENXML(@idoc, '/Root/PSRecordSet', 1)
		WITH (
			source_deal_detail_id		INT
			,shipment_id				INT
			,ticket_id					INT
			,deal_charge_type_id		INT
			,contract_charge_type_id	INT
			,counterparty_id			INT
			,counterparty_name			VARCHAR(500)
			,contract_id				INT
			,as_of_date					DATETIME			
			,term_start					DATETIME	
			,term_end					DATETIME
			,currency_id				INT
			,uom_id						INT
			,settlement_amount			VARCHAR(100)
			,settlement_volume			VARCHAR(100)
			,settlement_price			VARCHAR(100)
			,scheduled_volume			VARCHAR(100)
			,acutal_volume				VARCHAR(100)
			,[status]					INT
			,index_fees_id				INT		
			,debit_gl_number			VARCHAR(100)
			,credit_gl_number			VARCHAR(100)
			,pnl_line_item_id			INT
			,charge_type_alias			INT
			,invoicing_charge_type_id	INT
			,invoice_frequency			VARCHAR(100)
			,[type]						VARCHAR(100)
			,is_reversal_required		CHAR(1)
			,match_info_id				INT
		)
		END

	
		INSERT INTO stmt_checkout (	source_deal_detail_id
									,shipment_id
									,ticket_id
									,deal_charge_type_id
									,contract_charge_type_id
									,counterparty_id
									,counterparty_name
									,contract_id
									,as_of_date
									,term_start
									,term_end
									,currency_id
									,uom_id
									,settlement_amount
									,settlement_volume
									,settlement_price
									,scheduled_volume
									,acutal_volume
									,[status]
									,index_fees_id
									,debit_gl_number
									,credit_gl_number
									,pnl_line_item_id
									,charge_type_alias
									,invoicing_charge_type_id
									,accrual_or_final
									,invoice_frequency
									,[type]
									,accounting_month
									, is_ignore
									, is_reversal_required
									, match_info_id
									)
		OUTPUT INSERTED.stmt_checkout_id INTO #temp_settlement_checkout(stmt_checkout_id)
		SELECT	NULLIF(tc.source_deal_detail_id,0)
				,NULLIF(tc.shipment_id,0)
				,NULLIF(tc.ticket_id,0)
				,NULLIF(tc.deal_charge_type_id,0)
				,NULLIF(tc.contract_charge_type_id,0)
				,tc.counterparty_id
				,tc.counterparty_name
				,NULLIF(tc.contract_id,0)
				,tc.as_of_date
				,tc.term_start
				,tc.term_end
				,NULLIF(tc.currency_id,0)
				,NULLIF(tc.uom_id,0)
				,CONVERT(NUMERIC(32,20),ISNULL(NULLIF(tc.settlement_amount,''),0)) * rev.[rev_index]
				,CONVERT(NUMERIC(32,20),ISNULL(NULLIF(tc.settlement_volume,''),0)) * rev.[rev_index]
				,CONVERT(NUMERIC(32,20),ISNULL(NULLIF(tc.settlement_price,''),0))
				,CONVERT(NUMERIC(32,20),NULLIF(tc.scheduled_volume,''))
				,CONVERT(NUMERIC(32,20),NULLIF(tc.acutal_volume,''))
				,NULLIF(tc.[status],0)
				,tc.index_fees_id
				,NULLIF(tc.credit_gl_number,'')
				,NULLIF(tc.debit_gl_number,'')
				,NULLIF(tc.pnl_line_item_id,0)
				,NULLIF(tc.charge_type_alias,0)
				,NULLIF(tc.invoicing_charge_type_id,0)
				,CASE WHEN rev.[rev_index] = -1 THEN 'r' ELSE @accrual_or_final_flag END [accrual_or_final_flag]
				,NULLIF(tc.invoice_frequency,'')
				,NULLIF(tc.[type],'')
				,CASE WHEN rev.[rev_index] = -1 THEN DATEADD(mm,1,@accounting_month) ELSE @accounting_month END
				,IIF(@flag= 'ignore',1, 0 )
				,tc.is_reversal_required
				,NULLIF(tc.match_info_id,0)
		FROM #temp_checkouts tc
		LEFT JOIN stmt_checkout sc ON sc.index_fees_id = tc.index_fees_id AND sc.[type] = tc.[type] AND sc.accrual_or_final = 'x'
		OUTER APPLY (SELECT 1 [rev_index] UNION SELECT CASE WHEN @require_reversal = 1 AND ISNULL(tc.is_reversal_required,'n') = 'y' THEN -1 ELSE 1 END) rev 
		WHERE sc.stmt_checkout_id IS NULL

		IF @flag= 'ignore'
		BEGIN
			UPDATE sc SET  sc.accrual_or_final = 'f' FROM stmt_checkout sc INNER JOIN #temp_settlement_checkout tsc ON sc.stmt_checkout_id = tsc.stmt_checkout_id
		END

		--SELECT sc.stmt_checkout_id, stmt_a.stmt_checkout_id
		UPDATE sc 
			SET sc.reversal_stmt_checkout_id = stmt_a.stmt_checkout_id
		FROM stmt_checkout sc 
		INNER JOIN #temp_checkouts tc
			ON tc.source_deal_detail_id = sc.source_deal_detail_id
			AND tc.deal_charge_type_id = sc.deal_charge_type_id
			AND tc.counterparty_id = sc.counterparty_id
			AND tc.contract_id = ISNULL(sc.contract_id, 0)
			AND tc.as_of_date = sc.as_of_date
			AND tc.term_start = sc.term_start
			AND tc.term_end = sc.term_end
			AND tc.currency_id = sc.currency_id
			AND tc.uom_id = sc.uom_id
			AND ABS(CAST(ISNULL(NULLIF(tc.settlement_amount, ''), 0) AS NUMERIC(16,4))) = ABS(sc.settlement_amount)  --
			AND ABS(CAST(ISNULL(NULLIF(tc.settlement_volume, ''), 0) AS NUMERIC(16,4))) = ABS(sc.settlement_volume)  --
			AND  CAST(ISNULL(NULLIF(tc.settlement_price, ''), 0)  AS NUMERIC(16,4)) = sc.settlement_price
			AND tc.index_fees_id = sc.index_fees_id
			AND tc.debit_gl_number = sc.credit_gl_number
			AND tc.credit_gl_number = sc.debit_gl_number
			AND tc.pnl_line_item_id = ISNULL(sc.pnl_line_item_id, 0)
			AND tc.charge_type_alias = ISNULL(sc.charge_type_alias, 0)
			AND tc.invoicing_charge_type_id = ISNULL(sc.invoicing_charge_type_id, 0)
			AND tc.type = sc.type AND sc.accrual_or_final = 'r'
		INNER JOIN #temp_settlement_checkout tmp ON sc.stmt_checkout_id = tmp.stmt_checkout_id 
		OUTER APPLY (
			SELECT sc.stmt_checkout_id 
				FROM stmt_checkout sc 
			INNER JOIN #temp_settlement_checkout tmp ON sc.stmt_checkout_id = tmp.stmt_checkout_id
				WHERE sc.source_deal_detail_id = tc.source_deal_detail_id
			AND sc.deal_charge_type_id = tc.deal_charge_type_id
			AND sc.counterparty_id = tc.counterparty_id
			AND tc.contract_id = ISNULL(sc.contract_id, 0)
			AND sc.as_of_date = tc.as_of_date
			AND sc.term_start = tc.term_start
			AND sc.term_end = tc.term_end
			AND sc.currency_id = tc.currency_id
			AND sc.uom_id = tc.uom_id
			AND ABS(CAST(ISNULL(NULLIF(tc.settlement_amount, ''), 0) AS NUMERIC(16,4))) = ABS(tc.settlement_amount)  --
			AND ABS(CAST(ISNULL(NULLIF(tc.settlement_volume, ''), 0) AS NUMERIC(16,4))) = ABS(tc.settlement_volume)  --
			AND  CAST(ISNULL(NULLIF(tc.settlement_price, ''), 0) AS NUMERIC(16,4)) = sc.settlement_price
			AND sc.index_fees_id = tc.index_fees_id
			AND sc.debit_gl_number = tc.credit_gl_number
			AND sc.credit_gl_number = tc.debit_gl_number
			AND tc.pnl_line_item_id = ISNULL(sc.pnl_line_item_id, 0)
			AND tc.charge_type_alias = ISNULL(sc.charge_type_alias, 0)
			AND tc.invoicing_charge_type_id = ISNULL(sc.invoicing_charge_type_id, 0)
			AND sc.type = tc.type AND sc.accrual_or_final = 'a'
		) stmt_a

		IF @accrual_or_final_flag = 'a'
		BEGIN
			UPDATE sc_pre 
			SET reversal_stmt_checkout_id = -1
			FROM stmt_checkout sc 
			INNER JOIN #temp_settlement_checkout tmp ON sc.stmt_checkout_id = tmp.stmt_checkout_id AND sc.accrual_or_final = 'r'
			INNER JOIN stmt_checkout sc_pre ON sc_pre.source_deal_detail_id = sc.source_deal_detail_id 
				AND sc.deal_charge_type_id = sc_pre.deal_charge_type_id 
				AND sc.term_start = sc_pre.term_start
				AND sc.accounting_month > sc_pre.accounting_month
				AND sc_pre.accrual_or_final = 'r'
			LEFT JOIN stmt_invoice_detail stid ON stid.stmt_invoice_detail_id = sc_pre.stmt_invoice_detail_id
			WHERE stid.stmt_invoice_detail_id IS NULL
		END

		--IF @accrual_or_final_flag='f'
		--BEGIN
		--	DELETE sc_d FROM stmt_checkout sc 
		--	INNER JOIN #temp_settlement_checkout tsc ON sc.stmt_checkout_id = tsc.stmt_checkout_id
		--	INNER JOIN stmt_checkout sc_d ON sc_d.source_deal_detail_id = sc.source_deal_detail_id AND sc_d.accounting_month = sc.accounting_month
		--	WHERE sc_d.accrual_or_final = 'a' AND sc.accrual_or_final = 'f'
		--END

		DECLARE @process_id VARCHAR(100) = dbo.FNAGetNewID()
		DECLARE @alert_process_table VARCHAR(200) = 'adiha_process.dbo.alert_stmt_checkout_' + @process_id + '_ai'

		EXEC('CREATE TABLE ' + @alert_process_table + ' (stmt_checkout_id INT)')
				
		SET @sql = 'INSERT INTO ' + @alert_process_table + '(stmt_checkout_id) 
					SELECT stmt_checkout_id FROM #temp_settlement_checkout'


		EXEC(@sql)		

		IF @accrual_or_final_flag = 'f'
		BEGIN
			EXEC spa_register_event 20627, 20583, @alert_process_table, 1, @process_id
		END

		IF @accrual_or_final_flag = 'a'
		BEGIN
			EXEC spa_register_event 20627, 10000324, @alert_process_table, 1, @process_id
		END

		IF @flag <> 'auto_checkout'
			EXEC spa_ErrorHandler 0,
				 'Settlement Checkout',
				 'spa_settlement_checkout',
				 'Success',
				 'Successfully Saved',
				 ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		  
		IF @flag <> 'auto_checkout' 
			EXEC spa_ErrorHandler -1,
				 'Settlement Checkout',
				 'spa_settlement_checkout',
				 'Error',
				 'Failed to Save',
				 ''
	END CATCH
END


ELSE IF @flag = 'checkout_revert'
BEGIN
	BEGIN TRY
		EXEC sp_xml_preparedocument @idoc OUTPUT,@xml
		
		IF OBJECT_ID('tempdb..#temp_checkouts_revert') IS NOT NULL
			DROP TABLE #temp_checkouts_revert

		-- Execute a SELECT statement that uses the OPENXML rowset provider.
		SELECT	stmt_checkout_id
		INTO #temp_checkouts_revert
		FROM OPENXML(@idoc, '/Root/PSRecordSet', 1)
		WITH (
			stmt_checkout_id       INT
		)

		DELETE sc 
		FROM stmt_checkout sc 
		INNER JOIN #temp_checkouts_revert tmp ON sc.reversal_stmt_checkout_id = tmp.stmt_checkout_id AND sc.accrual_or_final = 'd'

		DELETE sc 
		FROM stmt_checkout sc 
		INNER JOIN #temp_checkouts_revert tmp ON sc.reversal_stmt_checkout_id = tmp.stmt_checkout_id AND sc.accrual_or_final = 'r'

		DELETE sc
		FROM stmt_checkout sc
		INNER JOIN #temp_checkouts_revert tmp ON sc.stmt_checkout_id = tmp.stmt_checkout_id 

		EXEC spa_ErrorHandler 0,
             'Settlement Checkout',
             'spa_settlement_checkout',
             'Success',
             'Successfully Saved',
             ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		EXEC spa_ErrorHandler -1,
             'Settlement Checkout',
             'spa_settlement_checkout',
             'Error',
             'Failed to Save',
             ''
	END CATCH
END

ELSE IF @flag = 'submitted_accrual_revert'
BEGIN
	BEGIN TRY
		SET @sql = '
		DELETE sc
			FROM stmt_checkout sc 
		WHERE sc.stmt_checkout_id IN ( ' + @stmt_checkout_ids  + ') OR sc.reversal_stmt_checkout_id IN ( ' + @stmt_checkout_ids + ')'
		EXEC(@sql)

		EXEC spa_ErrorHandler 0,
             'Settlement Checkout',
             'spa_settlement_checkout',
             'Success',
             'Successfully Saved',
             ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		EXEC spa_ErrorHandler -1,
             'Settlement Checkout',
             'spa_settlement_checkout',
             'Error',
             'Failed to Save',
             ''
	END CATCH
END

ELSE IF @flag = 'prepare_invoice'
BEGIN
	BEGIN TRY
		DECLARE @p_prod_date_from DATETIME = dbo.fnagetcontractmonth(@delivery_month)
		DECLARE @P_prod_date_to DATETIME = EOMONTH(@delivery_month)

		EXEC sp_xml_preparedocument @idoc OUTPUT,@xml
		
		IF OBJECT_ID('tempdb..#temp_prepare_invoice') IS NOT NULL
			DROP TABLE #temp_prepare_invoice

		-- Execute a SELECT statement that uses the OPENXML rowset provider.
		SELECT	stmt_checkout_id
		INTO #temp_prepare_invoice
		FROM OPENXML(@idoc, '/Root/PSRecordSet', 1)
		WITH (
			stmt_checkout_id       INT
		)

		DECLARE @total_charges INT, @total_prepays INT
		SELECT @total_charges = COUNT(1) FROM #temp_prepare_invoice
		SELECT @total_prepays = COUNT(1) FROM #temp_prepare_invoice tmp
		INNER JOIN stmt_checkout sc ON tmp.stmt_checkout_id = sc.stmt_checkout_id
		WHERE sc.deal_charge_type_id = -6600 AND sc.[type] = 'Prepay_Apply'

		IF @total_prepays = @total_charges
		BEGIN
			EXEC spa_ErrorHandler -1,
             'Settlement Checkout',
             'spa_settlement_checkout',
             'Error',
             'Invoice cannot be created with just prepay charges. Please select other charges too.',
             ''

			 RETURN
		END

		UPDATE sc 
		SET sc.settlement_amount = CASE WHEN sdh.header_buy_sell_flag = 'b' THEN  min_prepay.settlement_amount ELSE min_prepay.settlement_amount * -1 END,
			sc.index_fees_id = -2
		FROM #temp_prepare_invoice tmp
		INNER JOIN stmt_checkout sc ON tmp.stmt_checkout_id = sc.stmt_checkout_id
		OUTER APPLY (
			SELECT TOP(1) ABS(SUM(settlement_amount)) settlement_amount FROM #temp_prepare_invoice tmp
			INNER JOIN stmt_checkout sc ON tmp.stmt_checkout_id = sc.stmt_checkout_id
			GROUP BY CASE WHEN sc.deal_charge_type_id = -6600 THEN -6600 ELSE -1 END
			ORDER BY ABS(SUM(settlement_amount)) 
		) min_prepay
		LEFT JOIN source_deal_header sdh ON sdh.source_deal_header_id = ABS(sc.source_deal_detail_id)
		WHERE sc.deal_charge_type_id = -6600 AND sc.[type] = 'Prepay_Apply'
		
		DECLARE @inv_process_id VARCHAR(100) = dbo.FNAGetNewID()
		DECLARE @inv_alert_process_table VARCHAR(200) = 'adiha_process.dbo.alert_stmt_checkout_' + @inv_process_id + '_ai'

		EXEC('CREATE TABLE ' + @inv_alert_process_table + ' (stmt_checkout_id INT)')
				
		SET @sql = 'INSERT INTO ' + @inv_alert_process_table + '(stmt_checkout_id) 
					SELECT stmt_checkout_id FROM #temp_prepare_invoice'

		EXEC(@sql)		
		EXEC spa_register_event 20627, 20587, @inv_alert_process_table, 1, @inv_process_id
		
		IF OBJECT_ID('tempdb..#temp_new_invoices') IS NOT NULL
				DROP TABLE #temp_new_invoices

		CREATE TABLE #temp_new_invoices(
			stmt_invoice_id			INT,
			counterparty_id			INT,
			contract_id				INT,
			prod_date_from			DATETIME,
			prod_date_to			DATETIME,
			invoice_type			NCHAR(1),
			is_contract_netting		NCHAR(1),
			is_backing_sheet		NCHAR(1)
		)

		IF OBJECT_ID('tempdb..#temp_new_invoices_details') IS NOT NULL
				DROP TABLE #temp_new_invoices_details

		CREATE TABLE #temp_new_invoices_details(
			stmt_invoice_detail_id			INT,
			stmt_checkout_id				VARCHAR(MAX) COLLATE DATABASE_DEFAULT
		)
		
		IF OBJECT_ID('tempdb..#temp_netting_mapping') IS NOT NULL
				DROP TABLE #temp_netting_mapping

		CREATE TABLE #temp_netting_mapping(
			netting_contract_id	INT,
			contract_id			INT
		)

		/*
		 * INVOICE FOR NOT NETTING
		 */
		INSERT INTO stmt_invoice (
			as_of_date,
			counterparty_id,
			contract_id,
			prod_date_from,
			prod_date_to,
			invoice_number,
			invoice_type,
			is_backing_sheet
		)
		OUTPUT INSERTED.stmt_invoice_id,INSERTED.counterparty_id,INSERTED.contract_id,INSERTED.prod_date_from,INSERTED.prod_date_to, INSERTED.invoice_type, 'n', INSERTED.is_backing_sheet
		INTO #temp_new_invoices(stmt_invoice_id,counterparty_id,contract_id,prod_date_from,prod_date_to, invoice_type, is_contract_netting, is_backing_sheet)
		SELECT	MAX(sc.accounting_month),
				sc.counterparty_id,
				sc.contract_id,
				MIN(ISNULL(@p_prod_date_from,sc.term_start)), 
				MAX(ISNULL(@p_prod_date_to,sc.term_end)),
				1,
				it.invoice_type,
				CASE WHEN ISNULL(sng.create_backing_sheet,'n') = 'y' THEN 'y' ELSE 'n' END [is_backing_sheet]
		FROM stmt_checkout sc
		INNER JOIN #temp_prepare_invoice tmp ON sc.stmt_checkout_id = tmp.stmt_checkout_id
		INNER JOIN contract_group cg ON cg.contract_id = sc.contract_id
		LEFT JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = sc.source_deal_detail_id
		LEFT JOIN stmt_netting_group sng ON sng.counterparty_id = sc.counterparty_id AND sng.netting_type IN (109801,109802) AND sng.effective_date = ISNULL((
				SELECT MAX(effective_date) effective_date FROM stmt_netting_group sng
				WHERE sng.counterparty_id = sc.counterparty_id AND sng.netting_type IN (109801,109802) AND sng.effective_date <= GETDATE()
			),-1)
		LEFT JOIN stmt_netting_group_detail sngd ON sngd.contract_detail_id = sc.contract_id AND sng.netting_group_id = sngd.netting_group_id
		OUTER APPLY (
			SELECT 'i' [invoice_type]
			UNION ALL
			SELECT 'r' [invoice_type] FROM contract_group cg 
			INNER JOIN counterparty_contract_address cca ON cca.contract_id = cg.contract_id AND cca.counterparty_id = sc.counterparty_id
			WHERE cg.contract_id = sc.contract_id AND COALESCE(cca.neting_rule,cg.neting_rule,'n') = 'n'
		) it
		WHERE (sngd.netting_group_detail_id IS NULL OR ISNULL(sng.create_backing_sheet,'n') = 'y')
		GROUP BY sc.counterparty_id, sc.contract_id, it.invoice_type, sng.create_backing_sheet
	
		/*
		 * INVOICE FOR COUNTERPARTY NETTING
		 */
		INSERT INTO stmt_invoice (
			as_of_date,
			counterparty_id,
			contract_id,
			prod_date_from,
			prod_date_to,
			invoice_number,
            invoice_type
		)
		OUTPUT INSERTED.stmt_invoice_id,INSERTED.counterparty_id,INSERTED.contract_id,INSERTED.prod_date_from,INSERTED.prod_date_to, INSERTED.invoice_type, 'y', 'n'
		INTO #temp_new_invoices(stmt_invoice_id,counterparty_id,contract_id,prod_date_from,prod_date_to, invoice_type, is_contract_netting, is_backing_sheet)
		SELECT	MAX(sc.accounting_month),
				sc.counterparty_id,
				sng.netting_contract_id,
				MIN(ISNULL(@p_prod_date_from,sc.term_start)), 
				MAX(ISNULL(@p_prod_date_to,sc.term_end)),
				1,
               it.invoice_type
		FROM stmt_checkout sc
		INNER JOIN #temp_prepare_invoice tmp ON sc.stmt_checkout_id = tmp.stmt_checkout_id
		LEFT JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = sc.source_deal_detail_id
		LEFT JOIN stmt_netting_group sng ON sng.counterparty_id = sc.counterparty_id AND sng.netting_type IN (109801,109802)  AND sng.effective_date = ISNULL((
				SELECT MAX(effective_date) effective_date FROM stmt_netting_group sng
				WHERE sng.counterparty_id = sc.counterparty_id AND sng.netting_type IN (109801,109802) AND sng.effective_date <= GETDATE()
			),-1)
		LEFT JOIN stmt_netting_group_detail sngd ON sngd.contract_detail_id = sc.contract_id AND sng.netting_group_id = sngd.netting_group_id
	OUTER APPLY (
			SELECT 'i' [invoice_type]
			--UNION ALL
			--SELECT 'r' [invoice_type] FROM contract_group cg 
			--INNER JOIN counterparty_contract_address cca ON cca.contract_id = sng.netting_contract_id AND cca.counterparty_id = sc.counterparty_id
			--WHERE cg.contract_id = sng.netting_contract_id AND COALESCE(cca.neting_rule,cg.neting_rule,'n') = 'n'
		) it	
                WHERE sngd.netting_group_detail_id IS NOT NULL
		GROUP BY sc.counterparty_id, sng.netting_contract_id,it.invoice_type

		UPDATE si SET 
			si.payment_date = dbo.FNAInvoiceDueDate( CASE WHEN ISNULL(cca.settlement_due_date,cg.invoice_due_date) = '20023'  OR ISNULL(cca.settlement_due_date,cg.invoice_due_date) = '20024' THEN si.finalized_date ELSE si.prod_date_from END, ISNULL(cca.settlement_due_date,cg.invoice_due_date), cg.holiday_calendar_id, ISNULL(cca.settlement_payment_days,cg.payment_days)),
			si.invoice_date = dbo.FNAInvoiceDueDate( CASE WHEN ISNULL(cca.settlement_date,cg.settlement_date) = '20023'  OR ISNULL(cca.settlement_date,cg.settlement_date) = '20024' THEN si.finalized_date ELSE si.prod_date_from END, ISNULL(cca.settlement_date,cg.settlement_date), cg.holiday_calendar_id, ISNULL(cca.settlement_days,cg.settlement_days))
		FROM stmt_invoice si
		INNER JOIN contract_group cg ON  cg.contract_id = si.contract_id
		INNER JOIN #temp_new_invoices tmp ON tmp.stmt_invoice_id = si.stmt_invoice_id
		LEFT JOIN counterparty_contract_address cca ON cca.contract_id = si.contract_id AND cca.counterparty_id = si.counterparty_id

		INSERT INTO #temp_netting_mapping (netting_contract_id, contract_id)
		SELECT DISTINCT sng.netting_contract_id,sngd.contract_detail_id 
		FROM stmt_checkout sc
		INNER JOIN #temp_prepare_invoice tmp ON sc.stmt_checkout_id = tmp.stmt_checkout_id
		LEFT JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = sc.source_deal_detail_id
		LEFT JOIN stmt_netting_group sng ON sng.counterparty_id = sc.counterparty_id AND sng.netting_type IN (109801,109802)  AND sng.effective_date = ISNULL((
				SELECT MAX(effective_date) effective_date FROM stmt_netting_group sng
				WHERE sng.counterparty_id = sc.counterparty_id AND sng.netting_type IN (109801,109802) AND sng.effective_date <= GETDATE()
			),-1)
		LEFT JOIN stmt_netting_group_detail sngd ON sngd.contract_detail_id = sc.contract_id AND sng.netting_group_id = sngd.netting_group_id
		WHERE sngd.netting_group_id IS NOT NULL

		/*
		 * INVOICE DETAILS LOGIC
		 */
		IF OBJECT_ID('tempdb..#temp_all_calc_details') IS NOT NULL
				DROP TABLE #temp_all_calc_details

		SELECT DISTINCT
			tmp_n.stmt_invoice_id,
			dbo.fnagetcontractmonth(sc.term_start) prod_date_from,
			EOMONTH(sc.term_end) prod_date_to,
			ISNULL(sc.invoicing_charge_type_id, sc.contract_charge_type_id) invoicing_charge_type_id,
			sc.settlement_amount,
			sc.settlement_volume,
			sc.stmt_checkout_id,
			tmp_n.is_backing_sheet
		INTO #temp_all_calc_details
		FROM stmt_checkout sc
		INNER JOIN #temp_prepare_invoice tmp ON sc.stmt_checkout_id = tmp.stmt_checkout_id
		INNER JOIN contract_group cg ON cg.contract_id = sc.contract_id
		LEFT JOIN counterparty_contract_address cca ON cca.contract_id = cg.contract_id AND cca.counterparty_id = sc.counterparty_id
		LEFT JOIN #temp_netting_mapping tmp_net ON tmp_net.contract_id = sc.contract_id
		INNER JOIN #temp_new_invoices tmp_n ON tmp_n.counterparty_id = sc.counterparty_id
			AND tmp_n.contract_id = ISNULL(tmp_net.netting_contract_id,sc.contract_id)
			AND tmp_n.invoice_type = 
				CASE WHEN COALESCE(cca.neting_rule,cg.neting_rule,'n') = 'y' OR tmp_n.is_contract_netting = 'y' THEN 'i'
					WHEN COALESCE(cca.neting_rule,cg.neting_rule,'n') = 'n' AND sc.settlement_amount < 0 THEN 'r'
					ELSE 'i'
				END
			AND ISNULL(tmp_n.is_backing_sheet,'n') = 'n'
			--AND tmp_n.prod_date_from = sc.term_start
			--AND tmp_n.prod_date_to = sc.term_end
		UNION ALL
		SELECT DISTINCT
			tmp_n.stmt_invoice_id,
			dbo.fnagetcontractmonth(sc.term_start) prod_date_from,
			EOMONTH(sc.term_end) prod_date_to,
			ISNULL(sc.invoicing_charge_type_id, sc.contract_charge_type_id) invoicing_charge_type_id,
			sc.settlement_amount,
			sc.settlement_volume,
			sc.stmt_checkout_id,
			tmp_n.is_backing_sheet
		FROM stmt_checkout sc
		INNER JOIN #temp_prepare_invoice tmp ON sc.stmt_checkout_id = tmp.stmt_checkout_id
		INNER JOIN contract_group cg ON cg.contract_id = sc.contract_id
		LEFT JOIN counterparty_contract_address cca ON cca.contract_id = cg.contract_id AND cca.counterparty_id = sc.counterparty_id
		INNER JOIN #temp_new_invoices tmp_n ON tmp_n.counterparty_id = sc.counterparty_id
			AND tmp_n.contract_id = sc.contract_id
			AND tmp_n.invoice_type = 
				CASE WHEN COALESCE(cca.neting_rule,cg.neting_rule,'n') = 'y' OR tmp_n.is_contract_netting = 'y' THEN 'i'
					WHEN COALESCE(cca.neting_rule,cg.neting_rule,'n') = 'n' AND sc.settlement_amount < 0 THEN 'r'
					ELSE 'i'
				END
			AND ISNULL(tmp_n.is_backing_sheet,'n') = 'y'
		
		
		INSERT INTO stmt_invoice_detail (stmt_invoice_id, 
										invoice_line_item_id, 
										prod_date_from, 
										prod_date_to,
										value,
										volume,
										show_volume_in_invoice,
										show_charge_in_invoice,
										description1
										)
		OUTPUT INSERTED.stmt_invoice_detail_id,INSERTED.description1
		INTO #temp_new_invoices_details(stmt_invoice_detail_id,stmt_checkout_id)
		SELECT	tmp.stmt_invoice_id,
				tmp.invoicing_charge_type_id,
				MIN(tmp.prod_date_from),
				MAX(tmp.prod_date_to),
				SUM(tmp.settlement_amount),
				SUM(tmp.settlement_volume),
				'',
				'',
				MAX(b.stmt_checkout_id)	
		FROM #temp_all_calc_details tmp
		INNER JOIN (
			SELECT  DISTINCT stmt_invoice_id, prod_date_from, prod_date_to, invoicing_charge_type_id, is_backing_sheet
					,stmt_checkout_id = stuff((select ', ' + CAST(stmt_checkout_id AS VARCHAR)
					FROM #temp_all_calc_details t1
					WHERE t1.stmt_invoice_id = t2.stmt_invoice_id
							--AND t1.prod_date_from = t2.prod_date_from
							--AND t1.prod_date_to = t2.prod_date_to
							AND t1.invoicing_charge_type_id = t2.invoicing_charge_type_id
					FOR XML PATH('')), 1, 2, '')
			FROM #temp_all_calc_details t2
		) b ON tmp.stmt_invoice_id = b.stmt_invoice_id 
		--AND tmp.prod_date_from = b.prod_date_from 
		--AND tmp.prod_date_to = b.prod_date_to  
		AND b.invoicing_charge_type_id = tmp.invoicing_charge_type_id
		AND tmp.is_backing_sheet = b.is_backing_sheet
		GROUP BY tmp.stmt_invoice_id, tmp.invoicing_charge_type_id


		UPDATE	sti
		SET		sti.invoice_number = sti.stmt_invoice_id,
				--sti.invoice_template_id = NULL, --TODO
				sti.invoice_type = CASE WHEN stid.[value] < 0 THEN 'r' ELSE 'i' END
		FROM #temp_new_invoices tmp
		INNER JOIN stmt_invoice sti ON tmp.stmt_invoice_id = sti.stmt_invoice_id 
		OUTER APPLY (SELECT SUM(stid.value) [value] FROM stmt_invoice_detail stid WHERE stid.stmt_invoice_id = sti.stmt_invoice_id) stid
		
		IF EXISTS (SELECT 1 FROM data_source WHERE name = 'StmtInvoiceNumber')
		BEGIN
			DECLARE @all_stmt_invoice_id NVARCHAR(MAX)

			SELECT @all_stmt_invoice_id = stuff((select ', ' + CAST(stmt_invoice_id AS NVARCHAR)
			FROM #temp_new_invoices
			FOR XML PATH('')), 1, 2, '')

			DECLARE @invoice_number_function NVARCHAR(MAX)
			SELECT @invoice_number_function = tsql FROM data_source WHERE name = 'StmtInvoiceNumber'

			IF OBJECT_ID('tempdb..#invoice_number_fn_result') IS NOT NULL
				DROP TABLE #invoice_number_fn_result

			CREATE TABLE #invoice_number_fn_result (
				stmt_invoice_id INT,
				invoice_number NVARCHAR(2000)
			)

			SET @invoice_number_function = REPLACE(@invoice_number_function, '@stmt_invoice_id', @all_stmt_invoice_id)

			INSERT INTO #invoice_number_fn_result (stmt_invoice_id, invoice_number)
			EXEC(@invoice_number_function)

			UPDATE sti
			SET sti.invoice_number = fn.invoice_number
			 FROM stmt_invoice sti
			INNER JOIN #invoice_number_fn_result fn ON fn.stmt_invoice_id = sti.stmt_invoice_id
		END

		UPDATE sc
		SET sc.[stmt_invoice_detail_id] = tmp.stmt_invoice_detail_id
		 FROM #temp_new_invoices_details tmp
		OUTER APPLY( SELECT itm.item [stmt_checkout_id] FROM dbo.SplitCommaSeperatedValues(tmp.stmt_checkout_id) itm) a 
		INNER JOIN stmt_checkout sc ON a.stmt_checkout_id = sc.stmt_checkout_id
		INNER JOIN stmt_invoice_detail stid ON stid.stmt_invoice_detail_id = tmp.stmt_invoice_detail_id
		INNER JOIN stmt_invoice si On si.stmt_invoice_id = stid.stmt_invoice_id
		WHERE sc.accrual_or_final = 'f' AND ISNULL(si.is_backing_sheet,'n') = 'n'

		UPDATE sc
		SET sc.provisional_invoice_detail_id = tmp.stmt_invoice_detail_id
		FROM #temp_new_invoices_details tmp
		OUTER APPLY( SELECT itm.item [stmt_checkout_id] FROM dbo.SplitCommaSeperatedValues(tmp.stmt_checkout_id) itm) a 
		INNER JOIN stmt_checkout sc ON a.stmt_checkout_id = sc.stmt_checkout_id
		INNER JOIN stmt_invoice_detail stid ON stid.stmt_invoice_detail_id = tmp.stmt_invoice_detail_id
		INNER JOIN stmt_invoice si On si.stmt_invoice_id = stid.stmt_invoice_id
		WHERE sc.accrual_or_final = 'f' AND ISNULL(si.is_backing_sheet,'n') = 'n'

		DELETE sti
		FROM #temp_new_invoices tmp
		INNER JOIN stmt_invoice sti ON tmp.stmt_invoice_id = sti.stmt_invoice_id 
		LEFT JOIN stmt_invoice_detail stid ON sti.stmt_invoice_id = stid.stmt_invoice_id
		WHERE stid.stmt_invoice_id IS NULL

		INSERT INTO stmt_invoice_netting (stmt_invoice_id, netting_contract_id, contract_id)
		SELECT tmp_i.stmt_invoice_id, tmp_n.netting_contract_id, tmp_n.contract_id 
		FROM #temp_new_invoices tmp_i
		INNER JOIN #temp_netting_mapping tmp_n ON tmp_i.contract_id = tmp_n.netting_contract_id
        INNER JOIN stmt_invoice si ON si.stmt_invoice_id = tmp_i.stmt_invoice_id


		/* TAG ACCURALS WHICH HAS BEEN INVOICED */
		IF OBJECT_ID('tempdb..#temp_flag_accruals') IS NOT NULL
				DROP TABLE #temp_flag_accruals

		SELECT MAX(acc.stmt_checkout_id) acc_checkout_id, tmp.stmt_checkout_id, MAX(sc.stmt_invoice_detail_id) [stmt_invoice_detail_id], MAX(sc.accounting_month) [accounting_month]
		INTO #temp_flag_accruals
		FROM #temp_prepare_invoice tmp
		INNER JOIN stmt_checkout sc ON tmp.stmt_checkout_id = sc.stmt_checkout_id
		INNER JOIN stmt_checkout acc ON acc.source_deal_detail_id = sc.source_deal_detail_id
					AND acc.deal_charge_type_id = sc.deal_charge_type_id
				    AND acc.term_start = sc.term_start
					AND acc.term_end = sc.term_end
					AND acc.accrual_or_final <> 'f'
					AND acc.[type] = sc.[type]
		GROUP BY acc.source_deal_detail_id, acc.deal_charge_type_id, acc.term_start, acc.term_end, acc.accrual_or_final,tmp.stmt_checkout_id, acc.shipment_id, acc.ticket_id 

		UPDATE sc
		SET stmt_invoice_detail_id = tmp.stmt_invoice_detail_id
		FROM #temp_flag_accruals tmp
		INNER JOIN stmt_checkout sc ON tmp.acc_checkout_id = sc.stmt_checkout_id

		UPDATE sc
		SET accounting_month = tmp.accounting_month
		FROM #temp_flag_accruals tmp
		INNER JOIN stmt_checkout sc ON tmp.acc_checkout_id = sc.stmt_checkout_id AND sc.accrual_or_final = 'r'

		/* LOGIC TO ADD REVERSAL ITEMS FROM THE PROVISIONAL INVOICE TO ACTUAL INVOICE */
		INSERT INTO stmt_invoice_detail (
			stmt_invoice_id,
			invoice_line_item_id,
			prod_date_from,
			prod_date_to,
			value,
			volume,
			description1
		)
		SELECT	stid.stmt_invoice_id, 
				sc_r.invoicing_charge_type_id,
				dbo.fnagetcontractmonth(sc_r.term_start) prod_date_from,
				EOMONTH(sc_r.term_end) prod_date_to,
				sc_r.settlement_amount,
				sc_r.settlement_volume,
				sc_r.stmt_checkout_id 
		FROM #temp_flag_accruals tmp
		INNER JOIN stmt_checkout sc ON sc.stmt_checkout_id = tmp.acc_checkout_id AND sc.accrual_or_final = 'a' AND sc.provisional_invoice_detail_id IS NOT NULL
		INNER JOIN stmt_checkout sc_r ON sc_r.reversal_stmt_checkout_id = sc.stmt_checkout_id
		INNER JOIN stmt_invoice_detail stid ON stid.stmt_invoice_detail_id = tmp.stmt_invoice_detail_id
		
		
		INSERT INTO [stmt_prepay] (
			source_deal_header_id,
			settlement_date,
			amount,
			is_prepay,
			stmt_invoice_detail_id
		)
		SELECT	DISTINCT ISNULL(sp.source_deal_header_id,sdp.source_deal_header_id),
				ISNULL(sti.prod_date_to,sdp.settlement_date),
				ISNULL(sc.settlement_amount,sdp.value),
				CASE WHEN sc.[type] = 'Prepay' THEN 'y' ELSE 'n' END [is_prepay],
				sc.stmt_invoice_detail_id		
		FROM #temp_new_invoices_details tmp
		OUTER APPLY( SELECT itm.item [stmt_checkout_id] FROM dbo.SplitCommaSeperatedValues(tmp.stmt_checkout_id) itm) a 
		INNER JOIN stmt_checkout sc ON a.stmt_checkout_id =  sc.stmt_checkout_id
		LEFT JOIN source_deal_prepay sdp ON sdp.source_deal_prepay_id = sc.index_fees_id
		LEFT JOIN [stmt_prepay] sp ON sp.source_deal_header_id = ABS(sc.source_deal_detail_id) AND ISNULL(sp.is_prepay,'n') = 'y'
		LEFT JOIN stmt_invoice_detail stid ON stid.stmt_invoice_detail_id = sc.stmt_invoice_detail_id
		LEFT JOIN stmt_invoice sti ON sti.stmt_invoice_id = stid.stmt_invoice_id
		LEFT JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdp.source_deal_header_id
		WHERE sc.[type] = 'Prepay' OR sc.[type] = 'Prepay_Apply'
		
		SET @inv_process_id = dbo.FNAGetNewID()
		SET @inv_alert_process_table = 'adiha_process.dbo.alert_stmt_invoice_' + @inv_process_id + '_ai'

		EXEC('CREATE TABLE ' + @inv_alert_process_table + ' (stmt_invoice_id INT)')
				
		SET @sql = 'INSERT INTO ' + @inv_alert_process_table + '(stmt_invoice_id) 
					SELECT sti.stmt_invoice_id FROM #temp_new_invoices tmp
					INNER JOIN stmt_invoice sti ON tmp.stmt_invoice_id = sti.stmt_invoice_id '

		EXEC(@sql)		
		EXEC spa_register_event 20630, 20588, @inv_alert_process_table, 1, @inv_process_id

		EXEC spa_ErrorHandler 0,
             'Settlement Checkout',
             'spa_settlement_checkout',
             'Success',
             'Successfully Saved',
             ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		EXEC spa_ErrorHandler -1,
             'Settlement Checkout',
             'spa_settlement_checkout',
             'Error',
             'Failed to Save',
             ''
	END CATCH
END

ELSE IF @flag IN ('accrual_final_gl')
BEGIN
	IF OBJECT_ID('tempdb..#temp_deal_details') IS NOT NULL
		DROP TABLE #temp_deal_details
	SELECT DISTINCT a.item [source_deal_detail_id] INTO #temp_deal_details FROM dbo.SplitCommaSeperatedValues(@source_deal_detail_id) a

	IF OBJECT_ID('tempdb..#temp_gl') IS NOT NULL
		DROP TABLE #temp_gl

	CREATE TABLE #temp_gl (
		[Counterparty_Name]			VARCHAR(1000) COLLATE DATABASE_DEFAULT,
		[Charges]					VARCHAR(1000) COLLATE DATABASE_DEFAULT,
		[Account Name]				VARCHAR(1000) COLLATE DATABASE_DEFAULT,
		[Account Number]			VARCHAR(1000) COLLATE DATABASE_DEFAULT,
		[Debit]						FLOAT,
		[Credit]					FLOAT,
		[Order]						INT,
		[Debit_Credit_Order]		INT
	)

	INSERT INTO #temp_gl
	SELECT	sc.counterparty_name		[Counterparty], 
			ifx.field_name				[Charges],
			gl.[GL_Name] [Account Name],
			gl.[GL_Number] [Account Number],
			CASE WHEN gl.[Debit_Credit] = 'Debit' THEN ifx.value ELSE NULL END [Debit],
			CASE WHEN gl.[Debit_Credit] = 'Credit' THEN ifx.value ELSE NULL END [Credit],
			1 [Order],
			ROW_NUMBER() OVER( order by sc.counterparty_name, ifx.field_name, ISNULL(NULLIF(ifx.index_fees_id,-1),ifx.source_deal_settlement_id),debit_credit_order)
	FROM vwIndexFeesBreakdownStmt ifx
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = ifx.source_deal_detail_id
	INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
	LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = sdd.location_id
	LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
	
	LEFT JOIN stmt_account_code_mapping acm ON ISNULL(acm.buy_sell_flag,sdd.buy_sell_flag) = sdd.buy_sell_flag
			AND ISNULL(acm.source_deal_type_id,sdh.source_deal_type_id) = sdh.source_deal_type_id
			AND COALESCE(acm.source_deal_sub_type_id,sdh.deal_sub_type_type_id,-1) = ISNULL(sdh.deal_sub_type_type_id,-1)
			AND COALESCE(acm.commodity_id,sdh.commodity_id,-1) = ISNULL(sdh.commodity_id,-1)
			AND COALESCE(acm.location_id,sdd.location_id,-1) = ISNULL(sdd.location_id,-1)
			AND COALESCE(acm.location_group_id,sml.source_major_location_ID,-1) = ISNULL(sml.source_major_location_ID,-1)
			AND ISNULL(acm.template_id,sdh.template_id) = sdh.template_id
			AND COALESCE(acm.currency_id,ifx.currency_id,-1) = ISNULL(ifx.currency_id,-1)
			AND COALESCE(acm.counterparty_group,sc.type_of_entity,-1) = ISNULL(sc.type_of_entity,-1)
			AND COALESCE(acm.region,sc.region,-1) = ISNULL(sc.region,-1)
			AND COALESCE(acm.contract_id,sdh.contract_id,-1) = ISNULL(sdh.contract_id,-1)
			AND COALESCE(acm.counterparty_type,sc.int_ext_flag,'-1') = ISNULL(sc.int_ext_flag,'-1')
	LEFT JOIN stmt_account_code_chargetype acc ON acc.stmt_account_code_mapping_id = acm.stmt_account_code_mapping_id
		AND (acc.deal_charge_type_id = ifx.field_id)
	OUTER APPLY(SELECT MAX(ISNULL(effective_date,'9999-12-31')) effective_date 
		FROM stmt_account_code_gl WHERE stmt_account_code_chargetype_id = acc.stmt_account_code_chargetype_id AND effective_date <= sdd.term_start
	) acg1
	LEFT JOIN stmt_account_code_gl acg ON acg.stmt_account_code_chargetype_id = acc.stmt_account_code_chargetype_id AND ISNULL(acg.effective_date,'9999-12-31') = ISNULL(acg1.effective_date,'9999-12-31')
	
	LEFT JOIN adjustment_default_gl_codes adgc ON adgc.default_gl_id = CASE WHEN ISNULL(@accrual_or_final_flag,'f') = 'a' THEN acg.estimate_gl ELSE acg.final_gl END
	OUTER APPLY (
		SELECT gsm1.gl_account_name [GL_Name], gsm1.gl_account_number [GL_Number], 'Credit' [Debit_Credit], 1 [debit_credit_order] FROM gl_system_mapping gsm1 
		WHERE gsm1.gl_number_id = CASE WHEN ifx.value >= 0 THEN adgc.credit_gl_number ELSE adgc.credit_gl_number_minus END 
		UNION ALL
		SELECT gsm.gl_account_name [GL_Name], gsm.gl_account_number [GL_Number], 'Debit' [Debit_Credit], 2 [debit_credit_order] FROM gl_system_mapping gsm 
		WHERE gsm.gl_number_id = CASE WHEN ifx.value >= 0 THEN adgc.debit_gl_number ELSE adgc.debit_gl_number_minus END
	) gl
	INNER JOIN #temp_deal_details detail ON detail.source_deal_detail_id = sdd.source_deal_detail_id
	WHERE gl.[GL_Name] IS NOT NULL AND gl.[GL_Number] IS NOT NULL

	INSERT INTO #temp_gl ([Counterparty_Name], [Charges], [Debit], [Credit], [Order], [Debit_Credit_Order])
	SELECT [Counterparty_Name],'Sub-Total' [Charges], SUM([Debit]), SUM([Credit]), 2 [Order], 1 [Debit_Credit_Order]
	FROM #temp_gl
	GROUP BY [Counterparty_Name]

	SELECT	Counterparty_Name,
			Charges,
			[Account Name],
			[Account Number],
			[Debit],
			[Credit]
	FROM #temp_gl
	ORDER BY [Counterparty_Name], [Order], [Debit_Credit_Order]
END

ELSE IF @flag = 'submitted_accrual' --Loading date grid in Submitted Accural Report
BEGIN	
	SET @sql = '
	SELECT 
		stmt_checkout_id,
		dbo.FNADateFormat(stc.create_ts)		[Submitted_Date],
		stc.counterparty_name				[Counterparty_Name],
		cg.contract_name					[Contract_Name],
		sdh.source_deal_header_id			[source_deal_header_id],
		sdh.deal_id							[Deal],
		th.ticket_number					[Ticket_Number],
		dbo.FNADateFormat(as_of_date)		[As_of_Date],
		dbo.FNADateFormat(stc.term_start)	[Term_Start],
		dbo.FNADateFormat(stc.term_end)		[Term_End],
		charges.code						[Charge_Type],
		CONVERT(NUMERIC(32,2),deal_volume)				[Deal_Volume],
		CONVERT(NUMERIC(32,2),scheduled_volume)			[Scheduled_Volume],
		CONVERT(NUMERIC(32,2),acutal_volume)			[Acutal_volume],
		CONVERT(NUMERIC(32,2),stc.settlement_volume)	[Volume],	
		CONVERT(NUMERIC(32,2),settlement_amount)		[Amount],
		CONVERT(NUMERIC(32,2),settlement_price)			[Price],
		al.code					[Charge_Type_Alias],
		pnl_charges.code					[PNL_Line_Item],
		debit_gl_number						[Debit_GL_Number],
		credit_gl_number					[Credit_GL_Number],
		au.user_f_name + '' '' + au.user_l_name	[Submitted_User]
	FROM stmt_checkout stc
	LEFT JOIN source_counterparty sc ON stc.counterparty_id = sc.source_counterparty_id
	LEFT JOIN contract_group cg ON cg.contract_id = stc.contract_id
	LEFT JOIN static_data_value charges ON charges.value_id = stc.deal_charge_type_id
	LEFT JOIN application_users au ON au.user_login_id = stc.create_user
	LEFT JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = stc.source_deal_detail_id
	LEFT JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
	LEFT JOIN static_data_value pnl_charges ON pnl_charges.value_id = stc.pnl_line_item_id
	LEFT JOIN ticket_header th ON th.ticket_header_id = stc.ticket_id
	LEFT JOIN static_data_value al ON al.value_id = charge_type_alias
	WHERE 
		stc.accrual_or_final = ''a''' +
	CASE WHEN NULLIF(@date_from, '') IS NOT NULL THEN ' AND  CONVERT(VARCHAR(10), stc.create_ts, 120) >= '''  + CONVERT(VARCHAR(10), @date_from, 120) + '''' ELSE '' END +
	CASE WHEN NULLIF(@date_to, '') IS NOT NULL THEN ' AND CONVERT(VARCHAR(10), stc.create_ts, 120) <= '''  + CONVERT(VARCHAR(10), @date_to, 120) + '''' ELSE '' END +
	CASE WHEN NULLIF(@counterparty_id, '') IS NOT NULL THEN ' AND stc.counterparty_id IN ('  + @counterparty_id  + ')' ELSE '' END +
	CASE WHEN NULLIF(@contract_id, '') IS NOT NULL THEN ' AND stc.contract_id IN ('  + @contract_id  + ')' ELSE '' END +
	CASE WHEN NULLIF(@accounting_date, '') IS NOT NULL THEN ' AND  CONVERT(VARCHAR(10), stc.accounting_month, 120) = '''  + CONVERT(VARCHAR(10), DATEADD(m, DATEDIFF(m, 0, @accounting_date), 0), 120) + '''' ELSE '' END +
	CASE WHEN NULLIF(@deal_id, '') IS NOT NULL THEN ' AND sdh.source_deal_header_id IN ('  + CAST(@deal_id AS VARCHAR(10)) + ')' ELSE '' END +
	' ORDER BY stc.create_ts'
	--print @sql
	EXEC(@sql)
	


END

ELSE IF @flag = 'price_report' --Loading date grid in Settlement Price Report
BEGIN
	SELECT       
			 pcpd.source_deal_header_id source_deal_header_id,
			 dbo.FNADateFormat(pcpd.term_start) [term_start],
			 coalesce(spcd.curve_name,nullif(fe.formula_name,''),fe.formula,'Fixed Price')  [Curve], 
			 dbo.FNADateFormat(pcpd.as_of_date) [As_of_Date],
			 dbo.FNADateFormat(pcpd.maturity_date)  [maturity_date],
			 pcpd.raw_price    Price,
			 sc.currency_name [Price_Currency],
			 su.uom_name [Price_UOM],
			 pcpd.price_multiplier [Multiplier] ,
			 pcpd.raw_price_adder [Adder],
			 sc1.currency_name [Adder_Currency],
			 sc2.currency_name [Invoice_Currency] , 
			 su1.uom_name [Deal_UOM],
			 ROUND(pcpd.uom_conversion,4) [UOM_Conversion_Factor] ,
			 pcpd.fx_rate_curve [FX_Rate_Curve] ,
			 pcpd.fx_rate_adder [FX_Rate_Adder] ,
			 pcpd.curve_value [Curve_Value] ,
			 pcpd.price_adder [Adder_Value],
			 ISNULL(pcpd.curve_value,0) + ISNULL(pcpd.price_adder,0) [final_price]
	FROM dbo.pnl_component_price_detail pcpd     
	LEFT JOIN source_price_curve_def spcd 
		ON spcd.source_curve_def_id = pcpd.curve_id and pcpd.is_formula ='n'     
	LEFT JOIN formula_editor fe 
		ON fe.formula_id=pcpd.curve_id and pcpd.is_formula ='y'     
	LEFT JOIN source_currency sc 
		ON sc.source_currency_id=pcpd.price_currency     
	LEFT JOIN source_currency sc1 
		ON sc1.source_currency_id=pcpd.adder_currency     
	LEFT JOIN source_currency sc2 
		ON sc2.source_currency_id=pcpd.settlement_currency     
	LEFT JOIN source_uom su 
		ON su.source_uom_id=pcpd.price_uom     
	LEFT JOIN source_uom su1 
		ON su1.source_uom_id=pcpd.uom_id 
	LEFT JOIN ticket_detail td 
		ON td.ticket_detail_id = pcpd.ticket_detail_id
	WHERE 1=1      
		AND source_deal_detail_id = @source_deal_detail_id  
		AND pcpd.term_start = @term_filter	
		AND run_as_of_date = @filter_as_of_date
		AND calc_type = @cal_type_filter
		AND ISNULL(shipment_id, -1) = ISNULL(@shipment_id, -1)
		AND ISNULL(td.ticket_header_id, -1) = ISNULL(@ticket_id, -1)
	ORDER BY as_of_date ASC
END

 
ELSE IF @flag = 'manual_adjustment' 
BEGIN
	DELETE FROM index_fees_breakdown_settlement WHERE source_deal_header_id = @source_deal_header_id

	INSERT INTO index_fees_breakdown_settlement (as_of_date, source_deal_header_id, leg, term_start, term_end, field_id, field_name,value, internal_type, fee_currency_id, currency_id, set_type, value_deal, value_inv, deal_cur_id)
	SELECT	GETDATE() [as_of_date],
			sdh.source_deal_header_id,
			sdd.leg,
			sdd.term_start,
			sdd.term_end,
			uddft.field_name,
			uddft.field_label,
			uddf.udf_value,
			udft.internal_field_type,
			ISNULL(uddf.currency_id,sdd.fixed_price_currency_id) [fee_currency_id],
			ISNULL(sdd.settlement_currency,sdd.fixed_price_currency_id) currency_id,
			's',
			uddf.udf_value [value_deal],
			uddf.udf_value [value_inv],
			sdd.fixed_price_currency_id [deal_cur_id]
	FROM source_deal_header sdh
	INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
	INNER JOIN user_defined_deal_fields_template uddft ON uddft.template_id=sdh.template_id
	LEFT JOIN user_defined_fields_template udft ON udft.field_name = uddft.field_name
	INNER JOIN user_defined_deal_fields uddf ON uddf.source_deal_header_id = sdh.source_deal_header_id AND uddf.udf_template_id = uddft.udf_template_id
	WHERE sdh.source_deal_header_id = @source_deal_header_id
END  

ELSE IF @flag = 'volume_report' --Loading date grid in Settlement Volume Report
BEGIN 
	DECLARE @granularity VARCHAR(10) = NULL,
			@term_start DATETIME = NULL,
			@term_end DATETIME = NULL
	
	IF OBJECT_ID('tempdb..#temp_deal_meter_ids') IS NOT NULL
	DROP TABLE #temp_deal_meter_ids
  
	CREATE TABLE #temp_deal_meter_ids(source_deal_detail_id INT, location_id INT, meter_id INT, meter_name VARCHAR(500) COLLATE DATABASE_DEFAULT , channel INT, term_start DATETIME, term_end DATETIME)

	SET @sql = '
			INSERT INTO #temp_deal_meter_ids(source_deal_detail_id, location_id, meter_id, meter_name, term_start, term_end)
			SELECT sdd.source_deal_detail_id, sdd.location_id, sdd.meter_id, mi.recorderid, MIN(sdd.term_start), MAX(sdd.term_end)	
			FROM source_deal_detail sdd
			INNER JOIN meter_id mi ON mi.meter_id = sdd.meter_id
			WHERE 1 = 1
			AND sdd.meter_id IS NOT NULL
			'
				
	IF @source_deal_detail_id IS NOT NULL
		SET @sql += ' AND sdd.source_deal_detail_id = ' + CAST(@source_deal_detail_id AS VARCHAR(20))
	 
	SET @sql += ' GROUP BY sdd.source_deal_detail_id, sdd.location_id, sdd.meter_id, mi.recorderid'
	
	EXEC(@sql)
	
	SET @sql = '
			INSERT INTO #temp_deal_meter_ids(source_deal_detail_id, location_id, meter_id, meter_name, channel, term_start, term_end)
			SELECT sdd.source_deal_detail_id, sdd.location_id, smlm.meter_id, mi.recorderid, rp.channel, MIN(sdd.term_start), MAX(sdd.term_end)
			FROM source_deal_detail sdd
			INNER JOIN source_minor_location_meter smlm ON smlm.source_minor_location_id = sdd.location_id
			INNER JOIN meter_id mi ON mi.meter_id = smlm.meter_id
			INNER JOIN recorder_properties rp ON rp.meter_id = mi.meter_id
			LEFT JOIN #temp_deal_meter_ids t1 ON t1.location_id = sdd.location_id
			WHERE 1 = 1
			AND sdd.meter_id IS NULL
			AND t1.location_id IS NULL
			'
				
	IF @source_deal_detail_id IS NOT NULL
		SET @sql += ' AND sdd.source_deal_detail_id = ' + CAST(@source_deal_detail_id AS VARCHAR(20)) 
 
	SET @sql += ' GROUP BY sdd.source_deal_detail_id, sdd.location_id, smlm.meter_id, mi.recorderid, rp.channel'
		
	EXEC(@sql)

	SELECT @granularity = deal_volume_frequency FROM source_deal_detail WHERE source_deal_detail_id = @source_deal_detail_id 
	SELECT @term_start = MIN(term_start) FROM source_deal_detail WHERE source_deal_detail_id = @source_deal_detail_id
	 
	DECLARE @limit_term_end DATETIME

	--a	Annually, d	Daily, h - Hourly, m - Monthly, q - Quarterly, s - Semi-Annually
	IF @granularity = 'd'
		SET @limit_term_end = DATEADD(MONTH, DATEDIFF(MONTH, -1, DATEADD(month, 1, @term_start))-1, -1)
	IF @granularity = 'm'
		SET @limit_term_end = DATEADD(month, 30, @term_start)
	IF @granularity = 'w'
		SET @limit_term_end = DATEADD(week, 30, @term_start)
	IF @granularity = 'q'
		SET @limit_term_end = DATEADD(quarter, 15, @term_start)
	IF @granularity = 's'
		SET @limit_term_end = DATEADD(year, 15, @term_start)

	IF OBJECT_ID('tempdb..#temp_meter_terms') IS NOT NULL
	DROP TABLE #temp_meter_terms
 
	CREATE TABLE #temp_meter_terms (term_start DATETIME, is_dst INT)
 
	;WITH cte_terms AS (
		SELECT @term_start [term_start]
		UNION ALL
		SELECT dbo.FNAGetTermStartDate(@granularity, cte.[term_start], 1)
		FROM cte_terms cte 
		WHERE dbo.FNAGetTermStartDate(@granularity, cte.[term_start], 1) <= @limit_term_end
	) 
	INSERT INTO #temp_meter_terms(term_start)
	SELECT term_start
	FROM cte_terms cte
	OPTION (maxrecursion 0)


	IF OBJECT_ID('tempdb..#temp_deal_acutal_meter_data') IS NOT NULL 
 		DROP TABLE #temp_deal_acutal_meter_data
 	
	CREATE TABLE #temp_deal_acutal_meter_data(
		id                        INT IDENTITY(1, 1),
		source_deal_detail_id     INT,
		meter_id                  INT,
		meter                     VARCHAR(200) COLLATE DATABASE_DEFAULT ,
		channel                   INT,
		meter_data_id             INT,
		gen_date                  DATETIME,
		from_date                 DATETIME,
		to_date                   DATETIME,
		prod_date                 DATETIME,
		period                    INT,
	)

	IF @granularity = 'h'
	BEGIN
 		ALTER TABLE #temp_deal_acutal_meter_data
 		ADD	
 			Hr1 FLOAT, Hr2 FLOAT, Hr3 FLOAT, Hr4 FLOAT, Hr5 FLOAT, Hr6 FLOAT, Hr7 FLOAT, Hr8 FLOAT, Hr9 FLOAT, Hr10 FLOAT,
 			Hr11 FLOAT, Hr12 FLOAT, Hr13 FLOAT, Hr14 FLOAT, Hr15 FLOAT, Hr16 FLOAT, Hr17 FLOAT, Hr18 FLOAT, Hr19 FLOAT, Hr20 FLOAT,
 			Hr21 FLOAT, Hr22 FLOAT, Hr23 FLOAT, Hr24 FLOAT, Hr25 FLOAT
	END
	ELSE
	BEGIN
 		ALTER TABLE #temp_deal_acutal_meter_data ADD volume FLOAT
	END

	INSERT INTO #temp_deal_acutal_meter_data (
 		source_deal_detail_id, meter_id, meter, channel, gen_date, from_date, to_date, prod_date
	)	
	SELECT t1.source_deal_detail_id,
 			t1.meter_id,
 			mi.recorderid,
 			t1.channel,
 			dbo.FNAGetFirstLastDayOfMonth(t2.term_start, 'f'),
 			dbo.FNAGetFirstLastDayOfMonth(t2.term_start, 'f'),
 			dbo.FNAGetFirstLastDayOfMonth(t2.term_start, 'l'),
 			t2.term_start 
	FROM #temp_deal_meter_ids t1
	INNER JOIN meter_id mi ON t1.meter_id = mi.meter_id
	OUTER APPLY (SELECT * FROM #temp_meter_terms WHERE term_start BETWEEN t1.term_start AND t1.term_end) t2

	IF @granularity IN ('d','m','w','y')
	BEGIN
		UPDATE t1
 		SET meter_data_id = md.meter_data_id,
 			volume = mdh.Hr1
 		FROM #temp_deal_acutal_meter_data t1
 		INNER JOIN mv90_data md 
 			ON md.meter_id = t1.meter_id 
 		INNER JOIN mv90_data_hour mdh 
 			ON mdh.meter_data_id = md.meter_data_id
 			AND mdh.prod_date = t1.prod_date
 			--AND ISNULL(mdh.period, 0) = ISNULL(t1.period, 0)
	END

	IF OBJECT_ID('tempdb..#temp_final') IS NOT NULL 
 		DROP TABLE #temp_final
 	
	CREATE TABLE #temp_final(
			id                      INT IDENTITY(1, 1),
			[Date]					DATETIME,
			[Hour]					INT,
			[Deal_Volume]      FLOAT,
			[Schedule_Volume]       FLOAT,
			[Actual_Volume]         FLOAT 
	)
	 
	IF @granularity = 'd'
	BEGIN
		INSERT INTO #temp_final([Date], [Hour], [Deal_Volume], [Schedule_Volume], [Actual_Volume])
		SELECT	prod_date [Date],
				NULL [Hour], 			
				NULL [Deal_Volume],
				NULL [Schedule_Volume],
				volume [Actual_Volume]	
		FROM #temp_deal_acutal_meter_data
	END
	ELSE IF @granularity = 'm'
	BEGIN
		INSERT INTO #temp_final([Date], [Hour], [Deal_Volume], [Schedule_Volume], [Actual_Volume])
		SELECT	MIN(prod_date) [Date], 	
				NULL [Hour]	,	
				NULL [Deal_Volume],
				NULL [Schedule_Volume],
				SUM(volume) [Actual_Volume]	
		FROM #temp_deal_acutal_meter_data
		GROUP BY MONTH(prod_date)
	END 

	DECLARE @schedule_volume FLOAT
	SELECT @schedule_volume = schedule_volume FROM source_deal_detail WHERE source_deal_detail_id = @source_deal_detail_id

	UPDATE t1
		SET [Schedule_Volume] = @schedule_volume	
	FROM #temp_final t1
	INNER JOIN (
					SELECT MIN([DATE]) [Date1] FROM #temp_final
				) t2
		ON t1.[DATE] = t2.[Date1]

	IF NOT EXISTS (SELECT 1 FROM #temp_final)
	BEGIN
		IF EXISTS (SELECT 1 FROM source_deal_detail_hour WHERE source_deal_detail_id = @source_deal_detail_id)
		BEGIN
			INSERT INTO #temp_final ([Date], [Hour], [Deal_Volume], [Schedule_Volume], [Actual_Volume])
			SELECT term_date, hr, volume, schedule_volume, actual_volume 
			FROM source_deal_detail_hour
			WHERE source_deal_detail_id = @source_deal_detail_id
		END
		ELSE
		BEGIN
			INSERT INTO #temp_final ([Date], [Deal_Volume], [Schedule_Volume], [Actual_Volume])
			SELECT term_start, total_volume, schedule_volume, actual_volume
			FROM source_deal_detail
			WHERE source_deal_detail_id = @source_deal_detail_id
		END
	END
			
	SELECT  dbo.FNADateFormat([Date]),
			[Hour], 			
			[Deal_Volume],
			[Schedule_Volume],
			[Actual_Volume]	 
	FROM #temp_final 
END

ELSE IF @flag = 'amount_report' --Loading date grid in Settlement Amount Report
BEGIN
		SELECT	
				vw.source_deal_header_id,
				sdh.deal_id,
				sco.commodity_id,
				st.trader_id,
				sdt.source_deal_type_name [Deal_Type],
				sdht.template_name [Template],
				sc.counterparty_id [Counterparty],
				cg.contract_name [Contract],
				dbo.FNADateFormat(sdd.term_start) [term_start],
				dbo.FNADateFormat(sdd.term_end) [term_end],
				RIGHT('0'+ CAST(MONTH(sdd.term_start) AS VARCHAR(2)), 2) + '/' +  CAST(YEAR(sdd.term_start) AS VARCHAR(5))  term_start_year_month,
				vw.leg [Leg],
				vw.field_name [charge_type],
				CASE sdd.buy_sell_flag WHEN 'b' THEN  'Buy' WHEN 's' THEN 'Sell' END [buy_sell],
				sml.Location_Name [Location],
				spcd.curve_id [Index],
				sdv_block_def.code [Block Definition],
				CONVERT(NUMERIC(32,2),sdd.deal_volume) [Notional_Volume],
				su.uom_id [Uom],
				CONVERT(NUMERIC(32,2),sdd.total_volume) [Position],  
				puom.uom_id [Position_uom],
				CONVERT(NUMERIC(32,2),vw.price) [price],
				CONVERT(NUMERIC(32,2),vw.value) [value],
				CAST(ISNULL(sdpd.discount_factor,1) AS FLOAT) discount_factor,
				CONVERT(NUMERIC(32,2),CAST(ISNULL(sdpd.dis_pnl,vw.value) AS FLOAT)) dis_pnl,
				scu.currency_name [Currency],
				CASE WHEN sdpd.source_deal_header_id is null THEN 'Actual' ELSE 'Forward' END [actual_forward]
		FROM vwIndexFeesBreakdownStmt vw
		INNER JOIN source_deal_header sdh
			ON sdh.source_deal_header_id = vw.source_deal_header_id
		LEFT JOIN source_deal_detail sdd
			ON sdd.source_deal_detail_id = vw.source_deal_detail_id
		LEFT JOIN source_commodity sco
			ON sco.source_commodity_id = sdh.commodity_id
		LEFT JOIN source_traders st
			on st.source_trader_id = sdh.trader_id
		LEFT JOIN source_deal_type sdt 
			ON sdt.source_deal_type_id = sdh.source_deal_type_id
		LEFT JOIN source_deal_header_template sdht
			ON	sdht.template_id = sdh.template_id 
		LEFT JOIN source_counterparty sc
			ON sc.source_counterparty_id = sdh.counterparty_id
		LEFT JOIN contract_group cg
			ON cg.contract_id = sdh.contract_id
		LEFT JOIN source_minor_location sml
			ON sml.source_minor_location_id = sdd.location_id
		LEFT JOIN source_price_curve_def spcd 
			ON spcd.source_curve_def_id = sdd.curve_id 
		LEFT JOIN static_data_value sdv_block_def 
			ON sdv_block_def.value_id = sdh.block_define_id
		LEFT JOIN source_uom su 
			ON su.source_uom_id = sdd.deal_volume_uom_id
		LEFT JOIN source_uom puom 
			ON  puom.source_uom_id = ISNULL(spcd.display_uom_id, spcd.uom_id)
		LEFT JOIN source_currency scu 
			ON scu.source_currency_id  =vw.currency_id
		OUTER APPLY(
						SELECT TOP 1 spd.*
						FROM source_deal_pnl_detail spd
						WHERE spd.source_deal_header_id = vw.source_deal_header_id
								AND spd.term_start = sdd.term_start 
								AND spd.leg = sdd.leg 
						ORDER BY spd.pnl_as_of_date DESC
					) sdpd 
		WHERE vw.source_deal_detail_id = @source_deal_detail_id AND vw.source_deal_settlement_id = -1
END

ELSE IF @flag = 'y'
BEGIN
	IF EXISTS (
		SELECT 1 FROM close_measurement_books cmb
			INNER JOIN dbo.SplitCommaSeperatedValues(@term_date) a ON MONTH(cmb.as_of_date) = MONTH(a.item)
		AND YEAR(cmb.as_of_date) = YEAR(a.item)
	)
	BEGIN
		SELECT 'false', @term_date, 'Accounting Period has already been closed.'
		RETURN
	END
	SELECT 'true', @term_date
END

ELSE IF @flag = 'z'
BEGIN
	IF EXISTS(SELECT 1 FROM vwUdfTemplate WHERE udf_template_id = abs(@udf_template_id) AND internal_field_type IS NOT NULL)
	BEGIN
		SELECT 'true', @row_id
	END
	ELSE
		SELECT 'false', @row_id
END

ELSE IF @flag = 'delete_adjustment'
BEGIN
	BEGIN TRY
	BEGIN TRAN		
		SET @sql = 'DELETE FROM stmt_adjustments 
			WHERE stmt_adjustments_id IN (' + @index_fees_id + ')'
		EXEC(@sql);
		
		COMMIT
		EXEC spa_ErrorHandler 0
				, 'spa_transfer_mapping'
				, 'spa_transfer_mapping'
				, 'Success' 
				, 'Changes have been saved successfully'
				, ''
			
	END TRY
	BEGIN CATCH 
		IF @@TRANCOUNT > 0
		   ROLLBACK
		DECLARE @desc VARCHAR(200)
		DECLARE @err_no VARCHAR(200)
		SET @desc = 'Failed to delete adjustment invoice:' + ERROR_MESSAGE() + '.'
 
		SELECT @err_no = ERROR_NUMBER()
 
		EXEC spa_ErrorHandler @err_no
		   , 'spa_stmt_checkout'
		   , 'spa_stmt_checkout'
		   , 'Error'
		   , @desc
		   , ''
	END CATCH
END

ELSE IF @flag = 'd'
BEGIN
BEGIN TRY
EXEC sp_xml_preparedocument @idoc OUTPUT,@xml

IF OBJECT_ID('tempdb..#temp_settlement_checkout_delete') IS NOT NULL
			DROP TABLE #temp_settlement_checkout_delete

	SELECT
		  settlement_invoice_id
		INTO #temp_settlement_checkout_delete
		FROM OPENXML(@idoc, '/Root/GridDelete', 1)
		WITH (
			settlement_invoice_id INT
		)

		DELETE si_b
		FROM stmt_invoice si
		INNER JOIN #temp_settlement_checkout_delete tid ON tid.settlement_invoice_id = si.stmt_invoice_id
		INNER JOIN stmt_invoice_detail stid ON si.stmt_invoice_id = stid.stmt_invoice_id
		OUTER APPLY( SELECT itm.item [stmt_checkout_id] FROM dbo.SplitCommaSeperatedValues(stid.description1) itm) a 
		OUTER APPLY (
			SELECT DISTINCT stid_b.stmt_invoice_id
			FROM stmt_invoice_detail stid_b
			CROSS APPLY dbo.SplitCommaSeperatedValues(stid_b.description1) de
			WHERE de.item = a.stmt_checkout_id AND stid_b.stmt_invoice_id <> tid.settlement_invoice_id
		) inv
		INNER JOIN stmt_invoice si_b ON si_b.stmt_invoice_id = inv.stmt_invoice_id  AND ISNULL(si_b.is_voided,'n') = ISNULL(si.is_voided,'n')
		WHERE ISNULL(si_b.is_backing_sheet,'n') = 'y'

		DELETE si
		 FROM stmt_invoice si
		INNER JOIN #temp_settlement_checkout_delete tscd ON si.stmt_invoice_id = tscd.settlement_invoice_id


EXEC spa_ErrorHandler 0,
             'Settlement Checkout',
             'spa_settlement_checkout',
             'Success',
             'Successfully deleted',
             ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		EXEC spa_ErrorHandler -1,
             'Settlement Checkout',
             'spa_settlement_checkout',
             'Error',
             'Failed to delete',
             ''
	END CATCH
END

ELSE IF @flag = 'post_final_gl'
BEGIN
	BEGIN TRY
		BEGIN TRAN	

		EXEC sp_xml_preparedocument @idoc OUTPUT,@xml

		IF OBJECT_ID('tempdb..#temp_post_gl_final') IS NOT NULL
			DROP TABLE #temp_post_gl_final

		-- Execute a SELECT statement that uses the OPENXML rowset provider.
		SELECT	stmt_checkout_id
		INTO #temp_post_gl_final
		FROM OPENXML(@idoc, '/Root/PSRecordSet', 1)
		WITH (
			stmt_checkout_id INT
		)
		
		SET @sql = 'UPDATE sc 
			SET sc.status = 112900
		FROM #temp_post_gl_final tmp
			INNER JOIN stmt_checkout sc ON tmp.stmt_checkout_id = sc.stmt_checkout_id'

		EXEC(@sql);
		
		DECLARE @post_gl_process_id VARCHAR(100) = dbo.FNAGetNewID()
		DECLARE @post_gl_alert_process_table VARCHAR(200) = dbo.FNAProcessTableName('alert_stmt_checkout', @post_gl_process_id, 'ai')    
		--DECLARE @post_gl_alert_process_table VARCHAR(200) = 'adiha_process.dbo.alert_stmt_checkout_' + @post_gl_process_id + '_ai'

		EXEC('CREATE TABLE ' + @post_gl_alert_process_table + ' (stmt_checkout_id INT)')
				
		SET @sql = 'INSERT INTO ' + @post_gl_alert_process_table + '(stmt_checkout_id) 
					SELECT stmt_checkout_id FROM #temp_post_gl_final'

		EXEC(@sql)		

		EXEC spa_register_event 20627, 10000323, @post_gl_alert_process_table, 1, @post_gl_process_id

		COMMIT
		EXEC spa_ErrorHandler 0
				, 'spa_stmt_checkout'
				, 'spa_stmt_checkout'
				, 'Success' 
				, 'Post GL run successfully'
				, ''
			
	END TRY
	BEGIN CATCH 
		IF @@TRANCOUNT > 0
		   ROLLBACK
		DECLARE @post_gl_desc VARCHAR(200)
		DECLARE @post_gl_err_no VARCHAR(200)
		SET @post_gl_desc = 'Failed to run POST GL:' + ERROR_MESSAGE() + '.'
 
		SELECT @post_gl_err_no = ERROR_NUMBER()
 
		EXEC spa_ErrorHandler @post_gl_err_no
		   , 'spa_stmt_checkout'
		   , 'spa_stmt_checkout'
		   , 'Error'
		   , @post_gl_desc
		   , ''
	END CATCH
END