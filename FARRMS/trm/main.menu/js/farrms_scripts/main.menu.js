/* get datetime */
function GetClock() {
    var d = new Date();
    $('.clockbox').html('Refreshed at: ' + d.toLocaleDateString() + " " + d.toLocaleTimeString());
}

// to allow the click functions inside dropdown menu
$('.dropdown .dropdown-menu').click(function(e) {
    e.stopPropagation();
});

$('.dropdown-menu-far-left').click(function(e) {
    e.stopPropagation();
});
/* search function for message and alert popup */  
/* new filter selector - case insensitive contains filter*/

$.expr[':'].ci_contains = function(a, i, m) {
    return $(a).text().toLowerCase().indexOf(m[3].toLowerCase()) >= 0;
};

search = (function() {
    $(".search-text").keyup(function(event, handler) {
        var id = $(this).attr("id");

        var context_box = $(this).filter('#' + id);

        if (id == 'msg-search') {
            var context_block = $('.message-li');
            var filter_count = $('#filter_msg_counts_message');
            var added_content = ' Messages';
        } else {
            var context_block = $('.alert-li');
            var filter_count = $('#filter_msg_counts_alert');
            var added_content = ' Notifications';
        }
        
        if (context_box.val() == "") {
            context_block.show();
            return;
        } else {
            context_block.hide();
        }

        try {
            //split the current value of searchInput
            var data = this.value.split(" ");
            //Recusively filter the jquery object to get results.
            $.each(data, function(i, v) {
                v = v.toLowerCase();
                context_block = context_block.filter("*:ci_contains(" + v + ")");
                var filtered_msg_count = context_block.children().length; //filtered message count
                if (filtered_msg_count == 0) {
                   filtered_msg_count = 'No records found';
                } else {
                    filtered_msg_count = filtered_msg_count + added_content
                }
                filter_count.text(filtered_msg_count);
            });
        } catch (exp) {
        }
        //show the rows that match.
        context_block.show();
    }).focus(function() {
        this.value = "";
        $(this).unbind("focus");
    });
});
/* search function for message and alert popup */

/*display message and alert popup*/
function view_all_messages(type) { 
    if (typeof(dhx_wins) === "undefined" || !dhx_wins) {
        dhx_wins = new dhtmlXWindows();
		dhx_wins.attachViewportTo('workspace');
    }

    /* Open message board detail with left menu collapse */
	if ($('#page-wrapper').hasClass('nav-none') == false) {
        $('#page-wrapper').toggleClass('nav-none');
        $('.menu_overlay').hide();
    }	

	var is_win = dhx_wins.isWindow(type);
    var msg_title = (type == 'alert') ? 'Alert Message Board' : 'Message Board';

	if (is_win == false) {
		win_msg = dhx_wins.createWindow(type, 0, 0, 1130, 700);
		win_msg.setText(msg_title);
		//win_msg.centerOnScreen();
        win_msg.maximize();
		win_msg.attachURL('../scripts/message_board_grd.php?type='+type);
	} else {
        dhx_wins.window(type).bringToTop();
	}
}

function get_selected_checkbox() {
    var arr = $('input:checkbox.checkboxes_classes').filter(':checked').map(function () {
                return this.id;
            }).get();
    var len = arr.length;
    
    for (var i = 0; i < len; i++) {
        arr[i] = arr[i].replace('m-checkbox-', '');
    }
    
    var all_ids = arr.join(',');
    return all_ids;
}

function load_foward_message_post(selected_id) {
    $.ajax({
        type: "GET",
        dataType: "text",
        url: "send.message.php?selected_id=" + selected_id, 
        success: function(data) {
            //alert(data)
            var divs = $(data).filter(function(){ return $(this).is('div') });
            divs.each(function() {
                if($(this).hasClass("forward_message")){
                    
                    $("#forwardMessageModal").html($(this).html());
                    $('#forwardMessageModal').modal();
                    $("#messageModal").css("zIndex", 1000);
                }
            });    
        },
        error: function(xht) {
            //alert(xht.status); // generate the unwanted 
        }
    })
}

