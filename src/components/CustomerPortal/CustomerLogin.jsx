import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { supabase } from '../../supabase';
import './styles.css';

const CustomerLogin = ({ onLogin }) => {
  const [email, setEmail] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    setSuccess('');

    try {
      // Check if customer exists with this email
      const { data: customer, error: customerError } = await supabase
        .from('customers')
        .select('*')
        .eq('email', email)
        .eq('is_active', true)
        .single();

      if (customerError || !customer) {
        setError('No active customer account found with this email address.');
        return;
      }

      // Store customer info in session storage
      sessionStorage.setItem('customerPortalAuth', JSON.stringify({
        id: customer.id,
        name: customer.name,
        company: customer.company,
        email: customer.email
      }));

      setSuccess('Login successful! Redirecting...');
      onLogin(customer);
      
      setTimeout(() => {
        navigate('/customer-portal/dashboard');
      }, 1000);

    } catch (error) {
      console.error('Login error:', error);
      setError('An error occurred during login. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="customer-login">
      <div className="login-container">
        <div className="login-header">
          <h1>Customer Portal</h1>
          <p>Access your audit history and reports</p>
        </div>

        <form onSubmit={handleSubmit} className="login-form">
          {error && <div className="error-message">{error}</div>}
          {success && <div className="success-message">{success}</div>}

          <div className="form-group">
            <label htmlFor="email">Email Address</label>
            <input
              id="email"
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="Enter your registered email address"
              required
              disabled={loading}
            />
          </div>

          <button 
            type="submit" 
            className="login-btn"
            disabled={loading || !email}
          >
            {loading ? 'Verifying...' : 'Access Portal'}
          </button>
        </form>

        <div className="login-footer">
          <p>
            Don't have access? Contact your audit provider for assistance.
          </p>
        </div>
      </div>
    </div>
  );
};

export default CustomerLogin;