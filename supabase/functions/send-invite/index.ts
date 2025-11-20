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

    // Create invitation record ALWAYS
    const invitationData = {
      inviter_id: inviter_id,
      invitee_email: invitee_email,
      token: token,
      status: "pending",
      group_id: group_id || null,
    };

    const { data: invitationRecord, error: invitationError } = await supabaseClient
      .from("invitations")
      .insert([invitationData])
      .select();

    if (invitationError) {
      throw invitationError;
    }

    // Check if user already exists in profiles
    console.log(`Looking up invitee_id by email: ${invitee_email}`);
    const { data: inviteeProfile, error: inviteeProfileError } = await supabaseClient
      .from("profiles")
      .select("id")
      .eq("email", invitee_email)
      .single();

    if (inviteeProfileError && inviteeProfileError.code !== 'PGRST116') { // PGRST116 means no rows found
      console.error('Error looking up invitee profile:', inviteeProfileError);
      throw inviteeProfileError;
    }

    if (inviteeProfile) {
      // User exists, send in-app notification
      const invitee_id = inviteeProfile.id;
      console.log(`Sending notification to user_id (invitee): ${invitee_id}, email: ${invitee_email}`);
      const notificationMessage = `You have been invited to a group.`;
      const notificationData = {
        group_id: group_id,
        inviter_id: inviter_id,
        token: token, // INCLUDE TOKEN
      };

      const { error: notificationError } = await supabaseClient
        .from("notifications")
        .insert({
          user_id: invitee_id,
          type: "group_invite",
          title: "Group Invitation",
          message: notificationMessage,
          data: notificationData,
        });

      if (notificationError) {
        console.error('Error creating notification:', notificationError);
        throw notificationError;
      }

      console.log(`Notification created successfully for user ${invitee_id}`);
      return new Response(JSON.stringify({
        message: "User already exists, in-app notification sent.",
        user_id: invitee_id,
      }), {
        headers: { "Content-Type": "application/json" },
        status: 200,
      });
    }

    // User does not exist, send email
    const inviteType = group_id ? "group_invite" : "friend_invite";
    let redirectToUrl = `${Deno.env.get("SITE_URL") || "com.idiotsocialplatform.app://"}invite-accept?token=${token}`;
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
            group_id: group_id || null,
          }
        }
      );

      if (inviteError) {
        console.error("Built-in invite email failed:", inviteError.message);
        console.log(`Invite created but email failed. Share this link: com.idiotsocialplatform.app://invite?token=${token}${group_id ? `&group_id=${group_id}` : ''}`);

        return new Response(JSON.stringify({
          message: "Invitation created but email failed",
          data: invitationRecord,
          email_error: inviteError.message,
          invite_link: `com.idiotsocialplatform.app://invite?token=${token}${group_id ? `&group_id=${group_id}` : ''}`
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
        data: invitationRecord,
        email_error: error.message || String(error),
        invite_link: `com.idiotsocialplatform.app://invite?token=${token}${group_id ? `&group_id=${group_id}` : ''}`
      }), {
        headers: { "Content-Type": "application/json" },
        status: 200,
      });
    }

    return new Response(JSON.stringify({ message: "Invitation sent", data: invitationRecord }), {
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