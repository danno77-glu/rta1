/*
  # Add Test Customer Data for Portal

  This migration adds test customer data for testing the customer portal functionality.
  
  1. Test Customer
    - Name: Danny Williams
    - Company: DMD Storage Group
    - Email: dannyw@dmd.com.au
    
  2. Sample Audit Data
    - Two complete audits with damage records
    - Realistic damage photos from Unsplash
*/

-- Insert test customer
INSERT INTO customers (
  id,
  name,
  company,
  email,
  address,
  phone,
  is_active,
  auto_marketing,
  audit_price,
  notes,
  has_drawing,
  created_at,
  updated_at
) VALUES (
  'f47ac10b-58cc-4372-a567-0e02b2c3d479',
  'Danny Williams',
  'DMD Storage Group',
  'dannyw@dmd.com.au',
  '123 Industrial Drive, Perth WA 6000',
  '+61 8 9123 4567',
  true,
  true,
  2500.00,
  'Regular customer - annual audits',
  true,
  now(),
  now()
) ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  company = EXCLUDED.company,
  email = EXCLUDED.email,
  is_active = EXCLUDED.is_active;

-- Insert first test audit
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
  created_at,
  updated_at
) VALUES (
  'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
  'RA240115001',
  'John Smith',
  'Danny Williams',
  'DMD Storage Group',
  '2024-01-15',
  2,
  3,
  1,
  '<p>Comprehensive rack audit completed. Several critical issues identified requiring immediate attention.</p>',
  'Submitted',
  true,
  true,
  false,
  '2024-01-15 10:00:00+00',
  '2024-01-15 10:00:00+00'
) ON CONFLICT (id) DO UPDATE SET
  reference_number = EXCLUDED.reference_number,
  status = EXCLUDED.status;

-- Insert damage records for first audit
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
  created_at,
  updated_at
) VALUES 
(
  'dr001-2024-001',
  'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
  'Upright Damaged',
  'RED',
  'A1-B2-L3-S1',
  'Warehouse A',
  'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=400&h=300&fit=crop',
  'Significant structural damage to upright beam',
  'Replace upright immediately',
  'Dexion',
  'DR240115001',
  '2024-01-15 10:30:00+00',
  '2024-01-15 10:30:00+00'
),
(
  'dr001-2024-002',
  'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
  'Beam Safety Clips Missing',
  'AMBER',
  'A2-B1-L2-S2',
  'Warehouse A',
  'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400&h=300&fit=crop',
  'Multiple safety clips missing from beam connections',
  'Install safety clips',
  'Dexion',
  'DR240115002',
  '2024-01-15 11:00:00+00',
  '2024-01-15 11:00:00+00'
),
(
  'dr001-2024-003',
  'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
  'Load Sign Incorrect/Missing',
  'GREEN',
  'A3-B1-L1-S1',
  'Warehouse A',
  'https://images.unsplash.com/photo-1504328345606-18bbc8c9d7d1?w=400&h=300&fit=crop',
  'Load sign present but needs updating',
  'Continue to monitor',
  'Dexion',
  'DR240115003',
  '2024-01-15 11:30:00+00',
  '2024-01-15 11:30:00+00'
) ON CONFLICT (id) DO NOTHING;

-- Insert second test audit
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
  created_at,
  updated_at
) VALUES (
  'a2b3c4d5-e6f7-8901-bcde-f23456789012',
  'RA240301002',
  'Sarah Johnson',
  'Danny Williams',
  'DMD Storage Group',
  '2024-03-01',
  1,
  2,
  4,
  '<p>Follow-up audit showing improvement. Most critical issues from previous audit have been addressed.</p>',
  'Submitted',
  true,
  false,
  false,
  '2024-03-01 09:00:00+00',
  '2024-03-01 09:00:00+00'
) ON CONFLICT (id) DO UPDATE SET
  reference_number = EXCLUDED.reference_number,
  status = EXCLUDED.status;

-- Insert damage records for second audit
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
  created_at,
  updated_at
) VALUES 
(
  'dr002-2024-001',
  'a2b3c4d5-e6f7-8901-bcde-f23456789012',
  'Footplate Damaged/Missing',
  'RED',
  'B1-B3-L1-S1',
  'Warehouse B',
  'https://images.unsplash.com/photo-1581094794329-c8112a89af12?w=400&h=300&fit=crop',
  'Footplate completely missing, creating instability',
  'Replace footplate immediately',
  'Colby',
  'DR240301001',
  '2024-03-01 09:30:00+00',
  '2024-03-01 09:30:00+00'
),
(
  'dr002-2024-002',
  'a2b3c4d5-e6f7-8901-bcde-f23456789012',
  'Mesh Deck missing/damaged',
  'AMBER',
  'B2-B2-L3-S1',
  'Warehouse B',
  'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&h=300&fit=crop',
  'Mesh deck showing signs of wear',
  'Replace mesh deck',
  'Colby',
  'DR240301002',
  '2024-03-01 10:00:00+00',
  '2024-03-01 10:00:00+00'
),
(
  'dr002-2024-003',
  'a2b3c4d5-e6f7-8901-bcde-f23456789012',
  'Beam Damaged',
  'GREEN',
  'B3-B1-L2-S2',
  'Warehouse B',
  'https://images.unsplash.com/photo-1565814329452-e1efa11c5b89?w=400&h=300&fit=crop',
  'Minor surface damage, structurally sound',
  'Continue to monitor',
  'Colby',
  'DR240301003',
  '2024-03-01 10:30:00+00',
  '2024-03-01 10:30:00+00'
) ON CONFLICT (id) DO NOTHING;