/*
@license

dhtmlxGantt v.4.0.10 Professional
This software is covered by DHTMLX Enterprise License. Usage without proper license is prohibited.

(c) Dinamenta, UAB.
*/
Gantt.plugin(function(t){t.config.highlight_critical_path=!1,t._criticalPathHandler=function(){t.config.highlight_critical_path&&t.render()},t.attachEvent("onAfterLinkAdd",t._criticalPathHandler),t.attachEvent("onAfterLinkUpdate",t._criticalPathHandler),t.attachEvent("onAfterLinkDelete",t._criticalPathHandler),t.attachEvent("onAfterTaskAdd",t._criticalPathHandler),t.attachEvent("onAfterTaskUpdate",t._criticalPathHandler),t.attachEvent("onAfterTaskDelete",t._criticalPathHandler),t.isCriticalTask=function(t){
if(t){var e=arguments[1]||{};if(this._isProjectEnd(t))return!0;e[t.id]=!0;for(var a=this._getSuccessors(t),n=0;n<a.length;n++){var i=this.getTask(a[n].task);if(this._getSlack(t,i,a[n].link,a[n].lag)<=0&&!e[i.id]&&this.isCriticalTask(i,e))return!0}return!1}},t.isCriticalLink=function(e){return this.isCriticalTask(t.getTask(e.source))},t.getSlack=function(t,e){for(var a=[],n={},i=0;i<t.$source.length;i++)n[t.$source[i]]=!0;for(var i=0;i<e.$target.length;i++)n[e.$target[i]]&&a.push(e.$target[i]);for(var r=[],i=0;i<a.length;i++){
var s=this.getLink(a[i]);r.push(this._getSlack(t,e,s.type,s.lag))}return Math.min.apply(Math,r)},t._getSlack=function(t,e,a,n){if(null===a)return 0;var i=null,r=null,s=this.config.links,u=this.config.types;i=a!=s.finish_to_finish&&a!=s.finish_to_start||this._get_safe_type(t.type)==u.milestone?t.start_date:t.end_date,r=a!=s.finish_to_finish&&a!=s.start_to_finish||this._get_safe_type(e.type)==u.milestone?e.start_date:e.end_date;var o=0;return o=+i>+r?-this.calculateDuration(r,i):this.calculateDuration(i,r),
n&&1*n==n&&(o-=n),o},t._getProjectEnd=function(){var e=t.getTaskByTime();return e=e.sort(function(t,e){return+t.end_date>+e.end_date?1:-1}),e.length?e[e.length-1].end_date:null},t._isProjectEnd=function(t){return!this._hasDuration(t.end_date,this._getProjectEnd())},t._formatSuccessors=function(t,e){for(var a=[],n=0;n<t.length;n++)a.push(this._formatSuccessor(t[n],e));return a},t._formatSuccessor=function(t,e){return{task:t,link:e.type,lag:e.lag}},t._getSummarySuccessors=function(e,a){var n=[];return this.eachTask(function(e){
this._isTask(e)&&n.push(t._formatSuccessor(e.id,a))},e.id),n},t._getSuccessors=function(e){for(var a=[],n=e.$source.map(function(e){return t.getLink(e)}),i=0;i<n.length;i++){var r=n[i],s=this._get_link_target(r);s&&(this._isTask(s)?a.push(t._formatSuccessor(r.target,r)):a=a.concat(this._getSummarySuccessors(s,r)))}return this._eachParent(function(e){this._isProject(e)&&(a=a.concat(t._getSuccessors(e)))},e),a}});
//# sourceMappingURL=../sources/ext/dhtmlxgantt_critical_path.js.map