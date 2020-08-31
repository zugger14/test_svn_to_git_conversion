/*
@license
dhtmlxScheduler v.4.3.35 Professional

This software is covered by DHTMLX Enterprise License. Usage without proper license is prohibited.

(c) Dinamenta, UAB.
*/
Scheduler.plugin(function(e){!function(){e._register_copies_array=function(e){for(var t=0;t<e.length;t++)this._register_copy(e[t])},e._register_copy=function(e){this._multisection_copies[e.id]||(this._multisection_copies[e.id]={});var t=e[this._get_section_property()],i=this._multisection_copies[e.id];i[t]||(i[t]=e)},e._get_copied_event=function(t,i){if(!this._multisection_copies[t])return null;if(this._multisection_copies[t][i])return this._multisection_copies[t][i];var a=this._multisection_copies[t];
if(e._drag_event&&e._drag_event._orig_section&&a[e._drag_event._orig_section])return a[e._drag_event._orig_section];var n=1/0,s=null;for(var r in a)a[r]._sorder<n&&(s=a[r],n=a[r]._sorder);return s},e._clear_copied_events=function(){this._multisection_copies={}},e._restore_render_flags=function(t){for(var i=this._get_section_property(),a=0;a<t.length;a++){var n=t[a],s=e._get_copied_event(n.id,n[i]);if(s)for(var r in s)0===r.indexOf("_")&&(n[r]=s[r])}};var t=e.createTimelineView;e.createTimelineView=function(i){
function a(){var t=new Date(e.getState().date),a=e.date[c+"_start"](t);a=e.date.date_part(a);var n=[],s=e.matrix[c];s.y_unit=n,s.order={};for(var r=0;r<i.days;r++)n.push({key:+a,label:a}),s.order[s.y_unit[r].key]=r,a=e.date.add(a,1,"day")}function n(e){var t={};for(var i in e)t[i]=e[i];return t}function s(e,t){t.setDate(1),t.setFullYear(e.getFullYear()),t.setMonth(e.getMonth()),t.setDate(e.getDate())}function r(t){for(var i=[],a=0;a<t.length;a++){var n=o(t[a]);if(e.isOneDayEvent(n))l(n),i.push(n);else{
for(var s=new Date(Math.min(+n.end_date,+e._max_date)),r=new Date(Math.max(+n.start_date,+e._min_date)),_=[];+s>+r;){var c=o(n);c.start_date=r,c.end_date=new Date(Math.min(+h(c.start_date),+s)),r=h(r),l(c),i.push(c),_.push(c)}d(_,n)}}return i}function d(e,t){for(var i=!1,a=!1,n=0,s=e.length;s>n;n++){var r=e[n];i=+r._w_start_date==+t.start_date,a=+r._w_end_date==+t.end_date,r._no_resize_start=r._no_resize_end=!0,i&&(r._no_resize_start=!1),a&&(r._no_resize_end=!1)}}function o(t){var i=e.getEvent(t.event_pid);
return i&&i.isPrototypeOf(t)?(t=e._copy_event(t),delete t.event_length,delete t.event_pid,delete t.rec_pattern,delete t.rec_type):t=e._lame_clone(t),t}function l(t){if(!t._w_start_date||!t._w_end_date){var i=e.date,a=t._w_start_date=new Date(t.start_date),n=t._w_end_date=new Date(t.end_date);t[u]=+i.date_part(t.start_date),t._count||(t._count=1),t._sorder||(t._sorder=0);var s=n-a;t.start_date=new Date(e._min_date),_(a,t.start_date),t.end_date=new Date(+t.start_date+s)}}function _(e,t){t.setMinutes(e.getMinutes()),
t.setHours(e.getHours())}function h(t){var i=e.date.add(t,1,"day");return i=e.date.date_part(i)}if("days"!=i.render)return void t.apply(this,arguments);var c=i.name,u=i.y_property="timeline-week"+c;i.y_unit=[],i.render="bar",i.days=i.days||7,t.call(this,i),e.templates[c+"_scalex_class"]=function(){},e.templates[c+"_scaley_class"]=function(){},e.templates[c+"_scale_label"]=function(t,i,a){return e.templates.day_date(i)},e.date[c+"_start"]=function(t){return t=e.date.week_start(t),t=e.date.add(t,i.x_step*i.x_start,i.x_unit);
},e.date["add_"+c]=function(t,a){return e.date.add(t,a*i.days,"day")};var v=e._renderMatrix;e._renderMatrix=function(e,t){e&&a(),v.apply(this,arguments)};var g=e.checkCollision;e.checkCollision=function(t){if(t[u]){var t=n(t);delete t[u]}return g.apply(e,[t])},e.attachEvent("onBeforeDrag",function(t,i,a){var n=a.target||a.srcElement,s=e._getClassName(n);if("resize"==i)s.indexOf("dhx_event_resize_end")<0?e._w_line_drag_from_start=!0:e._w_line_drag_from_start=!1;else if("move"==i&&s.indexOf("no_drag_move")>=0)return!1;
return!0});var f=e["mouse_"+c];e["mouse_"+c]=function(t){var i;if(this._drag_event&&(i=this._drag_event._move_delta),void 0===i&&"move"==e._drag_mode){var a=e.matrix[this._mode],n={y:t.y};e._resolve_timeline_section(a,n);var s=t.x-a.dx,r=new Date(n.section);_(e._timeline_drag_date(a,s),r);var d=e._drag_event,o=this.getEvent(this._drag_id);d._move_delta=(o.start_date-r)/6e4,this.config.preserve_length&&t._ignores&&(d._move_delta=this._get_real_event_length(o.start_date,r,a),d._event_length=this._get_real_event_length(o.start_date,o.end_date,a));
}var t=f.apply(e,arguments);if(e._drag_mode&&"move"!=e._drag_mode){var l=null;l=e._drag_event&&e._drag_event["timeline-week"+c]?new Date(e._drag_event["timeline-week"+c]):new Date(t.section),t.y+=Math.round((l-e.date.date_part(new Date(e._min_date)))/(6e4*this.config.time_step)),"resize"==e._drag_mode&&(t.resize_from_start=e._w_line_drag_from_start)}else if(e._drag_event){var h=Math.floor(Math.abs(t.y/(1440/e.config.time_step)));h*=t.y>0?1:-1,t.y=t.y%(1440/e.config.time_step);var u=e.date.date_part(new Date(e._min_date));
u.valueOf()!=new Date(t.section).valueOf()&&(t.x=Math.floor((t.section-u)/864e5),t.x+=h)}return t},e.attachEvent("onEventCreated",function(t,i){return e._events[t]&&delete e._events[t][u],!0}),e.attachEvent("onBeforeEventChanged",function(t,i,a,n){return e._events[t.id]&&delete e._events[t.id][u],!0});var m=e.render_view_data;e.render_view_data=function(t,i){return this._mode==c&&t&&(t=r(t),e._restore_render_flags(t)),m.apply(e,[t,i])};var p=e.get_visible_events;e.get_visible_events=function(){if(this._mode==c){
this._clear_copied_events(),e._max_date=e.date.date_part(e.date.add(e._min_date,i.days,"day"));var t=p.apply(e,arguments);return t=r(t),e._register_copies_array(t),t}return p.apply(e,arguments)};var x=e.addEventNow;e.addEventNow=function(t){if(e.getState().mode==c)if(t[u]){var i=new Date(t[u]);s(i,t.start_date),s(i,t.end_date)}else{var a=new Date(t.start_date);t[u]=+e.date.date_part(a)}return x.apply(e,arguments)};var b=e._render_marked_timespan;e._render_marked_timespan=function(){return e._mode!=c?b.apply(this,arguments):void 0;
}}}()});
//# sourceMappingURL=../sources/ext/dhtmlxscheduler_daytimeline.js.map