# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ErrorHandlingService do
  let(:product_parser_rule) { create(:product_parser_rule) }
  let(:msg) { 'Test error message' }
  let(:error_threshold) { 3 }

  describe '#initialize' do
    it 'initializes with product_parser_rule, msg, and error_threshold' do
      error_handling_service = ErrorHandlingService.new(product_parser_rule, msg, error_threshold)
      expect(error_handling_service.instance_variable_get(:@product_parser_rule)).to eq(product_parser_rule)
      expect(error_handling_service.instance_variable_get(:@msg)).to eq(msg)
      expect(error_handling_service.instance_variable_get(:@error_threshold)).to eq(error_threshold)
    end
  end

  describe '#process' do
    before { create_list(:rules_error, 2, product_parser_rule:) }
    it 'creates a rule error and handles error notification' do
      allow(Notifier::TelegramBot).to receive(:error_alert)
      error_handling_service = ErrorHandlingService.new(product_parser_rule, msg, error_threshold)

      expect(error_handling_service).to receive(:create_rule_error).once.and_call_original
      expect(error_handling_service).to receive(:handle_error_notification).once.and_call_original

      error_handling_service.process
    end

    it 'logs an error if an exception is raised' do
      error_handling_service = ErrorHandlingService.new(product_parser_rule, msg, error_threshold)

      allow(error_handling_service).to receive(:create_rule_error).and_raise(StandardError, 'Test Error')
      expect(Rails.logger).to receive(:error).with('Test Error')

      error_handling_service.process
    end
  end

  describe '#create_rule_error' do
    it 'creates a rule error with the correct type and message' do
      error_handling_service = ErrorHandlingService.new(product_parser_rule, msg, error_threshold)

      rule_error = error_handling_service.send(:create_rule_error)

      expect(rule_error.product_parser_rule).to eq(product_parser_rule)
      expect(rule_error.error_type).to eq('unrecognized')
      expect(rule_error.message).to eq(msg)
    end
  end

  describe '#determine_error_type' do
    it 'returns :element_not_found if the message contains "no such element:"' do
      error_handling_service = ErrorHandlingService.new(product_parser_rule, 'no such element: Test message',
                                                        error_threshold)

      error_type = error_handling_service.send(:determine_error_type)

      expect(error_type).to eq(:element_not_found)
    end

    it 'returns :unrecognized if the message does not contain "no such element:"' do
      error_handling_service = ErrorHandlingService.new(product_parser_rule, 'Test unrecognized message',
                                                        error_threshold)

      error_type = error_handling_service.send(:determine_error_type)

      expect(error_type).to eq(:unrecognized)
    end
  end

  describe '#handle_error_notification' do
    it 'notifies with error_alert if errors count reaches the threshold' do
      error_handling_service = ErrorHandlingService.new(product_parser_rule, msg, 3)

      expect(RulesError).to receive(:where).with(product_parser_rule:, error_type: :unrecognized)
                                           .and_return([double, double])
      expect(Notifier::TelegramBot).to receive(:error_alert)

      error_handling_service.send(:process)
    end

    it 'does not notify if errors count does not reach the threshold' do
      error_handling_service = ErrorHandlingService.new(product_parser_rule, msg, 4)

      expect(RulesError).to receive(:where).with(product_parser_rule:,
                                                 error_type: :unrecognized).and_return([
                                                                                         double, double
                                                                                       ])
      expect(Notifier::TelegramBot).not_to receive(:error_alert)

      error_handling_service.send(:process)
    end
  end
end
