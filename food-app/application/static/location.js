/**
 * Created by Jbrack on 3/29/2015
 */
var m, t, w, r, f, s, su;

function init(){
    m = "0";
    t = "0";
    w = "0";
    r = "0";
    f = "0";
    s = "0";
    su = "0";
    $("#confirmButton").click(function(e){
        e.preventDefault();
        $.post('/api/updateHours', $('#hoursForm').serialize(), function(){
            window.location.reload();
        });
    });
}

function edit(){
    //getHours();
    document.getElementById("editHours").style.visibility = "visible";
    document.getElementById("mask").style.visibility = "visible";
}