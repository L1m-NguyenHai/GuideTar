-- Add billing tracking columns to payment transactions
ALTER TABLE payment_transactions ADD COLUMN IF NOT EXISTS plan_id UUID REFERENCES subscription_plans(id);
ALTER TABLE payment_transactions ADD COLUMN IF NOT EXISTS billing_cycle TEXT;

-- Add renewal date tracking to user subscriptions
ALTER TABLE user_subscriptions ADD COLUMN IF NOT EXISTS renew_at TIMESTAMP WITH TIME ZONE;

-- Update plan prices to match UI requirements (Maestro: 63k/month, 600k/year)
UPDATE subscription_plans SET price_monthly = 63000, price_yearly = 600000 WHERE code = 'MAESTRO';
UPDATE subscription_plans SET price_monthly = 0, price_yearly = 0 WHERE code = 'SOLO';