var message_count;
$(function() {
    $("#message-count").removeClass('count');
    $("#alert-count").removeClass('count');
    
    $('.msg-blk').click(function() {
        setTimeout(function(){
            $('.nano-message-box').nanoScroller({
                alwaysVisible: false,
                preventPageScrolling: true,
                contentClass: 'message-board-content'
            });
        }, 1000);
    });
    
    if (js_user_name != '') {
        refresh_alert_interval();
        message_count = setInterval(refresh_alert_interval, 10000);
    }
    
});

function refresh_alert_interval() {
    refresh_alert('n');
}

function refresh_alert(flag) {    
    $.ajax({
        type: "POST",
        dataType: "json",
        url: "message_count_process.php",
        success: function(data) {
            var cal_reminder_count = data.reminder_count;
            if(cal_reminder_count - count_reminder > 0) {
                open_reminder_window();
                count_reminder = cal_reminder_count;
            } else if (cal_reminder_count == 0) {
                count_reminder = 0;
            }
            
            var msg_notification_count = data.message_count;
            if (msg_notification_count > 0) {
                $("#message-count").addClass('count');
                $("#message-count").css('display', 'block');
                if (msg_notification_count > 0 && msg_notification_count < 100) {
                    $("#message-count").html(msg_notification_count);
                }  else if (msg_notification_count > 99) {
                    $("#message-count").html('99+');
                }
            }  else {
                $("#message-count").removeClass('count');
                $("#message-count").css('display', 'none');
            }

            var alert_notification_count = data.alert_count;
            if (alert_notification_count > 0) {
                $("#alert-count").addClass('count');
                $("#alert-count").css('display', 'block');
                
                if (alert_notification_count > 0 && alert_notification_count < 100) {
                    $("#alert-count").html(alert_notification_count);
                }  else if (alert_notification_count > 99) {
                    $("#alert-count").html('99+');
                }
            } else {
                $("#alert-count").removeClass('count');
                $("#alert-count").css('display', 'none');
            }

            $('.nano-message-box').nanoScroller({
                alwaysVisible: true,
                preventPageScrolling: true,
                contentClass: 'message-board-content'
            });
        },
        statusCode: {
            403: function() {
                clearInterval(message_count);
            }
        }
    });
}

