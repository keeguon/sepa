module Sepa
  class CreditTransferTransaction
    CURRENCY_CODE = 'EUR'

    def initialize
      @instruction_identification = ''
      @end_to_end_identification  = ''
      @instructed_amount          = 0.00
      @creditor_agent_bic         = ''
      @creditor_name              = ''
      @creditor_iban              = ''
      @remittance_information     = ''
    end

    def instruction_identification
      @instruction_identification.empty? ? end_to_end_identification : @instruction_identification
    end

    def instruction_identification=(instr_id)
      if (instr_id =~ /^([\-A-Za-z0-9\+\/\?:\(\)\., ]){0,35}\z/).nil?
        throw Sepa::Exception.new "Invalid InstructionIdentification (max. 35)."
      end

      @instruction_identification = instr_id
    end

    def end_to_end_identification
      @end_to_end_identification
    end

    def end_to_end_identification=(end_to_end_id)
      if (end_to_end_id =~ /^([\-A-Za-z0-9\+\/\?:\(\)\., ]){0,35}\z/).nil?
        throw Sepa::Exception.new "Invalid EndToEndIdentification (max. 35)."
      end

      @end_to_end_identification = end_to_end_id
    end

    def instructed_amount
      @instructed_amount
    end

    def instructed_amount=(instd_amt)
      @instructed_amount = instd_amt.to_f
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

    def creditor_name
      @creditor_name
    end

    def creditor_name=(cdtr)
      if cdtr.length == 0 || cdtr.length > 70
        throw Sepa::Exception.new "Invalid creditor name (max. 70 characters)."
      end

      @creditor_name = cdtr
    end

    def creditor_iban
      @creditor_iban
    end

    def creditor_iban=(iban)
      iban = iban.strip.gsub ' ', ''

      if (iban =~ /^[a-zA-Z]{2}[0-9]{2}[a-zA-Z0-9]{4}[a-zA-Z0-9]{7}([a-zA-Z0-9]?){0,16}\z/i).nil?
        throw Sepa::Exception.new "Invalid creditor IBAN."
      end

      @creditor_iban = iban
    end

    def remittance_information
      @remittance_information
    end

    def remittance_information=(ustrd)
      if (ustrd =~ /^([A-Za-z0-9]|[\+|\?|\/|\-|:|\(|\)|\.|,|'| ]){0,140}\z/).nil?
        throw Sepa::Exception.new "RmtInf contains invalid chars or is too long (max. 140)."
      end

      @remittance_information = ustrd
    end

    def to_xml(document)
      xml = Nokogiri::XML::Node.new "CdtTrfTxInf", document

      pmt_id               = Nokogiri::XML::Node.new "PmtId", document
      pmt_id_instr_id      = Nokogiri::XML::Node.new "InstrId", document
      pmt_id_end_to_end_id = Nokogiri::XML::Node.new "EndToEndId", document
      pmt_id_instr_id.content = instruction_identification
      pmt_id_end_to_end_id.content = end_to_end_identification
      pmt_id << pmt_id_instr_id
      pmt_id << pmt_id_end_to_end_id
      xml << pmt_id

      node    = Nokogiri::XML::Node.new "Amt", document
      subnode = Nokogiri::XML::Node.new "InstdAmt", document
      subnode['Ccy'] = Sepa::DirectDebitTransaction::CURRENCY_CODE
      subnode.content = instructed_amount
      node << subnode
      xml << node

      if !creditor_agent_bic.nil?
        cdtr_agt                  = Nokogiri::XML::Node.new "CdtrAgt", document
        cdtr_agt_fin_instn_id     = Nokogiri::XML::Node.new "FinInstnId", document
        cdtr_agt_fin_instn_id_bic = Nokogiri::XML::Node.new "BIC", document
        cdtr_agt_fin_instn_id_bic.content = creditor_agent_bic
        cdtr_agt_fin_instn_id << cdtr_agt_fin_instn_id_bic
        cdtr_agt << cdtr_agt_fin_instn_id
        xml << cdtr_agt
      end

      cdtr    = Nokogiri::XML::Node.new "Cdtr", document
      cdtr_nm = Nokogiri::XML::Node.new "Nm", document
      cdtr_nm.content = creditor_name
      cdtr << cdtr_nm
      xml << cdtr

      cdtr_acct         = Nokogiri::XML::Node.new "CdtrAcct", document
      cdtr_acct_id      = Nokogiri::XML::Node.new "Id", document
      cdtr_acct_id_iban = Nokogiri::XML::Node.new "IBAN", document
      cdtr_acct_id_iban.content = creditor_iban
      cdtr_acct_id << cdtr_acct_id_iban
      cdtr_acct << cdtr_acct_id
      xml << cdtr_acct

      rmt_inf       = Nokogiri::XML::Node.new "RmtInf", document
      rmt_inf_ustrd = Nokogiri::XML::Node.new "Ustrd", document
      rmt_inf_ustrd.content = remittance_information
      rmt_inf << rmt_inf_ustrd
      xml << rmt_inf

      xml
    end
  end
end
