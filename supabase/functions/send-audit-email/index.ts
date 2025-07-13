import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { customerEmail, customerName, companyName, auditReference, portalUrl } = await req.json()

    const emailHtml = `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: #2563eb; color: white; padding: 20px; text-align: center; }
          .content { padding: 20px; background: #f8fafc; }
          .button { 
            display: inline-block; 
            background: #2563eb; 
            color: white; 
            padding: 12px 24px; 
            text-decoration: none; 
            border-radius: 5px; 
            margin: 20px 0;
          }
          .footer { padding: 20px; text-align: center; color: #666; font-size: 12px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>Rack Audit Report Available</h1>
          </div>
          <div class="content">
            <p>Dear ${customerName},</p>
            
            <p>Your rack audit report (Reference: ${auditReference}) for ${companyName} has been completed and is now available for viewing.</p>
            
            <p>You can access your audit history and view all reports through our customer portal:</p>
            
            <div style="text-align: center;">
              <a href="${portalUrl}" class="button">Access Customer Portal</a>
            </div>
            
            <p>In the portal, you will be able to:</p>
            <ul>
              <li>View all your audit reports</li>
              <li>See detailed damage records with photos</li>
              <li>Track the status of recommendations</li>
              <li>Access historical audit data</li>
            </ul>
            
            <p>To access the portal, simply click the link above and enter your email address: <strong>${customerEmail}</strong></p>
            
            <p>If you have any questions about your audit report or need assistance accessing the portal, please don't hesitate to contact us.</p>
            
            <p>Thank you for choosing our audit services.</p>
            
            <p>Best regards,<br>
            The Audit Team</p>
          </div>
          <div class="footer">
            <p>This is an automated message. Please do not reply to this email.</p>
          </div>
        </div>
      </body>
      </html>
    `

    // Here you would integrate with your email service
    // For example, using Resend, SendGrid, or similar
    // This is a placeholder - you'll need to configure your email service
    
    const emailResponse = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${Deno.env.get('RESEND_API_KEY')}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        from: 'audits@yourcompany.com',
        to: [customerEmail],
        subject: `Rack Audit Report Available - ${auditReference}`,
        html: emailHtml,
      }),
    })

    if (!emailResponse.ok) {
      throw new Error('Failed to send email')
    }

    return new Response(
      JSON.stringify({ success: true, message: 'Email sent successfully' }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      },
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400,
      },
    )
  }
})