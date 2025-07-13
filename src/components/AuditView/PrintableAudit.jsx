import React, { useState, useEffect } from 'react';
import { supabase } from '../../supabase';
import DOMPurify from 'dompurify';
import html2pdf from 'html2pdf.js';
import './styles.css';
import { useSettings } from '../../contexts/SettingsContext';
import { boxedDamageRecordsTemplate } from '../QuoteTemplates/templates/boxedDamageRecordsTemplate';
import { imageToBase64 } from '../../utils/assetPaths';
import { Document, Packer, Paragraph, TextRun, Table, TableRow, TableCell, WidthType } from 'docx';

const PrintableAudit = ({ audit, damageRecords, onClose, auditorDetails }) => {
  const [templates, setTemplates] = useState([]);
  const [selectedTemplate, setSelectedTemplate] = useState(boxedDamageRecordsTemplate);
  const [processedContent, setProcessedContent] = useState(null);
  const [loading, setLoading] = useState(true);
  const { settings } = useSettings();
  const [localPrices, setLocalPrices] = useState({});
  const [pdfLoading, setPdfLoading] = useState(false);
  const [wordLoading, setWordLoading] = useState(false);
  const [pdfError, setPdfError] = useState(null);
  const [wordError, setWordError] = useState(null);
  const [downloadMessage, setDownloadMessage] = useState(''); // State for download message
  const [emailLoading, setEmailLoading] = useState(false);
  const [emailError, setEmailError] = useState(null);
  const [emailSuccess, setEmailSuccess] = useState(false);


  useEffect(() => {
    if (settings?.damagePrices) {
      setLocalPrices(settings.damagePrices);
    }
  }, [settings]);

  useEffect(() => {
    const fetchTemplates = async () => {
      try {
        setLoading(true);
        const { data, error } = await supabase
          .from('templates')
          .select('*')
          .eq('hidden', false)
          .order('name');

        if (error) throw error;

        const allTemplates = [boxedDamageRecordsTemplate];

        if (data?.length) {
          allTemplates.push(...data);
        }

        setTemplates(allTemplates);
        setSelectedTemplate(boxedDamageRecordsTemplate);
      } catch (error) {
        console.error('Error fetching templates:', error);
        setTemplates([boxedDamageRecordsTemplate]);
      } finally {
        setLoading(false);
      }
    };

    fetchTemplates();
  }, []);

  const processDamageRecord = async (record) => {
    let recordTemplate = selectedTemplate.content.match(/{{#each damage_records}}([\s\S]*?){{\/each}}/)[1];

    const recordFields = {
      damage_type: record.damage_type,
      risk_level: record.risk_level,
      location_details: record.location_details,
      building_area: record.building_area || '',
      recommendation: record.recommendation,
      notes: record.notes || '',
      reference_number: record.reference_number || 'Not assigned',
      brand: record.brand || 'Not specified',
      price: localPrices[record.damage_type] || 0
    };

    Object.entries(recordFields).forEach(([key, value]) => {
      const regex = new RegExp(`{{${key}}}`, 'g');
      recordTemplate = recordTemplate.replace(regex, value);
    });

    if (record.photo_url) {
      try {
        const response = await fetch(record.photo_url);
        const blob = await response.blob();
        const base64 = await new Promise((resolve, reject) => {
          const reader = new FileReader();
          reader.onloadend = () => resolve(reader.result);
          reader.onerror = reject;
          reader.readAsDataURL(blob);
        });
        recordTemplate = recordTemplate.replace(
          /{{#if photo_url}}([\s\S]*?){{\/if}}/g,
          `<div class="damage-photo"><img src="${base64}" alt="Damage" style="width: 300px; height: 225px; object-fit: contain; border: 1px solid #e2e8f0; border-radius: 4px; background-color: #f8fafc; margin: 10px auto; display: block;" /></div>`
        );
      } catch (error) {
        console.error('Error fetching or converting image:', error);
        recordTemplate = recordTemplate.replace(
          /{{#if photo_url}}[\s\S]*?{{\/if}}/g,
          ''
        );
      }
    } else {
      recordTemplate = recordTemplate.replace(
        /{{#if photo_url}}[\s\S]*?{{\/if}}/g,
        ''
      );
    }

    if (record.notes) {
      recordTemplate = recordTemplate.replace(
        /{{#if notes}}([\s\S]*?){{\/if}}/g,
        (_, content) => content.replace(/{{notes}}/g, record.notes)
      );
    } else {
      recordTemplate = recordTemplate.replace(
        /{{#if notes}}[\s\S]*?{{\/if}}/g,
        ''
      );
    }

    if (record.building_area) {
      recordTemplate = recordTemplate.replace(
        /{{#if building_area}}([\s\S]*?){{\/if}}/g,
        (_, content) => content.replace(/{{building_area}}/g, record.building_area)
      );
    } else {
      recordTemplate = recordTemplate.replace(
        /{{#if building_area}}[\s\S]*?{{\/if}}/g,
        ''
      );
    }

    return recordTemplate;
  };

  useEffect(() => {
    const processTemplate = async () => {
      if (!selectedTemplate || !audit) return;

      try {
        let content = selectedTemplate.content;

        try {
          const logoUrl = new URL('/assets/images/logo1.png', window.location.origin);
          const logoBase64 = await imageToBase64(logoUrl);
          if (logoBase64) {
            content = content.replace(/src="\/assets\/images\/logo1\.png"/g, `src="${logoBase64}"`);
          }
        } catch (error) {
          console.error('Error converting logo to base64:', error);
        }

        const auditFields = {
          reference_number: audit.reference_number,
          audit_date: new Date(audit.audit_date).toLocaleDateString(),
          auditor_name: audit.auditor_name,
          auditor_email: auditorDetails?.email || '',
          auditor_phone: auditorDetails?.phone || '',
          site_name: audit.site_name,
          company_name: audit.company_name,
          red_risks: audit.red_risks || 0,
          amber_risks: audit.amber_risks || 0,
          green_risks: audit.green_risks || 0,
          notes: audit.notes || ''
        };

        Object.entries(auditFields).forEach(([key, value]) => {
          const regex = new RegExp(`{{${key}}}`, 'g');
          content = content.replace(regex, value);
        });

        if (auditorDetails?.email) {
          content = content.replace(
            /{{#if auditor_email}}([\s\S]*?){{\/if}}/g,
            (_, innerContent) => innerContent.replace(/{{auditor_email}}/g, auditorDetails.email)
          );
        } else {
          content = content.replace(/{{#if auditor_email}}[\s\S]*?{{\/if}}/g, '');
        }

        if (auditorDetails?.phone) {
          content = content.replace(
            /{{#if auditor_phone}}([\s\S]*?){{\/if}}/g,
            (_, innerContent) => innerContent.replace(/{{auditor_phone}}/g, auditorDetails.phone)
          );
        } else {
          content = content.replace(/{{#if auditor_phone}}[\s\S]*?{{\/if}}/g, '');
        }

        if (content.includes('{{#each damage_records}}')) {
          let damageContent = '';
          const processedRecords = await Promise.all(damageRecords.map(processDamageRecord));
          damageContent = processedRecords.join('');

          content = content.replace(
            /{{#each damage_records}}[\s\S]*?{{\/each}}/,
            damageContent
          );
        }

        if (audit.notes) {
          content = content.replace(
            /{{#if notes}}([\s\S]*?){{\/if}}/g,
            (_, innerContent) => innerContent.replace(/{{notes}}/g, audit.notes)
          );
        } else {
          content = content.replace(/{{#if notes}}[\s\S]*?{{\/if}}/g, '');
        }

        content = content.replace(/{{#if\s+.*?}}.*?{{\/if}}/gs, '');
        content = content.replace(/{{.*?}}/g, '');

        const sanitizedContent = DOMPurify.sanitize(content);
        setProcessedContent(sanitizedContent);
      } catch (error) {
        console.error('Error processing template:', error);
        setProcessedContent('<div class="error">Error processing template</div>');
      }
    };

    processTemplate();
  }, [selectedTemplate, audit, damageRecords, settings, auditorDetails]);
    
  const handleGeneratePdf = async () => {
    if (!processedContent || !audit) return;
  
    setPdfLoading(true);
    setPdfError(null);
    setDownloadMessage(''); // Clear any previous message
  
    const date = new Date(audit.audit_date);
    const formattedDate = `${date.getFullYear().toString().slice(-2)}${(date.getMonth() + 1).toString().padStart(2, '0')}${date.getDate().toString().padStart(2, '0')}`;
    const filename = `${formattedDate}-${audit.company_name.replace(/[^a-zA-Z0-9]/g, '')}.pdf`;
  
    // Define CSS styles for pagination and page numbering
    const css = `
    @page {
        size: A4;
        margin: 15mm;
    }
    body {
        counter-reset: page;
    }
    .page-content {
        counter-increment: page;
        position: relative; /* Ensure footer is positioned relative to this */
        min-height: 257mm; /* Slightly less than A4 height minus margins */
        padding-bottom: 20mm; /* Space for the footer */
        box-sizing: border-box;
        padding-top: 40px; /* Add padding-top for the header */

    }
    .page-footer {
        position: absolute;
        bottom: 0;
        left: 20mm;
        right: 20mm;
        text-align: center;
        font-size: 12px;
        border-top: 1px solid #ccc; /* Add a line above the footer */
        padding-top: 5mm;
    }
    .page-footer::after {
        content: "Page " counter(page);
    }
      .page-header {
        position: absolute;
        top: 0;
        left: 20mm; /* Match page-content padding */
        right: 20mm; /* Match page-content padding */
        text-align: center;
        font-size: 12px;
        padding-bottom: 5mm; /* Space below the header */
        border-bottom: 1px solid #ccc;
    }
    .damage-record {
        page-break-inside: avoid;
    }
    .cover-page{
        page-break-after: always;
    }
    `;

    // Create header and footer content
    const headerContent = `<div class="page-header">Rack Audit Report - ${audit.reference_number}</div>`;
    const footerContent = `<div class="page-footer"></div>`;

    // Check if the template includes a cover page
    const hasCoverPage = selectedTemplate.content.includes('class="cover-page"');
    let fullContent = `<style>${css}</style>`;

    if (hasCoverPage) {
        fullContent += processedContent; // Add cover page directly
    } else {
        // Add default header if no cover page
        fullContent += headerContent;
        fullContent += `<div class="page-content">${processedContent}</div>`;
    }
     fullContent += footerContent; // Always add the footer


    const opt = {
      margin: [15, 15],
      filename: filename,
      image: { type: 'jpeg', quality: 0.98 },
      html2canvas: { scale: 2, useCORS: true, logging: false },
      jsPDF: { unit: 'mm', format: 'a4', orientation: 'portrait', compress: true },
      pagebreak: { mode: 'avoid-all' }
    };

    try {
      // Directly use html2pdf().save() with the HTML string
      await html2pdf().set(opt).from(fullContent).save();
      setDownloadMessage('Your download should start automatically. If it is blocked, please check your browser settings.');

    } catch (error) {
      console.error('Error generating PDF:', error);
      setPdfError('Failed to generate PDF. Please try again.');
    } finally {
      setPdfLoading(false);
    }
  };


  const handleExportWord = async () => {
    if (!audit) return;

    setWordLoading(true);
    setWordError(null);

    const date = new Date(audit.audit_date);
    const formattedDate = `${date.getFullYear().toString().slice(-2)}${(date.getMonth() + 1).toString().padStart(2, '0')}${date.getDate().toString().padStart(2, '0')}`;
    const filename = `${formattedDate}-${audit.company_name.replace(/[^a-zA-Z0-9]/g, '')}.docx`;

    try {
      const doc = new Document({
        sections: [{
          properties: {},
          children: [
            new Paragraph({
              children: [
                new TextRun({
                  text: "Rack Audit Report",
                  bold: true,
                  size: 36,
                  font: "Calibri",
                }),
              ],
              spacing: {
                after: 400,
              },
            }),
            new Paragraph({
              children: [
                new TextRun(`Reference: ${audit.reference_number}`),
                new TextRun({
                  text: `Date: ${new Date(audit.audit_date).toLocaleDateString()}`,
                  break: 1,
                }),
                new TextRun({
                  text: `Auditor: ${audit.auditor_name}`,
                  break: 1,
                }),
                auditorDetails?.email ? new TextRun({ text: `Email: ${auditorDetails.email}`, break: 1 }) : undefined,
                auditorDetails?.phone ? new TextRun({ text: `Phone: ${auditorDetails.phone}`, break: 1 }) : undefined,
              ].filter(Boolean),
              spacing: {
                after: 200,
              },
            }),
            new Paragraph({
              children: [
                new TextRun({
                  text: "Site Information",
                  bold: true,
                  size: 28,
                  font: 'Calibri'
                }),
              ],
              spacing: {
                after: 200,
              },
            }),
            new Table({
              rows: [
                new TableRow({
                  children: [
                    new TableCell({
                      children: [new Paragraph("Site Name")],
                      width: { size: 30, type: WidthType.PERCENTAGE },
                    }),
                    new TableCell({
                      children: [new Paragraph(audit.site_name)],
                    }),
                  ],
                }),
                new TableRow({
                  children: [
                    new TableCell({
                      children: [new Paragraph("Company")],
                    }),
                    new TableCell({
                      children: [new Paragraph(audit.company_name)],
                    }),
                  ],
                }),
              ],
              width: {
                size: 100,
                type: WidthType.PERCENTAGE,
              },
            }),
          ],
        }],
      });

      const blob = await Packer.toBlob(doc);

      // Convert the blob to a data URL
      const reader = new FileReader();
      reader.readAsDataURL(blob);
      reader.onloadend = () => {
        const base64data = reader.result;

        // Create a download link and trigger click
        const link = document.createElement('a');
        link.href = base64data; // Use the data URL
        link.download = filename;
        link.style.display = 'none'; // Hide the link
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
      }


    } catch (error) {
      console.error('Error exporting to Word:', error);
      setWordError('Failed to export to Word. Please try again.');
    } finally {
      setWordLoading(false);
    }
  };

  const handleEmailReport = async () => {
    if (!audit) return;

    setEmailLoading(true);
    setEmailError(null);
    setEmailSuccess(false);

    try {
      // Get the customer information from the audit
      const { data: customer, error: customerError } = await supabase
        .from('customers')
        .select('*')
        .eq('name', audit.site_name)
        .eq('company', audit.company_name)
        .single();

      if (customerError || !customer) {
        throw new Error('Customer not found. Please ensure customer information is properly set up.');
      }

      if (!customer.email) {
        throw new Error('Customer email not found. Please update customer information.');
      }

      // Get the portal URL
      const portalUrl = `${window.location.origin}/customer-portal`;

      // Call the edge function to send email
      const { data, error } = await supabase.functions.invoke('send-audit-email', {
        body: {
          customerEmail: customer.email,
          customerName: customer.name,
          companyName: customer.company,
          auditReference: audit.reference_number,
          portalUrl: portalUrl
        }
      });

      if (error) throw error;

      setEmailSuccess(true);
      setTimeout(() => setEmailSuccess(false), 5000); // Clear success message after 5 seconds

    } catch (error) {
      console.error('Error sending email:', error);
      setEmailError(error.message || 'Failed to send email. Please try again.');
    } finally {
      setEmailLoading(false);
    }
  };

  if (loading) {
    return <div className="loading">Loading templates...</div>;
  }

  return (
    <div className="print-preview">
      <div className="preview-header no-print">
        <div className="preview-controls">
          <h2>Print Preview</h2>
          <div className="template-selector">
            <label>Select Template:</label>
            <select
              value={selectedTemplate?.id || 'boxed'}
              onChange={(e) => {
                const template = templates.find(t => t.id === e.target.value);
                setSelectedTemplate(template || boxedDamageRecordsTemplate);
              }}
            >
              <option value="boxed">Boxed Damage Records (Default)</option>
              {templates.filter(t => t.id).map(template => (
                <option key={template.id} value={template.id}>
                  {template.name}
                </option>
              ))}
            </select>
          </div>
        </div>
        <div className="preview-actions">
          <button
            onClick={handleGeneratePdf}
            className="print-btn"
            disabled={!processedContent || pdfLoading}
          >
            {pdfLoading ? 'Generating PDF...' : 'Generate PDF'}
          </button>

          {pdfError && <div className="error-message">{pdfError}</div>}

          <button
            onClick={handleExportWord}
            className="export-word-btn"
            disabled={!processedContent || wordLoading}
          >
            {wordLoading ? 'Exporting...' : 'Export to Word'}
          </button>
          {wordError && <div className="error-message">{wordError}</div>}
          
          <button
            onClick={handleEmailReport}
            className="email-report-btn"
            disabled={!processedContent || emailLoading}
          >
            {emailLoading ? 'Sending Email...' : 'Email Report'}
          </button>
          {emailError && <div className="error-message">{emailError}</div>}
          {emailSuccess && <div className="success-message">Email sent successfully to customer!</div>}
          
          <button onClick={onClose} className="close-btn">
            Close Preview
          </button>
        </div>
      </div>
        {downloadMessage && <div className="download-message">{downloadMessage}</div>}

      <div className="preview-container">
        {processedContent ? (
          <div
            className="printable-content"
            dangerouslySetInnerHTML={{ __html: processedContent }}
          />
        ) : (
          <div className="no-preview">
            {templates.length ?
              'Processing template...' :
              'No templates available. Please create a template first.'
            }
          </div>
        )}
      </div>
    </div>
  );
};

export default PrintableAudit;
