/*
  # Add test customer data for portal testing

  This migration only adds test customer data without modifying any table structures.
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
  created_at,
  updated_at
) VALUES (
  'f47ac10b-58cc-4372-a567-0e02b2c3d479',
  'Danny Williams',
  'DMD Storage Group',
  'dannyw@dmd.com.au',
  '123 Test Street, Perth WA 6000',
  '+61 8 9410 9400',
  true,
  now(),
  now()
) ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  company = EXCLUDED.company,
  email = EXCLUDED.email,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  is_active = EXCLUDED.is_active,
  updated_at = now();

-- Insert test audit
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
  created_at,
  updated_at
) VALUES (
  'a47ac10b-58cc-4372-a567-0e02b2c3d480',
  'RA240101001',
  'John Smith',
  'Danny Williams',
  'DMD Storage Group',
  '2024-01-15',
  2,
  3,
  1,
  'Routine annual inspection completed. Several issues identified requiring attention.',
  'Submitted',
  now(),
  now()
) ON CONFLICT (id) DO UPDATE SET
  reference_number = EXCLUDED.reference_number,
  auditor_name = EXCLUDED.auditor_name,
  site_name = EXCLUDED.site_name,
  company_name = EXCLUDED.company_name,
  audit_date = EXCLUDED.audit_date,
  red_risks = EXCLUDED.red_risks,
  amber_risks = EXCLUDED.amber_risks,
  green_risks = EXCLUDED.green_risks,
  notes = EXCLUDED.notes,
  status = EXCLUDED.status,
  updated_at = now();

-- Insert test damage records
INSERT INTO damage_records (
  id,
  audit_id,
  damage_type,
  risk_level,
  location_details,
  photo_url,
  notes,
  recommendation,
  created_at,
  updated_at
) VALUES 
(
  'b47ac10b-58cc-4372-a567-0e02b2c3d481',
  'a47ac10b-58cc-4372-a567-0e02b2c3d480',
  'Upright Damaged',
  'RED',
  'Aisle A, Bay 3, Level 2, Left Side',
  'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=400',
  'Significant damage to upright beam requiring immediate attention',
  'Replace damaged upright beam immediately',
  now(),
  now()
),
(
  'c47ac10b-58cc-4372-a567-0e02b2c3d482',
  'a47ac10b-58cc-4372-a567-0e02b2c3d480',
  'Beam Safety Clips Missing',
  'AMBER',
  'Aisle B, Bay 1, Level 3, Right Side',
  'https://images.unsplash.com/photo-1504328345606-18bbc8c9d7d1?w=400',
  'Safety clips missing from beam connection',
  'Install safety clips on beam connections',
  now(),
  now()
),
(
  'd47ac10b-58cc-4372-a567-0e02b2c3d483',
  'a47ac10b-58cc-4372-a567-0e02b2c3d480',
  'Load Sign Incorrect/Missing',
  'GREEN',
  'Aisle C, Bay 5, Level 1, Front',
  null,
  'Load sign needs updating with current capacity',
  'Update load signage',
  now(),
  now()
) ON CONFLICT (id) DO UPDATE SET
  audit_id = EXCLUDED.audit_id,
  damage_type = EXCLUDED.damage_type,
  risk_level = EXCLUDED.risk_level,
  location_details = EXCLUDED.location_details,
  photo_url = EXCLUDED.photo_url,
  notes = EXCLUDED.notes,
  recommendation = EXCLUDED.recommendation,
  updated_at = now();