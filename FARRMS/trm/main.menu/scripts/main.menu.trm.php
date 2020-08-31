<!DOCTYPE html>
<html>
<head>
    <!-- The variable app_php script loc vaiable is being used in css also so the php tag is move to in here -->
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php
    require('../../adiha.php.scripts/components/include.file.v3.php');
    include('./load_menu_data.php');

    if (isset($_SESSION['otp_verified']) && $_SESSION['otp_verified'] == "false") {
        session_destroy();
        if ($CLOUD_MODE == 1) {
            echo "<script>top.location.href='" . $webserver . "?action=otp_verification_failed'</script>";
        } else {
            unset($_SESSION['otp_verified']);
            echo "<script>window.top.location.href='" . $app_adiha_loc ."index_login_farrms.php?loaded_from=" . $farrms_client_dir . "&flag=login&message=OTP verification failed.'</script>";
        } 
        die();
    }

    ## User Informations
    $recordsets = get_user_info();
    $user_name = $recordsets[0][0];
    $member_since = $recordsets[0][1];
    $full_name = $recordsets[0][2];
    $menu_role = $recordsets[0][3];

    // application version info
    $image_name = 'farrms_admin.png';
	$app_version_label = $recordsets[0][4];
    $app_version_color = $recordsets[0][5];
    $app_version_is_admin = $recordsets[0][6];
    $app_version_label_size = trim($recordsets[0][7]);
    
    ## Left Side Menu HTML
    $menu_list = load_all_menu_data($menu_role, $user_name);

    if (!$app_version_color || trim($app_version_color) == NULL) {
        $app_version_color = '#858585';
    }
    if ($app_version_label == 'Demo Version') {
        $visibility = 'visibility:visible;';
    } else {
        $visibility = 'visibility:hidden;';
    }

    ## This is used to Highlight the font size box
    $small_bordered = (($app_version_label_size == "10px") ? 'bordered' : '');
    $medium_bordered = (($app_version_label_size == '12px') ? 'bordered' : '');
    $large_bordered = (($app_version_label_size == '14px') ? 'bordered' : '');

    $rights_setup_version = 20006600;
    $rights_setup_theme = 20006301;

    list (
        $has_rights_setup_version,
        $has_rights_setup_theme
    ) = build_security_rights(
        $rights_setup_version,
        $rights_setup_theme
    );
    ?>
    <!-- !!! important for search menu highlight !!! -->
    <style id='custom' type="text/css">
    </style>
    <!-- !!! important for search menu highlight !!! -->

    <title><?php echo $product_name; ?></title>
    <!-- css for menu-search -->
    <link rel="stylesheet" type="text/css" href="../css/main.menu.additional.css">
    <!-- bootstrap -->
    <link href="../bootstrap-3.3.1/dist/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <!-- FONT AWESOME -->
    <link href="../font-awesome-4.2.0/css/font-awesome.min.css" rel="stylesheet" type="text/css" />
	<link rel="stylesheet" type="text/css" href="../css/libs/nanoscroller.css" />

    <!-- global styles -->
    <link rel="stylesheet" type="text/css" href="../css/compiled/theme_styles.css" />
    <!-- Favicon -->
    <link type="image/x-icon" href="../favicon.ico" rel="shortcut icon" />
    <link rel="stylesheet" type="text/css" href="../css/compiled/message_box.css" />
