require 'nokogiri'
require 'rexml/document'
require 'json'
require_relative "velocity_processor"
require_relative "velocity_exception"
require_relative "velocity_connection"
include Velocity::VelocityException::VelocityErrors
include Velocity::VelocityException::VelocityErrorMessages

module Velocity
  class VelocityXmlCreator
    attr_accessor :merchant_profile_id, :application_profile_id

    def initialize(application_profile_id,merchant_profile_id)
      @application_profile_id = application_profile_id
      @merchant_profile_id = merchant_profile_id
    end

    def application_profile_id
      @application_profile_id
    end
    
    def merchant_profile_id
      @merchant_profile_id
    end
    
   # Create verify xml as per the api format .
   # "params" is collection key-values, in this "params" holds CardData, AVSData, Amount. 
   # It returns xml format in string.

    def verifyXML(params)
      begin
        Nokogiri::XML::Builder.new do |xml|
          xml.AuthorizeTransaction('xmlns:i' => 'http://www.w3.org/2001/XMLSchema-instance',
           'xmlns' => 'http://schemas.ipcommerce.com/CWS/v2.0/Transactions/Rest',
           'i:type' =>"AuthorizeTransaction" ) {
            xml.ApplicationProfileId application_profile_id #'14560'
            xml.MerchantProfileId merchant_profile_id #'PrestaShop Global HC'
            xml.Transaction('xmlns:ns1' => "http://schemas.ipcommerce.com/CWS/v2.0/Transactions/Bankcard",
             'i:type' => "ns1:BankcardTransaction" ){
              xml['ns1'].TenderData{
                xml['ns1'].CardData{
                  xml['ns1'].CardType params[:CardType]
                  xml['ns1'].CardholderName params[:CardholderName]
                  # xml['ns1'].PAN params[:PAN] #'4111111111111111'
                  # xml['ns1'].Expire params[:Expire]
                  # xml['ns1'].Track1Data('i:nil' =>"true")
                  if params[:Track2Data].present?
                    xml['ns1'].Track2Data params[:Track2Data]
                    xml['ns1'].PAN('i:nil' =>"true") 
                    xml['ns1'].Expire('i:nil' =>"true")
                    xml['ns1'].Track1Data('i:nil' =>"true")
                  elsif params[:Track1Data].present?
                    xml['ns1'].Track1Data params[:Track1Data]
                    xml['ns1'].PAN('i:nil' =>"true") 
                    xml['ns1'].Expire('i:nil' =>"true")
                    xml['ns1'].Track2Data('i:nil' =>"true")
                  else
                    xml['ns1'].PAN params[:PAN] 
                    xml['ns1'].Expire params[:Expire]
                    xml['ns1'].Track1Data('i:nil' =>"true")
                    xml['ns1'].Track2Data('i:nil' =>"true")
                  end
                }
                xml['ns1'].CardSecurityData{
                  xml['ns1'].AVSData{
                    xml['ns1'].CardholderName('i:nil' =>"true") 
                    xml['ns1'].Street params[:Street]
                    xml['ns1'].City params[:City]
                    xml['ns1'].StateProvince params[:StateProvince]
                    xml['ns1'].PostalCode params[:PostalCode]
                    xml['ns1'].Phone params[:Phone]
                    xml['ns1'].Email params[:Email]
                  }
                  xml['ns1'].CVDataProvided 'Provided'
                  xml['ns1'].CVData params[:CVData]
                  xml['ns1'].KeySerialNumber('i:nil' =>"true")
                  xml['ns1'].PIN('i:nil' =>"true") 
                  xml['ns1'].IdentificationInformation('i:nil' =>"true")
                }
                xml['ns1'].EcommerceSecurityData('i:nil' =>"true")
              }
              xml['ns1'].TransactionData{
                if params[:Amount] != ''
                  xml['ns8'].Amount('xmlns:ns8' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text(params[:Amount])
                else
                  xml['ns8'].Amount('xmlns:ns8' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text('0.00')
                end
                xml['ns9'].CurrencyCode('xmlns:ns9' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text('USD')
                xml['ns10'].TransactionDateTime('xmlns:ns10' =>
                                                "http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text('2014-04-03T13:50:16') 
                xml['ns1'].AccountType 'NotSet'
                xml['ns1'].CustomerPresent 'Present'
                xml['ns1'].EmployeeId '11'
                if params[:Track2Data].present? || params[:Track1Data].present?
                  xml['ns1'].EntryMode params[:EntryMode]
                else
                  xml['ns1'].EntryMode 'Keyed'
                end  
                xml['ns1'].IndustryType params[:IndustryType]
                xml['ns1'].InvoiceNumber('i:nil' =>"true")
                xml['ns1'].OrderNumber('i:nil' =>"true")
                xml['ns1'].TipAmount '0.0'
              }       
            }
          }
        end.to_xml
      rescue Exception => ex
        return "Some value not set in xml for verifyXML!"
      end
    end

  # Create Authorize xml as per the api format .
  # "params" is collection key-values, in this "params" holds CardData, AVSData, Amount, P2PETransactionData,PaymentAccountDataToken. 
  # It returns xml format in string.

    def authorizeXML(params)  
      begin
        Nokogiri::XML::Builder.new do |xml|
          xml.AuthorizeTransaction('xmlns:i' => 'http://www.w3.org/2001/XMLSchema-instance', 
                        'xmlns' => 'http://schemas.ipcommerce.com/CWS/v2.0/Transactions/Rest',
                        'i:type' =>"AuthorizeTransaction" ) {
            xml.ApplicationProfileId application_profile_id
            xml.MerchantProfileId merchant_profile_id
            xml.Transaction('xmlns:ns1' => "http://schemas.ipcommerce.com/CWS/v2.0/Transactions/Bankcard",
            'i:type' => "ns1:BankcardTransaction" ){
              xml['ns1'].TenderData{
              if params[:SwipeStatus].present? && params[:IdentificationInformation].present? && params[:SecurePaymentAccountData].present? && params[:EncryptionKeyId].present?
                #p "Swipe card..maga..."
                 xml['ns5'].SecurePaymentAccountData('xmlns:ns5' =>
                                "http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text(params[:SecurePaymentAccountData])
                 xml['ns6'].EncryptionKeyId('xmlns:ns6' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text(params[:EncryptionKeyId])
                 xml['ns7'].SwipeStatus('xmlns:ns7' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text(params[:SwipeStatus])
                 xml['ns1'].CardSecurityData{
                  xml['ns1'].IdentificationInformation params[:IdentificationInformation]
                 }
                 xml['ns1'].CardData('i:nil' =>"true")
              elsif params[:SecurePaymentAccountData].present? || params[:EncryptionKeyId].present? 
                #p "Swipe card..Dukp..."
                 xml['ns5'].SecurePaymentAccountData('xmlns:ns5' =>
                               "http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text(params[:SecurePaymentAccountData])
                 xml['ns6'].EncryptionKeyId('xmlns:ns6' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text(params[:EncryptionKeyId])
                 xml['ns7'].SwipeStatus('xmlns:ns7' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions",'i:nil' =>"true") 
                 xml['ns1'].CardSecurityData{
                  xml['ns1'].IdentificationInformation('i:nil' =>"true")
                 }
                 xml['ns1'].CardData('i:nil' =>"true")
                 xml['ns1'].EcommerceSecurityData('i:nil' =>"true")   
              elsif params[:PaymentAccountDataToken].present?
                #p "PaymentAccountDataToken..........."
                xml['ns4'].PaymentAccountDataToken('xmlns:ns4' =>
                                "http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text(params[:PaymentAccountDataToken])
                xml['ns5'].SecurePaymentAccountData('xmlns:ns5' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions",'i:nil' =>"true")
                xml['ns6'].EncryptionKeyId('xmlns:ns6' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions",'i:nil' =>"true")
                xml['ns7'].SwipeStatus('xmlns:ns7' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions",'i:nil' =>"true") 
                xml['ns1'].CardData('i:nil' =>"true")
                xml['ns1'].EcommerceSecurityData('i:nil' =>"true")           
              else 
                #p "without token...."
                xml['ns4'].PaymentAccountDataToken('xmlns:ns4' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions", 'i:nil' =>"true")
                xml['ns5'].SecurePaymentAccountData('xmlns:ns5' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions",'i:nil' =>"true")
                xml['ns6'].EncryptionKeyId('xmlns:ns6' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions",'i:nil' =>"true")
                xml['ns7'].SwipeStatus('xmlns:ns7' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions",'i:nil' =>"true")
                xml['ns1'].CardData{
                  xml['ns1'].CardType params[:CardType] 
                  if params[:Track2Data].present?
                    xml['ns1'].Track2Data params[:Track2Data]
                    xml['ns1'].PAN('i:nil' =>"true") 
                    xml['ns1'].Expire('i:nil' =>"true")
                    xml['ns1'].Track1Data('i:nil' =>"true")
                  elsif params[:Track1Data].present?
                    xml['ns1'].Track1Data params[:Track1Data]
                    xml['ns1'].PAN('i:nil' =>"true") 
                    xml['ns1'].Expire('i:nil' =>"true")
                    xml['ns1'].Track2Data('i:nil' =>"true")
                  else
                    xml['ns1'].PAN params[:PAN] 
                    xml['ns1'].Expire params[:Expire]
                    xml['ns1'].Track1Data('i:nil' =>"true")
                    xml['ns1'].Track2Data('i:nil' =>"true")
                  end        
                }
                xml['ns1'].EcommerceSecurityData('i:nil' =>"true")             
              end
              }
              xml['ns2'].CustomerData('xmlns:ns2' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions"){
                xml['ns2'].BillingData{
                  xml['ns2'].Name('i:nil' =>"true")
                  xml['ns2'].Address{
                    xml['ns2'].Street1 params[:Street1] 
                    xml['ns2'].Street2('i:nil' =>"true")
                    xml['ns2'].City params[:City] 
                    xml['ns2'].StateProvince params[:StateProvince]
                    xml['ns2'].PostalCode params[:PostalCode]
                    xml['ns2'].CountryCode params[:CountryCode]
                  }
                  xml['ns2'].BusinessName 'MomCorp'
                  xml['ns2'].Phone params[:Phone]
                  xml['ns2'].Fax('i:nil' =>"true")
                  xml['ns2'].Email params[:Email]
                }
                xml['ns2'].CustomerId 'cust123'
                xml['ns2'].CustomerTaxId('i:nil' =>"true")
                xml['ns2'].ShippingData('i:nil' =>"true")
              }
              xml['ns3'].ReportingData('xmlns:ns3' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions"){
                xml['ns3'].Comment 'a test comment'
                xml['ns3'].Description 'a test description'
                xml['ns3'].Reference '001'
              }
              xml['ns1'].TransactionData{
                if params[:Amount] != ''
                  xml['ns8'].Amount('xmlns:ns8' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text(params[:Amount])
                else
                  xml['ns8'].Amount('xmlns:ns8' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text('0.00')
                end
                #xml['ns8'].Amount('xmlns:ns8' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text(params[:Amount])
                xml['ns9'].CurrencyCode('xmlns:ns9' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text('USD') 
                xml['ns10'].TransactionDateTime('xmlns:ns10' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text('2013-04-03T13:50:16')
                xml['ns11'].CampaignId('xmlns:ns11' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions",'i:nil' =>"true")
                xml['ns12'].Reference('xmlns:ns12' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text('xyt')
                xml['ns1'].AccountType 'NotSet'
                xml['ns1'].ApprovalCode('i:nil' =>"true")
                xml['ns1'].CashBackAmount '0.0'
                xml['ns1'].CustomerPresent 'Present'
                xml['ns1'].EmployeeId '11'
                xml['ns1'].EntryMode params[:EntryMode]
                xml['ns1'].GoodsType 'NotSet'
                xml['ns1'].IndustryType params[:IndustryType]
                xml['ns1'].InternetTransactionData('i:nil' =>"true")
                xml['ns1'].InvoiceNumber params[:InvoiceNumber]
                xml['ns1'].OrderNumber params[:OrderNumber]
                xml['ns1'].IsPartialShipment 'false'
                xml['ns1'].SignatureCaptured 'false'
                xml['ns1'].FeeAmount '0.0'
                xml['ns1'].TerminalId('i:nil' =>"true")
                xml['ns1'].LaneId('i:nil' =>"true")
                xml['ns1'].TipAmount '0.0'
                xml['ns1'].BatchAssignment('i:nil' =>"true")
                xml['ns1'].PartialApprovalCapable 'NotSet'
                xml['ns1'].ScoreThreshold('i:nil' =>"true")
                xml['ns1'].IsQuasiCash 'false' 
              }
            }
          }     
        end.to_xml 
      rescue Exception => ex
        return "Some value not set in xml for authorizeXML!"
      end
    end

  # Create AuthorizeCapture xml as per the api format .
  # "params" is collection key-values, in this "params" holds CardData, AVSData, Amount, P2PETransactionData,PaymentAccountDataToken. 
  # It returns xml format in string.

    def authorizeAndCaptureXML(params)
      begin
        Nokogiri::XML::Builder.new do |xml|
          xml.AuthorizeAndCaptureTransaction('xmlns:i' => 'http://www.w3.org/2001/XMLSchema-instance', 
                            'xmlns' => 'http://schemas.ipcommerce.com/CWS/v2.0/Transactions/Rest',
                            'i:type' =>"AuthorizeAndCaptureTransaction" ) {
            xml.ApplicationProfileId application_profile_id
            xml.MerchantProfileId merchant_profile_id 
            xml.Transaction('xmlns:ns1' => "http://schemas.ipcommerce.com/CWS/v2.0/Transactions/Bankcard", 
                            'i:type' => "ns1:BankcardTransaction" ){
              xml['ns1'].TenderData{
              if params[:SwipeStatus].present? && params[:IdentificationInformation].present? && params[:SecurePaymentAccountData].present? && params[:EncryptionKeyId].present?
                #p "Swipe card..maga..."
                 xml['ns5'].SecurePaymentAccountData('xmlns:ns5' =>
                                    "http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text(params[:SecurePaymentAccountData])
                 xml['ns6'].EncryptionKeyId('xmlns:ns6' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text(params[:EncryptionKeyId])
                 xml['ns7'].SwipeStatus('xmlns:ns7' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text(params[:SwipeStatus])
                 xml['ns1'].CardSecurityData{
                  xml['ns1'].IdentificationInformation params[:IdentificationInformation]
                 }
                 xml['ns1'].CardData('i:nil' =>"true")
              elsif params[:SecurePaymentAccountData].present? && params[:EncryptionKeyId].present? 
                #p "Swipe card..Dukp..."
                 xml['ns5'].SecurePaymentAccountData('xmlns:ns5' =>
                                      "http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text(params[:SecurePaymentAccountData])
                 xml['ns6'].EncryptionKeyId('xmlns:ns6' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text(params[:EncryptionKeyId])
                 xml['ns7'].SwipeStatus('xmlns:ns7' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions",'i:nil' =>"true") 
                 xml['ns1'].CardSecurityData{
                  xml['ns1'].IdentificationInformation('i:nil' =>"true")
                 }
                 xml['ns1'].CardData('i:nil' =>"true")
                 xml['ns1'].EcommerceSecurityData('i:nil' =>"true")   
              elsif params[:PaymentAccountDataToken].present?
                #p "PaymentAccountDataToken..........."
                xml['ns4'].PaymentAccountDataToken('xmlns:ns4' =>
                                        "http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text(params[:PaymentAccountDataToken])
                xml['ns5'].SecurePaymentAccountData('xmlns:ns5' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions",'i:nil' =>"true")
                xml['ns6'].EncryptionKeyId('xmlns:ns6' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions",'i:nil' =>"true")
                xml['ns7'].SwipeStatus('xmlns:ns7' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions",'i:nil' =>"true") 
                xml['ns1'].CardData('i:nil' =>"true")
                xml['ns1'].EcommerceSecurityData('i:nil' =>"true")           
              else 
                #p "without token...."
                xml['ns4'].PaymentAccountDataToken('xmlns:ns4' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions", 'i:nil' =>"true")
                xml['ns5'].SecurePaymentAccountData('xmlns:ns5' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions",'i:nil' =>"true")
                xml['ns6'].EncryptionKeyId('xmlns:ns6' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions",'i:nil' =>"true")
                xml['ns7'].SwipeStatus('xmlns:ns7' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions",'i:nil' =>"true")
                xml['ns1'].CardData{
                  xml['ns1'].CardType params[:CardType]    
                  if params[:Track2Data].present?
                    xml['ns1'].Track2Data params[:Track2Data]
                    xml['ns1'].PAN('i:nil' =>"true") 
                    xml['ns1'].Expire('i:nil' =>"true")
                    xml['ns1'].Track1Data('i:nil' =>"true")
                  elsif params[:Track1Data].present?
                    xml['ns1'].Track1Data params[:Track1Data]
                    xml['ns1'].PAN('i:nil' =>"true") 
                    xml['ns1'].Expire('i:nil' =>"true")
                    xml['ns1'].Track2Data('i:nil' =>"true")
                  else
                    xml['ns1'].PAN params[:PAN] 
                    xml['ns1'].Expire params[:Expire]
                    xml['ns1'].Track1Data('i:nil' =>"true")
                    xml['ns1'].Track2Data('i:nil' =>"true")
                  end
                }
                xml['ns1'].EcommerceSecurityData('i:nil' =>"true")             
              end
              }
              xml['ns2'].CustomerData('xmlns:ns2' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions"){
                xml['ns2'].BillingData{
                  xml['ns2'].Name('i:nil' =>"true")
                  xml['ns2'].Address{
                    xml['ns2'].Street1 params[:Street1] 
                    xml['ns2'].Street2('i:nil' =>"true")
                    xml['ns2'].City params[:City] 
                    xml['ns2'].StateProvince params[:StateProvince]
                    xml['ns2'].PostalCode params[:PostalCode]
                    xml['ns2'].CountryCode params[:CountryCode]
                  }
                  xml['ns2'].BusinessName 'MomCorp'
                  xml['ns2'].Phone params[:Phone]
                  xml['ns2'].Fax('i:nil' =>"true")
                  xml['ns2'].Email params[:Email]
                }
                xml['ns2'].CustomerId 'cust123'
                xml['ns2'].CustomerTaxId('i:nil' =>"true")
                xml['ns2'].ShippingData('i:nil' =>"true")
              }
              xml['ns3'].ReportingData('xmlns:ns3' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions"){
                xml['ns3'].Comment 'a test comment'
                xml['ns3'].Description 'a test description'
                xml['ns3'].Reference '001'
              }
              xml['ns1'].TransactionData{
                if params[:Amount] != ''
                  xml['ns8'].Amount('xmlns:ns8' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text(params[:Amount])
                else
                  xml['ns8'].Amount('xmlns:ns8' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text('0.00')
                end
                #xml['ns8'].Amount('xmlns:ns8' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text(params[:Amount])
                xml['ns9'].CurrencyCode('xmlns:ns9' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text('USD') 
                xml['ns10'].TransactionDateTime('xmlns:ns10' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text('2013-04-03T13:50:16')
                xml['ns11'].CampaignId('xmlns:ns11' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions",'i:nil' =>"true")
                xml['ns12'].Reference('xmlns:ns12' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text('xyt')
                xml['ns1'].AccountType 'NotSet'
                xml['ns1'].ApprovalCode('i:nil' =>"true")
                xml['ns1'].CashBackAmount '0.0'
                xml['ns1'].CustomerPresent 'Present'
                xml['ns1'].EmployeeId '11'
                xml['ns1'].EntryMode params[:EntryMode]
                xml['ns1'].GoodsType 'NotSet'
                xml['ns1'].IndustryType params[:IndustryType]
                xml['ns1'].InternetTransactionData('i:nil' =>"true")
                xml['ns1'].InvoiceNumber params[:InvoiceNumber]
                xml['ns1'].OrderNumber params[:OrderNumber]
                xml['ns1'].IsPartialShipment 'false'
                xml['ns1'].SignatureCaptured 'false'
                xml['ns1'].FeeAmount '0.0'
                xml['ns1'].TerminalId('i:nil' =>"true")
                xml['ns1'].LaneId('i:nil' =>"true")
                xml['ns1'].TipAmount '0.0'
                xml['ns1'].BatchAssignment('i:nil' =>"true")
                xml['ns1'].PartialApprovalCapable 'NotSet'
                xml['ns1'].ScoreThreshold('i:nil' =>"true")
                xml['ns1'].IsQuasiCash 'false'
              }
            }
          }     
        end.to_xml  
      rescue Exception => ex
        return "Some value not set in xml for authorizeAndCaptureXML!"
      end
    end

  # Create Capture xml as per the api format .
  # "params" is collection key-values, in this "params" holds Amount, TransactionId. 
  # It returns xml format in string.

    def captureXML(params)
      begin
        Nokogiri::XML::Builder.new do |xml|
          xml.ChangeTransaction('xmlns:i' => 'http://www.w3.org/2001/XMLSchema-instance',
           'xmlns' => 'http://schemas.ipcommerce.com/CWS/v2.0/Transactions/Rest',
            'i:type' =>"Capture" ) {
            xml.ApplicationProfileId application_profile_id #'14644'
              xml.DifferenceData('xmlns:d2p1' => 'http://schemas.ipcommerce.com/CWS/v2.0/Transactions',
                  'xmlns:d2p2' => 'http://schemas.ipcommerce.com/CWS/v2.0/Transactions/Bankcard', 
                  'xmlns:d2p3' => 'http://schemas.ipcommerce.com/CWS/v2.0/TransactionProcessing',
                  'i:type' => "d2p2:BankcardCapture"){
              xml['d2p1'].TransactionId params[:TransactionId]#'760CBDD65E4642E49A3CD2E2F3257A10'
              if params[:Amount] != ''
                 xml['d2p2'].Amount params[:Amount]
              else
                 xml['d2p2'].Amount '0.00'
              end 
              xml['d2p2'].TipAmount '0.00' 
            }
          }  
        end.to_xml   
      rescue Exception => ex
        return "transaction id and/or amount not set in xml for captureXML!"
      end   
    end

  # Create Undo xml as per the api format .
  # "params" is collection key-values, in this "params" hold TransactionId. 
  # It returns xml format in string.

    def undoXML(params)
      begin
        Nokogiri::XML::Builder.new do |xml|
          xml.Undo('xmlns:i' => 'http://www.w3.org/2001/XMLSchema-instance', 
              'xmlns' => 'http://schemas.ipcommerce.com/CWS/v2.0/Transactions/Rest', 'i:type' =>"Undo" ) {
             xml.ApplicationProfileId application_profile_id 
             xml.BatchIds('xmlns:d2p1' => 'http://schemas.microsoft.com/2003/10/Serialization/Arrays','i:nil' => "true")
             xml.DifferenceData('xmlns:d2p1' => 'http://schemas.ipcommerce.com/CWS/v2.0/Transactions','i:nil' => "true")
             xml.MerchantProfileId merchant_profile_id 
             xml.TransactionId params[:TransactionId] 
          }
        end.to_xml  
      rescue Exception => ex
        return "transaction id not set in xml for undoXML!"
      end     
    end

  # Create Adjust xml as per the api format .
  # "params" is collection key-values, in this "params" holds adjusted Amount, TransactionId. 
  # It returns xml format in string.

    def adjustXML(params)
      begin
        Nokogiri::XML::Builder.new do |xml|
          xml.Adjust('xmlns:i' => 'http://www.w3.org/2001/XMLSchema-instance',
           'xmlns' => 'http://schemas.ipcommerce.com/CWS/v2.0/Transactions/Rest', 'i:type' =>"Adjust" ) {
            xml.ApplicationProfileId application_profile_id 
            xml.BatchIds('xmlns:d2p1' => 'http://schemas.microsoft.com/2003/10/Serialization/Arrays', 'i:nil'=> "true")
            xml.MerchantProfileId merchant_profile_id
            xml.DifferenceData('xmlns:ns1' => 'http://schemas.ipcommerce.com/CWS/v2.0/Transactions',
                  'xmlns:ns2' => "http://schemas.ipcommerce.com/CWS/v2.0/Transactions",
                  'xmlns:ns3' => "http://schemas.ipcommerce.com/CWS/v2.0/Transactions") {
              if params[:Amount] != ''
                 xml['ns2'].Amount params[:Amount]
              else
                 xml['ns2'].Amount '0.00'
              end 
              xml['ns3'].TransactionId params[:TransactionId]
            }
          }   
        end.to_xml  
      rescue Exception => ex
        return "transaction id and/or amount not set in xml for adjustXML!"
      end   
    end

  # Create ReturnById xml as per the api format .
  # "params" is collection key-values, in this "params" holds Amount, TransactionId. 
  # It returns xml format in string.

    def returnByIdXML(params)
      begin
        Nokogiri::XML::Builder.new do |xml|
          xml.ReturnById('xmlns:i' => 'http://www.w3.org/2001/XMLSchema-instance',
           'xmlns' => 'http://schemas.ipcommerce.com/CWS/v2.0/Transactions/Rest', 'i:type' =>"ReturnById" ) {
            xml.ApplicationProfileId application_profile_id 
            xml.BatchIds('xmlns:d2p1' => 'http://schemas.microsoft.com/2003/10/Serialization/Arrays', 'i:nil' => "true")
            xml.DifferenceData('xmlns:ns1' => 'http://schemas.ipcommerce.com/CWS/v2.0/Transactions/Bankcard', 'i:type' => "ns1:BankcardReturn"){
              xml['ns2'].TransactionId params[:TransactionId] ,'xmlns:ns2' => 'http://schemas.ipcommerce.com/CWS/v2.0/Transactions'
              if params[:Amount] != ''
                 xml['ns1'].Amount params[:Amount]
              else
                 xml['ns1'].Amount '0.00'
              end
            }
            xml.MerchantProfileId merchant_profile_id
          } 
        end.to_xml
      rescue Exception => ex
        return "transaction id and/or amount not set in xml for returnByIdXML!"
      end  
    end
  
  # Create ReturnUnlinked xml as per the api format .
  # "params" is collection key-values, in this "params" holds CardData, AVSData, Amount, P2PETransactionData,PaymentAccountDataToken. 
  # It returns xml format in string.

    def returnUnlinkedXML(params)
      begin
        Nokogiri::XML::Builder.new do |xml|
          xml.ReturnTransaction('xmlns:i' => 'http://www.w3.org/2001/XMLSchema-instance',
           'xmlns' => 'http://schemas.ipcommerce.com/CWS/v2.0/Transactions/Rest', 'i:type' =>"ReturnTransaction" ) {
            xml.ApplicationProfileId application_profile_id 
            xml.BatchIds('xmlns:d2p1' => 'http://schemas.microsoft.com/2003/10/Serialization/Arrays', 'i:nil'=> "true")
            xml.MerchantProfileId merchant_profile_id 
            xml.Transaction('xmlns:ns1' => "http://schemas.ipcommerce.com/CWS/v2.0/Transactions/Bankcard", 'i:type' => "ns1:BankcardTransaction" ){
              xml['ns1'].TenderData{
              if params[:SwipeStatus].present? && params[:IdentificationInformation].present? && params[:SecurePaymentAccountData].present? && params[:EncryptionKeyId].present?
                #p "Swipe card..maga..."
                 xml['ns5'].SecurePaymentAccountData('xmlns:ns5' =>
                                    "http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text(params[:SecurePaymentAccountData])
                 xml['ns6'].EncryptionKeyId('xmlns:ns6' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text(params[:EncryptionKeyId])
                 xml['ns7'].SwipeStatus('xmlns:ns7' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text(params[:SwipeStatus])
                 xml['ns1'].CardSecurityData{
                  xml['ns1'].IdentificationInformation params[:IdentificationInformation]
                 }
                 xml['ns1'].CardData('i:nil' =>"true")
              elsif params[:SecurePaymentAccountData].present? && params[:EncryptionKeyId].present? 
                #p "Swipe card..Dukp..."
                 xml['ns5'].SecurePaymentAccountData('xmlns:ns5' =>
                                      "http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text(params[:SecurePaymentAccountData])
                 xml['ns6'].EncryptionKeyId('xmlns:ns6' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text(params[:EncryptionKeyId])
                 xml['ns7'].SwipeStatus('xmlns:ns7' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions",'i:nil' =>"true") 
                 xml['ns1'].CardSecurityData{
                  xml['ns1'].IdentificationInformation('i:nil' =>"true")
                 }
                 xml['ns1'].CardData('i:nil' =>"true")
                 xml['ns1'].EcommerceSecurityData('i:nil' =>"true")   
              elsif params[:PaymentAccountDataToken].present?
                #p "PaymentAccountDataToken..........."
                xml['ns4'].PaymentAccountDataToken('xmlns:ns4' =>
                                      "http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text(params[:PaymentAccountDataToken])
                xml['ns5'].SecurePaymentAccountData('xmlns:ns5' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions",'i:nil' =>"true")
                xml['ns6'].EncryptionKeyId('xmlns:ns6' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions",'i:nil' =>"true")
                xml['ns7'].SwipeStatus('xmlns:ns7' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions",'i:nil' =>"true") 
                xml['ns1'].CardData('i:nil' =>"true")
                xml['ns1'].EcommerceSecurityData('i:nil' =>"true")           
              else 
                #p "without token...."
                xml['ns4'].PaymentAccountDataToken('xmlns:ns4' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions", 'i:nil' =>"true")
                xml['ns5'].SecurePaymentAccountData('xmlns:ns5' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions",'i:nil' =>"true")
                xml['ns6'].EncryptionKeyId('xmlns:ns6' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions",'i:nil' =>"true")
                xml['ns7'].SwipeStatus('xmlns:ns7' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions",'i:nil' =>"true")
                xml['ns1'].CardData{
                  xml['ns1'].CardType params[:CardType]    
                  if params[:Track2Data].present?
                    xml['ns1'].Track2Data params[:Track2Data]
                    xml['ns1'].PAN('i:nil' =>"true") 
                    xml['ns1'].Expire('i:nil' =>"true")
                    xml['ns1'].Track1Data('i:nil' =>"true")
                  elsif params[:Track1Data].present?
                    xml['ns1'].Track1Data params[:Track1Data]
                    xml['ns1'].PAN('i:nil' =>"true") 
                    xml['ns1'].Expire('i:nil' =>"true")
                    xml['ns1'].Track2Data('i:nil' =>"true")
                  else
                    xml['ns1'].PAN params[:PAN] 
                    xml['ns1'].Expire params[:Expire]
                    xml['ns1'].Track1Data('i:nil' =>"true")
                    xml['ns1'].Track2Data('i:nil' =>"true")
                  end
                }
                xml['ns1'].EcommerceSecurityData('i:nil' =>"true")             
              end
              }
              xml['ns2'].CustomerData('xmlns:ns2' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions"){
                xml['ns2'].BillingData{
                  xml['ns2'].Name('i:nil' =>"true")
                  xml['ns2'].Address{
                    xml['ns2'].Street1 params[:Street1] 
                    xml['ns2'].Street2('i:nil' =>"true")
                    xml['ns2'].City params[:City] 
                    xml['ns2'].StateProvince params[:StateProvince]
                    xml['ns2'].PostalCode params[:PostalCode]
                    xml['ns2'].CountryCode params[:CountryCode]
                  }
                  xml['ns2'].BusinessName 'MomCorp'
                  xml['ns2'].Phone params[:Phone]
                  xml['ns2'].Fax('i:nil' =>"true")
                  xml['ns2'].Email params[:Email]
                }
                xml['ns2'].CustomerId 'cust123'
                xml['ns2'].CustomerTaxId('i:nil' =>"true")
                xml['ns2'].ShippingData('i:nil' =>"true")
              }
              xml['ns3'].ReportingData('xmlns:ns3' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions"){
                xml['ns3'].Comment 'a test comment'
                xml['ns3'].Description 'a test description'
                xml['ns3'].Reference '001'
              }
              xml['ns1'].TransactionData{
                if params[:Amount] != ''
                  xml['ns8'].Amount('xmlns:ns8' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text(params[:Amount])
                else
                  xml['ns8'].Amount('xmlns:ns8' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text('0.00')
                end
                xml['ns9'].CurrencyCode('xmlns:ns9' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text('USD') 
                xml['ns10'].TransactionDateTime('xmlns:ns10' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text('2013-04-03T13:50:16')
                xml['ns11'].CampaignId('xmlns:ns11' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions",'i:nil' =>"true")
                xml['ns12'].Reference('xmlns:ns12' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text('xyt')
                xml['ns1'].AccountType 'NotSet'
                xml['ns1'].ApprovalCode('i:nil' =>"true")
                xml['ns1'].CashBackAmount '0.0'
                xml['ns1'].CustomerPresent 'Present'
                xml['ns1'].EmployeeId '11'
                xml['ns1'].EntryMode params[:EntryMode]
                xml['ns1'].GoodsType 'NotSet'
                xml['ns1'].IndustryType params[:IndustryType]
                xml['ns1'].InternetTransactionData('i:nil' =>"true")
                xml['ns1'].InvoiceNumber params[:InvoiceNumber]
                xml['ns1'].OrderNumber params[:OrderNumber]
                xml['ns1'].IsPartialShipment 'false'
                xml['ns1'].SignatureCaptured 'false'
                xml['ns1'].FeeAmount '0.0'
                xml['ns1'].TerminalId('i:nil' =>"true")
                xml['ns1'].LaneId('i:nil' =>"true")
                xml['ns1'].TipAmount '0.0'
                xml['ns1'].BatchAssignment('i:nil' =>"true")
                xml['ns1'].PartialApprovalCapable 'NotSet'
                xml['ns1'].ScoreThreshold('i:nil' =>"true")
                xml['ns1'].IsQuasiCash 'false' 
              }
            }
          }     
        end.to_xml
      rescue Exception => ex
        return "Some value not set in xml for returnUnlinkedXML!"
      end
    end
  
  # Create CaptureAll xml as per the api format .
  # "params" is collection key-values, in this "params" holds list of Capture transactions. 
  # It returns xml format in string.

    def captureAllXML()
      begin
        Nokogiri::XML::Builder.new do |xml|
          xml.CaptureAll('xmlns:i' => 'http://www.w3.org/2001/XMLSchema-instance', 
                         'xmlns' => 'http://schemas.ipcommerce.com/CWS/v2.0/Transactions/Rest', 'i:type' =>"CaptureAll" ) {
            xml.ApplicationProfileId application_profile_id
            xml.MerchantProfileId merchant_profile_id
            xml.BatchIds('xmlns:d2p1' => 'http://schemas.microsoft.com/2003/10/Serialization/Arrays', 'i:nil'=> "true")
            xml.DifferenceData('xmlns:d2p1' => 'http://schemas.ipcommerce.com/CWS/v2.0/Transactions','i:nil'=> "true")
          }  
        end.to_xml 
      rescue Exception => ex
        return "Some value not set in xml for captureAllXML!"
      end   
    end

  # Create QueryTransactionsDetail JSON as per the api format .
  # "params" is collection key-values, in this "params" holds query information. 
  # It returns JSON format in string.

    def queryTransactionsDetailJSON(params)
      begin
         {  
             :TransactionDetailFormat => 'CWSTransaction',
             :PagingParameters => { 
               :Page => 0, 
               :PageSize => 10
             },
             :QueryTransactionsParameters => { 
                  :Amounts => nil,
                  :ApprovalCodes => nil,
                  :BatchIds => batch_ids(params),
                  :CaptureDateRange =>nil,
                  :CaptureStates => nil,
                  :TransactionIds => mul_trd(params),
                  :MerchantProfileIds => nil,
                  :CardTypes => nil,
                  :IsAcknowledged=> "false",
                  :OrderNumbers => nil,
                  :QueryType => "OR",
                  :ServiceIds => nil,
                  :ServiceKeys => nil,
                  :TransactionClassTypePairs=> nil,
                  :TransactionDateRange=> transaction_date_range(params),
                  :TransactionStates => nil,
             },
             :IncludeRelated => 'false' 
         }.to_json
      rescue Exception => ex
        return "Some value not set in querytransactiondetail, batchid, transactionid or transactiondates!"
      end
    end

    private
    def approval_codes(params)
      if params[:ApprovalCodes].present?
          return params[:ApprovalCodes].split(",")
      else 
          return nil
      end 
    end

    def batch_ids(params)
      if params[:BatchIds].present?
          return params[:BatchIds].split(",")
      else 
          return nil
     end  
    end

    def transaction_date_range(params)
       if params[:EndDateTime].present? && params[:StartDateTime].present?
        {
                    :EndDateTime => end_date_time(params),
                    :StartDateTime => start_date_time(params),
        }
      else
        return nil
      end
    end

    def capture_date_range(params)
     # p params[:EndDateTime1]
        if params[:EndDateTime1].present? && params[:StartDateTime1].present?
        {
                    :EndDateTime1 => end_date_time1(params),
                    :StartDateTime1 => start_date_time1(params),
        }
      else
        return nil
      end
    end

    def end_date_time(params)
      if params[:EndDateTime].present?
          return params[:EndDateTime]
      else 
          return nil
      end
    end
    def start_date_time(params)
      if params[:StartDateTime].present?
          return params[:StartDateTime]
      else 
          return nil
      end
    end
    def end_date_time1(params)
    # p params[:EndDateTime1]
      if params[:EndDateTime1].present?
          return params[:EndDateTime1]
      else 
          return nil
      end
    end
    def start_date_time1(params)
      if params[:StartDateTime1].present?
          return params[:StartDateTime1]
      else 
          return nil
      end
    end

    def capture_states(params)
      if params[:CaptureStates].present?
          return params[:CaptureStates].split(",")
      else 
          return nil
      end
    end

    def mul_trd(params)
      if params[:TransactionIds].present?
          return params[:TransactionIds].split(",")
      else
          return nil
      end
    end

    def mul_amt(params)
      if params[:Amounts].present?
          return params[:Amounts].split(",")
      else
          return nil
      end    
    end
    def mer_pro_ids(params)
      if params[:MerchantProfileIds].present?
        return params[:MerchantProfileIds].split(",")
      else
        return nil
      end
    end
    def card_types(params)
      if params[:CardTypes].present?
        return params[:CardTypes].split(",")
      else
        return nil
      end
    end
    def order_numbers(params)
      if params[:OrderNumbers].present?
        return params[:OrderNumbers].split(",")
      else
        return nil
      end
    end
    def ser_ids(params)
      if params[:ServiceIds].present?
        return params[:ServiceIds].split(",")
      else
        return nil
      end
    end
    def ser_keys(params)
      if params[:ServiceKeys].present?
        return params[:ServiceKeys].split(",")
      else
        return nil
      end
    end
    
    def transaction_states(params)
      if params[:TransactionStates].present?
        return params[:TransactionStates].split(",")
      else
        return nil
      end
    end


  end
end
