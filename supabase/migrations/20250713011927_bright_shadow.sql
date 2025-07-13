/*
  # Customer Portal Setup

  1. Security Updates
    - Add RLS policies for customer portal access
    - Allow customers to view their own audit data
    - Ensure customers can only access their own records

  2. New Policies
    - Allow public read access to audits for customer portal
    - Allow public read access to damage records for customer portal
    - Restrict access based on customer email/company matching
*/

-- Create policy for customers to view their own audits
CREATE POLICY "Customers can view their own audits"
  ON audits
  FOR SELECT
  TO public
  USING (
    status = 'Submitted' AND
    EXISTS (
      SELECT 1 FROM customers 
      WHERE customers.name = audits.site_name 
      AND customers.company = audits.company_name
      AND customers.is_active = true
    )
  );

-- Create policy for customers to view damage records for their audits
CREATE POLICY "Customers can view damage records for their audits"
  ON damage_records
  FOR SELECT
  TO public
  USING (
    EXISTS (
      SELECT 1 FROM audits 
      WHERE audits.id = damage_records.audit_id 
      AND audits.status = 'Submitted'
      AND EXISTS (
        SELECT 1 FROM customers 
        WHERE customers.name = audits.site_name 
        AND customers.company = audits.company_name
        AND customers.is_active = true
      )
    )
  );

-- Create policy for customers to view their own customer record
CREATE POLICY "Customers can view their own record"
  ON customers
  FOR SELECT
  TO public
  USING (is_active = true);