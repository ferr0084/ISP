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

    // Add bidirectional contact relationship
    try {
      // Add inviter to invitee's contacts
      const { error: contactError1 } = await supabaseClient
        .from('contacts')
        .insert({
          user_id: user_id, // invitee adds inviter as contact
          contact_id: invitation.inviter_id,
        });

      if (contactError1 && !contactError1.message.includes('duplicate key')) {
        console.error('Error adding contact relationship:', contactError1);
      }

      // Add invitee to inviter's contacts
      const { error: contactError2 } = await supabaseClient
        .from('contacts')
        .insert({
          user_id: invitation.inviter_id, // inviter adds invitee as contact
          contact_id: user_id,
        });

      if (contactError2 && !contactError2.message.includes('duplicate key')) {
        console.error('Error adding reverse contact relationship:', contactError2);
      }

      console.log(
        `Invitation ${invitation.id} accepted. Contacts added between ${invitation.inviter_id} and ${user_id}`,
      );
    } catch (error) {
      console.error('Error creating contact relationships:', error);
      // Don't fail the entire operation if contact creation fails
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
