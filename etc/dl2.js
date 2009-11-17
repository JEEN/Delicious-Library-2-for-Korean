// inspired by Instapaper Bookmarklet
// version 0.01 
// Author: JEEN < jeen@perl.kr >

var l=document.location;
 
if (/www\.aladdin\.co\.kr\/shop\/wproduct\.aspx/.test(l)) {
    href.match(/ISBN=(.+)$/);
    var isbn = RegExp.$1;
    if (isbn) {
        i = document.createElement('iframe');
        i.setAttribute('name', 'dl2');
        i.setAttribute('id', 'dl2');
        document.body.appendChild(i);
        i.onload = function() { setTimeout(_close, 350); }
        window['dl2'].document.write('<html><body><form action="http://localhost:8080/bookmarklet/add" method="post" id="f">'
                               + '<input type="hidden" name="id" value="'+isbn+'"/>'
                               + '</form>'
                               + '<scr' + 'ipt>setTimeout(function() { document.getElementById("f").submit(); }, 1);</scr' + 'ipt>'
                               + '</body></html>');
 
    }
} 
 
function _close() {
    var f = document.getElementById('dl2');
    f.style.display = 'none';
    f.parentNode.removeChild(f);
}