/* config options functions*/
$(function($) {
    $('body').addClass('fixed-header');
    $('body').addClass('fixed-footer');
    $('body').addClass('fixed-leftmenu');

    $('.fixed-leftmenu #col-left').nanoScroller({
        alwaysVisible: true,
        iOSNativeScrolling: false,
        preventPageScrolling: true,
        contentClass: 'col-left-nano-content'
    });

    var storage,
        fail,
        uid;
    try {
        uid = new Date;
        (storage = window.localStorage).setItem(uid, uid);
        fail = storage.getItem(uid) != uid;
        storage.removeItem(uid);
        fail && (storage = false);
    } catch(e) {}

    if (storage) {
        try {
            var usedSkin = default_theme;
            /*Used jomsomGreen selected for default theme; added class on body tag as well*/
            usedSkin = (usedSkin == null) ? 'theme-jomsomGreen' : usedSkin;
            if (usedSkin != '') {
                $('#skin-colors .skin-changer').removeClass('active');
                $('#skin-colors .skin-changer[data-skin="'+usedSkin+'"]').addClass('active');
                $('body').addClass(usedSkin);
				load_css(usedSkin);
				var pth = js_php_path + '/components/lib/adiha_dhtmlx/themes/dhtmlx_' + usedSkin.replace('theme-','') + '/imgs/dhxtoolbar_web/menu_search.png';
                $('.menu_search').css("background","url(" + pth + ") no-repeat;");
            } else {
                $('body').addClass('theme-whbl');
            }
           
            var boxedLayout = localStorage.getItem('config-boxed-layout');
            if (boxedLayout == 'boxed-layout') {
                $('body').addClass(boxedLayout);
                $('#config-boxed-layout').prop('checked', true);
            }

        }
        catch (e) {console.log(e); }
    }

    /* CONFIG TOOLS SETTINGS */
    $('#config-tool-cog').on('click', function(){
        $('#config-tool').toggleClass('closed');
    });


    $('#skin-colors .skin-changer-admin').on('click', function() {
        $('#skin-colors .skin-changer-admin').removeClass('active');
        $(this).addClass('active');
    });

});
function load_css(theme) {
    theme = (theme == 'theme-blue' || theme == 'theme-whbl') ? 'blue' : theme;
    theme = (theme == 'theme-awesome') ? 'theme-awesome' : theme;
    theme = (theme == '') ? 'theme-jomsomGreen' : theme;
    theme = theme.replace("theme-", "");
    theme = theme.replace("-", "_");
    css_file = js_php_path + "components/lib/adiha_dhtmlx/themes/dhtmlx_" + theme + "/dhtmlx.css"
    patch_css_file = js_php_path + "components/lib/adiha_dhtmlx/themes/dhtmlx_" + theme + "/patch.css"
    js_file = js_php_path + "components/lib/adiha_dhtmlx/themes/dhtmlx_" + theme + "/js/awesome.js"
    var fileref = document.createElement("link")
    fileref.setAttribute("rel", "stylesheet")
    fileref.setAttribute("type", "text/css")
    fileref.setAttribute("href", css_file);
    fileref.setAttribute("href",js_file);
	fileref.setAttribute("href", patch_css_file);
	
    document.getElementsByTagName("head")[0].appendChild(fileref);
	/* 
    Set async property to false for the synchronous request. 
    This property is added to set session theme before process other process to fix theme mismatch issue.
    Note: async false is no longer supported for jQuery >= 1.8.  This is workaround fix.
    */
    var theme_data = {'dhtmlx_theme' : theme}
    $.param(theme_data);
    $.ajax({
        type: "POST",
        dataShow : "text",
        url: js_php_path + 'components/set.dhtmlx.themes.php',
        data: theme_data,
        async: false
    })
}

function reload_theme_save() {
    var theme_admin = 'theme-'+$('#txt_version_theme_name').val();
    var storage = window.localStorage;
    writeStorage(storage, 'config-skin', theme_admin);
    var data = {'dhtmlx_theme' : theme_admin};
    $.param(data);
    $.ajax({
        type: "POST",
        url: js_php_path + 'components/set.dhtmlx.themes.php',
        data: data,
        success : function() {
            location.reload();
        }
    })
}

function writeStorage(storage, key, value) {
    if (storage) {
        try {
            localStorage.setItem(key, value);
        }
        catch (e) { console.log(e);}
    }
}

$.fn.removeClassPrefix = function(prefix) {
    this.each(function(i, el) {
        var classes = el.className.split(" ").filter(function(c) {
            return c.lastIndexOf(prefix, 0) !== 0;
        });
        el.className = classes.join(" ");
    });
    return this;
};  

// Log Off
$("#log-out").on('click', function() {
    confirm_messagebox('Are you sure you want to log off?', logout);
});

function logout() {
    $.ajax({
        type: "POST",
        url: js_php_path + 'spa_session_destroy.php',
        success: function(data) {
            if (azure_ad == 1 && cloud_mode == 0) { 
                // Azure AD Authentication
                $.when(document.location.href = '../../../' + farrms_client_dir + '/?action=logout').then(close());
            } else if (user_mode == 1) {
                // Windows Authentication
                close();
            } else if (cloud_mode == 1) {
                // SaaS Mode
                document.location.href = '/?action=user_logout';
            } else {
                // Non-SaaS mode using user login id and password
                document.location.href = '../../../' + farrms_client_dir + '/';
            }
        }
    });
}

