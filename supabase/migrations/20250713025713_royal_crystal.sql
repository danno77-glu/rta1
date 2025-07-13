/*
  # Add test customer data for portal testing

  1. New Customer
    - `dannyw@dmd.com.au` - Danny Williams from DMD Storage Group
    - Active customer with audit history
  
  2. Sample Audits
    - Two completed audits with damage records
    - Realistic data for testing customer portal
    
  3. Damage Records
    - Multiple damage types with photos
    - Mix of risk levels (RED, AMBER, GREEN)
*/

-- First, let's check if the customer already exists and delete if needed
DELETE FROM customers WHERE email = 'dannyw@dmd.com.au';

-- Insert test customer
INSERT INTO customers (
  id,
  name,
  company,
  email,
  address,
  phone,
  next_audit_due,
  default_auditor,
  is_active,
  auto_marketing,
  audit_price,
  notes,
  has_drawing,
  created_at,
  updated_at
) VALUES (
  gen_random_uuid(),
  'Danny Williams',
  'DMD Storage Group',
  'dannyw@dmd.com.au',
  '6 Renewable Chase, Bibra Lake WA 6163',
  '+61 8 9410 9400',
  '2025-12-15',
  'John Smith',
  true,
  true,
  2500.00,
  'Key customer - priority support',
  true,
  now(),
  now()
);

-- Get the customer ID for reference
DO $$
DECLARE
    customer_uuid uuid;
    audit1_uuid uuid;
    audit2_uuid uuid;
