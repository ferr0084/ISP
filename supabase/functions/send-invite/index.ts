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

    // Send email using Supabase's built-in invite system
    // Note: This creates a user account, but redirects to our custom acceptance flow
    try {
      const { error: inviteError } = await supabaseClient.auth.admin.inviteUserByEmail(
        invitee_email,
        {
          redirectTo: `${Deno.env.get("SITE_URL") || "yourapp://"}invite-accept?token=${token}`,
          data: {
            invitation_token: token,
            inviter_id: inviter_id,
            invite_type: "friend_invite"
          }
        }
      );

      if (inviteError) {
        console.error("Built-in invite email failed:", inviteError.message);
        // Fallback: invitation is still created, user can share link manually
        console.log(`Invite created but email failed. Share this link: yourapp://invite?token=${token}`);
      } else {
        console.log(`Invite email sent to ${invitee_email} using Supabase built-in system`);
      }
    } catch (error) {
      console.error("Email sending error:", error);
      console.log(`Invite created. Manual sharing token: ${token}`);
    }

    const inviteUrl = `yourapp://invite?token=${token}`;
    console.log(`Invite processed for ${invitee_email}. Token: ${token}`);

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
