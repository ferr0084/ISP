import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.42.0";

console.log("Hello from accept-invite Function!");

serve(async (req) => {
  try {
    const { token, user_id } = await req.json();

    if (!token || !user_id) {
      return new Response(
        JSON.stringify({ error: "token and user_id are required" }),
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

    // Look up the invitation
    const { data: invitation, error: fetchError } = await supabaseClient
      .from("invitations")
      .select("*")
      .eq("token", token)
      .single();

    if (fetchError) {
      throw fetchError;
    }
    if (!invitation) {
      return new Response(JSON.stringify({ error: "Invitation not found" }), {
        headers: { "Content-Type": "application/json" },
        status: 404,
      });
    }
    if (invitation.status !== "pending") {
      return new Response(
        JSON.stringify({ error: "Invitation is not pending" }),
        {
          headers: { "Content-Type": "application/json" },
          status: 400,
        },
      );
    }
    // Check for expiration (optional)
    if (invitation.expires_at && new Date(invitation.expires_at) < new Date()) {
      // Optionally update status to 'expired'
      await supabaseClient
        .from("invitations")
        .update({ status: "expired" })
        .eq("id", invitation.id);
      return new Response(JSON.stringify({ error: "Invitation has expired" }), {
        headers: { "Content-Type": "application/json" },
        status: 400,
      });
    }

    // Update invitation status to 'accepted'
    const { data: updatedInvitation, error: updateError } = await supabaseClient
      .from("invitations")
      .update({ status: "accepted" })
      .eq("id", invitation.id)
      .select();

    if (updateError) {
      throw updateError;
    }

    // If group_id is present, add the user to the group_members table
    if (invitation.group_id) {
      const { error: groupMemberError } = await supabaseClient
        .from("group_members")
        .insert([
          {
            group_id: invitation.group_id,
            user_id: user_id,
            role: "member", // Default role
          },
        ]);

      if (groupMemberError) {
        console.error("Error adding user to group_members:", groupMemberError);
        // Don't fail the entire operation if adding to group fails
      } else {
        console.log(
          `User ${user_id} added to group ${invitation.group_id} as member`,
        );
      }
    }

    return new Response(
      JSON.stringify({ message: "Invitation accepted", updatedInvitation }),
      {
        headers: { "Content-Type": "application/json" },
        status: 200,
      },
    );
  } catch (error) {
    console.error(error);
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { "Content-Type": "application/json" },
      status: 500,
    });
  }
});