BEGIN
    -- Get customer ID
    SELECT id INTO customer_uuid FROM customers WHERE email = 'dannyw@dmd.com.au';
    
    -- Insert first audit (recent)
    INSERT INTO audits (
      id,
      reference_number,
      auditor_name,
      site_name,
      company_name,
      audit_date,
      red_risks,
      amber_risks,
      green_risks,
      notes,
      status,
      pallet_racking_brand,
      is_invoiced,
      quote_sent,
      is_archived,
      audit_sent,
      created_at,
      updated_at
    ) VALUES (
      gen_random_uuid(),
      'RA250215001',
      'John Smith',
      'Danny Williams',
      'DMD Storage Group',
      '2025-02-15',
      2,
      3,
      1,
      '<p>Comprehensive audit completed. Several critical issues identified requiring immediate attention. Overall warehouse condition is good with some maintenance required.</p>',
      'Submitted',
      'Dexion',
      false,
      true,
      false,
      true,
      '2025-02-15 10:00:00+00',
      now()
    ) RETURNING id INTO audit1_uuid;
    
    -- Insert damage records for first audit
    INSERT INTO damage_records (
      id,
      audit_id,
      damage_type,
      risk_level,
      location_details,
      photo_url,
      notes,
      recommendation,
      price,
      brand,
      reference_number,
      building_area,
      created_at,
      updated_at
    ) VALUES 
    (
      gen_random_uuid(),
      audit1_uuid,
      'Upright Damaged',
      'RED',
      'A1-B3-L2-S1',
      'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=400',
      'Severe impact damage to upright frame',
      'Replace Upright',
      450.00,
      'Dexion',
      'DR250215001',
      'Warehouse A',
      now(),
      now()
    ),
    (
      gen_random_uuid(),
      audit1_uuid,
      'Beam Safety Clips Missing',
      'RED',
      'A2-B1-L3-S2',
      'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400',
      'Multiple safety clips missing from beam connections',
      'Replace Safety Beam Clip',
      25.00,
      'Dexion',
      'DR250215002',
      'Warehouse A',
      now(),
      now()
    ),
    (
      gen_random_uuid(),
      audit1_uuid,
      'Footplate Damaged/Missing',
      'AMBER',
      'B1-B2-L1-S1',
      'https://images.unsplash.com/photo-1504328345606-18bbc8c9d7d1?w=400',
      'Footplate showing signs of wear and minor damage',
      'Replace Footplate',
      180.00,
      'Dexion',
      'DR250215003',
      'Warehouse B',
      now(),
      now()
    ),
    (
      gen_random_uuid(),
      audit1_uuid,
      'Horizontal Brace Damaged',
      'AMBER',
      'B2-B4-L2-S2',
      'https://images.unsplash.com/photo-1581094794329-c8112a89af12?w=400',
      'Horizontal brace bent but still functional',
      'Replace Horizontal Brace',
      120.00,
      'Dexion',
      'DR250215004',
      'Warehouse B',
      now(),
      now()
    ),
    (
      gen_random_uuid(),
      audit1_uuid,
      'Load Sign Incorrect/Missing',
      'AMBER',
      'C1-B1-L1-S1',
      'https://images.unsplash.com/photo-1562654501-a0ccc0fc3fb1?w=400',
      'Load capacity signage is faded and illegible',
      'Replace Load Sign',
      35.00,
      'Dexion',
      'DR250215005',
      'Warehouse C',
      now(),
      now()
    ),
    (
      gen_random_uuid(),
      audit1_uuid,
      'Mesh Deck missing/damaged',
      'GREEN',
      'A3-B2-L2-S1',
      'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
      'Minor surface rust on mesh deck but structurally sound',
      'Continue to monitor',
      0.00,
      'Dexion',
      'DR250215006',
      'Warehouse A',
      now(),
      now()
    );
    
    -- Insert second audit (older)
    INSERT INTO audits (
      id,
      reference_number,
      auditor_name,
      site_name,
      company_name,
      audit_date,
      red_risks,
      amber_risks,
      green_risks,
      notes,
      status,
      pallet_racking_brand,
      is_invoiced,
      quote_sent,
      is_archived,
      audit_sent,
      created_at,
      updated_at
    ) VALUES (
      gen_random_uuid(),
      'RA241215001',
      'Sarah Johnson',
      'Danny Williams',
      'DMD Storage Group',
      '2024-12-15',
      1,
      2,
      2,
      '<p>Annual compliance audit completed. Good overall condition with minor maintenance items identified.</p>',
      'Submitted',
      'Dexion',
      true,
      true,
      false,
      true,
      '2024-12-15 14:00:00+00',
      now()
    ) RETURNING id INTO audit2_uuid;
    
    -- Insert damage records for second audit
    INSERT INTO damage_records (
      id,
      audit_id,
      damage_type,
      risk_level,
      location_details,
      photo_url,
      notes,
      recommendation,
      price,
      brand,
      reference_number,
      building_area,
      created_at,
      updated_at
    ) VALUES 
    (
      gen_random_uuid(),
      audit2_uuid,
      'Beam Dislodged',
      'RED',
      'A1-B1-L3-S1',
      'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=400',
      'Beam partially dislodged from frame connection',
      'Re-Engage Dislodged Beam',
      85.00,
      'Dexion',
      'DR241215001',
      'Warehouse A',
      now(),
      now()
    ),
    (
      gen_random_uuid(),
      audit2_uuid,
      'Floor Fixing Damaged/Missing',
      'AMBER',
      'B1-B3-L1-S2',
      'https://images.unsplash.com/photo-1590736969955-71cc94901144?w=400',
      'Floor anchor bolt showing signs of loosening',
      'Replace Floor Fixing',
      65.00,
      'Dexion',
      'DR241215002',
      'Warehouse B',
      now(),
      now()
    ),
    (
      gen_random_uuid(),
      audit2_uuid,
      'Diagonal Brace Damaged',
      'AMBER',
      'A2-B2-L2-S1',
      'https://images.unsplash.com/photo-1565814329452-e1efa11c5b89?w=400',
      'Minor dent in diagonal brace, still functional',
      'Replace Diagonal Brace',
      95.00,
      'Dexion',
      'DR241215003',
      'Warehouse A',
      now(),
      now()
    ),
    (
      gen_random_uuid(),
      audit2_uuid,
      'Row Spacer Damaged/Missing',
      'GREEN',
      'C1-B2-L1-S1',
      'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400',
      'Row spacer in good condition, minor surface wear',
      'Continue to monitor',
      0.00,
      'Dexion',
      'DR241215004',
      'Warehouse C',
      now(),
      now()
    ),
    (
      gen_random_uuid(),
      audit2_uuid,
      'Barrier/Guard Damaged/Missing',
      'GREEN',
      'B2-B1-L1-S2',
      'https://images.unsplash.com/photo-1586953208448-b95a79798f07?w=400',
      'Safety barrier in excellent condition',
      'Continue to monitor',
      0.00,
      'Dexion',
      'DR241215005',
      'Warehouse B',
      now(),
      now()
    );
    
END $$;