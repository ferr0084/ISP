import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.42.0";

console.log("Hello from Functions!");

serve(async (req) => {
  try {
    const { inviter_id, invitee_email, group_id } = await req.json();

    if (!inviter_id || !invitee_email) {
      return new Response(
        JSON.stringify({ error: "inviter_id and invitee_email are required" }),
        {
          headers: { "Content-Type": "application/json" },
          status: 400,
        },
      );
    }

    // Validate group_id if present
    if (group_id && !/^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/.test(group_id)) {
      return new Response(
        JSON.stringify({ error: "Invalid group_id format" }),
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
    const token = crypto.randomUUID();

    const invitationData = {
      inviter_id: inviter_id,
      invitee_email: invitee_email,
      token: token,
      status: "pending",
      group_id: group_id || null, // Add group_id if present
    };

    // Insert invitation into the 'invitations' table
    const { data, error } = await supabaseClient
      .from("invitations")
      .insert([invitationData])
      .select();

    if (error) {
      throw error;
    }

    const inviteType = group_id ? "group_invite" : "friend_invite";
    let redirectToUrl = `${Deno.env.get("SITE_URL") || "yourapp://"}invite-accept?token=${token}`;
    if (group_id) {
      redirectToUrl += `&group_id=${group_id}`;
    }

    try {
      const { error: inviteError } = await supabaseClient.auth.admin.inviteUserByEmail(
        invitee_email,
        {
          redirectTo: redirectToUrl,
          data: {
            invitation_token: token,
            inviter_id: inviter_id,
            invite_type: inviteType,
            group_id: group_id || null, // Pass group_id to email data
          }
        }
      );

      if (inviteError) {
        console.error("Built-in invite email failed:", inviteError.message);
        console.log(`Invite created but email failed. Share this link: yourapp://invite?token=${token}${group_id ? `&group_id=${group_id}` : ''}`);

        return new Response(JSON.stringify({
          message: "Invitation created but email failed",
          data,
          email_error: inviteError.message,
          invite_link: `yourapp://invite?token=${token}${group_id ? `&group_id=${group_id}` : ''}`
        }), {
          headers: { "Content-Type": "application/json" },
          status: 200,
        });
      } else {
        console.log(`Invite email sent to ${invitee_email} using Supabase built-in system`);
      }
    } catch (error) {
      console.error("Email sending error:", error);
      console.log(`Invite created. Manual sharing token: ${token}`);

      return new Response(JSON.stringify({
        message: "Invitation created but email failed",
        data,
        email_error: error.message || String(error),
        invite_link: `yourapp://invite?token=${token}${group_id ? `&group_id=${group_id}` : ''}`
      }), {
        headers: { "Content-Type": "application/json" },
        status: 200,
      });
    }

    const inviteUrl = `yourapp://invite?token=${token}${group_id ? `&group_id=${group_id}` : ''}`;
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