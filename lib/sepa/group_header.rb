module Sepa
  class GroupHeader
    def initialize
      @message_identification = ''
      @creation_date_time = nil
      @number_of_transactions = 0
      @control_sum = 0.00
      @initiating_party_name = ''
      @initiating_party_bei = ''
    end

    def message_identification
      @message_identification
    end

    def message_identification=(msg_id)
      if (msg_id =~ /^([A-Za-z0-9]|[\+|\?|\/|\-|:|\(|\)|\.|,|'| ]){1,35}\z/).nil?
        throw Sepa::Exception.new "MsgId empty, contains invalid characters or too long (max. 35)."
      end

      @message_identification = msg_id
    end

    def creation_date_time
      creation_date = Time.new
      @creation_date_time ||= creation_date.strftime("%Y-%m-%d\T%H:%M:%S")
      @creation_date_time
    end

    def number_of_transactions
      @number_of_transactions
    end

    def number_of_transactions=(nb_of_txs)
      if (nb_of_txs.to_s =~ /^[0-9]{1,15}\z/).nil?
        throw Sepa::Exception.new "Invalid NbOfTxs value (max. 15 digits)."
      end

      @number_of_transactions = nb_of_txs
    end

    def control_sum
      @control_sum
    end

    def control_sum=(ctrl_sum)
      @control_sum = sprintf "%.2f", ctrl_sum
    end

    def initiating_party_name
      @initiating_party_name
    end

    def initiating_party_name=(nm)
      if nm.length == 0 || nm.length > 70
        throw Sepa::Exception.new "Invalid initiating party name (max. 70)."
      end

      @initiating_party_name = nm
    end

    def initiating_party_bei
      @initiating_party_bei
    end

    def initiating_party_bei=(bei)
      @initiating_party_bei = bei
    end

    def to_xml(document)
      xml = Nokogiri::XML::Node.new "GrpHdr", document

      node = Nokogiri::XML::Node.new "MsgId", document
      node.content = message_identification
      xml << node
      node = Nokogiri::XML::Node.new "CreDtTm", document
      node.content = creation_date_time
      xml << node
      node = Nokogiri::XML::Node.new "NbOfTxs", document
      node.content = number_of_transactions
      xml << node
      node = Nokogiri::XML::Node.new "CtrlSum", document
      node.content = control_sum
      xml << node

      initg_pty                      = Nokogiri::XML::Node.new "InitgPty", document
      initg_pty_nm                   = Nokogiri::XML::Node.new "Nm", document
      initg_pty_nm.content = initiating_party_name
      initg_pty << initg_pty_nm
      initg_pty_id                   = Nokogiri::XML::Node.new "Id", document
      initg_pty_id_org_id            = Nokogiri::XML::Node.new "OrgId", document
      initg_pty_id_org_id_bic_or_bei = Nokogiri::XML::Node.new "BICOrBEI", document
      initg_pty_id_org_id_bic_or_bei.content = initiating_party_bei
      initg_pty_id_org_id << initg_pty_id_org_id_bic_or_bei
      initg_pty_id << initg_pty_id_org_id
      initg_pty << initg_pty_id
      xml << initg_pty

      xml
    end
  end
end
