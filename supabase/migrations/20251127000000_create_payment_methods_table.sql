-- Create payment methods table
CREATE TABLE payment_methods (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('card', 'bank_account')),
  name TEXT NOT NULL, -- Display name for the payment method

  -- Card-specific fields
  card_brand TEXT, -- visa, mastercard, amex, etc.
  card_last4 TEXT, -- Last 4 digits of card
  card_expiry_month INTEGER, -- 1-12
  card_expiry_year INTEGER, -- 4-digit year

  -- Bank account-specific fields
  bank_name TEXT,
  bank_account_last4 TEXT, -- Last 4 digits of account number
  bank_routing_number TEXT, -- For US banks

  -- Common fields
  is_default BOOLEAN DEFAULT FALSE,
  is_verified BOOLEAN DEFAULT FALSE, -- For future verification features
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add constraints
ALTER TABLE payment_methods ADD CONSTRAINT card_fields_check
  CHECK (
    (type = 'card' AND card_brand IS NOT NULL AND card_last4 IS NOT NULL AND card_expiry_month IS NOT NULL AND card_expiry_year IS NOT NULL) OR
    (type = 'bank_account' AND bank_name IS NOT NULL AND bank_account_last4 IS NOT NULL) OR
    (type NOT IN ('card', 'bank_account'))
  );

-- Ensure only one default payment method per user
CREATE UNIQUE INDEX idx_payment_methods_user_default
  ON payment_methods(user_id)
  WHERE is_default = TRUE;

-- Enable RLS
ALTER TABLE payment_methods ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view their own payment methods" ON payment_methods
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own payment methods" ON payment_methods
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own payment methods" ON payment_methods
  FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own payment methods" ON payment_methods
  FOR DELETE USING (auth.uid() = user_id);

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_payment_methods_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically update updated_at
CREATE TRIGGER update_payment_methods_updated_at_trigger
  BEFORE UPDATE ON payment_methods
  FOR EACH ROW EXECUTE FUNCTION update_payment_methods_updated_at();

-- Function to ensure only one default payment method per user
CREATE OR REPLACE FUNCTION ensure_single_default_payment_method()
RETURNS TRIGGER AS $$
BEGIN
  -- If setting is_default to TRUE, unset all other defaults for this user
  IF NEW.is_default = TRUE THEN
    UPDATE payment_methods
    SET is_default = FALSE
    WHERE user_id = NEW.user_id AND id != NEW.id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to ensure single default
CREATE TRIGGER ensure_single_default_payment_method_trigger
  BEFORE INSERT OR UPDATE ON payment_methods
  FOR EACH ROW EXECUTE FUNCTION ensure_single_default_payment_method();

-- Comments
COMMENT ON TABLE payment_methods IS 'Stores user payment methods (credit cards and bank accounts).';
COMMENT ON COLUMN payment_methods.user_id IS 'The ID of the user who owns this payment method.';
COMMENT ON COLUMN payment_methods.type IS 'The type of payment method: card or bank_account.';
COMMENT ON COLUMN payment_methods.name IS 'Display name for the payment method.';
COMMENT ON COLUMN payment_methods.card_brand IS 'Credit card brand (visa, mastercard, amex, etc.) - required for card type.';
COMMENT ON COLUMN payment_methods.card_last4 IS 'Last 4 digits of credit card number - required for card type.';
COMMENT ON COLUMN payment_methods.card_expiry_month IS 'Credit card expiry month (1-12) - required for card type.';
COMMENT ON COLUMN payment_methods.card_expiry_year IS 'Credit card expiry year (4-digit) - required for card type.';
COMMENT ON COLUMN payment_methods.bank_name IS 'Bank name - required for bank_account type.';
COMMENT ON COLUMN payment_methods.bank_account_last4 IS 'Last 4 digits of bank account number - required for bank_account type.';
COMMENT ON COLUMN payment_methods.bank_routing_number IS 'Bank routing number for US banks.';
COMMENT ON COLUMN payment_methods.is_default IS 'Whether this is the user''s default payment method.';
COMMENT ON COLUMN payment_methods.is_verified IS 'Whether this payment method has been verified (for future use).';
COMMENT ON COLUMN payment_methods.created_at IS 'When this payment method was created.';
COMMENT ON COLUMN payment_methods.updated_at IS 'When this payment method was last updated.';