</head>
<body class="theme-blue-gradient fixed-header fixed-footer fixed-leftmenu jomsomGreen">
<div class="menu_overlay" id="menu_overlay"></div>
<div id="theme-wrapper">
    <header class="navbar" id="header-navbar">
        <div class="container">
            <a href="#" id="logo" class="navbar-brand">
                <?php echo $farrms_product_name; ?>
                <span class="app_version_label_size" style=" font-size:<?php echo $app_version_label_size; ?>;padding-left:5px; float:right;">
                    <span class="app_version_label label_span" style="color:<?php echo $app_version_color; ?>" onclick="show_version_modal();"><?php echo $app_version_label; ?></span>
                    <!--  <i onclick="show_menu_searchbar();" class="menu_search" title="Menu Search"></i> -->
                    </span>
            </a>

            <div class="clearfix">
                <button class="navbar-toggle" data-target=".navbar-ex1-collapse" data-toggle="collapse" type="button">
                    <span class="sr-only"><?php echo get_locale_value('Toggle navigation'); ?></span>
                    <span class="fa fa-bars"></span>
                </button>

                <div class="nav-no-collapse navbar-left pull-left hidden-sm hidden-xs">
                    <ul class="nav navbar-nav pull-left">
                        <li>
                            <a class="btn" id="make-small-nav" title="<?php echo get_locale_value('Expand/Collapse Menu'); ?>">
                                <i class="fa fa-bars"></i>
                            </a>
                        </li>
                        <li>
                            <a onclick="show_menu_searchbar();" class="btn" title="<?php echo get_locale_value('Menu Search'); ?>">
                                <i class="fa fa-search-minus" title="Menu Search"></i>
                            </a>
                        </li>
                        <li>
                            <a href="#" class="dropdown-toggle" data-toggle="dropdown" title="<?php echo get_locale_value('Recent Menus'); ?>">
                                <i class="fa fa-history"></i>
                            </a>
                            <ul class="dropdown-menu recent-menu" id="recent_menu">

                            </ul>
                        </li>
                        <li>
                            <a href="#" class="dropdown-toggle"  data-toggle="dropdown" title="<?php echo get_locale_value('Favorites'); ?>">
                                <i class="fa fa-2x fa-star" style="color:#FCD927"></i>
                            </a>
                            <ul class="dropdown-menu favourite-menu" id="favourite_menu">

                            </ul>
                        </li>
                        <li>
                            <a href="#" class="dropdown-toggle"  data-toggle="dropdown" title="<?php echo get_locale_value('Pinned Reports'); ?>">
                                <i class="fa fa-2x fa-pie-chart"></i>
                            </a>
                            <ul class="dropdown-menu report-menu" id="pinned_reports">

                            </ul>
                        </li>
                        <li>
                            <a href="#" onclick="window.location.reload(true);" title="<?php echo get_locale_value('Refresh'); ?>">
                                <i class="fa fa-refresh"></i>
                            </a>
                        </li>
                        <li>
                            <a href="#" onclick="tile_windows();" title="<?php echo get_locale_value('Tile Windows'); ?>">
                                <i class="fa fa-th-large"></i>
                            </a>
                        </li>
                        <?php if ($CLOUD_MODE == 1) { ?>
                        <li>
                            <a target="_blank" href="<?php echo $webserver; ?>/" title="<?php echo get_locale_value('Website'); ?>" rel="noopener noreferrer">
                                <i class="fa fa-2x fa-globe"></i>
                            </a>
                        </li>
                        <?php } ?>
                    </ul>
                </div>
                <input id="txt_src" type="text" style="display: none;"/>
                <div class="nav-no-collapse pull-right" id="header-nav">
                    <ul class="nav navbar-nav pull-right">

                        <li class="mobile-search">
                            <a class="btn"> <i class="fa fa-search" title="<?php echo get_locale_value('Search'); ?>"></i> </a>
                            <div class="drowdown-search">
                                <form role="search">
                                    <div class="form-group">
                                        <input type="text" id="txt_search" name="txt_search" class="form-control" placeholder="Search..." autocomplete="on" onkeypress="if (event.keyCode==13) {open_search_window();}"/>
                                        <a class="btn dropdown-toggle nav-clear-icon" data-toggle="dropdown" aria-expanded="false">
                                            <i class="fa fa-caret-down"></i>
                                        </a>
                                        <div class="dropdown-menu dropdown-menu-far-left" role="menu">
                                            <div class="form-group" style="color:black;padding:10px">
                                                <label><?php echo get_locale_value('Search objects'); ?></label>
                                                <br/>
                                                <div class="checkbox-nice checkbox-inline">
                                                    <input type="checkbox" id="contract" name="search_objects" value="contract" />
                                                    <label for="contract"> <?php echo get_locale_value('Contract'); ?> </label>
                                                </div>  
                                                <div class="checkbox-nice checkbox-inline" style="margin-left: 56px;">
                                                    <input type="checkbox" id="counterparty" name="search_objects" value="counterparty" />
                                                    <label for="counterparty"> <?php echo get_locale_value('Counterparty'); ?> </label>
                                                </div>
                                                <br>    
                                                <div class="checkbox-nice checkbox-inline">
                                                    <input type="checkbox" id="creditinfo" name="search_objects" value="creditinfo" />
                                                    <label for="creditinfo"> <?php echo get_locale_value('Credit Info'); ?> </label>
                                                </div>                                                  
                                                <div class="checkbox-nice checkbox-inline" style="margin-left: 45px;">
                                                    <input type="checkbox" id="deal" name="search_objects" value="deal" />
                                                    <label for="deal"> <?php echo get_locale_value('Deal'); ?> </label>
                                                </div>                                          
                                                <br>
                                                <div class="checkbox-nice checkbox-inline">
                                                    <input type="checkbox" id="document" name="search_objects" value="document" />
                                                    <label for="document"> <?php echo get_locale_value('Document'); ?> </label>
                                                </div>
                                                <div class="checkbox-nice checkbox-inline" style="margin-left: 45px;">
                                                    <input type="checkbox" id="email" name="search_objects" value="email" />
                                                    <label for="email"> <?php echo get_locale_value('Email'); ?> </label>
                                                </div>
                                                <br>
                                                <div class="checkbox-nice checkbox-inline">
                                                    <input type="checkbox" id="incident_log" name="search_objects" value="incident log" />
                                                    <label for="incident_log"> <?php echo get_locale_value('Incident Log'); ?> </label>
                                                </div>  
                                            </div>
                                        </div>
                                        <a class="btn nav-search-icon" onclick="open_search_window();">
                                            <i class="fa fa-search "></i>
                                        </a>
                                    </div>
                                </form>
                            </div>
                        </li>
                        <li>
                            <a href="#" onclick="return open_menu_window('_setup/setup_calendar/calendar.php', 'win_10106800', 'Calendar', '10106800');" title="<?php echo get_locale_value('Calendar'); ?>">
                                <i class="fa fa-calendar"></i>
                            </a>
                        </li>

                        <li class="msg-blk">
                            <a class="btn dropdown-toggle" data-toggle="dropdown" title="<?php echo get_locale_value('Notifications'); ?>" onclick="counter_click('alert');">
                                <i class="fa fa-warning"></i>
                                <span id="alert-count" class="count"></span>
                            </a>
                            <div id="alerts" class="message-board-wrapper dropdown-menu notifications-list"></div>
                        </li>
                        <li class="msg-blk">
                            <a class="btn dropdown-toggle" data-toggle="dropdown" title="<?php echo get_locale_value('Messages'); ?>" onclick="counter_click('message');">
                                <i class="fa fa-envelope-o"></i>
                                <span id="message-count" class="count"></span>
                            </a>
                            <div id="messages" class="message-board-wrapper dropdown-menu notifications-list"> </div>
                        </li>
                        <li>
                            <a href="#" onclick="return open_menu_window('../adiha.php.scripts/help_module.php', 'win_10106800', 'Help', '10106800');" title="Help">
                                <i class="fa fa-question-circle"></i>
                            </a>
                        </li>
                        <li class="profile-dropdown"> <a href="#" class="dropdown-toggle" data-toggle="dropdown">
                                <img alt="" src="../img/user-image/<?php echo $image_name;?>" />
                                <span class="name"><?php echo $full_name; ?></span>
                                <b class="caret"></b> </a>
                            <ul class="dropdown-menu">
                                <li><a href="#" onclick="open_menu_window('_users_roles/maintain_users/maintain.users.php?view_profile=1', 'maintain User', 'Profile');"><i class="fa fa-user"></i><?php echo get_locale_value('Profile'); ?></a></li>
                                <li><a data-toggle="modal" href="#" data-target="#myModalAbout"><i class="fa fa-info-circle"></i><?php echo get_locale_value('About'); ?></a></li>
                            </ul>
                        </li>
                        <li id="log-out" class="hidden-xxs">
                            <a class="btn" title="<?php echo get_locale_value('Log out'); ?>">
                                <i class="fa fa-power-off"></i>
                            </a>
                        </li>
                    </ul>
                </div>
            </div>
        </div>
        <div id="window_label" style="display: none;"></div>
        <div id="window_name" style="display: none;"></div>
        <div id="file_path" style="display: none;"></div>
    </header>
    <div id="page-wrapper" class="container nav-none">
        <div class="row">
            <div id="nav-col">
                <section id="col-left" class="col-left-nano">
                    <div id='menu-searchbar' style="display:none; position: relative">
                        <!--
                            The Placeholder text requires to be hidden as the search text is typed in the field.
                            The function for keyup event handles this only when key is released.
                            This creates the delay while hiding placeholder.
                            So the key down event is also added to handle this.
                        -->
                        <input type="text" style="width: calc(100%);padding: 5px 85px 5px 15px;" onkeyup="search_menu_item(this.value)" onkeydown="toggle_placeholder();">
                        <span class="placeholder">Search for Menu</span>
                        <i onclick="clear_menu_search();" class="fa fa-close" style="position:absolute; right: 5px; top:11px; display: inline-block; width: 36px; text-align: center; z-index: 1000001; cursor: pointer" title="Clear"></i>
                        <i onclick="highlight_previous();" class="fa fa-angle-double-left previous" style="position:absolute; right: 60px; top:10px; display: inline-block; width: 36px; text-align: center; z-index: 1000001; cursor: pointer" title="Previous"></i>
                        <i onclick="highlight_next();" class="fa fa-angle-double-right next" style="position:absolute; right: 40px; top:10px; display: inline-block; width: 36px; text-align: center; z-index: 1000001; cursor: pointer" title="Next"></i>
                    </div>
                    <div id="col-left-inner" class="col-left-nano-content">
                        <div class="collapse navbar-collapse navbar-ex1-collapse nano" id="sidebar-nav">    <!-- Menu search field -->
                            <ul id="menu-lists" class="nav nav-pills nav-stacked content">
                                <?php echo $menu_list; ?>
                            </ul>
                        </div>
                    </div>
                </section>
            </div>
            <div id="content-wrapper">
                <div class="container-fluid">
                    <div class="row">
                        <div class="col-md-12 col-xs-12 col-sm-12 col-lg-12" id="workspace" style="height:calc(100vh - 45px)">

                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="alertModal" tabindex="-1" role="dialog" aria-labelledby="alertModal" aria-hidden="true"></div>
