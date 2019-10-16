require 'builder'

module AddressValidator
  class Validator
    attr_reader :client

    def initialize
      @client = Client.new
      @config = AddressValidator.config
    end

    def validate(address)
      if address.is_a?(::Hash)
        address = build_address(address)
      end

      request = build_request(address)
      @client.post(request)
    end

    def build_address(attrs)
      AddressValidator::Address.new(attrs)
    end

    def build_request(address)
      xml = Builder::XmlMarkup.new

      xml.instruct!
      xml.AddressValidationRequest do
        xml.Request do
          xml.RequestAction 'XAV' # must be XAV
          xml.RequestOption '3'   # validation + classification
          xml.MaximumCandidateListSize '3'
        end
        xml.MaximumListSize(@config.maximum_list_size || 1)
        xml << address.to_xml
      end

      xml.target!
    end
  end
end
