/**
 * Created by Jbrack on 3/29/2015
 */
var locations = ["Morgansdale", "Cloudyside", "Uptown", "Mountain"];

function init(){
    //locations = ?
    var x;
    var table = document.getElementById("salesTable");
    for (x in locations) {
        var row = table.insertRow(0);
        /*var cell1 = row.insertCell(0);
        cell1.innerHTML = locations[x].ccSales;
        var cell1 = row.insertCell(0);
        cell1.innerHTML = locations[x].ddSales;
        var cell1 = row.insertCell(0);
        cell1.innerHTML = locations[x].mealSales;
        var cell1 = row.insertCell(0);
        cell1.innerHTML = locations[x].totalSales;*/
        var cell1 = row.insertCell(0);
        cell1.innerHTML = "0";
        var cell1 = row.insertCell(0);
        cell1.innerHTML = "0";
        var cell1 = row.insertCell(0);
        cell1.innerHTML ="0";
        var cell1 = row.insertCell(0);
        cell1.innerHTML = "0";
        var cell1 = row.insertCell(0);
        cell1.innerHTML = locations[x];
    }
    var row = table.insertRow(0);
    var cell1 = row.insertCell(0);
    cell1.innerHTML = "Credit Card"
    var cell1 = row.insertCell(0);
    cell1.innerHTML = "Dining Dollars"
    var cell1 = row.insertCell(0);
    cell1.innerHTML = "Meal Plan"
    var cell1 = row.insertCell(0);
    cell1.innerHTML = "Total Sales"
    var cell1 = row.insertCell(0);
    cell1.innerHTML = "Location"
}

function edit(){
    //getHours();
    document.getElementById("editHours").style.visibility = "visible";
    document.getElementById("mask").style.visibility = "visible";
}

function sales(){

}

function transaction(){

}

function confirm(){

}