<div class="modal fade" id="forwardMessageModal" tabindex="-1" role="dialog" aria-labelledby="forwardMessageModal" aria-hidden="true"></div>
<div class="modal fade" id="messageModal" tabindex="-1" role="dialog" aria-labelledby="messageModal" aria-hidden="true"></div>
<div class="modal fade" id="messageDrill" tabindex="-1" role="dialog" aria-labelledby="messageDrill" aria-hidden="true"></div>
<div class="modal fade" id="mdds" tabindex="-1" role="dialog" aria-labelledby="mdds" aria-hidden="true"></div>
<div class="modal fade" id="myModalAbout" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
    <div id="setting-modal" class="modal-dialog">
        <div id="settings-modal-content" class="modal-content">
            <div class="wrapper">
                <div class="right_col">
                    <button type="button" class="close about_close" data-dismiss="modal" aria-hidden="true">&times;</button>
                    <img src="../img/user-image/logo.jpg" width="168" height="33" alt="" class="link_img"/>
                    <a target='_blank' href='https://www.pioneersolutionsglobal.com/' class="link_site" rel="noopener noreferrer">www.pioneersolutionsglobal.com</a>
                </div>
                <div class="left_col">
                    <p class="product_name"><?php echo $farrms_product_name." "; ?><span class="product_name_version" id="version"></span></p>
                    <p><strong><i>Powered by FARRMS</i></strong></p>
                </div>
                <div style="clear:both"></div>
                <p class="version app_version_label_about" id="platform"><?php echo $app_version_label; ?></p>
                <p class="version">Database: <span id="database"><?php echo $database_name; ?></span></p>
                <p class="copyright" >&copy; <span id="current_year"></span> Pioneer Solutions LLC <br/>All Right Reserved.</p>
            </div>

        </div>
    </div>
