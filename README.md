# Velocity Ruby SDK Documentations

#### 1. Installation:
For installation first download the source code then go to the source code directory in terminal and run the command:

        $ gem build velocity.gemspec

The above command will generate the .tar file. Now you can install the gem directly using this command:

        $ gem install velocity-0.0.0.gem

Add following lines to your application's Gemfile:

        gem 'velocity'
##### OR
Add the following line to your application's Gemfile:

        gem 'velocity', :git => "git://github.com/nab-velocity/ruby-sdk.git"

##### Then
Run the command:

        $ bundle

#### 2. Dependencies:
The Velocity Ruby SDK has the following dependencies:
1. HTTParty
2. Nokogiri

*Note: Bundler will automatically resolve 'httparty' and 'nokogiri' dependencies without adding them to the Gemfile.*

#### 3. How to initialize the ruby SDK
First initialize the object

```ruby
        req = Velocity::VelocityProcessor.new(
            identity_token,
            work_flow_id,
            application_profile_id,
            merchant_profile_id
        )
```
#### Verify Transaction:
Here we pass the address and credit card details, and industry type.

```ruby
        @response = req.verify(
            {
                CardholderName: 'John Doe',
                Street: '4 corporate sq',
                City: 'dever',
                CountryCode: 'USA',
                PostalCode: '30329',
                Phone: '9540123123',
                Email: 'najeers@chetu.com',
                Amount: '10.00',
                CardType: 'Visa',
                CVData: '123',
                IndustryType: 'Ecommerce',
                PAN: '4012888812348882',
                Expire: '0320',
                EntryMode: 'Keyed'
            }
        )
```

        OR

```ruby
        @response = req.verify(
            {
                CardholderName: 'John Doe',
                Street: '4 corporate sq',
                City: 'dever',
                CountryCode: 'USA',
                PostalCode: '30329',
                Phone: '9540123123',
                Email: 'najeers@chetu.com',
                Amount: '10.00',
                CardType: 'Visa',
                CVData: '123',
                IndustryType: 'Ecommerce',
                Track1Data: '%B4012000033330026^NAJEER/SHAIK ^0904101100001100000000123456780?',
                EntryMode: 'TrackDataFromMSR'
            }
        )
```

        OR

```ruby
        @response = req.verify(
            {
                CardholderName: 'John Doe',
                Street: '4 corporate sq',
                City: 'dever',
                CountryCode: 'USA',
                PostalCode: '30329',
                Phone: '9540123123',
                Email: 'najeers@chetu.com',
                Amount: '10.00',
                CardType: 'Visa',
                CVData: '123',
                IndustryType: 'Ecommerce',
                Track2Data: '4012000033330026=09041011000012345678',
                EntryMode: 'TrackDataFromMSR'
            }
        )
        puts @response  # show all the response data, if any error is raised also show errors.
```

#### Authorize without Token Transaction:
Here we pass the address and credit card details, and industry type.

```ruby
        @response = req.authorize(
            {
                Street1: '4 corporate sq',
                City: 'dever',
                CountryCode: 'USA',
                PostalCode: '30329',
                Phone: '9540123123',
                Email: 'najeers@chetu.com',
                IndustryType: 'Ecommerce'
                InvoiceNumber: '802',
                OrderNumber: '629203',
                Amount: '10.00',
                CardType: 'Visa',
                CVData: '123',
                PAN: '4012888812348882',
                Expire: '0320',
                EntryMode: 'Keyed'
            }
        )
```

                OR

```ruby
        @response = req.authorize(
            {
                Street1: '4 corporate sq',
                City: 'dever',
                CountryCode: 'USA',
                PostalCode: '30329',
                Phone: '9540123123',
                Email: 'najeers@chetu.com',
                IndustryType: 'Ecommerce'
                InvoiceNumber: '802',
                OrderNumber: '629203',
                Amount: '10.00',
                CardType: 'Visa',
                CVData: '123',
                Track1Data: '%B4012000033330026^NAJEER/SHAIK ^0904101100001100000000123456780?',
                EntryMode: 'TrackDataFromMSR'
            }
        )
```

                OR

