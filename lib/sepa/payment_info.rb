module Sepa
  class PaymentInfo
    PAYMENT_METHOD    = 'DD'
    SERVICELEVEL_CODE = 'SEPA'
    CHARGE_BEARER     = 'SLEV'
    PROPRIETARY_NAME  = 'SEPA'

    def initialize
      @payment_information_identification = ''
      @batchbooking = true
      @number_of_transactions = 0
      @control_sum = 0.00
      @local_instrument_code = 'CORE'
      @sequence_type = 'FRST'
      @requested_collection_date = nil
      @creditor_name = ''
      @creditor_account_iban = ''
      @creditor_agent_iban = ''
      @creditor_scheme_identification = ''
      @transactions = []
    end

    def payment_information_identification
      @payment_information_identification
    end

    def payment_information_identification=(pmt_inf_id)
      if (pmt_inf_id =~ /^([A-Za-z0-9]|[\+|\?|\/|\-|:|\(|\)|\.|,|'| ]){1,35}\z/).nil?
        throw Sepa::Exception.new "PmtInfId empty, contains invalid characters or too long (max. 35)." 
      end

      @payment_information_identification = pmt_inf_id
    end

    def batchbooking
      @batchbooking
    end

    def batchbooking=(btch_bookg)
      @batchbooking = (btch_bookg == true || btch_bookg == 'true') ? true : false
    end

    def number_of_transactions
      @number_of_transactions
    end

    def control_sum
      @control_sum
    end

    def local_instrument_code
      @local_instrument_code
    end

    def local_instrument_code=(cd)
      if (cd =~ /^(B2B|COR1|CORE)\z/).nil?
        throw Sepa::Exception.new "Only 'CORE', 'COR1', or 'B2B' are allowed."
      end

      @local_instrument_code = cd
    end

    def sequence_type
      @sequence_type
    end

    def sequence_type=(seq_type)
      if (seq_type =~ /^(FNAL|FRST|OOFF|RCUR)\z/).nil?
        throw Sepa::Exception.new "Only 'FNAL', 'FRST', 'OOFF', or 'RCUR' are allowed."
      end

      @sequence_type = seq_type
    end

    def requested_collection_date
      reqd_colltn_dt = Time.new
      #@requested_collection_date = reqd_colltn_dt.strftime("%Y-%m-%d\T%H:%M:%S")
      @requested_collection_date = reqd_colltn_dt.strftime("%Y-%m-%d")
      @requested_collection_date
    end

    def requested_collection_date=(reqd_colltn_dt)
      @requested_collection_date = reqd_colltn_dt
    end

    def creditor_name
      @creditor_name
    end

    def creditor_name=(cdtr)
      if cdtr.length == 0 || cdtr.length > 70
        throw Sepa::Exception.new "Invalid initiating party name (max. 70)."
      end

      @creditor_name = cdtr
    end

    def creditor_account_iban
      @creditor_account_iban
    end

    def creditor_account_iban=(iban)
      iban = iban.strip.gsub ' ', ''

      if (iban =~ /^[a-zA-Z]{2}[0-9]{2}[a-zA-Z0-9]{4}[0-9]{7}([a-zA-Z0-9]?){0,16}\z/i).nil?
        throw Sepa::Exception.new "Invalid creditor IBAN."
      end

      @creditor_account_iban = iban
    end

    def creditor_agent_bic
      @creditor_agent_bic
    end

    def creditor_agent_bic=(bic)
      bic = bic.strip.gsub ' ', ''

      if (bic =~ /^[0-9a-z]{4}[a-z]{2}[0-9a-z]{2}([0-9a-z]{3})?\z/i).nil?
        throw Sepa::Exception.new "Invalid creditor BIC."
      end

      @creditor_agent_bic = bic
    end

    def creditor_scheme_identification
      @creditor_scheme_identification
    end

    def creditor_scheme_identification=(cdtr_schme_id)
      if cdtr_schme_id.empty? || cdtr_schme_id.nil?
        throw Sepa::Exception.new "Invalid CreditorSchemeIdentification."
      end

      @creditor_scheme_identification = cdtr_schme_id
    end

    def add_transaction(transaction)
      if transaction.class != Sepa::DirectDebitTransaction
        throw Sepa::Exception.new "Invalid 'transaction' parameter, must be of class 'Sepa::DirectDebitTransaction'."
      end

      @transactions << transaction

      @number_of_transactions++
      @control_sum += transaction.instructed_amount
    end

    def to_xml(document)
      xml = Nokogiri::XML::Node.new "PmtInf", document

      node = Nokogiri::XML::Node.new "PmtInfId", document
      node.content = payment_information_identification
      xml << node
      node = Nokogiri::XML::Node.new "PmtMtd", document
      node.content = Sepa::PaymentInfo::PAYMENT_METHOD
      xml << node
      node = Nokogiri::XML::Node.new "BtchBookg", document
      node.content = batchbooking
      xml << node
      node = Nokogiri::XML::Node.new "NbOfTxs", document
      node.content = number_of_transactions
      xml << node
      node = Nokogiri::XML::Node.new "CtrlSum", document
      node.content = control_sum
      xml << node

      pmt_tp_inf            = Nokogiri::XML::Node.new "PmtTpInf", document
      svc_lvl               = Nokogiri::XML::Node.new "SvcLvl", document
      svl_lvl_cd            = Nokogiri::XML::Node.new "Cd", document
      lcl_instrm            = Nokogiri::XML::Node.new "LclInstrm", document
      lcl_instrm_cd         = Nokogiri::XML::Node.new "Cd", document
      seq_tp                = Nokogiri::XML::Node.new "SeqTp", document
      svl_lvl_cd.content    = Sepa::PaymentInfo::SERVICELEVEL_CODE
      lcl_instrm_cd.content = local_instrument_code
      seq_tp.content        = sequence_type
      svc_lvl << svl_lvl_cd
      pmt_tp_inf << svc_lvl
      lcl_instrm << lcl_instrm_cd
      pmt_tp_inf << lcl_instrm
      pmt_tp_inf << seq_tp
      xml << pmt_tp_inf

      node = Nokogiri::XML::Node.new "ReqdColltnDt", document
      node.content = requested_collection_date
      xml << node

      cdtr            = Nokogiri::XML::Node.new "Cdtr", document
      cdtr_nm         = Nokogiri::XML::Node.new "Nm", document
      cdtr_nm.content = creditor_name
      cdtr << cdtr_nm
      xml << cdtr

      cdtr_acct         = Nokogiri::XML::Node.new "CdtrAcct", document
      cdtr_acct_id      = Nokogiri::XML::Node.new "Id", document
      cdtr_acct_id_iban = Nokogiri::XML::Node.new "IBAN", document
      cdtr_acct_id_iban.content = creditor_account_iban
      cdtr_acct_id << cdtr_acct_id_iban
      cdtr_acct << cdtr_acct_id
      xml << cdtr_acct

      cdtr_agt                  = Nokogiri::XML::Node.new "CdtrAgt", document
      cdtr_agt_fin_instn_id     = Nokogiri::XML::Node.new "FinInstnId", document
      cdtr_agt_fin_instn_id_bic = Nokogiri::XML::Node.new "BIC", document
      cdtr_agt_fin_instn_id_bic.content = creditor_agent_bic
      cdtr_agt_fin_instn_id << cdtr_agt_fin_instn_id_bic
      cdtr_agt << cdtr_agt_fin_instn_id
      xml << cdtr_agt

      node = Nokogiri::XML::Node.new "ChrgBr", document
      node.content = Sepa::PaymentInfo::CHARGE_BEARER
      xml << node

      cdtr_schme_id                                = Nokogiri::XML::Node.new "CdtrSchmeId", document
      cdtr_schme_id_id                             = Nokogiri::XML::Node.new "Id", document
      cdtr_schme_id_id_prvt_id                     = Nokogiri::XML::Node.new "PrvtId", document
      cdtr_schme_id_id_prvt_id_othr                = Nokogiri::XML::Node.new "Othr", document
      cdtr_schme_id_id_prvt_id_othr_schme_nm       = Nokogiri::XML::Node.new "SchmeNm", document
      cdtr_schme_id_id_prvt_id_othr_schme_nm_prtry = Nokogiri::XML::Node.new "Prtry", document
      unless creditor_scheme_identification.empty?
        cdtr_schme_id_id_prvt_id_othr_id = Nokogiri::XML::Node.new "Id", document
        cdtr_schme_id_id_prvt_id_othr_id.content = creditor_scheme_identification
        cdtr_schme_id_id_prvt_id_othr << cdtr_schme_id_id_prvt_id_othr_id
      end
      cdtr_schme_id_id_prvt_id_othr_schme_nm_prtry.content = Sepa::PaymentInfo::PROPRIETARY_NAME
      cdtr_schme_id_id_prvt_id_othr_schme_nm << cdtr_schme_id_id_prvt_id_othr_schme_nm_prtry
      cdtr_schme_id_id_prvt_id_othr << cdtr_schme_id_id_prvt_id_othr_schme_nm
      cdtr_schme_id_id_prvt_id << cdtr_schme_id_id_prvt_id_othr
      cdtr_schme_id_id << cdtr_schme_id_id_prvt_id
      cdtr_schme_id << cdtr_schme_id_id
      xml << cdtr_schme_id

      @transactions.each_with_index { |transaction| xml << transaction.to_xml(document) }

      xml.xpath('.//NbOfTxs').first.content = number_of_transactions
      xml.xpath('.//CtrlSum').first.content = control_sum

      xml
    end
  end
end