-- Check if brand column exists, add only if it doesn't
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'damage_records' AND column_name = 'brand'
  ) THEN
    ALTER TABLE damage_records ADD COLUMN brand text;
  END IF;
END $$;

-- Create brands table if it doesn't exist
CREATE TABLE IF NOT EXISTS brands (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text UNIQUE NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create brand_prices table if it doesn't exist
CREATE TABLE IF NOT EXISTS brand_prices (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  brand_id uuid REFERENCES brands(id) ON DELETE CASCADE,
  damage_type text NOT NULL,
  price numeric NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(brand_id, damage_type)
);

-- Enable RLS only if not already enabled
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_tables 
    WHERE tablename = 'brands' AND rowsecurity = true
  ) THEN
    ALTER TABLE brands ENABLE ROW LEVEL SECURITY;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_tables 
    WHERE tablename = 'brand_prices' AND rowsecurity = true
  ) THEN
    ALTER TABLE brand_prices ENABLE ROW LEVEL SECURITY;
  END IF;
END $$;

-- Create policies for brands (drop if exists first)
DROP POLICY IF EXISTS "Enable read access for all users" ON brands;
DROP POLICY IF EXISTS "Enable write access for authenticated users" ON brands;

CREATE POLICY "Enable read access for all users" ON brands
  FOR SELECT TO public USING (true);

CREATE POLICY "Enable write access for authenticated users" ON brands
  FOR ALL TO authenticated USING (true);

-- Create policies for brand_prices (drop if exists first)
DROP POLICY IF EXISTS "Enable read access for all users" ON brand_prices;
DROP POLICY IF EXISTS "Enable write access for authenticated users" ON brand_prices;

CREATE POLICY "Enable read access for all users" ON brand_prices
  FOR SELECT TO public USING (true);

CREATE POLICY "Enable write access for authenticated users" ON brand_prices
  FOR ALL TO authenticated USING (true);