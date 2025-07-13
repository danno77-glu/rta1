-- Check and add brand column only if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'damage_records' AND column_name = 'brand'
    ) THEN
        ALTER TABLE damage_records ADD COLUMN brand text;
    END IF;
END $$;

-- Check and add reference_number column only if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'damage_records' AND column_name = 'reference_number'
    ) THEN
        ALTER TABLE damage_records ADD COLUMN reference_number text;
    END IF;
END $$;

-- Check and add building_area column only if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'damage_records' AND column_name = 'building_area'
    ) THEN
        ALTER TABLE damage_records ADD COLUMN building_area text;
    END IF;
END $$;

-- Create brands table only if it doesn't exist
CREATE TABLE IF NOT EXISTS brands (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text UNIQUE NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create brand_prices table only if it doesn't exist
CREATE TABLE IF NOT EXISTS brand_prices (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  brand_id uuid REFERENCES brands(id) ON DELETE CASCADE,
  damage_type text NOT NULL,
  price numeric NOT NULL DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(brand_id, damage_type)
);

-- Enable RLS only if not already enabled
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE c.relname = 'brands' AND n.nspname = 'public' AND c.relrowsecurity = true
    ) THEN
        ALTER TABLE brands ENABLE ROW LEVEL SECURITY;
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE c.relname = 'brand_prices' AND n.nspname = 'public' AND c.relrowsecurity = true
    ) THEN
        ALTER TABLE brand_prices ENABLE ROW LEVEL SECURITY;
    END IF;
END $$;

-- Drop existing policies if they exist, then create new ones
DROP POLICY IF EXISTS "Enable read access for all users" ON brands;
DROP POLICY IF EXISTS "Enable write access for authenticated users" ON brands;

CREATE POLICY "Enable read access for all users" ON brands
  FOR SELECT TO public USING (true);

CREATE POLICY "Enable write access for authenticated users" ON brands
  FOR ALL TO authenticated USING (true);

-- Drop existing policies if they exist, then create new ones
DROP POLICY IF EXISTS "Enable read access for all users" ON brand_prices;
DROP POLICY IF EXISTS "Enable write access for authenticated users" ON brand_prices;

CREATE POLICY "Enable read access for all users" ON brand_prices
  FOR SELECT TO public USING (true);

CREATE POLICY "Enable write access for authenticated users" ON brand_prices
  FOR ALL TO authenticated USING (true);