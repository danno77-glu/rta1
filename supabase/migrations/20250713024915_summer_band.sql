/*
  # Add test customer data for portal testing

  1. New Customer
    - Creates a test customer with email dannyw@dmd.com.au
    - Sets up basic customer information for portal testing
    - Marks customer as active for portal access

  2. Test Audit Data
    - Creates sample audit records for the test customer
    - Includes damage records with various risk levels
    - Provides realistic test data for portal demonstration
*/

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
  has_drawing
) VALUES (
  gen_random_uuid(),
  'Danny Williams',
  'DMD Storage Group',
  'dannyw@dmd.com.au',
  '123 Test Street, Perth WA 6000',
  '+61 8 9123 4567',
  '2025-06-01',
  'John Smith',
  true,
  true,
  2500.00,
  'Test customer for portal demonstration',
  true
) ON CONFLICT (email) DO UPDATE SET
  name = EXCLUDED.name,
  company = EXCLUDED.company,
  is_active = EXCLUDED.is_active;

-- Insert test audit for the customer
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
  audit_sent,
  quote_sent,
  is_invoiced,
  is_archived
) VALUES (
  gen_random_uuid(),
  'RA250301001',
  'John Smith',
  'Danny Williams',
  'DMD Storage Group',
  '2025-02-15',
  2,
  3,
  1,
  '<p>Comprehensive rack audit completed. Several issues identified requiring attention.</p><p><strong>Key findings:</strong></p><ul><li>Critical damage to upright in Aisle A</li><li>Missing safety clips in multiple locations</li><li>General wear and tear noted</li></ul>',
  'Submitted',
  true,
  false,
  false,
  false
) ON CONFLICT (reference_number) DO UPDATE SET
  auditor_name = EXCLUDED.auditor_name,
  site_name = EXCLUDED.site_name,
  company_name = EXCLUDED.company_name;

-- Get the audit ID for damage records
DO $$
DECLARE
    audit_uuid uuid;
BEGIN
    SELECT id INTO audit_uuid FROM audits WHERE reference_number = 'RA250301001';
    
    -- Insert test damage records
    INSERT INTO damage_records (
      id,
      audit_id,
      damage_type,
      risk_level,
      location_details,
      building_area,
      photo_url,
      notes,
      recommendation,
      brand,
      reference_number
    ) VALUES 
    (
      gen_random_uuid(),
      audit_uuid,
      'Upright Damaged',
      'RED',
      'A-12-3-L',
      'Warehouse A',
      'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=400',
      'Severe impact damage to upright frame',
      'Replace Upright',
      'Dexion',
      'DR250301001'
    ),
    (
      gen_random_uuid(),
      audit_uuid,
      'Beam Safety Clips Missing',
      'AMBER',
      'B-05-2-R',
      'Warehouse B',
      'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400',
      'Multiple safety clips missing from beam connections',
      'Replace Safety Beam Clip',
      'Colby',
      'DR250301002'
    ),
    (
      gen_random_uuid(),
      audit_uuid,
      'Mesh Deck missing/damaged',
      'AMBER',
      'A-08-1-L',
      'Warehouse A',
      NULL,
      'Wire mesh deck showing signs of wear',
      'Replace Mesh Deck',
      'Dexion',
      'DR250301003'
    ),
    (
      gen_random_uuid(),
      audit_uuid,
      'Footplate Damaged/Missing',
      'AMBER',
      'C-15-1-R',
      'Warehouse C',
      'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400',
      'Footplate showing minor damage but still functional',
      'Replace Footplate',
      'Stakrak',
      'DR250301004'
    ),
    (
      gen_random_uuid(),
      audit_uuid,
      'Load Sign Incorrect/Missing',
      'GREEN',
      'B-20-4-L',
      'Warehouse B',
      NULL,
      'Load sign present but faded, still readable',
      'Continue to monitor',
      'Colby',
      'DR250301005'
    ),
    (
      gen_random_uuid(),
      audit_uuid,
      'Beam Damaged',
      'RED',
      'A-03-2-R',
      'Warehouse A',
      'https://images.unsplash.com/photo-1504328345606-18bbc8c9d7d1?w=400',
      'Significant deformation in beam structure',
      'Replace Beam',
      'Dexion',
      'DR250301006'
    )
    ON CONFLICT (reference_number) DO NOTHING;
END $$;

-- Insert a second audit for more test data
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
  audit_sent,
  quote_sent,
  is_invoiced,
  is_archived
) VALUES (
  gen_random_uuid(),
  'RA241215001',
  'Sarah Johnson',
  'Danny Williams',
  'DMD Storage Group',
  '2024-12-15',
  0,
  1,
  2,
  '<p>Follow-up audit showing good improvement from previous recommendations.</p><p><strong>Summary:</strong></p><ul><li>Most critical issues have been addressed</li><li>Only minor maintenance items remaining</li><li>Overall compliance significantly improved</li></ul>',
  'Submitted',
  true,
  true,
  true,
  false
) ON CONFLICT (reference_number) DO UPDATE SET
  auditor_name = EXCLUDED.auditor_name,
  site_name = EXCLUDED.site_name,
  company_name = EXCLUDED.company_name;

-- Add damage records for second audit
DO $$
DECLARE
    audit_uuid uuid;
BEGIN
    SELECT id INTO audit_uuid FROM audits WHERE reference_number = 'RA241215001';
    
    INSERT INTO damage_records (
      id,
      audit_id,
      damage_type,
      risk_level,
      location_details,
      building_area,
      photo_url,
      notes,
      recommendation,
      brand,
      reference_number
    ) VALUES 
    (
      gen_random_uuid(),
      audit_uuid,
      'Horizontal Brace Damaged',
      'AMBER',
      'A-07-3-L',
      'Warehouse A',
      'https://images.unsplash.com/photo-1581094794329-c8112a89af12?w=400',
      'Minor damage to horizontal brace, still structurally sound',
      'Replace Horizontal Brace',
      'Dexion',
      'DR241215001'
    ),
    (
      gen_random_uuid(),
      audit_uuid,
      'Load Sign Incorrect/Missing',
      'GREEN',
      'B-12-2-R',
      'Warehouse B',
      NULL,
      'Load sign in good condition',
      'Continue to monitor',
      'Colby',
      'DR241215002'
    ),
    (
      gen_random_uuid(),
      audit_uuid,
      'Row Spacer Damaged/Missing',
      'GREEN',
      'C-09-1-L',
      'Warehouse C',
      NULL,
      'Row spacer showing minor wear but functioning correctly',
      'Continue to monitor',
      'Stakrak',
      'DR241215003'
    )
    ON CONFLICT (reference_number) DO NOTHING;
END $$;