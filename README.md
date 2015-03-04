#Velocity Ruby SDK Documentations 

####1. Installation: 
   For installation first download the source code then go to the source code directory in terminal and run the command:

       $ gem build velocity.gemspec
 
  The above command will generate the .tar file. Now you can install the gem directly using this command:
 
        $ gem install velocity-0.0.0.gem


####2.Dependencies:
The Velocity Ruby SDK has the following dependencies which are required by the gems.
      1. httparty
      2. nokogiri 

####3.How to add the gem to your application:
Add following lines to your application's Gemfile:

         gem 'velocity'
         gem 'httparty'
         gem 'nokogiri'


And then run the command:

    $ bundle



####4.How to initialize the ruby SDK
Frist initialize the object
                            
        req = Velocity::Processor.new(
                                   identity_token,
                                   work_flow_id,
                                   application_profile_id,
                                   merchant_profile_id)        
####Verify method:       
Here we pass the address and credit card details.

          @response = req.verify     
                   ({
                        CardType: 'Visa',
                        CardholderName: 'Najeer',
                        Expire: '0320', 
                        Street: '4 corporate sq',
                        City: 'dever',
                        CountryCode: 'USA',
                        PostalCode: '30329',
                        Phone: '9540243939',
                        Email: 'najeers@chetu.com',
                        Amount: '10.00', 
                        PAN: '4012888812348882', 
                        CVData: '123',
                        InvoiceNumber: '802',
                        OrderNumber: '629203'
                    })
         puts @response  # show all the response data, if any error is raised also show errors. 


####Authorize without Token method:                   
Here we pass the address and credit card details.

          @response = req.authorize     
                   ({
                        CardType: 'Visa',
                        Expire: '0320', 
                        Street1: '4 corporate sq',
                        City: 'dever',
                        CountryCode: 'USA',
                        PostalCode: '30329',
                        Phone: '9540243939',
                        Email: 'najeers@chetu.com',
                        Amount: '10.00', 
                        PAN: '4012888812348882', 
                        CVData: '123',
                        InvoiceNumber: '802',
                        OrderNumber: '629203'
                    })
         puts @response   #show all the response data, if any error is raised also show errors.
####Authorize with Token method:  
Here we pass the address, credit card details and also pass the payment account data token.

          @response = req.authorize     
                   ({
                        CardType: 'Visa',
                        Expire: '0320', 
                        Street1: '4 corporate sq',
                        City: 'dever',
                        CountryCode: 'USA',
                        PostalCode: '30329',
                        Phone: '9540243939',
                        Email: 'najeers@chetu.com',
                        Amount: '10.00', 
                        PaymentAccountDataToken: '   '    
                        PAN: '4012888812348882', 
                        CVData: '123',
                        InvoiceNumber: '802',
                        OrderNumber: '629203'
                    })
         puts @response   #show all the response data, if any error is raised also show errors.


####AuthorizeAndCapture without Token:    
 Here we pass the address and credit card details.

          @response = req.authorize_capture     
                   ({
                        CardType: 'Visa',
                        Expire: '0320', 
                        Street1: '4 corporate sq',
                        City: 'dever',
                        CountryCode: 'USA',
                        PostalCode: '30329',
                        Phone: '9540243939',
                        Email: 'najeers@chetu.com',
                        Amount: '10.00', 
                        PAN: '4012888812348882', 
                        CVData: '123',
                        InvoiceNumber: '802',
                        OrderNumber: '629203'
                    })
         puts @response   #show all the response data, if any error is raised also show errors. 

####AuthorizeAndCapture with Token method:   
Here we pass the address, credit card details and also pass the payment account data token.

          @response = req.authorize_capture     
                   ({
                        CardType: 'Visa',
                        Expire: '0320', 
                        Street1: '4 corporate sq',
                        City: 'dever',
                        CountryCode: 'USA',
                        PostalCode: '30329',
                        Phone: '9540243939',
                        Email: 'najeers@chetu.com',
                        Amount: '10.00', 
                        PaymentAccountDataToken: '   '
                        PAN: '4012888812348882', 
                        CVData: '123',
                        InvoiceNumber: '802',
                        OrderNumber: '629203'
                    })
         puts @response   #show all the response data, if any error is raised also show errors. 


####Capture method:
Here we pass the Transaction Id and Amount.

          @response = req.capture     
                   ({
                        TransactionId: '      ',
                        Amount: '10.00'
                    })
         puts @response   #show all the response data, if any error is raised also show errors.


####Void(Undo) method: 
Here we pass the Transaction Id only.

          @response = req.undo     
                   ({
                        TransactionId: '      '
                    })
         puts @response   #show all the response data, if any error is raised also show errors. 
####Adjust method:        
Here we pass the Transaction Id and adjust Amount.

          @response = req.adjust     
                   ({
                        TransactionId: '      ',
                        Amount: '10.00'
                    })
         puts @response   #show all the response data, if any error is raised also show errors.


####ReturnById method:   
Here we pass the Transaction Id and Amount.

          @response = req.return_by_id     
                   ({
                        TransactionId: '      ',
                        Amount: '10.00'
                    })
         puts @response   #show all the response data, if any error is raised also show errors.


####ReturnUnlinked method:   
Here we pass the address, credit card details and also pass the payment account data token. 

          @response = req.return_unlinked     
                   ({
                        CardType: 'Visa',
                        Expire: '0320', 
                        Street1: '4 corporate sq',
                        City: 'dever',
                        CountryCode: 'USA',
                        PostalCode: '30329',
                        Phone: '9540243939',
                        Email: 'najeers@chetu.com',
                        Amount: '10.00', 
                        PaymentAccountDataToken: '   ',
                        PAN: '4012888812348882', 
                        CVData: '123',
                        InvoiceNumber: '802',
                        OrderNumber: '629203'
                    })
         puts @response   #show all the response data, if any error is raised also show errors.
