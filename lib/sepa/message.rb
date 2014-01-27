module Sepa
  class Message
    def initialize(message_definition = '')
      @message_definition = message_definition
      @group_header = nil
      @payment_infos = []
    end

    def group_header
      @group_header = @group_header.nil? ? Sepa::GroupHeader.new : @group_header
      
      @group_header
    end

    def group_header=(grp_hdr)
      if grp_hdr.class != Sepa::GroupHeader
        throw Sepa::Exception.new "Invalid 'grp_hdr' parameter, must be of class 'Sepa::GroupHeader'."
      end

      @group_header = grp_hdr
    end

    def add_payment_info(payment_info)
      if payment_info.class != Sepa::PaymentInfo
        throw Sepa::Exception.new "Invalid 'payment_info' parameter, must be of class 'Sepa::PaymentInfo'."
      end

      @payment_infos << payment_info

      nb_of_txs = @group_header.number_of_transactions + payment_info.number_of_transactions
      ctrl_sum  = @group_header.control_sum + payment_info.control_sum
      @group_header.number_of_transactions = nb_of_txs
      @group_header.control_sum = ctrl_sum
    end

    def to_xml
      # Create document
      doc = Nokogiri::XML::Document.new
      node = Nokogiri::XML::Node.new "Document", doc
      node['xmlns'] = @message_definition
      node['xmlns:xsi'] = "http://www.w3.org/2001/XMLSchema-instance"
      doc.root = node

      # Initialize the actual message en add the group header
      message = Nokogiri::XML::Node.new "CstmrDrctDbtInitn", doc
      message << group_header.to_xml(doc)

      # Add all payment blocks
      @payment_infos.each do |payment_info|
        message << payment_info.to_xml
      end

      message.xpath('.//GrpHdr//NbOfTxs').first.content = group_header.number_of_transactions
      message.xpath('.//GrpHdr//CtrlSum').first.content = group_header.control_sum

      doc.root << message

      doc.to_xml
    end
  end
end