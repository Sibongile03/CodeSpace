// TEMPLATE: Copy this file to supabase_config.dart and add your credentials
/*223056129 Mokoena SP , 224085810 BBL NTSUTLE, 222019937 Melupe NE, 224120806 Maseko O, 223085941 TSM MATJENI*/ 

class SupabaseConfig {
  // Production Supabase credentials
  // REPLACE these with your actual Supabase project credentials
  static const String supabaseUrl = 'https://your-project-id.supabase.co';
  static const String supabaseAnonKey = 'YOUR_ANON_KEY_HERE';

  // ============================================
  // HOW TO GET YOUR CREDENTIALS
  // ============================================
  // 1. Go to https://app.supabase.com
  // 2. Select your project
  // 3. Go to Settings > API
  // 4. Copy:
  //    - Project URL (starts with https://)
  //    - anon public (NOT service_role)
  // 5. Paste them above

  // ============================================
  // IMPORTANT SECURITY NOTES
  // ============================================
  // ✅ SAFE TO SHARE: Anon public key (what goes above)
  // ❌ NEVER SHARE: Database password, service_role key, private keys
  // ❌ NEVER COMMIT: Real credentials to Git (use .gitignore)
  // ✅ DO COMMIT: This template file (with placeholder values)

  // Optional: Local development configuration
  static const String localUrl = 'http://localhost:54321';
  static const String localAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
}
