# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ClickupTui::Auth do
  describe '.store_token' do
    context 'with valid token format' do
      it 'stores token successfully' do
        token = 'pk_test_valid_token_123'

        expect { ClickupTui::Auth.store_token(token) }.not_to raise_error
        expect(ClickupTui::Auth.token_exists?).to be true
      end
    end

    context 'with invalid token format' do
      it 'raises InvalidTokenFormat error for non-pk token' do
        token = 'invalid_token_123'

        expect do
          ClickupTui::Auth.store_token(token)
        end.to raise_error(ClickupTui::Error::InvalidTokenFormat)
      end

      it 'raises InvalidTokenFormat error for short token' do
        token = 'pk_short'

        expect do
          ClickupTui::Auth.store_token(token)
        end.to raise_error(ClickupTui::Error::InvalidTokenFormat)
      end
    end
  end

  describe '.get_token' do
    context 'when token exists' do
      it 'returns the stored token' do
        token = 'pk_test_retrieval_token_456'
        ClickupTui::Auth.store_token(token)

        retrieved_token = ClickupTui::Auth.get_token
        expect(retrieved_token).to eq(token)
      end
    end

    context 'when no token exists' do
      it 'returns nil' do
        expect(ClickupTui::Auth.get_token).to be_nil
      end
    end
  end

  describe '.clear_token' do
    it 'removes stored token' do
      token = 'pk_test_clear_token_789'
      ClickupTui::Auth.store_token(token)

      expect(ClickupTui::Auth.token_exists?).to be true

      ClickupTui::Auth.clear_token

      expect(ClickupTui::Auth.token_exists?).to be false
    end
  end

  describe '.token_exists?' do
    it 'returns true when token is stored' do
      token = 'pk_test_exists_token_101'
      ClickupTui::Auth.store_token(token)

      expect(ClickupTui::Auth.token_exists?).to be true
    end

    it 'returns false when no token is stored' do
      expect(ClickupTui::Auth.token_exists?).to be false
    end
  end
end
