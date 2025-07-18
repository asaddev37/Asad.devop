🔐 Row-Level Security (RLS)
🔒 Enabled for:
sql
Copy
Edit
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE departments ENABLE ROW LEVEL SECURITY;
ALTER TABLE batches ENABLE ROW LEVEL SECURITY;
ALTER TABLE complaints ENABLE ROW LEVEL SECURITY;
ALTER TABLE complaint_timeline ENABLE ROW LEVEL SECURITY;
✅ Profiles RLS
sql
Copy
Edit
-- Admins can access all
CREATE POLICY admin_all_profiles ON profiles
FOR ALL TO authenticated
USING (auth.uid() IN (SELECT id FROM profiles WHERE role = 'admin'));

-- Self-access
CREATE POLICY user_read_own_profile ON profiles
FOR SELECT TO authenticated
USING (auth.uid() = id);

-- Advisors can access students
CREATE POLICY advisor_read_students ON profiles
FOR SELECT TO authenticated
USING (advisor_id = auth.uid() OR id = auth.uid());

CREATE POLICY advisor_update_students ON profiles
FOR UPDATE TO authenticated
USING (advisor_id = auth.uid());

-- HOD access by department
CREATE POLICY hod_read_department_profiles ON profiles
FOR SELECT TO authenticated
USING (
  auth.uid() IN (
    SELECT id FROM profiles WHERE role = 'hod'
    AND department_id = profiles.department_id
  )
);

CREATE POLICY hod_update_department_profiles ON profiles
FOR UPDATE TO authenticated
USING (
  auth.uid() IN (
    SELECT id FROM profiles WHERE role = 'hod'
    AND department_id = profiles.department_id
  )
);
✅ Batches RLS
sql
Copy
Edit
CREATE POLICY admin_all_batches ON batches
FOR ALL TO authenticated
USING (auth.uid() IN (SELECT id FROM profiles WHERE role = 'admin'));

CREATE POLICY advisor_read_batch ON batches
FOR SELECT TO authenticated
USING (advisor_id = auth.uid());
✅ Complaints RLS
sql
Copy
Edit
CREATE POLICY student_create_complaints ON complaints
FOR INSERT TO authenticated
WITH CHECK (student_id = auth.uid());

CREATE POLICY student_read_own_complaints ON complaints
FOR SELECT TO authenticated
USING (student_id = auth.uid());

CREATE POLICY advisor_read_batch_complaints ON complaints
FOR SELECT TO authenticated
USING (advisor_id = auth.uid());

CREATE POLICY advisor_update_batch_complaints ON complaints
FOR UPDATE TO authenticated
USING (advisor_id = auth.uid() AND status NOT IN ('Escalated', 'Resolved', 'Rejected'));

CREATE POLICY hod_read_complaints ON complaints
FOR SELECT TO authenticated
USING (hod_id = auth.uid());

CREATE POLICY hod_update_complaints ON complaints
FOR UPDATE TO authenticated
USING (hod_id = auth.uid() AND status = 'Escalated');

CREATE POLICY admin_all_complaints ON complaints
FOR ALL TO authenticated
USING (auth.uid() IN (SELECT id FROM profiles WHERE role = 'admin'));
✅ Complaint Timeline RLS
sql
Copy
Edit
CREATE POLICY student_read_timeline ON complaint_timeline
FOR SELECT TO authenticated
USING (complaint_id IN (SELECT id FROM complaints WHERE student_id = auth.uid()));

CREATE POLICY advisor_read_timeline ON complaint_timeline
FOR SELECT TO authenticated
USING (complaint_id IN (SELECT id FROM complaints WHERE advisor_id = auth.uid()));

CREATE POLICY advisor_create_timeline ON complaint_timeline
FOR INSERT TO authenticated
WITH CHECK (complaint_id IN (SELECT id FROM complaints WHERE advisor_id = auth.uid()));

CREATE POLICY hod_read_timeline ON complaint_timeline
FOR SELECT TO authenticated
USING (complaint_id IN (SELECT id FROM complaints WHERE hod_id = auth.uid()));

CREATE POLICY hod_create_timeline ON complaint_timeline
FOR INSERT TO authenticated
WITH CHECK (complaint_id IN (SELECT id FROM complaints WHERE hod_id = auth.uid()));

CREATE POLICY admin_all_timeline ON complaint_timeline
FOR ALL TO authenticated
USING (auth.uid() IN (SELECT id FROM profiles WHERE role = 'admin'));
⚡ Indexes
sql
Copy
Edit
CREATE INDEX idx_profiles_role ON profiles(role);
CREATE INDEX idx_profiles_batch_id ON profiles(batch_id);
CREATE INDEX idx_profiles_department_id ON profiles(department_id);

CREATE INDEX idx_complaints_status ON complaints(status);
CREATE INDEX idx_complaints_title ON complaints(title);
CREATE INDEX idx_complaints_created_at ON complaints(created_at);
CREATE INDEX idx_complaints_last_action_at ON complaints(last_action_at);


 ---

 CREATE POLICY "Batch advisor can update their complaints"
 ON complaints
 FOR UPDATE
 USING (
   advisor_id = auth.uid()
   AND status IN ('Submitted', 'In Progress')
 )
 WITH CHECK (
   advisor_id = auth.uid()
 );

 -- Enable RLS on the table (if not already enabled)
 ALTER TABLE complaint_timeline ENABLE ROW LEVEL SECURITY;

 -- Allow authenticated users to insert
 CREATE POLICY "Allow insert for authenticated users"
   ON complaint_timeline
   FOR INSERT
   WITH CHECK (auth.uid() IS NOT NULL);
  ---
  CREATE POLICY student_read_own_batch ON batches
  FOR SELECT TO authenticated
  USING (
    id = (SELECT batch_id FROM profiles WHERE id = auth.uid())
  );


  ---
  CREATE POLICY student_read_own_department ON departments
  FOR SELECT TO authenticated
  USING (
    id = (SELECT department_id FROM profiles WHERE id = auth.uid())
  );
  ---
  CREATE POLICY student_read_departments ON departments
  FOR SELECT TO authenticated
  USING (true);
  ----
  -- Disable the trigger that checks for batch advisor assignment on profile creation
  ALTER TABLE profiles DISABLE TRIGGER check_batch_advisor;
  ---
  CREATE OR REPLACE FUNCTION validate_batch_advisor()
  RETURNS TRIGGER AS $$
  BEGIN
    IF NEW.role = 'batch_advisor' AND NOT EXISTS (
      SELECT 1 FROM batches WHERE advisor_id = NEW.id
    ) THEN
      RAISE EXCEPTION 'Batch advisor must be assigned to a batch';
    END IF;
    RETURN NEW;
  END;
  $$ LANGUAGE plpgsql;