/*
  # Add Test Customer Data for Portal Testing

  1. New Customer
    - Danny Williams from DMD Storage Group
    - Email: dannyw@dmd.com.au
    - Active status for portal access

  2. Sample Audits
    - Two realistic audit records with damage data
    - Mix of risk levels and detailed information
    - Photos and comprehensive damage records

  3. Test Data
    - Auditor: John Smith
    - Damage records with various risk levels
    - Realistic recommendations and notes
*/

-- First, ensure we have a test auditor
INSERT INTO auditors (id, name, color, email, phone, created_at, updated_at) 
VALUES (
  'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
  'John Smith',
  '#3b82f6',
  'john.smith@dmd.com.au',
  '+61 8 9410 9400',
  now(),
  now()
) ON CONFLICT (id) DO NOTHING;

-- Add test customer
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
  'c1b2a3d4-e5f6-7890-abcd-ef1234567890',
  'Danny Williams',
  'DMD Storage Group',
  'dannyw@dmd.com.au',
  '6 Renewable Chase, Bibra Lake WA 6163',
  '+61 8 9410 9400',
  '2025-12-01',
  'John Smith',
  true,
  true,
  2500.00,
  'Key customer - priority service required',
  true,
  now(),
  now()
) ON CONFLICT (id) DO NOTHING;

-- Add first test audit (recent)
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
  is_archived,
  pallet_racking_brand,
  created_at,
  updated_at
) VALUES (
  'audit001-1234-5678-9abc-def123456789',
  'RA250201001',
  'John Smith',
  'Danny Williams',
  'DMD Storage Group',
  '2025-02-01',
  2,
  3,
  1,
  '<p>Comprehensive audit completed. Several critical issues identified requiring immediate attention.</p><p><strong>Key Findings:</strong></p><ul><li>Upright damage in Aisle A requires urgent repair</li><li>Missing safety clips throughout warehouse</li><li>Good overall compliance in newer sections</li></ul>',
  'Submitted',
  true,
  true,
  false,
  false,
  'Dexion',
  now(),
  now()
) ON CONFLICT (id) DO NOTHING;

-- Add second test audit (older)
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
  is_archived,
  pallet_racking_brand,
  created_at,
  updated_at
) VALUES (
  'audit002-1234-5678-9abc-def123456789',
  'RA241201001',
  'John Smith',
  'Danny Williams',
  'DMD Storage Group',
  '2024-12-01',
  1,
  2,
  2,
  '<p>Annual compliance audit completed successfully.</p><p>Overall good condition with minor maintenance items identified.</p>',
  'Submitted',
  true,
  true,
  true,
  false,
  'Dexion',
  now(),
  now()
) ON CONFLICT (id) DO NOTHING;

