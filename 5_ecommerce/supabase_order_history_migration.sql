-- Create order_history table
-- Run this SQL in your Supabase SQL Editor

CREATE TABLE IF NOT EXISTS order_history (
  order_id BIGSERIAL PRIMARY KEY,
  username TEXT NOT NULL,
  product_id TEXT NOT NULL,
  quantity INTEGER NOT NULL DEFAULT 1,
  unit_price TEXT NOT NULL,
  total_price TEXT NOT NULL,
  delivery_charge TEXT,
  delivery_address TEXT NOT NULL,
  phone TEXT NOT NULL,
  city TEXT NOT NULL,
  postal_code TEXT NOT NULL,
  customer_name TEXT NOT NULL,
  payment_method TEXT DEFAULT 'COD',
  status TEXT DEFAULT 'pending',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index on username for faster queries
CREATE INDEX IF NOT EXISTS idx_order_history_username ON order_history(username);

-- Create index on created_at for sorting
CREATE INDEX IF NOT EXISTS idx_order_history_created_at ON order_history(created_at DESC);

-- Enable Row Level Security
ALTER TABLE order_history ENABLE ROW LEVEL SECURITY;

-- Create policy to allow users to view only their own orders
CREATE POLICY "Users can view their own orders"
  ON order_history
  FOR SELECT
  USING (username = auth.jwt() ->> 'email' OR username = (auth.jwt() -> 'user_metadata' ->> 'username'));

-- Create policy to allow users to insert their own orders
CREATE POLICY "Users can insert their own orders"
  ON order_history
  FOR INSERT
  WITH CHECK (username = auth.jwt() ->> 'email' OR username = (auth.jwt() -> 'user_metadata' ->> 'username'));

-- Optional: Create a function to update the updated_at timestamp automatically
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_order_history_updated_at
  BEFORE UPDATE ON order_history
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
