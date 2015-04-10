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
                            
  req = Velocity::VelocityProcessor.new(
                                   identity_token,
                                   work_flow_id,
                                   application_profile_id,
                                   merchant_profile_id)        
####Verify Transaction:       
Here we pass the address and credit card details, and industry type.

          @response = req.verify     
                   ({
                        CardholderName: 'John Doe',
                        Street: '4 corporate sq',
                        City: 'dever',
                        CountryCode: 'USA',
                        PostalCode: '30329',
                        Phone: '9540123123',
                        Email: 'najeers@chetu.com',
                        Amount: '10.00',
                        CardType: 'Visa',
                        PAN: '4012888812348882',
                        Expire: '0320', 
                        CVData: '123',
                        EntryMode: 'Keyed',
                        IndustryType: 'Ecommerce'
                    })
         puts @response  # show all the response data, if any error is raised also show errors. 


####Authorize without Token Transaction:                   
Here we pass the address and credit card details, and industry type.

          @response = req.authorize     
                   ({
                        Street1: '4 corporate sq',
                        City: 'dever',
                        CountryCode: 'USA',
                        PostalCode: '30329',
                        Phone: '9540123123',
                        Email: 'najeers@chetu.com',
                        Amount: '10.00', 
                        CardType: 'Visa',
                        PAN: '4012888812348882',
                        Expire: '0320',  
                        CVData: '123',
                        InvoiceNumber: '802',
                        OrderNumber: '629203',
                        EntryMode: 'Keyed',
                        IndustryType: 'Ecommerce'
                    })
         puts @response   #show all the response data, if any error is raised also show errors.

####Authorize with Token Transaction:  
Here we pass the address details,industry type, and also pass the payment account data token. 

          @response = req.authorize     
                   ({
                        Street1: '4 corporate sq',
                        City: 'dever',
                        CountryCode: 'USA',
                        PostalCode: '30329',
                        Phone: '9540123123',
                        Email: 'najeers@chetu.com',
                        Amount: '10.00', 
                        PaymentAccountDataToken: '   '    
                        InvoiceNumber: '802',
                        OrderNumber: '629203',
                        EntryMode: 'Keyed',
                        IndustryType: 'Ecommerce'
                    })
         puts @response   #show all the response data, if any error is raised also show errors.

####P2PE transaction for Authorize:  
Here we pass the address details,industry type, and also pass card swape data. 

          @response = req.authorize     
                   ({
                        Street1: '4 corporate sq',
                        City: 'dever',
                        CountryCode: 'USA',
                        PostalCode: '30329',
                        Phone: '9540123123',
                        Email: 'najeers@chetu.com',
                        Amount: '10.00', 
                        SecurePaymentAccountData: '  ',
                        EncryptionKeyId:  ' ',   
                        InvoiceNumber: '802',
                        OrderNumber: '629203',
                        EntryMode: 'TrackDataFromMSR',
                        IndustryType: 'Retail'
                    })
         puts @response   #show all the response data, if any error is raised also show errors.


####AuthorizeAndCapture without Token Transaction:    
 Here we pass the address and credit card details, and industry type.

          @response = req.authorizeAndCapture     
                   ({
                        Street1: '4 corporate sq',
                        City: 'dever',
                        CountryCode: 'USA',
                        PostalCode: '30329',
                        Phone: '9540123123',
                        Email: 'najeers@chetu.com',
                        Amount: '10.00', 
                        CardType: 'Visa',
                        PAN: '4012888812348882',
                        Expire: '0320',  
                        CVData: '123',
                        InvoiceNumber: '802',
                        OrderNumber: '629203',
                        EntryMode: 'Keyed',
                        IndustryType: 'Ecommerce'
                    })
         puts @response   #show all the response data, if any error is raised also show errors. 

####AuthorizeAndCapture with Token Transaction:   
Here we pass the address details,industry type, and also pass the payment account data token. 

          @response = req.authorizeAndCapture     
                   ({
                        Street1: '4 corporate sq',
                        City: 'dever',
                        CountryCode: 'USA',
                        PostalCode: '30329',
                        Phone: '9540123123',
                        Email: 'najeers@chetu.com',
                        Amount: '10.00', 
                        PaymentAccountDataToken: '   '    
                        InvoiceNumber: '802',
                        OrderNumber: '629203',
                        EntryMode: 'Keyed',
                        IndustryType: 'Ecommerce'
                    })
         puts @response   #show all the response data, if any error is raised also show errors. 

