import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
);

export default async function handler(req, res) {
  const token = req.headers.authorization?.replace('Bearer ', '');
  if (!token) return res.status(401).json({ error: 'NO_TOKEN' });

  const { data, error } = await supabase.auth.getUser(token);
  if (error) return res.status(401).json({ error: 'INVALID_TOKEN' });

  const { data: user } = await supabase
    .from('users')
    .select('id,email,role,banned')
    .eq('id', data.user.id)
    .single();

  return res.json(user);
}
