module Sepa
  class DirectDebitTransaction
    CURRENCY_CODE = 'EUR'
    CHARGE_BEARER = 'SLEV'

    def initialize
      @instruction_identification = ''
      @end_to_end_identification  = ''
      @instructed_amount          = 0.00
      @mandate_identification     = ''
      @date_of_signature          = ''
      @amendment_indicator        = ''
      @debtor_agent_bic           = ''
      @debtor_name                = ''
      @debtor_iban                = ''
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

    def mandate_identification
      @mandate_identification
    end

    def mandate_identification=(mndt_id)
      if (mndt_id =~ /^([A-Za-z0-9]|[\+|\?|\/|\-|:|\(|\)|\.|,|']){1,35}\z/).nil?
        throw Sepa::Exception.new "MndtId empty, contains invalid characters or too long (max. 35)."
      end

      @mandate_identification = mndt_id
    end

    def date_of_signature
      @date_of_signature
    end

    def date_of_signature=(dt_of_sgntr)
      @date_of_signature = dt_of_sgntr
    end

    def amendment_indicator
      @amendment_indicator
    end

    def amendment_indicator=(amdmnt_ind)
      @amendment_indicator = ([true, 'true'].include?(amdmnt_ind) ? 'true' : 'false')
    end

    def debtor_agent_bic
      @debtor_agent_bic
    end

    def debtor_agent_bic=(bic)
      bic = bic.strip.gsub ' ', ''

      if (bic =~ /^[0-9a-z]{4}[a-z]{2}[0-9a-z]{2}([0-9a-z]{3})?\z/i).nil?
        throw Sepa::Exception.new "Invalid debtor BIC."
      end

      @debtor_agent_bic = bic
    end

    def debtor_name
      @debtor_name
    end

    def debtor_name=(dbtr)
      if dbtr.length == 0 || dbtr.length > 70
        throw Sepa::Exception.new "Invalid debtor name (max. 70 characters)."
      end

      @debtor_name = dbtr
    end

    def debtor_iban
      @debtor_iban
    end

    def debtor_iban=(iban)
      iban = iban.strip.gsub ' ', ''

      if (iban =~ /^[a-zA-Z]{2}[0-9]{2}[a-zA-Z0-9]{4}[a-zA-Z0-9]{7}([a-zA-Z0-9]?){0,16}\z/i).nil?
        throw Sepa::Exception.new "Invalid debtor IBAN."
      end

      @debtor_iban = iban
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
      xml = Nokogiri::XML::Node.new "DrctDbtTxInf", document

      pmt_id               = Nokogiri::XML::Node.new "PmtId", document
      pmt_id_instr_id      = Nokogiri::XML::Node.new "InstrId", document
      pmt_id_end_to_end_id = Nokogiri::XML::Node.new "EndToEndId", document
      pmt_id_instr_id.content = instruction_identification
      pmt_id_end_to_end_id.content = end_to_end_identification
      pmt_id << pmt_id_instr_id
      pmt_id << pmt_id_end_to_end_id
      xml << pmt_id

      node = Nokogiri::XML::Node.new "InstdAmt", document
      node['Ccy'] = Sepa::DirectDebitTransaction::CURRENCY_CODE
      node.content = instructed_amount
      xml << node
      node = Nokogiri::XML::Node.new "ChrgBr", document
      node.content = Sepa::DirectDebitTransaction::CHARGE_BEARER
      xml << node

      drct_dbt_tx                           = Nokogiri::XML::Node.new "DrctDbtTx", document
      drct_dbt_tx_mndt_rltd_inf             = Nokogiri::XML::Node.new "MndtRltdInf", document
      drct_dbt_tx_mndt_rltd_inf_mndt_id     = Nokogiri::XML::Node.new "MndtId", document
      drct_dbt_tx_mndt_rltd_inf_dt_of_sgntr = Nokogiri::XML::Node.new "DtOfSgntr", document
      drct_dbt_tx_mndt_rltd_inf_amdmnt_ind  = Nokogiri::XML::Node.new "AmdmntInd", document
      drct_dbt_tx_mndt_rltd_inf_mndt_id.content = mandate_identification
      drct_dbt_tx_mndt_rltd_inf_dt_of_sgntr.content = date_of_signature
      drct_dbt_tx_mndt_rltd_inf_amdmnt_ind.content = amendment_indicator
      drct_dbt_tx_mndt_rltd_inf << drct_dbt_tx_mndt_rltd_inf_mndt_id
      drct_dbt_tx_mndt_rltd_inf << drct_dbt_tx_mndt_rltd_inf_dt_of_sgntr
      drct_dbt_tx_mndt_rltd_inf << drct_dbt_tx_mndt_rltd_inf_amdmnt_ind
      drct_dbt_tx << drct_dbt_tx_mndt_rltd_inf
      xml << drct_dbt_tx

      dbtr_agt                  = Nokogiri::XML::Node.new "DbtrAgt", document
      dbtr_agt_fin_instn_id     = Nokogiri::XML::Node.new "FinInstnId", document
      dbtr_agt_fin_instn_id_bic = Nokogiri::XML::Node.new "BIC", document
      dbtr_agt_fin_instn_id_bic.content = debtor_agent_bic
      dbtr_agt_fin_instn_id << dbtr_agt_fin_instn_id_bic
      dbtr_agt << dbtr_agt_fin_instn_id
      xml << dbtr_agt

      dbtr    = Nokogiri::XML::Node.new "Dbtr", document
      dbtr_nm = Nokogiri::XML::Node.new "Nm", document
      dbtr_nm.content = debtor_name
      dbtr << dbtr_nm
      xml << dbtr

      dbtr_acct         = Nokogiri::XML::Node.new "DbtrAcct", document
      dbtr_acct_id      = Nokogiri::XML::Node.new "Id", document
      dbtr_acct_id_iban = Nokogiri::XML::Node.new "IBAN", document
      dbtr_acct_id_iban.content = debtor_iban
      dbtr_acct_id << dbtr_acct_id_iban
      dbtr_acct << dbtr_acct_id
      xml << dbtr_acct

      rmt_inf       = Nokogiri::XML::Node.new "RmtInf", document
      rmt_inf_ustrd = Nokogiri::XML::Node.new "Ustrd", document
      rmt_inf_ustrd.content = remittance_information
      rmt_inf << rmt_inf_ustrd
      xml << rmt_inf

      xml
    end
  end
end
