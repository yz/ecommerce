
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});

//Get user in _User table
Parse.Cloud.define("getUser", function(request, response) {

  Parse.Cloud.useMasterKey(); //DANGEROUS AND NOT QUITE REQUIRED. REMOVE!
  
  var users;
  var usrQuery = new Parse.Query('_User');
  usrQuery.equalTo('email', request.params.email);
  usrQuery.find({
    success: function(results) {
      response.success(results);
    },
    error: function() {
      response.error("User missing or invalid email-ID");
    }
  });
});