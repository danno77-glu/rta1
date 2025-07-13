import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { supabase } from '../../supabase';
import './styles.css';

const CustomerDashboard = ({ customer, onLogout }) => {
  const [audits, setAudits] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [selectedAudit, setSelectedAudit] = useState(null);
  const [damageRecords, setDamageRecords] = useState([]);
  const [expandedPhoto, setExpandedPhoto] = useState(null);
  const navigate = useNavigate();

  useEffect(() => {
    if (!customer) {
      navigate('/customer-portal');
      return;
    }
    fetchAudits();
  }, [customer, navigate]);

  const fetchAudits = async () => {
    try {
      setLoading(true);
      
      // Fetch audits for this customer
      const { data: auditData, error: auditError } = await supabase
        .from('audits')
        .select('*')
        .eq('site_name', customer.name)
        .eq('company_name', customer.company)
        .eq('status', 'Submitted')
        .order('audit_date', { ascending: false });

      if (auditError) throw auditError;

      setAudits(auditData || []);
    } catch (error) {
      console.error('Error fetching audits:', error);
      setError('Failed to load audit history');
    } finally {
      setLoading(false);
    }
  };

  const fetchDamageRecords = async (auditId) => {
    try {
      const { data, error } = await supabase
        .from('damage_records')
        .select('*')
        .eq('audit_id', auditId)
        .order('created_at', { ascending: true });

      if (error) throw error;
      setDamageRecords(data || []);
    } catch (error) {
      console.error('Error fetching damage records:', error);
      setDamageRecords([]);
    }
  };

  const handleAuditSelect = async (audit) => {
    setSelectedAudit(audit);
    await fetchDamageRecords(audit.id);
  };

  const handlePhotoClick = (photoUrl) => {
    setExpandedPhoto(photoUrl);
  };

  const closeExpandedPhoto = () => {
    setExpandedPhoto(null);
  };

  const handleLogout = () => {
    sessionStorage.removeItem('customerPortalAuth');
    onLogout();
    navigate('/customer-portal');
  };

  if (loading) {
    return <div className="loading">Loading your audit history...</div>;
  }

  return (
    <div className="customer-dashboard">
      <div className="dashboard-header">
        <div className="customer-info">
          <h1>Welcome, {customer.name}</h1>
          <p>{customer.company}</p>
        </div>
        <button onClick={handleLogout} className="logout-btn">
          Logout
        </button>
      </div>

      {error && <div className="error-message">{error}</div>}

      <div className="dashboard-content">
        <div className="audits-section">
          <h2>Audit History</h2>
          
          {audits.length === 0 ? (
            <div className="no-audits">
              <p>No audit records found for your account.</p>
            </div>
          ) : (
            <div className="audits-grid">
              {audits.map(audit => (
                <div 
                  key={audit.id} 
                  className={`audit-card ${selectedAudit?.id === audit.id ? 'selected' : ''}`}
                  onClick={() => handleAuditSelect(audit)}
                >
                  <div className="audit-header">
                    <h3>Audit Report</h3>
                    <span className="audit-date">
                      {new Date(audit.audit_date).toLocaleDateString()}
                    </span>
                  </div>
                  
                  <div className="audit-details">
                    <p><strong>Reference:</strong> {audit.reference_number}</p>
                    <p><strong>Auditor:</strong> {audit.auditor_name}</p>
                  </div>

                  <div className="risk-summary">
                    <div className="risk-count red">
                      <span className="count">{audit.red_risks || 0}</span>
                      <span className="label">Critical</span>
                    </div>
                    <div className="risk-count amber">
                      <span className="count">{audit.amber_risks || 0}</span>
                      <span className="label">Caution</span>
                    </div>
                    <div className="risk-count green">
                      <span className="count">{audit.green_risks || 0}</span>
                      <span className="label">Acceptable</span>
                    </div>
                  </div>

                  <div className="audit-status">
                    {audit.audit_sent && <span className="status-badge sent">Report Sent</span>}
                    {audit.quote_sent && <span className="status-badge quoted">Quote Provided</span>}
                    {audit.is_invoiced && <span className="status-badge invoiced">Invoiced</span>}
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>

        {selectedAudit && (
          <div className="audit-details-section">
            <h2>Audit Details - {selectedAudit.reference_number}</h2>
            
            <div className="audit-info">
              <div className="info-grid">
                <div className="info-item">
                  <label>Audit Date:</label>
                  <span>{new Date(selectedAudit.audit_date).toLocaleDateString()}</span>
                </div>
                <div className="info-item">
                  <label>Auditor:</label>
                  <span>{selectedAudit.auditor_name}</span>
                </div>
                <div className="info-item">
                  <label>Site:</label>
                  <span>{selectedAudit.site_name}</span>
                </div>
                <div className="info-item">
                  <label>Company:</label>
                  <span>{selectedAudit.company_name}</span>
                </div>
              </div>

              {selectedAudit.notes && (
                <div className="audit-notes">
                  <label>Notes:</label>
                  <div 
                    className="notes-content"
                    dangerouslySetInnerHTML={{ __html: selectedAudit.notes }}
                  />
                </div>
              )}
            </div>

            {damageRecords.length > 0 && (
              <div className="damage-records-section">
                <h3>Identified Issues</h3>
                <div className="damage-records">
                  {damageRecords.map(record => (
                    <div key={record.id} className={`damage-record ${record.risk_level.toLowerCase()}`}>
                      <div className="damage-header">
                        <div className="damage-title">
                          <h4>{record.damage_type}</h4>
                          <span className={`risk-badge ${record.risk_level.toLowerCase()}`}>
                            {record.risk_level}
                          </span>
                        </div>
                        <span className="reference-number">
                          Ref: {record.reference_number}
                        </span>
                      </div>

                      <div className="damage-content">
                        <div className="damage-info">
                          <p><strong>Location:</strong> {record.location_details}</p>
                          {record.building_area && (
                            <p><strong>Building/Area:</strong> {record.building_area}</p>
                          )}
                          <p><strong>Brand:</strong> {record.brand || 'Not specified'}</p>
                          <p><strong>Recommendation:</strong> {record.recommendation}</p>
                          {record.notes && (
                            <p><strong>Notes:</strong> {record.notes}</p>
                          )}
                        </div>

                        {record.photo_url && (
                          <div className="damage-photo">
                            <div 
                              className="photo-thumbnail"
                              onClick={() => handlePhotoClick(record.photo_url)}
                            >
                              <img 
                                src={record.photo_url} 
                                alt="Damage" 
                                className="damage-image"
                              />
                              <div className="photo-overlay">
                                <span>Click to enlarge</span>
                              </div>
                            </div>
                          </div>
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>
        )}
      </div>

      {expandedPhoto && (
        <div className="photo-modal" onClick={closeExpandedPhoto}>
          <div className="photo-modal-content" onClick={(e) => e.stopPropagation()}>
            <button className="close-modal" onClick={closeExpandedPhoto}>×</button>
            <img src={expandedPhoto} alt="Enlarged damage" className="enlarged-photo" />
          </div>
        </div>
      )}
    </div>
  );
};

export default CustomerDashboard;