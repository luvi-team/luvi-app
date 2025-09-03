-- Create consents table with RLS
CREATE TABLE consents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    scopes JSONB NOT NULL DEFAULT '{}',
    version TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    revoked_at TIMESTAMPTZ NULL
);

-- Enable RLS
ALTER TABLE consents ENABLE ROW LEVEL SECURITY;

-- Owner-based policies (user_id = auth.uid())
CREATE POLICY "Users can view their own consents" ON consents
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can insert their own consents" ON consents
    FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update their own consents" ON consents
    FOR UPDATE USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can delete their own consents" ON consents
    FOR DELETE USING (user_id = auth.uid());

-- Create indexes for performance
CREATE INDEX idx_consents_user_id ON consents(user_id);
CREATE INDEX idx_consents_created_at ON consents(created_at);
CREATE INDEX idx_consents_revoked_at ON consents(revoked_at) WHERE revoked_at IS NOT NULL;