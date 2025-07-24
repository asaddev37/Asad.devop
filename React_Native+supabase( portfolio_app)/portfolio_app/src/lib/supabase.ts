import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://dgfvklchhlqqlqkylxla.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRnZnZrbGNoaGxxcWxxa3lseGxhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI4NTc2NTEsImV4cCI6MjA2ODQzMzY1MX0.Mv1i-JYqhvVZYIEVi2pDB-hX3qtjCbdHkQS2yyhIe4w';

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
