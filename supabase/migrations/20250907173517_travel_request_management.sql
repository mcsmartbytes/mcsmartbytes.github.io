-- Location: supabase/migrations/20250907173517_travel_request_management.sql
-- Schema Analysis: Fresh project - no existing schema detected
-- Integration Type: NEW_MODULE - Complete travel request management system
-- Dependencies: None (fresh project)

-- 1. Custom Types (with public schema qualification)
CREATE TYPE public.request_status AS ENUM ('draft', 'pending', 'approved', 'rejected', 'cancelled');
CREATE TYPE public.priority_level AS ENUM ('low', 'medium', 'high');
CREATE TYPE public.user_role AS ENUM ('employee', 'manager', 'admin');

-- 2. Core Tables (following dependency order)

-- User profiles table (critical intermediary for PostgREST compatibility)
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    role public.user_role DEFAULT 'employee'::public.user_role,
    department TEXT,
    manager_id UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Travel requests table
CREATE TABLE public.travel_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE NOT NULL,
    trip_name TEXT NOT NULL,
    business_justification TEXT NOT NULL,
    expected_outcomes TEXT NOT NULL,
    departure_date DATE NOT NULL,
    departure_time TIME,
    return_date DATE NOT NULL,
    return_time TIME,
    origin_city TEXT NOT NULL,
    destination_city TEXT NOT NULL,
    transportation_cost DECIMAL(10,2) DEFAULT 0.0,
    accommodation_cost DECIMAL(10,2) DEFAULT 0.0,
    meals_cost DECIMAL(10,2) DEFAULT 0.0,
    other_cost DECIMAL(10,2) DEFAULT 0.0,
    total_cost DECIMAL(10,2) GENERATED ALWAYS AS (transportation_cost + accommodation_cost + meals_cost + other_cost) STORED,
    status public.request_status DEFAULT 'draft'::public.request_status,
    priority public.priority_level DEFAULT 'medium'::public.priority_level,
    manager_id UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    comments TEXT,
    submitted_at TIMESTAMPTZ,
    approved_at TIMESTAMPTZ,
    rejected_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Travel request attendees (many-to-many relationship)
