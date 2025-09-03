# ADR-0002: Least-Privilege & RLS (Supabase)
Status: Accepted
Kontext: Gesundheits-/PII-Daten; DSGVO.
Entscheidung: RLS ON, owner-based Policies (user_id = auth.uid()) für SELECT/INSERT/UPDATE/DELETE.
Konsequenzen: Alle Tabellen erhalten Zwangs-RLS; Service-Role nur serverseitig (Edge Functions).
