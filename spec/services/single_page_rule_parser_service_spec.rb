require 'rails_helper'
require 'dry/monads/result'

RSpec.describe SinglePageRuleParserService do
  let(:rule) { create(:product_parser_rule) }
  let(:service) { described_class.new(rule) }
  let(:stubbed_price_value_return) { Dry::Monads::Success.new(100) }

  before do
    parser_double = double('Parser::ProductPageParser')
    allow(Parser::ProductPageParser).to receive(:new).and_return(parser_double)
    allow(parser_double).to receive(:get_value).and_return(stubbed_price_value_return)
  end

  describe '#parse_and_process' do
    context 'when parsing is successful and price is lower' do
      it 'calls handle_success when parsing is successful' do
        expect(service).to receive(:handle_success).with(100)
        service.send(:parse_and_process)
      end
    end

    context 'when parsing fails' do
      let(:stubbed_price_value_return) { Dry::Monads::Failure.new(['Error message', 'screenshot_file_name']) }
      it 'calls handle_failure' do
        expect(service).to receive(:handle_failure).with('Error message')
        service.send(:parse_and_process)
      end
    end
  end

  describe '#handle_success' do
    context 'when there is no lowest price' do
      let!(:errors) { create_list(:rules_error, 3, product_parser_rule: rule)}
      let(:price_value) { 60 }

      it 'creates a new price record and doesnt send a notification' do
        allow(RulesError).to receive_message_chain(:where, :destroy_all)
        allow(rule).to receive(:lowest_price).and_return(nil)
        allow(rule).to receive(:prices).and_return([])

        expect(Price).to receive(:create).with(product_parser_rule: rule, value: 50)
        expect(Notifier::TelegramBot).not_to receive(:low_price_notification)

        service.send(:handle_success, 50)
      end
    end

    context 'when there is a lowest price' do
      let(:price_value) { 60 }

      before do
        create(:price, product_parser_rule: rule, value: 100)
        create(:price, product_parser_rule: rule, value: price_value)
      end

      it 'does not create a new price record if price is not differ from the last one' do
        allow(RulesError).to receive_message_chain(:where, :destroy_all)
        allow(rule).to receive(:lowest_price).and_return(price_value)

        expect(Price).not_to receive(:create).with(product_parser_rule: rule, value: price_value)

        service.send(:handle_success, price_value)
      end

      it 'creates a new price record if price is differ from the last one' do
        allow(RulesError).to receive_message_chain(:where, :destroy_all)
        allow(rule).to receive(:lowest_price).and_return(price_value)

        expect(Price).to receive(:create).with(product_parser_rule: rule, value: price_value + 5)

        service.send(:handle_success, price_value + 5)
      end

      it 'does not send a notification if price is not lower' do
        allow(RulesError).to receive_message_chain(:where, :destroy_all)
        allow(rule).to receive(:lowest_price).and_return(price_value)
        expect(Notifier::TelegramBot).not_to receive(:low_price_notification)

        service.send(:handle_success, 60)
      end

      it 'sends a notification if price is lower' do
        allow(RulesError).to receive_message_chain(:where, :destroy_all)
        allow(rule).to receive(:lowest_price).and_return(price_value)

        expect(Notifier::TelegramBot).to receive(:low_price_notification).with(rule, 50)

        service.send(:handle_success, 50)
      end
    end
  end

  describe '#handle_failure' do
    it 'logs the error message and calls ErrorHandlingService' do
      error_message = 'Error message'
      expect_any_instance_of(ErrorHandlingService).to receive(:process)

      service.send(:handle_failure, error_message)
    end
  end

  describe '#create_price' do
    it 'creates a new price record' do
      expect(Price).to receive(:create).with(product_parser_rule: rule, value: 50)
      service.send(:create_price, 50)
    end
  end

  describe '#need_notification' do
    context 'when lowest price is not available' do
      it 'returns false' do
        allow(rule.product).to receive(:lowest_price).and_return(nil)
        expect(service.send(:need_notification?, nil, 50)).to be_falsey
      end
    end

    context 'when price decrease percentage is less than 5%' do
      xit 'returns false' do
        allow(rule.product).to receive(:lowest_price).and_return(100)
        expect(service.send(:need_notification?, 100, 97)).to be_falsey
      end
    end

    context 'when price decrease percentage is equal to or greater than 5%' do
      it 'returns true' do
        allow(rule.product).to receive(:lowest_price).and_return(100)
        expect(service.send(:need_notification?, 100, 90)).to be_truthy
      end
    end
  end
end