CREATE TABLE public.travel_request_attendees (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    request_id UUID REFERENCES public.travel_requests(id) ON DELETE CASCADE NOT NULL,
    attendee_name TEXT NOT NULL,
    attendee_email TEXT NOT NULL,
    attendee_role TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Approval timeline/history
CREATE TABLE public.travel_request_timeline (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    request_id UUID REFERENCES public.travel_requests(id) ON DELETE CASCADE NOT NULL,
    action_type TEXT NOT NULL, -- 'created', 'submitted', 'approved', 'rejected', 'cancelled'
    action_by UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    action_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Indexes for performance
CREATE INDEX idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX idx_user_profiles_role ON public.user_profiles(role);
CREATE INDEX idx_user_profiles_manager_id ON public.user_profiles(manager_id);

CREATE INDEX idx_travel_requests_user_id ON public.travel_requests(user_id);
CREATE INDEX idx_travel_requests_status ON public.travel_requests(status);
CREATE INDEX idx_travel_requests_departure_date ON public.travel_requests(departure_date);
CREATE INDEX idx_travel_requests_manager_id ON public.travel_requests(manager_id);
CREATE INDEX idx_travel_requests_created_at ON public.travel_requests(created_at DESC);

CREATE INDEX idx_travel_request_attendees_request_id ON public.travel_request_attendees(request_id);
CREATE INDEX idx_travel_request_timeline_request_id ON public.travel_request_timeline(request_id);
CREATE INDEX idx_travel_request_timeline_action_by ON public.travel_request_timeline(action_by);

-- 4. Functions (MUST BE BEFORE RLS POLICIES)

-- Function for automatic profile creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $func$
BEGIN
    INSERT INTO public.user_profiles (id, email, full_name, role)
    VALUES (
        NEW.id, 
        NEW.email, 
        COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
        COALESCE((NEW.raw_user_meta_data->>'role')::public.user_role, 'employee'::public.user_role)
    );
    RETURN NEW;
END;
$func$;

-- Function for updating timestamps
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $func$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$func$;

-- Function for creating timeline entries
CREATE OR REPLACE FUNCTION public.create_timeline_entry()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $func$
BEGIN
    -- Insert timeline entry for status changes
    IF TG_OP = 'INSERT' THEN
        INSERT INTO public.travel_request_timeline (request_id, action_type, action_by, notes)
        VALUES (NEW.id, 'created', NEW.user_id, 'Travel request created');
    ELSIF TG_OP = 'UPDATE' AND OLD.status != NEW.status THEN
        INSERT INTO public.travel_request_timeline (request_id, action_type, action_by, notes)
        VALUES (NEW.id, NEW.status::TEXT, auth.uid(), 'Status changed to ' || NEW.status::TEXT);
    END IF;
    RETURN NEW;
END;
$func$;

-- 5. Enable RLS
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.travel_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.travel_request_attendees ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.travel_request_timeline ENABLE ROW LEVEL SECURITY;

-- 6. RLS Policies (following the 7-pattern system)

-- Pattern 1: Core user table (user_profiles) - Simple only, no functions
CREATE POLICY "users_manage_own_user_profiles"
ON public.user_profiles
FOR ALL
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Pattern 2: Simple user ownership for travel requests
CREATE POLICY "users_manage_own_travel_requests"
ON public.travel_requests
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Pattern 6A: Manager access using auth.users metadata
CREATE OR REPLACE FUNCTION public.is_manager_from_auth()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $func$
SELECT EXISTS (
    SELECT 1 FROM auth.users au
    WHERE au.id = auth.uid() 
    AND (au.raw_user_meta_data->>'role' = 'manager' 
         OR au.raw_user_meta_data->>'role' = 'admin'
         OR au.raw_app_meta_data->>'role' = 'manager'
         OR au.raw_app_meta_data->>'role' = 'admin')
)
$func$;

-- Manager access policy for travel requests
CREATE POLICY "managers_view_team_travel_requests"
ON public.travel_requests
FOR SELECT
TO authenticated
USING (
    user_id = auth.uid() OR 
    manager_id = auth.uid() OR 
    public.is_manager_from_auth()
);

-- Pattern 2: Simple ownership for attendees
CREATE POLICY "users_manage_request_attendees"
ON public.travel_request_attendees
FOR ALL
TO authenticated
USING (
    request_id IN (
        SELECT id FROM public.travel_requests WHERE user_id = auth.uid()
    )
)
WITH CHECK (
    request_id IN (
        SELECT id FROM public.travel_requests WHERE user_id = auth.uid()
    )
);

-- Pattern 4: Public read for timeline (managers can see), private write
CREATE POLICY "view_timeline_entries"
ON public.travel_request_timeline
FOR SELECT
TO authenticated
USING (
    request_id IN (
        SELECT id FROM public.travel_requests 
        WHERE user_id = auth.uid() OR manager_id = auth.uid()
    )
    OR public.is_manager_from_auth()
);

CREATE POLICY "create_timeline_entries"
ON public.travel_request_timeline
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() IS NOT NULL);

-- 7. Triggers
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

CREATE TRIGGER update_user_profiles_updated_at
    BEFORE UPDATE ON public.user_profiles
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_travel_requests_updated_at
    BEFORE UPDATE ON public.travel_requests
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER travel_request_timeline_trigger
    AFTER INSERT OR UPDATE ON public.travel_requests
    FOR EACH ROW EXECUTE FUNCTION public.create_timeline_entry();

-- 8. Mock Data for Development/Testing
DO $$
DECLARE
    admin_uuid UUID := gen_random_uuid();
    manager_uuid UUID := gen_random_uuid();
    employee1_uuid UUID := gen_random_uuid();
    employee2_uuid UUID := gen_random_uuid();
    request1_uuid UUID := gen_random_uuid();
    request2_uuid UUID := gen_random_uuid();
    request3_uuid UUID := gen_random_uuid();
BEGIN
    -- Create auth users with complete field structure
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        (admin_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'admin@travelcompany.com', crypt('admin123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Admin User", "role": "admin"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (manager_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'manager@travelcompany.com', crypt('manager123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Sarah Johnson", "role": "manager"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (employee1_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'john.doe@travelcompany.com', crypt('employee123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "John Doe", "role": "employee"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (employee2_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'jane.smith@travelcompany.com', crypt('employee123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Jane Smith", "role": "employee"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null);

    -- User profiles will be created automatically by trigger

    -- Update manager relationships
    UPDATE public.user_profiles 
    SET manager_id = manager_uuid, department = 'Sales'
    WHERE id IN (employee1_uuid, employee2_uuid);

    -- Create sample travel requests
    INSERT INTO public.travel_requests (
        id, user_id, trip_name, business_justification, expected_outcomes,
        departure_date, departure_time, return_date, return_time,
        origin_city, destination_city, transportation_cost, accommodation_cost,
        meals_cost, other_cost, status, priority, manager_id, submitted_at
    ) VALUES
        (request1_uuid, employee1_uuid, 'Client Meeting - London', 
         'Critical client presentation for Q1 contract renewal',
         'Secure renewal contract worth $500K, establish long-term partnership',
         '2024-02-15', '08:00:00', '2024-02-18', '18:00:00',
         'New York', 'London', 1200.00, 800.00, 400.00, 150.00,
         'pending'::public.request_status, 'high'::public.priority_level, manager_uuid, now()),
        
        (request2_uuid, employee2_uuid, 'Tech Conference - Berlin',
         'Industry knowledge sharing and networking opportunity',
         'Learn latest technologies, establish vendor relationships, present company capabilities',
         '2024-03-10', '06:00:00', '2024-03-13', '20:00:00',
         'New York', 'Berlin', 900.00, 600.00, 300.00, 100.00,
         'approved'::public.request_status, 'medium'::public.priority_level, manager_uuid, now()),
         
        (request3_uuid, employee1_uuid, 'Training Workshop - Tokyo',
         'Advanced certification training for new product line',
         'Obtain certification, train team on new methodologies',
         '2024-04-05', '10:00:00', '2024-04-08', '16:00:00',
         'Los Angeles', 'Tokyo', 1500.00, 1000.00, 500.00, 200.00,
         'draft'::public.request_status, 'low'::public.priority_level, manager_uuid, null);

    -- Create attendees
    INSERT INTO public.travel_request_attendees (request_id, attendee_name, attendee_email, attendee_role)
    VALUES
        (request1_uuid, 'John Doe', 'john.doe@travelcompany.com', 'Sales Representative'),
        (request1_uuid, 'Alex Wilson', 'alex.wilson@travelcompany.com', 'Technical Lead'),
        (request2_uuid, 'Jane Smith', 'jane.smith@travelcompany.com', 'Senior Developer'),
        (request3_uuid, 'John Doe', 'john.doe@travelcompany.com', 'Team Lead'),
        (request3_uuid, 'Mark Johnson', 'mark.johnson@travelcompany.com', 'Product Manager');

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key error during mock data creation: %', SQLERRM;
    WHEN unique_violation THEN
        RAISE NOTICE 'Unique constraint error during mock data creation: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error during mock data creation: %', SQLERRM;
END $$;