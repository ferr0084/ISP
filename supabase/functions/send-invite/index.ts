import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.42.0";

console.log("Hello from Functions!");

serve(async (req) => {
  try {
    const { inviter_id, invitee_email } = await req.json();

    if (!inviter_id || !invitee_email) {
      return new Response(
        JSON.stringify({ error: "inviter_id and invitee_email are required" }),
        {
          headers: { "Content-Type": "application/json" },
          status: 400,
        },
      );
    }

    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "", // Use service role key for RLS bypass
      {
        auth: {
          persistSession: false,
        },
      },
    );

    // Generate a unique token for the invitation
    const { data: tokenData, error: tokenError } = await supabaseClient.rpc(
      "uuid_generate_v4",
    );
    if (tokenError) throw tokenError;
    const token = tokenData;

    // Insert invitation into the 'invitations' table
    const { data, error } = await supabaseClient
      .from("invitations")
      .insert([
        {
          inviter_id: inviter_id,
          invitee_email: invitee_email,
          token: token,
          status: "pending",
        },
      ])
      .select();

    if (error) {
      throw error;
    }

    // Construct the invite URL (replace with your actual app deep link)
    const inviteUrl = `yourapp://invite?token=${token}`;
    console.log(`Sending invite to ${invitee_email} with link: ${inviteUrl}`);
    // In a real scenario, you would integrate with an email service here
    // e.g., SendGrid, Resend, or Supabase's built-in email capabilities

    return new Response(JSON.stringify({ message: "Invitation sent", data }), {
      headers: { "Content-Type": "application/json" },
      status: 200,
    });
  } catch (error) {
    console.error(error);
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { "Content-Type": "application/json" },
      status: 500,
    });
  }
});