```ruby
        @response = req.authorize(
            {
                Street1: '4 corporate sq',
                City: 'dever',
                CountryCode: 'USA',
                PostalCode: '30329',
                Phone: '9540123123',
                Email: 'najeers@chetu.com',
                IndustryType: 'Ecommerce'
                InvoiceNumber: '802',
                OrderNumber: '629203',
                Amount: '10.00',
                CardType: 'Visa',
                CVData: '123',
                Track2Data: '4012000033330026=09041011000012345678',
                EntryMode: 'TrackDataFromMSR'
            }
        )
        puts @response   # show all the response data, if any error is raised also show errors.
```

#### Authorize with Token Transaction:
Here we pass the address details, industry type, and also pass the payment account data token.

```ruby
        @response = req.authorize(
            {
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
            }
        )
        puts @response   # show all the response data, if any error is raised also show errors.
```

#### P2PE transaction for Authorize:
Here we pass the address details, industry type, and also pass card swipe data.

```ruby
        @response = req.authorize(
            {
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
            }
        )
        puts @response   # show all the response data, if any error is raised also show errors.
```

#### AuthorizeAndCapture without Token Transaction:
Here we pass the address and credit card details, and industry type.

```ruby
        @response = req.authorizeAndCapture(
            {
                Street1: '4 corporate sq',
                City: 'dever',
                CountryCode: 'USA',
                PostalCode: '30329',
                Phone: '9540123123',
                Email: 'najeers@chetu.com',
                IndustryType: 'Ecommerce'
                InvoiceNumber: '802',
                OrderNumber: '629203',
                Amount: '10.00',
                CardType: 'Visa',
                CVData: '123',
                PAN: '4012888812348882',
                Expire: '0320',
                EntryMode: 'Keyed'
            }
        )
```

                OR

```ruby
        @response = req.authorizeAndCapture(
            {
                Street1: '4 corporate sq',
                City: 'dever',
                CountryCode: 'USA',
                PostalCode: '30329',
                Phone: '9540123123',
                Email: 'najeers@chetu.com',
                IndustryType: 'Ecommerce'
                InvoiceNumber: '802',
                OrderNumber: '629203',
                Amount: '10.00',
                CardType: 'Visa',
                CVData: '123',
                Track1Data: '%B4012000033330026^NAJEER/SHAIK ^0904101100001100000000123456780?',
                EntryMode: 'TrackDataFromMSR'
            }
        )
```

                OR

```ruby
        @response = req.authorizeAndCapture(
            {
                Street1: '4 corporate sq',
                City: 'dever',
                CountryCode: 'USA',
                PostalCode: '30329',
                Phone: '9540123123',
                Email: 'najeers@chetu.com',
                IndustryType: 'Ecommerce'
                InvoiceNumber: '802',
                OrderNumber: '629203',
                Amount: '10.00',
                CardType: 'Visa',
                CVData: '123',
                Track2Data: '4012000033330026=09041011000012345678',
                EntryMode: 'TrackDataFromMSR'
            }
        )
        puts @response   # show all the response data, if any error is raised also show errors.
```

#### AuthorizeAndCapture with Token Transaction:
Here we pass the address details, industry type, and also pass the payment account data token.

```ruby
        @response = req.authorizeAndCapture(
            {
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
            }
        )
        puts @response   # show all the response data, if any error is raised also show errors.
```

#### P2PE transaction for AuthorizeAndCapture:
Here we pass the address details, industry type, and also pass card swipe data.

```ruby
        @response = req.authorizeAndCapture(
            {
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
            }
        )
        puts @response   # show all the response data, if any error is raised also show errors.
```

#### Capture Transaction:
Here we pass the Transaction Id and Amount.

```ruby
        @response = req.capture(
            {
                TransactionId: '      ',
                Amount: '10.00'
            }
        )
        puts @response   # show all the response data, if any error is raised also show errors.
```

