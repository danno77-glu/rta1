/*
  # Safe migration - only add what doesn't exist
  
  This migration safely adds missing columns and tables without errors.
*/

-- Only create brands table if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'brands') THEN
        CREATE TABLE brands (
            id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
            name text UNIQUE NOT NULL,
            created_at timestamptz DEFAULT now(),
            updated_at timestamptz DEFAULT now()
        );
        
        ALTER TABLE brands ENABLE ROW LEVEL SECURITY;
        
        CREATE POLICY "Enable read access for all users" ON brands
            FOR SELECT TO public USING (true);
            
        CREATE POLICY "Enable write access for authenticated users" ON brands
            FOR ALL TO authenticated USING (true);
    END IF;
END $$;

-- Only create brand_prices table if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'brand_prices') THEN
        CREATE TABLE brand_prices (
            id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
            brand_id uuid REFERENCES brands(id) ON DELETE CASCADE,
            damage_type text NOT NULL,
            product_cost numeric DEFAULT 0 NOT NULL,
            installation_cost numeric DEFAULT 0 NOT NULL,
            created_at timestamptz DEFAULT now(),
            updated_at timestamptz DEFAULT now(),
            UNIQUE(brand_id, damage_type)
        );
        
        ALTER TABLE brand_prices ENABLE ROW LEVEL SECURITY;
        
        CREATE POLICY "Enable read access for all users" ON brand_prices
            FOR SELECT TO public USING (true);
            
        CREATE POLICY "Enable write access for authenticated users" ON brand_prices
            FOR ALL TO authenticated USING (true);
    END IF;
END $$;

-- Add test customer data
DO $$
DECLARE
    customer_uuid uuid;
    audit1_uuid uuid;
    audit2_uuid uuid;
BEGIN
    -- Check if test customer already exists
    SELECT id INTO customer_uuid FROM customers WHERE email = 'dannyw@dmd.com.au';
    
    IF customer_uuid IS NULL THEN
        -- Insert test customer
        INSERT INTO customers (
            id, name, company, email, address, phone, 
            next_audit_due, default_auditor, is_active, 
            auto_marketing, audit_price, notes, has_drawing
        ) VALUES (
            gen_random_uuid(),
            'Danny Williams',
            'DMD Storage Group',
            'dannyw@dmd.com.au',
            '6 Renewable Chase Bibra Lake WA 6163',
            '9410 9400',
            '2025-12-01',
            'John Smith',
            true,
            true,
            2500.00,
            'Regular customer - annual audits',
            true
        ) RETURNING id INTO customer_uuid;
        
        -- Insert first audit
        INSERT INTO audits (
            id, reference_number, auditor_name, site_name, company_name,
            audit_date, red_risks, amber_risks, green_risks, notes, status
        ) VALUES (
            gen_random_uuid(),
            'RA250201001',
            'John Smith',
            'Danny Williams',
            'DMD Storage Group',
            '2025-02-01',
            2, 3, 1,
            'Annual compliance audit completed. Several issues identified requiring attention.',
            'Submitted'
        ) RETURNING id INTO audit1_uuid;
        
        -- Insert second audit
        INSERT INTO audits (
            id, reference_number, auditor_name, site_name, company_name,
            audit_date, red_risks, amber_risks, green_risks, notes, status
        ) VALUES (
            gen_random_uuid(),
            'RA241201001',
            'John Smith',
            'Danny Williams',
            'DMD Storage Group',
            '2024-12-01',
            1, 2, 2,
            'Follow-up audit showing improvement from previous recommendations.',
            'Submitted'
        ) RETURNING id INTO audit2_uuid;
        
        -- Insert damage records for first audit
        INSERT INTO damage_records (
            audit_id, damage_type, risk_level, location_details, 
            building_area, photo_url, notes, recommendation, brand, reference_number
        ) VALUES 
        (audit1_uuid, 'Upright Damaged', 'RED', 'A1-B2-L3-Left', 'Warehouse A', 'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=400', 'Severe impact damage to upright', 'Replace Upright', 'Dexion', 'DR250201001'),
        (audit1_uuid, 'Beam Safety Clips Missing', 'AMBER', 'A2-B1-L2-Right', 'Warehouse A', 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400', 'Multiple clips missing', 'Replace Safety Beam Clip', 'Dexion', 'DR250201002'),
        (audit1_uuid, 'Footplate Damaged/Missing', 'RED', 'A3-B4-L1-Left', 'Warehouse B', 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400', 'Footplate completely missing', 'Replace Footplate', 'Colby', 'DR250201003'),
        (audit1_uuid, 'Mesh Deck missing/damaged', 'AMBER', 'A1-B3-L4-Center', 'Warehouse A', 'https://images.unsplash.com/photo-1566228015668-4c45dbc4e2f5?w=400', 'Mesh deck has holes', 'Replace Mesh Deck', 'Dexion', 'DR250201004'),
        (audit1_uuid, 'Load Sign Incorrect/Missing', 'AMBER', 'A2-B2-L1-Right', 'Warehouse B', 'https://images.unsplash.com/photo-1504328345606-18bbc8c9d7d1?w=400', 'Load sign faded and unreadable', 'Replace Load Sign', 'Colby', 'DR250201005'),
        (audit1_uuid, 'Diagonal Brace Damaged', 'GREEN', 'A1-B1-L2-Left', 'Warehouse A', 'https://images.unsplash.com/photo-1581094794329-c8112a89af12?w=400', 'Minor dent in brace', 'Continue to monitor', 'Dexion', 'DR250201006');
        
        -- Insert damage records for second audit
        INSERT INTO damage_records (
            audit_id, damage_type, risk_level, location_details, 
            building_area, photo_url, notes, recommendation, brand, reference_number
        ) VALUES 
        (audit2_uuid, 'Beam Damaged', 'AMBER', 'A1-B1-L3-Right', 'Warehouse A', 'https://images.unsplash.com/photo-1565814329452-e1efa11c5b89?w=400', 'Beam showing stress cracks', 'Replace Beam', 'Dexion', 'DR241201001'),
        (audit2_uuid, 'Horizontal Brace Damaged', 'RED', 'A2-B3-L2-Left', 'Warehouse B', 'https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=400', 'Brace severely bent', 'Replace Horizontal Brace', 'Colby', 'DR241201002'),
        (audit2_uuid, 'Row Spacer Damaged/Missing', 'AMBER', 'A3-B2-L1-Center', 'Warehouse A', 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400', 'Spacer missing from row', 'Replace Row Spacer', 'Dexion', 'DR241201003'),
        (audit2_uuid, 'Barrier/Guard Damaged/Missing', 'GREEN', 'A1-B4-L4-Right', 'Warehouse B', 'https://images.unsplash.com/photo-1566228015668-4c45dbc4e2f5?w=400', 'Guard rail slightly loose', 'Continue to monitor', 'Colby', 'DR241201004'),
        (audit2_uuid, 'Floor Fixing Damaged/Missing', 'GREEN', 'A2-B1-L1-Left', 'Warehouse A', 'https://images.unsplash.com/photo-1504328345606-18bbc8c9d7d1?w=400', 'One bolt slightly loose', 'Continue to monitor', 'Dexion', 'DR241201005');
    END IF;
END $$;