# frozen_string_literal: true

begin
  require 'keyring'  
  KEYRING_AVAILABLE = true
rescue LoadError
  KEYRING_AVAILABLE = false
end

require 'base64'
require 'fileutils'

module ClickupTui
  class Auth
    KEYRING_SERVICE = "clickup-tui"
    KEYRING_ACCOUNT = "api-token"
    TOKEN_FILE_PATH = File.expand_path('~/.config/clickup-tui/token')
    
    class << self
      def store_token(token)
        validate_token_format!(token)
        
        if KEYRING_AVAILABLE
          begin
            Keyring.set_password(KEYRING_SERVICE, KEYRING_ACCOUNT, token)
            puts "✅ API token stored securely"
            return
          rescue => e
            puts "⚠️  Keyring not available (#{e.message}). Using file storage."
          end
        end
        
        store_token_file(token)
      end
      
      def get_token
        if KEYRING_AVAILABLE
          begin
            token = Keyring.get_password(KEYRING_SERVICE, KEYRING_ACCOUNT)
            return token if token && !token.empty?
          rescue => e
            # Fallback to file storage
          end
        end
        
        get_token_file
      end
      
      def clear_token
        if KEYRING_AVAILABLE
          begin
            Keyring.delete_password(KEYRING_SERVICE, KEYRING_ACCOUNT)
          rescue => e
            # Clear file storage instead
          end
        end
        
        clear_token_file
        puts "✅ API token cleared"
      end
      
      def token_exists?
        token = get_token
        !!(token && !token.empty?)
      end
      
      private
      
      def validate_token_format!(token)
        unless token.start_with?('pk_')
          raise Error::InvalidTokenFormat, 
                "ClickUp personal API tokens must start with 'pk_'"
        end
        
        if token.length < 20
          raise Error::InvalidTokenFormat,
                "Token appears to be too short. Please check your token."
        end
      end
      
      def store_token_file(token)
        ensure_config_directory
        encrypted = encrypt_token(token)
        File.write(TOKEN_FILE_PATH, encrypted)
        File.chmod(0600, TOKEN_FILE_PATH) # Read/write for owner only
        puts "✅ API token stored in encrypted file"
      end
      
      def get_token_file
        return nil unless File.exist?(TOKEN_FILE_PATH)
        
        encrypted = File.read(TOKEN_FILE_PATH)
        decrypt_token(encrypted)
      rescue => e
        puts "⚠️  Failed to read token file: #{e.message}"
        nil
      end
      
      def clear_token_file
        File.delete(TOKEN_FILE_PATH) if File.exist?(TOKEN_FILE_PATH)
      end
      
      def encrypt_token(token)
        key = get_encryption_key
        encrypted = token.bytes.zip(key.bytes.cycle).map { |a, b| a ^ b }.pack('C*')
        Base64.strict_encode64(encrypted)
      end
      
      def decrypt_token(encrypted_base64)
        key = get_encryption_key
        encrypted = Base64.strict_decode64(encrypted_base64)
        encrypted.bytes.zip(key.bytes.cycle).map { |a, b| a ^ b }.pack('C*')
      end
      
      def get_encryption_key
        # Use a combination of factors for the encryption key
        factors = [
          ENV['USER'] || ENV['USERNAME'] || 'clickup-tui',
          ENV['HOME'] || ENV['USERPROFILE'] || '/tmp',
          'clickup-tui-secret-key'
        ]
        
        Base64.strict_encode64(factors.join('-'))[0..31]
      end
      
      def ensure_config_directory
        config_dir = File.dirname(TOKEN_FILE_PATH)
        FileUtils.mkdir_p(config_dir) unless Dir.exist?(config_dir)
      end
    end
  end
end