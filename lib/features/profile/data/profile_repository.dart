import "package:supabase_flutter/supabase_flutter.dart";
import "profile_model.dart";

class ProfileRepository {
  final SupabaseClient supabase;
  ProfileRepository(this.supabase);

  Future<Profile> getOrCreateProfile(String userId) async {
    final res = await supabase
        .from("profiles")
        .select()
        .eq("id", userId)
        .maybeSingle();

    if (res == null) {
      final empty = Profile.empty(userId);
      await supabase.from("profiles").insert(empty.toMap());
      return empty;
    }

    return Profile.fromMap(res as Map<String, dynamic>);
  }

  Future<void> updateProfile(Profile profile) async {
    await supabase.from("profiles").upsert(profile.toMap());
  }
}
