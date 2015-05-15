var Stripe = require('stripe');
Stripe.initialize('sk_test_YdL7RiVRzXasT4YPE0d415s3');

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

//Charge user's card with token passed
Parse.Cloud.define("chargeCard", function(request, response) {

  Parse.Cloud.useMasterKey(); //DANGEROUS AND NOT QUITE REQUIRED. REMOVE!
  var res = Stripe.Charges.create(
    {
      amount: request.params.price * 100, //$ -> Cents 
      currency: 'usd',
      card: request.params.cardToken
    },  {
    success: function(charge) {
       console.log('Charging successful.');
       return charge;
    },
    error: function() {
      console.log('Charging failed.');
      response.success(false);
    }
  }).then(function(charge){
    console.log('Saving charge object...');
    //savedCharge = Charge.create({
    //  name: charge.card.name,
    //  amount: charge.amount,
    //  email: charge.metadata.email,
    //  address: charge.card.address_line1 + charge.card.address_line1,
    //  city: charge.card.address_city,
    //  state: charge.card.address_city,
    //  zip: charge.card.address_zip,
    //  tax_receipt: charge.metadata.tax_receipt,
    //  missionary: charge.metadata.missionary,
    //});
    console.log('Done!');
    response.success(true);
    })

});