require "base64"
require 'nokogiri'
require 'httparty'
require 'rexml/document'
require_relative "velocity_exception"
include Velocity::VelocityException::VelocityErrors
include Velocity::VelocityException::VelocityErrorMessages

module Velocity  
  class Processor
    attr_accessor :session_token, :identity_token, :work_flow_id, :application_profile_id, :merchant_profile_id

    def initialize(identity_token,work_flow_id,application_profile_id,merchant_profile_id)
      @identity_token = identity_token
      @work_flow_id = work_flow_id
      @application_profile_id = application_profile_id
      @merchant_profile_id = merchant_profile_id
    end
    def identity_token
      @identity_token
    end
    def work_flow_id
      @work_flow_id
    end
    def application_profile_id
      @application_profile_id
    end
    def merchant_profile_id
      @merchant_profile_id
    end
    SIGNON_URL = "https://api.cert.nabcommerce.com/REST/2.0.18/SvcInfo/token"
    URL = "https://api.cert.nabcommerce.com/REST/2.0.18/Txn/"
    def sign_on()
      res = HTTParty.get(SIGNON_URL,
       headers: { "Content-Type" => "application/json", "Authorization" => "Basic #{identity_token}"},
       verify: false
      )
     encode_token(res)
    end

    def verify(params)
        response_xml = HTTParty.post(URL+"#{work_flow_id}"+"/"+"verify",
          body: verify_xml(params),
          headers: {"Authorization" => "Basic #{sign_on}"},
          verify: false)
        #errors_exists?(response_xml)  
    end
  
    def authorize(params)
        response_xml = HTTParty.post( URL+"#{work_flow_id}",
          body: authorize_xml(params),
          headers: {"Authorization" => "Basic #{sign_on}"},
          verify: false)
        errors_exists?(response_xml)
    end 

    def authorize_capture(params)
        response_xml = HTTParty.post( URL+"#{work_flow_id}",
          body: authorize_capture_xml(params),
          headers: {"Authorization" => "Basic #{sign_on}"},
          verify: false)
        errors_exists?(response_xml) 
    end

    def capture(params)
        trid = params[:TransactionId].to_s
        response_xml = HTTParty.put( URL+"#{work_flow_id}"+"/"+trid,
          body: capture_xml(params),
          headers: {"Authorization" => "Basic #{sign_on}"},
          verify: false)
        errors_exists?(response_xml)  
    end

    def undo(params)
        trid = params[:TransactionId].to_s
        response_xml = HTTParty.put( URL+"#{work_flow_id}"+"/"+trid,
          body: undo_xml(params),
          headers: {"Authorization" => "Basic #{sign_on}"},
          verify: false)
      errors_exists?(response_xml)
    end 

    def adjust(params)
        trid = params[:TransactionId].to_s
        response_xml = HTTParty.put( URL+"#{work_flow_id}"+"/"+trid,
          body: adjust_xml(params),
          headers: {"Authorization" => "Basic #{sign_on}"},
          verify: false)
        errors_exists?(response_xml)
    end  
    
    def return_by_id(params)
        response_xml = HTTParty.post( URL+"#{work_flow_id}",
          body: return_by_id_xml(params),
          headers: {"Authorization" => "Basic #{sign_on}"},
          verify: false)
        errors_exists?(response_xml)    
    end  

    def return_unlinked(params)
        response_xml = HTTParty.post( URL+"#{work_flow_id}",
          body: return_unlinked_xml(params),
          headers: {"Authorization" => "Basic #{sign_on}"},
          verify: false)
          errors_exists?(response_xml)  
    end 

    def verify_xml(parm)
      #appl_merch_pid_exists?(parm)
      Nokogiri::XML::Builder.new do |xml|
        xml.AuthorizeTransaction('xmlns:i' => 'http://www.w3.org/2001/XMLSchema-instance', 'xmlns' => 'http://schemas.ipcommerce.com/CWS/v2.0/Transactions/Rest', 'i:type' =>"AuthorizeTransaction" ) {
          xml.ApplicationProfileId application_profile_id #'14560'
          xml.MerchantProfileId merchant_profile_id #'PrestaShop Global HC'
          xml.Transaction('xmlns:ns1' => "http://schemas.ipcommerce.com/CWS/v2.0/Transactions/Bankcard", 'i:type' => "ns1:BankcardTransaction" ){
            xml['ns1'].TenderData{
              xml['ns1'].CardData{
                xml['ns1'].CardType parm[:CardType]
                xml['ns1'].CardholderName parm[:CardholderName]
                xml['ns1'].PAN parm[:PAN] #'4111111111111111'
                xml['ns1'].Expire parm[:Expire]
                xml['ns1'].Track1Data('i:nil' =>"true")
              }
              xml['ns1'].CardSecurityData{
                xml['ns1'].AVSData{
                  xml['ns1'].CardholderName('i:nil' =>"true") 
                  xml['ns1'].Street parm[:Street]
                  xml['ns1'].City parm[:City]
                  xml['ns1'].StateProvince parm[:StateProvince]
                  xml['ns1'].PostalCode parm[:PostalCode]
                  xml['ns1'].Phone parm[:Phone]
                  xml['ns1'].Email parm[:Email]
                }
                xml['ns1'].CVDataProvided 'Provided'
                xml['ns1'].CVData parm[:CVData]
                xml['ns1'].KeySerialNumber('i:nil' =>"true")
                xml['ns1'].PIN('i:nil' =>"true") 
                xml['ns1'].IdentificationInformation('i:nil' =>"true")
              }
              xml['ns1'].EcommerceSecurityData('i:nil' =>"true")
            }
            xml['ns1'].TransactionData{
              if parm[:Amount] != ''
                xml['ns8'].Amount('xmlns:ns8' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text(parm[:Amount])
              else
                xml['ns8'].Amount('xmlns:ns8' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text('0.00')
              end
              #xml['ns8'].Amount('xmlns:ns8' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text(parm[:Amount]) 
              xml['ns9'].CurrencyCode('xmlns:ns9' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text('USD')
              xml['ns10'].TransactionDateTime('xmlns:ns10' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text('2014-04-03T13:50:16') 
              xml['ns1'].AccountType 'NotSet'
              xml['ns1'].CustomerPresent 'Present'
              xml['ns1'].EmployeeId '11'
              xml['ns1'].EntryMode 'Keyed'
              xml['ns1'].IndustryType 'Ecommerce'
              xml['ns1'].InvoiceNumber parm[:InvoiceNumber]
              xml['ns1'].OrderNumber parm[:OrderNumber]
              xml['ns1'].TipAmount '0.0'
            }       
          }
        }
      end.to_xml
    end

    def authorize_xml(parm)
      #appl_merch_pid_exists?(parm)
      Nokogiri::XML::Builder.new do |xml|
        xml.AuthorizeTransaction('xmlns:i' => 'http://www.w3.org/2001/XMLSchema-instance', 'xmlns' => 'http://schemas.ipcommerce.com/CWS/v2.0/Transactions/Rest', 'i:type' =>"AuthorizeTransaction" ) {
          xml.ApplicationProfileId application_profile_id
          xml.MerchantProfileId merchant_profile_id
          xml.Transaction('xmlns:ns1' => "http://schemas.ipcommerce.com/CWS/v2.0/Transactions/Bankcard", 'i:type' => "ns1:BankcardTransaction" ){
            xml['ns2'].CustomerData('xmlns:ns2' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions"){
              xml['ns2'].BillingData{
                xml['ns2'].Name('i:nil' =>"true")
                xml['ns2'].Address{
                  xml['ns2'].Street1 parm[:Street1] 
                  xml['ns2'].Street2('i:nil' =>"true")
                  xml['ns2'].City parm[:City] 
                  xml['ns2'].StateProvince parm[:StateProvince]
                  xml['ns2'].PostalCode parm[:PostalCode]
                  xml['ns2'].CountryCode parm[:CountryCode]
                }
                xml['ns2'].BusinessName 'MomCorp'
                xml['ns2'].Phone parm[:Phone]
                xml['ns2'].Fax('i:nil' =>"true")
                xml['ns2'].Email parm[:Email]
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
            xml['ns1'].TenderData{
            if parm[:PaymentAccountDataToken] != ''  
               xml['ns4'].PaymentAccountDataToken('xmlns:ns4' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text(parm[:PaymentAccountDataToken])
            else 
               xml['ns4'].PaymentAccountDataToken('xmlns:ns4' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions", 'i:nil' =>"true")
            end
              xml['ns5'].SecurePaymentAccountData('xmlns:ns5' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions",'i:nil' =>"true")
              xml['ns6'].EncryptionKeyId('xmlns:ns6' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions",'i:nil' =>"true")
              xml['ns7'].SwipeStatus('xmlns:ns7' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions",'i:nil' =>"true")
              xml['ns1'].CardData{
                xml['ns1'].CardType parm[:CardType]    
                xml['ns1'].PAN parm[:PAN] 
                xml['ns1'].Expire parm[:Expire]
                xml['ns1'].Track1Data('i:nil' =>"true")
              }
              xml['ns1'].EcommerceSecurityData('i:nil' =>"true")
            }
            xml['ns1'].TransactionData{
              if parm[:Amount] != ''
                xml['ns8'].Amount('xmlns:ns8' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text(parm[:Amount])
              else
                xml['ns8'].Amount('xmlns:ns8' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text('0.00')
              end
              #xml['ns8'].Amount('xmlns:ns8' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text(parm[:Amount])
              xml['ns9'].CurrencyCode('xmlns:ns9' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text('USD') 
              xml['ns10'].TransactionDateTime('xmlns:ns10' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text('2013-04-03T13:50:16')
              xml['ns11'].CampaignId('xmlns:ns11' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions",'i:nil' =>"true")
              xml['ns12'].Reference('xmlns:ns12' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text('xyt')
              xml['ns1'].AccountType 'NotSet'
              xml['ns1'].ApprovalCode('i:nil' =>"true")
              xml['ns1'].CashBackAmount '0.0'
              xml['ns1'].CustomerPresent 'Present'
              xml['ns1'].EmployeeId '11'
              xml['ns1'].EntryMode 'Keyed'
              xml['ns1'].GoodsType 'NotSet'
              xml['ns1'].IndustryType 'Ecommerce'
              xml['ns1'].InternetTransactionData('i:nil' =>"true")
              xml['ns1'].InvoiceNumber parm[:InvoiceNumber]
              xml['ns1'].OrderNumber parm[:OrderNumber]
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
    end

    def authorize_capture_xml(parm)
      #appl_merch_pid_exists?(parm)
      Nokogiri::XML::Builder.new do |xml|
        xml.AuthorizeAndCaptureTransaction('xmlns:i' => 'http://www.w3.org/2001/XMLSchema-instance', 'xmlns' => 'http://schemas.ipcommerce.com/CWS/v2.0/Transactions/Rest', 'i:type' =>"AuthorizeAndCaptureTransaction" ) {
          xml.ApplicationProfileId application_profile_id
          xml.MerchantProfileId merchant_profile_id 
          xml.Transaction('xmlns:ns1' => "http://schemas.ipcommerce.com/CWS/v2.0/Transactions/Bankcard", 'i:type' => "ns1:BankcardTransaction" ){
            xml['ns2'].CustomerData('xmlns:ns2' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions"){
              xml['ns2'].BillingData{
                xml['ns2'].Name('i:nil' =>"true")
                xml['ns2'].Address{
                  xml['ns2'].Street1 parm[:Street1]  
                  xml['ns2'].Street2('i:nil' =>"true")
                  xml['ns2'].City parm[:City]
                  xml['ns2'].StateProvince parm[:StateProvince]
                  xml['ns2'].PostalCode parm[:PostalCode]
                  xml['ns2'].CountryCode parm[:CountryCode]
                }
                xml['ns2'].BusinessName 'MomCorp'
                xml['ns2'].Phone('i:nil' =>"true")
                xml['ns2'].Fax('i:nil' =>"true")
                xml['ns2'].Email('i:nil' =>"true")
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
            xml['ns1'].TenderData{
            if parm[:PaymentAccountDataToken] != ''  
               xml['ns4'].PaymentAccountDataToken('xmlns:ns4' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text(parm[:PaymentAccountDataToken])
            else 
               xml['ns4'].PaymentAccountDataToken('xmlns:ns4' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions", 'i:nil' =>"true")
            end
              xml['ns5'].SecurePaymentAccountData('xmlns:ns5' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions",'i:nil' =>"true")
              xml['ns6'].EncryptionKeyId('xmlns:ns6' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions",'i:nil' =>"true")
              xml['ns7'].SwipeStatus('xmlns:ns7' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions",'i:nil' =>"true")
              xml['ns1'].CardData{
                xml['ns1'].CardType parm[:CardType]    
                xml['ns1'].PAN parm[:PAN]
                xml['ns1'].Expire parm[:Expire] 
                xml['ns1'].Track1Data('i:nil' =>"true")
              }
              xml['ns1'].EcommerceSecurityData('i:nil' =>"true")
            }
            xml['ns1'].TransactionData{
              if parm[:Amount] != ''
                xml['ns8'].Amount('xmlns:ns8' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text(parm[:Amount])
              else
                xml['ns8'].Amount('xmlns:ns8' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text('0.00')
              end
              #xml['ns8'].Amount('xmlns:ns8' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text(parm[:Amount])
              xml['ns9'].CurrencyCode('xmlns:ns9' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text('USD') 
              xml['ns10'].TransactionDateTime('xmlns:ns10' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text('2013-04-03T13:50:16')
              xml['ns11'].CampaignId('xmlns:ns11' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions",'i:nil' =>"true")
              xml['ns12'].Reference('xmlns:ns12' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text('xyt')
              xml['ns1'].AccountType 'NotSet'
              xml['ns1'].ApprovalCode('i:nil' =>"true")
              xml['ns1'].CashBackAmount '0.0'
              xml['ns1'].CustomerPresent 'Present'
              xml['ns1'].EmployeeId '11'
              xml['ns1'].EntryMode 'Keyed'
              xml['ns1'].GoodsType 'NotSet'
              xml['ns1'].IndustryType 'Ecommerce'
              xml['ns1'].InternetTransactionData('i:nil' =>"true")
              xml['ns1'].InvoiceNumber parm[:InvoiceNumber]
              xml['ns1'].OrderNumber parm[:OrderNumber]
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
    end

    def capture_xml(parm)
      #appl_merch_pid_exists?(parm)
      Nokogiri::XML::Builder.new do |xml|
        xml.ChangeTransaction('xmlns:i' => 'http://www.w3.org/2001/XMLSchema-instance', 'xmlns' => 'http://schemas.ipcommerce.com/CWS/v2.0/Transactions/Rest', 'i:type' =>"Capture" ) {
          xml.ApplicationProfileId application_profile_id #'14644'
            xml.DifferenceData('xmlns:d2p1' => 'http://schemas.ipcommerce.com/CWS/v2.0/Transactions', 'xmlns:d2p2' => 'http://schemas.ipcommerce.com/CWS/v2.0/Transactions/Bankcard', 'xmlns:d2p3' => 'http://schemas.ipcommerce.com/CWS/v2.0/TransactionProcessing','i:type' => "d2p2:BankcardCapture"){
            xml['d2p1'].TransactionId parm[:TransactionId]#'760CBDD65E4642E49A3CD2E2F3257A10'
            if parm[:Amount] != ''
               xml['d2p2'].Amount parm[:Amount]
            else
               xml['d2p2'].Amount '0.00'
            end 
            xml['d2p2'].TipAmount '0.00' 
          }
        }  
      end.to_xml   
    end

    def undo_xml(parm)
      #appl_merch_pid_exists?(parm)
      Nokogiri::XML::Builder.new do |xml|
         xml.Undo('xmlns:i' => 'http://www.w3.org/2001/XMLSchema-instance', 'xmlns' => 'http://schemas.ipcommerce.com/CWS/v2.0/Transactions/Rest', 'i:type' =>"Undo" ) {
           xml.ApplicationProfileId application_profile_id 
           xml.BatchIds('xmlns:d2p1' => 'http://schemas.microsoft.com/2003/10/Serialization/Arrays','i:nil' => "true")
           xml.DifferenceData('xmlns:d2p1' => 'http://schemas.ipcommerce.com/CWS/v2.0/Transactions','i:nil' => "true")
           xml.MerchantProfileId merchant_profile_id 
           xml.TransactionId parm[:TransactionId] 
         }
      end.to_xml     
    end

    def adjust_xml(parm)
      #appl_merch_pid_exists?(parm)
      Nokogiri::XML::Builder.new do |xml|
         xml.Adjust('xmlns:i' => 'http://www.w3.org/2001/XMLSchema-instance', 'xmlns' => 'http://schemas.ipcommerce.com/CWS/v2.0/Transactions/Rest', 'i:type' =>"Adjust" ) {
          xml.ApplicationProfileId application_profile_id 
          xml.BatchIds('xmlns:d2p1' => 'http://schemas.microsoft.com/2003/10/Serialization/Arrays', 'i:nil'=> "true")
          xml.MerchantProfileId merchant_profile_id
          xml.DifferenceData('xmlns:ns1' => 'http://schemas.ipcommerce.com/CWS/v2.0/Transactions', 'xmlns:ns2' => "http://schemas.ipcommerce.com/CWS/v2.0/Transactions", 'xmlns:ns3' => "http://schemas.ipcommerce.com/CWS/v2.0/Transactions") {
            if parm[:Amount] != ''
               xml['ns2'].Amount parm[:Amount]
            else
               xml['ns2'].Amount '0.00'
            end 
            xml['ns3'].TransactionId parm[:TransactionId]
          }
         }   
      end.to_xml   
    end

    def return_by_id_xml(parm)
      #appl_merch_pid_exists?(parm)
      Nokogiri::XML::Builder.new do |xml|
        xml.ReturnById('xmlns:i' => 'http://www.w3.org/2001/XMLSchema-instance', 'xmlns' => 'http://schemas.ipcommerce.com/CWS/v2.0/Transactions/Rest', 'i:type' =>"ReturnById" ) {
          xml.ApplicationProfileId application_profile_id 
          xml.BatchIds('xmlns:d2p1' => 'http://schemas.microsoft.com/2003/10/Serialization/Arrays', 'i:nil' => "true")
          xml.DifferenceData('xmlns:ns1' => 'http://schemas.ipcommerce.com/CWS/v2.0/Transactions/Bankcard', 'i:type' => "ns1:BankcardReturn"){
            xml['ns2'].TransactionId parm[:TransactionId] ,'xmlns:ns2' => 'http://schemas.ipcommerce.com/CWS/v2.0/Transactions'
            if parm[:Amount] != ''
               xml['ns1'].Amount parm[:Amount]
            else
               xml['ns1'].Amount '0.00'
            end
          }
          xml.MerchantProfileId merchant_profile_id
        } 
      end.to_xml
         
    end

    def return_unlinked_xml(parm)
      #appl_merch_pid_exists?(parm)
      Nokogiri::XML::Builder.new do |xml|
        xml.ReturnTransaction('xmlns:i' => 'http://www.w3.org/2001/XMLSchema-instance', 'xmlns' => 'http://schemas.ipcommerce.com/CWS/v2.0/Transactions/Rest', 'i:type' =>"ReturnTransaction" ) {
          xml.ApplicationProfileId application_profile_id 
          xml.BatchIds('xmlns:d2p1' => 'http://schemas.microsoft.com/2003/10/Serialization/Arrays', 'i:nil'=> "true")
          xml.MerchantProfileId merchant_profile_id 
          xml.Transaction('xmlns:ns1' => "http://schemas.ipcommerce.com/CWS/v2.0/Transactions/Bankcard", 'i:type' => "ns1:BankcardTransaction" ){
            xml['ns2'].CustomerData('xmlns:ns2' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions"){
              xml['ns2'].BillingData{
                xml['ns2'].Name('i:nil' =>"true")
                xml['ns2'].Address{
                  xml['ns2'].Street1 parm[:Street1] 
                  xml['ns2'].Street2('i:nil' =>"true")
                  xml['ns2'].City parm[:City] 
                  xml['ns2'].StateProvince parm[:StateProvince]
                  xml['ns2'].PostalCode parm[:PostalCode]
                  xml['ns2'].CountryCode parm[:CountryCode]
                }
                xml['ns2'].BusinessName 'MomCorp'
                xml['ns2'].Phone parm[:Phone]
                xml['ns2'].Fax('i:nil' =>"true")
                xml['ns2'].Email parm[:Email]
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
            xml['ns1'].TenderData{
              if parm[:PaymentAccountDataToken] != ''  
                    xml['ns4'].PaymentAccountDataToken('xmlns:ns4' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text(parm[:PaymentAccountDataToken])
              else 
                    xml['ns4'].PaymentAccountDataToken('xmlns:ns4' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions", 'i:nil' =>"true")
              end
              xml['ns5'].SecurePaymentAccountData('xmlns:ns5' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions",'i:nil' =>"true")
              xml['ns6'].EncryptionKeyId('xmlns:ns6' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions",'i:nil' =>"true")
              xml['ns7'].SwipeStatus('xmlns:ns7' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions",'i:nil' =>"true")
              xml['ns1'].CardData{
                xml['ns1'].CardType parm[:CardType]   
                xml['ns1'].PAN parm[:PAN] 
                xml['ns1'].Expire parm[:Expire]
                xml['ns1'].Track1Data('i:nil' =>"true")
              }
              xml['ns1'].EcommerceSecurityData('i:nil' =>"true")
            }
            xml['ns1'].TransactionData{
              if parm[:Amount] != ''
                xml['ns8'].Amount('xmlns:ns8' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text(parm[:Amount])
              else
                xml['ns8'].Amount('xmlns:ns8' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text('0.00')
              end
              #xml['ns8'].Amount('xmlns:ns8' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text(parm[:Amount])
              xml['ns9'].CurrencyCode('xmlns:ns9' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text('USD') 
              xml['ns10'].TransactionDateTime('xmlns:ns10' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text('2013-04-03T13:50:16')
              xml['ns11'].CampaignId('xmlns:ns11' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions",'i:nil' =>"true")
              xml['ns12'].Reference('xmlns:ns12' =>"http://schemas.ipcommerce.com/CWS/v2.0/Transactions").text('xyt')
              xml['ns1'].AccountType 'NotSet'
              xml['ns1'].ApprovalCode('i:nil' =>"true")
              xml['ns1'].CashBackAmount '0.0'
              xml['ns1'].CustomerPresent 'Present'
              xml['ns1'].EmployeeId '11'
              xml['ns1'].EntryMode 'Keyed'
              xml['ns1'].GoodsType 'NotSet'
              xml['ns1'].IndustryType 'Ecommerce'
              xml['ns1'].InternetTransactionData('i:nil' =>"true")
              xml['ns1'].InvoiceNumber parm[:InvoiceNumber]
              xml['ns1'].OrderNumber parm[:OrderNumber]
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
    end

    private

    def encode_token(str)
      Base64.strict_encode64(str.gsub(/"/, '').concat(":"))
    end

    def parameter_exists?(params)
      params.size != 0 || raise(ParameterMissing, MESSAGE[:parameter_missing])
    end
    def appl_merch_pid_exists?(parm)  
       (parm[:ApplicationProfileId] || parm[:MerchantProfileId]) != '' || raise(ApplicationAndMerchentProfileidFault, MESSAGE[:application_and_merchent_profileid_fault])
    end 
    
    def errors_exists?(response_xml)
      @response = response_xml   
     # p @response
      msg = REXML::Document.new(@response.body)
       if @response.code == 200
        #  p "200200200200"
          return @response
       elsif @response.code == 400
        #  p "400400400400"
          error = REXML::XPath.first(msg, "/ErrorResponse/Reason/text()")
             
          if error == "Validation Errors Occurred"  
              error1 = REXML::XPath.first(msg, "/ErrorResponse/ValidationErrors/ValidationError/RuleMessage/text()")
              @response = error1
              if @response == nil    
                  @response = "Bad Request" 
                  return @response
              else
                  return @response  
              end
          else 
             @response = error
            # p @response
             if @response == nil    
                  @response = "Bad Request" 
                  return @response
              else
                  return @response  
              end
          end
       else
         # p "201201201"
          return @response
       end
    end
  end

  ######################################################################################
  # for testing processor class, put here that code #
  #  res = Processor.new.verify({abc: "abc"})
  #   p res.body
  # rescue => ex
  #  p ex
  ######################################################################################
end