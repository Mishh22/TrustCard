# Firebase Test Phone Number Setup

## Step 1: Add Test Phone Number in Firebase Console

1. Go to: https://console.firebase.google.com/project/trustcard-aee4a/authentication/providers
2. Click on **"Phone"** provider
3. Scroll down to **"Phone numbers for testing"**
4. Click **"Add phone number"**
5. Add:
   - Phone number: `+918888888888`
   - Verification code: `123456`
6. Click **"Add"**
7. Click **"Save"**

## Step 2: Test in App

### For Android Emulator:
1. Enter phone number: `8888888888` (without +)
2. Click "Send OTP"
3. You should see "OTP sent successfully" (no real SMS)
4. Enter code: `123456`
5. You're in! ✅

### For iOS/Real Device (Real Phone Numbers):
1. Enter your **real phone number** (e.g., `9876543210`)
2. Click "Send OTP"
3. You should receive **real SMS** with 6-digit OTP
4. Enter the **real OTP** from SMS
5. You're in! ✅

## Why This Works:

**Test Phone Numbers** (`8888888888`):
- **Bypass** all device verification (Play Integrity, reCAPTCHA, SHA certificates)
- **No real SMS** sent - uses OTP `123456` 
- For **Android emulator testing** only

**Real Phone Numbers** (Any other number):
- **Sends real SMS** via Firebase
- **Real 6-digit OTP** received via SMS
- For **production and real device testing**

---

## Important Notes:

1. **Remove `+919654393044` from Firebase Console** test numbers if it's there
2. Only use `+918888888888` as test number for Android emulator
3. All other numbers will receive real SMS OTP