-- Add damage records for first audit
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
  reference_number,
  price,
  created_at,
  updated_at
) VALUES 
(
  'damage001-1234-5678-9abc-def123456789',
  'audit001-1234-5678-9abc-def123456789',
  'Upright Damaged',
  'RED',
  'A-12-3-L',
  'Main Warehouse',
  'https://images.pexels.com/photos/1267338/pexels-photo-1267338.jpeg',
  'Severe impact damage to upright frame. Immediate unloading required.',
  'Replace Upright',
  'Dexion',
  'DR250201001',
  450.00,
  now(),
  now()
),
(
  'damage002-1234-5678-9abc-def123456789',
  'audit001-1234-5678-9abc-def123456789',
  'Beam Safety Clips Missing',
  'RED',
  'A-15-2-R',
  'Main Warehouse',
  'https://images.pexels.com/photos/1267338/pexels-photo-1267338.jpeg',
  'Multiple safety clips missing on beam connections.',
  'Replace Safety Beam Clip',
  'Dexion',
  'DR250201002',
  25.00,
  now(),
  now()
),
(
  'damage003-1234-5678-9abc-def123456789',
  'audit001-1234-5678-9abc-def123456789',
  'Footplate Damaged/Missing',
  'AMBER',
  'B-08-1-L',
  'Storage Area B',
  'https://images.pexels.com/photos/1267338/pexels-photo-1267338.jpeg',
  'Footplate showing signs of wear and minor damage.',
  'Replace Footplate',
  'Dexion',
  'DR250201003',
  120.00,
  now(),
  now()
),
(
  'damage004-1234-5678-9abc-def123456789',
  'audit001-1234-5678-9abc-def123456789',
  'Horizontal Brace Damaged',
  'AMBER',
  'C-05-4-R',
  'Storage Area C',
  'https://images.pexels.com/photos/1267338/pexels-photo-1267338.jpeg',
  'Minor dent in horizontal brace, structurally sound but requires monitoring.',
  'Replace Horizontal Brace',
  'Dexion',
  'DR250201004',
  85.00,
  now(),
  now()
),
(
  'damage005-1234-5678-9abc-def123456789',
  'audit001-1234-5678-9abc-def123456789',
  'Load Sign Incorrect/Missing',
  'AMBER',
  'D-10-1-L',
  'Loading Dock',
  'https://images.pexels.com/photos/1267338/pexels-photo-1267338.jpeg',
  'Load capacity sign missing from rack end.',
  'Replace Load Sign',
  'Dexion',
  'DR250201005',
  35.00,
  now(),
  now()
),
(
  'damage006-1234-5678-9abc-def123456789',
  'audit001-1234-5678-9abc-def123456789',
  'Mesh Deck missing/damaged',
  'GREEN',
  'E-03-2-R',
  'Storage Area E',
  'https://images.pexels.com/photos/1267338/pexels-photo-1267338.jpeg',
  'Minor surface rust on mesh deck, no structural impact.',
  'Continue to monitor',
  'Dexion',
  'DR250201006',
  0.00,
  now(),
  now()
);

-- Add damage records for second audit
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
  reference_number,
  price,
  created_at,
  updated_at
) VALUES 
(
  'damage007-1234-5678-9abc-def123456789',
  'audit002-1234-5678-9abc-def123456789',
  'Beam Safety Clips Missing',
  'RED',
  'A-20-3-L',
  'Main Warehouse',
  'https://images.pexels.com/photos/1267338/pexels-photo-1267338.jpeg',
  'Safety clip missing from beam connection.',
  'Replace Safety Beam Clip',
  'Dexion',
  'DR241201001',
  25.00,
  now(),
  now()
),
(
  'damage008-1234-5678-9abc-def123456789',
  'audit002-1234-5678-9abc-def123456789',
  'Row Spacer Damaged/Missing',
  'AMBER',
  'B-12-2-R',
  'Storage Area B',
  'https://images.pexels.com/photos/1267338/pexels-photo-1267338.jpeg',
  'Row spacer showing minor damage but still functional.',
  'Replace Row Spacer',
  'Dexion',
  'DR241201002',
  65.00,
  now(),
  now()
),
(
  'damage009-1234-5678-9abc-def123456789',
  'audit002-1234-5678-9abc-def123456789',
  'Diagonal Brace Damaged',
  'AMBER',
  'C-08-1-L',
  'Storage Area C',
  'https://images.pexels.com/photos/1267338/pexels-photo-1267338.jpeg',
  'Minor bend in diagonal brace, monitoring recommended.',
  'Replace Diagonal Brace',
  'Dexion',
  'DR241201003',
  75.00,
  now(),
  now()
),
(
  'damage010-1234-5678-9abc-def123456789',
  'audit002-1234-5678-9abc-def123456789',
  'Barrier/Guard Damaged/Missing',
  'GREEN',
  'D-15-4-R',
  'Loading Dock',
  'https://images.pexels.com/photos/1267338/pexels-photo-1267338.jpeg',
  'Barrier in good condition, minor scuff marks only.',
  'Continue to monitor',
  'Dexion',
  'DR241201004',
  0.00,
  now(),
  now()
),
(
  'damage011-1234-5678-9abc-def123456789',
  'audit002-1234-5678-9abc-def123456789',
  'Floor Fixing Damaged/Missing',
  'GREEN',
  'E-05-1-L',
  'Storage Area E',
  'https://images.pexels.com/photos/1267338/pexels-photo-1267338.jpeg',
  'Floor fixing secure and in good condition.',
  'Continue to monitor',
  'Dexion',
  'DR241201005',
  0.00,
  now(),
  now()
);