####P2PE transaction for AuthorizeAndCapture:  
Here we pass the address details,industry type, and also pass card swape data. 

          @response = req.authorizeAndCapture     
                   ({
                        Street1: '4 corporate sq',
                        City: 'dever',
                        CountryCode: 'USA',
                        PostalCode: '30329',
                        Phone: '9540123123',
                        Email: 'najeers@chetu.com',
                        Amount: '10.00', 
                        SecurePaymentAccountData: '  ',
                        EncryptionKeyId:  ' ',   
                        InvoiceNumber: '802',
                        OrderNumber: '629203',
                        EntryMode: 'TrackDataFromMSR',
                        IndustryType: 'Retail'
                    })
         puts @response   #show all the response data, if any error is raised also show errors.

####Capture Transaction:
Here we pass the Transaction Id and Amount.

          @response = req.capture     
                   ({
                        TransactionId: '      ',
                        Amount: '10.00'
                    })
         puts @response   #show all the response data, if any error is raised also show errors.

####Capture All Transaction:
Here we pass the Transaction Ids and Amounts.

          @response = req.captureAll     
                   ({
                        TransactionId: '      ',
                        Amount: '10.00'
                    })
         puts @response   #show all the response data, if any error is raised also show errors.

####Void(Undo) Transaction: 
Here we pass the Transaction Id only.

          @response = req.undo     
                   ({
                        TransactionId: '      '
                    })
         puts @response   #show all the response data, if any error is raised also show errors. 
         
####Adjust Transaction:        
Here we pass the Transaction Id and adjusted Amount.

          @response = req.adjust     
                   ({
                        TransactionId: '    ',
                        Amount: '10.00'
                    })
         puts @response   #show all the response data, if any error is raised also show errors.


####ReturnById Transaction:   
Here we pass the Transaction Id and Amount.

          @response = req.returnById     
                   ({
                        TransactionId: '      ',
                        Amount: '10.00'
                    })
         puts @response   #show all the response data, if any error is raised also show errors.


####ReturnUnlinked Transaction:   
Here we pass the address details,industry type, and also pass the payment account data token. 

          @response = req.returnUnlinked     
                   ({
                        Street1: '4 corporate sq',
                        City: 'dever',
                        CountryCode: 'USA',
                        PostalCode: '30329',
                        Phone: '9540123123',
                        Email: 'najeers@chetu.com',
                        Amount: '10.00', 
                        PaymentAccountDataToken: '   ',
                        InvoiceNumber: '802',
                        OrderNumber: '629203',
                        EntryMode: 'Keyed',
                        IndustryType: 'Ecommerce'
                    })
         puts @response   #show all the response data, if any error is raised also show errors.

####P2PE transaction for ReturnUnlinked:  
Here we pass the address details,industry type, and also pass card swape data. 

          @response = req.returnUnlinked     
                   ({
                        Street1: '4 corporate sq',
                        City: 'dever',
                        CountryCode: 'USA',
                        PostalCode: '30329',
                        Phone: '9540123123',
                        Email: 'najeers@chetu.com',
                        Amount: '10.00', 
                        SecurePaymentAccountData: '  ',
                        EncryptionKeyId:  ' ',  
                        InvoiceNumber: '802',
                        OrderNumber: '629203',
                        EntryMode: 'TrackDataFromMSR',
                        IndustryType: 'Retail'
                    })
         puts @response   #show all the response data, if any error is raised also show errors.
         
####QueryTransactionsDetail Transaction:
Here we pass the Batch id or TransactionId or TransactionDateRanges.

          @response = req.queryTransactionsDetail     
            ({
                BatchIds: '0620',
                TransactionIds: 'C37A4ACDCA1340E2B458FBA7CDA76785',
                EndDateTime: '2015-03-17 02:03:40',
                StartDateTime: '2015-03-13 02:03:40'
            })
         puts @response   #show all the response data, if any error is raised also show errors.
         
