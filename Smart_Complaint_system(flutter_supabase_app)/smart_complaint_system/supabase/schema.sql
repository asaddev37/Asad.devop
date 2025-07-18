# 📝 Complaint Management System – Full Scope Document

## 📌 Overview

```sql
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  email TEXT NOT NULL UNIQUE,
  role TEXT NOT NULL CHECK (role IN ('admin', 'student', 'batch_advisor', 'hod')),
  name TEXT NOT NULL,
  batch_id UUID REFERENCES batches(id),
  department_id UUID REFERENCES departments(id),
  phone_no TEXT,
  student_id TEXT UNIQUE,
  advisor_id UUID REFERENCES profiles(id),
  avatar_url TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);
```

#### 🔄 Auto-Assign Advisor for Students

```sql
CREATE OR REPLACE FUNCTION assign_batch_advisor()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.role = 'student' AND NEW.batch_id IS NOT NULL THEN
    NEW.advisor_id := (
      SELECT advisor_id FROM batches WHERE id = NEW.batch_id
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER auto_assign_advisor
BEFORE INSERT OR UPDATE ON profiles
FOR EACH ROW
EXECUTE FUNCTION assign_batch_advisor();
```

#### ❗ Require Batch Advisor to Have a Batch

```sql
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

/*
CREATE TRIGGER check_batch_advisor
BEFORE INSERT OR UPDATE ON profiles
FOR EACH ROW
WHEN (NEW.role = 'batch_advisor')
EXECUTE FUNCTION validate_batch_advisor();
*/

---

### ✅ Complaints

```sql
CREATE TABLE complaints (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  student_id UUID REFERENCES profiles(id),
  batch_id UUID REFERENCES batches(id),
  advisor_id UUID REFERENCES profiles(id),
  hod_id UUID REFERENCES profiles(id),
  title TEXT NOT NULL CHECK (
    title IN ('Transport', 'Course', 'Fee', 'Faculty', 'Personal', 'Other') OR title ~ '^[a-zA-Z0-9 ]+$'
  ),
  description TEXT NOT NULL,
  media_url TEXT,
  status TEXT NOT NULL CHECK (status IN ('Submitted', 'In Progress', 'Escalated', 'Resolved', 'Rejected')) DEFAULT 'Submitted',
  same_title_count INTEGER DEFAULT 1,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  last_action_at TIMESTAMP DEFAULT NOW()
);
```

#### 🕒 Auto Update Timestamp

```sql
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_complaints_timestamp
BEFORE UPDATE ON complaints
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();
```

#### 📈 Same-Title Complaint Escalation (>= 5)

```sql
CREATE OR REPLACE FUNCTION handle_same_title_complaints()
RETURNS TRIGGER AS $$
DECLARE
  title_count INTEGER;
  hod_uuid UUID;
BEGIN
  SELECT COUNT(*) INTO title_count
  FROM complaints
  WHERE title = NEW.title AND status NOT IN ('Resolved', 'Rejected');

  UPDATE complaints
  SET same_title_count = title_count + 1
  WHERE title = NEW.title AND status NOT IN ('Resolved', 'Rejected');

  IF title_count + 1 >= 5 THEN
    SELECT id INTO hod_uuid FROM profiles WHERE role = 'hod' AND department_id = (
      SELECT department_id FROM batches WHERE id = NEW.batch_id
    );

    UPDATE complaints
    SET status = 'Escalated',
        hod_id = hod_uuid,
        updated_at = NOW(),
        last_action_at = NOW()
    WHERE title = NEW.title AND status NOT IN ('Resolved', 'Rejected');

    INSERT INTO complaint_timeline (complaint_id, comment, status, created_by)
    VALUES (NEW.id, 'Auto-escalated due to 5+ same-title complaints', 'Escalated', hod_uuid);
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER same_title_trigger
AFTER INSERT ON complaints
FOR EACH ROW
EXECUTE FUNCTION handle_same_title_complaints();
```

#### ⏰ Auto Escalate if No Action in 24h

```sql
CREATE OR REPLACE FUNCTION auto_escalate_complaints()
RETURNS VOID AS $$
DECLARE
  complaint RECORD;
  hod_uuid UUID;
BEGIN
  FOR complaint IN
    SELECT id, batch_id FROM complaints
    WHERE status = 'Submitted'
    AND last_action_at < NOW() - INTERVAL '24 hours'
  LOOP
    SELECT id INTO hod_uuid FROM profiles
    WHERE role = 'hod' AND department_id = (
      SELECT department_id FROM batches WHERE id = complaint.batch_id
    );

    UPDATE complaints
    SET status = 'Escalated',
        hod_id = hod_uuid,
        updated_at = NOW(),
        last_action_at = NOW()
    WHERE id = complaint.id;

    INSERT INTO complaint_timeline (complaint_id, comment, status, created_by)
    VALUES (complaint.id, 'Auto-escalated due to no action in 24 hours', 'Escalated', hod_uuid);
  END LOOP;
END;
$$ LANGUAGE plpgsql;
```

---

### ✅ Complaint Timeline

```sql
CREATE TABLE complaint_timeline (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  complaint_id UUID REFERENCES complaints(id),
  comment TEXT,
  status TEXT CHECK (status IN ('Submitted', 'In Progress', 'Escalated', 'Resolved', 'Rejected')),
  created_by UUID REFERENCES profiles(id),
  created_at TIMESTAMP DEFAULT NOW()
);
```

CREATE TABLE departments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);


