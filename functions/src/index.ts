import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as sgMail from '@sendgrid/mail';

// Initialize Firebase Admin
admin.initializeApp();

// Initialize SendGrid
sgMail.setApiKey(functions.config().sendgrid?.key || process.env.SENDGRID_API_KEY);

// Email template for company verification requests
const createEmailTemplate = (requestData: any) => {
  const {
    companyName,
    businessAddress,
    phoneNumber,
    email,
    contactPerson,
    gstNumber,
    panNumber,
    businessPhotoUrl,
    gstCertificateUrl,
    panCertificateUrl,
    requestId,
    submittedAt
  } = requestData;

  const attachments: any[] = [];
  
  // Note: For now, we'll include URLs in the email body instead of attachments
  // SendGrid requires base64 encoded content for attachments, not URLs

  return {
    to: 'av55756@gmail.com',
    from: 'mishhyadav@gmail.com', // Using your verified Gmail for now
    subject: `New Company Verification Request - ${companyName}`,
    html: `
      <!DOCTYPE html>
      <html>
      <head>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .header { background-color: #f4f4f4; padding: 20px; text-align: center; }
          .content { padding: 20px; }
          .section { margin-bottom: 20px; }
          .label { font-weight: bold; color: #555; }
          .value { margin-left: 10px; }
          .attachments { background-color: #f9f9f9; padding: 15px; border-radius: 5px; }
          .footer { background-color: #f4f4f4; padding: 15px; text-align: center; font-size: 12px; color: #666; }
        </style>
      </head>
      <body>
        <div class="header">
          <h2>🏢 New Company Verification Request</h2>
          <p>Request ID: ${requestId}</p>
          <p>Submitted: ${new Date(submittedAt).toLocaleString()}</p>
        </div>
        
        <div class="content">
          <div class="section">
            <h3>📋 Company Details</h3>
            <p><span class="label">Company Name:</span> <span class="value">${companyName}</span></p>
            <p><span class="label">Business Address:</span> <span class="value">${businessAddress}</span></p>
            <p><span class="label">Phone Number:</span> <span class="value">${phoneNumber}</span></p>
            <p><span class="label">Email:</span> <span class="value">${email}</span></p>
            <p><span class="label">Contact Person:</span> <span class="value">${contactPerson}</span></p>
          </div>
          
          <div class="section">
            <h3>📄 Legal Documents</h3>
            ${gstNumber ? `<p><span class="label">GST Number:</span> <span class="value">${gstNumber}</span></p>` : ''}
            ${panNumber ? `<p><span class="label">PAN Number:</span> <span class="value">${panNumber}</span></p>` : ''}
          </div>
          
          <div class="section">
            <h3>📎 Attachments</h3>
            <div class="attachments">
              ${businessPhotoUrl ? `<p>📸 <a href="${businessPhotoUrl}" target="_blank">Business Photo</a></p>` : ''}
              ${gstCertificateUrl ? `<p>📄 <a href="${gstCertificateUrl}" target="_blank">GST Certificate</a></p>` : ''}
              ${panCertificateUrl ? `<p>📄 <a href="${panCertificateUrl}" target="_blank">PAN Certificate</a></p>` : ''}
            </div>
          </div>
          
          <div class="section">
            <h3>⚡ Next Steps</h3>
            <p>Please review the attached documents and company details. You can approve or reject this verification request through the admin panel.</p>
            <p><strong>Action Required:</strong> This request is pending your review.</p>
          </div>
        </div>
        
        <div class="footer">
          <p>This email was sent automatically from TrustCard Verification System.</p>
          <p>Request ID: ${requestId} | Generated: ${new Date().toISOString()}</p>
        </div>
      </body>
      </html>
    `,
    attachments: attachments
  };
};

// Cloud Function triggered when a company verification request is created
export const sendCompanyVerificationEmail = functions.firestore
  .document('company_verification_requests/{requestId}')
  .onCreate(async (snap, context) => {
    try {
      const requestData = snap.data();
      const requestId = context.params.requestId;
      
      console.log('New company verification request:', requestId);
      
      // Create email template
      const emailData = createEmailTemplate({
        ...requestData,
        requestId,
        submittedAt: requestData.submittedAt?.toDate() || new Date()
      });
      
      // Send email
      const sendGridResponse = await sgMail.send(emailData);
      
      console.log('Email sent successfully for request:', requestId);
      console.log('SendGrid response:', JSON.stringify(sendGridResponse));
      
      // Update the request with email sent status
      await snap.ref.update({
        emailSent: true,
        emailSentAt: admin.firestore.FieldValue.serverTimestamp(),
        sendGridResponse: JSON.stringify(sendGridResponse)
      });
      
      return { success: true, requestId };
      
    } catch (error) {
      console.error('Error sending company verification email:', error);
      
      // Update the request with error status
      await snap.ref.update({
        emailError: error instanceof Error ? error.message : 'Unknown error',
        emailSentAt: admin.firestore.FieldValue.serverTimestamp()
      });
      
      throw error;
    }
  });

// Manual trigger function for testing
export const sendTestEmail = functions.https.onCall(async (data, context) => {
  try {
    const testData = {
      companyName: 'Test Company Pvt Ltd',
      businessAddress: '123 Test Street, Test City, Test State 12345',
      phoneNumber: '+91 9876543210',
      email: 'test@testcompany.com',
      contactPerson: 'Test Person',
      gstNumber: '22ABCDE1234F1Z5',
      panNumber: 'ABCDE1234F',
      businessPhotoUrl: 'https://example.com/business.jpg',
      gstCertificateUrl: 'https://example.com/gst.pdf',
      panCertificateUrl: 'https://example.com/pan.pdf',
      requestId: 'test_' + Date.now(),
      submittedAt: new Date()
    };
    
    const emailData = createEmailTemplate(testData);
    await sgMail.send(emailData);
    
    return { success: true, message: 'Test email sent successfully' };
    
  } catch (error) {
    console.error('Error sending test email:', error);
    const errorMessage = error instanceof Error ? error.message : 'Unknown error';
    throw new functions.https.HttpsError('internal', `Failed to send test email: ${errorMessage}`);
  }
});

// Auto-update user verification status when company verification request status changes
export const updateUserVerificationStatus = functions.firestore
  .document('company_verification_requests/{requestId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    const requestId = context.params.requestId;
    
    // Check if status changed
    if (before.status === after.status) {
      return null; // No status change
    }
    
    const userId = after.userId;
    const newStatus = after.status;
    
    try {
      if (newStatus === 'approved') {
        // Update user's company verification status to true
        await admin.firestore().collection('users').doc(userId).update({
          isCompanyVerified: true,
          companyId: requestId,
          companyName: after.companyName,
        });
        
        console.log(`User ${userId} company verification approved`);
      } else if (newStatus === 'rejected') {
        // Update user's company verification status to false
        await admin.firestore().collection('users').doc(userId).update({
          isCompanyVerified: false,
          companyId: null,
          companyName: null,
        });
        
        console.log(`User ${userId} company verification rejected`);
      }
      
      return null;
    } catch (error) {
      console.error('Error updating user verification status:', error);
      return null;
    }
  });
