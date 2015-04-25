/**
 * Created by Jbrack on 3/29/2015
 */
var name, email, phone, address, acct;

function init(){

}

function submit() {
   email = document.getElementById("email").value;
   name = document.getElementById("name").value;
   phone = document.getElementById("phone").value;
   address = document.getElementById("address").value;
   acct = new publicAccount(name, email, phone, address);
}

function publicAccount (name, email, phone, address){
    this.address = address;
    this.phone = phone;
    this.email = email;
    this.name = name;
}
