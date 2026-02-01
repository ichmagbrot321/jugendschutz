import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
);

export default async function handler(req, res) {
  const { targetUserId, role } = req.body;
  const token = req.headers.authorization?.replace('Bearer ', '');

  if (!token) return res.status(401).json({ error: 'NO_TOKEN' });

  const { data } = await supabase.auth.getUser(token);

  const { data: requester } = await supabase
    .from('users')
    .select('role')
    .eq('id', data.user.id)
    .single();

  if (requester.role !== 'owner') {
    return res.status(403).json({ error: 'NOT_OWNER' });
  }

  if (role === 'owner') {
    return res.status(400).json({ error: 'OWNER_ALREADY_DEFINED' });
  }

  await supabase
    .from('users')
    .update({ role })
    .eq('id', targetUserId);

  res.json({ success: true });
}
