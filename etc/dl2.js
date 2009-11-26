var title,d=document,l=d.location,href=l.href;

if (typeof is_server_on != 'undefined' && is_server_on !== 1) {
    alert('plz, Run Delicious Library 2 Server');
    exit;
}

if (/www\.aladdin\.co\.kr\/shop\/wproduct\.aspx/.test(l)) {
    // Aladdin
    href.match(/ISBN=(.+)$/i);
    var isbn = RegExp.$1;
    update_item(isbn);
} 
else if (/www\.yes24\.com\/24\/goods/.test(l)) {
    // Yes24
    var html = d.body.innerHTML;
    html.match(/ISBN-13<\/dt>[\s\n.]*?<dd>([^<]+)<\/dd>/);
    var isbn = RegExp.$1;
    update_item(isbn);
}
else if (/www\.kyobobook\.co\.kr\/product\/detailViewKor/.test(l)) {
    // Kyobo
    href.match(/barcode=(\d+)/i);
    var isbn = RegExp.$1;
    update_item(isbn);
}
else if (/kangcom.com\/sub\/view\.asp/.test(l)) {
    // Kangcom
    var html = d.body.innerHTML;
    html.match(/(\d{10}) \| (\d{13})/i);
    var isbn = RegExp.$1;
    update_item(isbn);
}
else {
    alert('WTF?');
}

function ping() {
    i = document.createElement('scr'+ 'ipt');
    i.setAttribute('src', 'http://localhost:8080/is_alive');
    document.body.appendChild(i);
    alert(is_server_on);
}

function update_item(isbn) {
    if (!isbn) {
	return;
    }
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

function _close() {
    var f = document.getElementById('dl2');
    f.style.display = 'none';
    f.parentNode.removeChild(f);
}