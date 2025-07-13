import React, { useState, useEffect } from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import CustomerLogin from './CustomerLogin';
import CustomerDashboard from './CustomerDashboard';

const CustomerPortal = () => {
  const [customer, setCustomer] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Check if customer is already logged in
    const storedAuth = sessionStorage.getItem('customerPortalAuth');
    if (storedAuth) {
      try {
        const customerData = JSON.parse(storedAuth);
        setCustomer(customerData);
      } catch (error) {
        console.error('Error parsing stored auth:', error);
        sessionStorage.removeItem('customerPortalAuth');
      }
    }
    setLoading(false);
  }, []);

  const handleLogin = (customerData) => {
    setCustomer(customerData);
  };

  const handleLogout = () => {
    setCustomer(null);
  };

  if (loading) {
    return <div className="loading">Loading...</div>;
  }

  return (
    <Routes>
      <Route 
        path="/" 
        element={
          customer ? 
            <Navigate to="/customer-portal/dashboard" replace /> : 
            <CustomerLogin onLogin={handleLogin} />
        } 
      />
      <Route 
        path="/dashboard" 
        element={
          customer ? 
            <CustomerDashboard customer={customer} onLogout={handleLogout} /> : 
            <Navigate to="/customer-portal" replace />
        } 
      />
    </Routes>
  );
};

export default CustomerPortal;