</div>

<div class="modal fade" id="myModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">


    <div id="setting-modal" class="modal-dialog">
        <div id="settings-modal-content" class="modal-content">
            <div id="disabled-div"></div>
            <div id="loader"></div>
            <div class="modal-header">
                <button type="button" style="font-size: 28px;" class="close" data-dismiss="modal" aria-hidden="true" onclick="close_default_modal()">&times;</button>
                <h4 class="modal-title">Version</h4>
            </div>
            <div id="config-tool" class="modal-body clearfix">
				<div class="dhxform_base_nested in_block" style="margin-top:-10px;">
                    <div class="dhxform_base" style="float: left;padding-right: 20px;">
                        <div class="dhxform_item_label_top div_version_label" style="padding-left: 15px !important;">
                            <div class="dhxform_label dhxform_label_align_left" title="Version Label">
                                <label>Label</label><span class="dhxform_item_required" style="color: #F00">&nbsp;*</span>

                            </div>
                            <div class="dhxform_control">
                                <input class="dhxform_textarea" maxlength = "14" name="txt_version_label" id="txt_version_label" type="TEXT" style="width: 160px;" value="<?php echo $app_version_label;?>">
                                <div class="dhxform_note" style="width: 160px;font-size: .8em;color: red;padding-bottom: 3px;white-space: normal;display: none;">Required Field </div>
                                <div class="dhxform_note_msg" style="width: 160px;font-size: .8em;color: red;padding-bottom: 3px;white-space: normal;display: none;">Only 14 Character Allowed</div>
                            </div>
                        </div>
                    </div>
                    <div class="dhxform_base" style="float: left;padding-right: 20px;">
                        <div class="dhxform_item_label_top">
                            <div class="dhxform_label dhxform_label_align_left" title="Version Font Size">
                                <label>Font Size</label>

                            </div>
                            <div style='display:inline-block;'>
                                <span title="10px" font_value="10px" class="selected-font version_label_size10px font-small <?php echo $small_bordered; ?>">A</span>
                                <span title="12px" font_value="12px" class="selected-font version_label_size12px font-medium <?php echo $medium_bordered; ?>">A</span>
                                <span title="14px" font_value="14px" class="selected-font version_label_size14px font-large <?php echo $large_bordered; ?>">A</span>
                            </div>
                        </div>
                    </div>
                    <div class="dhxform_base">
                        <div class="dhxform_item_label_top" style="padding-left: 15px !important;">
                            <div class="dhxform_label dhxform_label_align_left" title="Version Color">
                                <label>Color
                                </label>
                            </div>
                            <div class="dhxform_control div_color_picker">
                                <input class="dhxform_textarea"  type="text" id="txt_version_color" style="width: 80px;height:26px;border:1px solid #aaa" selectedcolor="<?php echo $app_version_color;?>" value="<?php echo $app_version_color;?>">
                            </div>

                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <div class="dhx_toolbar_btn" onclick="btn_version_save_click()">
                <img src="../img/save.gif" width="18" height="18" alt=""/> Save </div>
            </div>
        </div>
    </div>
