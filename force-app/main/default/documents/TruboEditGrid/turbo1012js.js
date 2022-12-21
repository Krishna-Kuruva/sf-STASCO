/*
	Copyright (c) 2004-2006, The TurboAjax Group
	All Rights Reserved.

	TurboWidgets are free free to use for noncommercial web pages and 
	applications. A commercial license is required to use TurboWidgets 
	in a commercial web page or application. The TurboWidgest commercial 
	license is per developer and requires no royalty fees.

	http://turboajax.com/turbowidgets/license.html
*/

/*
	This compiled TurboWidgets file contains a build of the Dojo Toolkit.
*/

/*
	Copyright (c) 2004-2006, The Dojo Foundation
	All Rights Reserved.

	Licensed under the Academic Free License version 2.1 or above OR the
	modified BSD license. For more information on Dojo licensing, see:

		http://dojotoolkit.org/community/licensing.shtml
*/

/*
	This is a compiled version of Dojo, built for deployment and not for
	development. To get an editable version, please visit:

		http://dojotoolkit.org

	for documentation and information on getting the source.
*/

var dj_global=this;
function dj_undef(_1,_2){
if(!_2){
_2=dj_global;
}
return (typeof _2[_1]=="undefined");
}
if(dj_undef("djConfig")){
var djConfig={};
}
if(dj_undef("dojo")){
var dojo={};
}
dojo.version={major:0,minor:2,patch:2,flag:"+",revision:Number("$Rev: 3802 $".match(/[0-9]+/)[0]),toString:function(){
with(dojo.version){
return major+"."+minor+"."+patch+flag+" ("+revision+")";
}
}};
dojo.evalProp=function(_3,_4,_5){
return (_4&&!dj_undef(_3,_4)?_4[_3]:(_5?(_4[_3]={}):undefined));
};
dojo.parseObjPath=function(_6,_7,_8){
var _9=(_7?_7:dj_global);
var _a=_6.split(".");
var _b=_a.pop();
for(var i=0,l=_a.length;i<l&&_9;i++){
_9=dojo.evalProp(_a[i],_9,_8);
}
return {obj:_9,prop:_b};
};
dojo.evalObjPath=function(_d,_e){
if(typeof _d!="string"){
return dj_global;
}
if(_d.indexOf(".")==-1){
return dojo.evalProp(_d,dj_global,_e);
}
with(dojo.parseObjPath(_d,dj_global,_e)){
return dojo.evalProp(prop,obj,_e);
}
};
dojo.errorToString=function(_f){
return ((!dj_undef("message",_f))?_f.message:(dj_undef("description",_f)?_f:_f.description));
};
dojo.raise=function(_10,_11){
if(_11){
_10=_10+": "+dojo.errorToString(_11);
}
var he=dojo.hostenv;
if((!dj_undef("hostenv",dojo))&&(!dj_undef("println",dojo.hostenv))){
dojo.hostenv.println("FATAL: "+_10);
}
throw Error(_10);
};
dojo.debug=function(){
};
dojo.debugShallow=function(obj){
};
dojo.profile={start:function(){
},end:function(){
},stop:function(){
},dump:function(){
}};
function dj_eval(s){
return dj_global.eval?dj_global.eval(s):eval(s);
}
dojo.unimplemented=function(_15,_16){
var _17="'"+_15+"' not implemented";
if((!dj_undef(_16))&&(_16)){
_17+=" "+_16;
}
dojo.raise(_17);
};
dojo.deprecated=function(_18,_19,_1a){
var _1b="DEPRECATED: "+_18;
if(_19){
_1b+=" "+_19;
}
if(_1a){
_1b+=" -- will be removed in version: "+_1a;
}
dojo.debug(_1b);
};
dojo.inherits=function(_1c,_1d){
if(typeof _1d!="function"){
dojo.raise("dojo.inherits: superclass argument ["+_1d+"] must be a function (subclass: ["+_1c+"']");
}
_1c.prototype=new _1d();
_1c.prototype.constructor=_1c;
_1c.superclass=_1d.prototype;
_1c["super"]=_1d.prototype;
};
dojo.render=(function(){
function vscaffold(_1e,_1f){
var tmp={capable:false,support:{builtin:false,plugin:false},prefixes:_1e};
for(var x in _1f){
tmp[x]=false;
}
return tmp;
}
return {name:"",ver:dojo.version,os:{win:false,linux:false,osx:false},html:vscaffold(["html"],["ie","opera","khtml","safari","moz"]),svg:vscaffold(["svg"],["corel","adobe","batik"]),vml:vscaffold(["vml"],["ie"]),swf:vscaffold(["Swf","Flash","Mm"],["mm"]),swt:vscaffold(["Swt"],["ibm"])};
})();
dojo.hostenv=(function(){
var _22={isDebug:false,allowQueryConfig:false,baseScriptUri:"",baseRelativePath:"",libraryScriptUri:"",iePreventClobber:false,ieClobberMinimal:true,preventBackButtonFix:true,searchIds:[],parseWidgets:true};
if(typeof djConfig=="undefined"){
djConfig=_22;
}else{
for(var _23 in _22){
if(typeof djConfig[_23]=="undefined"){
djConfig[_23]=_22[_23];
}
}
}
return {name_:"(unset)",version_:"(unset)",getName:function(){
return this.name_;
},getVersion:function(){
return this.version_;
},getText:function(uri){
dojo.unimplemented("getText","uri="+uri);
}};
})();
dojo.hostenv.getBaseScriptUri=function(){
if(djConfig.baseScriptUri.length){
return djConfig.baseScriptUri;
}
var uri=new String(djConfig.libraryScriptUri||djConfig.baseRelativePath);
if(!uri){
dojo.raise("Nothing returned by getLibraryScriptUri(): "+uri);
}
var _26=uri.lastIndexOf("/");
djConfig.baseScriptUri=djConfig.baseRelativePath;
return djConfig.baseScriptUri;
};
(function(){
var _27={pkgFileName:"__package__",loading_modules_:{},loaded_modules_:{},addedToLoadingCount:[],removedFromLoadingCount:[],inFlightCount:0,modulePrefixes_:{dojo:{name:"dojo",value:"src"}},setModulePrefix:function(_28,_29){
this.modulePrefixes_[_28]={name:_28,value:_29};
},getModulePrefix:function(_2a){
var mp=this.modulePrefixes_;
if((mp[_2a])&&(mp[_2a]["name"])){
return mp[_2a].value;
}
return _2a;
},getTextStack:[],loadUriStack:[],loadedUris:[],post_load_:false,modulesLoadedListeners:[]};
for(var _2c in _27){
dojo.hostenv[_2c]=_27[_2c];
}
})();
dojo.hostenv.loadPath=function(_2d,_2e,cb){
if((_2d.charAt(0)=="/")||(_2d.match(/^\w+:/))){
dojo.raise("relpath '"+_2d+"'; must be relative");
}
var uri=this.getBaseScriptUri()+_2d;
if(djConfig.cacheBust&&dojo.render.html.capable){
uri+="?"+String(djConfig.cacheBust).replace(/\W+/g,"");
}
try{
return ((!_2e)?this.loadUri(uri,cb):this.loadUriAndCheck(uri,_2e,cb));
}
catch(e){
dojo.debug(e);
return false;
}
};
dojo.hostenv.loadUri=function(uri,cb){
if(this.loadedUris[uri]){
return;
}
var _33=this.getText(uri,null,true);
if(_33==null){
return 0;
}
this.loadedUris[uri]=true;
var _34=dj_eval(_33);
return 1;
};
dojo.hostenv.loadUriAndCheck=function(uri,_36,cb){
var ok=true;
try{
ok=this.loadUri(uri,cb);
}
catch(e){
dojo.debug("failed loading ",uri," with error: ",e);
}
return ((ok)&&(this.findModule(_36,false)))?true:false;
};
dojo.loaded=function(){
};
dojo.hostenv.loaded=function(){
this.post_load_=true;
var mll=this.modulesLoadedListeners;
this.modulesLoadedListeners=[];
for(var x=0;x<mll.length;x++){
mll[x]();
}
dojo.loaded();
};
dojo.addOnLoad=function(obj,_3c){
var dh=dojo.hostenv;
if(arguments.length==1){
dh.modulesLoadedListeners.push(obj);
}else{
if(arguments.length>1){
dh.modulesLoadedListeners.push(function(){
obj[_3c]();
});
}
}
if(dh.post_load_&&dh.inFlightCount==0){
dh.callLoaded();
}
};
dojo.hostenv.modulesLoaded=function(){
if(this.post_load_){
return;
}
if((this.loadUriStack.length==0)&&(this.getTextStack.length==0)){
if(this.inFlightCount>0){
dojo.debug("files still in flight!");
return;
}
dojo.hostenv.callLoaded();
}
};
dojo.hostenv.callLoaded=function(){
if(typeof setTimeout=="object"){
setTimeout("dojo.hostenv.loaded();",0);
}else{
dojo.hostenv.loaded();
}
};
dojo.hostenv._global_omit_module_check=false;
dojo.hostenv.loadModule=function(_3e,_3f,_40){
if(!_3e){
return;
}
_40=this._global_omit_module_check||_40;
var _41=this.findModule(_3e,false);
if(_41){
return _41;
}
if(dj_undef(_3e,this.loading_modules_)){
this.addedToLoadingCount.push(_3e);
}
this.loading_modules_[_3e]=1;
var _42=_3e.replace(/\./g,"/")+".js";
var _43=_3e.split(".");
var _44=_3e.split(".");
for(var i=_43.length-1;i>0;i--){
var _46=_43.slice(0,i).join(".");
var _47=this.getModulePrefix(_46);
if(_47!=_46){
_43.splice(0,i,_47);
break;
}
}
var _48=_43[_43.length-1];
if(_48=="*"){
_3e=(_44.slice(0,-1)).join(".");
while(_43.length){
_43.pop();
_43.push(this.pkgFileName);
_42=_43.join("/")+".js";
if(_42.charAt(0)=="/"){
_42=_42.slice(1);
}
ok=this.loadPath(_42,((!_40)?_3e:null));
if(ok){
break;
}
_43.pop();
}
}else{
_42=_43.join("/")+".js";
_3e=_44.join(".");
var ok=this.loadPath(_42,((!_40)?_3e:null));
if((!ok)&&(!_3f)){
_43.pop();
while(_43.length){
_42=_43.join("/")+".js";
ok=this.loadPath(_42,((!_40)?_3e:null));
if(ok){
break;
}
_43.pop();
_42=_43.join("/")+"/"+this.pkgFileName+".js";
if(_42.charAt(0)=="/"){
_42=_42.slice(1);
}
ok=this.loadPath(_42,((!_40)?_3e:null));
if(ok){
break;
}
}
}
if((!ok)&&(!_40)){
dojo.raise("Could not load '"+_3e+"'; last tried '"+_42+"'");
}
}
if(!_40&&!this["isXDomain"]){
_41=this.findModule(_3e,false);
if(!_41){
dojo.raise("symbol '"+_3e+"' is not defined after loading '"+_42+"'");
}
}
return _41;
};
dojo.hostenv.startPackage=function(_4a){
var _4b=dojo.evalObjPath((_4a.split(".").slice(0,-1)).join("."));
this.loaded_modules_[(new String(_4a)).toLowerCase()]=_4b;
var _4c=_4a.split(/\./);
if(_4c[_4c.length-1]=="*"){
_4c.pop();
}
return dojo.evalObjPath(_4c.join("."),true);
};
dojo.hostenv.findModule=function(_4d,_4e){
var lmn=(new String(_4d)).toLowerCase();
if(this.loaded_modules_[lmn]){
return this.loaded_modules_[lmn];
}
var _50=dojo.evalObjPath(_4d);
if((_4d)&&(typeof _50!="undefined")&&(_50)){
this.loaded_modules_[lmn]=_50;
return _50;
}
if(_4e){
dojo.raise("no loaded module named '"+_4d+"'");
}
return null;
};
dojo.kwCompoundRequire=function(_51){
var _52=_51["common"]||[];
var _53=(_51[dojo.hostenv.name_])?_52.concat(_51[dojo.hostenv.name_]||[]):_52.concat(_51["default"]||[]);
for(var x=0;x<_53.length;x++){
var _55=_53[x];
if(_55.constructor==Array){
dojo.hostenv.loadModule.apply(dojo.hostenv,_55);
}else{
dojo.hostenv.loadModule(_55);
}
}
};
dojo.require=function(){
dojo.hostenv.loadModule.apply(dojo.hostenv,arguments);
};
dojo.requireIf=function(){
if((arguments[0]===true)||(arguments[0]=="common")||(arguments[0]&&dojo.render[arguments[0]].capable)){
var _56=[];
for(var i=1;i<arguments.length;i++){
_56.push(arguments[i]);
}
dojo.require.apply(dojo,_56);
}
};
dojo.requireAfterIf=dojo.requireIf;
dojo.provide=function(){
return dojo.hostenv.startPackage.apply(dojo.hostenv,arguments);
};
dojo.setModulePrefix=function(_58,_59){
return dojo.hostenv.setModulePrefix(_58,_59);
};
dojo.exists=function(obj,_5b){
var p=_5b.split(".");
for(var i=0;i<p.length;i++){
if(!(obj[p[i]])){
return false;
}
obj=obj[p[i]];
}
return true;
};
if(typeof window=="undefined"){
dojo.raise("no window object");
}
(function(){
if(djConfig.allowQueryConfig){
var _5e=document.location.toString();
var _5f=_5e.split("?",2);
if(_5f.length>1){
var _60=_5f[1];
var _61=_60.split("&");
for(var x in _61){
var sp=_61[x].split("=");
if((sp[0].length>9)&&(sp[0].substr(0,9)=="djConfig.")){
var opt=sp[0].substr(9);
try{
djConfig[opt]=eval(sp[1]);
}
catch(e){
djConfig[opt]=sp[1];
}
}
}
}
}
if(((djConfig["baseScriptUri"]=="")||(djConfig["baseRelativePath"]==""))&&(document&&document.getElementsByTagName)){
var _65=document.getElementsByTagName("script");
var _66=/(__package__|turbo|bootstrap1)\.js([\?\.]|$)/i;
for(var i=0;i<_65.length;i++){
var src=_65[i].getAttribute("src");
if(!src){
continue;
}
var m=src.match(_66);
if(m){
root=src.substring(0,m.index);
if(src.indexOf("bootstrap1")>-1){
root+="../";
}
if(!this["djConfig"]){
djConfig={};
}
if(djConfig["baseScriptUri"]==""){
djConfig["baseScriptUri"]=root;
}
if(djConfig["baseRelativePath"]==""){
djConfig["baseRelativePath"]=root;
}
break;
}
}
}
var dr=dojo.render;
var drh=dojo.render.html;
var drs=dojo.render.svg;
var dua=drh.UA=navigator.userAgent;
var dav=drh.AV=navigator.appVersion;
var t=true;
var f=false;
drh.capable=t;
drh.support.builtin=t;
dr.ver=parseFloat(drh.AV);
dr.os.mac=dav.indexOf("Macintosh")>=0;
dr.os.win=dav.indexOf("Windows")>=0;
dr.os.linux=dav.indexOf("X11")>=0;
drh.opera=dua.indexOf("Opera")>=0;
drh.khtml=(dav.indexOf("Konqueror")>=0)||(dav.indexOf("Safari")>=0);
drh.safari=dav.indexOf("Safari")>=0;
var _71=dua.indexOf("Gecko");
drh.mozilla=drh.moz=(_71>=0)&&(!drh.khtml);
if(drh.mozilla){
drh.geckoVersion=dua.substring(_71+6,_71+14);
}
drh.ie=(document.all)&&(!drh.opera);
drh.ie50=drh.ie&&dav.indexOf("MSIE 5.0")>=0;
drh.ie55=drh.ie&&dav.indexOf("MSIE 5.5")>=0;
drh.ie60=drh.ie&&dav.indexOf("MSIE 6.0")>=0;
dr.vml.capable=drh.ie;
drs.capable=f;
drs.support.plugin=f;
drs.support.builtin=f;
if(document.implementation&&document.implementation.hasFeature&&document.implementation.hasFeature("org.w3c.dom.svg","1.0")){
drs.capable=t;
drs.support.builtin=t;
drs.support.plugin=f;
}
})();
dojo.hostenv.startPackage("dojo.hostenv");
dojo.render.name=dojo.hostenv.name_="browser";
dojo.hostenv.searchIds=[];
var DJ_XMLHTTP_PROGIDS=["Msxml2.XMLHTTP","Microsoft.XMLHTTP","Msxml2.XMLHTTP.4.0"];
dojo.hostenv.getXmlhttpObject=function(){
var _72=null;
var _73=null;
try{
_72=new XMLHttpRequest();
}
catch(e){
}
if(!_72){
for(var i=0;i<3;++i){
var _75=DJ_XMLHTTP_PROGIDS[i];
try{
_72=new ActiveXObject(_75);
}
catch(e){
_73=e;
}
if(_72){
DJ_XMLHTTP_PROGIDS=[_75];
break;
}
}
}
if(!_72){
return dojo.raise("XMLHTTP not available",_73);
}
return _72;
};
dojo.hostenv.getText=function(uri,_77,_78){
var _79=this.getXmlhttpObject();
if(_77){
_79.onreadystatechange=function(){
if((4==_79.readyState)&&(_79["status"])){
if(_79.status==200){
_77(_79.responseText);
}
}
};
}
_79.open("GET",uri,_77?true:false);
try{
_79.send(null);
}
catch(e){
if(_78&&!_77){
return null;
}else{
throw e;
}
}
if(_77){
return null;
}
return _79.responseText;
};
dojo.hostenv.defaultDebugContainerId="dojoDebug";
dojo.hostenv._println_buffer=[];
dojo.hostenv._println_safe=false;
dojo.hostenv.println=function(_7a){
if(!dojo.hostenv._println_safe){
dojo.hostenv._println_buffer.push(_7a);
}else{
try{
var _7b=document.getElementById(djConfig.debugContainerId?djConfig.debugContainerId:dojo.hostenv.defaultDebugContainerId);
if(!_7b){
_7b=document.getElementsByTagName("body")[0]||document.body;
}
var div=document.createElement("div");
div.appendChild(document.createTextNode(_7a));
_7b.appendChild(div);
}
catch(e){
try{
document.write("<div>"+_7a+"</div>");
}
catch(e2){
window.status=_7a;
}
}
}
};
dojo.addOnLoad(function(){
dojo.hostenv._println_safe=true;
while(dojo.hostenv._println_buffer.length>0){
dojo.hostenv.println(dojo.hostenv._println_buffer.shift());
}
});
function dj_addNodeEvtHdlr(_7d,_7e,fp,_80){
var _81=_7d["on"+_7e]||function(){
};
_7d["on"+_7e]=function(){
fp.apply(_7d,arguments);
_81.apply(_7d,arguments);
};
return true;
}
dj_addNodeEvtHdlr(window,"load",function(){
if(arguments.callee.initialized){
return;
}
arguments.callee.initialized=true;
var _82=function(){
if(dojo.render.html.ie){
dojo.hostenv.makeWidgets();
}
};
if(dojo.hostenv.inFlightCount==0){
_82();
dojo.hostenv.modulesLoaded();
}else{
dojo.addOnLoad(_82);
}
});
dojo.hostenv.makeWidgets=function(){
var _83=[];
if(djConfig.searchIds&&djConfig.searchIds.length>0){
_83=_83.concat(djConfig.searchIds);
}
if(dojo.hostenv.searchIds&&dojo.hostenv.searchIds.length>0){
_83=_83.concat(dojo.hostenv.searchIds);
}
if((djConfig.parseWidgets)||(_83.length>0)){
if(dojo.evalObjPath("dojo.widget.Parse")){
try{
var _84=new dojo.xml.Parse();
if(_83.length>0){
for(var x=0;x<_83.length;x++){
var _86=document.getElementById(_83[x]);
if(!_86){
continue;
}
var _87=_84.parseElement(_86,null,true);
dojo.widget.getParser().createComponents(_87);
}
}else{
if(djConfig.parseWidgets){
var _87=_84.parseElement(document.getElementsByTagName("body")[0]||document.body,null,true);
dojo.widget.getParser().createComponents(_87);
}
}
}
catch(e){
dojo.debug("auto-build-widgets error:",e);
}
}
}
};
dojo.addOnLoad(function(){
if(!dojo.render.html.ie){
dojo.hostenv.makeWidgets();
}
});
try{
if(dojo.render.html.ie){
document.namespaces.add("v","urn:schemas-microsoft-com:vml");
document.createStyleSheet().addRule("v\\:*","behavior:url(#default#VML)");
}
}
catch(e){
}
dojo.hostenv.writeIncludes=function(){
};
dojo.byId=function(id,doc){
if(id&&(typeof id=="string"||id instanceof String)){
if(!doc){
doc=document;
}
return doc.getElementById(id);
}
return id;
};
(function(){
if(typeof dj_usingBootstrap!="undefined"){
return;
}
var _8a=false;
var _8b=false;
var _8c=false;
if((typeof this["load"]=="function")&&(typeof this["Packages"]=="function")){
_8a=true;
}else{
if(typeof this["load"]=="function"){
_8b=true;
}else{
if(window.widget){
_8c=true;
}
}
}
var _8d=[];
if((this["djConfig"])&&((djConfig["isDebug"])||(djConfig["debugAtAllCosts"]))){
_8d.push("debug.js");
}
if((this["djConfig"])&&(djConfig["debugAtAllCosts"])&&(!_8a)&&(!_8c)){
_8d.push("browser_debug.js");
}
if((this["djConfig"])&&(djConfig["compat"])){
_8d.push("compat/"+djConfig["compat"]+".js");
}
var _8e=djConfig["baseScriptUri"];
if((this["djConfig"])&&(djConfig["baseLoaderUri"])){
_8e=djConfig["baseLoaderUri"];
}
for(var x=0;x<_8d.length;x++){
var _90=_8e+"src/"+_8d[x];
if(_8a||_8b){
load(_90);
}else{
try{
document.write("<scr"+"ipt type='text/javascript' src='"+_90+"'></scr"+"ipt>");
}
catch(e){
var _91=document.createElement("script");
_91.src=_90;
document.getElementsByTagName("head")[0].appendChild(_91);
}
}
}
})();
dojo.provide("dojo.string.common");
dojo.require("dojo.string");
dojo.string.trim=function(str,wh){
if(!str.replace){
return str;
}
if(!str.length){
return str;
}
var re=(wh>0)?(/^\s+/):(wh<0)?(/\s+$/):(/^\s+|\s+$/g);
return str.replace(re,"");
};
dojo.string.trimStart=function(str){
return dojo.string.trim(str,1);
};
dojo.string.trimEnd=function(str){
return dojo.string.trim(str,-1);
};
dojo.string.repeat=function(str,_98,_99){
var out="";
for(var i=0;i<_98;i++){
out+=str;
if(_99&&i<_98-1){
out+=_99;
}
}
return out;
};
dojo.string.pad=function(str,len,c,dir){
var out=String(str);
if(!c){
c="0";
}
if(!dir){
dir=1;
}
while(out.length<len){
if(dir>0){
out=c+out;
}else{
out+=c;
}
}
return out;
};
dojo.string.padLeft=function(str,len,c){
return dojo.string.pad(str,len,c,1);
};
dojo.string.padRight=function(str,len,c){
return dojo.string.pad(str,len,c,-1);
};
dojo.provide("dojo.string");
dojo.require("dojo.string.common");
dojo.provide("dojo.lang.common");
dojo.require("dojo.lang");
dojo.lang.mixin=function(obj,_a8){
var _a9={};
for(var x in _a8){
if(typeof _a9[x]=="undefined"||_a9[x]!=_a8[x]){
obj[x]=_a8[x];
}
}
if(dojo.render.html.ie&&dojo.lang.isFunction(_a8["toString"])&&_a8["toString"]!=obj["toString"]){
obj.toString=_a8.toString;
}
return obj;
};
dojo.lang.extend=function(_ab,_ac){
this.mixin(_ab.prototype,_ac);
};
dojo.lang.find=function(arr,val,_af,_b0){
if(!dojo.lang.isArrayLike(arr)&&dojo.lang.isArrayLike(val)){
var a=arr;
arr=val;
val=a;
}
var _b2=dojo.lang.isString(arr);
if(_b2){
arr=arr.split("");
}
if(_b0){
var _b3=-1;
var i=arr.length-1;
var end=-1;
}else{
var _b3=1;
var i=0;
var end=arr.length;
}
if(_af){
while(i!=end){
if(arr[i]===val){
return i;
}
i+=_b3;
}
}else{
while(i!=end){
if(arr[i]==val){
return i;
}
i+=_b3;
}
}
return -1;
};
dojo.lang.indexOf=dojo.lang.find;
dojo.lang.findLast=function(arr,val,_b8){
return dojo.lang.find(arr,val,_b8,true);
};
dojo.lang.lastIndexOf=dojo.lang.findLast;
dojo.lang.inArray=function(arr,val){
return dojo.lang.find(arr,val)>-1;
};
dojo.lang.isObject=function(wh){
return typeof wh=="object"||dojo.lang.isArray(wh)||dojo.lang.isFunction(wh);
};
dojo.lang.isArray=function(wh){
return (wh instanceof Array||typeof wh=="array");
};
dojo.lang.isArrayLike=function(wh){
if(dojo.lang.isString(wh)){
return false;
}
if(dojo.lang.isFunction(wh)){
return false;
}
if(dojo.lang.isArray(wh)){
return true;
}
if(typeof wh!="undefined"&&wh&&dojo.lang.isNumber(wh.length)&&isFinite(wh.length)){
return true;
}
return false;
};
dojo.lang.isFunction=function(wh){
return (wh instanceof Function||typeof wh=="function");
};
dojo.lang.isString=function(wh){
return (wh instanceof String||typeof wh=="string");
};
dojo.lang.isAlien=function(wh){
return !dojo.lang.isFunction()&&/\{\s*\[native code\]\s*\}/.test(String(wh));
};
dojo.lang.isBoolean=function(wh){
return (wh instanceof Boolean||typeof wh=="boolean");
};
dojo.lang.isNumber=function(wh){
return (wh instanceof Number||typeof wh=="number");
};
dojo.lang.isUndefined=function(wh){
return ((wh==undefined)&&(typeof wh=="undefined"));
};
dojo.provide("dojo.lang.extras");
dojo.require("dojo.lang.common");
dojo.lang.setTimeout=function(_c4,_c5){
var _c6=window,argsStart=2;
if(!dojo.lang.isFunction(_c4)){
_c6=_c4;
_c4=_c5;
_c5=arguments[2];
argsStart++;
}
if(dojo.lang.isString(_c4)){
_c4=_c6[_c4];
}
var _c7=[];
for(var i=argsStart;i<arguments.length;i++){
_c7.push(arguments[i]);
}
return setTimeout(function(){
_c4.apply(_c6,_c7);
},_c5);
};
dojo.lang.getNameInObj=function(ns,_ca){
if(!ns){
ns=dj_global;
}
for(var x in ns){
if(ns[x]===_ca){
return new String(x);
}
}
return null;
};
dojo.lang.shallowCopy=function(obj){
var ret={},key;
for(key in obj){
if(dojo.lang.isUndefined(ret[key])){
ret[key]=obj[key];
}
}
return ret;
};
dojo.lang.firstValued=function(){
for(var i=0;i<arguments.length;i++){
if(typeof arguments[i]!="undefined"){
return arguments[i];
}
}
return undefined;
};
dojo.lang.getObjPathValue=function(_cf,_d0,_d1){
with(dojo.parseObjPath(_cf,_d0,_d1)){
return dojo.evalProp(prop,obj,_d1);
}
};
dojo.lang.setObjPathValue=function(_d2,_d3,_d4,_d5){
if(arguments.length<4){
_d5=true;
}
with(dojo.parseObjPath(_d2,_d4,_d5)){
if(obj&&(_d5||(prop in obj))){
obj[prop]=_d3;
}
}
};
dojo.provide("dojo.io.IO");
dojo.require("dojo.string");
dojo.require("dojo.lang.extras");
dojo.io.transports=[];
dojo.io.hdlrFuncNames=["load","error","timeout"];
dojo.io.Request=function(url,_d7,_d8,_d9){
if((arguments.length==1)&&(arguments[0].constructor==Object)){
this.fromKwArgs(arguments[0]);
}else{
this.url=url;
if(_d7){
this.mimetype=_d7;
}
if(_d8){
this.transport=_d8;
}
if(arguments.length>=4){
this.changeUrl=_d9;
}
}
};
dojo.lang.extend(dojo.io.Request,{url:"",mimetype:"text/plain",method:"GET",content:undefined,transport:undefined,changeUrl:undefined,formNode:undefined,sync:false,bindSuccess:false,useCache:false,preventCache:false,load:function(_da,_db,evt){
},error:function(_dd,_de){
},timeout:function(_df){
},handle:function(){
},timeoutSeconds:0,abort:function(){
},fromKwArgs:function(_e0){
if(_e0["url"]){
_e0.url=_e0.url.toString();
}
if(_e0["formNode"]){
_e0.formNode=dojo.byId(_e0.formNode);
}
if(!_e0["method"]&&_e0["formNode"]&&_e0["formNode"].method){
_e0.method=_e0["formNode"].method;
}
if(!_e0["handle"]&&_e0["handler"]){
_e0.handle=_e0.handler;
}
if(!_e0["load"]&&_e0["loaded"]){
_e0.load=_e0.loaded;
}
if(!_e0["changeUrl"]&&_e0["changeURL"]){
_e0.changeUrl=_e0.changeURL;
}
_e0.encoding=dojo.lang.firstValued(_e0["encoding"],djConfig["bindEncoding"],"");
_e0.sendTransport=dojo.lang.firstValued(_e0["sendTransport"],djConfig["ioSendTransport"],false);
var _e1=dojo.lang.isFunction;
for(var x=0;x<dojo.io.hdlrFuncNames.length;x++){
var fn=dojo.io.hdlrFuncNames[x];
if(_e1(_e0[fn])){
continue;
}
if(_e1(_e0["handle"])){
_e0[fn]=_e0.handle;
}
}
dojo.lang.mixin(this,_e0);
}});
dojo.io.Error=function(msg,_e5,num){
this.message=msg;
this.type=_e5||"unknown";
this.number=num||0;
};
dojo.io.transports.addTransport=function(_e7){
this.push(_e7);
this[_e7]=dojo.io[_e7];
};
dojo.io.bind=function(_e8){
if(!(_e8 instanceof dojo.io.Request)){
try{
_e8=new dojo.io.Request(_e8);
}
catch(e){
dojo.debug(e);
}
}
var _e9="";
if(_e8["transport"]){
_e9=_e8["transport"];
if(!this[_e9]){
return _e8;
}
}else{
for(var x=0;x<dojo.io.transports.length;x++){
var tmp=dojo.io.transports[x];
if((this[tmp])&&(this[tmp].canHandle(_e8))){
_e9=tmp;
}
}
if(_e9==""){
return _e8;
}
}
this[_e9].bind(_e8);
_e8.bindSuccess=true;
return _e8;
};
dojo.io.queueBind=function(_ec){
if(!(_ec instanceof dojo.io.Request)){
try{
_ec=new dojo.io.Request(_ec);
}
catch(e){
dojo.debug(e);
}
}
var _ed=_ec.load;
_ec.load=function(){
dojo.io._queueBindInFlight=false;
var ret=_ed.apply(this,arguments);
dojo.io._dispatchNextQueueBind();
return ret;
};
var _ef=_ec.error;
_ec.error=function(){
dojo.io._queueBindInFlight=false;
var ret=_ef.apply(this,arguments);
dojo.io._dispatchNextQueueBind();
return ret;
};
dojo.io._bindQueue.push(_ec);
dojo.io._dispatchNextQueueBind();
return _ec;
};
dojo.io._dispatchNextQueueBind=function(){
if(!dojo.io._queueBindInFlight){
dojo.io._queueBindInFlight=true;
if(dojo.io._bindQueue.length>0){
dojo.io.bind(dojo.io._bindQueue.shift());
}else{
dojo.io._queueBindInFlight=false;
}
}
};
dojo.io._bindQueue=[];
dojo.io._queueBindInFlight=false;
dojo.io.argsFromMap=function(map,_f2,_f3){
var enc=/utf/i.test(_f2||"")?encodeURIComponent:dojo.string.encodeAscii;
var _f5=[];
var _f6=new Object();
for(var _f7 in map){
var _f8=function(elt){
var val=enc(_f7)+"="+enc(elt);
_f5[(_f3==_f7)?"push":"unshift"](val);
};
if(!_f6[_f7]){
var _fb=map[_f7];
if(dojo.lang.isArray(_fb)){
dojo.lang.forEach(_fb,_f8);
}else{
_f8(_fb);
}
}
}
return _f5.join("&");
};
dojo.io.setIFrameSrc=function(_fc,src,_fe){
try{
var r=dojo.render.html;
if(!_fe){
if(r.safari){
_fc.location=src;
}else{
frames[_fc.name].location=src;
}
}else{
var idoc;
if(r.ie){
idoc=_fc.contentWindow.document;
}else{
if(r.safari){
idoc=_fc.document;
}else{
idoc=_fc.contentWindow;
}
}
idoc.location.replace(src);
}
}
catch(e){
dojo.debug(e);
dojo.debug("setIFrameSrc: "+e);
}
};
dojo.provide("dojo.lang.array");
dojo.require("dojo.lang.common");
dojo.lang.has=function(obj,name){
try{
return (typeof obj[name]!="undefined");
}
catch(e){
return false;
}
};
dojo.lang.isEmpty=function(obj){
if(dojo.lang.isObject(obj)){
var tmp={};
var _105=0;
for(var x in obj){
if(obj[x]&&(!tmp[x])){
_105++;
break;
}
}
return (_105==0);
}else{
if(dojo.lang.isArrayLike(obj)||dojo.lang.isString(obj)){
return obj.length==0;
}
}
};
dojo.lang.map=function(arr,obj,_109){
var _10a=dojo.lang.isString(arr);
if(_10a){
arr=arr.split("");
}
if(dojo.lang.isFunction(obj)&&(!_109)){
_109=obj;
obj=dj_global;
}else{
if(dojo.lang.isFunction(obj)&&_109){
var _10b=obj;
obj=_109;
_109=_10b;
}
}
if(Array.map){
var _10c=Array.map(arr,_109,obj);
}else{
var _10c=[];
for(var i=0;i<arr.length;++i){
_10c.push(_109.call(obj,arr[i]));
}
}
if(_10a){
return _10c.join("");
}else{
return _10c;
}
};
dojo.lang.forEach=function(_10e,_10f,_110){
if(dojo.lang.isString(_10e)){
_10e=_10e.split("");
}
if(Array.forEach){
Array.forEach(_10e,_10f,_110);
}else{
if(!_110){
_110=dj_global;
}
for(var i=0,l=_10e.length;i<l;i++){
_10f.call(_110,_10e[i],i,_10e);
}
}
};
dojo.lang._everyOrSome=function(_112,arr,_114,_115){
if(dojo.lang.isString(arr)){
arr=arr.split("");
}
if(Array.every){
return Array[(_112)?"every":"some"](arr,_114,_115);
}else{
if(!_115){
_115=dj_global;
}
for(var i=0,l=arr.length;i<l;i++){
var _117=_114.call(_115,arr[i],i,arr);
if((_112)&&(!_117)){
return false;
}else{
if((!_112)&&(_117)){
return true;
}
}
}
return (_112)?true:false;
}
};
dojo.lang.every=function(arr,_119,_11a){
return this._everyOrSome(true,arr,_119,_11a);
};
dojo.lang.some=function(arr,_11c,_11d){
return this._everyOrSome(false,arr,_11c,_11d);
};
dojo.lang.filter=function(arr,_11f,_120){
var _121=dojo.lang.isString(arr);
if(_121){
arr=arr.split("");
}
if(Array.filter){
var _122=Array.filter(arr,_11f,_120);
}else{
if(!_120){
if(arguments.length>=3){
dojo.raise("thisObject doesn't exist!");
}
_120=dj_global;
}
var _122=[];
for(var i=0;i<arr.length;i++){
if(_11f.call(_120,arr[i],i,arr)){
_122.push(arr[i]);
}
}
}
if(_121){
return _122.join("");
}else{
return _122;
}
};
dojo.lang.unnest=function(){
var out=[];
for(var i=0;i<arguments.length;i++){
if(dojo.lang.isArrayLike(arguments[i])){
var add=dojo.lang.unnest.apply(this,arguments[i]);
out=out.concat(add);
}else{
out.push(arguments[i]);
}
}
return out;
};
dojo.lang.toArray=function(_127,_128){
var _129=[];
for(var i=_128||0;i<_127.length;i++){
_129.push(_127[i]);
}
return _129;
};
dojo.provide("dojo.lang.func");
dojo.require("dojo.lang.common");
dojo.lang.hitch=function(_12b,_12c){
if(dojo.lang.isString(_12c)){
var fcn=_12b[_12c];
}else{
var fcn=_12c;
}
return function(){
return fcn.apply(_12b,arguments);
};
};
dojo.lang.anonCtr=0;
dojo.lang.anon={};
dojo.lang.nameAnonFunc=function(_12e,_12f){
var nso=(_12f||dojo.lang.anon);
if((dj_global["djConfig"])&&(djConfig["slowAnonFuncLookups"]==true)){
for(var x in nso){
if(nso[x]===_12e){
return x;
}
}
}
var ret="__"+dojo.lang.anonCtr++;
while(typeof nso[ret]!="undefined"){
ret="__"+dojo.lang.anonCtr++;
}
nso[ret]=_12e;
return ret;
};
dojo.lang.forward=function(_133){
return function(){
return this[_133].apply(this,arguments);
};
};
dojo.lang.curry=function(ns,func){
var _136=[];
ns=ns||dj_global;
if(dojo.lang.isString(func)){
func=ns[func];
}
for(var x=2;x<arguments.length;x++){
_136.push(arguments[x]);
}
var _138=(func["__preJoinArity"]||func.length)-_136.length;
function gather(_139,_13a,_13b){
var _13c=_13b;
var _13d=_13a.slice(0);
for(var x=0;x<_139.length;x++){
_13d.push(_139[x]);
}
_13b=_13b-_139.length;
if(_13b<=0){
var res=func.apply(ns,_13d);
_13b=_13c;
return res;
}else{
return function(){
return gather(arguments,_13d,_13b);
};
}
}
return gather([],_136,_138);
};
dojo.lang.curryArguments=function(ns,func,args,_143){
var _144=[];
var x=_143||0;
for(x=_143;x<args.length;x++){
_144.push(args[x]);
}
return dojo.lang.curry.apply(dojo.lang,[ns,func].concat(_144));
};
dojo.lang.tryThese=function(){
for(var x=0;x<arguments.length;x++){
try{
if(typeof arguments[x]=="function"){
var ret=(arguments[x]());
if(ret){
return ret;
}
}
}
catch(e){
dojo.debug(e);
}
}
};
dojo.lang.delayThese=function(farr,cb,_14a,_14b){
if(!farr.length){
if(typeof _14b=="function"){
_14b();
}
return;
}
if((typeof _14a=="undefined")&&(typeof cb=="number")){
_14a=cb;
cb=function(){
};
}else{
if(!cb){
cb=function(){
};
if(!_14a){
_14a=0;
}
}
}
setTimeout(function(){
(farr.shift())();
cb();
dojo.lang.delayThese(farr,cb,_14a,_14b);
},_14a);
};
dojo.provide("dojo.string.extras");
dojo.require("dojo.string.common");
dojo.require("dojo.lang");
dojo.string.paramString=function(str,_14d,_14e){
for(var name in _14d){
var re=new RegExp("\\%\\{"+name+"\\}","g");
str=str.replace(re,_14d[name]);
}
if(_14e){
str=str.replace(/%\{([^\}\s]+)\}/g,"");
}
return str;
};
dojo.string.capitalize=function(str){
if(!dojo.lang.isString(str)){
return "";
}
if(arguments.length==0){
str=this;
}
var _152=str.split(" ");
var _153="";
var len=_152.length;
for(var i=0;i<len;i++){
var word=_152[i];
word=word.charAt(0).toUpperCase()+word.substring(1,word.length);
_153+=word;
if(i<len-1){
_153+=" ";
}
}
return new String(_153);
};
dojo.string.isBlank=function(str){
if(!dojo.lang.isString(str)){
return true;
}
return (dojo.string.trim(str).length==0);
};
dojo.string.encodeAscii=function(str){
if(!dojo.lang.isString(str)){
return str;
}
var ret="";
var _15a=escape(str);
var _15b,re=/%u([0-9A-F]{4})/i;
while((_15b=_15a.match(re))){
var num=Number("0x"+_15b[1]);
var _15d=escape("&#"+num+";");
ret+=_15a.substring(0,_15b.index)+_15d;
_15a=_15a.substring(_15b.index+_15b[0].length);
}
ret+=_15a.replace(/\+/g,"%2B");
return ret;
};
dojo.string.escape=function(type,str){
var args=[];
for(var i=1;i<arguments.length;i++){
args.push(arguments[i]);
}
switch(type.toLowerCase()){
case "xml":
case "html":
case "xhtml":
return dojo.string.escapeXml.apply(this,args);
case "sql":
return dojo.string.escapeSql.apply(this,args);
case "regexp":
case "regex":
return dojo.string.escapeRegExp.apply(this,args);
case "javascript":
case "jscript":
case "js":
return dojo.string.escapeJavaScript.apply(this,args);
case "ascii":
return dojo.string.encodeAscii.apply(this,args);
default:
return str;
}
};
dojo.string.escapeXml=function(str,_163){
str=str.replace(/&/gm,"&amp;").replace(/</gm,"&lt;").replace(/>/gm,"&gt;").replace(/"/gm,"&quot;");
if(!_163){
str=str.replace(/'/gm,"&#39;");
}
return str;
};
dojo.string.escapeSql=function(str){
return str.replace(/'/gm,"''");
};
dojo.string.escapeRegExp=function(str){
return str.replace(/\\/gm,"\\\\").replace(/([\f\b\n\t\r[\^$|?*+(){}])/gm,"\\$1");
};
dojo.string.escapeJavaScript=function(str){
return str.replace(/(["'\f\b\n\t\r])/gm,"\\$1");
};
dojo.string.escapeString=function(str){
return ("\""+str.replace(/(["\\])/g,"\\$1")+"\"").replace(/[\f]/g,"\\f").replace(/[\b]/g,"\\b").replace(/[\n]/g,"\\n").replace(/[\t]/g,"\\t").replace(/[\r]/g,"\\r");
};
dojo.string.summary=function(str,len){
if(!len||str.length<=len){
return str;
}else{
return str.substring(0,len).replace(/\.+$/,"")+"...";
}
};
dojo.string.endsWith=function(str,end,_16c){
if(_16c){
str=str.toLowerCase();
end=end.toLowerCase();
}
if((str.length-end.length)<0){
return false;
}
return str.lastIndexOf(end)==str.length-end.length;
};
dojo.string.endsWithAny=function(str){
for(var i=1;i<arguments.length;i++){
if(dojo.string.endsWith(str,arguments[i])){
return true;
}
}
return false;
};
dojo.string.startsWith=function(str,_170,_171){
if(_171){
str=str.toLowerCase();
_170=_170.toLowerCase();
}
return str.indexOf(_170)==0;
};
dojo.string.startsWithAny=function(str){
for(var i=1;i<arguments.length;i++){
if(dojo.string.startsWith(str,arguments[i])){
return true;
}
}
return false;
};
dojo.string.has=function(str){
for(var i=1;i<arguments.length;i++){
if(str.indexOf(arguments[i])>-1){
return true;
}
}
return false;
};
dojo.string.normalizeNewlines=function(text,_177){
if(_177=="\n"){
text=text.replace(/\r\n/g,"\n");
text=text.replace(/\r/g,"\n");
}else{
if(_177=="\r"){
text=text.replace(/\r\n/g,"\r");
text=text.replace(/\n/g,"\r");
}else{
text=text.replace(/([^\r])\n/g,"$1\r\n");
text=text.replace(/\r([^\n])/g,"\r\n$1");
}
}
return text;
};
dojo.string.splitEscaped=function(str,_179){
var _17a=[];
for(var i=0,prevcomma=0;i<str.length;i++){
if(str.charAt(i)=="\\"){
i++;
continue;
}
if(str.charAt(i)==_179){
_17a.push(str.substring(prevcomma,i));
prevcomma=i+1;
}
}
_17a.push(str.substr(prevcomma));
return _17a;
};
dojo.provide("dojo.dom");
dojo.require("dojo.lang.array");
dojo.dom.ELEMENT_NODE=1;
dojo.dom.ATTRIBUTE_NODE=2;
dojo.dom.TEXT_NODE=3;
dojo.dom.CDATA_SECTION_NODE=4;
dojo.dom.ENTITY_REFERENCE_NODE=5;
dojo.dom.ENTITY_NODE=6;
dojo.dom.PROCESSING_INSTRUCTION_NODE=7;
dojo.dom.COMMENT_NODE=8;
dojo.dom.DOCUMENT_NODE=9;
dojo.dom.DOCUMENT_TYPE_NODE=10;
dojo.dom.DOCUMENT_FRAGMENT_NODE=11;
dojo.dom.NOTATION_NODE=12;
dojo.dom.dojoml="http://www.dojotoolkit.org/2004/dojoml";
dojo.dom.xmlns={svg:"http://www.w3.org/2000/svg",smil:"http://www.w3.org/2001/SMIL20/",mml:"http://www.w3.org/1998/Math/MathML",cml:"http://www.xml-cml.org",xlink:"http://www.w3.org/1999/xlink",xhtml:"http://www.w3.org/1999/xhtml",xul:"http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul",xbl:"http://www.mozilla.org/xbl",fo:"http://www.w3.org/1999/XSL/Format",xsl:"http://www.w3.org/1999/XSL/Transform",xslt:"http://www.w3.org/1999/XSL/Transform",xi:"http://www.w3.org/2001/XInclude",xforms:"http://www.w3.org/2002/01/xforms",saxon:"http://icl.com/saxon",xalan:"http://xml.apache.org/xslt",xsd:"http://www.w3.org/2001/XMLSchema",dt:"http://www.w3.org/2001/XMLSchema-datatypes",xsi:"http://www.w3.org/2001/XMLSchema-instance",rdf:"http://www.w3.org/1999/02/22-rdf-syntax-ns#",rdfs:"http://www.w3.org/2000/01/rdf-schema#",dc:"http://purl.org/dc/elements/1.1/",dcq:"http://purl.org/dc/qualifiers/1.0","soap-env":"http://schemas.xmlsoap.org/soap/envelope/",wsdl:"http://schemas.xmlsoap.org/wsdl/",AdobeExtensions:"http://ns.adobe.com/AdobeSVGViewerExtensions/3.0/"};
dojo.dom.isNode=function(wh){
if(typeof Element=="object"){
try{
return wh instanceof Element;
}
catch(E){
}
}else{
return wh&&!isNaN(wh.nodeType);
}
};
dojo.dom.getTagName=function(node){
dojo.deprecated("dojo.dom.getTagName","use node.tagName instead","0.4");
var _17e=node.tagName;
if(_17e.substr(0,5).toLowerCase()!="dojo:"){
if(_17e.substr(0,4).toLowerCase()=="dojo"){
return "dojo:"+_17e.substring(4).toLowerCase();
}
var djt=node.getAttribute("dojoType")||node.getAttribute("dojotype");
if(djt){
return "dojo:"+djt.toLowerCase();
}
if((node.getAttributeNS)&&(node.getAttributeNS(this.dojoml,"type"))){
return "dojo:"+node.getAttributeNS(this.dojoml,"type").toLowerCase();
}
try{
djt=node.getAttribute("dojo:type");
}
catch(e){
}
if(djt){
return "dojo:"+djt.toLowerCase();
}
if((!dj_global["djConfig"])||(!djConfig["ignoreClassNames"])){
var _180=node.className||node.getAttribute("class");
if((_180)&&(_180.indexOf)&&(_180.indexOf("dojo-")!=-1)){
var _181=_180.split(" ");
for(var x=0;x<_181.length;x++){
if((_181[x].length>5)&&(_181[x].indexOf("dojo-")>=0)){
return "dojo:"+_181[x].substr(5).toLowerCase();
}
}
}
}
}
return _17e.toLowerCase();
};
dojo.dom.getUniqueId=function(){
do{
var id="dj_unique_"+(++arguments.callee._idIncrement);
}while(document.getElementById(id));
return id;
};
dojo.dom.getUniqueId._idIncrement=0;
dojo.dom.firstElement=dojo.dom.getFirstChildElement=function(_184,_185){
var node=_184.firstChild;
while(node&&node.nodeType!=dojo.dom.ELEMENT_NODE){
node=node.nextSibling;
}
if(_185&&node&&node.tagName&&node.tagName.toLowerCase()!=_185.toLowerCase()){
node=dojo.dom.nextElement(node,_185);
}
return node;
};
dojo.dom.lastElement=dojo.dom.getLastChildElement=function(_187,_188){
var node=_187.lastChild;
while(node&&node.nodeType!=dojo.dom.ELEMENT_NODE){
node=node.previousSibling;
}
if(_188&&node&&node.tagName&&node.tagName.toLowerCase()!=_188.toLowerCase()){
node=dojo.dom.prevElement(node,_188);
}
return node;
};
dojo.dom.nextElement=dojo.dom.getNextSiblingElement=function(node,_18b){
if(!node){
return null;
}
do{
node=node.nextSibling;
}while(node&&node.nodeType!=dojo.dom.ELEMENT_NODE);
if(node&&_18b&&_18b.toLowerCase()!=node.tagName.toLowerCase()){
return dojo.dom.nextElement(node,_18b);
}
return node;
};
dojo.dom.prevElement=dojo.dom.getPreviousSiblingElement=function(node,_18d){
if(!node){
return null;
}
if(_18d){
_18d=_18d.toLowerCase();
}
do{
node=node.previousSibling;
}while(node&&node.nodeType!=dojo.dom.ELEMENT_NODE);
if(node&&_18d&&_18d.toLowerCase()!=node.tagName.toLowerCase()){
return dojo.dom.prevElement(node,_18d);
}
return node;
};
dojo.dom.moveChildren=function(_18e,_18f,trim){
var _191=0;
if(trim){
while(_18e.hasChildNodes()&&_18e.firstChild.nodeType==dojo.dom.TEXT_NODE){
_18e.removeChild(_18e.firstChild);
}
while(_18e.hasChildNodes()&&_18e.lastChild.nodeType==dojo.dom.TEXT_NODE){
_18e.removeChild(_18e.lastChild);
}
}
while(_18e.hasChildNodes()){
_18f.appendChild(_18e.firstChild);
_191++;
}
return _191;
};
dojo.dom.copyChildren=function(_192,_193,trim){
var _195=_192.cloneNode(true);
return this.moveChildren(_195,_193,trim);
};
dojo.dom.removeChildren=function(node){
var _197=node.childNodes.length;
while(node.hasChildNodes()){
node.removeChild(node.firstChild);
}
return _197;
};
dojo.dom.replaceChildren=function(node,_199){
dojo.dom.removeChildren(node);
node.appendChild(_199);
};
dojo.dom.removeNode=function(node){
if(node&&node.parentNode){
return node.parentNode.removeChild(node);
}
};
dojo.dom.getAncestors=function(node,_19c,_19d){
var _19e=[];
var _19f=dojo.lang.isFunction(_19c);
while(node){
if(!_19f||_19c(node)){
_19e.push(node);
}
if(_19d&&_19e.length>0){
return _19e[0];
}
node=node.parentNode;
}
if(_19d){
return null;
}
return _19e;
};
dojo.dom.getAncestorsByTag=function(node,tag,_1a2){
tag=tag.toLowerCase();
return dojo.dom.getAncestors(node,function(el){
return ((el.tagName)&&(el.tagName.toLowerCase()==tag));
},_1a2);
};
dojo.dom.getFirstAncestorByTag=function(node,tag){
return dojo.dom.getAncestorsByTag(node,tag,true);
};
dojo.dom.isDescendantOf=function(node,_1a7,_1a8){
if(_1a8&&node){
node=node.parentNode;
}
while(node){
if(node==_1a7){
return true;
}
node=node.parentNode;
}
return false;
};
dojo.dom.innerXML=function(node){
if(node.innerXML){
return node.innerXML;
}else{
if(typeof XMLSerializer!="undefined"){
return (new XMLSerializer()).serializeToString(node);
}
}
};
dojo.dom.createDocumentFromText=function(str,_1ab){
if(!_1ab){
_1ab="text/xml";
}
if(typeof DOMParser!="undefined"){
var _1ac=new DOMParser();
return _1ac.parseFromString(str,_1ab);
}else{
if(typeof ActiveXObject!="undefined"){
var _1ad=new ActiveXObject("Microsoft.XMLDOM");
if(_1ad){
_1ad.async=false;
_1ad.loadXML(str);
return _1ad;
}else{
dojo.debug("toXml didn't work?");
}
}else{
if(document.createElement){
var tmp=document.createElement("xml");
tmp.innerHTML=str;
if(document.implementation&&document.implementation.createDocument){
var _1af=document.implementation.createDocument("foo","",null);
for(var i=0;i<tmp.childNodes.length;i++){
_1af.importNode(tmp.childNodes.item(i),true);
}
return _1af;
}
return tmp.document&&tmp.document.firstChild?tmp.document.firstChild:tmp;
}
}
}
return null;
};
dojo.dom.prependChild=function(node,_1b2){
if(_1b2.firstChild){
_1b2.insertBefore(node,_1b2.firstChild);
}else{
_1b2.appendChild(node);
}
return true;
};
dojo.dom.insertBefore=function(node,ref,_1b5){
if(_1b5!=true&&(node===ref||node.nextSibling===ref)){
return false;
}
var _1b6=ref.parentNode;
_1b6.insertBefore(node,ref);
return true;
};
dojo.dom.insertAfter=function(node,ref,_1b9){
var pn=ref.parentNode;
if(ref==pn.lastChild){
if((_1b9!=true)&&(node===ref)){
return false;
}
pn.appendChild(node);
}else{
return this.insertBefore(node,ref.nextSibling,_1b9);
}
return true;
};
dojo.dom.insertAtPosition=function(node,ref,_1bd){
if((!node)||(!ref)||(!_1bd)){
return false;
}
switch(_1bd.toLowerCase()){
case "before":
return dojo.dom.insertBefore(node,ref);
case "after":
return dojo.dom.insertAfter(node,ref);
case "first":
if(ref.firstChild){
return dojo.dom.insertBefore(node,ref.firstChild);
}else{
ref.appendChild(node);
return true;
}
break;
default:
ref.appendChild(node);
return true;
}
};
dojo.dom.insertAtIndex=function(node,_1bf,_1c0){
var _1c1=_1bf.childNodes;
if(!_1c1.length){
_1bf.appendChild(node);
return true;
}
var _1c2=null;
for(var i=0;i<_1c1.length;i++){
var _1c4=_1c1.item(i)["getAttribute"]?parseInt(_1c1.item(i).getAttribute("dojoinsertionindex")):-1;
if(_1c4<_1c0){
_1c2=_1c1.item(i);
}
}
if(_1c2){
return dojo.dom.insertAfter(node,_1c2);
}else{
return dojo.dom.insertBefore(node,_1c1.item(0));
}
};
dojo.dom.textContent=function(node,text){
if(text){
dojo.dom.replaceChildren(node,document.createTextNode(text));
return text;
}else{
var _1c7="";
if(node==null){
return _1c7;
}
for(var i=0;i<node.childNodes.length;i++){
switch(node.childNodes[i].nodeType){
case 1:
case 5:
_1c7+=dojo.dom.textContent(node.childNodes[i]);
break;
case 3:
case 2:
case 4:
_1c7+=node.childNodes[i].nodeValue;
break;
default:
break;
}
}
return _1c7;
}
};
dojo.dom.collectionToArray=function(_1c9){
dojo.deprecated("dojo.dom.collectionToArray","use dojo.lang.toArray instead","0.4");
return dojo.lang.toArray(_1c9);
};
dojo.dom.hasParent=function(node){
return node&&node.parentNode&&dojo.dom.isNode(node.parentNode);
};
dojo.dom.isTag=function(node){
if(node&&node.tagName){
var arr=dojo.lang.toArray(arguments,1);
return arr[dojo.lang.find(node.tagName,arr)]||"";
}
return "";
};
dojo.provide("dojo.undo.browser");
dojo.require("dojo.io");
try{
if((!djConfig["preventBackButtonFix"])&&(!dojo.hostenv.post_load_)){
document.write("<iframe style='border: 0px; width: 1px; height: 1px; position: absolute; bottom: 0px; right: 0px; visibility: visible;' name='djhistory' id='djhistory' src='"+(dojo.hostenv.getBaseScriptUri()+"iframe_history.html")+"'></iframe>");
}
}
catch(e){
}
dojo.undo.browser={initialHref:window.location.href,initialHash:window.location.hash,moveForward:false,historyStack:[],forwardStack:[],historyIframe:null,bookmarkAnchor:null,locationTimer:null,setInitialState:function(args){
this.initialState={"url":this.initialHref,"kwArgs":args,"urlHash":this.initialHash};
},addToHistory:function(args){
var hash=null;
if(!this.historyIframe){
this.historyIframe=window.frames["djhistory"];
}
if(!this.bookmarkAnchor){
this.bookmarkAnchor=document.createElement("a");
(document.body||document.getElementsByTagName("body")[0]).appendChild(this.bookmarkAnchor);
this.bookmarkAnchor.style.display="none";
}
if((!args["changeUrl"])||(dojo.render.html.ie)){
var url=dojo.hostenv.getBaseScriptUri()+"iframe_history.html?"+(new Date()).getTime();
this.moveForward=true;
dojo.io.setIFrameSrc(this.historyIframe,url,false);
}
if(args["changeUrl"]){
this.changingUrl=true;
hash="#"+((args["changeUrl"]!==true)?args["changeUrl"]:(new Date()).getTime());
setTimeout("window.location.href = '"+hash+"'; dojo.undo.browser.changingUrl = false;",1);
this.bookmarkAnchor.href=hash;
if(dojo.render.html.ie){
var _1d1=args["back"]||args["backButton"]||args["handle"];
var tcb=function(_1d3){
if(window.location.hash!=""){
setTimeout("window.location.href = '"+hash+"';",1);
}
_1d1.apply(this,[_1d3]);
};
if(args["back"]){
args.back=tcb;
}else{
if(args["backButton"]){
args.backButton=tcb;
}else{
if(args["handle"]){
args.handle=tcb;
}
}
}
this.forwardStack=[];
var _1d4=args["forward"]||args["forwardButton"]||args["handle"];
var tfw=function(_1d6){
if(window.location.hash!=""){
window.location.href=hash;
}
if(_1d4){
_1d4.apply(this,[_1d6]);
}
};
if(args["forward"]){
args.forward=tfw;
}else{
if(args["forwardButton"]){
args.forwardButton=tfw;
}else{
if(args["handle"]){
args.handle=tfw;
}
}
}
}else{
if(dojo.render.html.moz){
if(!this.locationTimer){
this.locationTimer=setInterval("dojo.undo.browser.checkLocation();",200);
}
}
}
}
this.historyStack.push({"url":url,"kwArgs":args,"urlHash":hash});
},checkLocation:function(){
if(!this.changingUrl){
var hsl=this.historyStack.length;
if((window.location.hash==this.initialHash)||(window.location.href==this.initialHref)&&(hsl==1)){
this.handleBackButton();
return;
}
if(this.forwardStack.length>0){
if(this.forwardStack[this.forwardStack.length-1].urlHash==window.location.hash){
this.handleForwardButton();
return;
}
}
if((hsl>=2)&&(this.historyStack[hsl-2])){
if(this.historyStack[hsl-2].urlHash==window.location.hash){
this.handleBackButton();
return;
}
}
}
},iframeLoaded:function(evt,_1d9){
var _1da=this._getUrlQuery(_1d9.href);
if(_1da==null){
if(this.historyStack.length==1){
this.handleBackButton();
}
return;
}
if(this.moveForward){
this.moveForward=false;
return;
}
if(this.historyStack.length>=2&&_1da==this._getUrlQuery(this.historyStack[this.historyStack.length-2].url)){
this.handleBackButton();
}else{
if(this.forwardStack.length>0&&_1da==this._getUrlQuery(this.forwardStack[this.forwardStack.length-1].url)){
this.handleForwardButton();
}
}
},handleBackButton:function(){
var _1db=this.historyStack.pop();
if(!_1db){
return;
}
var last=this.historyStack[this.historyStack.length-1];
if(!last&&this.historyStack.length==0){
last=this.initialState;
}
if(last){
if(last.kwArgs["back"]){
last.kwArgs["back"]();
}else{
if(last.kwArgs["backButton"]){
last.kwArgs["backButton"]();
}else{
if(last.kwArgs["handle"]){
last.kwArgs.handle("back");
}
}
}
}
this.forwardStack.push(_1db);
},handleForwardButton:function(){
var last=this.forwardStack.pop();
if(!last){
return;
}
if(last.kwArgs["forward"]){
last.kwArgs.forward();
}else{
if(last.kwArgs["forwardButton"]){
last.kwArgs.forwardButton();
}else{
if(last.kwArgs["handle"]){
last.kwArgs.handle("forward");
}
}
}
this.historyStack.push(last);
},_getUrlQuery:function(url){
var _1df=url.split("?");
if(_1df.length<2){
return null;
}else{
return _1df[1];
}
}};
dojo.provide("dojo.io.BrowserIO");
dojo.require("dojo.io");
dojo.require("dojo.lang.array");
dojo.require("dojo.lang.func");
dojo.require("dojo.string.extras");
dojo.require("dojo.dom");
dojo.require("dojo.undo.browser");
dojo.io.checkChildrenForFile=function(node){
var _1e1=false;
var _1e2=node.getElementsByTagName("input");
dojo.lang.forEach(_1e2,function(_1e3){
if(_1e1){
return;
}
if(_1e3.getAttribute("type")=="file"){
_1e1=true;
}
});
return _1e1;
};
dojo.io.formHasFile=function(_1e4){
return dojo.io.checkChildrenForFile(_1e4);
};
dojo.io.updateNode=function(node,_1e6){
node=dojo.byId(node);
var args=_1e6;
if(dojo.lang.isString(_1e6)){
args={url:_1e6};
}
args.mimetype="text/html";
args.load=function(t,d,e){
while(node.firstChild){
if(dojo["event"]){
try{
dojo.event.browser.clean(node.firstChild);
}
catch(e){
}
}
node.removeChild(node.firstChild);
}
node.innerHTML=d;
};
dojo.io.bind(args);
};
dojo.io.formFilter=function(node){
var type=(node.type||"").toLowerCase();
return !node.disabled&&node.name&&!dojo.lang.inArray(type,["file","submit","image","reset","button"]);
};
dojo.io.encodeForm=function(_1ed,_1ee,_1ef){
if((!_1ed)||(!_1ed.tagName)||(!_1ed.tagName.toLowerCase()=="form")){
dojo.raise("Attempted to encode a non-form element.");
}
if(!_1ef){
_1ef=dojo.io.formFilter;
}
var enc=/utf/i.test(_1ee||"")?encodeURIComponent:dojo.string.encodeAscii;
var _1f1=[];
for(var i=0;i<_1ed.elements.length;i++){
var elm=_1ed.elements[i];
if(!elm||elm.tagName.toLowerCase()=="fieldset"||!_1ef(elm)){
continue;
}
var name=enc(elm.name);
var type=elm.type.toLowerCase();
if(type=="select-multiple"){
for(var j=0;j<elm.options.length;j++){
if(elm.options[j].selected){
_1f1.push(name+"="+enc(elm.options[j].value));
}
}
}else{
if(dojo.lang.inArray(type,["radio","checkbox"])){
if(elm.checked){
_1f1.push(name+"="+enc(elm.value));
}
}else{
_1f1.push(name+"="+enc(elm.value));
}
}
}
var _1f7=_1ed.getElementsByTagName("input");
for(var i=0;i<_1f7.length;i++){
var _1f8=_1f7[i];
if(_1f8.type.toLowerCase()=="image"&&_1f8.form==_1ed&&_1ef(_1f8)){
var name=enc(_1f8.name);
_1f1.push(name+"="+enc(_1f8.value));
_1f1.push(name+".x=0");
_1f1.push(name+".y=0");
}
}
return _1f1.join("&")+"&";
};
dojo.io.FormBind=function(args){
this.bindArgs={};
if(args&&args.formNode){
this.init(args);
}else{
if(args){
this.init({formNode:args});
}
}
};
dojo.lang.extend(dojo.io.FormBind,{form:null,bindArgs:null,clickedButton:null,init:function(args){
var form=dojo.byId(args.formNode);
if(!form||!form.tagName||form.tagName.toLowerCase()!="form"){
throw new Error("FormBind: Couldn't apply, invalid form");
}else{
if(this.form==form){
return;
}else{
if(this.form){
throw new Error("FormBind: Already applied to a form");
}
}
}
dojo.lang.mixin(this.bindArgs,args);
this.form=form;
this.connect(form,"onsubmit","submit");
for(var i=0;i<form.elements.length;i++){
var node=form.elements[i];
if(node&&node.type&&dojo.lang.inArray(node.type.toLowerCase(),["submit","button"])){
this.connect(node,"onclick","click");
}
}
var _1fe=form.getElementsByTagName("input");
for(var i=0;i<_1fe.length;i++){
var _1ff=_1fe[i];
if(_1ff.type.toLowerCase()=="image"&&_1ff.form==form){
this.connect(_1ff,"onclick","click");
}
}
},onSubmit:function(form){
return true;
},submit:function(e){
e.preventDefault();
if(this.onSubmit(this.form)){
dojo.io.bind(dojo.lang.mixin(this.bindArgs,{formFilter:dojo.lang.hitch(this,"formFilter")}));
}
},click:function(e){
var node=e.currentTarget;
if(node.disabled){
return;
}
this.clickedButton=node;
},formFilter:function(node){
var type=(node.type||"").toLowerCase();
var _206=false;
if(node.disabled||!node.name){
_206=false;
}else{
if(dojo.lang.inArray(type,["submit","button","image"])){
if(!this.clickedButton){
this.clickedButton=node;
}
_206=node==this.clickedButton;
}else{
_206=!dojo.lang.inArray(type,["file","submit","reset","button"]);
}
}
return _206;
},connect:function(_207,_208,_209){
if(dojo.evalObjPath("dojo.event.connect")){
dojo.event.connect(_207,_208,this,_209);
}else{
var fcn=dojo.lang.hitch(this,_209);
_207[_208]=function(e){
if(!e){
e=window.event;
}
if(!e.currentTarget){
e.currentTarget=e.srcElement;
}
if(!e.preventDefault){
e.preventDefault=function(){
window.event.returnValue=false;
};
}
fcn(e);
};
}
}});
dojo.io.XMLHTTPTransport=new function(){
var _20c=this;
var _20d={};
this.useCache=false;
this.preventCache=false;
function getCacheKey(url,_20f,_210){
return url+"|"+_20f+"|"+_210.toLowerCase();
}
function addToCache(url,_212,_213,http){
_20d[getCacheKey(url,_212,_213)]=http;
}
function getFromCache(url,_216,_217){
return _20d[getCacheKey(url,_216,_217)];
}
this.clearCache=function(){
_20d={};
};
function doLoad(_218,http,url,_21b,_21c){
if((http.status==200)||(http.status==304)||(http.status==204)||(location.protocol=="file:"&&(http.status==0||http.status==undefined))||(location.protocol=="chrome:"&&(http.status==0||http.status==undefined))){
var ret;
if(_218.method.toLowerCase()=="head"){
var _21e=http.getAllResponseHeaders();
ret={};
ret.toString=function(){
return _21e;
};
var _21f=_21e.split(/[\r\n]+/g);
for(var i=0;i<_21f.length;i++){
var pair=_21f[i].match(/^([^:]+)\s*:\s*(.+)$/i);
if(pair){
ret[pair[1]]=pair[2];
}
}
}else{
if(_218.mimetype=="text/javascript"){
try{
ret=dj_eval(http.responseText);
}
catch(e){
dojo.debug(e);
dojo.debug(http.responseText);
ret=null;
}
}else{
if(_218.mimetype=="text/json"){
try{
ret=dj_eval("("+http.responseText+")");
}
catch(e){
dojo.debug(e);
dojo.debug(http.responseText);
ret=false;
}
}else{
if((_218.mimetype=="application/xml")||(_218.mimetype=="text/xml")){
ret=http.responseXML;
if(!ret||typeof ret=="string"){
ret=dojo.dom.createDocumentFromText(http.responseText);
}
}else{
ret=http.responseText;
}
}
}
}
if(_21c){
addToCache(url,_21b,_218.method,http);
}
_218[(typeof _218.load=="function")?"load":"handle"]("load",ret,http,_218);
}else{
var _222=new dojo.io.Error("XMLHttpTransport Error: "+http.status+" "+http.statusText);
_218[(typeof _218.error=="function")?"error":"handle"]("error",_222,http,_218);
}
}
function setHeaders(http,_224){
if(_224["headers"]){
for(var _225 in _224["headers"]){
if(_225.toLowerCase()=="content-type"&&!_224["contentType"]){
_224["contentType"]=_224["headers"][_225];
}else{
http.setRequestHeader(_225,_224["headers"][_225]);
}
}
}
}
this.inFlight=[];
this.inFlightTimer=null;
this.startWatchingInFlight=function(){
if(!this.inFlightTimer){
this.inFlightTimer=setInterval("dojo.io.XMLHTTPTransport.watchInFlight();",10);
}
};
this.watchInFlight=function(){
var now=null;
for(var x=this.inFlight.length-1;x>=0;x--){
var tif=this.inFlight[x];
if(!tif){
this.inFlight.splice(x,1);
continue;
}
if(4==tif.http.readyState){
this.inFlight.splice(x,1);
doLoad(tif.req,tif.http,tif.url,tif.query,tif.useCache);
}else{
if(tif.startTime){
if(!now){
now=(new Date()).getTime();
}
if(tif.startTime+(tif.req.timeoutSeconds*1000)<now){
if(typeof tif.http.abort=="function"){
tif.http.abort();
}
this.inFlight.splice(x,1);
tif.req[(typeof tif.req.timeout=="function")?"timeout":"handle"]("timeout",null,tif.http,tif.req);
}
}
}
}
if(this.inFlight.length==0){
clearInterval(this.inFlightTimer);
this.inFlightTimer=null;
}
};
var _229=dojo.hostenv.getXmlhttpObject()?true:false;
this.canHandle=function(_22a){
return _229&&dojo.lang.inArray((_22a["mimetype"].toLowerCase()||""),["text/plain","text/html","application/xml","text/xml","text/javascript","text/json"])&&!(_22a["formNode"]&&dojo.io.formHasFile(_22a["formNode"]));
};
this.multipartBoundary="45309FFF-BD65-4d50-99C9-36986896A96F";
this.bind=function(_22b){
if(!_22b["url"]){
if(!_22b["formNode"]&&(_22b["backButton"]||_22b["back"]||_22b["changeUrl"]||_22b["watchForURL"])&&(!djConfig.preventBackButtonFix)){
dojo.deprecated("Using dojo.io.XMLHTTPTransport.bind() to add to browser history without doing an IO request","Use dojo.undo.browser.addToHistory() instead.","0.4");
dojo.undo.browser.addToHistory(_22b);
return true;
}
}
var url=_22b.url;
var _22d="";
if(_22b["formNode"]){
var ta=_22b.formNode.getAttribute("action");
if((ta)&&(!_22b["url"])){
url=ta;
}
var tp=_22b.formNode.getAttribute("method");
if((tp)&&(!_22b["method"])){
_22b.method=tp;
}
_22d+=dojo.io.encodeForm(_22b.formNode,_22b.encoding,_22b["formFilter"]);
}
if(url.indexOf("#")>-1){
dojo.debug("Warning: dojo.io.bind: stripping hash values from url:",url);
url=url.split("#")[0];
}
if(_22b["file"]){
_22b.method="post";
}
if(!_22b["method"]){
_22b.method="get";
}
if(_22b.method.toLowerCase()=="get"){
_22b.multipart=false;
}else{
if(_22b["file"]){
_22b.multipart=true;
}else{
if(!_22b["multipart"]){
_22b.multipart=false;
}
}
}
if(_22b["backButton"]||_22b["back"]||_22b["changeUrl"]){
dojo.undo.browser.addToHistory(_22b);
}
var _230=_22b["content"]||{};
if(_22b.sendTransport){
_230["dojo.transport"]="xmlhttp";
}
do{
if(_22b.postContent){
_22d=_22b.postContent;
break;
}
if(_230){
_22d+=dojo.io.argsFromMap(_230,_22b.encoding);
}
if(_22b.method.toLowerCase()=="get"||!_22b.multipart){
break;
}
var t=[];
if(_22d.length){
var q=_22d.split("&");
for(var i=0;i<q.length;++i){
if(q[i].length){
var p=q[i].split("=");
t.push("--"+this.multipartBoundary,"Content-Disposition: form-data; name=\""+p[0]+"\"","",p[1]);
}
}
}
if(_22b.file){
if(dojo.lang.isArray(_22b.file)){
for(var i=0;i<_22b.file.length;++i){
var o=_22b.file[i];
t.push("--"+this.multipartBoundary,"Content-Disposition: form-data; name=\""+o.name+"\"; filename=\""+("fileName" in o?o.fileName:o.name)+"\"","Content-Type: "+("contentType" in o?o.contentType:"application/octet-stream"),"",o.content);
}
}else{
var o=_22b.file;
t.push("--"+this.multipartBoundary,"Content-Disposition: form-data; name=\""+o.name+"\"; filename=\""+("fileName" in o?o.fileName:o.name)+"\"","Content-Type: "+("contentType" in o?o.contentType:"application/octet-stream"),"",o.content);
}
}
if(t.length){
t.push("--"+this.multipartBoundary+"--","");
_22d=t.join("\r\n");
}
}while(false);
var _236=_22b["sync"]?false:true;
var _237=_22b["preventCache"]||(this.preventCache==true&&_22b["preventCache"]!=false);
var _238=_22b["useCache"]==true||(this.useCache==true&&_22b["useCache"]!=false);
if(!_237&&_238){
var _239=getFromCache(url,_22d,_22b.method);
if(_239){
doLoad(_22b,_239,url,_22d,false);
return;
}
}
var http=dojo.hostenv.getXmlhttpObject(_22b);
var _23b=false;
if(_236){
var _23c=this.inFlight.push({"req":_22b,"http":http,"url":url,"query":_22d,"useCache":_238,"startTime":_22b.timeoutSeconds?(new Date()).getTime():0});
this.startWatchingInFlight();
}
if(_22b.method.toLowerCase()=="post"){
http.open("POST",url,_236);
setHeaders(http,_22b);
http.setRequestHeader("Content-Type",_22b.multipart?("multipart/form-data; boundary="+this.multipartBoundary):(_22b.contentType||"application/x-www-form-urlencoded"));
try{
http.send(_22d);
}
catch(e){
if(typeof http.abort=="function"){
http.abort();
}
doLoad(_22b,{status:404},url,_22d,_238);
}
}else{
var _23d=url;
if(_22d!=""){
_23d+=(_23d.indexOf("?")>-1?"&":"?")+_22d;
}
if(_237){
_23d+=(dojo.string.endsWithAny(_23d,"?","&")?"":(_23d.indexOf("?")>-1?"&":"?"))+"dojo.preventCache="+new Date().valueOf();
}
http.open(_22b.method.toUpperCase(),_23d,_236);
setHeaders(http,_22b);
try{
http.send(null);
}
catch(e){
if(typeof http.abort=="function"){
http.abort();
}
doLoad(_22b,{status:404},url,_22d,_238);
}
}
if(!_236){
doLoad(_22b,http,url,_22d,_238);
}
_22b.abort=function(){
return http.abort();
};
return;
};
dojo.io.transports.addTransport("XMLHTTPTransport");
};
dojo.provide("dojo.io.cookie");
dojo.io.cookie.setCookie=function(name,_23f,days,path,_242,_243){
var _244=-1;
if(typeof days=="number"&&days>=0){
var d=new Date();
d.setTime(d.getTime()+(days*24*60*60*1000));
_244=d.toGMTString();
}
_23f=escape(_23f);
document.cookie=name+"="+_23f+";"+(_244!=-1?" expires="+_244+";":"")+(path?"path="+path:"")+(_242?"; domain="+_242:"")+(_243?"; secure":"");
};
dojo.io.cookie.set=dojo.io.cookie.setCookie;
dojo.io.cookie.getCookie=function(name){
var idx=document.cookie.lastIndexOf(name+"=");
if(idx==-1){
return null;
}
value=document.cookie.substring(idx+name.length+1);
var end=value.indexOf(";");
if(end==-1){
end=value.length;
}
value=value.substring(0,end);
value=unescape(value);
return value;
};
dojo.io.cookie.get=dojo.io.cookie.getCookie;
dojo.io.cookie.deleteCookie=function(name){
dojo.io.cookie.setCookie(name,"-",0);
};
dojo.io.cookie.setObjectCookie=function(name,obj,days,path,_24e,_24f,_250){
if(arguments.length==5){
_250=_24e;
_24e=null;
_24f=null;
}
var _251=[],cookie,value="";
if(!_250){
cookie=dojo.io.cookie.getObjectCookie(name);
}
if(days>=0){
if(!cookie){
cookie={};
}
for(var prop in obj){
if(prop==null){
delete cookie[prop];
}else{
if(typeof obj[prop]=="string"||typeof obj[prop]=="number"){
cookie[prop]=obj[prop];
}
}
}
prop=null;
for(var prop in cookie){
_251.push(escape(prop)+"="+escape(cookie[prop]));
}
value=_251.join("&");
}
dojo.io.cookie.setCookie(name,value,days,path,_24e,_24f);
};
dojo.io.cookie.getObjectCookie=function(name){
var _254=null,cookie=dojo.io.cookie.getCookie(name);
if(cookie){
_254={};
var _255=cookie.split("&");
for(var i=0;i<_255.length;i++){
var pair=_255[i].split("=");
var _258=pair[1];
if(isNaN(_258)){
_258=unescape(pair[1]);
}
_254[unescape(pair[0])]=_258;
}
}
return _254;
};
dojo.io.cookie.isSupported=function(){
if(typeof navigator.cookieEnabled!="boolean"){
dojo.io.cookie.setCookie("__TestingYourBrowserForCookieSupport__","CookiesAllowed",90,null);
var _259=dojo.io.cookie.getCookie("__TestingYourBrowserForCookieSupport__");
navigator.cookieEnabled=(_259=="CookiesAllowed");
if(navigator.cookieEnabled){
this.deleteCookie("__TestingYourBrowserForCookieSupport__");
}
}
return navigator.cookieEnabled;
};
if(!dojo.io.cookies){
dojo.io.cookies=dojo.io.cookie;
}
dojo.kwCompoundRequire({common:["dojo.io"],rhino:["dojo.io.RhinoIO"],browser:["dojo.io.BrowserIO","dojo.io.cookie"],dashboard:["dojo.io.BrowserIO","dojo.io.cookie"]});
dojo.provide("dojo.io.*");
dojo.provide("dojo.AdapterRegistry");
dojo.require("dojo.lang.func");
dojo.AdapterRegistry=function(){
this.pairs=[];
};
dojo.lang.extend(dojo.AdapterRegistry,{register:function(name,_25b,wrap,_25d){
if(_25d){
this.pairs.unshift([name,_25b,wrap]);
}else{
this.pairs.push([name,_25b,wrap]);
}
},match:function(){
for(var i=0;i<this.pairs.length;i++){
var pair=this.pairs[i];
if(pair[1].apply(this,arguments)){
return pair[2].apply(this,arguments);
}
}
throw new Error("No match found");
},unregister:function(name){
for(var i=0;i<this.pairs.length;i++){
var pair=this.pairs[i];
if(pair[0]==name){
this.pairs.splice(i,1);
return true;
}
}
return false;
}});
dojo.provide("dojo.json");
dojo.require("dojo.lang.func");
dojo.require("dojo.string.extras");
dojo.require("dojo.AdapterRegistry");
dojo.json={jsonRegistry:new dojo.AdapterRegistry(),register:function(name,_264,wrap,_266){
dojo.json.jsonRegistry.register(name,_264,wrap,_266);
},evalJson:function(json){
try{
return eval("("+json+")");
}
catch(e){
dojo.debug(e);
return json;
}
},evalJSON:function(json){
dojo.deprecated("dojo.json.evalJSON","use dojo.json.evalJson","0.4");
return this.evalJson(json);
},serialize:function(o){
var _26a=typeof (o);
if(_26a=="undefined"){
return "undefined";
}else{
if((_26a=="number")||(_26a=="boolean")){
return o+"";
}else{
if(o===null){
return "null";
}
}
}
if(_26a=="string"){
return dojo.string.escapeString(o);
}
var me=arguments.callee;
var _26c;
if(typeof (o.__json__)=="function"){
_26c=o.__json__();
if(o!==_26c){
return me(_26c);
}
}
if(typeof (o.json)=="function"){
_26c=o.json();
if(o!==_26c){
return me(_26c);
}
}
if(_26a!="function"&&typeof (o.length)=="number"){
var res=[];
for(var i=0;i<o.length;i++){
var val=me(o[i]);
if(typeof (val)!="string"){
val="undefined";
}
res.push(val);
}
return "["+res.join(",")+"]";
}
try{
window.o=o;
_26c=dojo.json.jsonRegistry.match(o);
return me(_26c);
}
catch(e){
}
if(_26a=="function"){
return null;
}
res=[];
for(var k in o){
var _271;
if(typeof (k)=="number"){
_271="\""+k+"\"";
}else{
if(typeof (k)=="string"){
_271=dojo.string.escapeString(k);
}else{
continue;
}
}
val=me(o[k]);
if(typeof (val)!="string"){
continue;
}
res.push(_271+":"+val);
}
return "{"+res.join(",")+"}";
}};
dojo.provide("dojo.Deferred");
dojo.require("dojo.lang.func");
dojo.Deferred=function(_272){
this.chain=[];
this.id=this._nextId();
this.fired=-1;
this.paused=0;
this.results=[null,null];
this.canceller=_272;
this.silentlyCancelled=false;
};
dojo.lang.extend(dojo.Deferred,{getFunctionFromArgs:function(){
var a=arguments;
if((a[0])&&(!a[1])){
if(dojo.lang.isFunction(a[0])){
return a[0];
}else{
if(dojo.lang.isString(a[0])){
return dj_global[a[0]];
}
}
}else{
if((a[0])&&(a[1])){
return dojo.lang.hitch(a[0],a[1]);
}
}
return null;
},repr:function(){
var _274;
if(this.fired==-1){
_274="unfired";
}else{
if(this.fired==0){
_274="success";
}else{
_274="error";
}
}
return "Deferred("+this.id+", "+_274+")";
},toString:dojo.lang.forward("repr"),_nextId:(function(){
var n=1;
return function(){
return n++;
};
})(),cancel:function(){
if(this.fired==-1){
if(this.canceller){
this.canceller(this);
}else{
this.silentlyCancelled=true;
}
if(this.fired==-1){
this.errback(new Error(this.repr()));
}
}else{
if((this.fired==0)&&(this.results[0] instanceof dojo.Deferred)){
this.results[0].cancel();
}
}
},_pause:function(){
this.paused++;
},_unpause:function(){
this.paused--;
if((this.paused==0)&&(this.fired>=0)){
this._fire();
}
},_continue:function(res){
this._resback(res);
this._unpause();
},_resback:function(res){
this.fired=((res instanceof Error)?1:0);
this.results[this.fired]=res;
this._fire();
},_check:function(){
if(this.fired!=-1){
if(!this.silentlyCancelled){
dojo.raise("already called!");
}
this.silentlyCancelled=false;
return;
}
},callback:function(res){
this._check();
this._resback(res);
},errback:function(res){
this._check();
if(!(res instanceof Error)){
res=new Error(res);
}
this._resback(res);
},addBoth:function(cb,cbfn){
var _27c=this.getFunctionFromArgs(cb,cbfn);
if(arguments.length>2){
_27c=dojo.lang.curryArguments(null,_27c,arguments,2);
}
return this.addCallbacks(_27c,_27c);
},addCallback:function(cb,cbfn){
var _27f=this.getFunctionFromArgs(cb,cbfn);
if(arguments.length>2){
_27f=dojo.lang.curryArguments(null,_27f,arguments,2);
}
return this.addCallbacks(_27f,null);
},addErrback:function(cb,cbfn){
var _282=this.getFunctionFromArgs(cb,cbfn);
if(arguments.length>2){
_282=dojo.lang.curryArguments(null,_282,arguments,2);
}
return this.addCallbacks(null,_282);
return this.addCallbacks(null,fn);
},addCallbacks:function(cb,eb){
this.chain.push([cb,eb]);
if(this.fired>=0){
this._fire();
}
return this;
},_fire:function(){
var _285=this.chain;
var _286=this.fired;
var res=this.results[_286];
var self=this;
var cb=null;
while(_285.length>0&&this.paused==0){
var pair=_285.shift();
var f=pair[_286];
if(f==null){
continue;
}
try{
res=f(res);
_286=((res instanceof Error)?1:0);
if(res instanceof dojo.Deferred){
cb=function(res){
self._continue(res);
};
this._pause();
}
}
catch(err){
_286=1;
res=err;
}
}
this.fired=_286;
this.results[_286]=res;
if((cb)&&(this.paused)){
res.addBoth(cb);
}
}});
dojo.provide("dojo.rpc.Deferred");
dojo.require("dojo.Deferred");
dojo.rpc.Deferred=dojo.Deferred;
dojo.rpc.Deferred.prototype=dojo.Deferred.prototype;
dojo.provide("dojo.rpc.RpcService");
dojo.require("dojo.io.*");
dojo.require("dojo.json");
dojo.require("dojo.lang.func");
dojo.require("dojo.rpc.Deferred");
dojo.rpc.RpcService=function(url){
if(url){
this.connect(url);
}
};
dojo.lang.extend(dojo.rpc.RpcService,{strictArgChecks:true,serviceUrl:"",parseResults:function(obj){
return obj;
},errorCallback:function(_28f){
return function(type,obj,e){
_28f.errback(e);
};
},resultCallback:function(_293){
var tf=dojo.lang.hitch(this,function(type,obj,e){
var _298=this.parseResults(obj||e);
_293.callback(_298);
});
return tf;
},generateMethod:function(_299,_29a,url){
return dojo.lang.hitch(this,function(){
var _29c=new dojo.rpc.Deferred();
if((this.strictArgChecks)&&(_29a!=null)&&(arguments.length!=_29a.length)){
dojo.raise("Invalid number of parameters for remote method.");
}else{
this.bind(_299,arguments,_29c,url);
}
return _29c;
});
},processSmd:function(_29d){
dojo.debug("RpcService: Processing returned SMD.");
if(_29d.methods){
dojo.lang.forEach(_29d.methods,function(m){
if(m&&m["name"]){
dojo.debug("RpcService: Creating Method: this.",m.name,"()");
this[m.name]=this.generateMethod(m.name,m.parameters,m["url"]||m["serviceUrl"]||m["serviceURL"]);
if(dojo.lang.isFunction(this[m.name])){
dojo.debug("RpcService: Successfully created",m.name,"()");
}else{
dojo.debug("RpcService: Failed to create",m.name,"()");
}
}
},this);
}
this.serviceUrl=_29d.serviceUrl||_29d.serviceURL;
dojo.debug("RpcService: Dojo RpcService is ready for use.");
},connect:function(_29f){
dojo.debug("RpcService: Attempting to load SMD document from:",_29f);
dojo.io.bind({url:_29f,mimetype:"text/json",load:dojo.lang.hitch(this,function(type,_2a1,e){
return this.processSmd(_2a1);
}),sync:true});
}});
dojo.provide("dojo.rpc.JsonService");
dojo.require("dojo.rpc.RpcService");
dojo.require("dojo.io.*");
dojo.require("dojo.json");
dojo.require("dojo.lang");
dojo.rpc.JsonService=function(args){
if(args){
if(dojo.lang.isString(args)){
this.connect(args);
}else{
if(args["smdUrl"]){
this.connect(args.smdUrl);
}
if(args["smdStr"]){
this.processSmd(dj_eval("("+args.smdStr+")"));
}
if(args["smdObj"]){
this.processSmd(args.smdObj);
}
if(args["serviceUrl"]){
this.serviceUrl=args.serviceUrl;
}
if(typeof args["strictArgChecks"]!="undefined"){
this.strictArgChecks=args.strictArgChecks;
}
}
}
};
dojo.inherits(dojo.rpc.JsonService,dojo.rpc.RpcService);
dojo.lang.extend(dojo.rpc.JsonService,{bustCache:false,contentType:"application/json-rpc",lastSubmissionId:0,callRemote:function(_2a4,_2a5){
var _2a6=new dojo.rpc.Deferred();
this.bind(_2a4,_2a5,_2a6);
return _2a6;
},bind:function(_2a7,_2a8,_2a9,url){
dojo.io.bind({url:url||this.serviceUrl,postContent:this.createRequest(_2a7,_2a8),method:"POST",contentType:this.contentType,mimetype:"text/json",load:this.resultCallback(_2a9),preventCache:this.bustCache});
},createRequest:function(_2ab,_2ac){
var req={"params":_2ac,"method":_2ab,"id":++this.lastSubmissionId};
var data=dojo.json.serialize(req);
dojo.debug("JsonService: JSON-RPC Request: "+data);
return data;
},parseResults:function(obj){
if(!obj){
return;
}
if(obj["Result"]||obj["result"]){
return obj["result"]||obj["Result"];
}else{
if(obj["ResultSet"]){
return obj["ResultSet"];
}else{
return obj;
}
}
}});
dojo.provide("dojo.graphics.color");
dojo.require("dojo.lang.array");
dojo.graphics.color.Color=function(r,g,b,a){
if(dojo.lang.isArray(r)){
this.r=r[0];
this.g=r[1];
this.b=r[2];
this.a=r[3]||1;
}else{
if(dojo.lang.isString(r)){
var rgb=dojo.graphics.color.extractRGB(r);
this.r=rgb[0];
this.g=rgb[1];
this.b=rgb[2];
this.a=g||1;
}else{
if(r instanceof dojo.graphics.color.Color){
this.r=r.r;
this.b=r.b;
this.g=r.g;
this.a=r.a;
}else{
this.r=r;
this.g=g;
this.b=b;
this.a=a;
}
}
}
};
dojo.graphics.color.Color.fromArray=function(arr){
return new dojo.graphics.color.Color(arr[0],arr[1],arr[2],arr[3]);
};
dojo.lang.extend(dojo.graphics.color.Color,{toRgb:function(_2b6){
if(_2b6){
return this.toRgba();
}else{
return [this.r,this.g,this.b];
}
},toRgba:function(){
return [this.r,this.g,this.b,this.a];
},toHex:function(){
return dojo.graphics.color.rgb2hex(this.toRgb());
},toCss:function(){
return "rgb("+this.toRgb().join()+")";
},toString:function(){
return this.toHex();
},blend:function(_2b7,_2b8){
return dojo.graphics.color.blend(this.toRgb(),new Color(_2b7).toRgb(),_2b8);
}});
dojo.graphics.color.named={white:[255,255,255],black:[0,0,0],red:[255,0,0],green:[0,255,0],blue:[0,0,255],navy:[0,0,128],gray:[128,128,128],silver:[192,192,192]};
dojo.graphics.color.blend=function(a,b,_2bb){
if(typeof a=="string"){
return dojo.graphics.color.blendHex(a,b,_2bb);
}
if(!_2bb){
_2bb=0;
}else{
if(_2bb>1){
_2bb=1;
}else{
if(_2bb<-1){
_2bb=-1;
}
}
}
var c=new Array(3);
for(var i=0;i<3;i++){
var half=Math.abs(a[i]-b[i])/2;
c[i]=Math.floor(Math.min(a[i],b[i])+half+(half*_2bb));
}
return c;
};
dojo.graphics.color.blendHex=function(a,b,_2c1){
return dojo.graphics.color.rgb2hex(dojo.graphics.color.blend(dojo.graphics.color.hex2rgb(a),dojo.graphics.color.hex2rgb(b),_2c1));
};
dojo.graphics.color.extractRGB=function(_2c2){
var hex="0123456789abcdef";
_2c2=_2c2.toLowerCase();
if(_2c2.indexOf("rgb")==0){
var _2c4=_2c2.match(/rgba*\((\d+), *(\d+), *(\d+)/i);
var ret=_2c4.splice(1,3);
return ret;
}else{
var _2c6=dojo.graphics.color.hex2rgb(_2c2);
if(_2c6){
return _2c6;
}else{
return dojo.graphics.color.named[_2c2]||[255,255,255];
}
}
};
dojo.graphics.color.hex2rgb=function(hex){
var _2c8="0123456789ABCDEF";
var rgb=new Array(3);
if(hex.indexOf("#")==0){
hex=hex.substring(1);
}
hex=hex.toUpperCase();
if(hex.replace(new RegExp("["+_2c8+"]","g"),"")!=""){
return null;
}
if(hex.length==3){
rgb[0]=hex.charAt(0)+hex.charAt(0);
rgb[1]=hex.charAt(1)+hex.charAt(1);
rgb[2]=hex.charAt(2)+hex.charAt(2);
}else{
rgb[0]=hex.substring(0,2);
rgb[1]=hex.substring(2,4);
rgb[2]=hex.substring(4);
}
for(var i=0;i<rgb.length;i++){
rgb[i]=_2c8.indexOf(rgb[i].charAt(0))*16+_2c8.indexOf(rgb[i].charAt(1));
}
return rgb;
};
dojo.graphics.color.rgb2hex=function(r,g,b){
if(dojo.lang.isArray(r)){
g=r[1]||0;
b=r[2]||0;
r=r[0]||0;
}
var ret=dojo.lang.map([r,g,b],function(x){
x=new Number(x);
var s=x.toString(16);
while(s.length<2){
s="0"+s;
}
return s;
});
ret.unshift("#");
return ret.join("");
};
dojo.provide("dojo.uri.Uri");
dojo.uri=new function(){
this.joinPath=function(){
var arr=[];
for(var i=0;i<arguments.length;i++){
arr.push(arguments[i]);
}
return arr.join("/").replace(/\/{2,}/g,"/").replace(/((https*|ftps*):)/i,"$1/");
};
this.dojoUri=function(uri){
return new dojo.uri.Uri(dojo.hostenv.getBaseScriptUri(),uri);
};
this.Uri=function(){
var uri=arguments[0];
for(var i=1;i<arguments.length;i++){
if(!arguments[i]){
continue;
}
var _2d6=new dojo.uri.Uri(arguments[i].toString());
var _2d7=new dojo.uri.Uri(uri.toString());
if(_2d6.path==""&&_2d6.scheme==null&&_2d6.authority==null&&_2d6.query==null){
if(_2d6.fragment!=null){
_2d7.fragment=_2d6.fragment;
}
_2d6=_2d7;
}else{
if(_2d6.scheme==null){
_2d6.scheme=_2d7.scheme;
if(_2d6.authority==null){
_2d6.authority=_2d7.authority;
if(_2d6.path.charAt(0)!="/"){
var path=_2d7.path.substring(0,_2d7.path.lastIndexOf("/")+1)+_2d6.path;
var segs=path.split("/");
for(var j=0;j<segs.length;j++){
if(segs[j]=="."){
if(j==segs.length-1){
segs[j]="";
}else{
segs.splice(j,1);
j--;
}
}else{
if(j>0&&!(j==1&&segs[0]=="")&&segs[j]==".."&&segs[j-1]!=".."){
if(j==segs.length-1){
segs.splice(j,1);
segs[j-1]="";
}else{
segs.splice(j-1,2);
j-=2;
}
}
}
}
_2d6.path=segs.join("/");
}
}
}
}
uri="";
if(_2d6.scheme!=null){
uri+=_2d6.scheme+":";
}
if(_2d6.authority!=null){
uri+="//"+_2d6.authority;
}
uri+=_2d6.path;
if(_2d6.query!=null){
uri+="?"+_2d6.query;
}
if(_2d6.fragment!=null){
uri+="#"+_2d6.fragment;
}
}
this.uri=uri.toString();
var _2db="^(([^:/?#]+):)?(//([^/?#]*))?([^?#]*)(\\?([^#]*))?(#(.*))?$";
var r=this.uri.match(new RegExp(_2db));
this.scheme=r[2]||(r[1]?"":null);
this.authority=r[4]||(r[3]?"":null);
this.path=r[5];
this.query=r[7]||(r[6]?"":null);
this.fragment=r[9]||(r[8]?"":null);
if(this.authority!=null){
_2db="^((([^:]+:)?([^@]+))@)?([^:]*)(:([0-9]+))?$";
r=this.authority.match(new RegExp(_2db));
this.user=r[3]||null;
this.password=r[4]||null;
this.host=r[5];
this.port=r[7]||null;
}
this.toString=function(){
return this.uri;
};
};
};
dojo.provide("dojo.style");
dojo.require("dojo.graphics.color");
dojo.require("dojo.uri.Uri");
dojo.require("dojo.lang.common");
(function(){
var h=dojo.render.html;
var ds=dojo.style;
var db=document["body"]||document["documentElement"];
ds.boxSizing={MARGIN_BOX:"margin-box",BORDER_BOX:"border-box",PADDING_BOX:"padding-box",CONTENT_BOX:"content-box"};
var bs=ds.boxSizing;
ds.getBoxSizing=function(node){
if((h.ie)||(h.opera)){
var cm=document["compatMode"];
if((cm=="BackCompat")||(cm=="QuirksMode")){
return bs.BORDER_BOX;
}else{
return bs.CONTENT_BOX;
}
}else{
if(arguments.length==0){
node=document.documentElement;
}
var _2e3=ds.getStyle(node,"-moz-box-sizing");
if(!_2e3){
_2e3=ds.getStyle(node,"box-sizing");
}
return (_2e3?_2e3:bs.CONTENT_BOX);
}
};
ds.isBorderBox=function(node){
return (ds.getBoxSizing(node)==bs.BORDER_BOX);
};
ds.getUnitValue=function(node,_2e6,_2e7){
var s=ds.getComputedStyle(node,_2e6);
if((!s)||((s=="auto")&&(_2e7))){
return {value:0,units:"px"};
}
if(dojo.lang.isUndefined(s)){
return ds.getUnitValue.bad;
}
var _2e9=s.match(/(\-?[\d.]+)([a-z%]*)/i);
if(!_2e9){
return ds.getUnitValue.bad;
}
return {value:Number(_2e9[1]),units:_2e9[2].toLowerCase()};
};
ds.getUnitValue.bad={value:NaN,units:""};
ds.getPixelValue=function(node,_2eb,_2ec){
var _2ed=ds.getUnitValue(node,_2eb,_2ec);
if(isNaN(_2ed.value)){
return 0;
}
if((_2ed.value)&&(_2ed.units!="px")){
return NaN;
}
return _2ed.value;
};
ds.getNumericStyle=function(){
dojo.deprecated("dojo.(style|html).getNumericStyle","in favor of dojo.(style|html).getPixelValue","0.4");
return ds.getPixelValue.apply(this,arguments);
};
ds.setPositivePixelValue=function(node,_2ef,_2f0){
if(isNaN(_2f0)){
return false;
}
node.style[_2ef]=Math.max(0,_2f0)+"px";
return true;
};
ds._sumPixelValues=function(node,_2f2,_2f3){
var _2f4=0;
for(x=0;x<_2f2.length;x++){
_2f4+=ds.getPixelValue(node,_2f2[x],_2f3);
}
return _2f4;
};
ds.isPositionAbsolute=function(node){
return (ds.getComputedStyle(node,"position")=="absolute");
};
ds.getBorderExtent=function(node,side){
return (ds.getStyle(node,"border-"+side+"-style")=="none"?0:ds.getPixelValue(node,"border-"+side+"-width"));
};
ds.getMarginWidth=function(node){
return ds._sumPixelValues(node,["margin-left","margin-right"],ds.isPositionAbsolute(node));
};
ds.getBorderWidth=function(node){
return ds.getBorderExtent(node,"left")+ds.getBorderExtent(node,"right");
};
ds.getPaddingWidth=function(node){
return ds._sumPixelValues(node,["padding-left","padding-right"],true);
};
ds.getPadBorderWidth=function(node){
return ds.getPaddingWidth(node)+ds.getBorderWidth(node);
};
ds.getContentBoxWidth=function(node){
node=dojo.byId(node);
return node.offsetWidth-ds.getPadBorderWidth(node);
};
ds.getBorderBoxWidth=function(node){
node=dojo.byId(node);
return node.offsetWidth;
};
ds.getMarginBoxWidth=function(node){
return ds.getInnerWidth(node)+ds.getMarginWidth(node);
};
ds.setContentBoxWidth=function(node,_300){
node=dojo.byId(node);
if(ds.isBorderBox(node)){
_300+=ds.getPadBorderWidth(node);
}
return ds.setPositivePixelValue(node,"width",_300);
};
ds.setMarginBoxWidth=function(node,_302){
node=dojo.byId(node);
if(!ds.isBorderBox(node)){
_302-=ds.getPadBorderWidth(node);
}
_302-=ds.getMarginWidth(node);
return ds.setPositivePixelValue(node,"width",_302);
};
ds.getContentWidth=ds.getContentBoxWidth;
ds.getInnerWidth=ds.getBorderBoxWidth;
ds.getOuterWidth=ds.getMarginBoxWidth;
ds.setContentWidth=ds.setContentBoxWidth;
ds.setOuterWidth=ds.setMarginBoxWidth;
ds.getMarginHeight=function(node){
return ds._sumPixelValues(node,["margin-top","margin-bottom"],ds.isPositionAbsolute(node));
};
ds.getBorderHeight=function(node){
return ds.getBorderExtent(node,"top")+ds.getBorderExtent(node,"bottom");
};
ds.getPaddingHeight=function(node){
return ds._sumPixelValues(node,["padding-top","padding-bottom"],true);
};
ds.getPadBorderHeight=function(node){
return ds.getPaddingHeight(node)+ds.getBorderHeight(node);
};
ds.getContentBoxHeight=function(node){
node=dojo.byId(node);
return node.offsetHeight-ds.getPadBorderHeight(node);
};
ds.getBorderBoxHeight=function(node){
node=dojo.byId(node);
return node.offsetHeight;
};
ds.getMarginBoxHeight=function(node){
return ds.getInnerHeight(node)+ds.getMarginHeight(node);
};
ds.setContentBoxHeight=function(node,_30b){
node=dojo.byId(node);
if(ds.isBorderBox(node)){
_30b+=ds.getPadBorderHeight(node);
}
return ds.setPositivePixelValue(node,"height",_30b);
};
ds.setMarginBoxHeight=function(node,_30d){
node=dojo.byId(node);
if(!ds.isBorderBox(node)){
_30d-=ds.getPadBorderHeight(node);
}
_30d-=ds.getMarginHeight(node);
return ds.setPositivePixelValue(node,"height",_30d);
};
ds.getContentHeight=ds.getContentBoxHeight;
ds.getInnerHeight=ds.getBorderBoxHeight;
ds.getOuterHeight=ds.getMarginBoxHeight;
ds.setContentHeight=ds.setContentBoxHeight;
ds.setOuterHeight=ds.setMarginBoxHeight;
ds.getAbsolutePosition=ds.abs=function(node,_30f){
var ret=[];
ret.x=ret.y=0;
var st=dojo.html.getScrollTop();
var sl=dojo.html.getScrollLeft();
if(h.ie){
with(node.getBoundingClientRect()){
ret.x=left-2;
ret.y=top-2;
}
}else{
if(node["offsetParent"]){
var _313;
if((h.safari)&&(node.style.getPropertyValue("position")=="absolute")&&(node.parentNode==db)){
_313=db;
}else{
_313=db.parentNode;
}
if(node.parentNode!=db){
ret.x-=ds.sumAncestorProperties(node,"scrollLeft");
ret.y-=ds.sumAncestorProperties(node,"scrollTop");
}
do{
var n=node["offsetLeft"];
ret.x+=isNaN(n)?0:n;
var m=node["offsetTop"];
ret.y+=isNaN(m)?0:m;
node=node.offsetParent;
}while((node!=_313)&&(node!=null));
}else{
if(node["x"]&&node["y"]){
ret.x+=isNaN(node.x)?0:node.x;
ret.y+=isNaN(node.y)?0:node.y;
}
}
}
if(_30f){
ret.y+=st;
ret.x+=sl;
}
ret[0]=ret.x;
ret[1]=ret.y;
return ret;
};
ds.sumAncestorProperties=function(node,prop){
node=dojo.byId(node);
if(!node){
return 0;
}
var _318=0;
while(node){
var val=node[prop];
if(val){
_318+=val-0;
}
node=node.parentNode;
}
return _318;
};
ds.getTotalOffset=function(node,type,_31c){
node=dojo.byId(node);
return ds.abs(node,_31c)[(type=="top")?"y":"x"];
};
ds.getAbsoluteX=ds.totalOffsetLeft=function(node,_31e){
return ds.getTotalOffset(node,"left",_31e);
};
ds.getAbsoluteY=ds.totalOffsetTop=function(node,_320){
return ds.getTotalOffset(node,"top",_320);
};
ds.styleSheet=null;
ds.insertCssRule=function(_321,_322,_323){
if(!ds.styleSheet){
if(document.createStyleSheet){
ds.styleSheet=document.createStyleSheet();
}else{
if(document.styleSheets[0]){
ds.styleSheet=document.styleSheets[0];
}else{
return null;
}
}
}
if(arguments.length<3){
if(ds.styleSheet.cssRules){
_323=ds.styleSheet.cssRules.length;
}else{
if(ds.styleSheet.rules){
_323=ds.styleSheet.rules.length;
}else{
return null;
}
}
}
if(ds.styleSheet.insertRule){
var rule=_321+" { "+_322+" }";
return ds.styleSheet.insertRule(rule,_323);
}else{
if(ds.styleSheet.addRule){
return ds.styleSheet.addRule(_321,_322,_323);
}else{
return null;
}
}
};
ds.removeCssRule=function(_325){
if(!ds.styleSheet){
dojo.debug("no stylesheet defined for removing rules");
return false;
}
if(h.ie){
if(!_325){
_325=ds.styleSheet.rules.length;
ds.styleSheet.removeRule(_325);
}
}else{
if(document.styleSheets[0]){
if(!_325){
_325=ds.styleSheet.cssRules.length;
}
ds.styleSheet.deleteRule(_325);
}
}
return true;
};
ds.insertCssFile=function(URI,doc,_328){
if(!URI){
return;
}
if(!doc){
doc=document;
}
var _329=dojo.hostenv.getText(URI);
_329=ds.fixPathsInCssText(_329,URI);
if(_328){
var _32a=doc.getElementsByTagName("style");
var _32b="";
for(var i=0;i<_32a.length;i++){
_32b=(_32a[i].styleSheet&&_32a[i].styleSheet.cssText)?_32a[i].styleSheet.cssText:_32a[i].innerHTML;
if(_329==_32b){
return;
}
}
}
var _32d=ds.insertCssText(_329);
if(_32d&&djConfig.isDebug){
_32d.setAttribute("dbgHref",URI);
}
return _32d;
};
ds.insertCssText=function(_32e,doc,URI){
if(!_32e){
return;
}
if(!doc){
doc=document;
}
if(URI){
_32e=ds.fixPathsInCssText(_32e,URI);
}
var _331=doc.createElement("style");
_331.setAttribute("type","text/css");
if(_331.styleSheet){
_331.styleSheet.cssText=_32e;
}else{
var _332=doc.createTextNode(_32e);
_331.appendChild(_332);
}
var head=doc.getElementsByTagName("head")[0];
if(!head){
dojo.debug("No head tag in document, aborting styles");
}else{
head.appendChild(_331);
}
return _331;
};
ds.fixPathsInCssText=function(_334,URI){
if(!_334||!URI){
return;
}
var pos=0;
var str="";
var url="";
while(pos!=-1){
pos=0;
url="";
pos=_334.indexOf("url(",pos);
if(pos<0){
break;
}
str+=_334.slice(0,pos+4);
_334=_334.substring(pos+4,_334.length);
url+=_334.match(/^[\t\s\w()\/.\\'"-:#=&?]*\)/)[0];
_334=_334.substring(url.length-1,_334.length);
url=url.replace(/^[\s\t]*(['"]?)([\w()\/.\\'"-:#=&?]*)\1[\s\t]*?\)/,"$2");
if(url.search(/(file|https?|ftps?):\/\//)==-1){
url=(new dojo.uri.Uri(URI,url).toString());
}
str+=url;
}
return str+_334;
};
ds.getBackgroundColor=function(node){
node=dojo.byId(node);
var _33a;
do{
_33a=ds.getStyle(node,"background-color");
if(_33a.toLowerCase()=="rgba(0, 0, 0, 0)"){
_33a="transparent";
}
if(node==document.getElementsByTagName("body")[0]){
node=null;
break;
}
node=node.parentNode;
}while(node&&dojo.lang.inArray(_33a,["transparent",""]));
if(_33a=="transparent"){
_33a=[255,255,255,0];
}else{
_33a=dojo.graphics.color.extractRGB(_33a);
}
return _33a;
};
ds.getComputedStyle=function(node,_33c,_33d){
node=dojo.byId(node);
var _33c=ds.toSelectorCase(_33c);
var _33e=ds.toCamelCase(_33c);
if(!node||!node.style){
return _33d;
}else{
if(document.defaultView){
try{
var cs=document.defaultView.getComputedStyle(node,"");
if(cs){
return cs.getPropertyValue(_33c);
}
}
catch(e){
if(node.style.getPropertyValue){
return node.style.getPropertyValue(_33c);
}else{
return _33d;
}
}
}else{
if(node.currentStyle){
return node.currentStyle[_33e];
}
}
}
if(node.style.getPropertyValue){
return node.style.getPropertyValue(_33c);
}else{
return _33d;
}
};
ds.getStyleProperty=function(node,_341){
node=dojo.byId(node);
return (node&&node.style?node.style[ds.toCamelCase(_341)]:undefined);
};
ds.getStyle=function(node,_343){
var _344=ds.getStyleProperty(node,_343);
return (_344?_344:ds.getComputedStyle(node,_343));
};
ds.setStyle=function(node,_346,_347){
node=dojo.byId(node);
if(node&&node.style){
var _348=ds.toCamelCase(_346);
node.style[_348]=_347;
}
};
ds.toCamelCase=function(_349){
var arr=_349.split("-"),cc=arr[0];
for(var i=1;i<arr.length;i++){
cc+=arr[i].charAt(0).toUpperCase()+arr[i].substring(1);
}
return cc;
};
ds.toSelectorCase=function(_34c){
return _34c.replace(/([A-Z])/g,"-$1").toLowerCase();
};
ds.setOpacity=function setOpacity(node,_34e,_34f){
node=dojo.byId(node);
if(!_34f){
if(_34e>=1){
if(h.ie){
ds.clearOpacity(node);
return;
}else{
_34e=0.999999;
}
}else{
if(_34e<0){
_34e=0;
}
}
}
if(h.ie){
if(node.nodeName.toLowerCase()=="tr"){
var tds=node.getElementsByTagName("td");
for(var x=0;x<tds.length;x++){
tds[x].style.filter="Alpha(Opacity="+_34e*100+")";
}
}
node.style.filter="Alpha(Opacity="+_34e*100+")";
}else{
if(h.moz){
node.style.opacity=_34e;
node.style.MozOpacity=_34e;
}else{
if(h.safari){
node.style.opacity=_34e;
node.style.KhtmlOpacity=_34e;
}else{
node.style.opacity=_34e;
}
}
}
};
ds.getOpacity=function getOpacity(node){
node=dojo.byId(node);
if(h.ie){
var opac=(node.filters&&node.filters.alpha&&typeof node.filters.alpha.opacity=="number"?node.filters.alpha.opacity:100)/100;
}else{
var opac=node.style.opacity||node.style.MozOpacity||node.style.KhtmlOpacity||1;
}
return opac>=0.999999?1:Number(opac);
};
ds.clearOpacity=function clearOpacity(node){
node=dojo.byId(node);
var ns=node.style;
if(h.ie){
try{
if(node.filters&&node.filters.alpha){
ns.filter="";
}
}
catch(e){
}
}else{
if(h.moz){
ns.opacity=1;
ns.MozOpacity=1;
}else{
if(h.safari){
ns.opacity=1;
ns.KhtmlOpacity=1;
}else{
ns.opacity=1;
}
}
}
};
ds._toggle=function(node,_357,_358){
node=dojo.byId(node);
_358(node,!_357(node));
return _357(node);
};
ds.show=function(node){
node=dojo.byId(node);
if(ds.getStyleProperty(node,"display")=="none"){
ds.setStyle(node,"display",(node.dojoDisplayCache||""));
node.dojoDisplayCache=undefined;
}
};
ds.hide=function(node){
node=dojo.byId(node);
if(typeof node["dojoDisplayCache"]=="undefined"){
var d=ds.getStyleProperty(node,"display");
if(d!="none"){
node.dojoDisplayCache=d;
}
}
ds.setStyle(node,"display","none");
};
ds.setShowing=function(node,_35d){
ds[(_35d?"show":"hide")](node);
};
ds.isShowing=function(node){
return (ds.getStyleProperty(node,"display")!="none");
};
ds.toggleShowing=function(node){
return ds._toggle(node,ds.isShowing,ds.setShowing);
};
ds.displayMap={tr:"",td:"",th:"",img:"inline",span:"inline",input:"inline",button:"inline"};
ds.suggestDisplayByTagName=function(node){
node=dojo.byId(node);
if(node&&node.tagName){
var tag=node.tagName.toLowerCase();
return (tag in ds.displayMap?ds.displayMap[tag]:"block");
}
};
ds.setDisplay=function(node,_363){
ds.setStyle(node,"display",(dojo.lang.isString(_363)?_363:(_363?ds.suggestDisplayByTagName(node):"none")));
};
ds.isDisplayed=function(node){
return (ds.getComputedStyle(node,"display")!="none");
};
ds.toggleDisplay=function(node){
return ds._toggle(node,ds.isDisplayed,ds.setDisplay);
};
ds.setVisibility=function(node,_367){
ds.setStyle(node,"visibility",(dojo.lang.isString(_367)?_367:(_367?"visible":"hidden")));
};
ds.isVisible=function(node){
return (ds.getComputedStyle(node,"visibility")!="hidden");
};
ds.toggleVisibility=function(node){
return ds._toggle(node,ds.isVisible,ds.setVisibility);
};
ds.toCoordinateArray=function(_36a,_36b){
if(dojo.lang.isArray(_36a)){
while(_36a.length<4){
_36a.push(0);
}
while(_36a.length>4){
_36a.pop();
}
var ret=_36a;
}else{
var node=dojo.byId(_36a);
var pos=ds.getAbsolutePosition(node,_36b);
var ret=[pos.x,pos.y,ds.getBorderBoxWidth(node),ds.getBorderBoxHeight(node)];
}
ret.x=ret[0];
ret.y=ret[1];
ret.w=ret[2];
ret.h=ret[3];
return ret;
};
})();
dojo.provide("dojo.string.Builder");
dojo.require("dojo.string");
dojo.string.Builder=function(str){
this.arrConcat=(dojo.render.html.capable&&dojo.render.html["ie"]);
var a=[];
var b=str||"";
var _372=this.length=b.length;
if(this.arrConcat){
if(b.length>0){
a.push(b);
}
b="";
}
this.toString=this.valueOf=function(){
return (this.arrConcat)?a.join(""):b;
};
this.append=function(s){
if(this.arrConcat){
a.push(s);
}else{
b+=s;
}
_372+=s.length;
this.length=_372;
return this;
};
this.clear=function(){
a=[];
b="";
_372=this.length=0;
return this;
};
this.remove=function(f,l){
var s="";
if(this.arrConcat){
b=a.join("");
}
a=[];
if(f>0){
s=b.substring(0,(f-1));
}
b=s+b.substring(f+l);
_372=this.length=b.length;
if(this.arrConcat){
a.push(b);
b="";
}
return this;
};
this.replace=function(o,n){
if(this.arrConcat){
b=a.join("");
}
a=[];
b=b.replace(o,n);
_372=this.length=b.length;
if(this.arrConcat){
a.push(b);
b="";
}
return this;
};
this.insert=function(idx,s){
if(this.arrConcat){
b=a.join("");
}
a=[];
if(idx==0){
b=s+b;
}else{
var t=b.split("");
t.splice(idx,0,s);
b=t.join("");
}
_372=this.length=b.length;
if(this.arrConcat){
a.push(b);
b="";
}
return this;
};
};
dojo.kwCompoundRequire({common:["dojo.string","dojo.string.common","dojo.string.extras","dojo.string.Builder"]});
dojo.provide("dojo.string.*");
dojo.provide("dojo.lang.declare");
dojo.require("dojo.lang.common");
dojo.require("dojo.lang.extras");
dojo.lang.declare=function(_37c,_37d,_37e,init){
var ctor=function(){
var self=this._getPropContext();
var s=self.constructor.superclass;
if((s)&&(s.constructor)){
if(s.constructor==arguments.callee){
this.inherited("constructor",arguments);
}else{
this._inherited(s,"constructor",arguments);
}
}
if((!this.prototyping)&&(self.initializer)){
self.initializer.apply(this,arguments);
}
};
var scp=(_37d?_37d.prototype:null);
if(scp){
scp.prototyping=true;
ctor.prototype=new _37d();
scp.prototyping=false;
}
ctor.prototype.constructor=ctor;
ctor.superclass=scp;
dojo.lang.extend(ctor,dojo.lang.declare.base);
_37e=(_37e||{});
_37e.initializer=(_37e.initializer)||(init)||(function(){
});
_37e.className=_37c;
dojo.lang.extend(ctor,_37e);
dojo.lang.setObjPathValue(_37c,ctor,null,true);
};
dojo.lang.declare.base={_getPropContext:function(){
return (this.___proto||this);
},_inherited:function(_384,_385,args){
var _387=this.___proto;
this.___proto=_384;
var _388=_384[_385].apply(this,(args||[]));
this.___proto=_387;
return _388;
},inherited:function(prop,args){
var p=this._getPropContext();
do{
if((!p.constructor)||(!p.constructor.superclass)){
return;
}
p=p.constructor.superclass;
}while(!(prop in p));
return (typeof p[prop]=="function"?this._inherited(p,prop,args):p[prop]);
}};
dojo.declare=dojo.lang.declare;
if(this["dojo"]){
dojo.provide("turbo.turbo");
dojo.require("dojo.dom");
dojo.require("dojo.style");
dojo.require("dojo.string.*");
dojo.require("dojo.lang.declare");
dojo.setModulePrefix("turbo","../turbo");
}else{
turbo={};
dojo={provide:function(){
},require:function(){
}};
}
turbo.global=this;
turbo.isGoodIndex=function(_38c,_38d){
return (_38c&&_38d>=0&&_38d<_38c.length);
};
turbo.filter=function(_38e,_38f,_390){
if(!_390){
_390=dj_global;
}
var _391=[];
for(var i=0,elt;i<_38e.length;i++){
elt=_38f.call(_390,_38e[i]);
if(elt!==undefined){
_391.push(elt);
}
}
return _391;
};
turbo.arraySwap=function(_393,inI,inJ){
var _396=_393[inI];
_393[inI]=_393[inJ];
_393[inJ]=_396;
};
turbo.arrayMove=function(_397,_398,_399){
var e=_397[_398];
if(_399>_398){
_399--;
}
_397.splice(_398,1);
_397.splice(_399,0,e);
};
turbo.cat=function(){
turbo.cloneArguments(arguments).join("");
};
turbo.stringOf=function(_39b,_39c){
if(_39b<=0){
return "";
}
var _39d=new Array(_39b);
for(var i=0;i<_39b;i++){
_39d[i]=_39c;
}
return _39d.join("");
};
turbo.alphabetizeIndex=function(_39f){
var _3a0=function(c){
return String.fromCharCode("A".charCodeAt(0)+c);
};
var a=Math.floor(_39f/26);
return (a>0?_3a0(a-1):"")+_3a0(_39f%26);
};
turbo.pathpop=function(_3a3,_3a4){
var _3a5=_3a3.lastIndexOf((_3a4==undefined?"/":_3a4));
return (_3a5>=0?_3a3.substring(0,_3a5):"");
};
turbo.escapeText=function(_3a6){
return dojo.string.escapeXml(String(_3a6)).replace(/\n/g,"<br />");
};
turbo.conjoin=function(_3a7,_3a8,_3a9){
return _3a8+_3a7.join(_3a9+_3a8)+_3a9;
};
turbo.supplant=function(s,o){
var i,j;
for(;;){
i=s.lastIndexOf("{");
if(i<0){
break;
}
j=s.indexOf("}",i);
if(i+1>=j){
break;
}
s=s.substring(0,i)+o[s.substring(i+1,j)]+s.substring(j+1);
}
return s;
};
turbo.printf=function(s){
for(var a=1,i=0,r;a<arguments.length;){
i=s.indexOf("%",i);
if(i==-1){
break;
}
if(s.charAt(i+1)=="%"){
r="%";
}else{
r=arguments[a++];
}
s=s.substring(0,i)+r+s.substring(i+2);
if(r=="%"){
i++;
}
}
return (s==undefined?"":s);
};
turbo.stringReplace=function(_3af,_3b0,_3b1){
if(!dojo.render.html.safari){
return _3af.replace(_3b0,_3b1);
}
var str=_3af;
var _3b3=_3b1;
var reg=_3b0;
var _3b5=[];
var _3b6=reg.lastIndex;
var re;
while((re=reg.exec(str))!=null){
var idx=re.index;
var args=re.concat(idx,str);
_3b5.push(str.slice(_3b6,idx),_3b3.apply(null,args).toString());
if(!reg.global){
_3b6+=(RegExp.lastMatch?RegExp.lastMatch.length:0);
break;
}else{
_3b6=reg.lastIndex;
}
}
_3b5.push(str.slice(_3b6));
return _3b5.join("");
};
turbo.macros=new function(){
this.apply=function(_3ba,_3bb){
return turbo.stringReplace(_3ba,new RegExp("%%([^%]*)%%","ig"),function(w,m){
return (_3bb[m]?_3bb[m]:m);
});
};
this.interpolate=function(_3be){
for(var i in _3be){
_3be[i]=this.apply(_3be[i],_3be);
}
return _3be;
};
this.insert=function(_3c0,_3c1){
if(!_3c1){
return _3c0;
}
_3c1=(dojo.lang.isString(_3c1)?eval("("+_3c1+")"):_3c1);
_3c1=this.interpolate(_3c1);
return this.apply(_3c0,_3c1);
};
};
turbo.time=function(){
return new Date().getTime();
};
turbo._swiss=function(_3c2,_3c3){
for(var i in _3c2){
_3c3[i]=_3c2[i];
}
return _3c3;
};
turbo.swiss=function(_3c5,_3c6){
if(!_3c5||!_3c6){
return;
}
if(!dojo.lang.isArray(_3c5)){
turbo._swiss(_3c5,_3c6);
}else{
for(var i=0,l=_3c5.length;i<l;i++){
turbo._swiss(_3c5[i],_3c6);
}
}
return _3c6;
};
turbo.stringToReference=function(_3c8){
var obj=turbo.global;
var _3ca=_3c8.split(".");
var prop=_3ca.pop();
while(_3ca.length&&obj){
obj=obj[_3ca.shift()];
}
return (prop&&(prop in obj)?obj[prop]:null);
};
turbo.defineClass=dojo.declare;
turbo.cloneArguments=function(_3cc,_3cd){
var l=_3cc.length;
var s=(_3cd?_3cd:0);
var _3d0=new Array(l-s);
for(var i=s,j=0;i<l;i++,j++){
_3d0[j]=_3cc[i];
}
return _3d0;
};
turbo.bind=function(_3d2,_3d3){
if(_3d3){
if(dojo.lang.isString(_3d3)){
_3d3=_3d2[_3d3];
}
return function(){
return _3d3.apply(_3d2,arguments);
};
}else{
dojo.debug("turbo.bind called with null method");
return function(){
};
}
};
turbo.bindArgs=function(_3d4,_3d5){
if(!_3d5){
dojo.debug("turbo.bindArgs called with null method");
return function(){
};
}
if(dojo.lang.isString(_3d5)){
_3d5=_3d4[_3d5];
}
var _3d6=turbo.cloneArguments(arguments,2);
return function(){
var args=_3d6.slice(0);
for(var i=0;i<arguments.length;i++){
args.push(arguments[i]);
}
return _3d5.apply(_3d4,args);
};
};
turbo.defer=function(_3d9,_3da){
if(arguments.length>3){
var args=turbo.cloneArguments(arguments);
var _3dc=args.pop();
return window.setTimeout(turbo.bindArgs.apply(turbo,args),_3dc);
}
if(arguments.length>2){
return window.setTimeout(turbo.bind(arguments[0],arguments[1]),arguments[2]);
}else{
return window.setTimeout(arguments[0],arguments[1]);
}
};
turbo.cancel=function(_3dd){
if(_3dd){
window.clearTimeout(_3dd);
}
};
turbo.jobs=[];
turbo.job=function(_3de,_3df,_3e0){
turbo.cancel(turbo.jobs[_3de]);
var job=function(){
delete turbo.jobs[_3de];
_3e0();
};
turbo.jobs[_3de]=turbo.defer(job,_3df);
};
turbo.getFunction=turbo.stringToReference;
turbo.$=function(_3e2,_3e3){
return (!_3e2?null:(!dojo.lang.isString(_3e2)?_3e2:(_3e3?_3e3:document).getElementById(_3e2)));
};
turbo.create=function(_3e4){
return document.createElement(_3e4);
};
turbo.remove=function(_3e5){
_3e5=turbo.$(_3e5);
if(_3e5&&_3e5.parentNode){
_3e5.parentNode.removeChild(_3e5);
}
return _3e5;
};
turbo.append=function(_3e6,_3e7){
(_3e7?_3e7:document.body).appendChild(_3e6);
};
turbo.addBodyNode=function(_3e8){
document.body.appendChild(_3e8);
};
turbo.addHeadNode=function(_3e9){
document.getElementsByTagName("head").item(0).appendChild(_3e9);
};
turbo.marshall=function(){
var id="";
var _3eb=dj_global;
for(var i=0;i<arguments.length;i++){
id=arguments[i];
if(i==0&&!dojo.lang.isString(i)){
_3eb=id;
}else{
if(!_3eb[id]){
_3eb[id]=turbo.$(id);
}
}
}
return dj_global[id];
};
turbo.getTagName=function(_3ed){
var node=turbo.$(_3ed);
return (node&&node.tagName?node.tagName.toLowerCase():"");
};
turbo.indexInParent=function(_3ef){
var i=0,n,p=_3ef.parentNode;
while(n=p.childNodes[i++]){
if(n==_3ef){
return i-1;
}
}
return -1;
};
turbo.kids=function(_3f1,_3f2){
var _3f3=[];
var i=0,n;
while(n=_3f1.childNodes[i++]){
if(turbo.getTagName(n)==_3f2){
_3f3.push(n);
}
}
return _3f3;
};
turbo.divkids=function(_3f5){
return turbo.kids(_3f5,"div");
};
turbo.nthkid=function(_3f6,inN,_3f8){
var _3f9=[];
var i=0,n;
while(n=_3f6.childNodes[i++]){
if(turbo.getTagName(n)==_3f8){
if(inN--==0){
return n;
}
}
}
return null;
};
turbo.nthdiv=function(_3fb,inN){
return turbo.nthkid(_3fb,inN,"div");
};
turbo.capture=function(_3fd){
if(_3fd.setCapture){
_3fd.setCapture();
}else{
document.addEventListener("mousemove",_3fd.onmousemove,true);
document.addEventListener("mouseup",_3fd.onmouseup,true);
}
};
turbo.release=function(_3fe){
if(_3fe.releaseCapture){
_3fe.releaseCapture();
}else{
document.removeEventListener("mousemove",_3fe.onmousemove,true);
document.removeEventListener("mouseup",_3fe.onmouseup,true);
}
};
turbo.getScrollbarWidth=function(){
if(turbo["_scrollBarWidth"]){
return turbo._scrollBarWidth;
}
turbo._scrollBarWidth=18;
try{
var e=document.createElement("div");
with(e.style){
top="0px";
left="0px";
width="100px";
height="100px";
overflow="scroll";
position="absolute";
visibility="hidden";
}
document.body.appendChild(e);
turbo._scrollBarWidth=e.offsetWidth-e.clientWidth;
document.body.removeChild(e);
delete e;
}
catch(ex){
}
return turbo._scrollBarWidth;
};
turbo.preloads=[];
turbo.preloadImage=function(_400){
var i=new Image();
i.src=_400;
turbo.preloads.push(i);
};
turbo.setCursor=function(_402){
document.body.style.cursor=_402;
};
turbo.setBusyCursor=function(){
turbo.setCursor("wait");
};
turbo.setDefaultCursor=function(){
turbo.setCursor("default");
};
turbo.getSelectValue=function(_403){
var s=turbo.$(_403);
if(!s){
return "";
}
with(s.options[s.selectedIndex]){
return (value?value:innerHTML);
}
};
turbo.getCellIndex=function(inTd){
if(inTd.cellIndex){
return inTd.cellIndex;
}
var _406=inTd.parentNode.cells;
var l=_406.length;
for(var i=0;i<l;i++){
if(inTd==_406[i]){
return i;
}
}
return -1;
};
turbo.getRowIndex=function(inTr){
if(inTr.rowIndex&&inTr.rowIndex>=0){
return inTr.rowIndex;
}
var rows=inTr.parentNode.childNodes;
for(var i=0,l=rows.length;i<l;i++){
if(inTr==rows[i]){
return i;
}
}
return -1;
};
turbo.getTableRow=function(_40c,_40d){
if(!_40c){
return null;
}
if(_40c.rows&&_40c.rows.length>0){
return _40c.rows[_40d];
}else{
if(_40c.childNodes.length>_40d){
return _40c.childNodes[_40d];
}else{
return null;
}
}
};
turbo.getWindowSize=function(){
if(window.innerWidth){
return {w:window.innerWidth,h:window.innerHeight};
}else{
return {w:document.documentElement.clientWidth,h:document.documentElement.clientHeight};
}
};
turbo.getContentSize=function(_40e){
if(_40e&&_40e!=document.body){
return {w:dojo.style.getContentBoxWidth(_40e),h:dojo.style.getContentBoxHeight(_40e)};
}else{
return turbo.getWindowSize();
}
};
turbo.getInnerSize=function(_40f){
if(_40f&&_40f!=document.body){
return {w:dojo.style.getBorderBoxWidth(_40f),h:dojo.style.getBorderBoxHeight(_40f)};
}else{
return turbo.getWindowSize();
}
};
turbo.getOuterSize=function(_410){
if(_410&&_410!=document.body){
return {w:dojo.style.getMarginBoxWidth(_410),h:dojo.style.getMarginBoxHeight(_410)};
}else{
return turbo.getWindowSize();
}
};
turbo.setContentSize=function(_411,inW,inH){
var siz=turbo.getContentSize(_411);
if(inW>0&&inW!=siz.w){
_411.style.width=inW+"px";
}
if(inH>0&&inH!=siz.h){
_411.style.height=inH+"px";
}
};
turbo.setOuterSize=function(_415,inW,inH){
if(inW>=0){
dojo.style.setMarginBoxWidth(_415,inW);
}
if(inH>=0){
dojo.style.setMarginBoxHeight(_415,inH);
}
};
turbo.setBounds=function(_418,inL,inT,inW,inH){
if(!_418){
return;
}
with(_418.style){
if(inL>=0){
left=inL+"px";
}
if(inT>=0){
top=inT+"px";
}
}
turbo.setOuterSize(_418,inW,inH);
};
turbo.setStyle=function(_41d,_41e,_41f){
if(_41d&&_41d.style[_41e]!=_41f){
_41d.style[_41e]=_41f;
}
};
turbo.setStyleLeftPx=function(_420,_421){
turbo.setStyle(_420,"left",_421+"px");
};
turbo.setStyleTopPx=function(_422,_423){
turbo.setStyle(_422,"top",_423+"px");
};
turbo.setStyleWidthPx=function(_424,_425){
if(_425>=0){
turbo.setStyle(_424,"width",_425+"px");
}
};
turbo.setStyleHeightPx=function(_426,_427){
if(_427>=0){
turbo.setStyle(_426,"height",_427+"px");
}
};
turbo.setStyleSizePx=function(_428,_429,_42a){
turbo.setStyleWidthPx(_428,_429);
turbo.setStyleHeightPx(_428,_42a);
};
turbo.setStyleBoundsPx=function(_42b,_42c,_42d,_42e,_42f){
turbo.setVisibility(_42b,false);
turbo.setStyleLeftPx(_42b,_42c);
turbo.setStyleTopPx(_42b,_42d);
turbo.setStyleWidthPx(_42b,_42e);
turbo.setStyleHeightPx(_42b,_42f);
turbo.setVisibility(_42b,true);
};
turbo.setOuterStyleWidthPx=function(_430,_431){
if(_430){
dojo.style.setMarginBoxWidth(_430,_431);
}
};
turbo.setOuterStyleHeightPx=function(_432,_433){
if(_432){
dojo.style.setMarginBoxHeight(_432,_433);
}
};
turbo.debugOut=function(_434){
dojo.debug(_434);
};
turbo.debugArray=function(_435){
for(var i=0,l=_435.length;i<l;i++){
if(_435[i]){
turbo.debug(i+":",_435[i]);
}
}
};
turbo.debugNode=function(_437,_438){
turbo.debugOut(_438+"(node) "+_437.tagName);
};
turbo.debugObjs=[];
turbo.debugObject=function(_439,_43a){
if(!_43a){
_43a="";
}
if(_439.nodeName){
turbo.debugNode(_439,_43a);
}else{
if(_43a.length>6*10){
turbo.debugOut(_43a+"too deep");
}else{
if(dojo.lang.inArray(turbo.debugObjs,_439)){
turbo.debugOut(_43a+"(circular reference)");
}else{
var l=turbo.debugObjs.length;
turbo.debugObjs.push(_439);
try{
for(var name in _439){
var obj=_439[name];
s=_43a+"| "+name;
if(obj!=null&&typeof (obj)=="object"){
turbo.debugOut(s+" = ("+(obj instanceof Array?"array":"object")+")");
turbo.debugObject(obj,_43a+"......");
}else{
turbo.debugOut(s+" = "+obj);
}
}
}
finally{
delete turbo.debugObjs[l];
}
}
}
}
};
turbo.debugTop=function(_43e,_43f){
if(!_43f){
_43f="";
}
for(var name in _43e){
var obj=_43e[name];
s=_43f+name;
if(obj!=null&&typeof (obj)=="object"){
turbo.debugOut(s+" = ("+(obj instanceof Array?"array":"object")+")");
}else{
turbo.debugOut(s+" = "+obj);
}
}
};
turbo.debugf=function(){
turbo.debug(turbo.printf.apply(turbo,arguments));
};
turbo.debug=function(){
var c=arguments.length;
for(var i=0;i<c;i++){
if(dojo.lang.isArray(arguments[i])){
turbo.debugArray(arguments[i]);
}else{
if(dojo.lang.isObject(arguments[i])){
turbo.debugTop(arguments[i]);
}else{
turbo.debugOut(arguments[i]);
}
}
}
};
turbo.setShowing=function(_444,_445){
_444=turbo.$(_444);
if(_444&&_444.style){
_444.style.display=(_445?"":"none");
}
};
turbo.showHide=function(){
var l=arguments.length-1;
var show=arguments[l];
if(show!==true&&show!==false){
show=true;
l++;
}
for(var i=0;i<l;i++){
turbo.setShowing(arguments[i],show);
}
};
turbo.show=turbo.showHide;
turbo.hide=function(){
var l=arguments.length;
for(var i=0;i<l;i++){
turbo.setShowing(arguments[i],false);
}
};
turbo.isShowing=function(_44b){
_44b=turbo.$(_44b);
if(!_44b||(_44b["style"]&&dojo.style.getComputedStyle(_44b,"display")=="none")){
return false;
}else{
if(_44b["parentNode"]&&_44b.parentNode&&_44b.parentNode!=document.body){
return turbo.showing(_44b.parentNode);
}else{
return true;
}
}
};
turbo.showing=turbo.isShowing;
turbo.setVisibility=function(_44c,_44d){
_44c=turbo.$(_44c);
if(_44c&&_44c.style){
_44c.style.visibility=(_44d?"":"hidden");
}
};
turbo.setStyleProperties=function(_44e,_44f){
if(!_44e||!_44e.style){
return;
}
for(var i in _44f){
if(i=="opacity"){
dojo.style.setOpacity(_44e,_44f[i]);
}else{
if(i in _44e.style){
_44e.style[i]=_44f[i];
}
}
}
};
turbo.clean=function(_451){
if(!_451){
return;
}
var _452=function(inW){
return inW.domNode&&dojo.dom.isDescendantOf(inW.domNode,_451,true);
};
var ws=dojo.widget.byFilter(_452);
for(var i=0;i<ws.length;i++){
var w=ws[i];
if(dojo.widget.widgetIds[w.widgetId]==w){
w.destroy();
}
}
dojo.event.browser.clean(_451);
};
turbo.killEvent=function(e){
if(e){
dojo.event.browser.stopEvent(e);
}
};
turbo.parseWidgets=function(_458,_459){
try{
var n,parser=new dojo.xml.Parse(),sids=(_459?_459:djConfig.searchIds);
if(sids&&sids.length>0){
for(var i=0,l=sids.length;i<l;i++){
n=document.getElementById(sids[i]);
if(n){
dojo.widget.getParser().createComponents(parser.parseElement(n,null,true));
}
}
}else{
dojo.widget.getParser().createSubComponents(parser.parseElement(_458,null,true));
}
}
catch(e){
turbo.debug("turbo.makeWidgets: an exception was thrown",e);
}
};
turbo.scripts=[];
turbo.loadScript=function(_45c){
if(turbo.scripts[_45c]){
return;
}
turbo.scripts[_45c]=true;
dojo.io.bind({url:_45c,load:function(type,_45e){
},error:function(type,_460){
},mimetype:"text/javascript",sync:true});
};
turbo.loadScriptByTag=function(_461){
if(turbo.scripts[_461]){
return;
}
turbo.scripts[_461]=true;
var _462=document.createElement("script");
_462.type="text/javascript";
_462.language="JavaScript";
turbo.addHeadNode(_462);
_462.src=_461;
};
dojo.provide("turbo.lib.align");
dojo.require("turbo.turbo");
turbo.aligner=new function(){
this.enabled=false;
this.targets=[];
this.getAlignment=function(_463){
return _463.getAttribute("turboAlign")||_463.getAttribute("turboalign");
};
this.visible=function(_464){
return (dojo.style.getComputedStyle(_464,"display")!="none");
};
this.listChildrenByAlignment=function(_465,_466){
var _467=[];
var node=_465.firstChild;
while(node){
if(node.nodeType==1&&this.getAlignment(node)==_466&&this.visible(node)){
_467.push(node);
}
node=node.nextSibling;
}
return _467;
};
this.listAlignedChildren=function(_469){
var _46a={none:[],top:[],left:[],client:[],right:[],bottom:[]};
var node=_469.firstChild;
while(node){
if(node.nodeType==1&&this.visible(node)){
var _46c=this.getAlignment(node);
if(_46c){
if(_46a[_46c]){
_46a[_46c].push(node);
}else{
_46a[_46c]=[node];
}
}
}
node=node.nextSibling;
}
return _46a;
};
this.setStylePosition=function(_46d,_46e){
if(_46d.style.position!=_46e){
_46d.style.position=_46e;
}
};
this.normalizeAlignedElement=function(_46f){
this.setStylePosition(_46f,"absolute");
};
this.alignElement=function(_470,inL,inT,inW,inH){
this.normalizeAlignedElement(_470);
turbo.setBounds(_470,inL,inT,inW,inH);
this.alignChildren(_470);
};
this.alignChildren=function(_475){
var _476=this.listAlignedChildren(_475);
var siz=turbo.getContentSize(_475);
var top=dojo.style.getPixelValue(_475,"padding-top",true);
var left=dojo.style.getPixelValue(_475,"padding-left",true);
var l,r,t,b,w,h,c,aligns;
aligns=_476.none;
for(var i=0;i<aligns.length;i++){
var p=dojo.style.getComputedStyle(aligns[i],"position");
if(p!="relative"&&p!="absolute"){
this.setStylePosition(aligns[i],"relative");
}
}
aligns=_476.top;
t=top;
for(var i=0;i<aligns.length;i++){
this.alignElement(aligns[i],left,t,siz.w);
t+=aligns[i].offsetHeight;
}
aligns=_476.bottom;
b=siz.h+top;
c=aligns.length;
for(var i=c-1;i>=0;i--){
b-=aligns[i].offsetHeight;
this.alignElement(aligns[i],left,b,siz.w);
}
h=b-t;
aligns=_476.left;
l=left;
for(var i=0;i<aligns.length;i++){
this.alignElement(aligns[i],l,t,-1,h);
l+=aligns[i].offsetWidth;
}
aligns=_476.right;
r=siz.w+left;
c=aligns.length;
for(var i=c-1;i>=0;i--){
r-=aligns[i].offsetWidth;
this.alignElement(aligns[i],r,t,-1,h);
}
w=r-l;
aligns=_476.client;
for(var i=0;i<aligns.length;i++){
this.alignElement(aligns[i],l,t,w,h);
break;
}
aligns=_476.none;
for(var i=0;i<aligns.length;i++){
this.alignChildren(aligns[i]);
}
};
this.alignTargets=function(){
for(var i=0,l=turbo.aligner.targets.length;i<l;i++){
turbo.aligner.alignChildren(turbo.aligner.targets[i]);
}
};
this.alignFrom=function(_47e){
turbo.aligner.alignChildren(_47e);
};
this.alignNow=function(){
turbo.aligner.alignFrom(document.body);
turbo.aligner.alignTargets();
};
this.lastAlign=0;
this.align=function(){
if(!turbo.aligner.enabled){
return;
}
turbo.aligner.alignNow();
};
this.alignLater=function(_47f){
turbo.defer(turbo.aligner.align,(_47f?_47f:200));
};
this.enable=function(_480){
turbo.aligner.enabled=(_480!==false);
};
this.start=function(){
turbo.aligner.enable();
turbo.aligner.alignLater(500);
};
this.addTarget=function(_481){
var e=(dojo.lang.isString(_481)?turbo.$(_481):_481);
e.style.position="relative";
turbo.aligner.targets.push(e);
};
};
dojo.provide("dojo.event");
dojo.require("dojo.lang.array");
dojo.require("dojo.lang.extras");
dojo.require("dojo.lang.func");
dojo.event=new function(){
this.canTimeout=dojo.lang.isFunction(dj_global["setTimeout"])||dojo.lang.isAlien(dj_global["setTimeout"]);
function interpolateArgs(args){
var dl=dojo.lang;
var ao={srcObj:dj_global,srcFunc:null,adviceObj:dj_global,adviceFunc:null,aroundObj:null,aroundFunc:null,adviceType:(args.length>2)?args[0]:"after",precedence:"last",once:false,delay:null,rate:0,adviceMsg:false};
switch(args.length){
case 0:
return;
case 1:
return;
case 2:
ao.srcFunc=args[0];
ao.adviceFunc=args[1];
break;
case 3:
if((dl.isObject(args[0]))&&(dl.isString(args[1]))&&(dl.isString(args[2]))){
ao.adviceType="after";
ao.srcObj=args[0];
ao.srcFunc=args[1];
ao.adviceFunc=args[2];
}else{
if((dl.isString(args[1]))&&(dl.isString(args[2]))){
ao.srcFunc=args[1];
ao.adviceFunc=args[2];
}else{
if((dl.isObject(args[0]))&&(dl.isString(args[1]))&&(dl.isFunction(args[2]))){
ao.adviceType="after";
ao.srcObj=args[0];
ao.srcFunc=args[1];
var _486=dojo.lang.nameAnonFunc(args[2],ao.adviceObj);
ao.adviceFunc=_486;
}else{
if((dl.isFunction(args[0]))&&(dl.isObject(args[1]))&&(dl.isString(args[2]))){
ao.adviceType="after";
ao.srcObj=dj_global;
var _486=dojo.lang.nameAnonFunc(args[0],ao.srcObj);
ao.srcFunc=_486;
ao.adviceObj=args[1];
ao.adviceFunc=args[2];
}
}
}
}
break;
case 4:
if((dl.isObject(args[0]))&&(dl.isObject(args[2]))){
ao.adviceType="after";
ao.srcObj=args[0];
ao.srcFunc=args[1];
ao.adviceObj=args[2];
ao.adviceFunc=args[3];
}else{
if((dl.isString(args[0]))&&(dl.isString(args[1]))&&(dl.isObject(args[2]))){
ao.adviceType=args[0];
ao.srcObj=dj_global;
ao.srcFunc=args[1];
ao.adviceObj=args[2];
ao.adviceFunc=args[3];
}else{
if((dl.isString(args[0]))&&(dl.isFunction(args[1]))&&(dl.isObject(args[2]))){
ao.adviceType=args[0];
ao.srcObj=dj_global;
var _486=dojo.lang.nameAnonFunc(args[1],dj_global);
ao.srcFunc=_486;
ao.adviceObj=args[2];
ao.adviceFunc=args[3];
}else{
if((dl.isString(args[0]))&&(dl.isObject(args[1]))&&(dl.isString(args[2]))&&(dl.isFunction(args[3]))){
ao.srcObj=args[1];
ao.srcFunc=args[2];
var _486=dojo.lang.nameAnonFunc(args[3],dj_global);
ao.adviceObj=dj_global;
ao.adviceFunc=_486;
}else{
if(dl.isObject(args[1])){
ao.srcObj=args[1];
ao.srcFunc=args[2];
ao.adviceObj=dj_global;
ao.adviceFunc=args[3];
}else{
if(dl.isObject(args[2])){
ao.srcObj=dj_global;
ao.srcFunc=args[1];
ao.adviceObj=args[2];
ao.adviceFunc=args[3];
}else{
ao.srcObj=ao.adviceObj=ao.aroundObj=dj_global;
ao.srcFunc=args[1];
ao.adviceFunc=args[2];
ao.aroundFunc=args[3];
}
}
}
}
}
}
break;
case 6:
ao.srcObj=args[1];
ao.srcFunc=args[2];
ao.adviceObj=args[3];
ao.adviceFunc=args[4];
ao.aroundFunc=args[5];
ao.aroundObj=dj_global;
break;
default:
ao.srcObj=args[1];
ao.srcFunc=args[2];
ao.adviceObj=args[3];
ao.adviceFunc=args[4];
ao.aroundObj=args[5];
ao.aroundFunc=args[6];
ao.once=args[7];
ao.delay=args[8];
ao.rate=args[9];
ao.adviceMsg=args[10];
break;
}
if(dl.isFunction(ao.aroundFunc)){
var _486=dojo.lang.nameAnonFunc(ao.aroundFunc,ao.aroundObj);
ao.aroundFunc=_486;
}
if(!dl.isString(ao.srcFunc)){
ao.srcFunc=dojo.lang.getNameInObj(ao.srcObj,ao.srcFunc);
}
if(!dl.isString(ao.adviceFunc)){
ao.adviceFunc=dojo.lang.getNameInObj(ao.adviceObj,ao.adviceFunc);
}
if((ao.aroundObj)&&(!dl.isString(ao.aroundFunc))){
ao.aroundFunc=dojo.lang.getNameInObj(ao.aroundObj,ao.aroundFunc);
}
if(!ao.srcObj){
dojo.raise("bad srcObj for srcFunc: "+ao.srcFunc);
}
if(!ao.adviceObj){
dojo.raise("bad adviceObj for adviceFunc: "+ao.adviceFunc);
}
return ao;
}
this.connect=function(){
if(arguments.length==1){
var ao=arguments[0];
}else{
var ao=interpolateArgs(arguments);
}
if(dojo.lang.isArray(ao.srcObj)&&ao.srcObj!=""){
var _488={};
for(var x in ao){
_488[x]=ao[x];
}
var mjps=[];
dojo.lang.forEach(ao.srcObj,function(src){
if((dojo.render.html.capable)&&(dojo.lang.isString(src))){
src=dojo.byId(src);
}
_488.srcObj=src;
mjps.push(dojo.event.connect.call(dojo.event,_488));
});
return mjps;
}
var mjp=dojo.event.MethodJoinPoint.getForMethod(ao.srcObj,ao.srcFunc);
if(ao.adviceFunc){
var mjp2=dojo.event.MethodJoinPoint.getForMethod(ao.adviceObj,ao.adviceFunc);
}
mjp.kwAddAdvice(ao);
return mjp;
};
this.log=function(a1,a2){
var _490;
if((arguments.length==1)&&(typeof a1=="object")){
_490=a1;
}else{
_490={srcObj:a1,srcFunc:a2};
}
_490.adviceFunc=function(){
var _491=[];
for(var x=0;x<arguments.length;x++){
_491.push(arguments[x]);
}
dojo.debug("("+_490.srcObj+")."+_490.srcFunc,":",_491.join(", "));
};
this.kwConnect(_490);
};
this.connectBefore=function(){
var args=["before"];
for(var i=0;i<arguments.length;i++){
args.push(arguments[i]);
}
return this.connect.apply(this,args);
};
this.connectAround=function(){
var args=["around"];
for(var i=0;i<arguments.length;i++){
args.push(arguments[i]);
}
return this.connect.apply(this,args);
};
this.connectOnce=function(){
var ao=interpolateArgs(arguments);
ao.once=true;
return this.connect(ao);
};
this._kwConnectImpl=function(_498,_499){
var fn=(_499)?"disconnect":"connect";
if(typeof _498["srcFunc"]=="function"){
_498.srcObj=_498["srcObj"]||dj_global;
var _49b=dojo.lang.nameAnonFunc(_498.srcFunc,_498.srcObj);
_498.srcFunc=_49b;
}
if(typeof _498["adviceFunc"]=="function"){
_498.adviceObj=_498["adviceObj"]||dj_global;
var _49b=dojo.lang.nameAnonFunc(_498.adviceFunc,_498.adviceObj);
_498.adviceFunc=_49b;
}
return dojo.event[fn]((_498["type"]||_498["adviceType"]||"after"),_498["srcObj"]||dj_global,_498["srcFunc"],_498["adviceObj"]||_498["targetObj"]||dj_global,_498["adviceFunc"]||_498["targetFunc"],_498["aroundObj"],_498["aroundFunc"],_498["once"],_498["delay"],_498["rate"],_498["adviceMsg"]||false);
};
this.kwConnect=function(_49c){
return this._kwConnectImpl(_49c,false);
};
this.disconnect=function(){
var ao=interpolateArgs(arguments);
if(!ao.adviceFunc){
return;
}
var mjp=dojo.event.MethodJoinPoint.getForMethod(ao.srcObj,ao.srcFunc);
return mjp.removeAdvice(ao.adviceObj,ao.adviceFunc,ao.adviceType,ao.once);
};
this.kwDisconnect=function(_49f){
return this._kwConnectImpl(_49f,true);
};
};
dojo.event.MethodInvocation=function(_4a0,obj,args){
this.jp_=_4a0;
this.object=obj;
this.args=[];
for(var x=0;x<args.length;x++){
this.args[x]=args[x];
}
this.around_index=-1;
};
dojo.event.MethodInvocation.prototype.proceed=function(){
this.around_index++;
if(this.around_index>=this.jp_.around.length){
return this.jp_.object[this.jp_.methodname].apply(this.jp_.object,this.args);
}else{
var ti=this.jp_.around[this.around_index];
var mobj=ti[0]||dj_global;
var meth=ti[1];
return mobj[meth].call(mobj,this);
}
};
dojo.event.MethodJoinPoint=function(obj,_4a8){
this.object=obj||dj_global;
this.methodname=_4a8;
this.methodfunc=this.object[_4a8];
this.before=[];
this.after=[];
this.around=[];
};
dojo.event.MethodJoinPoint.getForMethod=function(obj,_4aa){
if(!obj){
obj=dj_global;
}
if(!obj[_4aa]){
obj[_4aa]=function(){
};
}else{
if((!dojo.lang.isFunction(obj[_4aa]))&&(!dojo.lang.isAlien(obj[_4aa]))){
return null;
}
}
var _4ab=_4aa+"$joinpoint";
var _4ac=_4aa+"$joinpoint$method";
var _4ad=obj[_4ab];
if(!_4ad){
var _4ae=false;
if(dojo.event["browser"]){
if((obj["attachEvent"])||(obj["nodeType"])||(obj["addEventListener"])){
_4ae=true;
dojo.event.browser.addClobberNodeAttrs(obj,[_4ab,_4ac,_4aa]);
}
}
var _4af=obj[_4aa].length;
obj[_4ac]=obj[_4aa];
_4ad=obj[_4ab]=new dojo.event.MethodJoinPoint(obj,_4ac);
obj[_4aa]=function(){
var args=[];
if((_4ae)&&(!arguments.length)){
var evt=null;
try{
if(obj.ownerDocument){
evt=obj.ownerDocument.parentWindow.event;
}else{
if(obj.documentElement){
evt=obj.documentElement.ownerDocument.parentWindow.event;
}else{
evt=window.event;
}
}
}
catch(e){
evt=window.event;
}
if(evt){
args.push(dojo.event.browser.fixEvent(evt,this));
}
}else{
for(var x=0;x<arguments.length;x++){
if((x==0)&&(_4ae)&&(dojo.event.browser.isEvent(arguments[x]))){
args.push(dojo.event.browser.fixEvent(arguments[x],this));
}else{
args.push(arguments[x]);
}
}
}
return _4ad.run.apply(_4ad,args);
};
obj[_4aa].__preJoinArity=_4af;
}
return _4ad;
};
dojo.lang.extend(dojo.event.MethodJoinPoint,{unintercept:function(){
this.object[this.methodname]=this.methodfunc;
this.before=[];
this.after=[];
this.around=[];
},disconnect:dojo.lang.forward("unintercept"),run:function(){
var obj=this.object||dj_global;
var args=arguments;
var _4b5=[];
for(var x=0;x<args.length;x++){
_4b5[x]=args[x];
}
var _4b7=function(marr){
if(!marr){
dojo.debug("Null argument to unrollAdvice()");
return;
}
var _4b9=marr[0]||dj_global;
var _4ba=marr[1];
if(!_4b9[_4ba]){
dojo.raise("function \""+_4ba+"\" does not exist on \""+_4b9+"\"");
}
var _4bb=marr[2]||dj_global;
var _4bc=marr[3];
var msg=marr[6];
var _4be;
var to={args:[],jp_:this,object:obj,proceed:function(){
return _4b9[_4ba].apply(_4b9,to.args);
}};
to.args=_4b5;
var _4c0=parseInt(marr[4]);
var _4c1=((!isNaN(_4c0))&&(marr[4]!==null)&&(typeof marr[4]!="undefined"));
if(marr[5]){
var rate=parseInt(marr[5]);
var cur=new Date();
var _4c4=false;
if((marr["last"])&&((cur-marr.last)<=rate)){
if(dojo.event.canTimeout){
if(marr["delayTimer"]){
clearTimeout(marr.delayTimer);
}
var tod=parseInt(rate*2);
var mcpy=dojo.lang.shallowCopy(marr);
marr.delayTimer=setTimeout(function(){
mcpy[5]=0;
_4b7(mcpy);
},tod);
}
return;
}else{
marr.last=cur;
}
}
if(_4bc){
_4bb[_4bc].call(_4bb,to);
}else{
if((_4c1)&&((dojo.render.html)||(dojo.render.svg))){
dj_global["setTimeout"](function(){
if(msg){
_4b9[_4ba].call(_4b9,to);
}else{
_4b9[_4ba].apply(_4b9,args);
}
},_4c0);
}else{
if(msg){
_4b9[_4ba].call(_4b9,to);
}else{
_4b9[_4ba].apply(_4b9,args);
}
}
}
};
if(this.before.length>0){
dojo.lang.forEach(this.before,_4b7);
}
var _4c7;
if(this.around.length>0){
var mi=new dojo.event.MethodInvocation(this,obj,args);
_4c7=mi.proceed();
}else{
if(this.methodfunc){
_4c7=this.object[this.methodname].apply(this.object,args);
}
}
if(this.after.length>0){
dojo.lang.forEach(this.after,_4b7);
}
return (this.methodfunc)?_4c7:null;
},getArr:function(kind){
var arr=this.after;
if((typeof kind=="string")&&(kind.indexOf("before")!=-1)){
arr=this.before;
}else{
if(kind=="around"){
arr=this.around;
}
}
return arr;
},kwAddAdvice:function(args){
this.addAdvice(args["adviceObj"],args["adviceFunc"],args["aroundObj"],args["aroundFunc"],args["adviceType"],args["precedence"],args["once"],args["delay"],args["rate"],args["adviceMsg"]);
},addAdvice:function(_4cc,_4cd,_4ce,_4cf,_4d0,_4d1,once,_4d3,rate,_4d5){
var arr=this.getArr(_4d0);
if(!arr){
dojo.raise("bad this: "+this);
}
var ao=[_4cc,_4cd,_4ce,_4cf,_4d3,rate,_4d5];
if(once){
if(this.hasAdvice(_4cc,_4cd,_4d0,arr)>=0){
return;
}
}
if(_4d1=="first"){
arr.unshift(ao);
}else{
arr.push(ao);
}
},hasAdvice:function(_4d8,_4d9,_4da,arr){
if(!arr){
arr=this.getArr(_4da);
}
var ind=-1;
for(var x=0;x<arr.length;x++){
if((arr[x][0]==_4d8)&&(arr[x][1]==_4d9)){
ind=x;
}
}
return ind;
},removeAdvice:function(_4de,_4df,_4e0,once){
var arr=this.getArr(_4e0);
var ind=this.hasAdvice(_4de,_4df,_4e0,arr);
if(ind==-1){
return false;
}
while(ind!=-1){
arr.splice(ind,1);
if(once){
break;
}
ind=this.hasAdvice(_4de,_4df,_4e0,arr);
}
return true;
}});
dojo.require("dojo.event");
dojo.provide("dojo.event.topic");
dojo.event.topic=new function(){
this.topics={};
this.getTopic=function(_4e4){
if(!this.topics[_4e4]){
this.topics[_4e4]=new this.TopicImpl(_4e4);
}
return this.topics[_4e4];
};
this.registerPublisher=function(_4e5,obj,_4e7){
var _4e5=this.getTopic(_4e5);
_4e5.registerPublisher(obj,_4e7);
};
this.subscribe=function(_4e8,obj,_4ea){
var _4e8=this.getTopic(_4e8);
_4e8.subscribe(obj,_4ea);
};
this.unsubscribe=function(_4eb,obj,_4ed){
var _4eb=this.getTopic(_4eb);
_4eb.unsubscribe(obj,_4ed);
};
this.destroy=function(_4ee){
this.getTopic(_4ee).destroy();
delete this.topics[_4ee];
};
this.publish=function(_4ef,_4f0){
var _4ef=this.getTopic(_4ef);
var args=[];
if(arguments.length==2&&(dojo.lang.isArray(_4f0)||_4f0.callee)){
args=_4f0;
}else{
var args=[];
for(var x=1;x<arguments.length;x++){
args.push(arguments[x]);
}
}
_4ef.sendMessage.apply(_4ef,args);
};
};
dojo.event.topic.TopicImpl=function(_4f3){
this.topicName=_4f3;
this.subscribe=function(_4f4,_4f5){
var tf=_4f5||_4f4;
var to=(!_4f5)?dj_global:_4f4;
dojo.event.kwConnect({srcObj:this,srcFunc:"sendMessage",adviceObj:to,adviceFunc:tf});
};
this.unsubscribe=function(_4f8,_4f9){
var tf=(!_4f9)?_4f8:_4f9;
var to=(!_4f9)?null:_4f8;
dojo.event.kwDisconnect({srcObj:this,srcFunc:"sendMessage",adviceObj:to,adviceFunc:tf});
};
this.destroy=function(){
dojo.event.MethodJoinPoint.getForMethod(this,"sendMessage").disconnect();
};
this.registerPublisher=function(_4fc,_4fd){
dojo.event.connect(_4fc,_4fd,this,"sendMessage");
};
this.sendMessage=function(_4fe){
};
};
dojo.provide("dojo.event.browser");
dojo.require("dojo.event");
dojo_ie_clobber=new function(){
this.clobberNodes=[];
function nukeProp(node,prop){
try{
node[prop]=null;
}
catch(e){
}
try{
delete node[prop];
}
catch(e){
}
try{
node.removeAttribute(prop);
}
catch(e){
}
}
this.clobber=function(_501){
var na;
var tna;
if(_501){
tna=_501.all||_501.getElementsByTagName("*");
na=[_501];
for(var x=0;x<tna.length;x++){
if(tna[x]["__doClobber__"]){
na.push(tna[x]);
}
}
}else{
try{
window.onload=null;
}
catch(e){
}
na=(this.clobberNodes.length)?this.clobberNodes:document.all;
}
tna=null;
var _505={};
for(var i=na.length-1;i>=0;i=i-1){
var el=na[i];
if(el["__clobberAttrs__"]){
for(var j=0;j<el.__clobberAttrs__.length;j++){
nukeProp(el,el.__clobberAttrs__[j]);
}
nukeProp(el,"__clobberAttrs__");
nukeProp(el,"__doClobber__");
}
}
na=null;
};
};
if(dojo.render.html.ie){
window.onunload=function(){
dojo_ie_clobber.clobber();
try{
if((dojo["widget"])&&(dojo.widget["manager"])){
dojo.widget.manager.destroyAll();
}
}
catch(e){
}
try{
window.onload=null;
}
catch(e){
}
try{
window.onunload=null;
}
catch(e){
}
dojo_ie_clobber.clobberNodes=[];
};
}
dojo.event.browser=new function(){
var _509=0;
this.clean=function(node){
if(dojo.render.html.ie){
dojo_ie_clobber.clobber(node);
}
};
this.addClobberNode=function(node){
if(!node["__doClobber__"]){
node.__doClobber__=true;
dojo_ie_clobber.clobberNodes.push(node);
node.__clobberAttrs__=[];
}
};
this.addClobberNodeAttrs=function(node,_50d){
this.addClobberNode(node);
for(var x=0;x<_50d.length;x++){
node.__clobberAttrs__.push(_50d[x]);
}
};
this.removeListener=function(node,_510,fp,_512){
if(!_512){
var _512=false;
}
_510=_510.toLowerCase();
if(_510.substr(0,2)=="on"){
_510=_510.substr(2);
}
if(node.removeEventListener){
node.removeEventListener(_510,fp,_512);
}
};
this.addListener=function(node,_514,fp,_516,_517){
if(!node){
return;
}
if(!_516){
var _516=false;
}
_514=_514.toLowerCase();
if(_514.substr(0,2)!="on"){
_514="on"+_514;
}
if(!_517){
var _518=function(evt){
if(!evt){
evt=window.event;
}
var ret=fp(dojo.event.browser.fixEvent(evt,this));
if(_516){
dojo.event.browser.stopEvent(evt);
}
return ret;
};
}else{
_518=fp;
}
if(node.addEventListener){
node.addEventListener(_514.substr(2),_518,_516);
return _518;
}else{
if(typeof node[_514]=="function"){
var _51b=node[_514];
node[_514]=function(e){
_51b(e);
return _518(e);
};
}else{
node[_514]=_518;
}
if(dojo.render.html.ie){
this.addClobberNodeAttrs(node,[_514]);
}
return _518;
}
};
this.isEvent=function(obj){
return (typeof obj!="undefined")&&(typeof Event!="undefined")&&(obj.eventPhase);
};
this.currentEvent=null;
this.callListener=function(_51e,_51f){
if(typeof _51e!="function"){
dojo.raise("listener not a function: "+_51e);
}
dojo.event.browser.currentEvent.currentTarget=_51f;
return _51e.call(_51f,dojo.event.browser.currentEvent);
};
this.stopPropagation=function(){
dojo.event.browser.currentEvent.cancelBubble=true;
};
this.preventDefault=function(){
dojo.event.browser.currentEvent.returnValue=false;
};
this.keys={KEY_BACKSPACE:8,KEY_TAB:9,KEY_ENTER:13,KEY_SHIFT:16,KEY_CTRL:17,KEY_ALT:18,KEY_PAUSE:19,KEY_CAPS_LOCK:20,KEY_ESCAPE:27,KEY_SPACE:32,KEY_PAGE_UP:33,KEY_PAGE_DOWN:34,KEY_END:35,KEY_HOME:36,KEY_LEFT_ARROW:37,KEY_UP_ARROW:38,KEY_RIGHT_ARROW:39,KEY_DOWN_ARROW:40,KEY_INSERT:45,KEY_DELETE:46,KEY_LEFT_WINDOW:91,KEY_RIGHT_WINDOW:92,KEY_SELECT:93,KEY_F1:112,KEY_F2:113,KEY_F3:114,KEY_F4:115,KEY_F5:116,KEY_F6:117,KEY_F7:118,KEY_F8:119,KEY_F9:120,KEY_F10:121,KEY_F11:122,KEY_F12:123,KEY_NUM_LOCK:144,KEY_SCROLL_LOCK:145};
this.revKeys=[];
for(var key in this.keys){
this.revKeys[this.keys[key]]=key;
}
this.fixEvent=function(evt,_522){
if((!evt)&&(window["event"])){
var evt=window.event;
}
if((evt["type"])&&(evt["type"].indexOf("key")==0)){
evt.keys=this.revKeys;
for(var key in this.keys){
evt[key]=this.keys[key];
}
if((dojo.render.html.ie)&&(evt["type"]=="keypress")){
evt.charCode=evt.keyCode;
}
}
if(dojo.render.html.ie){
if(!evt.target){
evt.target=evt.srcElement;
}
if(!evt.currentTarget){
evt.currentTarget=(_522?_522:evt.srcElement);
}
if(!evt.layerX){
evt.layerX=evt.offsetX;
}
if(!evt.layerY){
evt.layerY=evt.offsetY;
}
if(!evt.pageX){
evt.pageX=evt.clientX+(window.pageXOffset||document.documentElement.scrollLeft||document.body.scrollLeft||0);
}
if(!evt.pageY){
evt.pageY=evt.clientY+(window.pageYOffset||document.documentElement.scrollTop||document.body.scrollTop||0);
}
if(evt.type=="mouseover"){
evt.relatedTarget=evt.fromElement;
}
if(evt.type=="mouseout"){
evt.relatedTarget=evt.toElement;
}
this.currentEvent=evt;
evt.callListener=this.callListener;
evt.stopPropagation=this.stopPropagation;
evt.preventDefault=this.preventDefault;
}
return evt;
};
this.stopEvent=function(ev){
if(window.event){
ev.returnValue=false;
ev.cancelBubble=true;
}else{
ev.preventDefault();
ev.stopPropagation();
}
};
};
dojo.kwCompoundRequire({common:["dojo.event","dojo.event.topic"],browser:["dojo.event.browser"],dashboard:["dojo.event.browser"]});
dojo.provide("dojo.event.*");
dojo.provide("turbo.lib.app");
dojo.require("turbo.lib.align");
dojo.require("dojo.event.*");
turbo.app={marshall:function(){
var id="";
var _526=dj_global;
for(var i=0;i<arguments.length;i++){
id=arguments[i];
if(!_526[id]){
_526[id]=turbo.$(id);
}
}
return _526[id];
},onresize:function(){
},alignerAlign:function(){
this.onresize();
},resize:function(){
turbo.aligner.align();
},_windowResize:function(){
turbo.app.resize();
turbo.app.resizePending=null;
},windowResize:function(){
if(this.resizePending){
return;
}
this.resizePending=turbo.defer(turbo.app._windowResize,250);
},display:function(){
turbo.aligner.enable();
this._windowResize();
turbo.defer(turbo.app.windowResize,500);
turbo.remove("turboCurtain");
if(turbo.app.bodyOverflow!=undefined){
document.body.style.overflow=turbo.app.bodyOverflow;
}
if(turbo.turbo_disable_curtain||djConfig["turbo_disable_curtain"]){
this.showPageBody();
}
},encurtain:function(){
var d=document.createElement("div");
d.innerHTML=turbo.app.curtainHtml;
d.id="turboCurtain";
turbo.app.bodyOverflow=document.body.style.overflow;
document.body.style.overflow="hidden";
var siz=turbo.getContentSize(document.body);
with(d.style){
position="absolute";
zIndex=9999;
top="0";
left="0";
width="9999px";
height="9999px";
backgroundColor="white";
padding="16px";
}
document.body.insertBefore(d,document.body.firstChild);
this.showPageBody();
},showPageBody:function(){
document.body.style.display="block";
},init:function(){
},initialize:function(){
if(!turbo.turbo_disable_curtain&&!djConfig["turbo_disable_curtain"]){
this.encurtain();
}
try{
this.init();
}
catch(e){
dojo.debug("turbo.app.init failed: "+e);
turbo.debug(e);
}
turbo.defer(turbo.bind(this,this.display),100);
dojo.event.connect(turbo.aligner,"align",this,"alignerAlign");
dojo.event.connect(window,"onresize",this,"windowResize");
}};
turbo.app.curtainHtml="";
dojo.addOnLoad(turbo.app,"initialize");
if(false){
dojo.addOnLoad(function(){
showHideGrids=function(_52a){
var _52b=dojo.widget.getWidgetsByType("TurboGridClassic");
for(var i=0;i<_52b.length;i++){
turbo.showHide(_52b[i].domNode,_52a);
}
};
hideGrids=function(){
showHideGrids(false);
};
showGrids=function(){
showHideGrids(true);
};
dojo.event.connect("before",turbo.aligner,"align","hideGrids");
dojo.event.connect("after",turbo.aligner,"align","showGrids");
});
}
dojo.event.topic.registerPublisher("turboresize",turbo.app,"onresize");
dojo.provide("dojo.xml.Parse");
dojo.require("dojo.dom");
dojo.xml.Parse=function(){
function getDojoTagName(node){
var _52e=node.tagName;
if(_52e.substr(0,5).toLowerCase()!="dojo:"){
if(_52e.substr(0,4).toLowerCase()=="dojo"){
return "dojo:"+_52e.substring(4).toLowerCase();
}
var djt=node.getAttribute("dojoType")||node.getAttribute("dojotype");
if(djt){
return "dojo:"+djt.toLowerCase();
}
if(node.getAttributeNS&&node.getAttributeNS(dojo.dom.dojoml,"type")){
return "dojo:"+node.getAttributeNS(dojo.dom.dojoml,"type").toLowerCase();
}
try{
djt=node.getAttribute("dojo:type");
}
catch(e){
}
if(djt){
return "dojo:"+djt.toLowerCase();
}
if(!dj_global["djConfig"]||!djConfig["ignoreClassNames"]){
var _530=node.className||node.getAttribute("class");
if(_530&&_530.indexOf&&_530.indexOf("dojo-")!=-1){
var _531=_530.split(" ");
for(var x=0;x<_531.length;x++){
if(_531[x].length>5&&_531[x].indexOf("dojo-")>=0){
return "dojo:"+_531[x].substr(5).toLowerCase();
}
}
}
}
}
return _52e.toLowerCase();
}
this.parseElement=function(node,_534,_535,_536){
if(node.getAttribute("parseWidgets")=="false"){
return {};
}
var _537={};
var _538=getDojoTagName(node);
_537[_538]=[];
if((!_535)||(_538.substr(0,4).toLowerCase()=="dojo")){
var _539=parseAttributes(node);
for(var attr in _539){
if((!_537[_538][attr])||(typeof _537[_538][attr]!="array")){
_537[_538][attr]=[];
}
_537[_538][attr].push(_539[attr]);
}
_537[_538].nodeRef=node;
_537.tagName=_538;
_537.index=_536||0;
}
var _53b=0;
var tcn,i=0,nodes=node.childNodes;
while(tcn=nodes[i++]){
switch(tcn.nodeType){
case dojo.dom.ELEMENT_NODE:
_53b++;
var ctn=getDojoTagName(tcn);
if(!_537[ctn]){
_537[ctn]=[];
}
_537[ctn].push(this.parseElement(tcn,true,_535,_53b));
if((tcn.childNodes.length==1)&&(tcn.childNodes.item(0).nodeType==dojo.dom.TEXT_NODE)){
_537[ctn][_537[ctn].length-1].value=tcn.childNodes.item(0).nodeValue;
}
break;
case dojo.dom.TEXT_NODE:
if(node.childNodes.length==1){
_537[_538].push({value:node.childNodes.item(0).nodeValue});
}
break;
default:
break;
}
}
return _537;
};
function parseAttributes(node){
var _53f={};
var atts=node.attributes;
var _541,i=0;
while(_541=atts[i++]){
if((dojo.render.html.capable)&&(dojo.render.html.ie)){
if(!_541){
continue;
}
if((typeof _541=="object")&&(typeof _541.nodeValue=="undefined")||(_541.nodeValue==null)||(_541.nodeValue=="")){
continue;
}
}
var nn=(_541.nodeName.indexOf("dojo:")==-1)?_541.nodeName:_541.nodeName.split("dojo:")[1];
_53f[nn]={value:_541.nodeValue};
}
return _53f;
}
};
dojo.provide("dojo.widget.Manager");
dojo.require("dojo.lang.array");
dojo.require("dojo.lang.func");
dojo.require("dojo.event.*");
dojo.widget.manager=new function(){
this.widgets=[];
this.widgetIds=[];
this.topWidgets={};
var _543={};
var _544=[];
this.getUniqueId=function(_545){
return _545+"_"+(_543[_545]!=undefined?++_543[_545]:_543[_545]=0);
};
this.add=function(_546){
dojo.profile.start("dojo.widget.manager.add");
this.widgets.push(_546);
if(!_546.extraArgs["id"]){
_546.extraArgs["id"]=_546.extraArgs["ID"];
}
if(_546.widgetId==""){
if(_546["id"]){
_546.widgetId=_546["id"];
}else{
if(_546.extraArgs["id"]){
_546.widgetId=_546.extraArgs["id"];
}else{
_546.widgetId=this.getUniqueId(_546.widgetType);
}
}
}
if(this.widgetIds[_546.widgetId]){
dojo.debug("widget ID collision on ID: "+_546.widgetId);
}
this.widgetIds[_546.widgetId]=_546;
dojo.profile.end("dojo.widget.manager.add");
};
this.destroyAll=function(){
for(var x=this.widgets.length-1;x>=0;x--){
try{
this.widgets[x].destroy(true);
delete this.widgets[x];
}
catch(e){
}
}
};
this.remove=function(_548){
var tw=this.widgets[_548].widgetId;
delete this.widgetIds[tw];
this.widgets.splice(_548,1);
};
this.removeById=function(id){
for(var i=0;i<this.widgets.length;i++){
if(this.widgets[i].widgetId==id){
this.remove(i);
break;
}
}
};
this.getWidgetById=function(id){
return this.widgetIds[id];
};
this.getWidgetsByType=function(type){
var lt=type.toLowerCase();
var ret=[];
dojo.lang.forEach(this.widgets,function(x){
if(x.widgetType.toLowerCase()==lt){
ret.push(x);
}
});
return ret;
};
this.getWidgetsOfType=function(id){
dojo.deprecated("getWidgetsOfType","use getWidgetsByType","0.4");
return dojo.widget.manager.getWidgetsByType(id);
};
this.getWidgetsByFilter=function(_552,_553){
var ret=[];
dojo.lang.every(this.widgets,function(x){
if(_552(x)){
ret.push(x);
if(_553){
return false;
}
}
return true;
});
return (_553?ret[0]:ret);
};
this.getAllWidgets=function(){
return this.widgets.concat();
};
this.getWidgetByNode=function(node){
var w=this.getAllWidgets();
for(var i=0;i<w.length;i++){
if(w[i].domNode==node){
return w[i];
}
}
return null;
};
this.byId=this.getWidgetById;
this.byType=this.getWidgetsByType;
this.byFilter=this.getWidgetsByFilter;
this.byNode=this.getWidgetByNode;
var _559={};
var _55a=["dojo.widget"];
for(var i=0;i<_55a.length;i++){
_55a[_55a[i]]=true;
}
this.registerWidgetPackage=function(_55c){
if(!_55a[_55c]){
_55a[_55c]=true;
_55a.push(_55c);
}
};
this.getWidgetPackageList=function(){
return dojo.lang.map(_55a,function(elt){
return (elt!==true?elt:undefined);
});
};
this.getImplementation=function(_55e,_55f,_560){
var impl=this.getImplementationName(_55e);
if(impl){
var ret=new impl(_55f);
return ret;
}
};
this.getImplementationName=function(_563){
var _564=_563.toLowerCase();
var impl=_559[_564];
if(impl){
return impl;
}
if(!_544.length){
for(var _566 in dojo.render){
if(dojo.render[_566]["capable"]===true){
var _567=dojo.render[_566].prefixes;
for(var i=0;i<_567.length;i++){
_544.push(_567[i].toLowerCase());
}
}
}
_544.push("");
}
for(var i=0;i<_55a.length;i++){
var _569=dojo.evalObjPath(_55a[i]);
if(!_569){
continue;
}
for(var j=0;j<_544.length;j++){
if(!_569[_544[j]]){
continue;
}
for(var _56b in _569[_544[j]]){
if(_56b.toLowerCase()!=_564){
continue;
}
_559[_564]=_569[_544[j]][_56b];
return _559[_564];
}
}
for(var j=0;j<_544.length;j++){
for(var _56b in _569){
if(_56b.toLowerCase()!=(_544[j]+_564)){
continue;
}
_559[_564]=_569[_56b];
return _559[_564];
}
}
}
throw new Error("Could not locate \""+_563+"\" class");
};
this.resizing=false;
this.onWindowResized=function(){
if(this.resizing){
return;
}
try{
this.resizing=true;
for(var id in this.topWidgets){
var _56d=this.topWidgets[id];
if(_56d.onParentResized){
_56d.onParentResized();
}
}
}
catch(e){
}
finally{
this.resizing=false;
}
};
if(typeof window!="undefined"){
dojo.addOnLoad(this,"onWindowResized");
dojo.event.connect(window,"onresize",this,"onWindowResized");
}
};
(function(){
var dw=dojo.widget;
var dwm=dw.manager;
var h=dojo.lang.curry(dojo.lang,"hitch",dwm);
var g=function(_572,_573){
dw[(_573||_572)]=h(_572);
};
g("add","addWidget");
g("destroyAll","destroyAllWidgets");
g("remove","removeWidget");
g("removeById","removeWidgetById");
g("getWidgetById");
g("getWidgetById","byId");
g("getWidgetsByType");
g("getWidgetsByFilter");
g("getWidgetsByType","byType");
g("getWidgetsByFilter","byFilter");
g("getWidgetByNode","byNode");
dw.all=function(n){
var _575=dwm.getAllWidgets.apply(dwm,arguments);
if(arguments.length>0){
return _575[n];
}
return _575;
};
g("registerWidgetPackage");
g("getImplementation","getWidgetImplementation");
g("getImplementationName","getWidgetImplementationName");
dw.widgets=dwm.widgets;
dw.widgetIds=dwm.widgetIds;
dw.root=dwm.root;
})();
dojo.provide("dojo.widget.Widget");
dojo.provide("dojo.widget.tags");
dojo.require("dojo.lang.func");
dojo.require("dojo.lang.array");
dojo.require("dojo.lang.extras");
dojo.require("dojo.lang.declare");
dojo.require("dojo.widget.Manager");
dojo.require("dojo.event.*");
dojo.declare("dojo.widget.Widget",null,{initializer:function(){
this.children=[];
this.extraArgs={};
},parent:null,isTopLevel:false,isModal:false,isEnabled:true,isHidden:false,isContainer:false,widgetId:"",widgetType:"Widget",toString:function(){
return "[Widget "+this.widgetType+", "+(this.widgetId||"NO ID")+"]";
},repr:function(){
return this.toString();
},enable:function(){
this.isEnabled=true;
},disable:function(){
this.isEnabled=false;
},hide:function(){
this.isHidden=true;
},show:function(){
this.isHidden=false;
},onResized:function(){
this.notifyChildrenOfResize();
},notifyChildrenOfResize:function(){
for(var i=0;i<this.children.length;i++){
var _577=this.children[i];
if(_577.onResized){
_577.onResized();
}
}
},create:function(args,_579,_57a){
this.satisfyPropertySets(args,_579,_57a);
this.mixInProperties(args,_579,_57a);
this.postMixInProperties(args,_579,_57a);
dojo.widget.manager.add(this);
this.buildRendering(args,_579,_57a);
this.initialize(args,_579,_57a);
this.postInitialize(args,_579,_57a);
this.postCreate(args,_579,_57a);
return this;
},destroy:function(_57b){
this.destroyChildren();
this.uninitialize();
this.destroyRendering(_57b);
dojo.widget.manager.removeById(this.widgetId);
},destroyChildren:function(){
while(this.children.length>0){
var tc=this.children[0];
this.removeChild(tc);
tc.destroy();
}
},getChildrenOfType:function(type,_57e){
var ret=[];
var _580=dojo.lang.isFunction(type);
if(!_580){
type=type.toLowerCase();
}
for(var x=0;x<this.children.length;x++){
if(_580){
if(this.children[x] instanceof type){
ret.push(this.children[x]);
}
}else{
if(this.children[x].widgetType.toLowerCase()==type){
ret.push(this.children[x]);
}
}
if(_57e){
ret=ret.concat(this.children[x].getChildrenOfType(type,_57e));
}
}
return ret;
},getDescendants:function(){
var _582=[];
var _583=[this];
var elem;
while(elem=_583.pop()){
_582.push(elem);
dojo.lang.forEach(elem.children,function(elem){
_583.push(elem);
});
}
return _582;
},satisfyPropertySets:function(args){
return args;
},mixInProperties:function(args,frag){
if((args["fastMixIn"])||(frag["fastMixIn"])){
for(var x in args){
this[x]=args[x];
}
return;
}
var _58a;
var _58b=dojo.widget.lcArgsCache[this.widgetType];
if(_58b==null){
_58b={};
for(var y in this){
_58b[((new String(y)).toLowerCase())]=y;
}
dojo.widget.lcArgsCache[this.widgetType]=_58b;
}
var _58d={};
for(var x in args){
if(!this[x]){
var y=_58b[(new String(x)).toLowerCase()];
if(y){
args[y]=args[x];
x=y;
}
}
if(_58d[x]){
continue;
}
_58d[x]=true;
if((typeof this[x])!=(typeof _58a)){
if(typeof args[x]!="string"){
this[x]=args[x];
}else{
if(dojo.lang.isString(this[x])){
this[x]=args[x];
}else{
if(dojo.lang.isNumber(this[x])){
this[x]=new Number(args[x]);
}else{
if(dojo.lang.isBoolean(this[x])){
this[x]=(args[x].toLowerCase()=="false")?false:true;
}else{
if(dojo.lang.isFunction(this[x])){
if(args[x].search(/[^\w\.]+/i)==-1){
this[x]=dojo.evalObjPath(args[x],false);
}else{
var tn=dojo.lang.nameAnonFunc(new Function(args[x]),this);
dojo.event.connect(this,x,this,tn);
}
}else{
if(dojo.lang.isArray(this[x])){
this[x]=args[x].split(";");
}else{
if(this[x] instanceof Date){
this[x]=new Date(Number(args[x]));
}else{
if(typeof this[x]=="object"){
if(this[x] instanceof dojo.uri.Uri){
this[x]=args[x];
}else{
var _58f=args[x].split(";");
for(var y=0;y<_58f.length;y++){
var si=_58f[y].indexOf(":");
if((si!=-1)&&(_58f[y].length>si)){
this[x][_58f[y].substr(0,si).replace(/^\s+|\s+$/g,"")]=_58f[y].substr(si+1);
}
}
}
}else{
this[x]=args[x];
}
}
}
}
}
}
}
}
}else{
this.extraArgs[x.toLowerCase()]=args[x];
}
}
},postMixInProperties:function(){
},initialize:function(args,frag){
return false;
},postInitialize:function(args,frag){
return false;
},postCreate:function(args,frag){
return false;
},uninitialize:function(){
return false;
},buildRendering:function(){
dojo.unimplemented("dojo.widget.Widget.buildRendering, on "+this.toString()+", ");
return false;
},destroyRendering:function(){
dojo.unimplemented("dojo.widget.Widget.destroyRendering");
return false;
},cleanUp:function(){
dojo.unimplemented("dojo.widget.Widget.cleanUp");
return false;
},addedTo:function(_597){
},addChild:function(_598){
dojo.unimplemented("dojo.widget.Widget.addChild");
return false;
},removeChild:function(_599){
for(var x=0;x<this.children.length;x++){
if(this.children[x]===_599){
this.children.splice(x,1);
break;
}
}
return _599;
},resize:function(_59b,_59c){
this.setWidth(_59b);
this.setHeight(_59c);
},setWidth:function(_59d){
if((typeof _59d=="string")&&(_59d.substr(-1)=="%")){
this.setPercentageWidth(_59d);
}else{
this.setNativeWidth(_59d);
}
},setHeight:function(_59e){
if((typeof _59e=="string")&&(_59e.substr(-1)=="%")){
this.setPercentageHeight(_59e);
}else{
this.setNativeHeight(_59e);
}
},setPercentageHeight:function(_59f){
return false;
},setNativeHeight:function(_5a0){
return false;
},setPercentageWidth:function(_5a1){
return false;
},setNativeWidth:function(_5a2){
return false;
},getPreviousSibling:function(){
var idx=this.getParentIndex();
if(idx<=0){
return null;
}
return this.getSiblings()[idx-1];
},getSiblings:function(){
return this.parent.children;
},getParentIndex:function(){
return dojo.lang.indexOf(this.getSiblings(),this,true);
},getNextSibling:function(){
var idx=this.getParentIndex();
if(idx==this.getSiblings().length-1){
return null;
}
if(idx<0){
return null;
}
return this.getSiblings()[idx+1];
}});
dojo.widget.lcArgsCache={};
dojo.widget.tags={};
dojo.widget.tags.addParseTreeHandler=function(type){
var _5a6=type.toLowerCase();
this[_5a6]=function(_5a7,_5a8,_5a9,_5aa,_5ab){
return dojo.widget.buildWidgetFromParseTree(_5a6,_5a7,_5a8,_5a9,_5aa,_5ab);
};
};
dojo.widget.tags.addParseTreeHandler("dojo:widget");
dojo.widget.tags["dojo:propertyset"]=function(_5ac,_5ad,_5ae){
var _5af=_5ad.parseProperties(_5ac["dojo:propertyset"]);
};
dojo.widget.tags["dojo:connect"]=function(_5b0,_5b1,_5b2){
var _5b3=_5b1.parseProperties(_5b0["dojo:connect"]);
};
dojo.widget.buildWidgetFromParseTree=function(type,frag,_5b6,_5b7,_5b8,_5b9){
var _5ba=type.split(":");
_5ba=(_5ba.length==2)?_5ba[1]:type;
var _5bb=_5b9||_5b6.parseProperties(frag["dojo:"+_5ba]);
var _5bc=dojo.widget.manager.getImplementation(_5ba);
if(!_5bc){
throw new Error("cannot find \""+_5ba+"\" widget");
}else{
if(!_5bc.create){
throw new Error("\""+_5ba+"\" widget object does not appear to implement *Widget");
}
}
_5bb["dojoinsertionindex"]=_5b8;
var ret=_5bc.create(_5bb,frag,_5b7);
return ret;
};
dojo.widget.defineWidget=function(_5be,_5bf,_5c0,_5c1,ctor){
var _5c3=_5be.split(".");
var type=_5c3.pop();
if(_5c1){
while((_5c3.length)&&(_5c3.pop()!=_5c1)){
}
}
_5c3=_5c3.join(".");
dojo.widget.manager.registerWidgetPackage(_5c3);
dojo.widget.tags.addParseTreeHandler("dojo:"+type.toLowerCase());
if(!_5c0){
_5c0={};
}
_5c0.widgetType=type;
if((!ctor)&&(_5c0["classConstructor"])){
ctor=_5c0.classConstructor;
delete _5c0.classConstructor;
}
dojo.declare(_5be,_5bf,_5c0,ctor);
};
dojo.provide("dojo.widget.Parse");
dojo.require("dojo.widget.Manager");
dojo.require("dojo.dom");
dojo.widget.Parse=function(_5c5){
this.propertySetsList=[];
this.fragment=_5c5;
this.createComponents=function(frag,_5c7){
var _5c8=[];
var _5c9=false;
try{
if((frag)&&(frag["tagName"])&&(frag!=frag["nodeRef"])){
var _5ca=dojo.widget.tags;
var tna=String(frag["tagName"]).split(";");
for(var x=0;x<tna.length;x++){
var ltn=(tna[x].replace(/^\s+|\s+$/g,"")).toLowerCase();
if(_5ca[ltn]){
_5c9=true;
frag.tagName=ltn;
var ret=_5ca[ltn](frag,this,_5c7,frag["index"]);
_5c8.push(ret);
}else{
if((dojo.lang.isString(ltn))&&(ltn.substr(0,5)=="dojo:")){
dojo.debug("no tag handler registed for type: ",ltn);
}
}
}
}
}
catch(e){
dojo.debug("dojo.widget.Parse: error:",e);
}
if(!_5c9){
_5c8=_5c8.concat(this.createSubComponents(frag,_5c7));
}
return _5c8;
};
this.createSubComponents=function(_5cf,_5d0){
var frag,comps=[];
for(var item in _5cf){
frag=_5cf[item];
if((frag)&&(typeof frag=="object")&&(frag!=_5cf.nodeRef)&&(frag!=_5cf["tagName"])){
comps=comps.concat(this.createComponents(frag,_5d0));
}
}
return comps;
};
this.parsePropertySets=function(_5d3){
return [];
var _5d4=[];
for(var item in _5d3){
if((_5d3[item]["tagName"]=="dojo:propertyset")){
_5d4.push(_5d3[item]);
}
}
this.propertySetsList.push(_5d4);
return _5d4;
};
this.parseProperties=function(_5d6){
var _5d7={};
for(var item in _5d6){
if((_5d6[item]==_5d6["tagName"])||(_5d6[item]==_5d6.nodeRef)){
}else{
if((_5d6[item]["tagName"])&&(dojo.widget.tags[_5d6[item].tagName.toLowerCase()])){
}else{
if((_5d6[item][0])&&(_5d6[item][0].value!="")&&(_5d6[item][0].value!=null)){
try{
if(item.toLowerCase()=="dataprovider"){
var _5d9=this;
this.getDataProvider(_5d9,_5d6[item][0].value);
_5d7.dataProvider=this.dataProvider;
}
_5d7[item]=_5d6[item][0].value;
var _5da=this.parseProperties(_5d6[item]);
for(var _5db in _5da){
_5d7[_5db]=_5da[_5db];
}
}
catch(e){
dojo.debug(e);
}
}
}
}
}
return _5d7;
};
this.getDataProvider=function(_5dc,_5dd){
dojo.io.bind({url:_5dd,load:function(type,_5df){
if(type=="load"){
_5dc.dataProvider=_5df;
}
},mimetype:"text/javascript",sync:true});
};
this.getPropertySetById=function(_5e0){
for(var x=0;x<this.propertySetsList.length;x++){
if(_5e0==this.propertySetsList[x]["id"][0].value){
return this.propertySetsList[x];
}
}
return "";
};
this.getPropertySetsByType=function(_5e2){
var _5e3=[];
for(var x=0;x<this.propertySetsList.length;x++){
var cpl=this.propertySetsList[x];
var cpcc=cpl["componentClass"]||cpl["componentType"]||null;
if((cpcc)&&(propertySetId==cpcc[0].value)){
_5e3.push(cpl);
}
}
return _5e3;
};
this.getPropertySets=function(_5e7){
var ppl="dojo:propertyproviderlist";
var _5e9=[];
var _5ea=_5e7["tagName"];
if(_5e7[ppl]){
var _5eb=_5e7[ppl].value.split(" ");
for(propertySetId in _5eb){
if((propertySetId.indexOf("..")==-1)&&(propertySetId.indexOf("://")==-1)){
var _5ec=this.getPropertySetById(propertySetId);
if(_5ec!=""){
_5e9.push(_5ec);
}
}else{
}
}
}
return (this.getPropertySetsByType(_5ea)).concat(_5e9);
};
this.createComponentFromScript=function(_5ed,_5ee,_5ef){
var ltn="dojo:"+_5ee.toLowerCase();
if(dojo.widget.tags[ltn]){
_5ef.fastMixIn=true;
return [dojo.widget.tags[ltn](_5ef,this,null,null,_5ef)];
}else{
if(ltn.substr(0,5)=="dojo:"){
dojo.debug("no tag handler registed for type: ",ltn);
}
}
};
};
dojo.widget._parser_collection={"dojo":new dojo.widget.Parse()};
dojo.widget.getParser=function(name){
if(!name){
name="dojo";
}
if(!this._parser_collection[name]){
this._parser_collection[name]=new dojo.widget.Parse();
}
return this._parser_collection[name];
};
dojo.widget.createWidget=function(name,_5f3,_5f4,_5f5){
var _5f6=name.toLowerCase();
var _5f7="dojo:"+_5f6;
var _5f8=(dojo.byId(name)&&(!dojo.widget.tags[_5f7]));
if((arguments.length==1)&&((typeof name!="string")||(_5f8))){
var xp=new dojo.xml.Parse();
var tn=(_5f8)?dojo.byId(name):name;
return dojo.widget.getParser().createComponents(xp.parseElement(tn,null,true))[0];
}
function fromScript(_5fb,name,_5fd){
_5fd[_5f7]={dojotype:[{value:_5f6}],nodeRef:_5fb,fastMixIn:true};
return dojo.widget.getParser().createComponentFromScript(_5fb,name,_5fd,true);
}
if(typeof name!="string"&&typeof _5f3=="string"){
dojo.deprecated("dojo.widget.createWidget","argument order is now of the form "+"dojo.widget.createWidget(NAME, [PROPERTIES, [REFERENCENODE, [POSITION]]])","0.4");
return fromScript(name,_5f3,_5f4);
}
_5f3=_5f3||{};
var _5fe=false;
var tn=null;
var h=dojo.render.html.capable;
if(h){
tn=document.createElement("span");
}
if(!_5f4){
_5fe=true;
_5f4=tn;
if(h){
document.body.appendChild(_5f4);
}
}else{
if(_5f5){
dojo.dom.insertAtPosition(tn,_5f4,_5f5);
}else{
tn=_5f4;
}
}
var _600=fromScript(tn,name,_5f3);
if(!_600[0]||typeof _600[0].widgetType=="undefined"){
throw new Error("createWidget: Creation of \""+name+"\" widget failed.");
}
if(_5fe){
if(_600[0].domNode.parentNode){
_600[0].domNode.parentNode.removeChild(_600[0].domNode);
}
}
return _600[0];
};
dojo.widget.fromScript=function(name,_602,_603,_604){
dojo.deprecated("dojo.widget.fromScript"," use "+"dojo.widget.createWidget instead","0.4");
return dojo.widget.createWidget(name,_602,_603,_604);
};
dojo.kwCompoundRequire({common:["dojo.uri.Uri",false,false]});
dojo.provide("dojo.uri.*");
dojo.provide("dojo.widget.DomWidget");
dojo.require("dojo.event.*");
dojo.require("dojo.widget.Widget");
dojo.require("dojo.dom");
dojo.require("dojo.xml.Parse");
dojo.require("dojo.uri.*");
dojo.require("dojo.lang.func");
dojo.widget._cssFiles={};
dojo.widget._cssStrings={};
dojo.widget._templateCache={};
dojo.widget.defaultStrings={dojoRoot:dojo.hostenv.getBaseScriptUri(),baseScriptUri:dojo.hostenv.getBaseScriptUri()};
dojo.widget.buildFromTemplate=function(){
dojo.lang.forward("fillFromTemplateCache");
};
dojo.widget.fillFromTemplateCache=function(obj,_606,_607,_608,_609){
var _60a=_606||obj.templatePath;
var _60b=_607||obj.templateCssPath;
if(_60a&&!(_60a instanceof dojo.uri.Uri)){
_60a=dojo.uri.dojoUri(_60a);
dojo.deprecated("templatePath should be of type dojo.uri.Uri",null,"0.4");
}
if(_60b&&!(_60b instanceof dojo.uri.Uri)){
_60b=dojo.uri.dojoUri(_60b);
dojo.deprecated("templateCssPath should be of type dojo.uri.Uri",null,"0.4");
}
var _60c=dojo.widget._templateCache;
if(!obj["widgetType"]){
do{
var _60d="__dummyTemplate__"+dojo.widget._templateCache.dummyCount++;
}while(_60c[_60d]);
obj.widgetType=_60d;
}
var wt=obj.widgetType;
if((!obj.templateCssString)&&(_60b)&&(!dojo.widget._cssFiles[_60b])){
obj.templateCssString=dojo.hostenv.getText(_60b);
obj.templateCssPath=null;
dojo.widget._cssFiles[_60b]=true;
}
if((obj["templateCssString"])&&(!obj.templateCssString["loaded"])){
dojo.style.insertCssText(obj.templateCssString,null,_60b);
if(!obj.templateCssString){
obj.templateCssString="";
}
obj.templateCssString.loaded=true;
}
var ts=_60c[wt];
if(!ts){
_60c[wt]={"string":null,"node":null};
if(_609){
ts={};
}else{
ts=_60c[wt];
}
}
if(!obj.templateString){
obj.templateString=_608||ts["string"];
}
if(!obj.templateNode){
obj.templateNode=ts["node"];
}
if((!obj.templateNode)&&(!obj.templateString)&&(_60a)){
var _610=dojo.hostenv.getText(_60a);
if(_610){
var _611=_610.match(/<body[^>]*>\s*([\s\S]+)\s*<\/body>/im);
if(_611){
_610=_611[1];
}
}else{
_610="";
}
obj.templateString=_610;
if(!_609){
_60c[wt]["string"]=_610;
}
}
if((!ts["string"])&&(!_609)){
ts.string=obj.templateString;
}
};
dojo.widget._templateCache.dummyCount=0;
dojo.widget.attachProperties=["dojoAttachPoint","id"];
dojo.widget.eventAttachProperty="dojoAttachEvent";
dojo.widget.onBuildProperty="dojoOnBuild";
dojo.widget.waiNames=["waiRole","waiState"];
dojo.widget.wai={waiRole:{name:"waiRole",namespace:"http://www.w3.org/TR/xhtml2",alias:"x2",prefix:"wairole:",nsName:"role"},waiState:{name:"waiState",namespace:"http://www.w3.org/2005/07/aaa",alias:"aaa",prefix:"",nsName:"state"},setAttr:function(node,attr,_614){
if(dojo.render.html.ie){
node.setAttribute(this[attr].alias+":"+this[attr].nsName,this[attr].prefix+_614);
}else{
node.setAttributeNS(this[attr].namespace,this[attr].nsName,this[attr].prefix+_614);
}
}};
dojo.widget.attachTemplateNodes=function(_615,_616,_617){
var _618=dojo.dom.ELEMENT_NODE;
function trim(str){
return str.replace(/^\s+|\s+$/g,"");
}
if(!_615){
_615=_616.domNode;
}
if(_615.nodeType!=_618){
return;
}
var _61a=_615.all||_615.getElementsByTagName("*");
var _61b=_616;
for(var x=-1;x<_61a.length;x++){
var _61d=(x==-1)?_615:_61a[x];
var _61e=[];
for(var y=0;y<this.attachProperties.length;y++){
var _620=_61d.getAttribute(this.attachProperties[y]);
if(_620){
_61e=_620.split(";");
for(var z=0;z<_61e.length;z++){
if(dojo.lang.isArray(_616[_61e[z]])){
_616[_61e[z]].push(_61d);
}else{
_616[_61e[z]]=_61d;
}
}
break;
}
}
var _622=_61d.getAttribute(this.templateProperty);
if(_622){
_616[_622]=_61d;
}
dojo.lang.forEach(dojo.widget.waiNames,function(name){
var wai=dojo.widget.wai[name];
var val=_61d.getAttribute(wai.name);
if(val){
dojo.widget.wai.setAttr(_61d,wai.name,val);
}
},this);
var _626=_61d.getAttribute(this.eventAttachProperty);
if(_626){
var evts=_626.split(";");
for(var y=0;y<evts.length;y++){
if((!evts[y])||(!evts[y].length)){
continue;
}
var _628=null;
var tevt=trim(evts[y]);
if(evts[y].indexOf(":")>=0){
var _62a=tevt.split(":");
tevt=trim(_62a[0]);
_628=trim(_62a[1]);
}
if(!_628){
_628=tevt;
}
var tf=function(){
var ntf=new String(_628);
return function(evt){
if(_61b[ntf]){
_61b[ntf](dojo.event.browser.fixEvent(evt,this));
}
};
}();
dojo.event.browser.addListener(_61d,tevt,tf,false,true);
}
}
for(var y=0;y<_617.length;y++){
var _62e=_61d.getAttribute(_617[y]);
if((_62e)&&(_62e.length)){
var _628=null;
var _62f=_617[y].substr(4);
_628=trim(_62e);
var _630=[_628];
if(_628.indexOf(";")>=0){
_630=dojo.lang.map(_628.split(";"),trim);
}
for(var z=0;z<_630.length;z++){
if(!_630[z].length){
continue;
}
var tf=function(){
var ntf=new String(_630[z]);
return function(evt){
if(_61b[ntf]){
_61b[ntf](dojo.event.browser.fixEvent(evt,this));
}
};
}();
dojo.event.browser.addListener(_61d,_62f,tf,false,true);
}
}
}
var _633=_61d.getAttribute(this.onBuildProperty);
if(_633){
eval("var node = baseNode; var widget = targetObj; "+_633);
}
}
};
dojo.widget.getDojoEventsFromStr=function(str){
var re=/(dojoOn([a-z]+)(\s?))=/gi;
var evts=str?str.match(re)||[]:[];
var ret=[];
var lem={};
for(var x=0;x<evts.length;x++){
if(evts[x].legth<1){
continue;
}
var cm=evts[x].replace(/\s/,"");
cm=(cm.slice(0,cm.length-1));
if(!lem[cm]){
lem[cm]=true;
ret.push(cm);
}
}
return ret;
};
dojo.declare("dojo.widget.DomWidget",dojo.widget.Widget,{initializer:function(){
if((arguments.length>0)&&(typeof arguments[0]=="object")){
this.create(arguments[0]);
}
},templateNode:null,templateString:null,templateCssString:null,preventClobber:false,domNode:null,containerNode:null,addChild:function(_63b,_63c,pos,ref,_63f){
if(!this.isContainer){
dojo.debug("dojo.widget.DomWidget.addChild() attempted on non-container widget");
return null;
}else{
this.addWidgetAsDirectChild(_63b,_63c,pos,ref,_63f);
this.registerChild(_63b,_63f);
}
return _63b;
},addWidgetAsDirectChild:function(_640,_641,pos,ref,_644){
if((!this.containerNode)&&(!_641)){
this.containerNode=this.domNode;
}
var cn=(_641)?_641:this.containerNode;
if(!pos){
pos="after";
}
if(!ref){
if(!cn){
cn=document.body;
}
ref=cn.lastChild;
}
if(!_644){
_644=0;
}
_640.domNode.setAttribute("dojoinsertionindex",_644);
if(!ref){
cn.appendChild(_640.domNode);
}else{
if(pos=="insertAtIndex"){
dojo.dom.insertAtIndex(_640.domNode,ref.parentNode,_644);
}else{
if((pos=="after")&&(ref===cn.lastChild)){
cn.appendChild(_640.domNode);
}else{
dojo.dom.insertAtPosition(_640.domNode,cn,pos);
}
}
}
},registerChild:function(_646,_647){
_646.dojoInsertionIndex=_647;
var idx=-1;
for(var i=0;i<this.children.length;i++){
if(this.children[i].dojoInsertionIndex<_647){
idx=i;
}
}
this.children.splice(idx+1,0,_646);
_646.parent=this;
_646.addedTo(this);
delete dojo.widget.manager.topWidgets[_646.widgetId];
},removeChild:function(_64a){
dojo.dom.removeNode(_64a.domNode);
return dojo.widget.DomWidget.superclass.removeChild.call(this,_64a);
},getFragNodeRef:function(frag){
if(!frag||!frag["dojo:"+this.widgetType.toLowerCase()]){
dojo.raise("Error: no frag for widget type "+this.widgetType+", id "+this.widgetId+" (maybe a widget has set it's type incorrectly)");
}
return (frag?frag["dojo:"+this.widgetType.toLowerCase()]["nodeRef"]:null);
},postInitialize:function(args,frag,_64e){
var _64f=this.getFragNodeRef(frag);
if(_64e&&(_64e.snarfChildDomOutput||!_64f)){
_64e.addWidgetAsDirectChild(this,"","insertAtIndex","",args["dojoinsertionindex"],_64f);
}else{
if(_64f){
if(this.domNode&&(this.domNode!==_64f)){
var _650=_64f.parentNode.replaceChild(this.domNode,_64f);
}
}
}
if(_64e){
_64e.registerChild(this,args.dojoinsertionindex);
}else{
dojo.widget.manager.topWidgets[this.widgetId]=this;
}
if(this.isContainer){
var _651=dojo.widget.getParser();
_651.createSubComponents(frag,this);
}
},buildRendering:function(args,frag){
var ts=dojo.widget._templateCache[this.widgetType];
if((!this.preventClobber)&&((this.templatePath)||(this.templateNode)||((this["templateString"])&&(this.templateString.length))||((typeof ts!="undefined")&&((ts["string"])||(ts["node"]))))){
this.buildFromTemplate(args,frag);
}else{
this.domNode=this.getFragNodeRef(frag);
}
this.fillInTemplate(args,frag);
},buildFromTemplate:function(args,frag){
var _657=false;
if(args["templatecsspath"]){
args["templateCssPath"]=args["templatecsspath"];
}
if(args["templatepath"]){
_657=true;
args["templatePath"]=args["templatepath"];
}
dojo.widget.fillFromTemplateCache(this,args["templatePath"],args["templateCssPath"],null,_657);
var ts=dojo.widget._templateCache[this.widgetType];
if((ts)&&(!_657)){
if(!this.templateString.length){
this.templateString=ts["string"];
}
if(!this.templateNode){
this.templateNode=ts["node"];
}
}
var _659=false;
var node=null;
var tstr=this.templateString;
if((!this.templateNode)&&(this.templateString)){
_659=this.templateString.match(/\$\{([^\}]+)\}/g);
if(_659){
var hash=this.strings||{};
for(var key in dojo.widget.defaultStrings){
if(dojo.lang.isUndefined(hash[key])){
hash[key]=dojo.widget.defaultStrings[key];
}
}
for(var i=0;i<_659.length;i++){
var key=_659[i];
key=key.substring(2,key.length-1);
var kval=(key.substring(0,5)=="this.")?this[key.substring(5)]:hash[key];
var _660;
if((kval)||(dojo.lang.isString(kval))){
_660=(dojo.lang.isFunction(kval))?kval.call(this,key,this.templateString):kval;
tstr=tstr.replace(_659[i],_660);
}
}
}else{
this.templateNode=this.createNodesFromText(this.templateString,true)[0];
ts.node=this.templateNode;
}
}
if((!this.templateNode)&&(!_659)){
dojo.debug("weren't able to create template!");
return false;
}else{
if(!_659){
node=this.templateNode.cloneNode(true);
if(!node){
return false;
}
}else{
node=this.createNodesFromText(tstr,true)[0];
}
}
this.domNode=node;
this.attachTemplateNodes(this.domNode,this);
if(this.isContainer&&this.containerNode){
var src=this.getFragNodeRef(frag);
if(src){
dojo.dom.moveChildren(src,this.containerNode);
}
}
},attachTemplateNodes:function(_662,_663){
if(!_663){
_663=this;
}
return dojo.widget.attachTemplateNodes(_662,_663,dojo.widget.getDojoEventsFromStr(this.templateString));
},fillInTemplate:function(){
},destroyRendering:function(){
try{
delete this.domNode;
}
catch(e){
}
},cleanUp:function(){
},getContainerHeight:function(){
dojo.unimplemented("dojo.widget.DomWidget.getContainerHeight");
},getContainerWidth:function(){
dojo.unimplemented("dojo.widget.DomWidget.getContainerWidth");
},createNodesFromText:function(){
dojo.unimplemented("dojo.widget.DomWidget.createNodesFromText");
}});
dojo.provide("dojo.html");
dojo.require("dojo.lang.func");
dojo.require("dojo.dom");
dojo.require("dojo.style");
dojo.require("dojo.string");
dojo.lang.mixin(dojo.html,dojo.dom);
dojo.lang.mixin(dojo.html,dojo.style);
dojo.html.clearSelection=function(){
try{
if(window["getSelection"]){
if(dojo.render.html.safari){
window.getSelection().collapse();
}else{
window.getSelection().removeAllRanges();
}
}else{
if(document.selection){
if(document.selection.empty){
document.selection.empty();
}else{
if(document.selection.clear){
document.selection.clear();
}
}
}
}
return true;
}
catch(e){
dojo.debug(e);
return false;
}
};
dojo.html.disableSelection=function(_664){
_664=dojo.byId(_664)||document.body;
var h=dojo.render.html;
if(h.mozilla){
_664.style.MozUserSelect="none";
}else{
if(h.safari){
_664.style.KhtmlUserSelect="none";
}else{
if(h.ie){
_664.unselectable="on";
}else{
return false;
}
}
}
return true;
};
dojo.html.enableSelection=function(_666){
_666=dojo.byId(_666)||document.body;
var h=dojo.render.html;
if(h.mozilla){
_666.style.MozUserSelect="";
}else{
if(h.safari){
_666.style.KhtmlUserSelect="";
}else{
if(h.ie){
_666.unselectable="off";
}else{
return false;
}
}
}
return true;
};
dojo.html.selectElement=function(_668){
_668=dojo.byId(_668);
if(document.selection&&document.body.createTextRange){
var _669=document.body.createTextRange();
_669.moveToElementText(_668);
_669.select();
}else{
if(window["getSelection"]){
var _66a=window.getSelection();
if(_66a["selectAllChildren"]){
_66a.selectAllChildren(_668);
}
}
}
};
dojo.html.selectInputText=function(_66b){
_66b=dojo.byId(_66b);
if(document.selection&&document.body.createTextRange){
var _66c=_66b.createTextRange();
_66c.moveStart("character",0);
_66c.moveEnd("character",_66b.value.length);
_66c.select();
}else{
if(window["getSelection"]){
var _66d=window.getSelection();
_66b.setSelectionRange(0,_66b.value.length);
}
}
_66b.focus();
};
dojo.html.isSelectionCollapsed=function(){
if(document["selection"]){
return document.selection.createRange().text=="";
}else{
if(window["getSelection"]){
var _66e=window.getSelection();
if(dojo.lang.isString(_66e)){
return _66e=="";
}else{
return _66e.isCollapsed;
}
}
}
};
dojo.html.getEventTarget=function(evt){
if(!evt){
evt=window.event||{};
}
var t=(evt.srcElement?evt.srcElement:(evt.target?evt.target:null));
while((t)&&(t.nodeType!=1)){
t=t.parentNode;
}
return t;
};
dojo.html.getDocumentWidth=function(){
dojo.deprecated("dojo.html.getDocument*","replaced by dojo.html.getViewport*","0.4");
return dojo.html.getViewportWidth();
};
dojo.html.getDocumentHeight=function(){
dojo.deprecated("dojo.html.getDocument*","replaced by dojo.html.getViewport*","0.4");
return dojo.html.getViewportHeight();
};
dojo.html.getDocumentSize=function(){
dojo.deprecated("dojo.html.getDocument*","replaced of dojo.html.getViewport*","0.4");
return dojo.html.getViewportSize();
};
dojo.html.getViewportWidth=function(){
var w=0;
if(window.innerWidth){
w=window.innerWidth;
}
if(dojo.exists(document,"documentElement.clientWidth")){
var w2=document.documentElement.clientWidth;
if(!w||w2&&w2<w){
w=w2;
}
return w;
}
if(document.body){
return document.body.clientWidth;
}
return 0;
};
dojo.html.getViewportHeight=function(){
if(window.innerHeight){
return window.innerHeight;
}
if(dojo.exists(document,"documentElement.clientHeight")){
return document.documentElement.clientHeight;
}
if(document.body){
return document.body.clientHeight;
}
return 0;
};
dojo.html.getViewportSize=function(){
var ret=[dojo.html.getViewportWidth(),dojo.html.getViewportHeight()];
ret.w=ret[0];
ret.h=ret[1];
return ret;
};
dojo.html.getScrollTop=function(){
return window.pageYOffset||document.documentElement.scrollTop||document.body.scrollTop||0;
};
dojo.html.getScrollLeft=function(){
return window.pageXOffset||document.documentElement.scrollLeft||document.body.scrollLeft||0;
};
dojo.html.getScrollOffset=function(){
var off=[dojo.html.getScrollLeft(),dojo.html.getScrollTop()];
off.x=off[0];
off.y=off[1];
return off;
};
dojo.html.getParentOfType=function(node,type){
dojo.deprecated("dojo.html.getParentOfType","replaced by dojo.html.getParentByType*","0.4");
return dojo.html.getParentByType(node,type);
};
dojo.html.getParentByType=function(node,type){
var _679=dojo.byId(node);
type=type.toLowerCase();
while((_679)&&(_679.nodeName.toLowerCase()!=type)){
if(_679==(document["body"]||document["documentElement"])){
return null;
}
_679=_679.parentNode;
}
return _679;
};
dojo.html.getAttribute=function(node,attr){
node=dojo.byId(node);
if((!node)||(!node.getAttribute)){
return null;
}
var ta=typeof attr=="string"?attr:new String(attr);
var v=node.getAttribute(ta.toUpperCase());
if((v)&&(typeof v=="string")&&(v!="")){
return v;
}
if(v&&v.value){
return v.value;
}
if((node.getAttributeNode)&&(node.getAttributeNode(ta))){
return (node.getAttributeNode(ta)).value;
}else{
if(node.getAttribute(ta)){
return node.getAttribute(ta);
}else{
if(node.getAttribute(ta.toLowerCase())){
return node.getAttribute(ta.toLowerCase());
}
}
}
return null;
};
dojo.html.hasAttribute=function(node,attr){
node=dojo.byId(node);
return dojo.html.getAttribute(node,attr)?true:false;
};
dojo.html.getClass=function(node){
node=dojo.byId(node);
if(!node){
return "";
}
var cs="";
if(node.className){
cs=node.className;
}else{
if(dojo.html.hasAttribute(node,"class")){
cs=dojo.html.getAttribute(node,"class");
}
}
return dojo.string.trim(cs);
};
dojo.html.getClasses=function(node){
var c=dojo.html.getClass(node);
return (c=="")?[]:c.split(/\s+/g);
};
dojo.html.hasClass=function(node,_685){
return dojo.lang.inArray(dojo.html.getClasses(node),_685);
};
dojo.html.prependClass=function(node,_687){
_687+=" "+dojo.html.getClass(node);
return dojo.html.setClass(node,_687);
};
dojo.html.addClass=function(node,_689){
if(dojo.html.hasClass(node,_689)){
return false;
}
_689=dojo.string.trim(dojo.html.getClass(node)+" "+_689);
return dojo.html.setClass(node,_689);
};
dojo.html.setClass=function(node,_68b){
node=dojo.byId(node);
var cs=new String(_68b);
try{
if(typeof node.className=="string"){
node.className=cs;
}else{
if(node.setAttribute){
node.setAttribute("class",_68b);
node.className=cs;
}else{
return false;
}
}
}
catch(e){
dojo.debug("dojo.html.setClass() failed",e);
}
return true;
};
dojo.html.removeClass=function(node,_68e,_68f){
var _68e=dojo.string.trim(new String(_68e));
try{
var cs=dojo.html.getClasses(node);
var nca=[];
if(_68f){
for(var i=0;i<cs.length;i++){
if(cs[i].indexOf(_68e)==-1){
nca.push(cs[i]);
}
}
}else{
for(var i=0;i<cs.length;i++){
if(cs[i]!=_68e){
nca.push(cs[i]);
}
}
}
dojo.html.setClass(node,nca.join(" "));
}
catch(e){
dojo.debug("dojo.html.removeClass() failed",e);
}
return true;
};
dojo.html.replaceClass=function(node,_694,_695){
dojo.html.removeClass(node,_695);
dojo.html.addClass(node,_694);
};
dojo.html.classMatchType={ContainsAll:0,ContainsAny:1,IsOnly:2};
dojo.html.getElementsByClass=function(_696,_697,_698,_699){
_697=dojo.byId(_697)||document;
var _69a=_696.split(/\s+/g);
var _69b=[];
if(_699!=1&&_699!=2){
_699=0;
}
var _69c=new RegExp("(\\s|^)(("+_69a.join(")|(")+"))(\\s|$)");
if(!_698){
_698="*";
}
var _69d=_697.getElementsByTagName(_698);
var node,i=0;
outer:
while(node=_69d[i++]){
var _69f=dojo.html.getClasses(node);
if(_69f.length==0){
continue outer;
}
var _6a0=0;
for(var j=0;j<_69f.length;j++){
if(_69c.test(_69f[j])){
if(_699==dojo.html.classMatchType.ContainsAny){
_69b.push(node);
continue outer;
}else{
_6a0++;
}
}else{
if(_699==dojo.html.classMatchType.IsOnly){
continue outer;
}
}
}
if(_6a0==_69a.length){
if(_699==dojo.html.classMatchType.IsOnly&&_6a0==_69f.length){
_69b.push(node);
}else{
if(_699==dojo.html.classMatchType.ContainsAll){
_69b.push(node);
}
}
}
}
return _69b;
};
dojo.html.getElementsByClassName=dojo.html.getElementsByClass;
dojo.html.getCursorPosition=function(e){
e=e||window.event;
var _6a3={x:0,y:0};
if(e.pageX||e.pageY){
_6a3.x=e.pageX;
_6a3.y=e.pageY;
}else{
var de=document.documentElement;
var db=document.body;
_6a3.x=e.clientX+((de||db)["scrollLeft"])-((de||db)["clientLeft"]);
_6a3.y=e.clientY+((de||db)["scrollTop"])-((de||db)["clientTop"]);
}
return _6a3;
};
dojo.html.overElement=function(_6a6,e){
_6a6=dojo.byId(_6a6);
var _6a8=dojo.html.getCursorPosition(e);
with(dojo.html){
var top=getAbsoluteY(_6a6,true);
var _6aa=top+getInnerHeight(_6a6);
var left=getAbsoluteX(_6a6,true);
var _6ac=left+getInnerWidth(_6a6);
}
return (_6a8.x>=left&&_6a8.x<=_6ac&&_6a8.y>=top&&_6a8.y<=_6aa);
};
dojo.html.setActiveStyleSheet=function(_6ad){
var i=0,a,els=document.getElementsByTagName("link");
while(a=els[i++]){
if(a.getAttribute("rel").indexOf("style")!=-1&&a.getAttribute("title")){
a.disabled=true;
if(a.getAttribute("title")==_6ad){
a.disabled=false;
}
}
}
};
dojo.html.getActiveStyleSheet=function(){
var i=0,a,els=document.getElementsByTagName("link");
while(a=els[i++]){
if(a.getAttribute("rel").indexOf("style")!=-1&&a.getAttribute("title")&&!a.disabled){
return a.getAttribute("title");
}
}
return null;
};
dojo.html.getPreferredStyleSheet=function(){
var i=0,a,els=document.getElementsByTagName("link");
while(a=els[i++]){
if(a.getAttribute("rel").indexOf("style")!=-1&&a.getAttribute("rel").indexOf("alt")==-1&&a.getAttribute("title")){
return a.getAttribute("title");
}
}
return null;
};
dojo.html.body=function(){
return document.body||document.getElementsByTagName("body")[0];
};
dojo.html.isTag=function(node){
node=dojo.byId(node);
if(node&&node.tagName){
var arr=dojo.lang.map(dojo.lang.toArray(arguments,1),function(a){
return String(a).toLowerCase();
});
return arr[dojo.lang.find(node.tagName.toLowerCase(),arr)]||"";
}
return "";
};
dojo.html.copyStyle=function(_6b4,_6b5){
if(dojo.lang.isUndefined(_6b5.style.cssText)){
_6b4.setAttribute("style",_6b5.getAttribute("style"));
}else{
_6b4.style.cssText=_6b5.style.cssText;
}
dojo.html.addClass(_6b4,dojo.html.getClass(_6b5));
};
dojo.html._callExtrasDeprecated=function(_6b6,args){
var _6b8="dojo.html.extras";
dojo.deprecated("dojo.html."+_6b6,"moved to "+_6b8,"0.4");
dojo["require"](_6b8);
return dojo.html[_6b6].apply(dojo.html,args);
};
dojo.html.createNodesFromText=function(){
return dojo.html._callExtrasDeprecated("createNodesFromText",arguments);
};
dojo.html.gravity=function(){
return dojo.html._callExtrasDeprecated("gravity",arguments);
};
dojo.html.placeOnScreen=function(){
return dojo.html._callExtrasDeprecated("placeOnScreen",arguments);
};
dojo.html.placeOnScreenPoint=function(){
return dojo.html._callExtrasDeprecated("placeOnScreenPoint",arguments);
};
dojo.html.renderedTextContent=function(){
return dojo.html._callExtrasDeprecated("renderedTextContent",arguments);
};
dojo.html.BackgroundIframe=function(){
return dojo.html._callExtrasDeprecated("BackgroundIframe",arguments);
};
dojo.require("dojo.html");
dojo.provide("dojo.html.extras");
dojo.require("dojo.string.extras");
dojo.html.gravity=function(node,e){
node=dojo.byId(node);
var _6bb=dojo.html.getCursorPosition(e);
with(dojo.html){
var _6bc=getAbsoluteX(node,true)+(getInnerWidth(node)/2);
var _6bd=getAbsoluteY(node,true)+(getInnerHeight(node)/2);
}
with(dojo.html.gravity){
return ((_6bb.x<_6bc?WEST:EAST)|(_6bb.y<_6bd?NORTH:SOUTH));
}
};
dojo.html.gravity.NORTH=1;
dojo.html.gravity.SOUTH=1<<1;
dojo.html.gravity.EAST=1<<2;
dojo.html.gravity.WEST=1<<3;
dojo.html.renderedTextContent=function(node){
node=dojo.byId(node);
var _6bf="";
if(node==null){
return _6bf;
}
for(var i=0;i<node.childNodes.length;i++){
switch(node.childNodes[i].nodeType){
case 1:
case 5:
var _6c1="unknown";
try{
_6c1=dojo.style.getStyle(node.childNodes[i],"display");
}
catch(E){
}
switch(_6c1){
case "block":
case "list-item":
case "run-in":
case "table":
case "table-row-group":
case "table-header-group":
case "table-footer-group":
case "table-row":
case "table-column-group":
case "table-column":
case "table-cell":
case "table-caption":
_6bf+="\n";
_6bf+=dojo.html.renderedTextContent(node.childNodes[i]);
_6bf+="\n";
break;
case "none":
break;
default:
if(node.childNodes[i].tagName&&node.childNodes[i].tagName.toLowerCase()=="br"){
_6bf+="\n";
}else{
_6bf+=dojo.html.renderedTextContent(node.childNodes[i]);
}
break;
}
break;
case 3:
case 2:
case 4:
var text=node.childNodes[i].nodeValue;
var _6c3="unknown";
try{
_6c3=dojo.style.getStyle(node,"text-transform");
}
catch(E){
}
switch(_6c3){
case "capitalize":
text=dojo.string.capitalize(text);
break;
case "uppercase":
text=text.toUpperCase();
break;
case "lowercase":
text=text.toLowerCase();
break;
default:
break;
}
switch(_6c3){
case "nowrap":
break;
case "pre-wrap":
break;
case "pre-line":
break;
case "pre":
break;
default:
text=text.replace(/\s+/," ");
if(/\s$/.test(_6bf)){
text.replace(/^\s/,"");
}
break;
}
_6bf+=text;
break;
default:
break;
}
}
return _6bf;
};
dojo.html.createNodesFromText=function(txt,trim){
if(trim){
txt=dojo.string.trim(txt);
}
var tn=document.createElement("div");
tn.style.visibility="hidden";
document.body.appendChild(tn);
var _6c7="none";
if((/^<t[dh][\s\r\n>]/i).test(dojo.string.trimStart(txt))){
txt="<table><tbody><tr>"+txt+"</tr></tbody></table>";
_6c7="cell";
}else{
if((/^<tr[\s\r\n>]/i).test(dojo.string.trimStart(txt))){
txt="<table><tbody>"+txt+"</tbody></table>";
_6c7="row";
}else{
if((/^<(thead|tbody|tfoot)[\s\r\n>]/i).test(dojo.string.trimStart(txt))){
txt="<table>"+txt+"</table>";
_6c7="section";
}
}
}
tn.innerHTML=txt;
if(tn["normalize"]){
tn.normalize();
}
var _6c8=null;
switch(_6c7){
case "cell":
_6c8=tn.getElementsByTagName("tr")[0];
break;
case "row":
_6c8=tn.getElementsByTagName("tbody")[0];
break;
case "section":
_6c8=tn.getElementsByTagName("table")[0];
break;
default:
_6c8=tn;
break;
}
var _6c9=[];
for(var x=0;x<_6c8.childNodes.length;x++){
_6c9.push(_6c8.childNodes[x].cloneNode(true));
}
tn.style.display="none";
document.body.removeChild(tn);
return _6c9;
};
dojo.html.placeOnScreen=function(node,_6cc,_6cd,_6ce,_6cf){
if(dojo.lang.isArray(_6cc)){
_6cf=_6ce;
_6ce=_6cd;
_6cd=_6cc[1];
_6cc=_6cc[0];
}
if(!isNaN(_6ce)){
_6ce=[Number(_6ce),Number(_6ce)];
}else{
if(!dojo.lang.isArray(_6ce)){
_6ce=[0,0];
}
}
var _6d0=dojo.html.getScrollOffset();
var view=dojo.html.getViewportSize();
node=dojo.byId(node);
var w=node.offsetWidth+_6ce[0];
var h=node.offsetHeight+_6ce[1];
if(_6cf){
_6cc-=_6d0.x;
_6cd-=_6d0.y;
}
var x=_6cc+w;
if(x>view.w){
x=view.w-w;
}else{
x=_6cc;
}
x=Math.max(_6ce[0],x)+_6d0.x;
var y=_6cd+h;
if(y>view.h){
y=view.h-h;
}else{
y=_6cd;
}
y=Math.max(_6ce[1],y)+_6d0.y;
node.style.left=x+"px";
node.style.top=y+"px";
var ret=[x,y];
ret.x=x;
ret.y=y;
return ret;
};
dojo.html.placeOnScreenPoint=function(node,_6d8,_6d9,_6da,_6db){
if(dojo.lang.isArray(_6d8)){
_6db=_6da;
_6da=_6d9;
_6d9=_6d8[1];
_6d8=_6d8[0];
}
if(!isNaN(_6da)){
_6da=[Number(_6da),Number(_6da)];
}else{
if(!dojo.lang.isArray(_6da)){
_6da=[0,0];
}
}
var _6dc=dojo.html.getScrollOffset();
var view=dojo.html.getViewportSize();
node=dojo.byId(node);
var _6de=node.style.display;
node.style.display="";
var w=dojo.style.getInnerWidth(node);
var h=dojo.style.getInnerHeight(node);
node.style.display=_6de;
if(_6db){
_6d8-=_6dc.x;
_6d9-=_6dc.y;
}
var x=-1,y=-1;
if((_6d8+_6da[0])+w<=view.w&&(_6d9+_6da[1])+h<=view.h){
x=(_6d8+_6da[0]);
y=(_6d9+_6da[1]);
}
if((x<0||y<0)&&(_6d8-_6da[0])<=view.w&&(_6d9+_6da[1])+h<=view.h){
x=(_6d8-_6da[0])-w;
y=(_6d9+_6da[1]);
}
if((x<0||y<0)&&(_6d8+_6da[0])+w<=view.w&&(_6d9-_6da[1])<=view.h){
x=(_6d8+_6da[0]);
y=(_6d9-_6da[1])-h;
}
if((x<0||y<0)&&(_6d8-_6da[0])<=view.w&&(_6d9-_6da[1])<=view.h){
x=(_6d8-_6da[0])-w;
y=(_6d9-_6da[1])-h;
}
if(x<0||y<0||(x+w>view.w)||(y+h>view.h)){
return dojo.html.placeOnScreen(node,_6d8,_6d9,_6da,_6db);
}
x+=_6dc.x;
y+=_6dc.y;
node.style.left=x+"px";
node.style.top=y+"px";
var ret=[x,y];
ret.x=x;
ret.y=y;
return ret;
};
dojo.html.BackgroundIframe=function(node){
if(dojo.render.html.ie){
var html="<iframe "+"style='position: absolute; left: 0px; top: 0px; width: 100%; height: 100%;"+"z-index: -1; filter:Alpha(Opacity=\"0\");' "+">";
this.iframe=document.createElement(html);
if(node){
node.appendChild(this.iframe);
this.domNode=node;
}else{
document.body.appendChild(this.iframe);
this.iframe.style.display="none";
}
}
};
dojo.lang.extend(dojo.html.BackgroundIframe,{iframe:null,onResized:function(){
if(this.iframe&&this.domNode){
var w=dojo.style.getOuterWidth(this.domNode);
var h=dojo.style.getOuterHeight(this.domNode);
if(w==0||h==0){
dojo.lang.setTimeout(this,this.onResized,50);
return;
}
var s=this.iframe.style;
s.width=w+"px";
s.height=h+"px";
}
},size:function(node){
if(!this.iframe){
return;
}
coords=dojo.style.toCoordinateArray(node,true);
var s=this.iframe.style;
s.width=coords.w+"px";
s.height=coords.h+"px";
s.left=coords.x+"px";
s.top=coords.y+"px";
},setZIndex:function(node){
if(!this.iframe){
return;
}
if(dojo.dom.isNode(node)){
this.iframe.style.zIndex=dojo.html.getStyle(node,"z-index")-1;
}else{
if(!isNaN(node)){
this.iframe.style.zIndex=node;
}
}
},show:function(){
if(!this.iframe){
return;
}
this.iframe.style.display="block";
},hide:function(){
if(!this.ie){
return;
}
var s=this.iframe.style;
s.display="none";
},remove:function(){
dojo.dom.removeNode(this.iframe);
}});
dojo.provide("dojo.lfx.Animation");
dojo.provide("dojo.lfx.Line");
dojo.require("dojo.lang.func");
dojo.lfx.Line=function(_6ec,end){
this.start=_6ec;
this.end=end;
if(dojo.lang.isArray(_6ec)){
var diff=[];
dojo.lang.forEach(this.start,function(s,i){
diff[i]=this.end[i]-s;
},this);
this.getValue=function(n){
var res=[];
dojo.lang.forEach(this.start,function(s,i){
res[i]=(diff[i]*n)+s;
},this);
return res;
};
}else{
var diff=end-_6ec;
this.getValue=function(n){
return (diff*n)+this.start;
};
}
};
dojo.lfx.easeIn=function(n){
return Math.pow(n,3);
};
dojo.lfx.easeOut=function(n){
return (1-Math.pow(1-n,3));
};
dojo.lfx.easeInOut=function(n){
return ((3*Math.pow(n,2))-(2*Math.pow(n,3)));
};
dojo.lfx.IAnimation=function(){
};
dojo.lang.extend(dojo.lfx.IAnimation,{curve:null,duration:1000,easing:null,repeatCount:0,rate:25,handler:null,beforeBegin:null,onBegin:null,onAnimate:null,onEnd:null,onPlay:null,onPause:null,onStop:null,play:null,pause:null,stop:null,fire:function(evt,args){
if(this[evt]){
this[evt].apply(this,(args||[]));
}
},_active:false,_paused:false});
dojo.lfx.Animation=function(_6fb,_6fc,_6fd,_6fe,_6ff,rate){
dojo.lfx.IAnimation.call(this);
if(dojo.lang.isNumber(_6fb)||(!_6fb&&_6fc.getValue)){
rate=_6ff;
_6ff=_6fe;
_6fe=_6fd;
_6fd=_6fc;
_6fc=_6fb;
_6fb=null;
}else{
if(_6fb.getValue||dojo.lang.isArray(_6fb)){
rate=_6fe;
_6ff=_6fd;
_6fe=_6fc;
_6fd=_6fb;
_6fc=null;
_6fb=null;
}
}
if(dojo.lang.isArray(_6fd)){
this.curve=new dojo.lfx.Line(_6fd[0],_6fd[1]);
}else{
this.curve=_6fd;
}
if(_6fc!=null&&_6fc>0){
this.duration=_6fc;
}
if(_6ff){
this.repeatCount=_6ff;
}
if(rate){
this.rate=rate;
}
if(_6fb){
this.handler=_6fb.handler;
this.beforeBegin=_6fb.beforeBegin;
this.onBegin=_6fb.onBegin;
this.onEnd=_6fb.onEnd;
this.onPlay=_6fb.onPlay;
this.onPause=_6fb.onPause;
this.onStop=_6fb.onStop;
this.onAnimate=_6fb.onAnimate;
}
if(_6fe&&dojo.lang.isFunction(_6fe)){
this.easing=_6fe;
}
};
dojo.inherits(dojo.lfx.Animation,dojo.lfx.IAnimation);
dojo.lang.extend(dojo.lfx.Animation,{_startTime:null,_endTime:null,_timer:null,_percent:0,_startRepeatCount:0,play:function(_701,_702){
if(_702){
clearTimeout(this._timer);
this._active=false;
this._paused=false;
this._percent=0;
}else{
if(this._active&&!this._paused){
return;
}
}
this.fire("beforeBegin");
if(_701>0){
setTimeout(dojo.lang.hitch(this,function(){
this.play(null,_702);
}),_701);
return;
}
this._startTime=new Date().valueOf();
if(this._paused){
this._startTime-=(this.duration*this._percent/100);
}
this._endTime=this._startTime+this.duration;
this._active=true;
this._paused=false;
var step=this._percent/100;
var _704=this.curve.getValue(step);
if(this._percent==0){
if(!this._startRepeatCount){
this._startRepeatCount=this.repeatCount;
}
this.fire("handler",["begin",_704]);
this.fire("onBegin",[_704]);
}
this.fire("handler",["play",_704]);
this.fire("onPlay",[_704]);
this._cycle();
},pause:function(){
clearTimeout(this._timer);
if(!this._active){
return;
}
this._paused=true;
var _705=this.curve.getValue(this._percent/100);
this.fire("handler",["pause",_705]);
this.fire("onPause",[_705]);
},gotoPercent:function(pct,_707){
clearTimeout(this._timer);
this._active=true;
this._paused=true;
this._percent=pct;
if(_707){
this.play();
}
},stop:function(_708){
clearTimeout(this._timer);
var step=this._percent/100;
if(_708){
step=1;
}
var _70a=this.curve.getValue(step);
this.fire("handler",["stop",_70a]);
this.fire("onStop",[_70a]);
this._active=false;
this._paused=false;
},status:function(){
if(this._active){
return this._paused?"paused":"playing";
}else{
return "stopped";
}
},_cycle:function(){
clearTimeout(this._timer);
if(this._active){
var curr=new Date().valueOf();
var step=(curr-this._startTime)/(this._endTime-this._startTime);
if(step>=1){
step=1;
this._percent=100;
}else{
this._percent=step*100;
}
if(this.easing&&dojo.lang.isFunction(this.easing)){
step=this.easing(step);
}
var _70d=this.curve.getValue(step);
this.fire("handler",["animate",_70d]);
this.fire("onAnimate",[_70d]);
if(step<1){
this._timer=setTimeout(dojo.lang.hitch(this,"_cycle"),this.rate);
}else{
this._active=false;
this.fire("handler",["end"]);
this.fire("onEnd");
if(this.repeatCount>0){
this.repeatCount--;
this.play(null,true);
}else{
if(this.repeatCount==-1){
this.play(null,true);
}else{
if(this._startRepeatCount){
this.repeatCount=this._startRepeatCount;
this._startRepeatCount=0;
}
}
}
}
}
}});
dojo.lfx.Combine=function(){
dojo.lfx.IAnimation.call(this);
this._anims=[];
this._animsEnded=0;
var _70e=arguments;
if(_70e.length==1&&(dojo.lang.isArray(_70e[0])||dojo.lang.isArrayLike(_70e[0]))){
_70e=_70e[0];
}
var _70f=this;
dojo.lang.forEach(_70e,function(anim){
_70f._anims.push(anim);
dojo.event.connect(anim,"onEnd",function(){
_70f._onAnimsEnded();
});
});
};
dojo.inherits(dojo.lfx.Combine,dojo.lfx.IAnimation);
dojo.lang.extend(dojo.lfx.Combine,{_animsEnded:0,play:function(_711,_712){
if(!this._anims.length){
return;
}
this.fire("beforeBegin");
if(_711>0){
setTimeout(dojo.lang.hitch(this,function(){
this.play(null,_712);
}),_711);
return;
}
if(_712||this._anims[0].percent==0){
this.fire("onBegin");
}
this.fire("onPlay");
this._animsCall("play",null,_712);
},pause:function(){
this.fire("onPause");
this._animsCall("pause");
},stop:function(_713){
this.fire("onStop");
this._animsCall("stop",_713);
},_onAnimsEnded:function(){
this._animsEnded++;
if(this._animsEnded>=this._anims.length){
this.fire("onEnd");
}
},_animsCall:function(_714){
var args=[];
if(arguments.length>1){
for(var i=1;i<arguments.length;i++){
args.push(arguments[i]);
}
}
var _717=this;
dojo.lang.forEach(this._anims,function(anim){
anim[_714](args);
},_717);
}});
dojo.lfx.Chain=function(){
dojo.lfx.IAnimation.call(this);
this._anims=[];
this._currAnim=-1;
var _719=arguments;
if(_719.length==1&&(dojo.lang.isArray(_719[0])||dojo.lang.isArrayLike(_719[0]))){
_719=_719[0];
}
var _71a=this;
dojo.lang.forEach(_719,function(anim,i,_71d){
_71a._anims.push(anim);
if(i<_71d.length-1){
dojo.event.connect(anim,"onEnd",function(){
_71a._playNext();
});
}else{
dojo.event.connect(anim,"onEnd",function(){
_71a.fire("onEnd");
});
}
},_71a);
};
dojo.inherits(dojo.lfx.Chain,dojo.lfx.IAnimation);
dojo.lang.extend(dojo.lfx.Chain,{_currAnim:-1,play:function(_71e,_71f){
if(!this._anims.length){
return;
}
if(_71f||!this._anims[this._currAnim]){
this._currAnim=0;
}
this.fire("beforeBegin");
if(_71e>0){
setTimeout(dojo.lang.hitch(this,function(){
this.play(null,_71f);
}),_71e);
return;
}
if(this._anims[this._currAnim]){
if(this._currAnim==0){
this.fire("handler",["begin",this._currAnim]);
this.fire("onBegin",[this._currAnim]);
}
this.fire("onPlay",[this._currAnim]);
this._anims[this._currAnim].play(null,_71f);
}
},pause:function(){
if(this._anims[this._currAnim]){
this._anims[this._currAnim].pause();
this.fire("onPause",[this._currAnim]);
}
},playPause:function(){
if(this._anims.length==0){
return;
}
if(this._currAnim==-1){
this._currAnim=0;
}
var _720=this._anims[this._currAnim];
if(_720){
if(!_720._active||_720._paused){
this.play();
}else{
this.pause();
}
}
},stop:function(){
if(this._anims[this._currAnim]){
this._anims[this._currAnim].stop();
this.fire("onStop",[this._currAnim]);
}
},_playNext:function(){
if(this._currAnim==-1||this._anims.length==0){
return;
}
this._currAnim++;
if(this._anims[this._currAnim]){
this._anims[this._currAnim].play(null,true);
}
}});
dojo.lfx.combine=function(){
var _721=arguments;
if(dojo.lang.isArray(arguments[0])){
_721=arguments[0];
}
return new dojo.lfx.Combine(_721);
};
dojo.lfx.chain=function(){
var _722=arguments;
if(dojo.lang.isArray(arguments[0])){
_722=arguments[0];
}
return new dojo.lfx.Chain(_722);
};
dojo.provide("dojo.lfx.html");
dojo.require("dojo.lfx.Animation");
dojo.require("dojo.html");
dojo.require("dojo.event");
dojo.require("dojo.lang.func");
dojo.lfx.html._byId=function(_723){
if(dojo.lang.isArrayLike(_723)){
if(!_723.alreadyChecked){
var n=[];
dojo.lang.forEach(_723,function(node){
n.push(dojo.byId(node));
});
n.alreadyChecked=true;
return n;
}else{
return _723;
}
}else{
var n=[];
n.push(dojo.byId(_723));
n.alreadyChecked=true;
return n;
}
};
dojo.lfx.html.propertyAnimation=function(_726,_727,_728,_729){
_726=dojo.lfx.html._byId(_726);
if(_726.length==1){
dojo.lang.forEach(_727,function(prop){
if(typeof prop["start"]=="undefined"){
if(prop.property!="opacity"){
prop.start=parseInt(dojo.style.getComputedStyle(_726[0],prop.property));
}else{
prop.start=dojo.style.getOpacity(_726[0]);
}
}
});
}
var _72b=function(_72c){
var _72d=new Array(_72c.length);
for(var i=0;i<_72c.length;i++){
_72d[i]=Math.round(_72c[i]);
}
return _72d;
};
var _72f=function(n,_731){
n=dojo.byId(n);
if(!n||!n.style){
return;
}
for(s in _731){
if(s=="opacity"){
dojo.style.setOpacity(n,_731[s]);
}else{
n.style[s]=_731[s];
}
}
};
var _732=function(_733){
this._properties=_733;
this.diffs=new Array(_733.length);
dojo.lang.forEach(_733,function(prop,i){
if(dojo.lang.isArray(prop.start)){
this.diffs[i]=null;
}else{
if(prop.start instanceof dojo.graphics.color.Color){
prop.startRgb=prop.start.toRgb();
prop.endRgb=prop.end.toRgb();
}else{
this.diffs[i]=prop.end-prop.start;
}
}
},this);
this.getValue=function(n){
var ret={};
dojo.lang.forEach(this._properties,function(prop,i){
var _73a=null;
if(dojo.lang.isArray(prop.start)){
}else{
if(prop.start instanceof dojo.graphics.color.Color){
_73a=(prop.units||"rgb")+"(";
for(var j=0;j<prop.startRgb.length;j++){
_73a+=Math.round(((prop.endRgb[j]-prop.startRgb[j])*n)+prop.startRgb[j])+(j<prop.startRgb.length-1?",":"");
}
_73a+=")";
}else{
_73a=((this.diffs[i])*n)+prop.start+(prop.property!="opacity"?prop.units||"px":"");
}
}
ret[dojo.style.toCamelCase(prop.property)]=_73a;
},this);
return ret;
};
};
var anim=new dojo.lfx.Animation(_728,new _732(_727),_729);
dojo.event.connect(anim,"onAnimate",function(_73d){
dojo.lang.forEach(_726,function(node){
_72f(node,_73d);
});
});
return anim;
};
dojo.lfx.html._makeFadeable=function(_73f){
var _740=function(node){
if(dojo.render.html.ie){
if((node.style.zoom.length==0)&&(dojo.style.getStyle(node,"zoom")=="normal")){
node.style.zoom="1";
}
if((node.style.width.length==0)&&(dojo.style.getStyle(node,"width")=="auto")){
node.style.width="auto";
}
}
};
if(dojo.lang.isArrayLike(_73f)){
dojo.lang.forEach(_73f,_740);
}else{
_740(_73f);
}
};
dojo.lfx.html.fadeIn=function(_742,_743,_744,_745){
_742=dojo.lfx.html._byId(_742);
dojo.lfx.html._makeFadeable(_742);
var anim=dojo.lfx.propertyAnimation(_742,[{property:"opacity",start:dojo.style.getOpacity(_742[0]),end:1}],_743,_744);
if(_745){
dojo.event.connect(anim,"onEnd",function(){
_745(_742,anim);
});
}
return anim;
};
dojo.lfx.html.fadeOut=function(_747,_748,_749,_74a){
_747=dojo.lfx.html._byId(_747);
dojo.lfx.html._makeFadeable(_747);
var anim=dojo.lfx.propertyAnimation(_747,[{property:"opacity",start:dojo.style.getOpacity(_747[0]),end:0}],_748,_749);
if(_74a){
dojo.event.connect(anim,"onEnd",function(){
_74a(_747,anim);
});
}
return anim;
};
dojo.lfx.html.fadeShow=function(_74c,_74d,_74e,_74f){
var anim=dojo.lfx.html.fadeIn(_74c,_74d,_74e,_74f);
dojo.event.connect(anim,"beforeBegin",function(){
if(dojo.lang.isArrayLike(_74c)){
dojo.lang.forEach(_74c,dojo.style.show);
}else{
dojo.style.show(_74c);
}
});
return anim;
};
dojo.lfx.html.fadeHide=function(_751,_752,_753,_754){
var anim=dojo.lfx.html.fadeOut(_751,_752,_753,function(){
if(dojo.lang.isArrayLike(_751)){
dojo.lang.forEach(_751,dojo.style.hide);
}else{
dojo.style.hide(_751);
}
if(_754){
_754(_751,anim);
}
});
return anim;
};
dojo.lfx.html.wipeIn=function(_756,_757,_758,_759){
_756=dojo.lfx.html._byId(_756);
var _75a=[];
var init=function(node,_75d){
if(_75d=="visible"){
node.style.overflow="hidden";
}
dojo.style.show(node);
node.style.height=0;
};
dojo.lang.forEach(_756,function(node){
var _75f=dojo.style.getStyle(node,"overflow");
var _760=function(){
init(node,_75f);
};
_760();
var anim=dojo.lfx.propertyAnimation(node,[{property:"height",start:0,end:node.scrollHeight}],_757,_758);
dojo.event.connect(anim,"beforeBegin",_760);
dojo.event.connect(anim,"onEnd",function(){
node.style.overflow=_75f;
node.style.height="auto";
if(_759){
_759(node,anim);
}
});
_75a.push(anim);
});
if(_756.length>1){
return dojo.lfx.combine(_75a);
}else{
return _75a[0];
}
};
dojo.lfx.html.wipeOut=function(_762,_763,_764,_765){
_762=dojo.lfx.html._byId(_762);
var _766=[];
var init=function(node,_769){
dojo.style.show(node);
if(_769=="visible"){
node.style.overflow="hidden";
}
};
dojo.lang.forEach(_762,function(node){
var _76b=dojo.style.getStyle(node,"overflow");
var _76c=function(){
init(node,_76b);
};
_76c();
var anim=dojo.lfx.propertyAnimation(node,[{property:"height",start:node.offsetHeight,end:0}],_763,_764);
dojo.event.connect(anim,"beforeBegin",_76c);
dojo.event.connect(anim,"onEnd",function(){
dojo.style.hide(node);
node.style.overflow=_76b;
if(_765){
_765(node,anim);
}
});
_766.push(anim);
});
if(_762.length>1){
return dojo.lfx.combine(_766);
}else{
return _766[0];
}
};
dojo.lfx.html.slideTo=function(_76e,_76f,_770,_771,_772){
_76e=dojo.lfx.html._byId(_76e);
var _773=[];
dojo.lang.forEach(_76e,function(node){
var top=null;
var left=null;
var pos=null;
var init=(function(){
var _779=node;
return function(){
top=node.offsetTop;
left=node.offsetLeft;
pos=dojo.style.getComputedStyle(node,"position");
if(pos=="relative"||pos=="static"){
top=parseInt(dojo.style.getComputedStyle(node,"top"))||0;
left=parseInt(dojo.style.getComputedStyle(node,"left"))||0;
}
};
})();
init();
var anim=dojo.lfx.propertyAnimation(node,[{property:"top",start:top,end:_76f[0]},{property:"left",start:left,end:_76f[1]}],_770,_771);
dojo.event.connect(anim,"beforeBegin",init);
if(_772){
dojo.event.connect(anim,"onEnd",function(){
_772(node,anim);
});
}
_773.push(anim);
});
if(_76e.length>1){
return dojo.lfx.combine(_773);
}else{
return _773[0];
}
};
dojo.lfx.html.explode=function(_77b,_77c,_77d,_77e,_77f){
var _780=dojo.style.toCoordinateArray(_77b);
var _781=document.createElement("div");
with(_781.style){
position="absolute";
border="1px solid black";
display="none";
}
document.body.appendChild(_781);
_77c=dojo.byId(_77c);
with(_77c.style){
visibility="hidden";
display="block";
}
var _782=dojo.style.toCoordinateArray(_77c);
with(_77c.style){
display="none";
visibility="visible";
}
var anim=new dojo.lfx.Animation({beforeBegin:function(){
dojo.style.setDisplay(_781,"block");
},onAnimate:function(_784){
with(_781.style){
left=_784[0]+"px";
top=_784[1]+"px";
width=_784[2]+"px";
height=_784[3]+"px";
}
},onEnd:function(){
dojo.style.setDisplay(_77c,"block");
_781.parentNode.removeChild(_781);
}},_77d,new dojo.lfx.Line(_780,_782),_77e);
if(_77f){
dojo.event.connect(anim,"onEnd",function(){
_77f(_77c,anim);
});
}
return anim;
};
dojo.lfx.html.implode=function(_785,end,_787,_788,_789){
var _78a=dojo.style.toCoordinateArray(_785);
var _78b=dojo.style.toCoordinateArray(end);
_785=dojo.byId(_785);
var _78c=document.createElement("div");
with(_78c.style){
position="absolute";
border="1px solid black";
display="none";
}
document.body.appendChild(_78c);
var anim=new dojo.lfx.Animation({beforeBegin:function(){
dojo.style.hide(_785);
dojo.style.show(_78c);
},onAnimate:function(_78e){
with(_78c.style){
left=_78e[0]+"px";
top=_78e[1]+"px";
width=_78e[2]+"px";
height=_78e[3]+"px";
}
},onEnd:function(){
_78c.parentNode.removeChild(_78c);
}},_787,new dojo.lfx.Line(_78a,_78b),_788);
if(_789){
dojo.event.connect(anim,"onEnd",function(){
_789(_785,anim);
});
}
return anim;
};
dojo.lfx.html.highlight=function(_78f,_790,_791,_792,_793){
_78f=dojo.lfx.html._byId(_78f);
var _794=[];
dojo.lang.forEach(_78f,function(node){
var _796=dojo.style.getBackgroundColor(node);
var bg=dojo.style.getStyle(node,"background-color").toLowerCase();
var _798=(bg=="transparent"||bg=="rgba(0, 0, 0, 0)");
while(_796.length>3){
_796.pop();
}
var rgb=new dojo.graphics.color.Color(_790);
var _79a=new dojo.graphics.color.Color(_796);
var anim=dojo.lfx.propertyAnimation(node,[{property:"background-color",start:rgb,end:_79a}],_791,_792);
dojo.event.connect(anim,"beforeBegin",function(){
node.style.backgroundColor="rgb("+rgb.toRgb().join(",")+")";
});
dojo.event.connect(anim,"onEnd",function(){
if(_798){
node.style.backgroundColor="transparent";
}
if(_793){
_793(node,anim);
}
});
_794.push(anim);
});
if(_78f.length>1){
return dojo.lfx.combine(_794);
}else{
return _794[0];
}
};
dojo.lfx.html.unhighlight=function(_79c,_79d,_79e,_79f,_7a0){
_79c=dojo.lfx.html._byId(_79c);
var _7a1=[];
dojo.lang.forEach(_79c,function(node){
var _7a3=new dojo.graphics.color.Color(dojo.style.getBackgroundColor(node));
var rgb=new dojo.graphics.color.Color(_79d);
var anim=dojo.lfx.propertyAnimation(node,[{property:"background-color",start:_7a3,end:rgb}],_79e,_79f);
dojo.event.connect(anim,"beforeBegin",function(){
node.style.backgroundColor="rgb("+_7a3.toRgb().join(",")+")";
});
if(_7a0){
dojo.event.connect(anim,"onEnd",function(){
_7a0(node,anim);
});
}
_7a1.push(anim);
});
if(_79c.length>1){
return dojo.lfx.combine(_7a1);
}else{
return _7a1[0];
}
};
dojo.lang.mixin(dojo.lfx,dojo.lfx.html);
dojo.kwCompoundRequire({browser:["dojo.lfx.html"],dashboard:["dojo.lfx.html"]});
dojo.provide("dojo.lfx.*");
dojo.provide("dojo.lfx.toggle");
dojo.require("dojo.lfx.*");
dojo.lfx.toggle.plain={show:function(node,_7a7,_7a8,_7a9){
dojo.style.show(node);
if(dojo.lang.isFunction(_7a9)){
_7a9();
}
},hide:function(node,_7ab,_7ac,_7ad){
dojo.style.hide(node);
if(dojo.lang.isFunction(_7ad)){
_7ad();
}
}};
dojo.lfx.toggle.fade={show:function(node,_7af,_7b0,_7b1){
dojo.lfx.fadeShow(node,_7af,_7b0,_7b1).play();
},hide:function(node,_7b3,_7b4,_7b5){
dojo.lfx.fadeHide(node,_7b3,_7b4,_7b5).play();
}};
dojo.lfx.toggle.wipe={show:function(node,_7b7,_7b8,_7b9){
dojo.lfx.wipeIn(node,_7b7,_7b8,_7b9).play();
},hide:function(node,_7bb,_7bc,_7bd){
dojo.lfx.wipeOut(node,_7bb,_7bc,_7bd).play();
}};
dojo.lfx.toggle.explode={show:function(node,_7bf,_7c0,_7c1,_7c2){
dojo.lfx.explode(_7c2||[0,0,0,0],node,_7bf,_7c0,_7c1).play();
},hide:function(node,_7c4,_7c5,_7c6,_7c7){
dojo.lfx.implode(node,_7c7||[0,0,0,0],_7c4,_7c5,_7c6).play();
}};
dojo.provide("dojo.widget.HtmlWidget");
dojo.require("dojo.widget.DomWidget");
dojo.require("dojo.html");
dojo.require("dojo.html.extras");
dojo.require("dojo.lang.extras");
dojo.require("dojo.lang.func");
dojo.require("dojo.lfx.toggle");
dojo.declare("dojo.widget.HtmlWidget",dojo.widget.DomWidget,{widgetType:"HtmlWidget",templateCssPath:null,templatePath:null,toggle:"plain",toggleDuration:150,animationInProgress:false,initialize:function(args,frag){
},postMixInProperties:function(args,frag){
this.toggleObj=dojo.lfx.toggle[this.toggle.toLowerCase()]||dojo.lfx.toggle.plain;
},getContainerHeight:function(){
dojo.unimplemented("dojo.widget.HtmlWidget.getContainerHeight");
},getContainerWidth:function(){
return this.parent.domNode.offsetWidth;
},setNativeHeight:function(_7cc){
var ch=this.getContainerHeight();
},createNodesFromText:function(txt,wrap){
return dojo.html.createNodesFromText(txt,wrap);
},destroyRendering:function(_7d0){
try{
if(!_7d0){
dojo.event.browser.clean(this.domNode);
}
this.domNode.parentNode.removeChild(this.domNode);
delete this.domNode;
}
catch(e){
}
},isShowing:function(){
return dojo.style.isShowing(this.domNode);
},toggleShowing:function(){
if(this.isHidden){
this.show();
}else{
this.hide();
}
},show:function(){
this.animationInProgress=true;
this.isHidden=false;
this.toggleObj.show(this.domNode,this.toggleDuration,null,dojo.lang.hitch(this,this.onShow),this.explodeSrc);
},onShow:function(){
this.animationInProgress=false;
},hide:function(){
this.animationInProgress=true;
this.isHidden=true;
this.toggleObj.hide(this.domNode,this.toggleDuration,null,dojo.lang.hitch(this,this.onHide),this.explodeSrc);
},onHide:function(){
this.animationInProgress=false;
},_isResized:function(w,h){
if(!this.isShowing()){
return false;
}
w=w||dojo.style.getOuterWidth(this.domNode);
h=h||dojo.style.getOuterHeight(this.domNode);
if(this.width==w&&this.height==h){
return false;
}
this.width=w;
this.height=h;
return true;
},onParentResized:function(){
if(!this._isResized()){
return;
}
this.onResized();
},resizeTo:function(w,h){
if(!this._isResized(w,h)){
return;
}
dojo.style.setOuterWidth(this.domNode,w);
dojo.style.setOuterHeight(this.domNode,h);
this.onResized();
},resizeSoon:function(){
if(this.isShowing()){
dojo.lang.setTimeout(this,this.onResized,0);
}
},onResized:function(){
dojo.lang.forEach(this.children,function(_7d5){
_7d5.onParentResized();
});
}});
dojo.kwCompoundRequire({common:["dojo.xml.Parse","dojo.widget.Widget","dojo.widget.Parse","dojo.widget.Manager"],browser:["dojo.widget.DomWidget","dojo.widget.HtmlWidget"],dashboard:["dojo.widget.DomWidget","dojo.widget.HtmlWidget"],svg:["dojo.widget.SvgWidget"]});
dojo.provide("dojo.widget.*");
dojo.provide("turbo.lib.theme");
dojo.require("dojo.io.*");
dojo.require("dojo.html");
dojo.require("turbo.turbo");
turbo.stylesheet={cssFiles:[],links:[],rules:0,loadCost:0,processCost:0,dummy:0};
turbo.stylesheet.create=function(_7d6){
var l=document.createElement("link");
l.setAttribute("rel","stylesheet");
l.setAttribute("type","text/css");
l.setAttribute("href",_7d6+"/base.css");
return l;
};
turbo.stylesheet.getLink=function(_7d8){
var l=turbo.stylesheet.links[_7d8];
if(!l){
l=turbo.stylesheet.create(_7d8);
turbo.addHeadNode(l);
turbo.stylesheet.links[_7d8]=l;
}
return l;
};
turbo.stylesheet.getLinkSheet=function(_7da){
var s=null;
if(!_7da.addRule){
turbo.debug("stylesheet has no addRule method");
if(_7da.styleSheet){
s=_7da.styleSheet;
}else{
turbo.debug("turbo.stylesheet.getLinkSheet: link has no .styleSheet property");
}
}
return s;
};
turbo.stylesheet.loaded=function(_7dc){
if(!_7dc||turbo.stylesheet.cssFiles[_7dc]){
return true;
}
turbo.stylesheet.cssFiles[_7dc]=true;
return false;
};
turbo.stylesheet.append=function(_7dd){
if(turbo.stylesheet.loaded(_7dd)){
return;
}
var t=turbo.time();
dojo.io.bind({url:_7dd,sync:true,load:function(_7df,_7e0){
turbo.stylesheet._append(_7dd,_7e0);
},error:function(e,m){
turbo.debug(m.message+": "+_7dd);
}});
};
turbo.stylesheet._append=function(_7e3,_7e4){
var s=turbo.stylesheet.getLink(turbo.pathpop(_7e3)).styleSheet;
if(!s||!s.addRule){
return;
}
var _7e6=/(\/\*[\s\S]*?\*\/)/g;
_7e4=_7e4.replace(_7e6,"");
var _7e6=/[\s]*([^{]*)({[^}]*})/g;
while((result=_7e6.exec(_7e4))!=null){
var rule=result[2];
var _7e8=result[1].split(",");
for(var i in _7e8){
s.addRule(_7e8[i],rule);
}
}
};
turbo.stylesheet.importStyleSheet=function(_7ea){
if(turbo.stylesheet.loaded(_7ea)){
return;
}
dojo.style.insertCssFile(_7ea);
};
turbo.stylesheet.importThemeFile=function(_7eb){
if(turbo.by_hand_css||djConfig["turbo_hand_css"]){
return;
}
if(turbo.fine_css||djConfig["turbo_fine_css"]){
if(dojo.render.html.ie){
turbo.stylesheet.append(_7eb);
}else{
turbo.stylesheet.importStyleSheet(_7eb);
}
}else{
turbo.stylesheet.importStyleSheet(turbo.pathpop(_7eb)+"/theme.css");
}
};
turbo.themes=new function(){
this.theme="";
this.themeable=[];
this.addThemeable=function(_7ec){
this.themeable.push(_7ec);
};
this.removeThemeable=function(_7ed){
for(var i in this.themeable){
if(this.themeable[i]==_7ed){
this.themeable.splice(i,1);
return;
}
}
};
this.setTheme=function(_7ef){
this.theme=(_7ef&&_7ef.toLowerCase()!="xp"?_7ef:"default");
for(var i=0,l=this.themeable.length;i<l;i++){
this.themeable[i].setTheme(this.theme);
}
if(turbo["aligner"]){
turbo.defer(turbo.aligner.align,250);
turbo.defer(turbo.aligner.align,1000);
}
};
};
dojo.addOnLoad(function(){
dojo.html.addClass(document.body,(dojo.render.html.moz?"turbo-gecko":(dojo.render.html.ie?"turbo-ie":"")));
});
dojo.provide("turbo.widgets.TurboWidget");
dojo.require("dojo.widget.*");
dojo.require("turbo.turbo");
dojo.require("turbo.lib.theme");
dojo.require("turbo.lib.align");
turbo.widgetRoot="../turbo/widgets/";
turbo.templateRoot=turbo.widgetRoot+"templates/";
turbo.themeRoot=turbo.widgetRoot+"themes/";
turbo.themePath=dojo.hostenv.getBaseScriptUri()+turbo.themeRoot;
turbo.loadJs=function(_7f1){
turbo.loadScript(dojo.hostenv.getBaseScriptUri()+_7f1);
};
turbo.loadCss=function(_7f2){
turbo.stylesheet.importThemeFile(dojo.hostenv.getBaseScriptUri()+_7f2);
};
turbo.setWidgetType=function(_7f3,_7f4){
if(_7f3.widgetType=="HtmlWidget"){
_7f3.widgetType=_7f4;
}
};
dojo.widget.HtmlTurboWidget=function(){
dojo.widget.HtmlWidget.call(this);
this.themeRoot=turbo.themeRoot;
this.templateRoot=turbo.templateRoot;
this.templatePath=dojo.uri.dojoUri(turbo.templateRoot+this.widgetType+".html");
this.styleRoot=(this.styleRoot||this.widgetType);
this.isContainer=false;
this.debuggable=true;
this.style="";
this.theme="";
this.themeable=true;
this.turboalign="";
this.themeJs=false;
this.turboCreate=function(){
};
this.turboDestroy=function(){
};
this.initialize=function(){
if(this.widgetId.substr(-2,1)!="_"&&this.widgetId.substr(-3,1)!="_"){
dj_global[this.widgetId]=this;
}
if(this.extraArgs["turboAlign"]){
this.turboalign=this.extraArgs.turboAlign;
}
if(this.turboalign){
this.domNode.setAttribute("turboalign",this.turboalign);
}
this.className=this.extraArgs["class"];
if(this.className){
this.domNode.className=this.className;
}
this.domNode.id=this.widgetId;
if(this.themeable){
turbo.themes.addThemeable(this);
if(!this.theme){
this.theme=turbo.themes.theme;
}
this.setTheme(this.theme);
}
this.turboCreate();
};
this.uninitialize=function(){
if(this.themeable){
turbo.themes.removeThemeable(this);
}
this.turboDestroy();
};
this.bindArgEvent=function(_7f5,_7f6){
if(_7f6[_7f5]){
this[_7f5]=turbo.getFunction(_7f6[_7f5]);
}
};
this.bindArgEvents=function(_7f7){
return;
for(var arg in _7f7){
if(dojo.lang.isFunction(this[arg])){
var _7f9=_7f7[arg];
if(_7f9.search(/[^\w\.]+/i)==-1){
var func=turbo.getFunction(_7f9);
if(func){
this[arg]=func;
}else{
this.debug("bindArgEvents","could not bind \""+arg+"\" to \""+_7f9+"\"");
}
}
}
}
};
this.connectEvents=function(_7fb){
for(var i=1,l=arguments.length;i<l;i++){
dojo.event.connect(_7fb,"on"+arguments[i].toLowerCase(),this,"do"+arguments[i]);
}
};
this.getWidgetFragment=function(_7fd){
return _7fd["dojo:"+this.widgetType.toLowerCase()];
};
this.createChildWidgets=function(_7fe){
dojo.widget.getParser().createSubComponents(_7fe);
return;
};
this.installChildren=function(_7ff,_800){
this.createChildWidgets(_7ff);
var _801=(_800?_800:this.domNode);
dojo.dom.moveChildren(this.getFragNodeRef(_7ff),_801);
};
this.getStylePath=function(_802){
return this.themeRoot+(_802?_802:"default")+"/"+this.styleRoot+_802;
};
this.loadStyle=function(_803){
var p=this.getStylePath(_803);
turbo.loadCss(p+".css");
if(this.themeJs){
turbo.loadJs(p+"Theme.js");
}
};
this.setStyle=function(_805){
this.style=(_805=="default"?"":_805);
this.loadStyle(this.style);
this.styleChanged();
};
this.setTheme=function(_806){
this.loadStyle("");
if(!this.themeable){
return;
}
if(_806&&(_806.charAt(0)=="+")){
this.themeable=false;
_806=_806.substring(1);
}
this.setStyle(_806);
};
this.styleChanged=function(){
};
this.setStyledClass=function(_807,_808){
if(!_808){
_808="";
}
_807.className=this.classTag+_808+(this.style?" "+this.classTag+this.style+_808:"");
};
this.setClassName=this.setStyledClass;
this.debug=function(_809,_80a){
if(this.debuggable){
turbo.debug(this.widgetId+" ["+this.widgetType+"]: "+_809+": "+turbo.printf.apply(turbo,turbo.cloneArguments(arguments,1)));
}
};
this.showHide=function(_80b){
if(_80b){
this.show();
}else{
this.hide();
}
};
};
dojo.widget.HtmlTurboValueWidget=function(){
dojo.widget.HtmlTurboWidget.call(this);
this.defaultValue=null;
this.value="";
this.fillInTemplate=function(){
if(this.value){
eval("this.defaultValue = "+this.value);
}
if(this.setValue){
this.setValue(this.defaultValue);
}
};
};
dojo.widget.HtmlTurboNotifier=function(){
dojo.widget.HtmlWidget.call(this);
this.widgetType="TurboNotifier";
this.templateString="<div dojoAttachPoint=\"div\" style=\"display:none;\"></div>";
this.notify="";
this.div=null;
this.fillInTemplate=function(){
if(this.notify){
eval(this.notify+"(this);");
}
};
};
dojo.inherits(dojo.widget.HtmlTurboNotifier,dojo.widget.HtmlWidget);
dojo.widget.tags.addParseTreeHandler("dojo:turbonotifier");
dojo.provide("turbo.widgets.TurboButton");
dojo.provide("turbo.widgets.HtmlTurboButton");
dojo.require("turbo.widgets.TurboWidget");
turbo.button={};
turbo.button.groups=[];
turbo.button.states={normal:0,down:1,disabled:2,over:3,selected:1};
turbo.button.add=function(_80c,_80d){
if(!turbo.button.groups[_80c]){
turbo.button.groups[_80c]=[];
}
turbo.button.groups[_80c].push(_80d);
};
turbo.button.remove=function(_80e,_80f){
if(!_80e||!_80f){
return;
}
var g=turbo.button.groups[_80e];
if(!g){
return;
}
for(var i=0,l=g.length;i<l;i++){
if(g[i]==_80f){
delete g[i];
return;
}
}
};
turbo.button.resetGroup=function(_812){
var g=turbo.button.groups[_812];
if(!g){
return;
}
for(i=0,l=g.length;i<l;i++){
if(g[i]&&g[i].state!=turbo.button.states.disabled){
g[i].setState(turbo.button.states.normal);
}
}
};
dojo.widget.TurboButtonBase=function(){
dojo.widget.HtmlTurboWidget.call(this);
this.states=turbo.button.states;
this.state="normal";
this.focusOnClick=true;
this.group="";
this.toggle="";
this.value="";
this.innerWidth=0;
this.repeating=false;
this.event=null;
this.type="button";
this.mouseDownState=-1;
this.btn=null;
this.btnNode=null;
this.onClick=function(_814){
};
this.onDown=function(_815){
};
this.onUp=function(_816){
};
this.initButton=function(_817){
this.bindArgEvents(_817);
if(this.btnNode){
var w=this.innerWidth||this.extraArgs["width"];
if(w){
this.btnNode.style.width=w+"px";
}
this.btnNode.setAttribute("autocomplete","off");
}
if(this.state){
if(parseInt(this.state)){
this.state=parseInt(this.state);
}else{
this.state=this.states[this.state];
}
}
this.setState(this.state);
this.setGroup(this.group);
};
this.turboDestroy=function(){
turbo.button.remove(this.group,this);
};
this.styleChanged=function(){
this.updateButton();
};
this.updateButton=function(_819){
dojo.debug("abstract function TurboButtonBase.updateButton invoked.");
};
this.setGroup=function(_81a){
if(_81a){
this.group=_81a;
this.toggle=true;
turbo.button.add(this.group,this);
}
};
this.setState=function(_81b){
if(dojo.lang.isString(_81b)){
_81b=(_81b?this.states[_81b]:this.states.normal);
}
if(this.group&&_81b==this.states.down){
turbo.button.resetGroup(this.group);
}
this.state=_81b;
this.delayedState=this.state;
this.updateButton();
this.domNode.setAttribute("tabindex",(this.isDisabled()?"-1":"0"));
};
this.isDisabled=function(){
return (this.state==this.states.disabled);
};
this.isDown=function(){
return (this.state==this.states.down);
};
this.isUp=function(){
return (this.state==this.states.normal);
};
this.show=function(){
turbo.show(this.domNode);
};
this.hide=function(){
turbo.hide(this.domNode);
};
this.blur=function(){
if(this.btn){
this.btn.blur();
}
};
this.focus=function(){
if(dojo.render.html.safari){
return;
}
if(this.btn && this.btn.focus){
this.btn.focus();
}
};
this.delayedSetState=function(){
if(this.state!=this.delayedState){
this.setState(this.delayedState);
}
this.delayedState=this.state;
};
this.doMouseOver=function(){
if(!this.isDisabled()&&(!this.toggle||!this.isDown())){
this.setState(this.states.over);
}
};
this.doMouseOut=function(){
if(!this.isDisabled()&&(!this.toggle||!this.isDown())){
this.delayedState=this.states.normal;
window.setTimeout(turbo.bind(this,this.delayedSetState),1);
}
};
this.doMouseDown=function(_81c){
turbo.killEvent(_81c);
if(this.isDisabled()){
return;
}
if(this.mouseDownState==-1){
this.mouseDownState=this.state;
}
this.setState(this.states.down);
var btn=this.btn;
this.onDown(_81c);
};
this.doMouseUp=function(_81e){
turbo.killEvent(_81e);
if(this.isDisabled()){
return;
}
if(!this.toggle){
this.setState(this.states.normal);
}
this.onUp(_81e);
};
this._click=function(_81f){
if(this.toggle){
var _820=(this.mouseDownState>-1?this.mouseDownState:this.state);
if(!this.group||_820!=this.states.down){
this.setState(_820!=this.states.down?this.states.down:this.states.normal);
}
this.mouseDownState=-1;
}
this.event=_81f;
switch(this.type){
case "submit":
case "reset":
var form=dojo.dom.getFirstAncestorByTag(this.btn,"form");
if(form){
form[this.type]();
}
break;
}
this.onClick(_81f);
turbo.killEvent(_81f);
};
this.doClick=function(_822){
if(this.isDisabled()){
turbo.killEvent(_822);
return;
}
if(this.focusOnClick){
this.focus();
}
this._click(_822);
};
this.doKeyDown=function(_823){
switch(_823.keyCode){
case _823.KEY_ENTER:
case _823.KEY_SPACE:
this.keyDown=_823.keyCode;
this.doMouseDown(null);
if(this.repeating){
turbo.defer(turbo.bindArgs(this,"doMouseUp",null),10);
this._click(_823);
}
}
};
this.doKeyUp=function(_824){
if(this.repeating||this.keyDown!=_824.keyCode){
return;
}
this.keyDown=0;
switch(_824.keyCode){
case _824.KEY_ENTER:
case _824.KEY_SPACE:
this.doMouseUp(null);
this._click(_824);
}
};
};
dojo.widget.HtmlTurboButton=function(){
turbo.setWidgetType(this,"TurboButton");
dojo.widget.TurboButtonBase.call(this);
this.templatePath=null;
this.templateString="<span dojoAttachPoint=\"btn\" tabindex=\"0\" hidefocus=\"hidefocus\"></span>";
this.classTag="turbo-button";
this.focused=false;
this.glyph="";
this.glyphAfter=false;
this.hideLeft="";
this.hideRight="";
this.themeJs=true;
this.btn=null;
this.btnClient=null;
this.btnMid=null;
this.btnLeft=null;
this.btnRight=null;
this.fillInTemplate=function(_825,_826){
if(this.extraArgs["gecko"]||(dojo.render.html.moz&&dojo.dom.getFirstAncestorByTag(this.getFragNodeRef(_826),"table"))){
dojo.widget.HtmlTurboGeckoButton.call(this);
}
this.createNodes();
this.btnNode=this.btnMid;
this.initButton(_825);
if(this.hideLeft){
this.btnLeft.style.display="none";
}
if(this.hideRight){
this.btnRight.style.display="none";
}
if(!this.value){
var node=this.getWidgetFragment(_826).nodeRef;
if(node.innerHTML){
this.value=node.innerHTML;
}
}
if(this.width){
turbo.setStyleWidthPx(this.btnMid,this.width);
}
this.glyph=this.glyph||this.extraArgs["image"];
this.setContent(this.value,this.glyph);
this.connectEvents(this.btn,"MouseOver","MouseOut","MouseDown","MouseUp","Click","KeyDown","KeyUp","Focus","Blur");
};
this.createNodes=function(){
var html="<span class=\"turbo-button-client\"><span class=\"turbo-button-left\"></span><span class=\"turbo-button-mid\"></span><span class=\"turbo-button-right\"></span></span>";
this.btn.innerHTML=html;
this.btnClient=this.btn.childNodes[0];
var cn=this.btnClient.childNodes;
this.btnLeft=cn[0];
this.btnMid=cn[1];
this.btnRight=cn[2];
};
this.disableSelectionRecurse=function(_82a){
dojo.html.disableSelection(_82a);
};
this.getButtonClass=function(){
return ["","-down","-disabled","-over"][this.state];
};
this.setButtonClasses=function(){
var cn=this.getButtonClass();
var bccn=this.classTag+"-client"+(cn?" "+this.classTag+cn:"");
if(this.focused&&!this.isDown()&&!this.isDisabled()){
bccn+=" "+this.classTag+"-focus";
}
this.btnClient.className=bccn;
this.btnLeft.className=this.classTag+"-left";
this.btnMid.className=this.classTag+"-mid"+(dojo.render.html.ie?" "+this.classTag+"-mid-ie":"");
this.btnRight.className=this.classTag+"-right";
};
this.doFocus=function(_82d){
this.focused=true;
this.setButtonClasses();
};
this.doBlur=function(_82e){
this.focused=false;
this.setButtonClasses();
};
this.updateButton=function(){
this.setStyledClass(this.domNode,"");
this.setButtonClasses();
};
this.getContent=function(_82f,_830){
var h=_82f;
if(!dojo.render.html.safari){
h="<span>"+h+"</span>";
}
if(_830){
var g="<img src=\""+_830+"\">";
if(this.glyphAfter){
h=h+g;
}else{
h=g+h;
}
}
return h;
};
this.setContent=function(_833,_834){
this.btnMid.innerHTML=this.getContent(_833,_834);
this.disableSelectionRecurse(this.btnMid);
};
};
dojo.inherits(dojo.widget.HtmlTurboButton,dojo.widget.HtmlWidget);
dojo.widget.tags.addParseTreeHandler("dojo:turbobutton");
dojo.widget.HtmlTurboGeckoButton=function(){
this.updateButton=function(){
this.setStyledClass(this.domNode,"");
dojo.html.addClass(this.domNode,"turbo-gecko-button");
this.setButtonClasses();
};
this.createNodes=function(){
var html="<span><button disabled=\"disabled\">&#160;</button><button tabindex=\"-1\">Caption</button><button disabled=\"disabled\">&#160;</button></span>";
this.btn.innerHTML=html;
this.btnClient=this.btn.childNodes[0];
var cn=this.btnClient.childNodes;
this.btnLeft=cn[0];
this.btnMid=cn[1];
this.btnRight=cn[2];
};
};
dojo.widget.HtmlTurboTab=function(){
this.widgetType="TurboTab";
dojo.widget.HtmlTurboButton.call(this);
this.classTag="turbo-tab";
this.focusOnClick=false;
this.downEvent=null;
this.onGlyphClick=function(_837){
};
this.getContent=function(_838,_839){
return "<span>"+_838+"</span>";
};
this.setContent=function(_83a,_83b){
this.btnMid.innerHTML=this.getContent(_83a,_83b);
if(arguments.length>1){
this.setGlyph(_83b);
}
this.disableSelectionRecurse(this.btnMid);
};
this.setGlyph=function(_83c){
this.glyph=_83c;
var n=this.btnMid.childNodes[0];
if(this.glyph){
n.className=this.classTag+"-bg"+(this.glyphAfter?"-right":"-left");
n.style.backgroundImage="url("+this.glyph+")";
}else{
n.style.backgroundImage="";
}
};
this.isGlyphEvent=function(_83e){
if(!_83e||_83e.keyCode||!this.glyph){
return false;
}
var x=_83e.clientX-dojo.style.getAbsoluteX(this.domNode);
return (this.glyphAfter?x>this.domNode.offsetWidth-16:x<16);
};
this.superDoMouseDown=this.doMouseDown;
this.doMouseDown=function(_840){
turbo.killEvent(_840);
if(this.isDisabled()){
return;
}
this.downEvent=_840;
if(this.isGlyphEvent(this.downEvent)){
return;
}
this.superDoMouseDown(_840);
};
this.superDoMouseUp=this.doMouseUp;
this.doMouseUp=function(_841){
turbo.killEvent(_841);
if(this.isDisabled()){
return;
}
if(this.isGlyphEvent(this.downEvent)){
return;
}
this.superDoMouseDown(_841);
};
this.super_Click=this._click;
this._click=function(_842){
if(!this.isGlyphEvent(this.downEvent)){
this.super_Click(_842);
}else{
if(this.isGlyphEvent(_842)){
return this.onGlyphClick(_842);
}
}
};
};
dojo.inherits(dojo.widget.HtmlTurboTab,dojo.widget.HtmlWidget);
dojo.widget.tags.addParseTreeHandler("dojo:turboTab");
dojo.widget.HtmlTurboToolbtn=function(){
this.widgetType="TurboToolbtn";
dojo.widget.TurboButtonBase.call(this);
this.templatePath=null;
this.templateString="<button dojoAttachPoint=\"btn\"><div dojoAttachPoint=\"div\"><img dojoAttachPoint=\"img\"></div></button>";
this.classTag="turbo_toolbtn";
this.glyph="";
this.image="";
this.caption="";
this.span=null;
this.div=null;
this.img=null;
this.fillInTemplate=function(_843){
this.btnNode=this.btn;
this.initButton(_843);
this.setCaption(this.caption?this.caption:this.value);
this.setGlyph(this.image?this.image:this.glyph);
if(!dojo.render.html.ie&&!dojo.render.html.moz){
this.btn.style.paddingLeft="2px";
this.btn.style.paddingRight="2px";
}
this.connectEvents(this.btn,"MouseOver","MouseOut","MouseDown","MouseUp","Click","KeyDown","KeyUp");
};
this.updateButton=function(){
this.btn.disabled=(this.state==this.states.disabled?"disabled":"");
this.setStyledClass(this.btn,["","_down","","_over"][this.state]);
};
this.setCaption=function(_844){
if(!_844){
return;
}
if(!this.span){
this.span=document.createElement("span");
this.btn.appendChild(this.span);
}
this.span.innerHTML=_844;
};
this.setGlyph=function(_845){
if(_845){
this.img.src=_845;
}else{
this.img.style.display="none";
}
};
this.set=function(_846,_847){
this.setCaption(_846);
this.setGlyph(_847);
};
};
dojo.inherits(dojo.widget.HtmlTurboToolbtn,dojo.widget.HtmlWidget);
dojo.widget.tags.addParseTreeHandler("dojo:turbotoolbtn");
dojo.widget.HtmlTurboSimpleButton=function(){
this.widgetType="TurboSimpleButton";
dojo.widget.TurboButtonBase.call(this);
this.classTag="turbo_sbtn";
this.fillInTemplate=function(_848){
this.btnNode=this.btn;
this.initButton(_848);
if(this.value){
this.btn.innerHTML=this.value;
}
};
this.updateButton=function(){
this.btn.disabled=(this.state==this.states.disabled?"disabled":"");
var a=["","Down","","Over"];
this.btn.className=this.classTag+[this.state];
};
};
dojo.inherits(dojo.widget.HtmlTurboSimpleButton,dojo.widget.HtmlWidget);
dojo.widget.tags.addParseTreeHandler("dojo:turbosimplebutton");
dojo.widget.HtmlTurboCheckbox=function(){
turbo.setWidgetType(this,"TurboCheckbox");
dojo.widget.TurboButtonBase.call(this);
this.templatePath=null;
this.templateString="<div></div>";
this.classTag="turbo_cbox";
this.btn=null;
this.span=null;
this.fillInTemplate=function(_84a){
this.toggle=true;
this.createButtons();
this.btnNode=this.btn;
this.initButton(_84a);
if(this.value){
this.span.innerHTML=this.value;
}
};
this.blur=function(){
};
this.createButtons=function(){
var html="<button type=\""+this.type+"\"><span>Checkbox</span></button>";
this.domNode.innerHTML=html;
this.setStyledClass(this.domNode,"");
this.btn=this.domNode.childNodes[0];
this.span=this.btn.childNodes[0];
dojo.event.connect(this.btn,"onmouseover",this,"onMouseOver");
dojo.event.connect(this.btn,"onmouseout",this,"onMouseOut");
dojo.event.connect(this.btn,"onclick",this,"onMouseClick");
};
this.updateButton=function(){
this.setClassName(this.domNode,"");
var a=["Off","Down","Off","Over"];
this.setClassName(this.btn,a[this.state]);
this.btn.disabled=(this.state==this.states.disabled?"disabled":"");
this.setClassName(this.span,"Span"+a[this.state]);
};
};
dojo.inherits(dojo.widget.HtmlTurboCheckbox,dojo.widget.HtmlWidget);
dojo.widget.tags.addParseTreeHandler("dojo:turbocheckbox");
dojo.widget.HtmlTurboRadio=function(){
this.widgetType="TurboRadio";
dojo.widget.HtmlTurboCheckbox.call(this);
this.classTag="turbo_radio";
};
dojo.inherits(dojo.widget.HtmlTurboRadio,dojo.widget.HtmlWidget);
dojo.widget.tags.addParseTreeHandler("dojo:turboradio");
dojo.provide("turbo.widgets.TurboTableBox");
dojo.provide("turbo.widgets.HtmlTurboTableBox");
dojo.require("turbo.widgets.TurboWidget");
dojo.widget.HtmlTurboTableBox=function(){
this.widgetType="TurboTableBox";
dojo.widget.HtmlTurboWidget.call(this);
this.boxTable=null;
this.boxCaption=null;
this.boxContent=null;
this.classTag="turbo_box";
this.width="";
this.color="Yellow";
this.imageRoot=dojo.uri.dojoUri(this.themeRoot+"default/tablebox/");
this.fillInTemplate=function(_84d,_84e){
if(this.width){
this.boxTable.style.width=this.width+"px";
}
this.setColor(this.color);
this.installChildren(_84e,this.boxContent);
this.boxCaption.appendChild(this.boxContent.removeChild(this.boxContent.firstChild));
this.boxTable.rows[0].cells[0].height="33";
this.boxTable.rows[0].cells[1].height="33";
this.boxTable.rows[0].cells[2].height="33";
};
this.setBg=function(_84f,_850){
_84f.style.backgroundImage="url("+this.imageRoot+"box"+this.color+"_0"+_850+".gif)";
};
this.setColor=function(_851){
this.color=_851;
var r=this.boxTable.rows[0];
this.setBg(r.cells[0],1);
this.setBg(r.cells[1],2);
this.setBg(r.cells[2],3);
r=this.boxTable.rows[1];
this.setBg(r.cells[0],4);
this.setBg(r.cells[2],6);
r=this.boxTable.rows[2];
this.setBg(r.cells[0],7);
this.setBg(r.cells[1],8);
this.setBg(r.cells[2],9);
};
};
dojo.inherits(dojo.widget.HtmlTurboTableBox,dojo.widget.HtmlWidget);
dojo.widget.tags.addParseTreeHandler("dojo:turbotablebox");
dojo.provide("turbo.widgets.TurboToolbar");
dojo.provide("turbo.widgets.HtmlTurboToolbar");
dojo.require("turbo.widgets.TurboWidget");
dojo.require("turbo.widgets.TurboButton");
dojo.widget.HtmlTurboToolbar=function(){
turbo.setWidgetType(this,"TurboToolbar");
dojo.widget.HtmlTurboWidget.call(this);
this.templatePath=null;
this.list=false;
this.classTag="turbo-toolbar";
this.fillInTemplate=function(_853,_854){
this.createChildWidgets(_854);
};
this.styleChanged=function(){
this.setStyledClass(this.domNode,(this.list?"-list":""));
};
};
dojo.inherits(dojo.widget.HtmlTurboToolbar,dojo.widget.HtmlWidget);
dojo.widget.tags.addParseTreeHandler("dojo:turbotoolbar");
dojo.provide("turbo.widgets.TurboTabbar");
dojo.provide("turbo.widgets.HtmlTurboTabbar");
dojo.require("turbo.widgets.TurboWidget");
dojo.require("turbo.widgets.TurboButton");
dojo.widget.HtmlTurboTabbar=function(){
turbo.setWidgetType(this,"TurboTabbar");
dojo.widget.HtmlTurboWidget.call(this);
this.isContainer=true;
this.templatePath=null;
this.templateString="<div dojoAttachPoint=\"containerNode\"></div>";
this.containerNode=null;
this.classTag="turbo_tabbar";
this.tabIndex=0;
this.lastIndex=-1;
this.canSelectTab=function(_855){
};
this.onSelectTab=function(_856){
};
this.onTabGlyphClick=function(_857,_858,_859){
};
this.fillInTemplate=function(_85a){
this.bindArgEvents(_85a);
};
this.styleChanged=function(){
this.setStyledClass(this.domNode,"");
for(var i=0,l=this.children.length;i<l;i++){
this.children[i].setTheme(this.style);
}
};
this.registerTab=function(_85c,_85d){
_85c.tabIndex=_85d;
_85c.onClick=this._tabClick;
_85c.onGlyphClick=this._tabGlyphClick;
_85c.setGroup(this.widgetId);
_85c.setTheme(this.style);
};
this.inheritedRegisterChild=this.registerChild;
this.registerChild=function(_85e,_85f){
this.registerTab(_85e,this.children.length);
return this.inheritedRegisterChild(_85e,_85f);
};
this.count=function(){
return this.children.length;
};
var self=this;
this._tabClick=function(_861){
self.tabClick(this,_861);
};
this._tabGlyphClick=function(_862){
self.tabGlyphClick(this,_862);
};
this.getTab=function(_863){
return this.children[_863];
};
this.tabGlyphClick=function(_864,_865){
this.onTabGlyphClick(_864.tabIndex,_864,_865);
};
this.tabClick=function(_866,_867){
if(this.canSelectTab(_866.inTabIndex)===false){
return this.selectTab(this.tabIndex);
}
this.lastIndex=this.tabIndex;
this.tabIndex=_866.tabIndex;
this.onSelectTab(this.tabIndex);
};
this.selectTab=function(_868){
if(!this.goodIndex(_868)){
_868=this.count()-1;
}
this.tabIndex=_868;
if(_868>=0){
this.getTab(this.tabIndex).setState("down");
}
};
this.insertChild=function(_869,_86a){
for(var i=_86a,l=this.count();i<l;i++){
this.children[i].tabIndex++;
}
this.children.splice(_86a,0,_869);
};
this.removeChild=function(_86c){
for(var i=_86c+1,l=this.count();i<l;i++){
this.children[i].tabIndex--;
}
this.children.splice(_86c,1);
};
this.addTab=function(_86e,_86f){
var node=this.containerNode;
var _871="last";
var _872=this.count();
if(arguments.length>1&&this.goodIndex(_86f)){
node=this.children[_86f].domNode;
_871="before";
_872=_86f;
}
var _873=dojo.widget.createWidget("TurboTab",_86e,node,_871);
this.insertChild(_873,_872);
this.registerTab(_873,_872);
if(this.count()==1){
this.selectTab(0);
this.tabClick(_873);
}
};
this.removeTab=function(_874){
if(this.goodIndex(_874)){
var _875=this.children[_874];
this.removeChild(_874);
_875.destroy();
}
if(this.lastIndex==_874){
this.lastIndex=-1;
}
if(this.tabIndex>_874){
this.tabIndex--;
}
if(this.tabIndex==_874){
var i=Math.min(this.count()-1,this.tabIndex);
this.tabIndex=-1;
if(i>=0){
this.selectTab(i);
this.tabClick(this.getTab(i));
}
}
};
this.goodIndex=function(_877){
return (_877>=0&&_877<this.count());
};
};
dojo.inherits(dojo.widget.HtmlTurboTabbar,dojo.widget.HtmlWidget);
dojo.widget.tags.addParseTreeHandler("dojo:turbotabbar");
dojo.provide("turbo.widgets.TurboModule");
dojo.provide("turbo.widgets.HtmlTurboModule");
dojo.require("turbo.widgets.TurboWidget");
dojo.require("dojo.io.*");
turbo.beforeOnLoad=true;
turbo.onloads=[];
turbo.doOnLoad=function(){
for(var i=0;i<turbo.onloads.length;i++){
turbo.onloads[i]();
}
turbo.onloads=[];
};
dojo.addOnLoad(function(){
turbo.beforeOnLoad=false;
turbo.doOnLoad();
});
dojo.widget.HtmlTurboModule=function(){
this.widgetType="TurboModule";
dojo.widget.HtmlTurboWidget.call(this);
this.templatePath=null;
this.classTag="turbo-module";
this.form="";
this.src="";
this.loaded=false;
this.sync=true;
this.delayed=false;
this.themeable=false;
this.manageIds=false;
this.macros="";
this.hasWidgets=true;
this.prefix="";
this._counter=0;
this.fillInTemplate=function(_879,_87a){
this.bindArgEvents(_879);
dojo.html.prependClass(this.domNode,this.classTag);
if(!this.delayed){
this.request();
}
};
this.onLoading=function(_87b){
};
this.onLoaded=function(){
};
this.setSrc=function(_87c){
this.loaded=false;
this.src=_87c;
if(!this.delayed){
this.request();
}
};
this.clear=function(){
turbo.clean(this.domNode);
dojo.dom.removeChildren(this.domNode);
};
this.load=function(_87d){
if(!_87d){
this.request();
}else{
this.delayed=false;
this.setSrc(_87d);
}
};
this.request=function(){
if(this.loaded||!this.src){
return;
}
var _87e={url:this.src,formNode:(dojo.lang.isString(this.form)?turbo.$(this.form):this.form),sync:this.sync,load:turbo.bind(this,this.receive),error:turbo.bind(this,this.error)};
turbo.setBusyCursor();
try{
if(dojo.io.bind(_87e)===false){
this.status="unspecified bind error";
turbo.debug(this.status);
}
}
catch(e){
this.status=e;
turbo.debug(e);
}
finally{
turbo.setDefaultCursor();
}
};
this.error=function(type,_880){
turbo.debug(_880);
};
this.receive=function(type,data,evt){
this.loaded=true;
if(this.onLoading(data)===false){
return;
}
turbo.clean(this.domNode);
if(this.manageIds){
data=this.uniquifyIds(data);
}
data=turbo.macros.insert(data,this.macros);
this.domNode.innerHTML=this.extractScript(data);
this.loadScript();
var _884=djConfig.searchIds;
delete djConfig.searchIds;
this.executeScript();
if(this.hasWidgets){
this.parseWidgets();
}
djConfig.searchIds=_884;
if(dojo.render.html.ie&&this.turboalign){
turbo.setStyleSizePx(this.domNode,1,1);
}
turbo.aligner.alignFrom(this.domNode.parentNode);
if(!turbo.beforeOnLoad){
turbo.doOnLoad();
}
this.onLoaded();
};
this.getIdPrefix=function(){
return (!this.manageIds?"":(this.prefix?this.prefix:this.widgetId)+"_"+this._counter+".");
};
this.byId=function(inId){
return turbo.$(this.getIdPrefix()+inId);
};
this.$=this.byId;
this.uniquifyIds=function(_886){
this._counter++;
var idp=this.getIdPrefix();
return turbo.stringReplace(_886,/(<[^>]*id=")([^"]*)/ig,function(w,pre,id){
return pre+idp+id;
});
};
this.extractScript=function(_88b){
var _88c=[];
var xml=turbo.stringReplace(_88b,/<script[^>]*src="([^"]*)"[^>]*>[\s\S]*?<\/script>/ig,function(w,_88f){
_88c.push(_88f);
return "";
});
this.sources=_88c;
var _890=[];
var id=this.widgetId;
var xml=turbo.stringReplace(_88b,/<script[^>]*>([\s\S]*?)<\/script>/ig,function(w,_893){
_893=turbo.stringReplace(_893,/%%module%%/ig,id);
_890.push(_893);
return "";
});
this.scripts=_890;
return xml;
};
this.loadScript=function(){
for(var i=0;i<this.sources.length;i++){
turbo.loadScript(this.sources[i]);
}
};
this.hookOnLoad=function(){
this.oldAddOnLoad=dojo.addOnLoad;
dojo.addOnLoad=function(_895){
turbo.onloads.push(_895);
};
};
this.unHookOnLoad=function(){
dojo.addOnLoad=this.oldAddOnLoad;
};
this.executeScript=function(){
this.hookOnLoad();
try{
for(var i=0;i<this.scripts.length;i++){
var _897="with (turbo.global) { "+this.scripts[i]+" }";
try{
eval(_897);
}
catch(e){
turbo.debug("TurboModule: exception evaluating module script");
turbo.debug("message = "+e.message,"fileName = "+e.fileName,"lineNumber = "+e.lineNumber);
dojo.debug("script = ["+_897+"]");
}
}
}
finally{
this.unHookOnLoad();
}
};
this.parseWidgets=function(){
turbo.parseWidgets(this.domNode);
};
};
dojo.inherits(dojo.widget.HtmlTurboModule,dojo.widget.HtmlWidget);
dojo.widget.tags.addParseTreeHandler("dojo:turbomodule");
dojo.provide("turbo.widgets.TurboNotebook");
dojo.provide("turbo.widgets.HtmlTurboNotebook");
dojo.require("turbo.widgets.TurboWidget");
dojo.require("dojo.io.*");
dojo.widget.HtmlTurboNotebook=function(){
this.widgetType="TurboNotebook";
dojo.widget.HtmlTurboWidget.call(this);
this.templatePath=null;
this.templateString="<div turboalign=\"client\"></div>";
this.themeable=false;
this.src="";
this.sync=true;
this.delayed=false;
this.classTag="turbo_notebook";
this.count=0;
this.pages=[];
this.modules=[];
this.selected=-1;
this.fillInTemplate=function(_898,_899){
var _89a=this.getFragNodeRef(_899);
for(var i=0;i<_89a.childNodes.length;){
var n=_89a.childNodes[i];
if(n.nodeType==1){
this.addPage(n);
}else{
i++;
}
}
this.parseChildWidgets(_899);
this.count=this.pages.length;
this._selectPage(0);
};
this.turboDestroy=function(){
turbo.clean(this.domNode);
};
this.goodIndex=function(_89d){
return (_89d>=0&&_89d<this.pages.length);
};
this.getPage=function(_89e){
if(this.goodIndex(_89e)){
return this.pages[_89e];
}else{
return null;
}
};
this.hidePage=function(_89f){
if(this.goodIndex(_89f)){
var p=this.getPage(_89f);
if(turbo.showing(p)){
turbo.hide(p);
}
}
};
this.showPage=function(_8a1){
if(!this.goodIndex(_8a1)){
return;
}
this.requestModule(this.modules[_8a1]);
turbo.show(this.getPage(_8a1));
};
this.showHidePage=function(_8a2,_8a3){
if(_8a3){
this.showPage(_8a2);
}else{
this.hidePage(_8a2);
}
};
this.requestModule=function(_8a4){
if(_8a4&&_8a4.delayed){
_8a4.request();
}
};
this.parseChildWidgets=function(_8a5){
this.modules=[];
var _8a6=dojo.widget.getParser().createSubComponents(_8a5);
if(!_8a6.length){
return;
}
var self=this;
var each=function(w){
if(dojo.lang.isArray(w)){
dojo.lang.forEach(w,each);
}else{
if(w.widgetType=="TurboModule"){
var idx=(dojo.lang.indexOf(self.pages,w.domNode));
if(idx>=0){
self.modules[idx]=w;
}
}
}
};
dojo.lang.forEach(_8a6,each);
};
this.addPage=function(_8ab,_8ac,_8ad){
var _8ae=this.pages.length;
if(arguments.length>2&&_8ad>=0&&_8ad<=_8ae){
_8ae=_8ad;
}
if(this.pages.length>0){
if(this.selected>=_8ae){
this.selected++;
}
turbo.hide(_8ab);
}else{
this.selected=_8ae;
}
this.domNode.insertBefore(_8ab,this.getPage(_8ae));
this.pages.splice(_8ae,0,_8ab);
return _8ae;
};
this.addPageContent=function(_8af,_8b0,_8b1){
var div=document.createElement("div");
div.innerHTML=_8af;
return this.addPage(div,_8b0,_8b1);
};
this.removePage=function(_8b3){
if(!this.goodIndex(_8b3)){
return;
}
var page=this.pages[_8b3];
turbo.clean(page);
page.parentNode.removeChild(page);
this.pages.splice(_8b3,1);
if(this.selected>_8b3){
this.selected--;
}else{
if(this.selected==_8b3){
this.selected=-1;
}
}
};
this._selectPage=function(_8b5){
this.showPage(_8b5);
if(this.selected!=_8b5){
this.hidePage(this.selected);
}
this.selected=_8b5;
};
this.selectPage=function(_8b6){
if(!this.goodIndex(_8b6)){
return;
}
var page=this.getPage(_8b6);
if(!page.turboNotebookShown){
turbo.setVisibility(page,false);
}
this._selectPage(_8b6);
var _8b8=function(){
turbo.aligner.align();
turbo.setVisibility(page,true);
page.turboNotebookShown=true;
};
turbo.defer(_8b8,200);
turbo.aligner.alignLater(500);
};
};
dojo.inherits(dojo.widget.HtmlTurboNotebook,dojo.widget.HtmlWidget);
dojo.widget.tags.addParseTreeHandler("dojo:turbonotebook");
dojo.provide("turbo.widgets.TurboPagebar");
dojo.provide("turbo.widgets.HtmlTurboPagebar");
dojo.require("turbo.widgets.TurboWidget");
dojo.require("turbo.widgets.TurboButton");
dojo.require("turbo.widgets.TurboTabbar");
dojo.require("turbo.widgets.TurboNotebook");
dojo.widget.HtmlTurboPagebar=function(){
this.widgetType="TurboPagebar";
dojo.widget.HtmlTurboTabbar.call(this);
this.templateString="<div turboalign=\"client\"><div dojoAttachPoint=\"containerNode\" turboalign=\"top\" class=\"turbo-pagebar-tabs\"></div><div dojoAttachPoint=\"pages\" turboAlign=\"client\" class=\"turbo-pagebar-pages\"></div></div>";
this.pages=null;
this.classTag="turbo-pagebar";
this.contentId="";
this.inheritedFillInTemplate=this.fillInTemplate;
this.fillInTemplate=function(_8b9,_8ba){
this.inheritedFillInTemplate(_8b9,_8ba);
turbo.defer(this,this.installPages,100);
};
this.installPages=function(){
if(this.contentId){
this.content=turbo.$(this.contentId);
}
if(!this.content){
this.content=this.domNode.nextSibling;
while(this.content&&this.content.nodeType&&this.content.nodeType!=1){
this.content=this.content.nextSibling;
}
}
if(this.content){
this.content.parentNode.removeChild(this.content);
this.pages.appendChild(this.content);
}else{
this.debug("installPages","BAD content - contentId: ("+this.contentId+")");
}
};
};
dojo.inherits(dojo.widget.HtmlTurboPagebar,dojo.widget.HtmlWidget);
dojo.widget.tags.addParseTreeHandler("dojo:turbopagebar");
dojo.provide("turbo.widgets.TurboPageButtons");
dojo.provide("turbo.widgets.HtmlTurboPageButtons");
dojo.require("turbo.widgets.TurboWidget");
dojo.widget.HtmlTurboPageButtons=function(){
this.widgetType="TurboPageButtons";
dojo.widget.HtmlTurboWidget.call(this);
this.templatePath=null;
this.pagesNode=null;
this.classTag="turbo-page-buttons";
this.className="";
this.buttonClass=this.classTag+"-button";
this.buttonHighlightClass=this.buttonClass+" "+this.classTag+"-highlight";
this.buttonSelectedClass=this.buttonClass+" "+this.classTag+"-selected";
this.buttonDisabledClass=this.buttonClass+" "+this.classTag+"-disabled";
this.buttonSeparatorClass=this.classTag+"-separator";
this.numPages=1;
this.numButtons=3;
this.onPageChange=function(){
};
this.buttonWidth=30;
this.buttonHeight=20;
this.buttonMargin=6;
this._x=0;
this._i=0;
this.lastValue=1;
this.buttonList="prevN, prev, innerFirst, pages, innerLast, next, nextN";
this.buttonLabels={first:"|&lt;",prevN:"&lt;&lt;",prev:"&lt;",next:"&gt;",nextN:"&gt;&gt;",last:"&gt;|",sep:"..."};
this.page=1;
this.fillInTemplate=function(_8bb,_8bc){
this.bindArgEvents(_8bb);
dojo.html.disableSelection(this.domNode);
dojo.event.connect(this.domNode,"onclick",this,"pageClick");
dojo.event.connect(this.domNode,"onmouseover",this,"pageOver");
dojo.event.connect(this.domNode,"onmouseout",this,"pageOut");
dojo.event.topic.subscribe("turboresize",this,"turboresize");
this.setButtonList(this.buttonList);
this.createPagesNode();
this.initBuild();
};
this.styleChanged=function(){
this.setStyledClass(this.domNode);
};
this.turboresize=function(){
if(turbo.showing(this.domNode)){
this.build();
}
};
this.build=function(){
this.createPages();
};
this.setNumPages=function(_8bd){
if(_8bd!=undefined){
this.numPages=Number(_8bd);
}
this.numPages=(this.numPages<1)?1:this.numPages;
this.build();
};
this.setButtonList=function(_8be){
this.buttonList={};
var list=_8be.replace(/ /g,"").split(",");
for(var i in list){
if(!Array.prototype[i]){
this.buttonList[list[i]]=true;
}
}
};
this.initBuild=function(_8c1,_8c2){
turbo.defer(turbo.bindArgs(this,this.setPage,_8c1,_8c2),10);
};
this.getNumPages=function(){
return this.numPages;
};
this.getPage=function(){
return this.page;
};
this.setPage=function(_8c3,_8c4){
if(_8c4){
this.numPages=Number(_8c4);
}
_8c3=Number(_8c3);
if(!_8c3||_8c3<1||_8c3>this.numPages){
return;
}
this.lastValue=this.page;
this.page=_8c3;
this.build();
};
this.doResize=function(){
this.build();
};
this.pageClick=function(_8c5){
var node=_8c5.target;
if(node.disabled||!node.page){
return;
}
this.setPage(node.page);
this.onPageChange(this.page);
};
this.pageOver=function(_8c7){
var node=_8c7.target;
if(node==this.domNode||node.disabled||!node.page||node.page==this.page){
return;
}
node.className=this.buttonHighlightClass;
};
this.pageOut=function(_8c9){
var node=_8c9.target;
if(node==this.domNode||node.disabled||!node.page){
return;
}
node.className=this.getDefaultButtonClass(node);
};
this.getDefaultButtonClass=function(_8cb){
return (_8cb.disabled?this.buttonDisabledClass:(_8cb.page==this.page&&!isNaN(_8cb.innerHTML)?this.buttonSelectedClass:this.buttonClass));
};
this.getPageRange=function(_8cc){
var _8cc=(_8cc!=undefined?_8cc:this.numButtons);
if(this.numPages<=_8cc){
return {start:1,end:Math.max(1,this.numPages)};
}
var rp=Math.floor(Number(_8cc)/2);
var _8ce={};
_8ce.start=Math.max(1,Number(this.page)-rp);
if(this.numPages-_8ce.start<_8cc){
_8ce.start=this.numPages-(_8cc-1);
}
_8ce.end=_8ce.start+_8cc-1;
return _8ce;
};
this.inPageRange=function(_8cf,_8d0){
var _8d1=this.getPageRange(_8d0);
return (_8cf>=_8d1.start&&_8cf<=_8d1.end);
};
this.numFixedButtons=function(_8d2){
var w=0;
for(var i in _8d2){
if(i!="pages"&&i!="innerFirst"&&i!="innerLast"){
w++;
}
}
return w;
};
this.calcFixedButtonsWidth=function(_8d5){
var w=0;
for(var i in _8d5){
w+=(i!="pages"&&i!="innerFirst"&&i!="innerLast")?this.buttonWidth+this.buttonMargin:0;
}
return w;
};
this.calcNumButtons=function(_8d8){
var s=turbo.getContentSize(this.domNode);
var w=this.calcFixedButtonsWidth(_8d8);
var bs=this.buttonWidth+this.buttonMargin;
var _8dc=function(){
return Math.floor((s.w-w)/bs);
};
var _8dd=_8d8["innerFirst"];
var _8de=(_8dd==true)&&this.inPageRange(1,_8dc());
if(_8dd&&!_8de){
w+=bs+bs;
}
if(_8d8["innerLast"]&&!this.inPageRange(this.numPages,_8dc())){
w+=bs+bs;
}
if(_8de&&!this.inPageRange(1,_8dc())){
w+=bs+bs;
}
return _8dc(_8d8);
};
this.attachButton=function(_8df){
this.pagesNode.appendChild(_8df);
};
this.createPageButton=function(_8e0,_8e1,_8e2,_8e3){
var node=(this._i<this.oldNumButtons)?this.pagesNode.childNodes[this._i]:document.createElement("div");
node.page=_8e0;
node.disabled=(_8e2?true:false);
node.innerHTML=(_8e1?_8e1:_8e0);
node.className=this.getDefaultButtonClass(node);
var w=(_8e3!=undefined?_8e3:this.buttonWidth);
node.style.lineHeight=this.buttonHeight+"px";
turbo.setStyleBoundsPx(node,this._x,0,w,this.buttonHeight);
this._x+=w+this.buttonMargin;
this._i++;
if(this._i>=this.oldNumButtons){
this.attachButton(node);
}
};
this.createSep=function(){
var sep=(this._i<this.oldNumButtons)?this.pagesNode.childNodes[this._i]:document.createElement("div");
sep.page=undefined;
sep.disabled=undefined;
sep.className=this.buttonSeparatorClass;
sep.innerHTML=this.buttonLabels.sep;
turbo.setStyleBoundsPx(sep,this._x,0,this.buttonWidth,this.buttonHeight);
this._x+=this.buttonWidth+this.buttonMargin;
this._i++;
if(this._i>=this.oldNumButtons){
this.attachButton(sep);
}
};
this.create_first=function(){
this.createPageButton(1,this.buttonLabels.first,(this.page==1));
};
this.create_last=function(){
this.createPageButton(this.numPages,this.buttonLabels.last,(this.page==this.numPages));
};
this.create_pages=function(){
var _8e7=this.getPageRange();
for(var i=_8e7.start;i<=_8e7.end;i++){
this.createPageButton(i);
}
};
this.create_prev=function(){
var _8e9=Math.max(1,Number(this.page)-1);
this.createPageButton(_8e9,this.buttonLabels.prev,(this.page==1));
};
this.create_next=function(){
var _8ea=Math.min(this.numPages,Number(this.page)+1);
this.createPageButton(_8ea,this.buttonLabels.next,(this.page==this.numPages));
};
this.create_prevN=function(){
var _8eb=Math.max(1,Number(this.page)-this.numButtons);
this.createPageButton(_8eb,this.buttonLabels.prevN,(this.page==1));
};
this.create_nextN=function(){
var _8ec=Math.min(this.numPages,Number(this.page)+this.numButtons);
this.createPageButton(_8ec,this.buttonLabels.nextN,(this.page==this.numPages));
};
this.create_innerFirst=function(){
if(!this.inPageRange(1)){
this.createPageButton(1,"1");
this.createSep();
}
};
this.create_innerLast=function(){
if(!this.inPageRange(this.numPages)){
this.createSep();
this.createPageButton(this.numPages,this.numPages);
}
};
this.getButtonList=function(){
var x=0;
for(var i in this.buttonList){
x++;
}
var t=this.calcNumButtons(this.buttonList)+this.numFixedButtons(this.buttonList);
var _8f0={prev:true,pages:true,next:true};
return (t<x)?_8f0:this.buttonList;
};
this.createPages=function(){
this._x=0;
this._i=0;
this.oldNumButtons=this.pagesNode.childNodes.length;
var _8f1=this.getButtonList();
this.numButtons=this.calcNumButtons(_8f1);
for(var i in _8f1){
this["create_"+i]();
}
turbo.setStyleSizePx(this.pagesNode,this._x,this.buttonHeight+this.buttonMargin);
this.removeExcessPages();
};
this.removeExcessPages=function(){
for(var i=this._i;i<this.oldNumButtons;i++){
this.pagesNode.removeChild(this.pagesNode.childNodes[this._i]);
}
};
this.createPagesNode=function(){
this.pagesNode=document.createElement("div");
this.pagesNode.style.position="relative";
this.pagesNode.style.top="0";
this.domNode.appendChild(this.pagesNode);
};
};
dojo.inherits(dojo.widget.HtmlTurboPageButtons,dojo.widget.HtmlWidget);
dojo.widget.tags.addParseTreeHandler("dojo:TurboPageButtons");
dojo.provide("turbo.widgets.TurboSlider");
dojo.provide("turbo.widgets.HtmlTurboSlider");
dojo.require("turbo.widgets.TurboWidget");
turbo.rangemap=function(){
this.minimum=0;
this.maximum=100;
this.getRange=function(){
return (this.maximum-this.minimum);
};
this.getExtentOverRange=function(){
return this.getExtent()/this.getRange();
};
this.setMinMax=function(_8f4,_8f5){
this.minimum=_8f4;
this.maximum=_8f5;
};
this.changePosition=function(inDx){
var p=this.getPosition();
var n=p+inDx;
return (this.setPosition(p+inDx)-p)-inDx;
};
this.setValue=function(_8f9){
this.setPosition(Math.round((_8f9-this.minimum)*this.getExtentOverRange()));
};
this.getValue=function(){
var eor=this.getExtentOverRange();
return (eor?Math.round(this.getPosition()/eor):0)+this.minimum;
};
};
dojo.widget.HtmlTurboRangebar=function(){
turbo.setWidgetType(this,"TurboRangeBar");
dojo.widget.HtmlTurboWidget.call(this);
turbo.rangemap.call(this);
this.templateString="<div dojoAttachPoint=\"LeftBar\" tabindex=\"1\"><div dojoAttachPoint=\"RightBar\"></div></div>";
this.templatePath=null;
this.LeftBar=null;
this.RightBar=null;
this.classTag="turbo_rangebar";
this.margin=1;
this.fillInTemplate=function(_8fb,_8fc){
if(this.extraArgs["value"]){
window.setTimeout(turbo.bindArgs(this,this.setValue,this.extraArgs["value"]),400);
}
};
this.styleChanged=function(){
this.setClassName(this.LeftBar,"Left");
this.setClassName(this.RightBar,"Right");
};
this.getWindow=function(){
return this.margin;
};
this.getExtent=function(){
return this.LeftBar.offsetWidth-this.getWindow();
};
this.getPosition=function(){
return this.RightBar.offsetLeft;
};
this.setPosition=function(_8fd){
var _8fe=this.getWindow();
var _8ff=this.getExtent();
var p=(_8fd>_8ff?_8ff:(_8fd<this.margin?this.margin:_8fd));
this.RightBar.style.marginLeft=(p&&p>0?p+"px":0);
var _901=this.LeftBar.offsetWidth;
return p;
};
};
dojo.inherits(dojo.widget.HtmlTurboRangebar,dojo.widget.HtmlWidget);
dojo.widget.tags.addParseTreeHandler("dojo:turborangebar");
dojo.widget.HtmlTurboSlider=function(){
this.widgetType="TurboSlider";
dojo.widget.HtmlTurboRangebar.call(this);
this.templateString="<div dojoAttachPoint=\"LeftBar\" tabindex=\"1\"><div dojoAttachPoint=\"RightBar\"><div dojoAttachPoint=\"Thumb\"><div></div></div></div>";
this.snap=false;
this.Thumb=null;
this.classTag="turbo_slider";
this.mouseDown=false;
this.mouseX=0;
this.changing=function(_902){
};
this.change=function(_903){
};
this.inheritedFillInTemplate=this.fillInTemplate;
this.fillInTemplate=function(_904,_905){
this.inheritedFillInTemplate(_904,_905);
dojo.event.connect(this.Thumb,"onmousedown",this,"down");
dojo.event.connect(this.Thumb,"onmouseup",this,"up");
dojo.event.connect(this.Thumb,"onmousemove",this,"move");
dojo.event.connect(this.LeftBar,"onmousewheel",this,"wheel");
};
this.inheritedStyleChanged=this.styleChanged;
this.styleChanged=function(){
this.inheritedStyleChanged();
this.setClassName(this.Thumb,"Thumb");
};
this.getWindow=function(){
return this.Thumb.offsetWidth;
};
this.down=function(_906){
this.lastValue=this.getValue();
if(this.LeftBar.focus){
this.LeftBar.focus();
}
this.mouseDown=true;
this.mouseX=_906.screenX;
turbo.capture(this.Thumb);
};
this.up=function(_907){
if(this.mouseDown){
this.mouseDown=false;
turbo.release(this.Thumb);
if(this.snap){
this.setValue(this.getValue());
}
this.change(this);
}
};
this.move=function(_908){
if(this.mouseDown){
var dx=_908.screenX-this.mouseX;
this.mouseX=_908.screenX+this.changePosition(dx);
if(dojo.render.html.safari&&window.getSelection){
window.getSelection().collapse();
}
this.changing(this);
}
};
this.wheel=function(_90a){
var v=this.getValue()+Math.round(_90a.wheelDelta/120);
this.setValue(this.getValue()+Math.round(_90a.wheelDelta/120));
this.changing(this);
};
};
dojo.inherits(dojo.widget.HtmlTurboSlider,dojo.widget.HtmlWidget);
dojo.widget.tags.addParseTreeHandler("dojo:turboslider");
dojo.provide("turbo.widgets.TurboRollover");
dojo.provide("turbo.widgets.HtmlTurboRollover");
dojo.require("turbo.widgets.TurboWidget");
dojo.widget.HtmlTurboRollover=function(){
this.widgetType="TurboRollover";
dojo.widget.HtmlTurboWidget.call(this);
this.templatePath=null;
this.classTag="turbo-rollover";
this.mouseover=function(_90c){
dojo.debug("over");
};
this.mouseout=function(_90d){
dojo.debug("out");
};
this.click=function(_90e){
dojo.debug("click");
};
this.themeable=false;
this.fillInTemplate=function(_90f,_910){
this.bindArgEvents(_90f);
dojo.event.connect(this.domNode,"onmouseover",this,"mouseover");
dojo.event.connect(this.domNode,"onmouseout",this,"mouseout");
dojo.event.connect(this.domNode,"onclick",this,"click");
};
};
dojo.inherits(dojo.widget.HtmlTurboRollover,dojo.widget.HtmlWidget);
dojo.widget.tags.addParseTreeHandler("dojo:turborollover");
dojo.provide("turbo.widgets.TurboSplitter");
dojo.provide("turbo.widgets.HtmlTurboSplitter");
dojo.require("turbo.turbo");
dojo.require("turbo.lib.align");
dojo.require("turbo.widgets.TurboWidget");
dojo.widget.HtmlTurboSplitter=function(){
this.widgetType="TurboSplitter";
dojo.widget.HtmlTurboWidget.call(this);
this.templatePath=null;
this.classTag="turbo-splitter";
this.mouseDown=false;
this.mouseX=0;
this.changing=function(){
};
this.change=function(){
};
this.fillInTemplate=function(_911,_912){
switch(this.turboalign){
case "left":
case "right":
break;
case "top":
case "bottom":
this.vertical=true;
break;
default:
this.turboalign="left";
this.domNode.setAttribute("turboalign","left");
break;
}
dojo.event.connect(this.domNode,"onmousedown",this,"down");
dojo.event.connect(this.domNode,"onmouseup",this,"up");
dojo.event.connect(this.domNode,"onmousemove",this,"move");
dojo.event.connect(this.domNode,"onmouseover",this,"killCapturedEvent");
dojo.event.connect(this.domNode,"onmouseout",this,"killCapturedEvent");
};
this.styleChanged=function(){
this.domNode.style.cursor=(this.vertical?"n-resize":"e-resize");
this.setStyledClass(this.domNode,(this.vertical?"-v":"-h"));
};
this.getPosition=function(){
return {top:dojo.style.getNumericStyle(this.domNode,"top"),left:dojo.style.getNumericStyle(this.domNode,"left")};
};
this.getSizeNode=function(inDx){
switch(this.turboalign){
case "left":
case "top":
var node=this.domNode.previousSibling;
while(node&&node.nodeType!=1){
node=node.previousSibling;
}
break;
case "right":
case "bottom":
var node=this.domNode.nextSibling;
while(node&&node.nodeType!=1){
node=node.nextSibling;
}
break;
}
return node;
};
this.adjustSize=function(inDx,inDy){
turbo.setOuterSize(this.sizeNode,this.size.w+(this.turboalign=="right"?-inDx:inDx),this.size.h+(this.turboalign=="bottom"?-inDy:inDy));
turbo.aligner.align();
};
this.killCapturedEvent=function(_917){
if(this.mouseDown&&_917){
dojo.event.browser.stopEvent(_917);
}
};
this.down=function(_918){
this.sizeNode=this.getSizeNode();
if(!this.sizeNode){
return;
}
this.size=turbo.getOuterSize(this.sizeNode);
this.initialPosition=this.getPosition();
this.position=this.getPosition();
this.mouseDown=true;
this.mouseX=_918.screenX;
this.mouseY=_918.screenY;
turbo.capture(this.domNode);
document.body.style.cursor=this.domNode.style.cursor;
};
this.up=function(_919){
if(this.mouseDown){
this.mouseDown=false;
turbo.release(this.domNode);
this.adjustSize(this.position.left-this.initialPosition.left,this.position.top-this.initialPosition.top);
this.change();
document.body.style.cursor="";
}
};
this.move=function(_91a){
if(this.mouseDown){
this.killCapturedEvent(_91a);
if(this.vertical){
this.moveY(_91a.screenY-this.mouseY);
}else{
this.moveX(_91a.screenX-this.mouseX);
}
this.mouseX=_91a.screenX;
this.mouseY=_91a.screenY;
this.changing();
}
};
this.moveX=function(inDx){
this.position.left+=inDx;
this.domNode.style.left=this.position.left+"px";
};
this.moveY=function(inDy){
this.position.top+=inDy;
this.domNode.style.top=this.position.top+"px";
};
this.resizeX=function(inDx){
this.adjustSize(inDx,0);
};
this.resizeY=function(inDy){
this.adjustSize(0,inDy);
};
};
dojo.inherits(dojo.widget.HtmlTurboSplitter,dojo.widget.HtmlWidget);
dojo.widget.tags.addParseTreeHandler("dojo:turbosplitter");
dojo.provide("turbo.widgets.TurboTree");
dojo.provide("turbo.widgets.HtmlTurboTree");
dojo.require("turbo.widgets.TurboWidget");
turbo.objectToArray=function(_91f){
if(turbo.isArray(_91f)){
return _91f;
}
var _920=[];
for(var i in _91f){
_920.push(new Array(i,turbo.objectToArray(_91f[i])));
}
return _920;
};
dojo.widget.HtmlTurboTree=function(){
this.widgetType="TurboTree";
dojo.widget.HtmlTurboWidget.call(this);
this.templatePath=null;
this.templateString="<div dojoattachpoint=\"mainDiv\"><div dojoattachpoint=\"treeDiv\" class=\"turbo-tree-scroller\"></div></div>";
this.classTag="turbo-tree";
this.imageRoot=dojo.uri.dojoUri(this.themeRoot+"default/images/");
this.mainDiv=null;
this.treeDiv=null;
this.nodes=null;
this.selected=null;
this.onCanUnselect=function(_922){
};
this.onCanSelect=function(_923){
};
this.onNodeSelected=function(_924){
};
this.fillInTemplate=function(_925){
this.bindArgEvents(_925);
this.domNode.style.overflow="auto";
if(this.nodes){
this.buildNodes(this.nodes);
}
dojo.event.connect(this.mainDiv,"onclick",this,"divClick");
};
this.styleChanged=function(){
this.mainDiv.className=this.classTag+(this.style?" "+this.classTag+"_"+this.style:"");
};
this.buildLeaf=function(_926,_927,_928,_929){
var img=document.createElement("img");
var leaf=this.imageRoot+(_926?"tree_root.gif":(_928?"tree_last_leaf.gif":"tree_leaf.gif"));
if(_927){
img.src=this.imageRoot+(_929?"tree_closed":"tree_open")+".gif";
img.style.backgroundImage="url("+leaf+")";
}else{
img.src=leaf;
}
return img;
};
this.buildNode=function(_92c,_92d,_92e,_92f){
if(dojo.lang.isObject(_92e)){
var _930=(_92e.children)&&(_92e.children.length>0);
var _931=(_92e.content?_92e.content:_92e.name);
}else{
var _930=false;
var _931=_92e;
}
var row=document.createElement("div");
row.name=_92e.name;
row.data=_92e.data;
row.turboTreeNode=true;
if(_92d){
row.appendChild(_92d.cloneNode(true));
}else{
row.appendChild(document.createTextNode(""));
}
row.appendChild(this.buildLeaf((_92d==null),_930,_92f,_92e.closed));
var node=document.createElement("span");
node.innerHTML=_931;
node.className=this.classTag+"-content";
node.style.cursor="default";
row.appendChild(node);
if(_930){
var pre=(_92d?_92d:document.createElement("span"));
var img=document.createElement("img");
img.src=this.imageRoot+(_92f?"tree_blank.gif":"tree_bar.gif");
pre.appendChild(img);
var _936=document.createElement("div");
this.buildChildren(_936,pre,_92e.children);
row.appendChild(_936);
pre.removeChild(img);
if(_92e.closed){
_936.style.display="none";
}
}
_92c.appendChild(row);
};
this.buildChildren=function(_937,_938,_939){
var l=_939.length;
for(var i=0;i<l;i++){
this.buildNode(_937,_938,_939[i],(i==l-1));
}
};
this.teardown=function(){
this.treeDiv.innerHTML="";
this.selected=null;
};
this.buildNodes=function(_93c){
this.teardown();
if(dojo.lang.isArray(_93c)){
this.buildChildren(this.treeDiv,null,_93c);
}else{
this.buildNode(this.treeDiv,null,_93c,true);
}
};
this.getToggleElement=function(_93d){
return _93d.childNodes[1];
};
this.getContentElement=function(_93e){
return _93e.childNodes[2];
};
this.getChildrenElement=function(_93f){
return _93f.childNodes[3];
};
this.setSelected=function(_940,_941){
if(_940){
with(this.getContentElement(_940)){
style.backgroundColor=(_941?"blue":"");
style.color=(_941?"white":"");
}
}
};
this.getContent=function(_942){
return this.getContentElement(_942).innerHTML;
};
this.selectNode=function(_943){
if(this.onCanUnselect(this.selected)===false||this.onCanSelect(_943)===false){
return;
}
this.setSelected(this.selected,false);
this.selected=_943;
this.setSelected(this.selected,true);
this.onNodeSelected(this.selected);
};
this.toggleNode=function(_944){
var n=this.getChildrenElement(_944);
if(n){
n.style.display=(n.style.display=="none"?"":"none");
this.getToggleElement(_944).src=this.imageRoot+(n.style.display=="none"?"tree_closed":"tree_open")+".gif";
}
};
this.isTreeNode=function(_946){
return _946&&_946.turboTreeNode;
};
this.divClick=function(_947){
var t=_947.target;
while(t&&!this.isTreeNode(t)){
t=t.parentNode;
}
if(t){
if(_947.target==this.getToggleElement(t)){
this.toggleNode(t);
}else{
this.selectNode(t);
}
}
};
this._firstTreeNode=function(_949){
if(_949&&!this.isTreeNode(_949)){
_949=_949.nextSibling;
}
return _949;
};
this.nextNode=function(_94a){
return (_94a?this._firstTreeNode(_94a.nextSibling):null);
};
this.childNode=function(_94b){
if(!_94b||!this.isTreeNode(_94b)){
return null;
}
var _94c=this.getChildrenElement(_94b);
if(!_94c){
return null;
}
return this._firstTreeNode(_94c.firstChild);
};
this.rootNode=function(){
return this._firstTreeNode(this.treeDiv.firstChild);
};
this.isLeaf=function(_94d){
return (!this.getChildrenElement(_94d));
};
};
dojo.inherits(dojo.widget.HtmlTurboTree,dojo.widget.HtmlWidget);
dojo.widget.tags.addParseTreeHandler("dojo:turbotree");
dojo.provide("turbo.widgets.TurboTree2");
dojo.provide("turbo.widgets.HtmlTurboTree2");
dojo.require("turbo.widgets.TurboWidget");
turbo.TreeNode=function(_94e){
this.tree=_94e;
this.id=this.tree.makeNodeId();
this.childCount=0;
this.domNode=null;
this.elements={gutter:0,connector:1,button:1,content:2,children:3};
this.hasChildren=false;
this.childrenInited=false;
this.parent=null;
this.getNodeElement=function(_94f){
return (this.domNode?this.domNode.childNodes[_94f]:null);
};
this.getImg=function(_950){
var i=document.createElement("img");
i.src=this.tree.imageRoot+_950;
return i;
};
this.getBar=function(){
return this.getImg("tree_bar.gif");
};
this.getBlank=function(){
return this.getImg("tree_blank.gif");
};
this.buildGutter=function(_952){
if(_952){
var g=_952.getNodeElement(this.elements.gutter).cloneNode(true);
g.appendChild((!g.hasChildNodes()||_952.isLastChildNode())?this.getBlank():this.getBar());
return g;
}else{
return document.createElement("span");
}
};
this.buildContent=function(){
var s=document.createElement("span");
s.innerHTML="Node";
s.className=this.tree.classTag+"-content";
s.style.cursor="default";
return s;
};
this.buildDomNode=function(_955){
node=document.createElement("div");
node.appendChild(this.buildGutter(_955));
node.appendChild(document.createElement("img"));
node.appendChild(this.buildContent());
node.appendChild(document.createElement("div"));
node.setAttribute("turboTreeNode","true");
node.id=this.id;
this.domNode=node;
return node;
};
this.setConnector=function(_956,_957){
var i=this.getNodeElement(this.elements.connector);
i.style.backgroundImage="url("+this.tree.imageRoot+(_956?"tree_root":(_957?"tree_last_leaf":"tree_leaf"))+".gif"+")";
};
this.isRootNode=function(){
return (this.domNode.parentNode==this.tree.treeDiv);
};
this.isLastChildNode=function(){
return (this.domNode.parentNode&&this.domNode.parentNode.lastChild==this.domNode);
};
this.selectConnector=function(){
this.setConnector(this.isRootNode(),this.isLastChildNode());
};
this.getButton=function(){
return this.getNodeElement(this.elements.button);
};
this.setButton=function(_959,_95a){
this.getButton().src=this.tree.imageRoot+(!_959?"tree_blank":(_95a?"tree_open":"tree_closed"))+".gif";
};
this.selectButton=function(){
this.setButton(this.hasChildren,this.getOpen());
};
this.getOpen=function(){
var n=this.getNodeElement(this.elements.children);
return (n?n.style.display=="":undefined);
};
this.setOpen=function(_95c){
var n=this.getNodeElement(this.elements.children);
if(n){
n.style.display=(_95c?"":"none");
}
if(this.getOpen()&&this.hasChildren&&!this.childrenInited){
this.tree.initChildren(this);
}
this.selectButton();
};
this.toggleNode=function(){
this.setOpen(!this.getOpen());
};
this.setContent=function(_95e){
this.getNodeElement(this.elements.content).innerHTML=_95e;
};
this.appendTo=function(_95f){
this.parent=_95f;
var p=(_95f?_95f.getNodeElement(this.elements.children):this.tree.treeDiv);
this.index=p.childNodes.length;
p.appendChild(this.domNode);
var n=this.tree.nodeFromDomNode(this.domNode.previousSibling);
if(n){
n.selectConnector();
}
this.selectConnector();
};
this.setSelected=function(_962){
if(_962===undefined){
_962=true;
}
var c=this.tree.classTag+"-content";
var _964=this.getNodeElement(this.elements.content);
if(_964){
_964.className=c+(_962?" "+c+"-selected":"");
}
};
this.getChildrenDomNode=function(){
return this.getNodeElement(inNode.elements.children);
};
this.getChildNode=function(_965){
var _966=this.getChildrenDomNode().childNodes;
if(turbo.isGoodIndex(_966,_965)){
return this.tree.nodeFromDomNode(_966[_965]);
}
};
this._deleteChildNodes=function(_967){
var _968=_967.getChildrenDomNode().childNodes;
for(var i=0,l=_968.length;i<l;i++){
var el=_968[i];
this._deleteChildNodes(this.tree.nodeFromDomNode(el));
delete this.tree.nodes[el.id];
}
};
this.removeChildren=function(){
this._deleteChildNodes(this);
this.domNode.replaceChild(document.createElement("div"),this.getChildrenDomNode());
this.setOpen(false);
};
this.refreshChildren=function(){
if(!this.hasChildren){
return;
}
this.removeChildren();
this.childrenInited=false;
this.tree.initChildren(this);
this.setOpen(true);
};
};
dojo.widget.HtmlTurboTree2=function(){
this.widgetType="TurboTree2";
dojo.widget.HtmlTurboWidget.call(this);
this.templatePath=null;
this.templateString="<div><div dojoattachpoint=\"treeDiv\" class=\"turbo-tree-scroller\"></div></div>";
this.styleRoot="TurboTree";
this.classTag="turbo-tree";
this.imageRoot=dojo.uri.dojoUri(this.themeRoot+"default/images/");
this.treeDiv=null;
this.nodeId=0;
this.nodes=[];
this.selected=null;
this.onInitNode=function(){
};
this.onInitChildren=function(){
};
this.onCanUnselect=function(_96b){
};
this.onCanSelect=function(_96c){
};
this.onSelect=function(_96d){
};
this.fillInTemplate=function(_96e,_96f){
this.bindArgEvents(_96e);
this.setTheme("");
dojo.event.connect(this.domNode,"onclick",this,"domClick");
};
this.styleChanged=function(){
this.setStyledClass(this.domNode,"");
};
this.makeNodeId=function(){
return this.widgetId+":"+this.nodeId++;
};
this.nodeFromDomNode=function(_970){
return (_970&&_970.id?this.nodes[_970.id]:null);
};
this.clear=function(){
this.nodeId=0;
this.nodes=[];
this.treeDiv.innerHTML="";
};
this.setRootCount=function(_971){
this.clear();
for(var i=0;i<_971;i++){
this.newNode(null);
}
};
this.newTreeNode=function(_973){
var n=new turbo.TreeNode(this);
this.nodes[n.id]=n;
n.buildDomNode(_973);
return n;
};
this.newNode=function(_975){
var n=this.newTreeNode(_975);
n.appendTo(_975);
n.setOpen(false);
this.onInitNode(n);
n.selectButton();
return n;
};
this.initChildren=function(_977){
this.onInitChildren(_977);
var c=_977.childCount;
for(var i=0;i<c;i++){
this.newNode(_977);
}
_977.childrenInited=true;
_977.hasChildren=(c>0);
};
this.selectNode=function(_97a){
if(_97a&&this.onCanSelect(_97a)===false){
return;
}
if(this.selected){
if(this.onCanUnselect(this.selected)===false){
return;
}
this.selected.setSelected(false);
}
this.selected=_97a;
if(this.selected){
this.selected.setSelected(true);
}
this.onSelect(this.selected);
};
this.forEach=function(_97b){
for(var i in this.nodes){
if(_97b(this.nodes[i])===true){
return this.nodes[i];
}
}
return null;
};
this.isTreeNode=function(_97d){
return _97d&&_97d.getAttribute&&_97d.getAttribute("turboTreeNode");
};
this.nodeClick=function(_97e,_97f){
if(_97e){
if(_97e.getButton()==_97f.target){
_97e.toggleNode();
}else{
this.selectNode(_97e);
}
}
};
this.domClick=function(_980){
var n=_980.target;
while(n&&!this.isTreeNode(n)){
n=n.parentNode;
}
this.nodeClick((n?this.nodeFromDomNode(n):null),_980);
};
this.getRootNodeByIndex=function(_982){
var _983=this.treeDiv.childNodes;
if(turbo.isGoodIndex(_983,_982)){
return this.nodeFromDomNode(_983[_982]);
}
};
this.getNodeByIndex=function(){
if(!(arguments.length>0)){
return null;
}
var node=this.getRootNode(arguments[0]);
for(var i=1,l=arguments.length;i<l;i++){
node=node.getChildNode(arguments[i]);
}
return node;
};
this.removeNode=function(_986){
_986.removeChildren();
delete this.nodes[_986.id];
var prev=_986.domNode.previousSibling;
var _988=this.nodeFromDomNode(prev);
dojo.dom.removeNode(_986.domNode);
if(_988){
_988.setConnector(_988.isRootNode(),_988.isLastChildNode());
}
};
};
dojo.inherits(dojo.widget.HtmlTurboTree2,dojo.widget.HtmlWidget);
dojo.widget.tags.addParseTreeHandler("dojo:turbotree2");
dojo.provide("turbo.widgets.TurboRepeater");
dojo.provide("turbo.widgets.HtmlTurboRepeater");
dojo.require("turbo.widgets.TurboWidget");
dojo.widget.HtmlTurboRepeater=function(){
this.widgetType="TurboRepeater";
dojo.widget.HtmlTurboWidget.call(this);
this.isContainer=false;
this.templatePath=null;
this.containerNode=null;
this.classTag="turbo_repeater";
this.data={};
this.openMacro="{%";
this.closeMacro="}";
this.count=100;
this.clear=function(){
dojo.event.browser.clean(this.domNode);
this.domNode.innerHTML="";
};
this.fillInTemplate=function(_989,_98a){
this.domNode.style.display="";
this.nodes=this.domNode.cloneNode(true);
this.clear();
};
this.getDatum=function(inId){
try{
return this.data[inId];
}
catch(e){
return "failed to get datum";
}
};
this.interpolate=function(_98c){
for(var i in this.data){
_98c=_98c.replace(RegExp(this.openMacro+i+this.closeMacro,"gi"),this.data[i]);
}
return _98c;
};
this.iterate=function(_98e,_98f){
return false;
};
this.afterBuild=function(){
return false;
};
this.build=function(){
this.clear();
for(var i=0;i<this.count;i++){
this.index=i;
if(this.iterate(this,this.index)===false){
break;
}
var iter=this.nodes.cloneNode(true);
iter.innerHTML=this.interpolate(iter.innerHTML);
var frag=new dojo.xml.Parse().parseElement(iter);
dojo.widget.getParser().createSubComponents(frag);
this.domNode.appendChild(iter);
}
if(this.afterBuild){
this.afterBuild();
}
};
this.xbuild=function(){
this.clear();
var self=this;
var _994=function(){
if(self.index>=self.count||self.iterate(self,self.index)===false){
return;
}
var iter=self.nodes.cloneNode(true);
iter.innerHTML=self.interpolate(iter.innerHTML);
self.domNode.appendChild(iter);
self.index++;
window.setTimeout(_994,0);
};
this.index=0;
_994();
};
};
dojo.inherits(dojo.widget.HtmlTurboRepeater,dojo.widget.HtmlWidget);
dojo.widget.tags.addParseTreeHandler("dojo:turborepeater");
dojo.provide("turbo.lib.scrim");
dojo.require("turbo.turbo");
turbo.defineClass("turbo.pool",null,{pool:[],findUnused:function(){
for(var i=this.pool.length-1;i>=0;i--){
if(!pool[i].__inuse){
return this.pool[i];
}
}
return false;
},create:function(){
},_create:function(){
var _997=this.create();
this.pool.push(_997);
},get:function(){
var _998=this.findUnused()||this._create();
if(_998){
_998.__inuse=true;
}
return _998;
},release:function(_999){
if(_999){
_999.__inuse=false;
}
}});
turbo.scrim={pool:new turbo.pool(),createIFrame:function(){
var node=document.createElement("iframe");
node.setAttribute("frameBorder",0);
node.setAttribute("scrolling","no");
return node;
},createDiv:function(){
return document.createElement("div");
},createScrim:function(){
var node=(dojo.render.html.ie?turbo.scrim.createIFrame():turbo.scrim.createDiv());
node.isScrim=true;
return node;
},get:function(_99c,inId,_99e){
var node=turbo.scrim.pool.get();
node.scrimActive=true;
node.style.border=0;
node.style.position="absolute";
node.id=inId;
node.name=inId;
turbo.setStyleProperties(node,_99e);
_99c.appendChild(node);
turbo.scrim.size(node);
return node;
},release:function(_9a0){
if(_9a0.isScrim){
turbo.scrim.pool.release(_9a0);
dojo.dom.removeNode(_9a0);
}
},size:function(_9a1){
var siz=turbo.getInnerSize(_9a1.parentNode);
if(_9a1.parentNode==document.body){
var _9a3=0;
var aW=_9a3;
var aH=_9a3;
}else{
var aW=-dojo.style.getBorderWidth(_9a1.parentNode);
var aH=-dojo.style.getBorderHeight(_9a1.parentNode);
}
turbo.setBounds(_9a1,0,0,siz.w+aW,siz.h+aH);
}};
turbo.scrim.pool.get=turbo.scrim.createScrim;
dojo.provide("turbo.widgets.TurboModal");
dojo.provide("turbo.widgets.HtmlTurboModal");
dojo.require("turbo.lib.scrim");
dojo.require("turbo.widgets.TurboWidget");
turbo.modals=[];
dojo.widget.HtmlTurboModal=function(){
this.widgetType="TurboModal";
dojo.widget.HtmlTurboWidget.call(this);
this.templatePath=null;
this.templateString="<div dojoAttachPoint=\"domNode\" hidefocus=\"hidefocus\"><div tabIndex=\"0\" hidefocus=\"hidefocus\" dojoAttachPoint=\"contentNode\" dojoOnFocus=\"interceptTab\"></div><span dojoAttachPoint=\"tabOut\" dojoOnFocus=\"interceptTab\" tabindex=\"0\"></span></div>";
this.tabIntercepted=false;
this.classTag="turbo-modal";
this.modalWidth=-1;
this.modalHeight=-1;
this.defaultWidth=50;
this.defaultHeight=50;
this.bgName="";
this.modalFocus="";
this.allowFocus=true;
this.autoHeight=false;
this.bgOpacity=0.8;
this.bgColor="white";
this._showing=false;
this.onShow=function(){
};
this.onHide=function(){
};
this.onBeforeShow=function(){
};
this.onBeforeHide=function(){
};
this.fillInTemplate=function(_9a6,_9a7){
this.bindArgEvents(_9a6);
dojo.event.topic.subscribe("turboresize",this,"doResize");
this.initNodes();
this.installChildren(_9a7,this.contentNode);
};
this.styleChanged=function(){
this.setStyledClass(this.domNode,"");
this.setStyledClass(this.contentNode,"-content");
this.domNode.className=this.domNode.className+(this.className?" "+this.className:"");
};
this.initNodes=function(){
if(!this.bgName){
this.bgName=this.widgetId+"_bg";
}
this.domNode.isModal=true;
this._hide();
this.styleChanged();
};
this.setHeightWidth=function(){
var _9a8=dojo.style.getOuterHeight(this.domNode);
var _9a9=dojo.style.getOuterWidth(this.domNode);
if(!_9a8||!_9a9){
return false;
}
if(this.modalHeight<=0){
this.modalHeight=(_9a8?_9a8:this.defaultHeight);
}
if(this.modalWidth<=0){
this.modalWidth=(_9a9?_9a9:this.defaultWidth);
}
return true;
};
this.getBgNode=function(){
props={backgroundColor:this.bgColor,opacity:this.bgOpacity,zIndex:parseInt(dojo.html.getStyle(this.domNode,"z-index"))-1};
var node=turbo.scrim.get(this.domNode.parentNode,this.bgName,props);
node.isModalBg=true;
return node;
};
this.detachNode=function(_9ab){
dojo.dom.removeNode(_9ab);
};
this.attachNode=function(_9ac){
var p=this.getParentNode();
try{
p.appendChild(_9ac);
}
catch(e){
turbo.debug("failed to append node to");
turbo.debugObject(p);
}
};
this.setZIndexes=function(){
var _9ae=this.getTopModal();
if(_9ae&&_9ae.parentModal==this.parentModal){
this.domNode.style.zIndex=parseInt(dojo.html.getStyle(_9ae.domNode,"z-index"))+2;
}
this.setBgZ();
};
this.setBgZ=function(){
this.bgNode.style.zIndex=parseInt(dojo.html.getStyle(this.domNode,"z-index"))-1;
};
this.focusNode=function(){
if(!this.allowFocus){
return;
}
var f=(this.modalFocus?turbo.$(this.modalFocus):null);
if(f){
if((f.style.display!="none"&&f.style.visibility!="hidden")){
turbo.defer(function(){
f.focus();
},10);
}
}else{
turbo.defer(turbo.bindArgs(this,"focusFirstLast","first",null),10);
}
};
this.getParentNode=function(){
var t=this.getTopModal();
var _9b1=(t&&t.domNode?t.domNode:document.body);
return _9b1;
};
this.setTopModal=function(){
if(this.getTopModal()!=this){
turbo.modals.push(this);
}
};
this.getTopModal=function(){
if(turbo.modals.length){
return turbo.modals[turbo.modals.length-1];
}else{
return false;
}
};
this.removeModal=function(){
for(var i=0,l=turbo.modals.length;i<l;i++){
if(turbo.modals[i]==this){
turbo.modals.splice(i,1);
return;
}
}
};
this.getStackIndex=function(){
for(i=turbo.modals.length-1;i>=0;i--){
if(this==turbo.modals[i]){
return i;
}
}
return -1;
};
this.show=function(){
if(this.onBeforeShow){
this.onBeforeShow();
}
this.initShow(turbo.bind(this,this.doOnShow));
};
this.doOnShow=function(){
this.focusNode();
this.onShow();
};
this.initShow=function(_9b3){
this.attachNode(this.domNode);
this.bgNode=this.getBgNode();
turbo.show(this.bgNode);
turbo.show(this.domNode);
this.attemptShow(_9b3);
};
this.attemptShow=function(_9b4){
if(!this.setHeightWidth()){
turbo.defer(turbo.bindArgs(this,this.attemptShow,_9b4),10);
return;
}
this._showing=true;
this.setTopModal();
turbo.defer(this,this.finishShow,10);
this.doResize(_9b4);
};
this.finishShow=function(){
this.setZIndexes();
};
this.hide=function(){
if(this!=this.getTopModal()){
this.hideModals(turbo.modals[this.getStackIndex()]);
}else{
this.doHide();
}
};
this.doHide=function(){
if(this.onBeforeHide){
this.onBeforeHide();
}
this._hide();
this.removeModal();
if(this.onHide){
turbo.defer(this,"onHide",10);
}
};
this._hide=function(){
this.hideDomNode();
this.hideBgNode();
this._showing=false;
};
this.hideModals=function(_9b5){
if(!_9b5||!_9b5.getStackIndex){
var l=0;
}else{
var l=_9b5.getStackIndex();
}
l=(l>-1?l:0);
for(i=turbo.modals.length-1;i>=l;i--){
turbo.modals[i].doHide();
}
};
this.hideAll=function(){
this.hideModals();
};
this.hideDomNode=function(){
turbo.hide(this.domNode);
this.detachNode(this.domNode);
};
this.hideBgNode=function(){
if(!this.bgNode){
return;
}
turbo.hide(this.bgNode);
turbo.scrim.release(this.bgNode);
};
this.showHide=function(){
if(this._showing){
this.hide();
}else{
this.show();
}
};
this.hasContent=function(){
return Boolean(this.contentNode.innerHTML);
};
this.getAutoHeight=function(){
turbo.setOuterSize(this.domNode,this.modalWidth,this.modalHeight);
var _9b7=0;
for(var i=0,l=this.domNode.childNodes.length;i<l;i++){
var n=this.domNode.childNodes[i];
if(n.style&&n.style.display==""&&n.style.visibility!="hidden"&&!(n.isModal||n.isModalBg)){
_9b7+=turbo.getOuterSize(n).h;
}
}
var _9ba=dojo.style.getPixelValue(this.domNode,"padding-top",true)+dojo.style.getPixelValue(this.domNode,"padding-bottom",true);
var _9bb=dojo.style.getBorderHeight(this.domNode);
return _9b7+_9ba+_9bb;
};
this.resizeModal=function(){
var siz=turbo.getInnerSize(this.domNode.parentNode);
var _9bd=this.hasContent();
var _9be=10000;
var w=(_9bd?this.modalWidth:0);
var h=(_9bd?this.modalHeight:0);
if(this.autoHeight){
h=this.getAutoHeight(w);
}
var l=(_9bd?Math.round((siz.w-w)/2):siz.w+_9be);
var t=(_9bd?Math.round((siz.h-h)/2):siz.h+_9be);
turbo.setBounds(this.domNode,l,t,w,h);
};
this.doResize=function(_9c3){
if(!this._showing){
return;
}
turbo.scrim.size(this.bgNode);
this.resizeModal();
turbo.aligner.alignFrom(this.domNode);
this.alignModal(_9c3);
};
this.alignModal=function(_9c4){
turbo.defer(this,"_alignModal",_9c4,10);
};
this._alignModal=function(_9c5){
turbo.aligner.alignFrom(this.domNode);
if(_9c5){
turbo.defer(_9c5,10);
}
};
this.interceptTab=function(e){
if(!this.allowFocus){
return;
}
if(this.skipIntercept){
this.skipIntercept=false;
return;
}
if(e.target!=this.contentNode&&e.target!=this.tabOut){
return;
}
var f=(e.target==this.tabOut?"first":"last");
this.focusFirstLast(f);
};
this.focusFirstLast=function(_9c8,_9c9){
if(!this.allowFocus){
return;
}
var _9ca=(_9c8=="first");
var n=(_9ca?this.getNextElement(this.contentNode,_9c9):this.getPrevElement(this.contentNode,_9c9));
if(!n){
return;
}
this.focusOk=false;
var self=this;
dojo.event.kwConnect({srcObj:n,srcFunc:"onfocus",targetObj:self,targetFunc:"focusCheck",once:true});
try{
if((n==this.contentNode&&this.hasContent())||n!=this.contentNode){
n.focus();
}
}
catch(e){
}
turbo.defer(turbo.bindArgs(this,this.processFocusCheck,_9c8,n),0);
};
this.focusCheck=function(){
this.focusOk=true;
};
this.processFocusCheck=function(_9cd,_9ce){
var self=this;
var dc={srcObj:_9ce,srcFunc:"onfocus",targetObj:self,targetFunc:"focusCheck",once:true};
if(!this.focusOk){
this.focusFirstLast(_9cd,_9ce);
}
};
this.elementOk=function(_9d1){
return (_9d1&&turbo.isShowing(_9d1)&&!_9d1.isModal);
};
this.getNextElement=function(_9d2,_9d3){
if(!_9d3){
var c=dojo.dom.getFirstChildElement(_9d2);
return (c?c:false);
}
var c=dojo.dom.getFirstChildElement(_9d3);
var n=(c?c:dojo.dom.nextElement(_9d3));
if(this.elementOk(n)){
return n;
}
var n=null;
while(_9d3.parentNode&&_9d3.parentNode!=_9d2){
_9d3=_9d3.parentNode;
var n=dojo.dom.nextElement(_9d3);
if(this.elementOk(n)){
break;
}
}
return (n?n:false);
};
this.getPrevElement=function(_9d6,_9d7){
if(!_9d7){
var c=dojo.dom.getLastChildElement(_9d6);
return (c?c:false);
}
var c=dojo.dom.getLastChildElement(_9d7);
var n=(c?c:dojo.dom.prevElement(_9d7));
if(this.elementOk(n)){
return n;
}
var n=null;
while(_9d7.parentNode&&_9d7.parentNode!=_9d6){
_9d7=_9d7.parentNode;
var n=dojo.dom.prevElement(_9d7);
if(this.elementOk(n)){
break;
}
}
return (n?n:false);
};
};
dojo.inherits(dojo.widget.HtmlTurboModal,dojo.widget.HtmlWidget);
dojo.widget.tags.addParseTreeHandler("dojo:TurboModal");
dojo.provide("turbo.widgets.TurboTags");
dojo.provide("turbo.widgets.HtmlTurboTags");
dojo.require("turbo.widgets.TurboWidget");
dojo.widget.HtmlTurboTags=function(){
this.widgetType="TurboTags";
dojo.widget.HtmlTurboWidget.call(this);
this.templateString="<div dojoAttachPoint=\"containerNode\"></div>";
this.containerNode=null;
this.tagNode=null;
this.classTag="turbo_tags";
this.maxFontSize=20;
this.minFontSize=10;
this.maxTags=-1;
this.className="";
this.highlightClass="tagHighlight";
this.tags=[];
this.mostItems=0;
this.leastItems=0;
this.fillInTemplate=function(_9da,_9db){
this.setStyle(this.style);
dojo.dom.moveChildren(this.getWidgetFragment(_9db),this.containerNode);
var frag=new dojo.xml.Parse().parseElement(this.containerNode);
dojo.widget.getParser().createComponents(frag);
this.tagNode=document.createElement("div");
this.containerNode.appendChild(this.tagNode);
this.build();
};
this.build=function(_9dd){
this.setTags(_9dd);
this.tagNode.innerHTML="";
this.shuffleTags();
this.buildTagsNode(this.tags,this.tagNode);
};
this.buildTagsNode=function(_9de,_9df,_9e0){
for(var i=0;i<_9de.length;i++){
_9df.appendChild(this.buildTag(_9de[i],_9e0));
if(i<_9de.length-1){
var sep=_9e0==undefined?document.createTextNode("  "):document.createTextNode(", ");
_9df.appendChild(sep);
}
}
};
this.buildTag=function(_9e3,_9e4){
var node=document.createElement("span");
var self=this;
node.onmouseover=function(){
this.className=self.highlightClass;
};
node.onmouseout=function(){
this.className="";
};
node.onclick=function(){
_9e3.action(_9e3.name);
};
if(_9e4==undefined){
if(_9e3.amount==undefined){
_9e3.amount=0;
}
var _9e7=Number(_9e3.amount);
var _9e8=Math.max(0,(_9e7-this.leastItems)/(this.mostItems-this.leastItems));
var _9e9=Math.max(this.minFontSize,Math.round(_9e8*this.maxFontSize));
node.style.fontSize=_9e9+"px";
}
node.style.padding="0px 2px 0px 2px";
node.style.cursor="pointer";
node.innerHTML=_9e3.name;
return node;
};
this.setTags=function(_9ea){
if(_9ea!=undefined){
this.tags=_9ea;
}
this.tags.length=this.maxTags>0?Math.min(this.maxTags,this.tags.length):this.tags.length;
this.setMostItems();
this.setLeastItems();
};
this.setMostItems=function(){
this.mostItems=0;
for(var i in this.tags){
if(Number(this.tags[i].amount)>Number(this.mostItems)){
this.mostItems=this.tags[i].amount;
}
}
};
this.setLeastItems=function(){
this.leastItems=null;
for(var i in this.tags){
if(this.tags[i].amount<this.leastItems||this.leastItems==null){
this.leastItems=this.tags[i].amount;
}
}
};
this.shuffleTags=function(){
for(var i in this.tags){
var a=Math.round(Math.random()*(this.tags.length-1));
var b=Math.round(Math.random()*(this.tags.length-1));
var _9f0=this.tags[a];
this.tags[a]=this.tags[b];
this.tags[b]=_9f0;
}
};
};
dojo.inherits(dojo.widget.HtmlTurboTags,dojo.widget.HtmlWidget);
dojo.widget.tags.addParseTreeHandler("dojo:turbotags");
dojo.provide("turbo.widgets.TurboGridClassic");
dojo.provide("turbo.widgets.HtmlTurboGridClassic");
dojo.require("turbo.widgets.TurboWidget");
dojo.widget.HtmlTurboGridClassic=function(){
this.widgetType="TurboGridClassic";
dojo.widget.HtmlTurboWidget.call(this);
this.autobuild=true;
this.autosize=true;
this.autosizing=false;
this.controller={};
this.classTag="turbo-grid-classic";
this.cols=0;
this.colWidth=96;
this.colWidths=[];
this.fixedColWidth=40;
this.multiSelect=true;
this.rows=0;
this.scrollLeft=0;
this.selectedRow=-1;
this.selectCount=0;
this.sortInfo={column:-1,desc:false};
this.selected=[];
this.rowMarkerClass=[];
this.readyImage="";
this.busyImage="";
this.templatePath=null;
this.templateString="<table dojoAttachPoint=\"GrdTbl\" cellspacing=\"0\" cellpadding=\"0\"><tr><td><div dojoAttachPoint=\"Corner\" class=\"turbo-grid-classic-corner\">&#160;</div><div dojoAttachPoint=\"ColDiv\" class=\"turbo-grid-classic-col\"></div></td><td><div dojoAttachPoint=\"HdrDiv\" class=\"turbo-grid-classic-hdr\"></div><div dojoAttachPoint=\"DtaDiv\" tabIndex=\"\" hidefocus=\"hidefocus\" class=\"turbo-grid-classic-dta\"></div></td></tr><tr><td dojoAttachPoint=\"Status\" colspan=\"2\" class=\"turbo-grid-classic-status\">Empty</td></tr></table>";
this.Corner=null;
this.ColDiv=null;
this.HdrDiv=null;
this.DtaDiv=null;
this.Status=null;
this.GrdTbl=null;
this.DtaTbl=null;
this.HdrTbl=null;
this.ColTbl=null;
var _9f1=false;
var _9f2=null;
this.getCell=function(_9f3,_9f4){
return (this.controller.getCell?this.controller.getCell(this,_9f3,_9f4):_9f3+", "+_9f4);
};
this.getHeaderAlign=function(_9f5){
return (this.controller.getHeaderAlign?this.controller.getHeaderAlign(this,_9f5):"left");
};
this.getColumnTitle=function(_9f6){
return (this.controller.getColumnTitle?this.controller.getColumnTitle(this,_9f6):undefined);
};
this.getColumnWidth=function(_9f7){
var w=(this.controller.getColumnWidth?this.controller.getColumnWidth(this,_9f7):-1);
return (w>=0?w:this.colWidth);
};
this.getSortInfo=function(){
this.sortInfo=(this.controller.getSortInfo?this.controller.getSortInfo(this):this.sortInfo);
return this.sortInfo;
};
this.onInit=function(){
};
this.onSelectionChange=function(){
};
this.onSelectRow=function(_9f9){
if(this.controller.onSelectRow){
this.controller.onSelectRow(this,_9f9);
}
};
this.onUnselectRow=function(_9fa){
if(this.controller.onUnselectRow){
this.controller.onUnselectRow(this,_9fa);
}
};
this.onUpdateRow=function(_9fb){
if(this.controller.onUpdateRow){
this.controller.onUpdateRow(this,_9fb);
}
};
this.onEditDone=function(_9fc){
if(this.controller.onEditDone){
this.controller.onEditDone(this);
}
};
this.onEditRowStart=function(_9fd){
if(this.controller.onEditRowStart){
this.controller.onEditRowStart(this,_9fd);
}
};
this.onEditRowDone=function(){
if(this.controller.onEditRowDone){
this.controller.onEditRowDone(this);
}
};
this.onKeyDown=function(_9fe){
if(this.controller.onKeyDown){
this.controller.onKeyDown(this,_9fe);
}
};
this.onDataClick=function(_9ff,_a00){
if(this.controller.onDataClick){
this.controller.onDataClick(this,_9ff,_a00);
}
};
this.onDataDblClick=function(_a01,_a02){
if(this.controller.onDataDblClick){
this.controller.onDataDblClick(this,_a01,_a02);
}
};
this.onHeaderClick=null;
this.fillInTemplate=function(_a03){
this.bindArgEvents(_a03);
this.bindArgEvent("onHeaderClick",_a03);
this.setTheme(this.theme);
this.DtaDiv.onscroll=turbo.bind(this,this.doScroll);
this.onInit();
if(this.rows&&this.cols&&this.autobuild){
this.build();
}else{
this.deferResize();
}
dojo.event.connect(this.DtaDiv,"onkeydown",this,"dataKeyDown");
dojo.event.topic.subscribe("turboresize",this,"turboResize");
};
this.turboDestroy=function(){
dojo.event.topic.unsubscribe("turboresize",this,"turboResize");
};
this.turboResize=function(){
if(turbo.showing(this.domNode.parentNode)){
this.resize();
}
};
this.enableAutoResize=function(){
if(!this.autosizing){
dojo.event.connect(window,"onresize",this,"doResize");
}
this.autosizing=true;
};
this.setElementClass=function(_a04,_a05){
_a05=(_a05?this.classTag+"-"+_a05:"");
if(_a04.className!=_a05){
_a04.className=_a05;
}
};
this.setStyledClass=function(_a06,_a07){
if(!_a07){
_a07="";
}
_a06.className=this.classTag+_a07+(this.style?" "+this.classTag+"-"+this.style+_a07:"");
};
this.styleChanged=function(){
this.setStyledClass(this.GrdTbl);
};
this.setStatus=function(_a08,_a09){
var h=(_a09?"<img src=\"images/"+_a09+"\" align=\"absmiddle\"/>":"");
this.Status.innerHTML=h+_a08;
};
this.setReadyStatus=function(){
document.body.style.cursor="default";
this.setStatus("Ready.",this.readyImage);
};
this.setBusyStatus=function(){
this.setStatus("Busy.",this.busyImage);
document.body.style.cursor="wait";
};
this.setSize=function(_a0b,_a0c){
this.cols=_a0b;
this.rows=_a0c;
};
this.deferResize=function(inMs){
turbo.defer(turbo.bind(this,this.resize),(inMs?inMs:200));
};
this.clearGrid=function(){
this.scrollLeft=0;
this.selected=[];
this.selectCount=0;
this.selectedRow=-1;
this.rowMarkerClass=[];
this.sortInfo={};
this.onSelectionChange();
};
this.teardownRows=function(){
this.clearGrid();
dojo.event.browser.clean(this.DtaDiv);
this.DtaDiv.innerHTML="";
dojo.event.browser.clean(this.ColDiv);
this.ColDiv.innerHTML="";
this.DtaTbl=null;
this.ColTbl=null;
};
this.teardown=function(){
this.teardownRows();
dojo.event.browser.clean(this.HdrDiv);
this.HdrDiv.innerHTML="";
this.HdrTbl=null;
};
this.build=function(){
this.cacheColWidths();
this.buildTable();
this.buildFixedColumn();
this.buildHeader();
this.setScrollLeft();
this.setReadyStatus();
this.deferResize();
};
this.refresh=function(){
if(!dojo.render.html.ie){
this.build();
return;
}
this.cacheColWidths();
this.refreshHeader();
this.refreshData();
this.updateRowSizes();
};
this.getCellPos=function(_a0e){
return {col:turbo.getCellIndex(_a0e),row:turbo.getRowIndex(_a0e.parentNode)};
};
this.sameCell=function(inA,inB){
return inA&&inB&&(inA.col==inB.col)&&(inA.row==inB.row);
};
this.goodCell=function(_a11){
return (_a11.col>=0&&_a11.col<this.cols&&_a11.row>=0&&_a11.row<this.rows);
};
this.getDomCell=function(_a12){
return turbo.getTableRow(this.DtaTbl,_a12.row).cells[_a12.col];
};
this.refreshCell=function(_a13){
var _a14=this.getDomCell(_a13);
dojo.event.browser.clean(_a14);
_a14.innerHTML=this.getCell(_a13.col,_a13.row);
};
this.setSortInfo=function(_a15,_a16){
if(this.sortInfo.column==_a15&&_a16===undefined){
_a16=!this.sortInfo.desc;
}
this.sortInfo={column:_a15,desc:_a16};
};
this.setSortColumn=this.setSortInfo;
this.cacheColWidths=function(){
for(var i=0;i<this.cols;i++){
this.colWidths[i]=this.getColumnWidth(i);
}
};
this.calcColsWidth=function(){
var sum=0;
for(var i=0;i<this.cols;i++){
sum+=this.colWidths[i];
}
return sum;
};
this.calcTableWidth=function(){
return this.calcColsWidth()+this.cols*(1+2+6)+1;
};
this.getRowClass=function(_a1a){
var _a1b=(this.controller.getRowClass?this.controller.getRowClass(_a1a):"");
if(_a1b){
return _a1b;
}
if(this.selected[_a1a]){
_a1b=this.classTag+"-selected";
}
return this.classTag+"-row-"+(_a1a&1)+(_a1b?" "+_a1b:"");
};
this.getRowHeight=function(_a1c){
var row=turbo.getTableRow(this.DtaTbl,_a1c);
return (row?row.offsetHeight-(dojo.render.html.ie?5:0):0);
};
this.getTable=function(){
return "<table width=\""+this.calcTableWidth()+"\" cellspacing=\"0\">";
};
this.createTable=function(){
var _a1e=document.createElement("table");
_a1e.cellPadding=0;
_a1e.cellSpacing=0;
_a1e.width=this.calcTableWidth();
return _a1e;
};
this.getHeaderCell=function(_a1f){
var h=this.getColumnTitle(_a1f);
if(h===undefined){
var a=Math.floor(_a1f/26);
var b=_a1f%26;
var _a23=function(c){
return String.fromCharCode("A".charCodeAt(0)+c);
};
h=(a>0?_a23(a-1):"")+_a23(b);
}
return h;
};
this.getHeaderSortClass=function(_a25){
return " class=\""+this.classTag+"-sort-"+(this.sortInfo.column!=_a25?"none":(this.sortInfo.desc?"down":"up"))+"\"";
};
this.getHeaderCellHtml=function(inW,_a27){
return "<div style=\"width:"+inW+"px;\""+this.getHeaderSortClass(_a27)+">"+"<div style=\"text-align:"+this.getHeaderAlign(_a27)+";\">"+this.getHeaderCell(_a27)+"</div></div>";
};
this.buildHeader=function(){
this.getSortInfo();
var c="",w;
var sep="<td class=\"turbo-separator\"></td>";
for(var i=0;i<this.cols;i++){
w=this.colWidths[i];
c+="<th width=\""+w+"\">"+this.getHeaderCellHtml(w,i)+"</th>";
c+=sep;
}
c+="<th></th>";
var h="<tr>"+c+"</tr>";
c="";
var bv="<th class=\""+this.classTag+"-bevel\" width=\"";
for(var i=0;i<this.cols;i++){
c+=bv+this.colWidths[i]+"\"></th>"+"<td class=\"turbo-separator\"></td>";
}
c+="<th></th>";
h+="<tr>"+c+"</tr>";
h=this.getTable()+h+"</table>";
this.HdrDiv.innerHTML=h;
this.HdrTbl=this.HdrDiv.firstChild;
this.HdrTbl.width="4096";
this.HdrHeight=this.HdrDiv.clientHeight;
dojo.event.connect(this.HdrTbl,"onmousedown",this,"headerDown");
dojo.event.connect(this.HdrTbl,"onmousemove",this,"headerMove");
dojo.event.connect(this.HdrTbl,"onmouseup",this,"headerUp");
dojo.event.connect(this.HdrTbl,"onmouseover",this,"headerOver");
dojo.event.connect(this.HdrTbl,"onmouseout",this,"headerOut");
dojo.event.connect(this.HdrTbl,"onclick",this,"headerClick");
};
this.refreshHeader=function(){
this.getSortInfo();
var row=turbo.getTableRow(this.HdrTbl,0);
for(var i=0;i<this.cols;i++){
var cell=row.cells[i*2];
var w=this.getColumnWidth(i);
cell.width=w;
cell.innerHTML=this.getHeaderCellHtml(w,i);
}
};
this.getBevel=function(_a31){
var _a32=_a31.parentNode.parentNode;
if(!_a32.rows){
_a32=_a32.parentNode;
}
var row=turbo.getTableRow(_a32,1);
return row.cells[turbo.getCellIndex(_a31)];
};
this.findEventCell=function(_a34,_a35){
while(turbo.getTagName(_a34)!="td"&&_a34.parentNode&&_a34.parentNode!=this.GrdTbl){
_a34=_a34.parentNode;
}
return (_a34&&dojo.dom.isDescendantOf(_a34,_a35)?_a34:null);
};
this.findEventHeaderCell=function(_a36,_a37){
while(turbo.getTagName(_a36)!="th"&&_a36.parentNode&&_a36.parentNode!=this.GrdTbl){
_a36=_a36.parentNode;
}
return (_a36&&dojo.dom.isDescendantOf(_a36,_a37)?_a36:null);
};
this.getHeaderCellIndex=function(_a38){
return turbo.getCellIndex(_a38)>>1;
};
this.isValidHeaderCell=function(_a39){
return (this.getHeaderCellIndex(_a39)<this.cols);
};
this.headerDown=function(_a3a){
var _a3b=this.findEventCell(_a3a.target,this.HdrTbl);
if(_a3b&&this.isValidHeaderCell(_a3b)){
_9f1=true;
_9f2=_a3b;
turbo.capture(_9f2);
_a3a.preventDefault();
_a3a.stopPropagation();
}
};
this.headerMove=function(_a3c){
if(_9f1){
window.status=_a3c.clientX+", "+_a3c.clientY;
_a3c.preventDefault();
_a3c.stopPropagation();
}
};
this.headerUp=function(_a3d){
if(_9f1){
_9f1=false;
turbo.release(_9f2);
}
};
this.headerOver=function(_a3e){
var _a3f=this.findEventHeaderCell(_a3e.target,this.HdrTbl);
if(_a3f&&this.isValidHeaderCell(_a3f)){
this.setElementClass(_a3f,"over");
this.setElementClass(this.getBevel(_a3f),"bevel-over");
}
};
this.headerOut=function(_a40){
var _a41=this.findEventHeaderCell(_a40.target,this.HdrTbl);
if(_a41&&this.isValidHeaderCell(_a41)){
this.setElementClass(_a41,"");
this.setElementClass(this.getBevel(_a41),"bevel");
}
};
this.delayedHeaderClick=function(_a42){
var idx=turbo.getCellIndex(_a42)>>1;
if(this.onHeaderClick){
this.onHeaderClick(idx);
}else{
if(this.controller.onHeaderClick){
this.controller.onHeaderClick(this,idx);
}
}
};
this.headerClick=function(_a44){
if(!this.onHeaderClick&&!this.controller.onHeaderClick){
return;
}
var _a45=this.findEventHeaderCell(_a44.target,this.HdrTbl);
if(_a45&&this.isValidHeaderCell(_a45)){
this.setElementClass(_a45,"down");
this.setElementClass(this.getBevel(_a45),"bevel-over");
this.getScrollLeft();
turbo.defer(turbo.bindArgs(this,this.delayedHeaderClick,_a45),1);
}
};
this.getFixedColClass=function(_a46){
return (this.selected[_a46]?this.classTag+"-fixed-select":"");
};
this.formatFixedCol=function(_a47){
return (this.controller.formatFixedCol?this.controller.formatFixedCol(this,_a47):Number(_a47)+1);
};
this.buildFixedColumn=function(){
this.Corner.style.width=this.fixedColWidth+"px";
this.ColDiv.style.width=this.fixedColWidth+"px";
var tbl=new Array(this.rows+2);
tbl[0]="<table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\">";
for(var c,j=0,k=1;j<this.rows;j++,k++){
c=this.getFixedColClass(j);
c=(c?" class=\""+c+"\"":"");
tbl[k]="<tr height=\""+this.getRowHeight(j)+"\"><td"+c+">"+this.formatFixedCol(j)+"</td></tr>";
}
tbl[k]="<tr><td height=\"64\" style=\"border: none; background-image: none;\"></td></tr></table>";
this.ColDiv.innerHTML=tbl.join("");
this.ColTbl=this.ColDiv.firstChild;
dojo.event.connect(this.ColTbl,"onclick",this,"fixedTableClick");
};
this.updateFixedColumnRow=function(_a4a){
var row=turbo.getTableRow(this.ColTbl,_a4a);
var cell=row.cells[0];
cell.className=this.getFixedColClass(_a4a);
cell.innerHTML=this.formatFixedCol(_a4a);
};
this.fixedTableClick=function(_a4d){
};
this.buildCells=function(){
var _a4e=new Array(this.cols);
for(var i=0;i<this.cols;i++){
var w=this.getColumnWidth(i);
_a4e[i]="<td width=\""+w+"\"><div style=\"width:"+w+"px;\">";
}
return _a4e;
};
this.buildTable=function(){
var _a51=this.buildCells();
var tbl=new Array(this.rows);
for(var j=0;j<this.rows;j++){
var row=new Array(this.cols);
for(var i=0;i<this.cols;i++){
row[i]=_a51[i]+this.getCell(i,j)+"</div></td>";
}
tbl[j]="<tr class=\""+this.getRowClass(j)+"\">"+row.join("")+"<td>&#160;</td></tr>";
}
var h=tbl.join("");
this.DtaDiv.innerHTML=this.getTable()+h+"</table>";
this.DtaTbl=this.DtaDiv.firstChild;
dojo.event.connect(this.DtaTbl,"onmouseover",this,"tableOver");
dojo.event.connect(this.DtaTbl,"onmouseout",this,"tableOut");
dojo.event.connect(this.DtaTbl,"onclick",this,"tableClick");
dojo.event.connect(this.DtaTbl,"ondblclick",this,"tableDblClick");
};
this.buildCols=function(_a57){
var cell;
var j=turbo.getRowIndex(_a57);
for(var i=0;i<this.cols;i++){
var w=this.getColumnWidth(i);
cell=_a57.insertCell(i);
cell.width=w;
var h="<div style=\"width:"+w+"px;\">"+this.getCell(i,j)+"</div>";
cell.innerHTML=h;
}
cell=_a57.insertCell(this.cols);
cell.innerHTML="&#160;";
};
this.buildRow=function(_a5d){
_a5d.onmouseover=turbo.bindArgs(this,this.dataOver,_a5d);
_a5d.onmouseout=turbo.bindArgs(this,this.dataOut,_a5d);
_a5d.className=this.getRowClass(turbo.getRowIndex(_a5d));
this.buildCols(_a5d);
};
this.refreshData=function(){
for(var j=0;j<this.rows;j++){
var row=turbo.getTableRow(this.DtaTbl,j);
for(var i=0;i<this.cols;i++){
row.style.height="0px";
row.cells[i].innerHTML="<div style=\"width:"+this.colWidths[i]+"px;\">"+this.getCell(i,j)+"</div>";
}
}
};
this.dataOver=function(_a61){
if(!this.selected[turbo.getRowIndex(_a61)]){
this.setElementClass(_a61,"row-over");
}
};
this.dataOut=function(_a62){
_a62.className=this.getRowClass(turbo.getRowIndex(_a62));
};
this.dataClick=function(_a63,_a64){
this.onDataClick(_a63,_a64);
};
this.dataDblClick=function(_a65,_a66){
this.onDataDblClick(_a65,_a66);
};
this.dataKeyDown=function(_a67){
this.onKeyDown(_a67);
};
this.tableOver=function(_a68){
var _a69=this.findEventCell(_a68.target,this.DtaTbl);
if(_a69){
this.dataOver(_a69.parentNode);
}
};
this.tableOut=function(_a6a){
var _a6b=this.findEventCell(_a6a.target,this.DtaTbl);
if(_a6b){
this.dataOut(_a6b.parentNode);
}
};
this.tableClick=function(_a6c){
var _a6d=this.findEventCell(_a6c.target,this.DtaTbl);
if(_a6d){
this.dataClick(_a6d,_a6c);
}
};
this.tableDblClick=function(_a6e){
var _a6f=this.findEventCell(_a6e.target,this.DtaTbl);
if(_a6f){
this.dataDblClick(_a6f,_a6e);
}
};
this.getFirstSelectedRow=function(){
for(var i=0;i<this.rows;i++){
if(this.selected[i]){
return Number(i);
}
}
return -1;
};
this.getNextSelectedRow=function(_a71){
for(var i=_a71+1;i<this.rows;i++){
if(this.selected[i]){
return i;
}
}
return -1;
};
this.hasSelection=function(){
return (this.getFirstSelectedRow()>-1);
};
this.getSelectedRows=function(){
var _a73=[];
for(var i=0;i<this.rows;i++){
if(this.selected[i]){
_a73.push(i);
}
}
return _a73;
};
this.clearSelection=function(){
this.selected=[];
this.selectedRow=-1;
this.selectCount=0;
this.updateRowClasses();
this.buildFixedColumn();
this.onSelectionChange();
};
this.setRowSelected=function(_a75,_a76){
if(_a75<0){
return;
}
if(_a76===undefined){
_a76=true;
}
if(this.selected[_a75]!=_a76){
this.selected[_a75]=_a76;
this.selectedRow=(_a76?_a75:-1);
this.selectCount+=(_a76?1:-1);
if(_a76){
this.onSelectRow(_a75);
}else{
this.onUnselectRow(_a75);
}
}
this.selectedRow=(_a76?_a75:-1);
this.updateFixedColumnRow(_a75);
turbo.getTableRow(this.DtaTbl,_a75).className=this.getRowClass(_a75);
};
this.selectRow=function(_a77){
if(!this.selected[_a77]){
this.setRowSelected(_a77,true);
this.updateRowSizes();
}
};
this.deselectRow=function(_a78){
if(this.selected[_a78]){
this.setRowSelected(_a78,false);
this.updateRowSizes();
}
};
this.toggleSelectRow=function(_a79){
if(this.selected[_a79]){
this.setRowSelected(_a79,false);
}else{
this.setRowSelected(_a79,true);
}
};
this.unselectRows=function(_a7a){
for(var i in this.selected){
if(i!=_a7a&&this.selected[i]){
this.setRowSelected(i,false);
}
}
};
this.clickSelect=function(_a7c,_a7d,_a7e){
if(!this.multiSelect||(!_a7d&&!_a7e)){
this.unselectRows(_a7c);
}
if(!_a7e||!this.multiSelect){
if(_a7d){
this.toggleSelectRow(_a7c);
}else{
this.setRowSelected(_a7c,true);
}
this.updateRowClasses();
}else{
var r=(this.selectedRow<0?0:this.selectedRow);
var s=r;
var e=_a7c;
if(s>_a7c){
e=s;
s=_a7c;
}
for(var i=s;i<=e;i++){
this.setRowSelected(i,true);
}
this.updateRowClass(r);
}
window.setTimeout(turbo.bind(this,this.updateRowSizes),100);
this.onSelectionChange();
};
this.offsetMarkers=function(_a83,_a84){
var _a85=[];
for(var i in this.rowMarkerClass){
if(this.rowMarkerClass[i]){
if(i>=_a83){
_a85[Number(i)+_a84]=this.rowMarkerClass[i];
}else{
_a85[i]=this.rowMarkerClass[i];
}
}
}
this.rowMarkerClass=_a85;
};
this.setMarker=function(_a87,_a88){
this.rowMarkerClass[_a87]=_a88;
this.updateRowClass(_a87);
};
this.clearMarkers=function(){
this.rowMarkerClass=[];
};
this.addRow=function(_a89){
this.clearSelection();
this.buildRow(this.DtaTbl.insertRow(_a89));
this.offsetMarkers(_a89,1);
this.rows++;
this.buildFixedColumn();
this.updateRowSizes();
this.setRowSelected(_a89,true);
};
this.removeRow=function(_a8a){
this.rowMarkerClass[_a8a]=null;
this.offsetMarkers(_a8a,-1);
this.rows--;
this.DtaTbl.deleteRow(_a8a);
this.clearSelection();
};
this.updateRow=function(_a8b){
this.DtaTbl.deleteRow(_a8b);
this.buildRow(this.DtaTbl.insertRow(_a8b));
};
this.swapRows=function(_a8c,_a8d){
turbo.arraySwap(this.rowMarkerClass,_a8c,_a8d);
this.updateRow(_a8c);
this.updateRow(_a8d);
this.updateRowSizes();
};
this.replaceRow=function(_a8e){
this.updateRow(_a8e);
this.updateRowSizes();
};
this.updateRowSizes=function(){
if(!this.ColTbl){
return;
}
for(var j=0;j<this.rows;j++){
turbo.setStyleHeightPx(turbo.getTableRow(this.ColTbl,j),this.getRowHeight(j));
}
};
this.updateRowClass=function(_a90){
turbo.getTableRow(this.DtaTbl,_a90).className=this.getRowClass(_a90);
};
this.updateRowClasses=function(){
for(var j=0;j<this.rows;j++){
turbo.getTableRow(this.DtaTbl,j).className=this.getRowClass(j);
}
};
this.getScrollLeft=function(){
this.scrollLeft=this.DtaDiv.scrollLeft;
};
this.setScrollLeft=function(){
this.HdrDiv.scrollLeft=this.scrollLeft;
this.DtaDiv.scrollLeft=this.scrollLeft;
};
this.doScroll=function(){
this.HdrDiv.scrollLeft=this.DtaDiv.scrollLeft;
this.ColDiv.scrollTop=this.DtaDiv.scrollTop;
};
this.getContentSize=function(){
var siz=turbo.getContentSize(this.GrdTbl.parentNode);
siz.w-=dojo.style.getPaddingWidth(this.GrdTbl)+dojo.style.getBorderWidth(this.GrdTbl);
siz.h-=dojo.style.getPaddingWidth(this.GrdTbl)+dojo.style.getBorderHeight(this.GrdTbl);
siz.w=siz.w-this.fixedColWidth-1;
return siz;
};
this._resize=function(){
turbo.setStyleWidthPx(this.HdrDiv,1);
turbo.setStyleWidthPx(this.DtaDiv,1);
var siz=this.getContentSize();
turbo.setStyleWidthPx(this.HdrDiv,siz.w);
turbo.setStyleWidthPx(this.DtaDiv,siz.w);
this.DataWidth=this.calcTableWidth();
siz.w=(siz.w<this.DataWidth?this.DataWidth:siz.w-turbo.getScrollbarWidth());
var _a94=function(_a95,_a96){
if(_a95&&_a96>0){
_a95.width=_a96;
}
};
_a94(this.HdrTbl,siz.w+128+64);
_a94(this.DtaTbl,siz.w);
hh=this.HdrDiv.clientHeight;
turbo.setStyleHeightPx(this.Corner,hh-1);
hh=siz.h-hh-this.Status.clientHeight-1;
turbo.setStyleHeightPx(this.DtaDiv,hh);
if(this.fixedColWidth>0){
hh=siz.h-this.Corner.clientHeight-this.Status.clientHeight-1;
}
turbo.setStyleHeightPx(this.ColDiv,hh);
this.doScroll();
this.updateRowSizes();
};
this.earliestResize=0;
this.doResize=function(){
if(this.GrdTbl&&this.GrdTbl.parentNode&&this.earliestResize<turbo.time()){
this._resize();
this.earliestResize=turbo.time()+100;
}
};
this.resize=this.doResize;
};
dojo.inherits(dojo.widget.HtmlTurboGridClassic,dojo.widget.HtmlWidget);
dojo.widget.tags.addParseTreeHandler("dojo:TurboGridClassic");
dojo.provide("turbo.data.classic.fields");
turbo.data.index=function(){
this.defaultValue={};
this.values=[];
this.count=function(){
return this.values.length;
};
this.clear=function(){
this.values=[];
};
this.get=function(_a97){
var _a98=this.values[_a97];
if(!_a98){
_a98=turbo.swiss(this.defaultValue,{});
this.values[_a97]=_a98;
}
return _a98;
};
this._set=function(_a99,_a9a){
var v=this.get(_a99);
for(var i=1;i<arguments.length;i++){
turbo.swiss(arguments[i],v);
}
this.values[_a99]=v;
};
this.set=function(){
if(arguments.length<1){
return;
}
var a=arguments[0];
if(!dojo.lang.isArray(a)){
this._set.apply(this,arguments);
}else{
for(i=0,l=a.length;i<l;i++){
this._set(i,a[i]);
}
}
};
this.insert=function(_a9e,_a9f){
if(_a9e>=this.values.length){
this.values[_a9e]=_a9f;
}else{
this.values.splice(_a9e,0,_a9f);
}
};
this.remove=function(_aa0){
this.values.splice(_aa0,1);
};
this.swap=function(_aa1,_aa2){
turbo.arraySwap(this.values,_aa1,_aa2);
};
this.move=function(_aa3,_aa4){
turbo.arrayMove(this.values,_aa3,_aa4);
};
};
turbo.data.fields=function(_aa5){
turbo.data.index.call(this);
var _aa6=(_aa5?_aa5:Object);
this.defaultValue=new _aa6();
this.setDefault=function(_aa7){
if(typeof (_aa7)!="object"){
alert("tubo.data.fields.setDefaultField (stores.js): bad input field object. Are your field definitions included?");
}
turbo.swiss(_aa7,this.defaultValue);
};
};
turbo.data.comparator=function(_aa8){
return function(a,b){
return (a[_aa8]>b[_aa8]?1:(a[_aa8]==b[_aa8]?0:-1));
};
};
turbo.data.field=function(_aab){
this.name=_aab;
this.comparator=turbo.data.comparator;
this.getComparator=function(_aac,_aad){
var _aae=this.comparator(_aac);
if(!_aad){
return _aae;
}else{
return function(a,b){
return -_aae(a,b);
};
}
};
};
dojo.provide("turbo.data.classic.stores");
dojo.require("turbo.data.classic.fields");
turbo.data.table=function(_ab1){
this.fields=new turbo.data.fields(turbo.data.field);
this.fields.set(_ab1);
this.rowinfo=new turbo.data.index();
this.sortIndex=-1;
this.sortField="";
this.sortDesc=false;
this.autoSort=false;
this.getFieldNameArray=function(){
var f=this.fields.values;
var a=new Array(f.length);
for(var i=0,l=f.length;i<l;i++){
a[i]=f[i].name;
}
return a;
};
this.getFieldNameIndex=function(_ab5){
var f=this.fields.values;
for(var i=0,l=f.length;i<l;i++){
if(f[i].name==_ab5){
return i;
}
}
return false;
};
this.getColCount=function(){
return this.fields.count();
};
this.hasData=function(){
return (this.fields.count()>0);
};
this.deleteRows=function(_ab8,inOk,_aba){
inOk(_ab8,_ab8.length);
};
this._setSortField=function(_abb,_abc){
if(_abc){
this.sortDesc=_abc;
}else{
if(this.sortField==_abb){
this.sortDesc=!this.sortDesc;
}else{
this.sortDesc=false;
}
}
this.sortField=_abb;
};
this.setSortIndex=function(_abd,_abe){
if(_abd<0){
this.sortField="";
}else{
this._setSortField(this.fields.get(_abd).name,_abe);
}
this.sortIndex=_abd;
};
this.setSortField=function(_abf,_ac0){
if(_abf==""){
this.setSortIndex(-1);
}else{
this._setSortField(_abf,_ac0);
this.sortIndex=this.getFieldNameIndex(this.sortField);
}
};
this.hasEdits=function(){
var v=this.rowinfo.values;
for(var i in v){
if(!v.constructor.prototype[i]&&v[i].edit){
return true;
}
}
return false;
};
this.startEdit=function(_ac3){
this.cacheRow(_ac3);
this.rowinfo.set(_ac3,{edit:true});
};
this.cancelEdit=function(_ac4){
this.restoreRow(_ac4);
with(this.rowinfo.get(_ac4)){
delete edit;
}
};
this.applyEdit=function(_ac5,inOk,_ac7){
if(this.rowChanged(_ac5)||this.rowinfo.get(_ac5).error){
this._applyEdit(_ac5,inOk,_ac7);
}else{
this.cancelEdit(_ac5);
}
};
this._applyEdit=function(_ac8,inOk,_aca){
this.rowinfo.get(_ac8).inflight=true;
var self=this;
var _acc=function(){
with(self.rowinfo.get(_ac8)){
delete cache;
delete edit;
delete insert;
delete inflight;
delete error;
}
inOk.apply(this,arguments);
};
var _acd=function(_ace){
var i=self.rowinfo.get(_ac8);
delete i.inflight;
if(_ace){
i.error=_ace;
}
_aca.apply(this,arguments);
};
this.commitRow(_ac8,_acc,_acd);
};
this.commitRow=function(_ad0,inOk,_ad2){
inOk();
};
};
turbo.data.store=function(_ad3,_ad4){
turbo.data.table.call(this);
this.data=[];
this.hasData=function(){
return (this.data&&this.data.length>0);
};
this.setData=function(_ad5,_ad6){
this.data=(_ad5?_ad5:[]);
this.fields.set(_ad6);
};
this.sort=function(){
if(this.sortIndex>=0&&this.hasData()){
this.data.sort(this.fields.get(this.sortIndex).getComparator(this.sortIndex,this.sortDesc));
}
};
this.getColCount=function(){
var _ad7=this.fields.count();
var _ad8=(this.data&&this.data.length?this.data[0].length:0);
return Math.max(_ad7,_ad8);
};
this.getRowCount=function(){
return (this.data&&this.data.length?this.data.length:0);
};
this.getDatum=function(_ad9,_ada){
if(djConfig.isDebug&&(_ada<0||_ada>=this.data.length)){
turbo.debug("turbo.data.arrayStore.getDatum: bad row: "+_ada);
return null;
}
return this.data[_ada][_ad9];
};
this.setDatum=function(_adb,_adc,_add){
this.data[_adc][_adb]=_add;
};
this.getRow=function(_ade){
return this.data[_ade];
};
this.copyRow=function(_adf){
return this.data[_adf].slice(0);
};
this.compareRow=function(_ae0,_ae1){
var c=this.getColCount();
if(!_ae1||_ae1.length!=c){
return false;
}
var row=this.getRow(_ae0);
for(var i=0;i<c;i++){
if(_ae1[i]!==row[i]){
return false;
}
}
return true;
};
this.removeRow=function(_ae5){
this.data.splice(_ae5,1);
this.rowinfo.remove(_ae5);
};
this.replaceRow=function(_ae6,_ae7){
this.data[_ae6]=_ae7;
};
this.swapRows=function(_ae8,_ae9){
turbo.arraySwap(this.data,_ae8,_ae9);
this.rowinfo.swap(_ae8,_ae9);
};
this.getRowCache=function(_aea){
return this.rowinfo.get(_aea).cache;
};
this.getRowBacking=function(_aeb){
var c=this.getRowCache(_aeb);
return (c?c:this.getRow(_aeb));
};
this.cacheRow=function(_aed){
if(!this.getRowCache(_aed)){
this.rowinfo.set(_aed,{cache:this.copyRow(_aed)});
}
};
this.rowChanged=function(_aee){
var c=this.getRowCache(_aee);
return (!c?true:!this.compareRow(_aee,c));
};
this.restoreRow=function(_af0){
var c=this.getRowCache(_af0);
if(c){
this.replaceRow(_af0,c);
}
};
this.addRow=function(_af2,_af3){
var c=this.getColCount();
if(!_af3){
_af3=[];
}
for(var i=0;i<c;i++){
if(dojo.lang.isUndefined(_af3[i])){
_af3[i]=this.fields.get(i).defaultValue;
}
}
if(this.data.length>0){
this.data.splice(_af2,0,_af3);
}else{
this.data=[_af3];
}
this.rowinfo.insert(_af2,{edit:true,insert:true});
};
this.setData(_ad3,_ad4);
};
turbo.data.paged=function(_af6){
turbo.data.store.call(this,null,_af6);
this.totalRows=0;
this.rowsPerPage=50;
this.pageCount=0;
this.pages=[];
this.page=-1;
this.invalidPage=-1;
this.requestPage=function(_af7){
};
this.clear=function(){
this.setTotalRows(0);
this.page=-1;
this.pages=[];
this.setSortIndex(-1);
};
this.setTotalRows=function(_af8){
var _af9=this.pageCount;
var _afa=this.page;
this.totalRows=_af8;
this.pageCount=Math.ceil(this.totalRows/this.rowsPerPage);
if(this.page>=this.pageCount){
this.page=this.pageCount-1;
}
return (_af9!=this.pageCount||_afa!=this.page);
};
this.getPageLength=function(_afb){
var page=(_afb==this.page?this.data:this.pages[_afb]);
return (page?page.length:this.rowsPerPage);
};
this.fetchRowCount=function(){
return this.totalRows;
};
this.repaginate=function(){
var rows=this.fetchRowCount();
this.pages=[];
if(this.page>=0){
this.pages[this.page]=this.data;
}
return this.setTotalRows(rows);
};
this.getTopRow=function(_afe){
var page=(_afe===undefined?this.page:_afe);
return page*this.rowsPerPage;
};
this.getBottomRow=function(_b00){
var row=this.getTopRow(_b00)+this.getPageLength(_b00)-1;
return Math.min(row,this.totalRows-1);
};
this.fillPage=function(_b02,_b03){
this.pages[_b02]=_b03;
};
this.selectPage=function(_b04){
this.page=_b04;
if(!this.pages[_b04]){
this.requestPage(_b04);
}
this.rowinfo.clear();
if(this.pages[_b04]){
this.invalidPage=-1;
this.data=this.pages[_b04];
}else{
this.invalidPage=_b04;
this.data=[];
}
};
this.invalidatePage=function(){
this.pages[this.page]=null;
};
this.pageIsValid=function(_b05){
return (this.pages[_b05]?true:false);
};
this.reloadPage=function(){
this.pages[this.page]=null;
this.selectPage(this.page);
};
this.reloadPages=function(){
this.pages=[];
this.selectPage(this.page);
};
this.fillNextPage=function(){
for(var i=0;i<this.pageCount;i++){
if(!this.pages[i]){
break;
}
}
if(i==this.pageCount){
return false;
}
turbo.debug("turbo.data.pages: fillNextPage: "+i);
this.requestPageAsync(i);
return true;
};
this.sort=function(){
this.reloadPages();
};
};
dojo.provide("turbo.grid.classic.columns");
turbo.grid.format={};
turbo.grid.format.noformat=function(_b07,_b08){
return _b07;
};
turbo.grid.edit={};
turbo.grid.edit.noedit={edit:function(_b09,_b0a,_b0b){
return false;
},getValue:function(){
return null;
}};
turbo.grid.column=function(_b0c){
this.name=(_b0c?_b0c:"");
this.width=96;
this.readonly=false;
this.editor=null;
this.formatter=turbo.grid.format.text;
this.format=function(_b0d,_b0e){
if(!this.formatter){
dojo.debug("turbo.grid.column: illegal formatter for column ["+this.name+"]");
this.formatter=turbo.grid.format.text;
}
var _b0f=(this.readonly||_b0e||!this.editor);
return this.formatter.call(this,_b0d,_b0f);
};
this.getEditor=function(){
if(!this.editor||this.readonly){
return turbo.grid.edit.noedit;
}else{
this.editor.column=this;
return this.editor;
}
};
};
turbo.grid.format.text=function(_b10,_b11){
var s="width:"+this.width+"px;";
if(_b10==null){
s+=" color: #CCBBB3;";
_b10="~";
}else{
if(typeof (_b10)=="string"&&_b10.length>255){
_b10="(text: "+_b10.length+" chars)";
}else{
_b10=turbo.escapeText(_b10);
}
}
if(this.align){
s+=" text-align: "+this.align+";";
}
return "<div style=\""+s+"\">"+_b10+"</div>";
};
turbo.grid.format.line=turbo.grid.format.text;
turbo.grid.edit.line=new function(){
this.createInput=function(_b13,_b14){
var i=document.createElement("input");
i.setAttribute("autocomplete","OFF");
i.value=(_b14===undefined?"":String(_b14));
i.style.width=_b13.clientWidth-10+"px";
_b13.innerHTML="";
_b13.appendChild(i);
if(i.clientHeight<_b13.clientHeight-4){
i.style.height=_b13.clientHeight-4+"px";
}
turbo.defer(function(){
i.select();
i.focus();
},10);
return i;
};
this.edit=function(_b16,_b17){
this.client.input=this.createInput(_b16,_b17);
};
this.getValue=function(){
return (this.client.input.value=="null"?null:(this.client.input.value=="undefined"?undefined:this.client.input.value));
};
};
turbo.grid.edit.multiLine=new function(){
this.createInput=function(_b18,_b19){
var i=document.createElement("textarea");
i.value=String(_b19);
i.rows=2;
i.style.width=_b18.clientWidth-8+"px";
_b18.innerHTML="";
_b18.appendChild(i);
if(i.clientHeight<_b18.clientHeight-4){
i.style.height=_b18.clientHeight-4+"px";
}
i.select();
i.focus();
return i;
};
this.edit=function(_b1b,_b1c){
this.client.input=this.createInput(_b1b,_b1c);
};
this.getValue=function(){
return (this.client.input.value=="null"?null:this.client.input.value);
};
};
turbo.grid.format.bool=function(_b1d,_b1e){
_b1d=(_b1d?parseInt(_b1d)!=0:false);
var s=" text-align: "+(this.align?this.align:"center")+";";
return "<div style=\"width:"+this.width+"px; "+s+"\">"+"<input type=\"checkbox\""+(_b1e?" disabled=\"disabled\"":"")+(_b1d?" checked=\"checked\"":"")+"/>"+"</div>";
};
turbo.grid.edit.bool=new function(){
this.edit=function(_b20,_b21,_b22){
while(turbo.getTagName(_b20)!="input"){
_b20=_b20.childNodes[0];
}
if(!_b20){
return false;
}
this.client.input=_b20;
this.client.input.focus();
if(this.column.onclick){
this.client.input.onclick=turbo.bindArgs(this,this.column.onclick,_b22);
this.client.input.onclick();
}
};
this.getValue=function(){
return (this.client.input.checked?1:0);
};
};
turbo.grid.isIntChar=function(_b23){
return (_b23.search(/[-+\0\t\n\r\d]/)!=-1);
};
turbo.grid.format.integer=function(_b24,_b25){
var s=" width:"+this.width+"px; text-align: "+(this.align?this.align:"right")+";";
var f="~";
if(_b24==null){
s+=" color: #CCBBB3;";
}else{
f=parseInt(_b24)+(this.units?this.units:"");
}
return "<div style=\""+s+"\">"+f+"</div>";
};
turbo.grid.edit.integer=new function(){
this.limitToInteger=function(_b28){
if(!turbo.grid.isIntChar(String.fromCharCode(_b28.charCode))){
_b28.preventDefault();
}
};
this.createInput=turbo.grid.edit.line.createInput;
this.edit=function(_b29,_b2a){
this.client.input=this.createInput(_b29,_b2a);
dojo.event.connect(this.client.input,"onkeypress",this,"limitToInteger");
};
this.getValue=function(){
var _b2b=Number(this.client.input.value);
return (isNaN(_b2b)?0:_b2b);
};
};
turbo.grid.format.decimal=function(_b2c,_b2d){
var s="text-align: "+(this.align?this.align:"right")+";";
var f="~";
if(_b2c==null){
s+=" color: #CCBBB3;";
}else{
f=parseFloat(_b2c);
f=(this.decimals?f.toFixed(this.decimals):f)+(this.units?this.units:"");
}
return "<div style=\""+s+"\">"+f+"</div>";
};
turbo.grid.decimalIsOk=function(_b30,_b31){
return (_b31=="."&&!/[\.]/.test(_b30));
};
turbo.grid.edit.decimal=new function(){
this.limitToDecimal=function(_b32){
var s=String.fromCharCode(_b32.charCode);
if(!turbo.grid.isIntChar(s)&&!turbo.grid.decimalIsOk(this.client.input.value,s)){
_b32.preventDefault();
}
};
this.createInput=turbo.grid.edit.line.createInput;
this.edit=function(_b34,_b35){
this.client.input=this.createInput(_b34,_b35);
dojo.event.connect(this.client.input,"onkeypress",this,"limitToDecimal");
};
this.getValue=function(){
var _b36=Number(this.client.input.value);
return (isNaN(_b36)?0:_b36);
};
};
turbo.grid.format.money=function(_b37,_b38){
var f=parseFloat(_b37);
var s=(f<0?-1:1);
f=Math.abs(f);
var i=Math.floor(f).toString();
var l=i.length+(s<0?1:0);
f=(s<0?"&#45;":"")+f.toFixed(2);
l=(this.digits?this.digits:5)-l;
var k="$"+turbo.stringOf(l,"&#160;")+f;
return "<div style=\"width:"+this.width+"px;\" class=\"turbo-grid-money"+(s<0?" turbo-grid-money-neg":"")+"\">"+k+"</div>";
};
turbo.grid.format.enumerated=function(_b3e,_b3f){
var opts="";
if(this.options){
for(var i=0,v,s;i<this.options.length;i++){
if(this.values&&this.values[i]){
v=" value=\""+this.values[i]+"\"";
s=(this.values[i]==_b3e);
}else{
v="";
s=(this.options[i]==_b3e);
}
s=(s?" selected":"");
opts+="<option"+v+s+">"+this.options[i]+"</option>";
}
}else{
opts="<option>"+_b3e+"</option>";
}
return "<div>"+"<select"+(_b3f?" disabled=\"disabled\"":"")+">"+opts+"</select>"+"</div>";
};
turbo.grid.edit.enumerated=new function(){
this.edit=function(_b42,_b43){
while(_b42.tagName!="SELECT"){
_b42=_b42.childNodes[0];
}
this.client.input=_b42;
};
this.getValue=function(){
return turbo.getSelectValue(this.client.input);
};
};
turbo.grid.format.autoInc=function(_b44){
var s="";
s+="width:"+(this.width-4)+"px;";
s+=" text-align: "+(this.align?this.align:"right")+";";
if(_b44===undefined){
s+=" color: #CCBBB3;";
_b44="auto";
}
return "<div style=\""+s+"\">"+_b44+"</div>";
};
turbo.grid.columns={};
turbo.grid.columns.basic={width:128,formatter:turbo.grid.format.line,editor:turbo.grid.edit.line};
turbo.grid.columns.integer={width:64,align:"right",formatter:turbo.grid.format.integer,editor:turbo.grid.edit.integer};
turbo.grid.columns.decimal={width:80,align:"right",decimals:3,formatter:turbo.grid.format.decimal,editor:turbo.grid.edit.decimal};
turbo.grid.columns.bool={width:48,align:"center",formatter:turbo.grid.format.bool,editor:turbo.grid.edit.bool};
turbo.grid.columns.enumerated={width:96,formatter:turbo.grid.format.enumerated,editor:turbo.grid.edit.enumerated};
turbo.grid.columns.money={width:96,align:"right",digits:5,formatter:turbo.grid.format.money,editor:turbo.grid.edit.decimal};
turbo.grid.columns.autoInc={align:"right",formatter:turbo.grid.format.autoInc,editor:turbo.grid.edit.integer};
dojo.provide("turbo.grid.classic.controllers");
dojo.require("turbo.grid.classic.columns");
turbo.grid.controllers={};
turbo.grid.controller=function(_b46,_b47,_b48){
if(_b46){
this.readonly=false;
this.columns=new turbo.data.fields(turbo.grid.column);
this.columns.set(_b48);
this.grid=(dojo.lang.isString(_b46)?dojo.widget.getWidgetById(_b46):_b46);
this.grid.controller=this;
this.setModel(_b47);
}
};
dojo.lang.extend(turbo.grid.controller,{canSort:function(_b49){
},showMessage:function(_b4a){
},rowsChanged:function(){
}});
dojo.lang.extend(turbo.grid.controller,{clear:function(){
this.editingCell=null;
this.editingRow=-1;
},build:function(){
this.clear();
this.grid.setSize(this.getColCount(),this.model.getRowCount());
this.grid.build();
},setReadonly:function(_b4b){
if(_b4b!=this.readonly){
this.readonly=_b4b;
this.build();
}
},setModel:function(_b4c){
this.model=_b4c;
if(this.model){
this.build();
}
},getColCount:function(){
var _b4d=this.columns.count();
return (_b4d?_b4d:this.model.getColCount());
},getColumnWidth:function(_b4e,_b4f){
return this.columns.get(_b4f).width;
},getDatum:function(_b50,_b51){
return this.model.getDatum(_b50,_b51);
},getCell:function(_b52,_b53,_b54){
return this.columns.get(_b53).format(this.getDatum(_b53,_b54),this.readonly,_b54);
},getHeaderAlign:function(_b55,_b56){
var a=this.columns.get(_b56)["align"];
return (a?a:"left");
},getColumnTitle:function(_b58,_b59){
var t=this.columns.get(_b59).name;
return (t?t:this.model.fields.get(_b59).name);
},getSortInfo:function(_b5b){
return {column:this.model.sortIndex,desc:this.model.sortDesc};
},onHeaderClick:function(_b5c,_b5d){
if(this.canSort(_b5d)===false){
return;
}
this.applyEdit();
this.model.setSortIndex(_b5d);
this.model.sort();
this.grid.clearMarkers();
this.grid.refresh();
},getClientRowClass:function(_b5e){
},getRowClass:function(_b5f){
var _b60="";
if(this.grid.selected[_b5f]&&this.grid.selectCount>1){
_b60="selected";
}else{
_b60=this.getClientRowClass(_b5f);
if(_b60){
return _b60;
}
}
if(!_b60){
var i=this.model.rowinfo.get(_b5f);
if(i.inflight){
_b60="inflight";
}else{
if(i.error){
_b60="error";
}else{
if(this.grid.selected[_b5f]&&!_b60){
_b60=(i.edit?"editing":"selected");
}
}
}
}
return this.grid.classTag+"-row-"+(_b5f&1)+(_b60?" "+this.grid.classTag+"-"+_b60:"");
}});
dojo.lang.extend(turbo.grid.controller,{setRow:function(_b62,_b63){
this.model.replaceRow(_b62,_b63);
this.grid.updateRow(_b62);
},addRow:function(_b64,_b65){
var row=Number(_b64!=undefined&&_b64>=0?_b64:this.grid.getFirstSelectedRow()+1);
this.applyEdit();
this.model.addRow(row,_b65);
this.grid.addRow(row);
this.editingRow=row;
this.grid.setRowSelected(row);
this.grid.onSelectionChange();
this.rowsChanged();
},appendRow:function(_b67){
this.addRow(Math.max(this.grid.rows,0),_b67);
},removeRow:function(_b68){
this.model.removeRow(_b68);
this.grid.removeRow(_b68);
},removeSelectedRows:function(){
var rows=this.grid.getSelectedRows();
for(var i=0;i<rows.length;i++){
this.removeRow(rows[i]-i);
}
},swapRows:function(inI,inJ){
this.finishGridEdit();
this.model.swapRows(inI,inJ);
this.grid.swapRows(inI,inJ);
},canMoveRow:function(_b6d){
var src=this.grid.selectedRow;
var dst=src+_b6d;
return (src>=0&&dst>=0&&dst<this.grid.rows);
},moveRow:function(_b70){
if(!this.canMoveRow(_b70)){
return;
}
this.finishGridEdit();
var src=this.grid.selectedRow;
var dst=src+_b70;
this.swapRows(src,src+_b70);
this.grid.setRowSelected(src,false);
this.grid.setRowSelected(dst,true);
this.grid.onSelectionChange();
},moveRowUp:function(){
this.moveRow(-1);
},moveRowDown:function(){
this.moveRow(1);
}});
turbo.grid.controller.prototype.newRow=turbo.grid.controller.prototype.addRow;
dojo.lang.extend(turbo.grid.controller,{onBeginEdit:function(_b73){
},onEditRowStart:function(_b74){
},onEditRowDone:function(){
},editingCell:null,editingRow:-1,editCellDone:function(){
this.editingCell=null;
},cancelEditCell:function(){
if(this.editingCell){
this.grid.refreshCell(this.editingCell);
this.editCellDone();
}
},updateEditCell:function(){
if(this.editingCell&&this.editor){
this.updateCell(this.editingCell,this.editor);
this.grid.refreshCell(this.editingCell);
}
},finishEditCell:function(){
this.updateEditCell();
if(this.editingCell){
this.grid.updateRowClass(this.editingCell.row);
}
this.editCellDone();
},editRowStart:function(_b75){
if(this.editingRow!=_b75){
this.editingRow=_b75;
this.model.startEdit(_b75);
this.onEditRowStart(_b75);
}
},editRowDone:function(){
this.editingRow=-1;
this.onEditRowDone();
},cancelEditRow:function(){
if(this.editingRow>=0){
var row=this.editingRow;
this.editingRow=-1;
this.grid.updateRowClass(row);
this.editRowDone();
}
},finishEditRow:function(){
if(this.editingRow>=0){
var row=this.editingRow;
this.updateRow(row);
this.editingRow=-1;
this.grid.updateRowClass(row);
this.editRowDone();
}
},cancelGridEdit:function(){
this.cancelEditCell();
this.cancelEditRow();
},finishGridEdit:function(){
this.finishEditCell();
this.finishEditRow();
},editCell:function(_b78,_b79,_b7a){
if(!_b78){
return;
}
var cell=this.grid.getCellPos(_b78);
if(this.grid.sameCell(this.editingCell,cell)||(!this.grid.goodCell(cell)&&cell.row==this.editingRow)){
return;
}
this.finishEditCell();
if(!this.grid.goodCell(cell)||_b79||_b7a){
this.finishEditRow();
this.grid.clickSelect(cell.row,_b79,_b7a);
dojo.html.clearSelection();
}else{
this.grid.unselectRows(cell.row);
if(_b78.parentNode==null){
return;
}
cell=this.grid.getCellPos(_b78);
this.editor=this.getEditor(cell);
if(this.editor){
this.editingCell=cell;
this.editRowStart(cell.row);
window.setTimeout(turbo.bind(this.grid,this.grid.updateRowSizes),10);
this.onBeginEdit(cell);
}
this.grid.setRowSelected(cell.row,true);
this.grid.onSelectionChange();
}
},onDataClick:function(_b7c,_b7d,_b7e){
this.editCell(_b7d,_b7e.ctrlKey,_b7e.shiftKey);
},onDataDblClick:function(_b7f,_b80,_b81){
}});
dojo.lang.extend(turbo.grid.controller,{getEditor:function(_b82){
var _b83=(this.readonly?null:this.columns.get(_b82.col).getEditor());
if(_b83){
_b83.client=this;
if(_b83.edit(this.grid.getDomCell(_b82),this.getDatum(_b82.col,_b82.row),_b82)===false){
_b83=null;
}
}
return _b83;
},updateCell:function(_b84,_b85){
_b85.client=this;
this.model.setDatum(_b84.col,_b84.row,_b85.getValue());
}});
dojo.lang.extend(turbo.grid.controller,{onUnselectRow:function(_b86,_b87){
if(_b87==this.editingRow){
this.applyEdit();
}
},applyEdit:function(_b88){
if(this.editingRow>=0){
this.model.rowinfo.get(this.editingRow).sync=Boolean(_b88);
this.finishGridEdit();
}
},applyEditSync:function(){
this.applyEdit(true);
},cancelEdit:function(){
if(this.editingRow>=0){
var row=this.editingRow;
this.cancelGridEdit();
if(this.model.rowinfo.get(row).insert){
this.removeRow(row);
}else{
this.model.cancelEdit(row);
this.grid.updateRow(row);
}
}
}});
dojo.lang.extend(turbo.grid.controller,{_commitError:function(_b8a,_b8b){
this.grid.updateRow(_b8a);
var e=(_b8b?_b8b:this.model.rowinfo.get(_b8a).error);
turbo.debug("turbo.grid.controller._commitError: "+e);
this.showMessage("A server commit error occured: ["+e+"]",true);
},_commitOk:function(_b8d){
this.grid.updateRow(_b8d);
this.rowsChanged();
},updateRow:function(_b8e){
var ok=turbo.bindArgs(this,"_commitOk",_b8e);
var _b90=turbo.bindArgs(this,"_commitError",_b8e);
this.model.applyEdit(_b8e,ok,_b90);
}});
dojo.lang.extend(turbo.grid.controller,{_deleteError:function(){
},_deleteOk:function(_b91,_b92){
var c=_b92;
turbo.debug("turbo.grid.controller._deleteOk: deleted "+c+" row(s)");
var self=this;
var _b95=0;
var each=function(_b97){
if(_b95>=c){
return false;
}
self.removeRow(_b97-_b95++);
return true;
};
dojo.lang.every(_b91,each);
if(this.model.repaginate()){
turbo.debug("turbo.grid.controller._deleteOk: repaginate signalled page change, reloading");
this.reloadPage();
}else{
this.model.invalidatePage();
}
this.rowsChanged();
},_deleteRows:function(){
var rows=this.grid.getSelectedRows();
var _b99=rows.length;
if(!confirm("Ok to delete "+(_b99!=1?_b99+" rows":"one row")+" from table \""+this.model.table+"\""+"?")){
return;
}
this.cancelGridEdit();
var _b9a=0;
var _b9b=function(_b9c){
var row=_b9c-_b9a;
var e=this.model.rowinfo.get(row);
if(!e.insert){
return row;
}else{
_b9a++;
turbo.debug("turbo.grid.controller._deleteRows: removing non-committed row "+row);
this.removeRow(row);
return undefined;
}
};
rows=turbo.filter(rows,_b9b,this);
turbo.debug("turbo.grid.controller._deleteRows: deleting "+rows.length+" row(s)");
this.model.deleteRows(rows,turbo.bind(this,this._deleteOk),turbo.bind(this,this._deleteError));
},deleteRows:function(){
this.grid.setBusyStatus();
try{
this._deleteRows();
}
finally{
this.grid.setReadyStatus();
}
}});
dojo.lang.extend(turbo.grid.controller,{prevEdit:function(){
if(this.editingCell){
var cell={col:this.editingCell.col,row:this.editingCell.row};
if(--cell.col>=0){
this.editCell(this.grid.getDomCell(cell));
}else{
if(--cell.row>=0){
this.editCell(this.grid.getDomCell({col:this.grid.cols-1,row:cell.row}));
}
}
}
},nextEdit:function(){
if(this.editingCell){
var cell={col:this.editingCell.col,row:this.editingCell.row};
if(++cell.col<this.grid.cols){
this.editCell(this.grid.getDomCell(cell));
}else{
if(++cell.row<this.grid.rows){
this.editCell(this.grid.getDomCell({col:0,row:cell.row}));
}
}
}
},onKeyDown:function(_ba1,_ba2){
if(_ba2.altKey||_ba2.ctrlKey||_ba2.metaKey){
return;
}
switch(_ba2.keyCode){
case _ba2.KEY_ESCAPE:
this.cancelEditCell();
break;
case _ba2.KEY_ENTER:
if(!_ba2.shiftKey){
this.finishEditCell();
}
break;
case _ba2.KEY_TAB:
if(this.editingCell){
dojo.event.browser.stopEvent(_ba2);
if(_ba2.shiftKey){
this.prevEdit();
}else{
this.nextEdit();
}
}
break;
}
}});
turbo.grid.controllers.paged=function(_ba3,_ba4,_ba5){
turbo.grid.controller.call(this,_ba3,_ba4,_ba5);
};
dojo.inherits(turbo.grid.controllers.paged,turbo.grid.controller);
dojo.lang.extend(turbo.grid.controllers.paged,{setModel:function(_ba6){
this.model=_ba6;
if(this.model){
this.model.repaginate();
this.model.selectPage(0);
this.build();
}
},_selectPage:function(_ba7,_ba8){
this.model.selectPage(_ba7);
this.build();
this.grid.setReadyStatus();
if(_ba8){
_ba8();
}
},selectPage:function(_ba9,_baa){
this.grid.setBusyStatus();
this.grid.teardownRows();
turbo.defer(turbo.bindArgs(this,this._selectPage,_ba9,_baa),20);
},reloadPage:function(){
this.model.reloadPage();
this.build();
},formatFixedCol:function(_bab,_bac){
return Number(_bac)+1+this.model.getTopRow();
}});
dojo.provide("turbo.grid.classic.extensions");
turbo.grid.extensions={};
turbo.grid.extensions.edit={extend:function(_bad){
dojo.lang.mixin(_bad,this);
},getEditor:function(_bae){
},updateCell:function(_baf,_bb0){
},updateRow:function(_bb1){
},cacheEditRow:function(_bb2){
},onEditRowStart:function(){
},onEditRowDone:function(){
},editingCell:null,editingRow:-1,editClear:function(){
this.editingCell=null;
this.editingRow=-1;
},editCellDone:function(){
this.editingCell=null;
},cancelEditCell:function(){
if(this.editingCell){
this.refreshCell(this.editingCell);
this.editCellDone();
}
},updateEditCell:function(){
if(this.editingCell&&this.editor){
this.updateCell(this.editingCell,this.editor);
this.refreshCell(this.editingCell);
}
},finishEditCell:function(){
this.updateEditCell();
if(this.editingCell){
this.updateRowClass(this.editingCell.row);
}
this.editCellDone();
},editRowStart:function(_bb3){
if(this.editingRow!=_bb3){
this.editingRow=_bb3;
this.cacheEditRow(_bb3);
this.onEditRowStart(_bb3);
}
},editRowDone:function(){
this.editingRow=-1;
this.onEditRowDone();
},cancelEditRow:function(){
if(this.editingRow>=0){
var row=this.editingRow;
this.editingRow=-1;
this.updateRowClass(row);
this.editRowDone();
}
},finishEditRow:function(){
if(this.editingRow>=0){
var row=this.editingRow;
this.updateRow(row);
this.editingRow=-1;
this.updateRowClass(row);
this.editRowDone();
}
},cancelGridEdit:function(){
this.cancelEditCell();
this.cancelEditRow();
},finishGridEdit:function(){
this.finishEditCell();
this.finishEditRow();
},editCell:function(_bb6,_bb7,_bb8){
if(!_bb6){
return;
}
var cell=this.getCellPos(_bb6);
if(!this.goodCell(cell)||this.sameCell(this.editingCell,cell)){
return;
}
this.finishEditCell();
if(_bb7||_bb8){
this.finishEditRow();
this.clickSelect(cell.row,_bb7,_bb8);
dojo.html.clearSelection();
}else{
this.unselectRows(cell.row);
if(_bb6.parentNode==null){
return;
}
cell=this.getCellPos(_bb6);
this.editor=this.getEditor(cell,_bb6);
if(this.editor){
this.editor.client=this;
this.editingCell=cell;
this.editRowStart(cell.row);
window.setTimeout(turbo.bind(this,this.updateRowSizes),10);
}
this.setRowSelected(cell.row,true);
this.onSelectionChange();
}
},editClick:function(_bba,_bbb,_bbc){
this.editCell(_bba,_bbb,_bbc);
},prevEdit:function(){
if(this.editingCell){
var cell={col:this.editingCell.col,row:this.editingCell.row};
if(--cell.col>=0){
this.editCell(this.getDomCell(cell));
}else{
if(--cell.row>=0){
this.editCell(this.getDomCell({col:this.cols-1,row:cell.row}));
}
}
}
},nextEdit:function(){
if(this.editingCell){
var cell={col:this.editingCell.col,row:this.editingCell.row};
if(++cell.col<this.cols){
this.editCell(this.getDomCell(cell));
}else{
if(++cell.row<this.rows){
this.editCell(this.getDomCell({col:0,row:cell.row}));
}
}
}
},editKeyDown:function(_bbf){
if(_bbf.altKey||_bbf.ctrlKey||_bbf.metaKey){
return;
}
switch(_bbf.keyCode){
case _bbf.KEY_ESCAPE:
this.cancelEditCell();
break;
case _bbf.KEY_ENTER:
if(!_bbf.shiftKey){
this.finishEditCell();
}
break;
case _bbf.KEY_TAB:
if(this.editingCell){
dojo.event.browser.stopEvent(_bbf);
if(_bbf.shiftKey){
this.prevEdit();
}else{
this.nextEdit();
}
}
break;
}
},getRowClass:function(_bc0){
var _bc1=this.rowMarkerClass[_bc0];
if(this.selected[_bc0]&&(!_bc1||this.selectCount>1)){
_bc1=(this.editingRow==_bc0?"editing":"selected");
}
return this.classTag+"-row-"+(_bc0&1)+(_bc1?" "+this.classTag+"-"+_bc1:"");
},dataClick:function(_bc2,_bc3){
this.editClick(_bc2,_bc3.ctrlKey,_bc3.shiftKey);
},dataKeyDown:function(_bc4){
this.editKeyDown(_bc4);
}};

