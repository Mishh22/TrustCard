# TrustCard Email Service

This Firebase Functions service handles sending company verification emails to `info@accexasia.com` when new verification requests are submitted.

## Setup Instructions

### 1. Install Dependencies
```bash
cd functions
npm install
```

### 2. Configure SendGrid
1. Sign up for SendGrid account: https://sendgrid.com/
2. Create an API key in SendGrid dashboard
3. Set the API key in Firebase Functions config:

```bash
firebase functions:config:set sendgrid.key="YOUR_SENDGRID_API_KEY"
```

### 3. Deploy Functions
```bash
firebase deploy --only functions
```

## How It Works

1. **Automatic Trigger**: When a new document is created in `company_verification_requests` collection
2. **Email Generation**: Creates a formatted HTML email with all company details and attachments
3. **Email Sending**: Sends to `info@accexasia.com` with all verification data
4. **Status Update**: Updates the request document with email sent status

## Email Content Includes

- Company name, address, phone, email
- Contact person details
- GST and PAN numbers (if provided)
- Download links to all attachments:
  - Business photo
  - GST certificate
  - PAN certificate
- Request ID and submission timestamp

## Testing

Test the email functionality:
```bash
firebase functions:shell
sendTestEmail()
```

## Monitoring

Check function logs:
```bash
firebase functions:log
```