#### Capture All Transaction:
Here we pass the Transaction Ids and Amounts.

```ruby
        @response = req.captureAll(
            {
                TransactionId: '      ',
                Amount: '10.00'
            }
        )
        puts @response   # show all the response data, if any error is raised also show errors.
```

#### Void(Undo) Transaction:
Here we pass the Transaction Id only.

```ruby
        @response = req.undo(
            {
                TransactionId: '      '
            }
        )
        puts @response   # show all the response data, if any error is raised also show errors.
```

#### Adjust Transaction:
Here we pass the Transaction Id and adjusted Amount.

```ruby
        @response = req.adjust(
            {
                TransactionId: '    ',
                Amount: '10.00'
            }
        )
        puts @response   # show all the response data, if any error is raised also show errors.
```

#### ReturnById Transaction:
Here we pass the Transaction Id and Amount.

```ruby
        @response = req.returnById(
            {
                TransactionId: '      ',
                Amount: '10.00'
            }
        )
        puts @response   # show all the response data, if any error is raised also show errors.
```

#### ReturnUnlinked without Token Transaction:
Here we pass the address, industry type, credit card details or Track1Data or Track2Data.

```ruby
        @response = req.returnUnlinked(
            {
                Street1: '4 corporate sq',
                City: 'dever',
                CountryCode: 'USA',
                PostalCode: '30329',
                Phone: '9540123123',
                Email: 'najeers@chetu.com',
                IndustryType: 'Ecommerce'
                InvoiceNumber: '802',
                OrderNumber: '629203',
                Amount: '10.00',
                CardType: 'Visa',
                CVData: '123',
                PAN: '4012888812348882',
                Expire: '0320',
                EntryMode: 'Keyed'
            }
        )
```

                OR
```ruby
        @response = req.returnUnlinked(
            {
                Street1: '4 corporate sq',
                City: 'dever',
                CountryCode: 'USA',
                PostalCode: '30329',
                Phone: '9540123123',
                Email: 'najeers@chetu.com',
                IndustryType: 'Ecommerce'
                InvoiceNumber: '802',
                OrderNumber: '629203',
                Amount: '10.00',
                CardType: 'Visa',
                CVData: '123',
                Track1Data: '%B4012000033330026^NAJEER/SHAIK ^0904101100001100000000123456780?',
                EntryMode: 'TrackDataFromMSR'
            }
        )
```

                OR
```ruby
        @response = req.returnUnlinked(
            {
                Street1: '4 corporate sq',
                City: 'dever',
                CountryCode: 'USA',
                PostalCode: '30329',
                Phone: '9540123123',
                Email: 'najeers@chetu.com',
                IndustryType: 'Ecommerce'
                InvoiceNumber: '802',
                OrderNumber: '629203',
                Amount: '10.00',
                CardType: 'Visa',
                CVData: '123',
                Track2Data: '4012000033330026=09041011000012345678',
                EntryMode: 'TrackDataFromMSR'
            }
        )
        puts @response   # show all the response data, if any error is raised also show errors.
```

#### ReturnUnlinked with Token Transaction:
Here we pass the address details, industry type, and also pass the payment account data token.

```ruby
        @response = req.returnUnlinked(
            {
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
            }
        )
        puts @response   # show all the response data, if any error is raised also show errors.
```

#### P2PE transaction for ReturnUnlinked:
Here we pass the address details, industry type, and also pass card swipe data.

```ruby
        @response = req.returnUnlinked(
            {
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
            }
        )
        puts @response   # show all the response data, if any error is raised also show errors.
```

#### QueryTransactionsDetail Transaction:
Here we pass the Batch id or TransactionId or TransactionDateRanges.

```ruby
        @response = req.queryTransactionsDetail(
            {
                BatchIds: '0620',
                TransactionIds: 'C37A4ACDCA1340E2B458FBA7CDA76785',
                EndDateTime: '2015-03-17 02:03:40',
                StartDateTime: '2015-03-13 02:03:40'
            }
        )
        puts @response   # show all the response data, if any error is raised also show errors.
```