</div>
<div class="modal fade" id="myModalTheme" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
    <div id="setting-modal" class="modal-dialog">
        <div id="settings-modal-content" class="modal-content">
            <div class="modal-header">
                <button type="button" style="font-size: 28px;" class="close" data-dismiss="modal" aria-hidden="true" onclick="close_default_modal()">&times;</button>
                <h4 class="modal-title">Default Theme</h4>
            </div>
            <div id="config-tool" class="modal-body">
                <div id="config-tool-options" >
                    <div class="theme-config color-settings col-xs-12">
                        <ul id="skin-colors" class="clearfix" style="border-bottom: 0px;">
                            <!--  Same theme must be added in set user UI -->
                            <li>
                                <a class='skin-changer skin-changer-admin' data-skin="theme-jomsomGreen" data-toggle="tooltip" title="Jomsom Green" alt='Jomsom Green' onclick="$('#txt_version_theme_name').val('jomsomGreen')">
                                    <div class='color-box' style = 'background-color: #00944A;'></div>
                                </a>
                            </li>
                            <!--disable theme color start-->
                            <li>
                                <a class='skin-changer skin-changer-admin' data-skin="theme-jomsomBlue" data-toggle="tooltip" title="Jomsom Blue" onclick="$('#txt_version_theme_name').val('jomsomBlue')">
                                    <div class='color-box' style = 'background-color: #9fc6fd;'></div>
                                </a>
                            </li>

                            <li>
                                <a class='skin-changer skin-changer-admin' data-skin="theme-jomsomBrown"  data-placement="bottom" data-toggle="tooltip" title="Jomsom Brown" onclick="$('#txt_version_theme_name').val('jomsomBrown')">
                                    <div class='color-box' style = 'background-color: #c5a490;'></div>
                                </a>
                            </li>
                            <li>
                                <a class='skin-changer skin-changer-admin' data-skin="theme-jomsomPurple"  data-placement="bottom" data-toggle="tooltip" title="Jomsom Purple" onclick="$('#txt_version_theme_name').val('jomsomPurple')">
                                    <div class='color-box' style = 'background-color: #c3d0ff;'></div>
                                </a>
                            </li>

                        </ul>
                        <!--<ul id="skin-colors" class="clearfix">
                          <h2> Mugu <span>v1.3</span></h2>
                            <li>
                            <a class='skin-changer' data-skin="theme-muguGreen" data-toggle="tooltip" title="Mugu Green" alt='MuguGreen'>
                              <div class='color-box' style='background-color: #00944A;'></div>
                            </a>
                          </li>
                        </ul> -->
                        <input class="dhxform_textarea" maxlength = "14" name="txt_version_label" id="txt_version_theme_name" type="TEXT" style="width: 160px;display: none;" value="<?php echo isset($version_theme_name) ? $version_theme_name : 'jomsomGreen'; ?>">
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <div  class="dhx_toolbar_btn" onclick="save_default_theme()" <?php echo ($has_rights_setup_theme || $app_version_is_admin == '1') ? '' : 'disabled';?>>
                <img src="../img/save.gif" width="18" height="18" alt=""/> Save </div>
            </div>
        </div>
    </div>
</div>
<div id="___fav_group___" style="display:none;"></div>

<!-- global scripts -->

<script src="../js/farrms_scripts/jquery-1.11.1.js"></script>
<script src="../bootstrap-3.3.1/dist/js/bootstrap.js" type="text/javascript"></script>
<script src="../js/jquery.nanoscroller.min.js"></script>
<script src="../js/farrms_scripts/jquery-ui.min.js"></script>
<script src="../js/farrms_scripts/main.menu.js"></script>
<script src="../js/farrms_scripts/main.menu.search.js"></script>
<script src="../js/pace.min.js"></script>

