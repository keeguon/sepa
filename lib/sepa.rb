path = File.expand_path(File.dirname(__FILE__))
$:.unshift path unless $:.include?(path)

require 'nokogiri'
require 'sepa/exception'
require 'sepa/credit_transfer_transaction'
require 'sepa/direct_debit_transaction'
require 'sepa/payment_info'
require 'sepa/group_header'
require 'sepa/message'
require 'sepa/version'
