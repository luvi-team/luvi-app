-- Create daily_plan table with RLS
CREATE TABLE IF NOT EXISTS daily_plan (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    mood TEXT CHECK (mood IN ('happy', 'neutral', 'sad', 'stressed', 'anxious')),
    energy_level INTEGER CHECK (energy_level >= 1 AND energy_level <= 10),
    symptoms JSONB DEFAULT '[]',
    notes TEXT,
    activities JSONB DEFAULT '[]',
    nutrition JSONB DEFAULT '{}',
    sleep_hours DECIMAL(3,1) CHECK (sleep_hours >= 0 AND sleep_hours <= 24),
    exercise_minutes INTEGER CHECK (exercise_minutes >= 0),
    water_intake_ml INTEGER CHECK (water_intake_ml >= 0),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT unique_user_date UNIQUE(user_id, date)
);

-- Enable RLS
ALTER TABLE daily_plan ENABLE ROW LEVEL SECURITY;

-- Create function to automatically set user_id from auth context
CREATE OR REPLACE FUNCTION set_user_id_from_auth()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
BEGIN
    -- Always set user_id from auth context
    NEW.user_id := auth.uid();
    IF NEW.user_id IS NULL THEN
        RAISE EXCEPTION 'missing auth context (auth.uid() is null)';
    END IF;

    RETURN NEW;
END;
$$;
-- Create trigger to auto-set user_id on insert
CREATE TRIGGER ensure_user_id_daily_plan
    BEFORE INSERT ON daily_plan
    FOR EACH ROW
    EXECUTE FUNCTION set_user_id_from_auth();

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for updated_at
CREATE TRIGGER update_daily_plan_updated_at
    BEFORE UPDATE ON daily_plan
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- RLS Policies with USING and WITH CHECK clauses
-- Policy for SELECT: Users can only view their own daily plans
CREATE POLICY "Users can view own daily plans" 
    ON daily_plan
    FOR SELECT 
    USING (user_id = auth.uid());

-- Policy for INSERT: Users can only insert their own daily plans
CREATE POLICY "Users can insert own daily plans" 
    ON daily_plan
    FOR INSERT 
    WITH CHECK (user_id = auth.uid());

-- Policy for UPDATE: Users can only update their own daily plans
CREATE POLICY "Users can update own daily plans" 
    ON daily_plan
    FOR UPDATE 
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

-- Policy for DELETE: Users can only delete their own daily plans
CREATE POLICY "Users can delete own daily plans" 
    ON daily_plan
    FOR DELETE 
    USING (user_id = auth.uid());

-- Create indexes for performance
CREATE INDEX idx_daily_plan_user_id ON daily_plan(user_id);
CREATE INDEX idx_daily_plan_date ON daily_plan(date DESC);
CREATE INDEX idx_daily_plan_user_date ON daily_plan(user_id, date DESC);
CREATE INDEX idx_daily_plan_created_at ON daily_plan(created_at DESC);

-- Add comment for documentation
COMMENT ON TABLE daily_plan IS 'Daily health and wellness tracking plans with strict RLS enforcement';
COMMENT ON COLUMN daily_plan.user_id IS 'References auth.users, automatically set from auth.uid() via trigger';
COMMENT ON COLUMN daily_plan.symptoms IS 'JSON array of symptom objects [{name, severity, notes}]';
COMMENT ON COLUMN daily_plan.activities IS 'JSON array of activity objects [{type, duration, intensity}]';
COMMENT ON COLUMN daily_plan.nutrition IS 'JSON object with meal tracking {breakfast, lunch, dinner, snacks}';