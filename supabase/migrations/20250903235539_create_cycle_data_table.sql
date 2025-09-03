-- Create cycle_data table with RLS
CREATE TABLE cycle_data (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    cycle_length INTEGER NOT NULL CHECK (cycle_length > 0 AND cycle_length <= 60),
    period_duration INTEGER NOT NULL CHECK (period_duration > 0 AND period_duration <= 15),
    last_period DATE NOT NULL,
    age INTEGER NOT NULL CHECK (age >= 10 AND age <= 65),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE cycle_data ENABLE ROW LEVEL SECURITY;

-- Owner-based policies (user_id = auth.uid())
CREATE POLICY "Users can view their own cycle data" ON cycle_data
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can insert their own cycle data" ON cycle_data
    FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update their own cycle data" ON cycle_data
    FOR UPDATE USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can delete their own cycle data" ON cycle_data
    FOR DELETE USING (user_id = auth.uid());

-- Create indexes for performance
CREATE INDEX idx_cycle_data_user_id ON cycle_data(user_id);
CREATE INDEX idx_cycle_data_created_at ON cycle_data(created_at);
CREATE INDEX idx_cycle_data_last_period ON cycle_data(last_period);