// menus transitions 
(function($,sr){
    // debouncing function from John Hann
    // http://unscriptable.com/index.php/2009/03/20/debouncing-javascript-methods/
    var debounce = function (func, threshold, execAsap) {
        var timeout;

        return function debounced () {
            var obj = this, args = arguments;
            function delayed () {
                if (!execAsap)
                    func.apply(obj, args);
                timeout = null;
            };

            if (timeout)
                clearTimeout(timeout);
            else if (execAsap)
                func.apply(obj, args);

            timeout = setTimeout(delayed, threshold || 100);
        };
    }
    // smartresize 
    jQuery.fn[sr] = function(fn){   return fn ? this.bind('resize', debounce(fn)) : this.trigger(sr); };

})(jQuery,'smartresize');

$(function($) {
    setTimeout(function() {
        $('#content-wrapper > .row').css({
            opacity: 1
        });
    }, 200);
    
    $('#sidebar-nav .dropdown-toggle').on('click', function (e) {
        e.preventDefault();
        var $item = $(this).parent();
        
        if (!$item.hasClass('open')) {
            $item.parent().find('.open .submenu').slideUp('fast');
            $item.parent().find('.open').toggleClass('open');
        }
        
        $item.toggleClass('open');
        
        if ($item.hasClass('open')) {
            $item.children('.submenu').delay(150).slideDown('fast');
        } 
        else {
            $item.children('.submenu').slideUp('fast');
        }
    });
    $('.menu_overlay').click(function (e) {
        $(this).hide();
        $('#page-wrapper').toggleClass('nav-none');
    });

    $('#make-small-nav').click(function (e) {
		$('#menu-searchbar').slideUp();
        $('#col-left-inner').removeClass('offset-top-search');
		
        if ($('#page-wrapper').hasClass('nav-none')) {
            $('#page-wrapper').toggleClass('nav-none');
            $('.menu_overlay').show();
        } else if ($('#page-wrapper').hasClass('nav-none') == false) {
            //$('#page-wrapper').toggleClass('nav-small');
            $('#page-wrapper').toggleClass('nav-none');
            $('.menu_overlay').hide();
        } else {
            //$('#page-wrapper').toggleClass('nav-small');
        }
        
        if ($('#page-wrapper #menu-lists li').hasClass('open')) {
            $('#page-wrapper #menu-lists li').parent().find('.open .submenu').slideUp('fast');
            $('#page-wrapper #menu-lists li').parent().find('.open').toggleClass('open');
        }
    });
    
    $(window).smartresize(function(){
        if ($( document ).width() <= 991) {
            $('#page-wrapper').removeClass('nav-small');
            $('#page-wrapper').removeClass('nav-none');
        }
    });
    
    $('.mobile-search').click(function(e) {
        e.preventDefault();
        
        $('.mobile-search').addClass('active');
        $('.mobile-search form input.form-control').focus();
    });
    $(document).mouseup(function (e) {
        var container = $('.mobile-search');

        if (!container.is(e.target) // if the target of the click isn't the container...
            && container.has(e.target).length === 0) // ... nor a descendant of the container
        {
            container.removeClass('active');
        }
    });
    
    $('.fixed-leftmenu #col-left').nanoScroller({
        alwaysVisible: true,
        iOSNativeScrolling: false,
        preventPageScrolling: true,
        contentClass: 'col-left-nano-content'
    });
    
    // build all tooltips from data-attributes
    $("[data-toggle='tooltip']").each(function (index, el) {
        $(el).tooltip({
            placement: $(this).data("placement") || 'top'
        });
    });
});

$.fn.removeClassPrefix = function(prefix) {
    this.each(function(i, el) {
        var classes = el.className.split(" ").filter(function(c) {
            return c.lastIndexOf(prefix, 0) !== 0;
        });
        el.className = classes.join(" ");
    });
    return this;
};
