import "package:flutter/material.dart";
import "placeholder_models.dart";

/// Single source of truth for ALL placeholders.
/// Dev Menu -> "Placeholder Map (All)" should open /placeholders.
/// Tapping an item navigates to /p/:id.
const List<PlaceholderItem> kPlaceholders = [
  // 0) Global / App-Wide
  PlaceholderItem(
    id: "global-loading",
    section: "0) Global / App-Wide",
    title: "Global loading screen",
    subtitle: "⏳ Full-screen loading state",
    icon: Icons.hourglass_top,
  ),
  PlaceholderItem(
    id: "global-error",
    section: "0) Global / App-Wide",
    title: "Global error screen",
    subtitle: "❌ Something went wrong + retry",
    icon: Icons.error_outline,
  ),
  PlaceholderItem(
    id: "offline-banner",
    section: "0) Global / App-Wide",
    title: "Offline / no internet banner",
    subtitle: "📡 Banner + CTA to retry",
    icon: Icons.wifi_off,
  ),
  PlaceholderItem(
    id: "retry-state",
    section: "0) Global / App-Wide",
    title: "Retry state",
    subtitle: "🔁 Button + message",
    icon: Icons.refresh,
  ),
  PlaceholderItem(
    id: "dev-banner",
    section: "0) Global / App-Wide",
    title: "Dev Mode banner",
    subtitle: "🧪 Only visible in debug",
    icon: Icons.bug_report,
  ),
  PlaceholderItem(
    id: "empty-list",
    section: "0) Global / App-Wide",
    title: "Empty list placeholder",
    subtitle: "Icon + text",
    icon: Icons.inbox_outlined,
  ),
  PlaceholderItem(
    id: "skeletons",
    section: "0) Global / App-Wide",
    title: "Skeleton loaders",
    subtitle: "Lists / cards skeleton UI",
    icon: Icons.view_agenda_outlined,
  ),
  PlaceholderItem(
    id: "toasts",
    section: "0) Global / App-Wide",
    title: "Toast / Snackbar messages",
    subtitle: "Success / error / info",
    icon: Icons.notifications_active_outlined,
  ),
  PlaceholderItem(
    id: "confirm-dialog",
    section: "0) Global / App-Wide",
    title: "Confirmation dialogs",
    subtitle: "Yes / No confirmation",
    icon: Icons.help_outline,
  ),
  PlaceholderItem(
    id: "bottom-sheets",
    section: "0) Global / App-Wide",
    title: "Bottom sheets",
    subtitle: "Actions / filters",
    icon: Icons.vertical_align_top,
  ),

  // 1) App Start & Auth Flow
  PlaceholderItem(
    id: "splash",
    section: "1) App Start & Auth",
    title: "Splash / Launch",
    subtitle: "Logo + preparing...",
    icon: Icons.health_and_safety,
  ),
  PlaceholderItem(
    id: "auth-gate",
    section: "1) App Start & Auth",
    title: "Auth Gate",
    subtitle: "Checking session... redirecting...",
    icon: Icons.lock_clock,
  ),
  PlaceholderItem(
    id: "role-select",
    section: "1) App Start & Auth",
    title: "Role selection",
    subtitle: "Client / Caregiver / Agency / Admin (dev)",
    icon: Icons.people_alt_outlined,
  ),
  PlaceholderItem(
    id: "login-email",
    section: "1) App Start & Auth",
    title: "Email / Phone login",
    subtitle: "Email input + continue",
    icon: Icons.alternate_email,
  ),
  PlaceholderItem(
    id: "otp-sent",
    section: "1) App Start & Auth",
    title: "OTP sent confirmation",
    subtitle: "Code sent + instructions",
    icon: Icons.mark_email_read_outlined,
  ),
  PlaceholderItem(
    id: "otp-input",
    section: "1) App Start & Auth",
    title: "OTP input",
    subtitle: "Enter code + verify",
    icon: Icons.password_outlined,
  ),
  PlaceholderItem(
    id: "otp-resend",
    section: "1) App Start & Auth",
    title: "Resend code timer",
    subtitle: "Countdown + resend",
    icon: Icons.timer_outlined,
  ),
  PlaceholderItem(
    id: "otp-wrong",
    section: "1) App Start & Auth",
    title: "Wrong code error",
    subtitle: "Invalid code + retry",
    icon: Icons.warning_amber_outlined,
  ),
  PlaceholderItem(
    id: "first-time-setup",
    section: "1) App Start & Auth",
    title: "First-time setup",
    subtitle: "Checklist of required profile steps",
    icon: Icons.checklist_outlined,
  ),

  // 2) Client Experience
  PlaceholderItem(
    id: "client-home",
    section: "2) Client",
    title: "Client Home",
    subtitle: "Search + categories + featured + CTA",
    icon: Icons.home_outlined,
  ),
  PlaceholderItem(
    id: "client-requests",
    section: "2) Client",
    title: "Client Requests",
    subtitle: "List + status + CTA create",
    icon: Icons.receipt_long_outlined,
  ),
  PlaceholderItem(
    id: "client-request-detail",
    section: "2) Client",
    title: "Request Detail",
    subtitle: "Summary + timeline + cancel/complete",
    icon: Icons.subject_outlined,
  ),
  PlaceholderItem(
    id: "client-messages",
    section: "2) Client",
    title: "Client Messages",
    subtitle: "Conversations + empty state",
    icon: Icons.chat_bubble_outline,
  ),
  PlaceholderItem(
    id: "chat-thread",
    section: "2) Client",
    title: "Chat Thread",
    subtitle: "Bubbles + typing + attachments",
    icon: Icons.forum_outlined,
  ),
  PlaceholderItem(
    id: "client-profile",
    section: "2) Client",
    title: "Client Profile",
    subtitle: "Edit profile + payment placeholder + logout",
    icon: Icons.person_outline,
  ),

  // 3) Caregiver Experience
  PlaceholderItem(
    id: "caregiver-home",
    section: "3) Caregiver",
    title: "Caregiver Home",
    subtitle: "Availability + incoming requests + earnings",
    icon: Icons.volunteer_activism_outlined,
  ),
  PlaceholderItem(
    id: "caregiver-requests",
    section: "3) Caregiver",
    title: "Caregiver Requests",
    subtitle: "Cards + accept/decline",
    icon: Icons.list_alt_outlined,
  ),
  PlaceholderItem(
    id: "caregiver-request-detail",
    section: "3) Caregiver",
    title: "Caregiver Request Detail",
    subtitle: "Details + client preview",
    icon: Icons.assignment_outlined,
  ),
  PlaceholderItem(
    id: "caregiver-messages",
    section: "3) Caregiver",
    title: "Caregiver Messages",
    subtitle: "Conversations + chat thread",
    icon: Icons.message_outlined,
  ),
  PlaceholderItem(
    id: "caregiver-profile",
    section: "3) Caregiver",
    title: "Caregiver Profile",
    subtitle: "Verification + skills + rates + docs",
    icon: Icons.badge_outlined,
  ),

  // 4) Agency
  PlaceholderItem(
    id: "agency-dashboard",
    section: "4) Agency",
    title: "Agency Dashboard",
    subtitle: "Caregivers + requests overview + earnings",
    icon: Icons.apartment_outlined,
  ),
  PlaceholderItem(
    id: "agency-apply",
    section: "4) Agency",
    title: "Agency Apply",
    subtitle: "Application form placeholder",
    icon: Icons.note_add_outlined,
  ),
  PlaceholderItem(
    id: "agency-status",
    section: "4) Agency",
    title: "Agency Status",
    subtitle: "Pending/approved tracker",
    icon: Icons.fact_check_outlined,
  ),

  // 5) Admin / Dev Tools
  PlaceholderItem(
    id: "admin-panel",
    section: "5) Admin / Dev",
    title: "Admin Panel",
    subtitle: "Moderation & system control",
    icon: Icons.admin_panel_settings_outlined,
  ),
  PlaceholderItem(
    id: "dev-tools",
    section: "5) Admin / Dev",
    title: "Dev Tools",
    subtitle: "Seed data, toggle role, simulate errors",
    icon: Icons.build_outlined,
  ),

  // 6) System & UX Edge Cases
  PlaceholderItem(
    id: "error-auth-failed",
    section: "6) System / Edge Cases",
    title: "Auth failed",
    subtitle: "Error screen + retry",
    icon: Icons.lock_outline,
  ),
  PlaceholderItem(
    id: "error-timeout",
    section: "6) System / Edge Cases",
    title: "Network timeout",
    subtitle: "Timeout + retry",
    icon: Icons.timer_off_outlined,
  ),
  PlaceholderItem(
    id: "error-permission",
    section: "6) System / Edge Cases",
    title: "Permission denied",
    subtitle: "Explain + open settings",
    icon: Icons.block_outlined,
  ),
  PlaceholderItem(
    id: "error-unknown",
    section: "6) System / Edge Cases",
    title: "Unknown error",
    subtitle: "Fallback + support CTA",
    icon: Icons.report_problem_outlined,
  ),
  PlaceholderItem(
    id: "perm-location",
    section: "6) System / Edge Cases",
    title: "Location permission",
    subtitle: "Explain why needed",
    icon: Icons.location_on_outlined,
  ),
  PlaceholderItem(
    id: "perm-notifications",
    section: "6) System / Edge Cases",
    title: "Notifications permission",
    subtitle: "Explain why needed",
    icon: Icons.notifications_none,
  ),
  PlaceholderItem(
    id: "perm-camera",
    section: "6) System / Edge Cases",
    title: "Camera / gallery permission",
    subtitle: "For documents / profile photo",
    icon: Icons.camera_alt_outlined,
  ),

  // 7) Payments
  PlaceholderItem(
    id: "payment-add",
    section: "7) Payments",
    title: "Add payment method",
    subtitle: "Card form placeholder",
    icon: Icons.credit_card_outlined,
  ),
  PlaceholderItem(
    id: "payment-none",
    section: "7) Payments",
    title: "No payment method yet",
    subtitle: "Empty state + CTA add",
    icon: Icons.credit_card_off_outlined,
  ),
  PlaceholderItem(
    id: "payment-success",
    section: "7) Payments",
    title: "Payment success",
    subtitle: "Receipt + next steps",
    icon: Icons.check_circle_outline,
  ),
  PlaceholderItem(
    id: "payment-failed",
    section: "7) Payments",
    title: "Payment failed",
    subtitle: "Try again + support CTA",
    icon: Icons.cancel_outlined,
  ),
  PlaceholderItem(
    id: "payment-history",
    section: "7) Payments",
    title: "Transaction history (empty)",
    subtitle: "No transactions yet",
    icon: Icons.history_outlined,
  ),

  // 8) Notifications
  PlaceholderItem(
    id: "notifications-list",
    section: "8) Notifications",
    title: "Notifications list",
    subtitle: "List + unread states",
    icon: Icons.notifications_outlined,
  ),
  PlaceholderItem(
    id: "notifications-empty",
    section: "8) Notifications",
    title: "Empty notifications",
    subtitle: "No notifications yet",
    icon: Icons.notifications_off_outlined,
  ),
  PlaceholderItem(
    id: "notification-detail",
    section: "8) Notifications",
    title: "Notification detail",
    subtitle: "Deep link placeholder",
    icon: Icons.open_in_new_outlined,
  ),

  // 9) Settings
  PlaceholderItem(
    id: "settings",
    section: "9) Settings",
    title: "Settings",
    subtitle: "Language, Theme, Privacy, Terms, About",
    icon: Icons.settings_outlined,
  ),
  PlaceholderItem(
    id: "terms",
    section: "9) Settings",
    title: "Terms & conditions",
    subtitle: "Legal placeholder",
    icon: Icons.description_outlined,
  ),
  PlaceholderItem(
    id: "about",
    section: "9) Settings",
    title: "About",
    subtitle: "Version + build + env",
    icon: Icons.info_outline,
  ),
];
