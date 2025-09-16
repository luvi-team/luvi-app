-- Create email_preferences table with RLS
CREATE TABLE email_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    newsletter BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE email_preferences ENABLE ROW LEVEL SECURITY;

-- Owner-based policies (user_id = auth.uid())
CREATE POLICY "Users can view their own email preferences" ON email_preferences
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can insert their own email preferences" ON email_preferences
    FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update their own email preferences" ON email_preferences
    FOR UPDATE USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can delete their own email preferences" ON email_preferences
    FOR DELETE USING (user_id = auth.uid());

-- Create indexes for performance
CREATE INDEX idx_email_preferences_user_id ON email_preferences(user_id);
CREATE INDEX idx_email_preferences_created_at ON email_preferences(created_at);

-- Ensure one row per user (unique constraint)
CREATE UNIQUE INDEX idx_email_preferences_user_unique ON email_preferences(user_id);