<script type="text/javascript">
    var database_font_size = '<?php echo $app_version_label_size;?>';
    var txt_version_font_size1 = '<?php echo $app_version_label_size;?>';
    var app_version_is_admin = <?php echo $app_version_is_admin; ?>;
    var default_theme_name = '<?php echo $default_theme;?>';
    default_theme_name = (default_theme_name == '') ? 'theme-jomsomGreen' : default_theme_name;
    var has_rights_setup_version = '<?php echo $has_rights_setup_version;?>';
    var azure_ad = '<?php echo isset($_SESSION['uti']) ? 1 : 0; ?>';
    // for font font-size
    $('.selected-font').on('click', function() {
        txt_version_font_size1 = $(this).attr('font_value');
        $('.selected-font').removeClass('bordered');
        $(this).addClass('bordered');
    })
    
    $(function() {
        // Use Application Theme in Menu Search
        var usedSkin = default_theme;
        $('.menu_search').className = 'menu_search';
        $('.menu_search').addClass(usedSkin);
        $('#disabled-div').hide();
        /*** application version info ***/
        txt_version_label = '<?php echo $app_version_label; ?>';
        txt_version_color = '<?php echo $app_version_color; ?>';

        // Add ColorPicker in Color Input
        mcp = dhtmlXColorPicker(["txt_version_color"]);
        $('.div_color_picker div').css({"width":120, "height":25});
        $('#txt_version_color').css({"background-color":txt_version_color});

        //$('.version_label_size' + txt_version_size).addClass('bordered');
        $('.version_label_size' + txt_version_font_size1).addClass('bordered');

        $('#txt_version_label').keypress(function() {
            $(this).removeClass("app_version_label_red");
        });

        $('#txt_version_label').on('change',function() {
            if ($(this).val() != '')
                $(this).removeClass("app_version_label_red");
            $('.div_version_label .dhxform_note').css({"display":"none"});
            $('.div_version_label .dhxform_note_msg').css({"display":"none"});
        });

        $('#myModal').on('hidden.bs.modal', function () {
            $('#txt_version_label').val(txt_version_label);
            $('#txt_version_color').val(txt_version_color);
            $('#txt_version_color').css({"background-color":txt_version_color});
            $('#txt_version_label').removeClass("app_version_label_red");
            $('.selected-font').removeClass('bordered');
            var a = (database_font_size != txt_version_font_size1) ? database_font_size : txt_version_font_size1;
            $('.version_label_size' + a).addClass('bordered');
            $('.div_version_label .dhxform_note').css({"display":"none"});
            $('.div_version_label .dhxform_note_msg').css({"display":"none"});
        })

        $("#myModalTheme a[data-skin='theme-" + version_theme_name +"']").addClass("active");
    })

    $(window).on('blur',function() {
        $('header.navbar .dropdown-toggle').parent().removeClass('open');
    });
    
    //## Used in main.menu.js & main.menu.additional.js to show the reminder window
    var count_reminder = 0;
    var farrms_product_id = '<?php echo $farrms_product_id; ?>';

    var date = new Date();
    var current_year = document.getElementById('current_year') ;
    current_year.innerHTML = date.getFullYear();

    //## Gets the Version Number Information
    var version_data = {
        "action": "spa_application_version",
        "flag": "s"
    };

    adiha_post_data("return_array", version_data, '', '', "set_version");

    /**
     * Sets the Application Version Number
     * @param {Array} result Application Version Information
     */
    function set_version(result) {
        var version = document.getElementById("version");
        version.innerHTML = result[0][3];
    }

    /*
     * version label and color
     */
    function btn_version_save_click() {
        var txt_version_label1 =  $('#txt_version_label').val().replace(/<[^>]+>/g, '');
        txt_version_color1 = $('#txt_version_color').val();
        //var txt_version_font_size1 = $('.bordered').css('fontSize');
        if (trim(txt_version_label1) == '') {
            $('#txt_version_label').addClass("app_version_label_red");
            $('.div_version_label .dhxform_note').css({"display":"block"});
            return false;
        } else if (trim(txt_version_label1).length > 14) {
            $('#txt_version_label').addClass("app_version_label_red");
            $('.div_version_label .dhxform_note_msg').css({"display":"block"});
            return false;
        }
        $('#loader').addClass('loader');
        $('#disabled-div').show();
        database_font_size = txt_version_font_size1;

        var version_data = {
            "action": "spa_application_version",
            "flag": "i",
            "version_label":txt_version_label1,
            "version_color":txt_version_color1,
            "txt_version_label_font_size":txt_version_font_size1
        };

        adiha_post_data("return_array", version_data, '', '', "btn_version_save_click_post");

    }

    function btn_version_save_click_post(result) {
        txt_version_label =  $('#txt_version_label').val().replace(/<[^>]+>/g, '');
        txt_version_color = $('#txt_version_color').val();
        var txt_version_font_size = txt_version_size =txt_version_font_size1 ;
        //$('.bordered').css('fontSize');
        if (result[0][0] == 'Success') {
            $('.app_version_label').text(txt_version_label);
            $('.app_version_label_about').html(txt_version_label);
            $('.app_version_label').css({"color":txt_version_color});
            $('.app_version_label_size').css({"font-size":txt_version_font_size});
            success_call(result[0][4]);
        }
        $('#loader').removeClass('loader');
        $('#disabled-div').hide();
        $('#myModal').modal('hide');
    }

    //## DHTMLX Windows Configuration
    var dhxWins;
    dhx_wins = new dhtmlXWindows();
    dhx_wins.attachViewportTo("workspace");

    var win_x_position = 1;
    /**
     * Unload help window.
     */
    function unload_window() {
        if (helpfile_window != null && helpfile_window.unload != null) {
            helpfile_window.unload();
            helpfile_window = w1 = null;
        }
    }

    function arrange_windows() {
        var win_y_position = $("#workspace").height() - 25;
        win_x_position = 1;
        dhx_wins.forEachWindow(function(win) {
            if (win.isParked()) {
                win.setPosition(win_x_position, win_y_position);
                win_x_position = win_x_position + 252;
            }
        });
    }

    /**
     * Tiles all opened windows
     */
    function tile_windows() {
        var win_y_position = 0;
        var win_x_position = 0;

        var win_height = $("#workspace").height();
        var win_width = $("#workspace").width();

        var temp_width = win_width/5;
        var i = 1;
        var break_point = 6;
        dhx_wins.forEachWindow(function(win) {
            if (i % 5 == 0) {
                break_point = i + 1;
            } else if (i == break_point) {
                if (i == 11) {
                    document.getElementById('workspace').style.overflowY = 'scroll';
                }
                win_x_position = 0;
                win_y_position = win_y_position + (win_height-25)/2;
            }

            win.setDimension(temp_width, (win_height-35)/2);
            win.setPosition(win_x_position, win_y_position);
            win_x_position = win_x_position + temp_width;
            i++;
        });
    }

    /**
     * Deletes the message from message board
     * @param  {integer}  msg_ids  Message Board Id
     * @param  {integer} is_alert  Alert (1) or Message (0)
     */
    function delete_message(msg_ids, is_alert) {
        if (msg_ids == '' || msg_ids == 'NULL') {
            dhtmlx.alert({
                title: 'Warning',
                type: "alert-warning",
                text: "Please select the message to delete!"
            });
            return;
        }
        
        var data = {"action": "spa_message_board", "message_id":msg_ids, "flag": "d", "user_login_id":js_user_name, "message_filter":is_alert};
        var confirm_status = adiha_post_data('confirm', data, '', '', 'delete_message_call_back', '', 'Are you sure you want to delete the selected messages?');
    }

    var timer;
    /**
     * Marks message as Read when hovering to the message for a second
     * @param  {integer}  msg_id   Mesasage Board Id
     * @param  {integer} is_alert Alert (1) or Message (0)
     */
    function mark_message_as_read(msg_id, is_alert) {
        timer = setTimeout(function() {
            if (msg_id == '' || msg_id == 'NULL') {
                dhtmlx.alert({
                    title: 'Warning',
                    type: "alert-warning",
                    text: "Please select the message to mark read!"
                });
                return;
            }
            
            var data = {"action": "spa_message_board", "message_id":msg_id, "flag": "f", "user_login_id":js_user_name, "message_filter":is_alert};
            adiha_post_data('return_array', data, '', '', 'mark_message_call_back', '', '');
        }, 1000);
    }

    /**
     * [refresh_recent_menu Refresh recent menu]
     * @return {[type]} [description]
     */
    function refresh_recent_menu() {
        var no_of_recent_items = '<?php echo $NOS_OF_RECENT_LOG;?>';
        var data = {"action": "spa_my_application_log", "flag": "s", "record_count": no_of_recent_items, "product_category": farrms_product_id};
        adiha_post_data('return_json', data, '', '', 'recent_menu_populate', 0);
    }

    function save_default_theme() {
        var txt_version_theme_name = $('#txt_version_theme_name').val();
        var version_data = {
            "action": "spa_application_version",
            "flag": "t",
            "txt_version_theme_name": txt_version_theme_name
        };
        
        adiha_post_data("return_array", version_data, '', '', "btn_version_theme_save_click_post");
    }

    function btn_version_theme_save_click_post(result) {
        if (result[0][0] == 'Success') {
            $('#myModalTheme').modal('hide');
            reload_theme_save();
        }
        success_call(result[0][4]);
    }

    function close_default_modal() {
        $('#skin-colors .skin-changer-admin').removeClass('active');
        $("#myModalTheme a[data-skin='theme-" + default_theme_name +"']").addClass("active");
    }

    function show_version_modal() {
        if (app_version_is_admin == 1 || has_rights_setup_version) {
            $('#myModal').modal('show');
        }
    }

    function TRMHyperlink(func_id, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10 , asofdate, asofdate_to) {
        get_file_path(func_id);
        $('#messageModal').hide();
        var window_title = '';

        switch (func_id) {
            case 10221013:
                args = "counterparty_id=" + arg1 +
                       "&contract_id=" + arg2 +
                       "&calc_id=" + arg3 +
                       "&source_deal_header_id=" + arg4 +
                       "&deal_date_from=" + asofdate +
                       "&deal_date_to=" + asofdate +
                       "&prod_month=" + asofdate_to +
                       "&estimate_calc=n" +
                       "&int_ext_flag=" + arg5 +
                       "&report_type=" + arg6 +
                       "&invoice_type=" + arg7 +
                       "&calc_status=" + arg8 +
                       "&netting_group_id=" + arg9 +
                       "&settlement_date=" + arg10;
                break;
            case 10131020: // Trade Ticket
                args = "deal_ids=" + arg1 + "&disable_all_buttons=" + arg2 + "&show_button=" + arg3;
                break;
            case 10131010: // Maintain Deal Detail
                args = "deal_id=" + arg1 + "&view_deleted=" + arg2;
                window_title = 'Deal Detail - ' + arg1;
                break;
            case 10171016: // Confirm Deal
                args = "source_deal_header_id=" + arg1;
                break;
            case 10171013: // Deal Confirm History UI
                args = "mode=u&source_deal_header_id=" + arg1 + "&confirm_status_id=" + arg2 + "&call_from=c";
                break;
            case 10234411: // Auto Matching Hedge Report
                var args = "process_id=" + arg1 + "&sub_id=" + arg2 + "&h_or_i=" + arg3 + "&v_buy_sell=" + arg4 +
                            "&str_id=" + arg5 +
                            "&book_id=" + arg6 +
                            "&as_of_date_from=" + asofdate +
                            "&as_of_date_to=" + asofdate_to +
                            "&fifo_lifo=" + arg7 +
                            "&b_s_match_option=" + arg8 +
                            "&v_curve_id=" + arg9 +
                            "&call_from="+arg10+
                            "&call_for_report=y";
                break;
            case 10234500:
                var args = "&show_approved=" + arg1 +
                            "&as_of_date_from=" + asofdate +
                            "&as_of_date_to=" + asofdate_to;
                break;
            case 10201020:
                //openBatchWindowfromlink(arg1, arg2, arg3, arg4, arg5, arg6, arg7, asofdate);
                break;    
            case 10211010:
                var args = "mode=u&contract_id=" + arg1;
                break;
            case 10211300:
                var args = "contract_id=" + arg1 + "&contract_name=" + arg2;
                break;
            case 10211200:
                var args = "contract_id=" + arg1 + "&contract_name=" + arg2;
                break;
            case 10211400:
                var args = "contract_id=" + arg1 + "&contract_name=" + arg2;
                break;
            case 10202210: //view report
                $('#file_path').html('_reporting/report_manager_dhx/report.viewer.php');
                var report_name = arg2.split('_');
                
                $('#window_name').html(report_name[0]);
                $('#window_label').html(report_name[0]);
                var args = 'report_name=' + arg2 + arg1 + '&session_id=' + js_session_id;
                break;
            case 10106100:
                var args = "function_parameter=" + func_id + "&time_series_id=" + arg1 + "&term_start=" + arg2 + "&term_end=" + arg3;
                break;
            case 10131025:
                args = "deal_ids=" + arg1;
            case 10161100:
                args = "call_from=schedule_detail_report&mode=u&path_id=" + arg1;   
                break;
            case 10164000:
                var args = "meter_ids=" + arg1 + '&term_start=' + arg2 + '&term_end=' + arg3 + '&call_from=shutin';
                break;
            case 10105800: // Setup Counterparty
               args = "counterparty_id=" + arg1;
               break;
            case 10101122: // Credit Info
               args = "counterparty_id=" + arg1;
               break;
            case 10163710: // Match
               args = arg1;
               break;
            case 10101200: // tree
               args = "tree_id=" + arg1 + '&level_name=' + arg2 + '&tab_name=' + arg3 ;
               break;
            case 10221300: // view invoice.
               args = "calc_id=" + arg1;
               break;
            case 12101700:
                args = "generator_id=" + arg1;
                break;
            case 10106700:
                args = "workflow_activity_id=" + arg1 + '&call_from=' + arg2 ;
                break;
            case 10233700:
                var args = "&link_id=" + arg1;
                break;
            case 10231900:
                args = "relation_id=" + arg1;
                break;
            case 10102600:
                var args = "&source_price_curve_def_id=" + arg1;
                break;  
            case 10101125:
                var args = "&counterparty_credit_enhancement_id=" + arg1;
                break;        
            case 10105830:  //counterparty Contract
                var args = "&counterparty_contract_address_id=" + arg1;
                break;
        }
        
        setTimeout(function() {
            TRMHyperlink_callback(args, window_title);
        }, 500);
    }
    
    function TRMHyperlink_callback(args, window_title) {
        var file_path = $('#file_path').html();  
        var operator = (file_path.indexOf('?') > 0) ? '&' : '?';// For cases which have function id in file path saved in application_functions
        var window_name = $('#window_name').html(); 
        var window_label = (window_title != '') ? window_title : $('#window_label').html(); 
        open_menu_window(file_path + operator + args, window_name, window_label)
    }
</script>
<script src="../js/farrms_scripts/main.menu.additional.js"></script>
</body>
</html>