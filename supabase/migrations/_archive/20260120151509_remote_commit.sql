drop extension if exists "pg_net";

create schema if not exists "admin";

create schema if not exists "app_private";

create extension if not exists "citext" with schema "public";

create extension if not exists "pg_trgm" with schema "public";

create extension if not exists "postgis" with schema "public";

create type "public"."booking_status" as enum ('draft', 'requested', 'accepted', 'in_progress', 'completed', 'cancelled');

create type "public"."message_type" as enum ('text', 'system');

create sequence "public"."login_audit_id_seq";

create sequence "public"."messages_id_seq";

create sequence "public"."services_id_seq";

alter table "public"."profiles" alter column "role" drop default;

alter type "public"."user_role" rename to "user_role__old_version_to_be_dropped";

create type "public"."user_role" as enum ('client', 'caregiver', 'agency', 'admin', 'super_admin', 'ceo', 'support');


  create table "public"."admin_members" (
    "user_id" uuid not null,
    "role" text not null default 'super_admin'::text,
    "status" text not null default 'active'::text,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."admin_members" enable row level security;


  create table "public"."agencies" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null,
    "address" text,
    "verified" boolean not null default false,
    "owner_user_id" uuid not null,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."agencies" enable row level security;


  create table "public"."applications" (
    "id" uuid not null default gen_random_uuid(),
    "job_id" uuid not null,
    "caregiver_id" uuid not null,
    "status" text not null default 'sent'::text,
    "proposed_rate" numeric(10,2),
    "message" text,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
      );



  create table "public"."audit_logs" (
    "id" uuid not null default gen_random_uuid(),
    "actor_id" uuid,
    "actor_role" text,
    "action" text not null,
    "entity_type" text not null,
    "entity_id" uuid,
    "ip" text,
    "user_agent" text,
    "payload" jsonb not null default '{}'::jsonb,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."audit_logs" enable row level security;


  create table "public"."availability" (
    "id" uuid not null default gen_random_uuid(),
    "caregiver_id" uuid not null,
    "day_of_week" smallint,
    "start_time" time without time zone not null,
    "end_time" time without time zone not null,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
      );



  create table "public"."bookings" (
    "id" uuid not null default gen_random_uuid(),
    "client_id" uuid not null,
    "caregiver_id" uuid,
    "status" public.booking_status not null default 'requested'::public.booking_status,
    "care_type" text not null,
    "notes" text,
    "start_at" timestamp with time zone not null,
    "end_at" timestamp with time zone not null,
    "address_line1" text,
    "city" text,
    "state" text,
    "postal_code" text,
    "lat" double precision,
    "lng" double precision,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "service_id" integer,
    "emergency" boolean not null default false,
    "price_cents" integer,
    "currency" text not null default 'USD'::text
      );


alter table "public"."bookings" enable row level security;


  create table "public"."caregiver_profiles" (
    "id" uuid not null,
    "city" text,
    "state_code" text,
    "lat" double precision,
    "lng" double precision,
    "hourly_rate_cents" integer,
    "currency" text not null default 'USD'::text,
    "years_experience" smallint,
    "bio" text,
    "identity_verified" boolean not null default false,
    "background_check_verified" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
      );


alter table "public"."caregiver_profiles" enable row level security;


  create table "public"."caregiver_skills" (
    "caregiver_id" uuid not null,
    "service_id" integer not null
      );


alter table "public"."caregiver_skills" enable row level security;


  create table "public"."client_profiles" (
    "user_id" uuid not null,
    "needs" jsonb not null default '{}'::jsonb,
    "preferences" jsonb not null default '{}'::jsonb,
    "address_text" text,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
      );



  create table "public"."conversation_members" (
    "conversation_id" uuid not null,
    "user_id" uuid not null,
    "joined_at" timestamp with time zone not null default now()
      );


alter table "public"."conversation_members" enable row level security;


  create table "public"."conversations" (
    "id" uuid not null default gen_random_uuid(),
    "created_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "last_message_at" timestamp with time zone,
    "updated_at" timestamp with time zone
      );


alter table "public"."conversations" enable row level security;


  create table "public"."device_tokens" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "platform" text not null,
    "expo_push_token" text not null,
    "device_id" text,
    "last_seen_at" timestamp with time zone default now(),
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
      );


alter table "public"."device_tokens" enable row level security;


  create table "public"."job_posts" (
    "id" uuid not null default gen_random_uuid(),
    "created_by" uuid not null,
    "org_id" uuid,
    "title" text not null,
    "description" text,
    "status" text not null default 'open'::text,
    "address_text" text,
    "lat" double precision,
    "lng" double precision,
    "budget_min" numeric(10,2),
    "budget_max" numeric(10,2),
    "start_at" timestamp with time zone,
    "end_at" timestamp with time zone,
    "requirements" jsonb not null default '{}'::jsonb,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
      );



  create table "public"."login_audit" (
    "id" bigint not null default nextval('public.login_audit_id_seq'::regclass),
    "user_id" uuid not null,
    "role" public.user_role,
    "ip" text,
    "user_agent" text,
    "device_platform" text,
    "city" text,
    "state_code" text,
    "lat" double precision,
    "lng" double precision,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."login_audit" enable row level security;


  create table "public"."matches" (
    "id" uuid not null default gen_random_uuid(),
    "job_id" uuid not null,
    "client_id" uuid not null,
    "caregiver_id" uuid not null,
    "org_id" uuid,
    "status" text not null default 'active'::text,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
      );



  create table "public"."messages" (
    "id" bigint not null default nextval('public.messages_id_seq'::regclass),
    "booking_id" uuid,
    "sender_id" uuid not null,
    "content" text not null,
    "created_at" timestamp with time zone not null default now(),
    "conversation_id" uuid,
    "sender_user_id" uuid,
    "body" text,
    "type" public.message_type default 'text'::public.message_type,
    "deleted_at" timestamp with time zone
      );


alter table "public"."messages" enable row level security;


  create table "public"."notification_preferences" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "push_enabled" boolean not null default true,
    "email_enabled" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
      );



  create table "public"."notifications" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "type" text not null,
    "title" text not null,
    "body" text,
    "data" jsonb not null default '{}'::jsonb,
    "read_at" timestamp with time zone,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."notifications" enable row level security;


  create table "public"."org_members" (
    "org_id" uuid not null,
    "user_id" uuid not null,
    "role" text not null default 'staff'::text,
    "status" text not null default 'active'::text,
    "invited_email" public.citext,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
      );


alter table "public"."org_members" enable row level security;


  create table "public"."orgs" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null,
    "slug" public.citext,
    "type" text default 'agency'::text,
    "status" text not null default 'active'::text,
    "billing_email" public.citext,
    "created_by" uuid,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
      );


alter table "public"."orgs" enable row level security;


  create table "public"."service_categories" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null,
    "description" text,
    "active" boolean not null default true,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
      );



  create table "public"."services" (
    "id" integer not null default nextval('public.services_id_seq'::regclass),
    "key" text not null,
    "label" text not null,
    "active" boolean not null default true,
    "created_at" timestamp with time zone not null default now()
      );



  create table "public"."shifts" (
    "id" uuid not null default gen_random_uuid(),
    "booking_id" uuid not null,
    "starts_at" timestamp with time zone not null,
    "ends_at" timestamp with time zone not null,
    "status" text not null default 'scheduled'::text,
    "checkin_at" timestamp with time zone,
    "checkout_at" timestamp with time zone,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
      );



  create table "public"."timesheets" (
    "id" uuid not null default gen_random_uuid(),
    "caregiver_id" uuid not null,
    "period_start" date not null,
    "period_end" date not null,
    "status" text not null default 'draft'::text,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
      );



  create table "public"."user_presence" (
    "user_id" uuid not null,
    "role" public.user_role not null default 'client'::public.user_role,
    "state_code" text,
    "city" text,
    "lat" double precision,
    "lng" double precision,
    "device_platform" text,
    "last_seen" timestamp with time zone not null default now(),
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
      );


alter table "public"."user_presence" enable row level security;


  create table "public"."users" (
    "id" bigint generated by default as identity not null,
    "created_at" timestamp with time zone not null default now(),
    "email" text,
    "zip" text,
    "role" text,
    "services" text
      );


alter table "public"."users" enable row level security;


  create table "public"."verification_checks" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "type" text not null,
    "status" text not null default 'pending'::text,
    "reviewed_by" uuid,
    "reviewed_at" timestamp with time zone,
    "notes" text,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
      );


alter table "public"."profiles" alter column role type "public"."user_role" using role::text::"public"."user_role";

alter table "public"."profiles" alter column "role" set default 'client'::public.user_role;

drop type "public"."user_role__old_version_to_be_dropped";

alter table "public"."profiles" add column "email" text;

alter table "public"."profiles" add column "onboarding_complete" boolean not null default false;

alter table "public"."profiles" add column "timezone" text;

alter sequence "public"."login_audit_id_seq" owned by "public"."login_audit"."id";

alter sequence "public"."messages_id_seq" owned by "public"."messages"."id";

alter sequence "public"."services_id_seq" owned by "public"."services"."id";

CREATE UNIQUE INDEX admin_members_pkey ON public.admin_members USING btree (user_id);

CREATE UNIQUE INDEX agencies_pkey ON public.agencies USING btree (id);

CREATE UNIQUE INDEX applications_job_id_caregiver_id_key ON public.applications USING btree (job_id, caregiver_id);

CREATE UNIQUE INDEX applications_pkey ON public.applications USING btree (id);

CREATE UNIQUE INDEX audit_logs_pkey ON public.audit_logs USING btree (id);

CREATE UNIQUE INDEX availability_pkey ON public.availability USING btree (id);

CREATE UNIQUE INDEX bookings_pkey ON public.bookings USING btree (id);

CREATE UNIQUE INDEX caregiver_profiles_pkey ON public.caregiver_profiles USING btree (id);

CREATE UNIQUE INDEX caregiver_skills_pkey ON public.caregiver_skills USING btree (caregiver_id, service_id);

CREATE UNIQUE INDEX client_profiles_pkey ON public.client_profiles USING btree (user_id);

CREATE UNIQUE INDEX conversation_members_pkey ON public.conversation_members USING btree (conversation_id, user_id);

CREATE UNIQUE INDEX conversations_pkey ON public.conversations USING btree (id);

CREATE UNIQUE INDEX device_tokens_pkey ON public.device_tokens USING btree (id);

CREATE UNIQUE INDEX device_tokens_user_id_expo_push_token_key ON public.device_tokens USING btree (user_id, expo_push_token);

CREATE INDEX idx_agencies_owner ON public.agencies USING btree (owner_user_id);

CREATE INDEX idx_audit_user_time ON public.login_audit USING btree (user_id, created_at DESC);

CREATE INDEX idx_bookings_caregiver ON public.bookings USING btree (caregiver_id);

CREATE INDEX idx_bookings_client ON public.bookings USING btree (client_id);

CREATE INDEX idx_bookings_emergency ON public.bookings USING btree (emergency);

CREATE INDEX idx_bookings_service ON public.bookings USING btree (service_id);

CREATE INDEX idx_bookings_status ON public.bookings USING btree (status);

CREATE INDEX idx_caregiver_skills_service ON public.caregiver_skills USING btree (service_id);

CREATE INDEX idx_conv_members_conv ON public.conversation_members USING btree (conversation_id);

CREATE INDEX idx_conv_members_user ON public.conversation_members USING btree (user_id);

CREATE INDEX idx_conversation_members_user ON public.conversation_members USING btree (user_id);

CREATE INDEX idx_conversations_last_message_at ON public.conversations USING btree (last_message_at DESC);

CREATE INDEX idx_messages_booking_id_created_at ON public.messages USING btree (booking_id, created_at);

CREATE INDEX idx_messages_conv_created_at ON public.messages USING btree (conversation_id, created_at DESC);

CREATE INDEX idx_messages_conv_time ON public.messages USING btree (conversation_id, created_at);

CREATE INDEX idx_messages_conversation_created ON public.messages USING btree (conversation_id, created_at DESC);

CREATE INDEX idx_notifications_user_created ON public.notifications USING btree (user_id, created_at DESC);

CREATE INDEX idx_presence_last_seen ON public.user_presence USING btree (last_seen);

CREATE INDEX idx_presence_state ON public.user_presence USING btree (state_code);

CREATE UNIQUE INDEX idx_profiles_email_unique ON public.profiles USING btree (lower(email)) WHERE (email IS NOT NULL);

CREATE INDEX idx_profiles_role ON public.profiles USING btree (role);

CREATE INDEX idx_services_active ON public.services USING btree (active);

CREATE UNIQUE INDEX job_posts_pkey ON public.job_posts USING btree (id);

CREATE UNIQUE INDEX login_audit_pkey ON public.login_audit USING btree (id);

CREATE UNIQUE INDEX matches_job_id_caregiver_id_key ON public.matches USING btree (job_id, caregiver_id);

CREATE UNIQUE INDEX matches_pkey ON public.matches USING btree (id);

CREATE UNIQUE INDEX messages_pkey ON public.messages USING btree (id);

CREATE UNIQUE INDEX notification_preferences_pkey ON public.notification_preferences USING btree (id);

CREATE UNIQUE INDEX notification_preferences_user_id_key ON public.notification_preferences USING btree (user_id);

CREATE UNIQUE INDEX notifications_pkey ON public.notifications USING btree (id);

CREATE UNIQUE INDEX org_members_pkey ON public.org_members USING btree (org_id, user_id);

CREATE UNIQUE INDEX orgs_pkey ON public.orgs USING btree (id);

CREATE UNIQUE INDEX orgs_slug_key ON public.orgs USING btree (slug);

CREATE UNIQUE INDEX service_categories_name_key ON public.service_categories USING btree (name);

CREATE UNIQUE INDEX service_categories_pkey ON public.service_categories USING btree (id);

CREATE UNIQUE INDEX services_key_key ON public.services USING btree (key);

CREATE UNIQUE INDEX services_pkey ON public.services USING btree (id);

CREATE UNIQUE INDEX shifts_pkey ON public.shifts USING btree (id);

CREATE UNIQUE INDEX timesheets_pkey ON public.timesheets USING btree (id);

CREATE UNIQUE INDEX user_presence_pkey ON public.user_presence USING btree (user_id);

CREATE UNIQUE INDEX users_pkey ON public.users USING btree (id);

CREATE UNIQUE INDEX verification_checks_pkey ON public.verification_checks USING btree (id);

alter table "public"."admin_members" add constraint "admin_members_pkey" PRIMARY KEY using index "admin_members_pkey";

alter table "public"."agencies" add constraint "agencies_pkey" PRIMARY KEY using index "agencies_pkey";

alter table "public"."applications" add constraint "applications_pkey" PRIMARY KEY using index "applications_pkey";

alter table "public"."audit_logs" add constraint "audit_logs_pkey" PRIMARY KEY using index "audit_logs_pkey";

alter table "public"."availability" add constraint "availability_pkey" PRIMARY KEY using index "availability_pkey";

alter table "public"."bookings" add constraint "bookings_pkey" PRIMARY KEY using index "bookings_pkey";

alter table "public"."caregiver_profiles" add constraint "caregiver_profiles_pkey" PRIMARY KEY using index "caregiver_profiles_pkey";

alter table "public"."caregiver_skills" add constraint "caregiver_skills_pkey" PRIMARY KEY using index "caregiver_skills_pkey";

alter table "public"."client_profiles" add constraint "client_profiles_pkey" PRIMARY KEY using index "client_profiles_pkey";

alter table "public"."conversation_members" add constraint "conversation_members_pkey" PRIMARY KEY using index "conversation_members_pkey";

alter table "public"."conversations" add constraint "conversations_pkey" PRIMARY KEY using index "conversations_pkey";

alter table "public"."device_tokens" add constraint "device_tokens_pkey" PRIMARY KEY using index "device_tokens_pkey";

alter table "public"."job_posts" add constraint "job_posts_pkey" PRIMARY KEY using index "job_posts_pkey";

alter table "public"."login_audit" add constraint "login_audit_pkey" PRIMARY KEY using index "login_audit_pkey";

alter table "public"."matches" add constraint "matches_pkey" PRIMARY KEY using index "matches_pkey";

alter table "public"."messages" add constraint "messages_pkey" PRIMARY KEY using index "messages_pkey";

alter table "public"."notification_preferences" add constraint "notification_preferences_pkey" PRIMARY KEY using index "notification_preferences_pkey";

alter table "public"."notifications" add constraint "notifications_pkey" PRIMARY KEY using index "notifications_pkey";

alter table "public"."org_members" add constraint "org_members_pkey" PRIMARY KEY using index "org_members_pkey";

alter table "public"."orgs" add constraint "orgs_pkey" PRIMARY KEY using index "orgs_pkey";

alter table "public"."service_categories" add constraint "service_categories_pkey" PRIMARY KEY using index "service_categories_pkey";

alter table "public"."services" add constraint "services_pkey" PRIMARY KEY using index "services_pkey";

alter table "public"."shifts" add constraint "shifts_pkey" PRIMARY KEY using index "shifts_pkey";

alter table "public"."timesheets" add constraint "timesheets_pkey" PRIMARY KEY using index "timesheets_pkey";

alter table "public"."user_presence" add constraint "user_presence_pkey" PRIMARY KEY using index "user_presence_pkey";

alter table "public"."users" add constraint "users_pkey" PRIMARY KEY using index "users_pkey";

alter table "public"."verification_checks" add constraint "verification_checks_pkey" PRIMARY KEY using index "verification_checks_pkey";

alter table "public"."admin_members" add constraint "admin_members_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."admin_members" validate constraint "admin_members_user_id_fkey";

alter table "public"."agencies" add constraint "agencies_owner_user_id_fkey" FOREIGN KEY (owner_user_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."agencies" validate constraint "agencies_owner_user_id_fkey";

alter table "public"."applications" add constraint "applications_caregiver_id_fkey" FOREIGN KEY (caregiver_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."applications" validate constraint "applications_caregiver_id_fkey";

alter table "public"."applications" add constraint "applications_job_id_caregiver_id_key" UNIQUE using index "applications_job_id_caregiver_id_key";

alter table "public"."applications" add constraint "applications_job_id_fkey" FOREIGN KEY (job_id) REFERENCES public.job_posts(id) ON DELETE CASCADE not valid;

alter table "public"."applications" validate constraint "applications_job_id_fkey";

alter table "public"."availability" add constraint "availability_caregiver_id_fkey" FOREIGN KEY (caregiver_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."availability" validate constraint "availability_caregiver_id_fkey";

alter table "public"."availability" add constraint "availability_day_of_week_check" CHECK (((day_of_week >= 0) AND (day_of_week <= 6))) not valid;

alter table "public"."availability" validate constraint "availability_day_of_week_check";

alter table "public"."bookings" add constraint "bookings_caregiver_id_fkey" FOREIGN KEY (caregiver_id) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "public"."bookings" validate constraint "bookings_caregiver_id_fkey";

alter table "public"."bookings" add constraint "bookings_client_id_fkey" FOREIGN KEY (client_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."bookings" validate constraint "bookings_client_id_fkey";

alter table "public"."bookings" add constraint "bookings_service_id_fkey" FOREIGN KEY (service_id) REFERENCES public.services(id) not valid;

alter table "public"."bookings" validate constraint "bookings_service_id_fkey";

alter table "public"."bookings" add constraint "bookings_time_check" CHECK ((end_at > start_at)) not valid;

alter table "public"."bookings" validate constraint "bookings_time_check";

alter table "public"."caregiver_profiles" add constraint "caregiver_profiles_hourly_rate_cents_check" CHECK ((hourly_rate_cents >= 0)) not valid;

alter table "public"."caregiver_profiles" validate constraint "caregiver_profiles_hourly_rate_cents_check";

alter table "public"."caregiver_profiles" add constraint "caregiver_profiles_id_fkey" FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."caregiver_profiles" validate constraint "caregiver_profiles_id_fkey";

alter table "public"."caregiver_profiles" add constraint "caregiver_profiles_years_experience_check" CHECK ((years_experience >= 0)) not valid;

alter table "public"."caregiver_profiles" validate constraint "caregiver_profiles_years_experience_check";

alter table "public"."caregiver_skills" add constraint "caregiver_skills_caregiver_id_fkey" FOREIGN KEY (caregiver_id) REFERENCES public.caregiver_profiles(id) ON DELETE CASCADE not valid;

alter table "public"."caregiver_skills" validate constraint "caregiver_skills_caregiver_id_fkey";

alter table "public"."caregiver_skills" add constraint "caregiver_skills_service_id_fkey" FOREIGN KEY (service_id) REFERENCES public.services(id) ON DELETE CASCADE not valid;

alter table "public"."caregiver_skills" validate constraint "caregiver_skills_service_id_fkey";

alter table "public"."client_profiles" add constraint "client_profiles_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."client_profiles" validate constraint "client_profiles_user_id_fkey";

alter table "public"."conversation_members" add constraint "conversation_members_conversation_id_fkey" FOREIGN KEY (conversation_id) REFERENCES public.conversations(id) ON DELETE CASCADE not valid;

alter table "public"."conversation_members" validate constraint "conversation_members_conversation_id_fkey";

alter table "public"."conversation_members" add constraint "conversation_members_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."conversation_members" validate constraint "conversation_members_user_id_fkey";

alter table "public"."conversations" add constraint "conversations_created_by_fkey" FOREIGN KEY (created_by) REFERENCES public.profiles(id) not valid;

alter table "public"."conversations" validate constraint "conversations_created_by_fkey";

alter table "public"."device_tokens" add constraint "device_tokens_platform_check" CHECK ((platform = ANY (ARRAY['ios'::text, 'android'::text, 'web'::text]))) not valid;

alter table "public"."device_tokens" validate constraint "device_tokens_platform_check";

alter table "public"."device_tokens" add constraint "device_tokens_user_id_expo_push_token_key" UNIQUE using index "device_tokens_user_id_expo_push_token_key";

alter table "public"."device_tokens" add constraint "device_tokens_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."device_tokens" validate constraint "device_tokens_user_id_fkey";

alter table "public"."job_posts" add constraint "job_posts_created_by_fkey" FOREIGN KEY (created_by) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."job_posts" validate constraint "job_posts_created_by_fkey";

alter table "public"."job_posts" add constraint "job_posts_org_id_fkey" FOREIGN KEY (org_id) REFERENCES public.orgs(id) ON DELETE SET NULL not valid;

alter table "public"."job_posts" validate constraint "job_posts_org_id_fkey";

alter table "public"."login_audit" add constraint "login_audit_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."login_audit" validate constraint "login_audit_user_id_fkey";

alter table "public"."matches" add constraint "matches_caregiver_id_fkey" FOREIGN KEY (caregiver_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."matches" validate constraint "matches_caregiver_id_fkey";

alter table "public"."matches" add constraint "matches_client_id_fkey" FOREIGN KEY (client_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."matches" validate constraint "matches_client_id_fkey";

alter table "public"."matches" add constraint "matches_job_id_caregiver_id_key" UNIQUE using index "matches_job_id_caregiver_id_key";

alter table "public"."matches" add constraint "matches_job_id_fkey" FOREIGN KEY (job_id) REFERENCES public.job_posts(id) ON DELETE CASCADE not valid;

alter table "public"."matches" validate constraint "matches_job_id_fkey";

alter table "public"."matches" add constraint "matches_org_id_fkey" FOREIGN KEY (org_id) REFERENCES public.orgs(id) ON DELETE SET NULL not valid;

alter table "public"."matches" validate constraint "matches_org_id_fkey";

alter table "public"."messages" add constraint "messages_booking_id_fkey" FOREIGN KEY (booking_id) REFERENCES public.bookings(id) ON DELETE CASCADE not valid;

alter table "public"."messages" validate constraint "messages_booking_id_fkey";

alter table "public"."messages" add constraint "messages_conversation_id_fkey" FOREIGN KEY (conversation_id) REFERENCES public.conversations(id) ON DELETE CASCADE not valid;

alter table "public"."messages" validate constraint "messages_conversation_id_fkey";

alter table "public"."messages" add constraint "messages_sender_id_fkey" FOREIGN KEY (sender_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."messages" validate constraint "messages_sender_id_fkey";

alter table "public"."messages" add constraint "messages_sender_user_id_fkey" FOREIGN KEY (sender_user_id) REFERENCES public.profiles(id) ON DELETE RESTRICT not valid;

alter table "public"."messages" validate constraint "messages_sender_user_id_fkey";

alter table "public"."notification_preferences" add constraint "notification_preferences_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."notification_preferences" validate constraint "notification_preferences_user_id_fkey";

alter table "public"."notification_preferences" add constraint "notification_preferences_user_id_key" UNIQUE using index "notification_preferences_user_id_key";

alter table "public"."notifications" add constraint "notifications_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."notifications" validate constraint "notifications_user_id_fkey";

alter table "public"."org_members" add constraint "org_members_org_id_fkey" FOREIGN KEY (org_id) REFERENCES public.orgs(id) ON DELETE CASCADE not valid;

alter table "public"."org_members" validate constraint "org_members_org_id_fkey";

alter table "public"."org_members" add constraint "org_members_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."org_members" validate constraint "org_members_user_id_fkey";

alter table "public"."orgs" add constraint "orgs_slug_key" UNIQUE using index "orgs_slug_key";

alter table "public"."orgs" add constraint "orgs_type_check" CHECK ((type = ANY (ARRAY['agency'::text, 'facility'::text]))) not valid;

alter table "public"."orgs" validate constraint "orgs_type_check";

alter table "public"."service_categories" add constraint "service_categories_name_key" UNIQUE using index "service_categories_name_key";

alter table "public"."services" add constraint "services_key_key" UNIQUE using index "services_key_key";

alter table "public"."shifts" add constraint "shifts_booking_id_fkey" FOREIGN KEY (booking_id) REFERENCES public.bookings(id) ON DELETE CASCADE not valid;

alter table "public"."shifts" validate constraint "shifts_booking_id_fkey";

alter table "public"."timesheets" add constraint "timesheets_caregiver_id_fkey" FOREIGN KEY (caregiver_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."timesheets" validate constraint "timesheets_caregiver_id_fkey";

alter table "public"."user_presence" add constraint "user_presence_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."user_presence" validate constraint "user_presence_user_id_fkey";

alter table "public"."verification_checks" add constraint "verification_checks_reviewed_by_fkey" FOREIGN KEY (reviewed_by) REFERENCES public.profiles(id) ON DELETE SET NULL not valid;

alter table "public"."verification_checks" validate constraint "verification_checks_reviewed_by_fkey";

alter table "public"."verification_checks" add constraint "verification_checks_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."verification_checks" validate constraint "verification_checks_user_id_fkey";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION admin.dashboard_counts()
 RETURNS TABLE(profiles bigint, orgs bigint, conversations bigint, messages bigint)
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select
    (select count(*) from public.profiles)::bigint,
    (select count(*) from public.orgs)::bigint,
    (select count(*) from public.conversations)::bigint,
    (select count(*) from public.messages)::bigint
  where public.is_admin();
$function$
;

CREATE OR REPLACE FUNCTION admin.users_list(q text DEFAULT NULL::text)
 RETURNS SETOF public.profiles
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select p.*
  from public.profiles p
  where public.is_admin()
    and (q is null or p.email ilike '%'||q||'%' or coalesce(p.full_name,'') ilike '%'||q||'%')
  order by p.created_at desc
  limit 200;
$function$
;

CREATE OR REPLACE FUNCTION app_private.user_id_by_email(p_email text)
 RETURNS uuid
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public', 'auth'
AS $function$
  select u.id
  from auth.users u
  where lower(u.email) = lower(p_email)
  order by u.created_at desc
  limit 1
$function$
;

CREATE OR REPLACE FUNCTION public.admin_promote(p_email text, p_role text DEFAULT 'super_admin'::text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_user uuid;
begin
  -- find the auth user by email (qualify the column to avoid ambiguity)
  select u.id
    into v_user
  from auth.users u
  where lower(u.email) = lower(p_email)
  order by u.created_at desc
  limit 1;

  if v_user is null then
    raise exception 'No user with email %', p_email;
  end if;

  insert into public.admin_members (user_id, role, status)
  values (v_user, p_role, 'active')
  on conflict (user_id)
  do update set role = excluded.role, status = 'active';
end;
$function$
;

CREATE OR REPLACE FUNCTION public.bump_conversation_last_message()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
  update public.conversations
     set last_message_at = NEW.created_at
   where id = NEW.conversation_id;
  return null;
end
$function$
;

create or replace view "public"."conversation_list_v" as  SELECT id AS conversation_id,
    ( SELECT m.body
           FROM public.messages m
          WHERE ((m.conversation_id = c.id) AND (m.deleted_at IS NULL))
          ORDER BY m.created_at DESC
         LIMIT 1) AS last_message_body,
    ( SELECT m.created_at
           FROM public.messages m
          WHERE (m.conversation_id = c.id)
          ORDER BY m.created_at DESC
         LIMIT 1) AS last_message_at,
    ( SELECT m.sender_user_id
           FROM public.messages m
          WHERE (m.conversation_id = c.id)
          ORDER BY m.created_at DESC
         LIMIT 1) AS last_sender_user_id
   FROM public.conversations c;


CREATE OR REPLACE FUNCTION public.ensure_policy(p_schema text, p_table text, p_name text, p_sql text)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = p_schema and tablename = p_table and policyname = p_name
  ) then
    execute p_sql;
  end if;
end$function$
;

create type "public"."geometry_dump" as ("path" integer[], "geom" public.geometry);

CREATE OR REPLACE FUNCTION public.get_user_id_by_email(p_email text)
 RETURNS uuid
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public', 'auth'
AS $function$
  select u.id
  from auth.users u
  where lower(u.email) = lower(p_email)
  order by u.created_at desc
  limit 1
$function$
;

CREATE OR REPLACE FUNCTION public.has_admin_role(wanted text)
 RETURNS boolean
 LANGUAGE sql
 STABLE
AS $function$
  select exists(
    select 1 from public.admin_members m
    where m.user_id = auth.uid()
      and m.status = 'active'
      and (m.role = 'super_admin' or m.role = wanted)
  );
$function$
;

CREATE OR REPLACE FUNCTION public.has_any_org_role(p_uid uuid, p_org_id uuid, p_roles text[])
 RETURNS boolean
 LANGUAGE sql
 STABLE
 SET search_path TO 'public'
AS $function$
  select exists (
    select 1
    from public.org_members om
    where om.user_id = coalesce(p_uid, auth.uid())
      and om.org_id  = p_org_id
      and om.status  = 'active'
      and (om.role = any(p_roles) or om.role in ('owner','admin'))
  );
$function$
;

CREATE OR REPLACE FUNCTION public.has_org_role(p_uid uuid, p_org uuid, p_role text)
 RETURNS boolean
 LANGUAGE sql
 STABLE
AS $function$
  select exists (
    select 1
    from public.org_members om
    where om.user_id = coalesce(p_uid, auth.uid())
      and om.org_id = p_org
      and om.status = 'active'
      and om.role in (
        case lower(p_role)
          when 'owner' then 'owner'
          when 'admin' then 'admin'
          when 'staff' then 'staff'
          else 'viewer'
        end, 'owner','admin'
      )
  );
$function$
;

CREATE OR REPLACE FUNCTION public.is_admin()
 RETURNS boolean
 LANGUAGE sql
 STABLE
AS $function$
  select public.is_admin(auth.uid());
$function$
;

CREATE OR REPLACE FUNCTION public.is_admin(uid uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE
AS $function$
      select exists (
        select 1
        from public.admin_members am
        where am.user_id = uid
          and coalesce(am.status, 'active') = 'active'
      );
    $function$
;

CREATE OR REPLACE FUNCTION public.is_org_admin(p_org uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE
AS $function$
  select exists (
    select 1 from public.org_members om
    where om.org_id = p_org and om.user_id = auth.uid()
      and om.role in ('owner','admin') and om.status='active'
  ) or public.is_admin();
$function$
;

CREATE OR REPLACE FUNCTION public.is_org_member(p_org_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE
AS $function$
begin
  return exists (
    select 1
    from public.org_members om
    where om.org_id = p_org_id
      and om.user_id = auth.uid()
      and om.status = 'active'
  );
end
$function$
;

CREATE OR REPLACE FUNCTION public.messages_normalize()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
  if NEW.content is null and NEW.body is not null then
    NEW.content := NEW.body;
  end if;
  if NEW.type is null then
    NEW.type := 'text';
  end if;
  return NEW;
end $function$
;

CREATE OR REPLACE FUNCTION public.my_org_ids()
 RETURNS SETOF uuid
 LANGUAGE sql
 STABLE
 SET search_path TO 'public'
AS $function$
  select org_id
  from public.org_members
  where user_id = auth.uid()
    and status  = 'active';
$function$
;

CREATE OR REPLACE FUNCTION public.notify_on_message()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  insert into public.notifications (user_id, type, title, body, data)
  select cm.user_id,
         'new_message',
         'New message',
         left(coalesce(new.content, new.body)::text, 120),
         jsonb_build_object('conversation_id', new.conversation_id, 'message_id', new.id)
  from public.conversation_members cm
  where cm.conversation_id = new.conversation_id
    and cm.user_id <> new.sender_id;
  return new;
end$function$
;

CREATE OR REPLACE FUNCTION public.set_my_avatar(_path text)
 RETURNS void
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
begin
  -- must live under your own user folder: "<uid>/..."
  if _path is null
     or position((auth.uid())::text || '/' in _path) <> 1 then
    raise exception 'avatar path must live under your own folder (%s/)', auth.uid();
  end if;

  update public.profiles
     set avatar_url = _path,
         updated_at = now()
   where id = auth.uid();
end
$function$
;

CREATE OR REPLACE FUNCTION public.tg_set_timestamp()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin new.updated_at = now(); return new; end $function$
;

CREATE OR REPLACE FUNCTION public.uid()
 RETURNS uuid
 LANGUAGE sql
 STABLE
AS $function$ select auth.uid() $function$
;

create type "public"."valid_detail" as ("valid" boolean, "reason" character varying, "location" public.geometry);

grant delete on table "public"."admin_members" to "anon";

grant insert on table "public"."admin_members" to "anon";

grant references on table "public"."admin_members" to "anon";

grant select on table "public"."admin_members" to "anon";

grant trigger on table "public"."admin_members" to "anon";

grant truncate on table "public"."admin_members" to "anon";

grant update on table "public"."admin_members" to "anon";

grant delete on table "public"."admin_members" to "authenticated";

grant insert on table "public"."admin_members" to "authenticated";

grant references on table "public"."admin_members" to "authenticated";

grant select on table "public"."admin_members" to "authenticated";

grant trigger on table "public"."admin_members" to "authenticated";

grant truncate on table "public"."admin_members" to "authenticated";

grant update on table "public"."admin_members" to "authenticated";

grant delete on table "public"."admin_members" to "service_role";

grant insert on table "public"."admin_members" to "service_role";

grant references on table "public"."admin_members" to "service_role";

grant select on table "public"."admin_members" to "service_role";

grant trigger on table "public"."admin_members" to "service_role";

grant truncate on table "public"."admin_members" to "service_role";

grant update on table "public"."admin_members" to "service_role";

grant delete on table "public"."agencies" to "anon";

grant insert on table "public"."agencies" to "anon";

grant references on table "public"."agencies" to "anon";

grant select on table "public"."agencies" to "anon";

grant trigger on table "public"."agencies" to "anon";

grant truncate on table "public"."agencies" to "anon";

grant update on table "public"."agencies" to "anon";

grant delete on table "public"."agencies" to "authenticated";

grant insert on table "public"."agencies" to "authenticated";

grant references on table "public"."agencies" to "authenticated";

grant select on table "public"."agencies" to "authenticated";

grant trigger on table "public"."agencies" to "authenticated";

grant truncate on table "public"."agencies" to "authenticated";

grant update on table "public"."agencies" to "authenticated";

grant delete on table "public"."agencies" to "service_role";

grant insert on table "public"."agencies" to "service_role";

grant references on table "public"."agencies" to "service_role";

grant select on table "public"."agencies" to "service_role";

grant trigger on table "public"."agencies" to "service_role";

grant truncate on table "public"."agencies" to "service_role";

grant update on table "public"."agencies" to "service_role";

grant delete on table "public"."applications" to "anon";

grant insert on table "public"."applications" to "anon";

grant references on table "public"."applications" to "anon";

grant select on table "public"."applications" to "anon";

grant trigger on table "public"."applications" to "anon";

grant truncate on table "public"."applications" to "anon";

grant update on table "public"."applications" to "anon";

grant delete on table "public"."applications" to "authenticated";

grant insert on table "public"."applications" to "authenticated";

grant references on table "public"."applications" to "authenticated";

grant select on table "public"."applications" to "authenticated";

grant trigger on table "public"."applications" to "authenticated";

grant truncate on table "public"."applications" to "authenticated";

grant update on table "public"."applications" to "authenticated";

grant delete on table "public"."applications" to "service_role";

grant insert on table "public"."applications" to "service_role";

grant references on table "public"."applications" to "service_role";

grant select on table "public"."applications" to "service_role";

grant trigger on table "public"."applications" to "service_role";

grant truncate on table "public"."applications" to "service_role";

grant update on table "public"."applications" to "service_role";

grant delete on table "public"."audit_logs" to "anon";

grant insert on table "public"."audit_logs" to "anon";

grant references on table "public"."audit_logs" to "anon";

grant select on table "public"."audit_logs" to "anon";

grant trigger on table "public"."audit_logs" to "anon";

grant truncate on table "public"."audit_logs" to "anon";

grant update on table "public"."audit_logs" to "anon";

grant delete on table "public"."audit_logs" to "authenticated";

grant insert on table "public"."audit_logs" to "authenticated";

grant references on table "public"."audit_logs" to "authenticated";

grant select on table "public"."audit_logs" to "authenticated";

grant trigger on table "public"."audit_logs" to "authenticated";

grant truncate on table "public"."audit_logs" to "authenticated";

grant update on table "public"."audit_logs" to "authenticated";

grant delete on table "public"."audit_logs" to "service_role";

grant insert on table "public"."audit_logs" to "service_role";

grant references on table "public"."audit_logs" to "service_role";

grant select on table "public"."audit_logs" to "service_role";

grant trigger on table "public"."audit_logs" to "service_role";

grant truncate on table "public"."audit_logs" to "service_role";

grant update on table "public"."audit_logs" to "service_role";

grant delete on table "public"."availability" to "anon";

grant insert on table "public"."availability" to "anon";

grant references on table "public"."availability" to "anon";

grant select on table "public"."availability" to "anon";

grant trigger on table "public"."availability" to "anon";

grant truncate on table "public"."availability" to "anon";

grant update on table "public"."availability" to "anon";

grant delete on table "public"."availability" to "authenticated";

grant insert on table "public"."availability" to "authenticated";

grant references on table "public"."availability" to "authenticated";

grant select on table "public"."availability" to "authenticated";

grant trigger on table "public"."availability" to "authenticated";

grant truncate on table "public"."availability" to "authenticated";

grant update on table "public"."availability" to "authenticated";

grant delete on table "public"."availability" to "service_role";

grant insert on table "public"."availability" to "service_role";

grant references on table "public"."availability" to "service_role";

grant select on table "public"."availability" to "service_role";

grant trigger on table "public"."availability" to "service_role";

grant truncate on table "public"."availability" to "service_role";

grant update on table "public"."availability" to "service_role";

grant delete on table "public"."bookings" to "anon";

grant insert on table "public"."bookings" to "anon";

grant references on table "public"."bookings" to "anon";

grant select on table "public"."bookings" to "anon";

grant trigger on table "public"."bookings" to "anon";

grant truncate on table "public"."bookings" to "anon";

grant update on table "public"."bookings" to "anon";

grant delete on table "public"."bookings" to "authenticated";

grant insert on table "public"."bookings" to "authenticated";

grant references on table "public"."bookings" to "authenticated";

grant select on table "public"."bookings" to "authenticated";

grant trigger on table "public"."bookings" to "authenticated";

grant truncate on table "public"."bookings" to "authenticated";

grant update on table "public"."bookings" to "authenticated";

grant delete on table "public"."bookings" to "service_role";

grant insert on table "public"."bookings" to "service_role";

grant references on table "public"."bookings" to "service_role";

grant select on table "public"."bookings" to "service_role";

grant trigger on table "public"."bookings" to "service_role";

grant truncate on table "public"."bookings" to "service_role";

grant update on table "public"."bookings" to "service_role";

grant delete on table "public"."caregiver_profiles" to "anon";

grant insert on table "public"."caregiver_profiles" to "anon";

grant references on table "public"."caregiver_profiles" to "anon";

grant select on table "public"."caregiver_profiles" to "anon";

grant trigger on table "public"."caregiver_profiles" to "anon";

grant truncate on table "public"."caregiver_profiles" to "anon";

grant update on table "public"."caregiver_profiles" to "anon";

grant delete on table "public"."caregiver_profiles" to "authenticated";

grant insert on table "public"."caregiver_profiles" to "authenticated";

grant references on table "public"."caregiver_profiles" to "authenticated";

grant select on table "public"."caregiver_profiles" to "authenticated";

grant trigger on table "public"."caregiver_profiles" to "authenticated";

grant truncate on table "public"."caregiver_profiles" to "authenticated";

grant update on table "public"."caregiver_profiles" to "authenticated";

grant delete on table "public"."caregiver_profiles" to "service_role";

grant insert on table "public"."caregiver_profiles" to "service_role";

grant references on table "public"."caregiver_profiles" to "service_role";

grant select on table "public"."caregiver_profiles" to "service_role";

grant trigger on table "public"."caregiver_profiles" to "service_role";

grant truncate on table "public"."caregiver_profiles" to "service_role";

grant update on table "public"."caregiver_profiles" to "service_role";

grant delete on table "public"."caregiver_skills" to "anon";

grant insert on table "public"."caregiver_skills" to "anon";

grant references on table "public"."caregiver_skills" to "anon";

grant select on table "public"."caregiver_skills" to "anon";

grant trigger on table "public"."caregiver_skills" to "anon";

grant truncate on table "public"."caregiver_skills" to "anon";

grant update on table "public"."caregiver_skills" to "anon";

grant delete on table "public"."caregiver_skills" to "authenticated";

grant insert on table "public"."caregiver_skills" to "authenticated";

grant references on table "public"."caregiver_skills" to "authenticated";

grant select on table "public"."caregiver_skills" to "authenticated";

grant trigger on table "public"."caregiver_skills" to "authenticated";

grant truncate on table "public"."caregiver_skills" to "authenticated";

grant update on table "public"."caregiver_skills" to "authenticated";

grant delete on table "public"."caregiver_skills" to "service_role";

grant insert on table "public"."caregiver_skills" to "service_role";

grant references on table "public"."caregiver_skills" to "service_role";

grant select on table "public"."caregiver_skills" to "service_role";

grant trigger on table "public"."caregiver_skills" to "service_role";

grant truncate on table "public"."caregiver_skills" to "service_role";

grant update on table "public"."caregiver_skills" to "service_role";

grant delete on table "public"."client_profiles" to "anon";

grant insert on table "public"."client_profiles" to "anon";

grant references on table "public"."client_profiles" to "anon";

grant select on table "public"."client_profiles" to "anon";

grant trigger on table "public"."client_profiles" to "anon";

grant truncate on table "public"."client_profiles" to "anon";

grant update on table "public"."client_profiles" to "anon";

grant delete on table "public"."client_profiles" to "authenticated";

grant insert on table "public"."client_profiles" to "authenticated";

grant references on table "public"."client_profiles" to "authenticated";

grant select on table "public"."client_profiles" to "authenticated";

grant trigger on table "public"."client_profiles" to "authenticated";

grant truncate on table "public"."client_profiles" to "authenticated";

grant update on table "public"."client_profiles" to "authenticated";

grant delete on table "public"."client_profiles" to "service_role";

grant insert on table "public"."client_profiles" to "service_role";

grant references on table "public"."client_profiles" to "service_role";

grant select on table "public"."client_profiles" to "service_role";

grant trigger on table "public"."client_profiles" to "service_role";

grant truncate on table "public"."client_profiles" to "service_role";

grant update on table "public"."client_profiles" to "service_role";

grant delete on table "public"."conversation_members" to "anon";

grant insert on table "public"."conversation_members" to "anon";

grant references on table "public"."conversation_members" to "anon";

grant select on table "public"."conversation_members" to "anon";

grant trigger on table "public"."conversation_members" to "anon";

grant truncate on table "public"."conversation_members" to "anon";

grant update on table "public"."conversation_members" to "anon";

grant delete on table "public"."conversation_members" to "authenticated";

grant insert on table "public"."conversation_members" to "authenticated";

grant references on table "public"."conversation_members" to "authenticated";

grant select on table "public"."conversation_members" to "authenticated";

grant trigger on table "public"."conversation_members" to "authenticated";

grant truncate on table "public"."conversation_members" to "authenticated";

grant update on table "public"."conversation_members" to "authenticated";

grant delete on table "public"."conversation_members" to "service_role";

grant insert on table "public"."conversation_members" to "service_role";

grant references on table "public"."conversation_members" to "service_role";

grant select on table "public"."conversation_members" to "service_role";

grant trigger on table "public"."conversation_members" to "service_role";

grant truncate on table "public"."conversation_members" to "service_role";

grant update on table "public"."conversation_members" to "service_role";

grant delete on table "public"."conversations" to "anon";

grant insert on table "public"."conversations" to "anon";

grant references on table "public"."conversations" to "anon";

grant select on table "public"."conversations" to "anon";

grant trigger on table "public"."conversations" to "anon";

grant truncate on table "public"."conversations" to "anon";

grant update on table "public"."conversations" to "anon";

grant delete on table "public"."conversations" to "authenticated";

grant insert on table "public"."conversations" to "authenticated";

grant references on table "public"."conversations" to "authenticated";

grant select on table "public"."conversations" to "authenticated";

grant trigger on table "public"."conversations" to "authenticated";

grant truncate on table "public"."conversations" to "authenticated";

grant update on table "public"."conversations" to "authenticated";

grant delete on table "public"."conversations" to "service_role";

grant insert on table "public"."conversations" to "service_role";

grant references on table "public"."conversations" to "service_role";

grant select on table "public"."conversations" to "service_role";

grant trigger on table "public"."conversations" to "service_role";

grant truncate on table "public"."conversations" to "service_role";

grant update on table "public"."conversations" to "service_role";

grant delete on table "public"."device_tokens" to "anon";

grant insert on table "public"."device_tokens" to "anon";

grant references on table "public"."device_tokens" to "anon";

grant select on table "public"."device_tokens" to "anon";

grant trigger on table "public"."device_tokens" to "anon";

grant truncate on table "public"."device_tokens" to "anon";

grant update on table "public"."device_tokens" to "anon";

grant delete on table "public"."device_tokens" to "authenticated";

grant insert on table "public"."device_tokens" to "authenticated";

grant references on table "public"."device_tokens" to "authenticated";

grant select on table "public"."device_tokens" to "authenticated";

grant trigger on table "public"."device_tokens" to "authenticated";

grant truncate on table "public"."device_tokens" to "authenticated";

grant update on table "public"."device_tokens" to "authenticated";

grant delete on table "public"."device_tokens" to "service_role";

grant insert on table "public"."device_tokens" to "service_role";

grant references on table "public"."device_tokens" to "service_role";

grant select on table "public"."device_tokens" to "service_role";

grant trigger on table "public"."device_tokens" to "service_role";

grant truncate on table "public"."device_tokens" to "service_role";

grant update on table "public"."device_tokens" to "service_role";

grant delete on table "public"."job_posts" to "anon";

grant insert on table "public"."job_posts" to "anon";

grant references on table "public"."job_posts" to "anon";

grant select on table "public"."job_posts" to "anon";

grant trigger on table "public"."job_posts" to "anon";

grant truncate on table "public"."job_posts" to "anon";

grant update on table "public"."job_posts" to "anon";

grant delete on table "public"."job_posts" to "authenticated";

grant insert on table "public"."job_posts" to "authenticated";

grant references on table "public"."job_posts" to "authenticated";

grant select on table "public"."job_posts" to "authenticated";

grant trigger on table "public"."job_posts" to "authenticated";

grant truncate on table "public"."job_posts" to "authenticated";

grant update on table "public"."job_posts" to "authenticated";

grant delete on table "public"."job_posts" to "service_role";

grant insert on table "public"."job_posts" to "service_role";

grant references on table "public"."job_posts" to "service_role";

grant select on table "public"."job_posts" to "service_role";

grant trigger on table "public"."job_posts" to "service_role";

grant truncate on table "public"."job_posts" to "service_role";

grant update on table "public"."job_posts" to "service_role";

grant delete on table "public"."login_audit" to "anon";

grant insert on table "public"."login_audit" to "anon";

grant references on table "public"."login_audit" to "anon";

grant select on table "public"."login_audit" to "anon";

grant trigger on table "public"."login_audit" to "anon";

grant truncate on table "public"."login_audit" to "anon";

grant update on table "public"."login_audit" to "anon";

grant delete on table "public"."login_audit" to "authenticated";

grant insert on table "public"."login_audit" to "authenticated";

grant references on table "public"."login_audit" to "authenticated";

grant select on table "public"."login_audit" to "authenticated";

grant trigger on table "public"."login_audit" to "authenticated";

grant truncate on table "public"."login_audit" to "authenticated";

grant update on table "public"."login_audit" to "authenticated";

grant delete on table "public"."login_audit" to "service_role";

grant insert on table "public"."login_audit" to "service_role";

grant references on table "public"."login_audit" to "service_role";

grant select on table "public"."login_audit" to "service_role";

grant trigger on table "public"."login_audit" to "service_role";

grant truncate on table "public"."login_audit" to "service_role";

grant update on table "public"."login_audit" to "service_role";

grant delete on table "public"."matches" to "anon";

grant insert on table "public"."matches" to "anon";

grant references on table "public"."matches" to "anon";

grant select on table "public"."matches" to "anon";

grant trigger on table "public"."matches" to "anon";

grant truncate on table "public"."matches" to "anon";

grant update on table "public"."matches" to "anon";

grant delete on table "public"."matches" to "authenticated";

grant insert on table "public"."matches" to "authenticated";

grant references on table "public"."matches" to "authenticated";

grant select on table "public"."matches" to "authenticated";

grant trigger on table "public"."matches" to "authenticated";

grant truncate on table "public"."matches" to "authenticated";

grant update on table "public"."matches" to "authenticated";

grant delete on table "public"."matches" to "service_role";

grant insert on table "public"."matches" to "service_role";

grant references on table "public"."matches" to "service_role";

grant select on table "public"."matches" to "service_role";

grant trigger on table "public"."matches" to "service_role";

grant truncate on table "public"."matches" to "service_role";

grant update on table "public"."matches" to "service_role";

grant delete on table "public"."messages" to "anon";

grant insert on table "public"."messages" to "anon";

grant references on table "public"."messages" to "anon";

grant select on table "public"."messages" to "anon";

grant trigger on table "public"."messages" to "anon";

grant truncate on table "public"."messages" to "anon";

grant update on table "public"."messages" to "anon";

grant delete on table "public"."messages" to "authenticated";

grant insert on table "public"."messages" to "authenticated";

grant references on table "public"."messages" to "authenticated";

grant select on table "public"."messages" to "authenticated";

grant trigger on table "public"."messages" to "authenticated";

grant truncate on table "public"."messages" to "authenticated";

grant update on table "public"."messages" to "authenticated";

grant delete on table "public"."messages" to "service_role";

grant insert on table "public"."messages" to "service_role";

grant references on table "public"."messages" to "service_role";

grant select on table "public"."messages" to "service_role";

grant trigger on table "public"."messages" to "service_role";

grant truncate on table "public"."messages" to "service_role";

grant update on table "public"."messages" to "service_role";

grant delete on table "public"."notification_preferences" to "anon";

grant insert on table "public"."notification_preferences" to "anon";

grant references on table "public"."notification_preferences" to "anon";

grant select on table "public"."notification_preferences" to "anon";

grant trigger on table "public"."notification_preferences" to "anon";

grant truncate on table "public"."notification_preferences" to "anon";

grant update on table "public"."notification_preferences" to "anon";

grant delete on table "public"."notification_preferences" to "authenticated";

grant insert on table "public"."notification_preferences" to "authenticated";

grant references on table "public"."notification_preferences" to "authenticated";

grant select on table "public"."notification_preferences" to "authenticated";

grant trigger on table "public"."notification_preferences" to "authenticated";

grant truncate on table "public"."notification_preferences" to "authenticated";

grant update on table "public"."notification_preferences" to "authenticated";

grant delete on table "public"."notification_preferences" to "service_role";

grant insert on table "public"."notification_preferences" to "service_role";

grant references on table "public"."notification_preferences" to "service_role";

grant select on table "public"."notification_preferences" to "service_role";

grant trigger on table "public"."notification_preferences" to "service_role";

grant truncate on table "public"."notification_preferences" to "service_role";

grant update on table "public"."notification_preferences" to "service_role";

grant delete on table "public"."notifications" to "anon";

grant insert on table "public"."notifications" to "anon";

grant references on table "public"."notifications" to "anon";

grant select on table "public"."notifications" to "anon";

grant trigger on table "public"."notifications" to "anon";

grant truncate on table "public"."notifications" to "anon";

grant update on table "public"."notifications" to "anon";

grant delete on table "public"."notifications" to "authenticated";

grant insert on table "public"."notifications" to "authenticated";

grant references on table "public"."notifications" to "authenticated";

grant select on table "public"."notifications" to "authenticated";

grant trigger on table "public"."notifications" to "authenticated";

grant truncate on table "public"."notifications" to "authenticated";

grant update on table "public"."notifications" to "authenticated";

grant delete on table "public"."notifications" to "service_role";

grant insert on table "public"."notifications" to "service_role";

grant references on table "public"."notifications" to "service_role";

grant select on table "public"."notifications" to "service_role";

grant trigger on table "public"."notifications" to "service_role";

grant truncate on table "public"."notifications" to "service_role";

grant update on table "public"."notifications" to "service_role";

grant delete on table "public"."org_members" to "anon";

grant insert on table "public"."org_members" to "anon";

grant references on table "public"."org_members" to "anon";

grant select on table "public"."org_members" to "anon";

grant trigger on table "public"."org_members" to "anon";

grant truncate on table "public"."org_members" to "anon";

grant update on table "public"."org_members" to "anon";

grant delete on table "public"."org_members" to "authenticated";

grant insert on table "public"."org_members" to "authenticated";

grant references on table "public"."org_members" to "authenticated";

grant select on table "public"."org_members" to "authenticated";

grant trigger on table "public"."org_members" to "authenticated";

grant truncate on table "public"."org_members" to "authenticated";

grant update on table "public"."org_members" to "authenticated";

grant delete on table "public"."org_members" to "service_role";

grant insert on table "public"."org_members" to "service_role";

grant references on table "public"."org_members" to "service_role";

grant select on table "public"."org_members" to "service_role";

grant trigger on table "public"."org_members" to "service_role";

grant truncate on table "public"."org_members" to "service_role";

grant update on table "public"."org_members" to "service_role";

grant delete on table "public"."orgs" to "anon";

grant insert on table "public"."orgs" to "anon";

grant references on table "public"."orgs" to "anon";

grant select on table "public"."orgs" to "anon";

grant trigger on table "public"."orgs" to "anon";

grant truncate on table "public"."orgs" to "anon";

grant update on table "public"."orgs" to "anon";

grant delete on table "public"."orgs" to "authenticated";

grant insert on table "public"."orgs" to "authenticated";

grant references on table "public"."orgs" to "authenticated";

grant select on table "public"."orgs" to "authenticated";

grant trigger on table "public"."orgs" to "authenticated";

grant truncate on table "public"."orgs" to "authenticated";

grant update on table "public"."orgs" to "authenticated";

grant delete on table "public"."orgs" to "service_role";

grant insert on table "public"."orgs" to "service_role";

grant references on table "public"."orgs" to "service_role";

grant select on table "public"."orgs" to "service_role";

grant trigger on table "public"."orgs" to "service_role";

grant truncate on table "public"."orgs" to "service_role";

grant update on table "public"."orgs" to "service_role";

grant delete on table "public"."service_categories" to "anon";

grant insert on table "public"."service_categories" to "anon";

grant references on table "public"."service_categories" to "anon";

grant select on table "public"."service_categories" to "anon";

grant trigger on table "public"."service_categories" to "anon";

grant truncate on table "public"."service_categories" to "anon";

grant update on table "public"."service_categories" to "anon";

grant delete on table "public"."service_categories" to "authenticated";

grant insert on table "public"."service_categories" to "authenticated";

grant references on table "public"."service_categories" to "authenticated";

grant select on table "public"."service_categories" to "authenticated";

grant trigger on table "public"."service_categories" to "authenticated";

grant truncate on table "public"."service_categories" to "authenticated";

grant update on table "public"."service_categories" to "authenticated";

grant delete on table "public"."service_categories" to "service_role";

grant insert on table "public"."service_categories" to "service_role";

grant references on table "public"."service_categories" to "service_role";

grant select on table "public"."service_categories" to "service_role";

grant trigger on table "public"."service_categories" to "service_role";

grant truncate on table "public"."service_categories" to "service_role";

grant update on table "public"."service_categories" to "service_role";

grant delete on table "public"."services" to "anon";

grant insert on table "public"."services" to "anon";

grant references on table "public"."services" to "anon";

grant select on table "public"."services" to "anon";

grant trigger on table "public"."services" to "anon";

grant truncate on table "public"."services" to "anon";

grant update on table "public"."services" to "anon";

grant delete on table "public"."services" to "authenticated";

grant insert on table "public"."services" to "authenticated";

grant references on table "public"."services" to "authenticated";

grant select on table "public"."services" to "authenticated";

grant trigger on table "public"."services" to "authenticated";

grant truncate on table "public"."services" to "authenticated";

grant update on table "public"."services" to "authenticated";

grant delete on table "public"."services" to "service_role";

grant insert on table "public"."services" to "service_role";

grant references on table "public"."services" to "service_role";

grant select on table "public"."services" to "service_role";

grant trigger on table "public"."services" to "service_role";

grant truncate on table "public"."services" to "service_role";

grant update on table "public"."services" to "service_role";

grant delete on table "public"."shifts" to "anon";

grant insert on table "public"."shifts" to "anon";

grant references on table "public"."shifts" to "anon";

grant select on table "public"."shifts" to "anon";

grant trigger on table "public"."shifts" to "anon";

grant truncate on table "public"."shifts" to "anon";

grant update on table "public"."shifts" to "anon";

grant delete on table "public"."shifts" to "authenticated";

grant insert on table "public"."shifts" to "authenticated";

grant references on table "public"."shifts" to "authenticated";

grant select on table "public"."shifts" to "authenticated";

grant trigger on table "public"."shifts" to "authenticated";

grant truncate on table "public"."shifts" to "authenticated";

grant update on table "public"."shifts" to "authenticated";

grant delete on table "public"."shifts" to "service_role";

grant insert on table "public"."shifts" to "service_role";

grant references on table "public"."shifts" to "service_role";

grant select on table "public"."shifts" to "service_role";

grant trigger on table "public"."shifts" to "service_role";

grant truncate on table "public"."shifts" to "service_role";

grant update on table "public"."shifts" to "service_role";

grant delete on table "public"."spatial_ref_sys" to "anon";

grant insert on table "public"."spatial_ref_sys" to "anon";

grant references on table "public"."spatial_ref_sys" to "anon";

grant select on table "public"."spatial_ref_sys" to "anon";

grant trigger on table "public"."spatial_ref_sys" to "anon";

grant truncate on table "public"."spatial_ref_sys" to "anon";

grant update on table "public"."spatial_ref_sys" to "anon";

grant delete on table "public"."spatial_ref_sys" to "authenticated";

grant insert on table "public"."spatial_ref_sys" to "authenticated";

grant references on table "public"."spatial_ref_sys" to "authenticated";

grant select on table "public"."spatial_ref_sys" to "authenticated";

grant trigger on table "public"."spatial_ref_sys" to "authenticated";

grant truncate on table "public"."spatial_ref_sys" to "authenticated";

grant update on table "public"."spatial_ref_sys" to "authenticated";

grant delete on table "public"."spatial_ref_sys" to "postgres";

grant insert on table "public"."spatial_ref_sys" to "postgres";

grant references on table "public"."spatial_ref_sys" to "postgres";

grant select on table "public"."spatial_ref_sys" to "postgres";

grant trigger on table "public"."spatial_ref_sys" to "postgres";

grant truncate on table "public"."spatial_ref_sys" to "postgres";

grant update on table "public"."spatial_ref_sys" to "postgres";

grant delete on table "public"."spatial_ref_sys" to "service_role";

grant insert on table "public"."spatial_ref_sys" to "service_role";

grant references on table "public"."spatial_ref_sys" to "service_role";

grant select on table "public"."spatial_ref_sys" to "service_role";

grant trigger on table "public"."spatial_ref_sys" to "service_role";

grant truncate on table "public"."spatial_ref_sys" to "service_role";

grant update on table "public"."spatial_ref_sys" to "service_role";

grant delete on table "public"."timesheets" to "anon";

grant insert on table "public"."timesheets" to "anon";

grant references on table "public"."timesheets" to "anon";

grant select on table "public"."timesheets" to "anon";

grant trigger on table "public"."timesheets" to "anon";

grant truncate on table "public"."timesheets" to "anon";

grant update on table "public"."timesheets" to "anon";

grant delete on table "public"."timesheets" to "authenticated";

grant insert on table "public"."timesheets" to "authenticated";

grant references on table "public"."timesheets" to "authenticated";

grant select on table "public"."timesheets" to "authenticated";

grant trigger on table "public"."timesheets" to "authenticated";

grant truncate on table "public"."timesheets" to "authenticated";

grant update on table "public"."timesheets" to "authenticated";

grant delete on table "public"."timesheets" to "service_role";

grant insert on table "public"."timesheets" to "service_role";

grant references on table "public"."timesheets" to "service_role";

grant select on table "public"."timesheets" to "service_role";

grant trigger on table "public"."timesheets" to "service_role";

grant truncate on table "public"."timesheets" to "service_role";

grant update on table "public"."timesheets" to "service_role";

grant delete on table "public"."user_presence" to "anon";

grant insert on table "public"."user_presence" to "anon";

grant references on table "public"."user_presence" to "anon";

grant select on table "public"."user_presence" to "anon";

grant trigger on table "public"."user_presence" to "anon";

grant truncate on table "public"."user_presence" to "anon";

grant update on table "public"."user_presence" to "anon";

grant delete on table "public"."user_presence" to "authenticated";

grant insert on table "public"."user_presence" to "authenticated";

grant references on table "public"."user_presence" to "authenticated";

grant select on table "public"."user_presence" to "authenticated";

grant trigger on table "public"."user_presence" to "authenticated";

grant truncate on table "public"."user_presence" to "authenticated";

grant update on table "public"."user_presence" to "authenticated";

grant delete on table "public"."user_presence" to "service_role";

grant insert on table "public"."user_presence" to "service_role";

grant references on table "public"."user_presence" to "service_role";

grant select on table "public"."user_presence" to "service_role";

grant trigger on table "public"."user_presence" to "service_role";

grant truncate on table "public"."user_presence" to "service_role";

grant update on table "public"."user_presence" to "service_role";

grant delete on table "public"."users" to "anon";

grant insert on table "public"."users" to "anon";

grant references on table "public"."users" to "anon";

grant select on table "public"."users" to "anon";

grant trigger on table "public"."users" to "anon";

grant truncate on table "public"."users" to "anon";

grant update on table "public"."users" to "anon";

grant delete on table "public"."users" to "authenticated";

grant insert on table "public"."users" to "authenticated";

grant references on table "public"."users" to "authenticated";

grant select on table "public"."users" to "authenticated";

grant trigger on table "public"."users" to "authenticated";

grant truncate on table "public"."users" to "authenticated";

grant update on table "public"."users" to "authenticated";

grant delete on table "public"."users" to "service_role";

grant insert on table "public"."users" to "service_role";

grant references on table "public"."users" to "service_role";

grant select on table "public"."users" to "service_role";

grant trigger on table "public"."users" to "service_role";

grant truncate on table "public"."users" to "service_role";

grant update on table "public"."users" to "service_role";

grant delete on table "public"."verification_checks" to "anon";

grant insert on table "public"."verification_checks" to "anon";

grant references on table "public"."verification_checks" to "anon";

grant select on table "public"."verification_checks" to "anon";

grant trigger on table "public"."verification_checks" to "anon";

grant truncate on table "public"."verification_checks" to "anon";

grant update on table "public"."verification_checks" to "anon";

grant delete on table "public"."verification_checks" to "authenticated";

grant insert on table "public"."verification_checks" to "authenticated";

grant references on table "public"."verification_checks" to "authenticated";

grant select on table "public"."verification_checks" to "authenticated";

grant trigger on table "public"."verification_checks" to "authenticated";

grant truncate on table "public"."verification_checks" to "authenticated";

grant update on table "public"."verification_checks" to "authenticated";

grant delete on table "public"."verification_checks" to "service_role";

grant insert on table "public"."verification_checks" to "service_role";

grant references on table "public"."verification_checks" to "service_role";

grant select on table "public"."verification_checks" to "service_role";

grant trigger on table "public"."verification_checks" to "service_role";

grant truncate on table "public"."verification_checks" to "service_role";

grant update on table "public"."verification_checks" to "service_role";


  create policy "admin_members_admin_all"
  on "public"."admin_members"
  as permissive
  for all
  to public
using (public.has_admin_role('super_admin'::text))
with check (public.has_admin_role('super_admin'::text));



  create policy "admin_members_self"
  on "public"."admin_members"
  as permissive
  for select
  to public
using (((user_id = auth.uid()) OR public.is_admin()));



  create policy "admin_members_self_read"
  on "public"."admin_members"
  as permissive
  for select
  to public
using (((auth.uid() = user_id) OR public.has_admin_role('super_admin'::text)));



  create policy "agencies_admin_all"
  on "public"."agencies"
  as permissive
  for all
  to authenticated
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));



  create policy "agencies_owner_rw"
  on "public"."agencies"
  as permissive
  for all
  to authenticated
using (((owner_user_id = auth.uid()) OR public.is_admin(auth.uid())))
with check (((owner_user_id = auth.uid()) OR public.is_admin(auth.uid())));



  create policy "audit_admin_insert"
  on "public"."audit_logs"
  as permissive
  for insert
  to authenticated
with check (public.is_admin());



  create policy "audit_admin_read"
  on "public"."audit_logs"
  as permissive
  for select
  to authenticated
using (public.is_admin());



  create policy "bookings_caregiver_read_assigned"
  on "public"."bookings"
  as permissive
  for select
  to public
using (((caregiver_id = auth.uid()) OR public.is_admin(auth.uid())));



  create policy "bookings_caregiver_update_status"
  on "public"."bookings"
  as permissive
  for update
  to public
using (((caregiver_id = auth.uid()) OR public.is_admin(auth.uid())))
with check (((caregiver_id = auth.uid()) OR public.is_admin(auth.uid())));



  create policy "bookings_client_crud_own"
  on "public"."bookings"
  as permissive
  for all
  to public
using (((client_id = auth.uid()) OR public.is_admin(auth.uid())))
with check (((client_id = auth.uid()) OR public.is_admin(auth.uid())));



  create policy "cg_admin_all"
  on "public"."caregiver_profiles"
  as permissive
  for all
  to public
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));



  create policy "cg_public_read"
  on "public"."caregiver_profiles"
  as permissive
  for select
  to public
using (true);



  create policy "cg_self_rw"
  on "public"."caregiver_profiles"
  as permissive
  for all
  to public
using ((auth.uid() = id))
with check ((auth.uid() = id));



  create policy "cg_skills_admin_all"
  on "public"."caregiver_skills"
  as permissive
  for all
  to public
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));



  create policy "cg_skills_public_read"
  on "public"."caregiver_skills"
  as permissive
  for select
  to public
using (true);



  create policy "cg_skills_self_rw"
  on "public"."caregiver_skills"
  as permissive
  for all
  to public
using ((auth.uid() = caregiver_id))
with check ((auth.uid() = caregiver_id));



  create policy "conversation_members_creator_insert"
  on "public"."conversation_members"
  as permissive
  for insert
  to public
with check (((user_id = auth.uid()) OR public.is_admin()));



  create policy "conversation_members_insert_self"
  on "public"."conversation_members"
  as permissive
  for insert
  to authenticated
with check ((user_id = auth.uid()));



  create policy "conversation_members_member_select"
  on "public"."conversation_members"
  as permissive
  for select
  to public
using (((user_id = auth.uid()) OR public.is_admin()));



  create policy "conversation_members_read_members"
  on "public"."conversation_members"
  as permissive
  for select
  to authenticated
using (((user_id = auth.uid()) OR (EXISTS ( SELECT 1
   FROM public.conversation_members me
  WHERE ((me.conversation_id = conversation_members.conversation_id) AND (me.user_id = auth.uid()))))));



  create policy "conversation_members_self"
  on "public"."conversation_members"
  as permissive
  for all
  to authenticated
using ((user_id = auth.uid()))
with check ((user_id = auth.uid()));



  create policy "conversations_admin_read"
  on "public"."conversations"
  as permissive
  for select
  to public
using ((public.has_admin_role('support'::text) OR public.has_admin_role('ceo'::text)));



  create policy "conversations_creator_insert"
  on "public"."conversations"
  as permissive
  for insert
  to public
with check ((created_by = auth.uid()));



  create policy "conversations_members_read"
  on "public"."conversations"
  as permissive
  for select
  to public
using ((EXISTS ( SELECT 1
   FROM public.conversation_members cm
  WHERE ((cm.conversation_id = conversations.id) AND (cm.user_id = auth.uid())))));



  create policy "conversations_members_select"
  on "public"."conversations"
  as permissive
  for select
  to public
using (((EXISTS ( SELECT 1
   FROM public.conversation_members cm
  WHERE ((cm.conversation_id = conversations.id) AND (cm.user_id = auth.uid())))) OR public.is_admin()));



  create policy "conversations_read_members"
  on "public"."conversations"
  as permissive
  for select
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.conversation_members cm
  WHERE ((cm.conversation_id = conversations.id) AND (cm.user_id = auth.uid())))));



  create policy "devt_insert_own"
  on "public"."device_tokens"
  as permissive
  for insert
  to authenticated
with check ((user_id = auth.uid()));



  create policy "devt_read_own"
  on "public"."device_tokens"
  as permissive
  for select
  to authenticated
using ((user_id = auth.uid()));



  create policy "devt_update_own"
  on "public"."device_tokens"
  as permissive
  for update
  to authenticated
using ((user_id = auth.uid()))
with check ((user_id = auth.uid()));



  create policy "audit_admin_read_all"
  on "public"."login_audit"
  as permissive
  for select
  to public
using (public.is_admin(auth.uid()));



  create policy "audit_self_insert"
  on "public"."login_audit"
  as permissive
  for insert
  to public
with check ((auth.uid() = user_id));



  create policy "messages_admin_read"
  on "public"."messages"
  as permissive
  for select
  to public
using ((public.has_admin_role('support'::text) OR public.has_admin_role('ceo'::text)));



  create policy "messages_insert_member_sender"
  on "public"."messages"
  as permissive
  for insert
  to authenticated
with check (((sender_user_id = auth.uid()) AND (EXISTS ( SELECT 1
   FROM public.conversation_members cm
  WHERE ((cm.conversation_id = messages.conversation_id) AND (cm.user_id = auth.uid()))))));



  create policy "messages_member_insert"
  on "public"."messages"
  as permissive
  for insert
  to public
with check ((((sender_id = auth.uid()) AND (EXISTS ( SELECT 1
   FROM public.conversation_members cm
  WHERE ((cm.conversation_id = cm.conversation_id) AND (cm.user_id = auth.uid()))))) OR public.is_admin()));



  create policy "messages_member_select"
  on "public"."messages"
  as permissive
  for select
  to public
using (((EXISTS ( SELECT 1
   FROM public.conversation_members cm
  WHERE ((cm.conversation_id = cm.conversation_id) AND (cm.user_id = auth.uid())))) OR public.is_admin()));



  create policy "messages_participants_rw"
  on "public"."messages"
  as permissive
  for all
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.conversation_members cm
  WHERE ((cm.conversation_id = messages.conversation_id) AND (cm.user_id = auth.uid())))))
with check ((EXISTS ( SELECT 1
   FROM public.conversation_members cm
  WHERE ((cm.conversation_id = messages.conversation_id) AND (cm.user_id = auth.uid())))));



  create policy "messages_read_members"
  on "public"."messages"
  as permissive
  for select
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.conversation_members cm
  WHERE ((cm.conversation_id = messages.conversation_id) AND (cm.user_id = auth.uid())))));



  create policy "messages_read_participants"
  on "public"."messages"
  as permissive
  for select
  to public
using ((public.is_admin(auth.uid()) OR (EXISTS ( SELECT 1
   FROM public.bookings b
  WHERE ((b.id = messages.booking_id) AND ((b.client_id = auth.uid()) OR (b.caregiver_id = auth.uid())))))));



  create policy "messages_write_participants"
  on "public"."messages"
  as permissive
  for insert
  to public
with check ((public.is_admin(auth.uid()) OR (EXISTS ( SELECT 1
   FROM public.bookings b
  WHERE ((b.id = messages.booking_id) AND ((b.client_id = auth.uid()) OR (b.caregiver_id = auth.uid())))))));



  create policy "notif_insert_own"
  on "public"."notifications"
  as permissive
  for insert
  to authenticated
with check ((user_id = auth.uid()));



  create policy "notif_read_own"
  on "public"."notifications"
  as permissive
  for select
  to authenticated
using ((user_id = auth.uid()));



  create policy "org_members_read_all_tmp"
  on "public"."org_members"
  as permissive
  for select
  to public
using (true);



  create policy "org_members_self_read"
  on "public"."org_members"
  as permissive
  for select
  to public
using (((user_id = auth.uid()) OR public.is_admin()));



  create policy "orgs_member_read"
  on "public"."orgs"
  as permissive
  for select
  to public
using ((EXISTS ( SELECT 1
   FROM public.org_members om
  WHERE ((om.org_id = orgs.id) AND (om.user_id = auth.uid()) AND (om.status = 'active'::text)))));



  create policy "orgs_read_all_tmp"
  on "public"."orgs"
  as permissive
  for select
  to public
using (true);



  create policy "profiles_admin_read"
  on "public"."profiles"
  as permissive
  for select
  to public
using ((public.has_admin_role('support'::text) OR public.has_admin_role('ceo'::text)));



  create policy "profiles_admin_read_all"
  on "public"."profiles"
  as permissive
  for select
  to public
using (public.is_admin(auth.uid()));



  create policy "profiles_insert_self"
  on "public"."profiles"
  as permissive
  for insert
  to public
with check ((auth.uid() = id));



  create policy "profiles_read_self"
  on "public"."profiles"
  as permissive
  for select
  to public
using (((auth.uid() = id) OR public.is_admin()));



  create policy "profiles_select_own"
  on "public"."profiles"
  as permissive
  for select
  to public
using ((auth.uid() = id));



  create policy "profiles_self_rw"
  on "public"."profiles"
  as permissive
  for all
  to authenticated
using ((id = auth.uid()))
with check ((id = auth.uid()));



  create policy "profiles_update_own"
  on "public"."profiles"
  as permissive
  for update
  to public
using ((auth.uid() = id))
with check ((auth.uid() = id));



  create policy "profiles_update_self"
  on "public"."profiles"
  as permissive
  for update
  to public
using ((auth.uid() = id))
with check ((auth.uid() = id));



  create policy "presence_admin_read_all"
  on "public"."user_presence"
  as permissive
  for select
  to public
using (public.is_admin(auth.uid()));



  create policy "presence_self_upsert"
  on "public"."user_presence"
  as permissive
  for all
  to public
using ((auth.uid() = user_id))
with check ((auth.uid() = user_id));


CREATE TRIGGER trg_bookings_updated_at BEFORE UPDATE ON public.bookings FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_caregiver_profiles_updated_at BEFORE UPDATE ON public.caregiver_profiles FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER t_conversations_updated BEFORE UPDATE ON public.conversations FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER tr_conversations_updated_at BEFORE UPDATE ON public.conversations FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER tr_device_tokens_updated BEFORE UPDATE ON public.device_tokens FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER t_messages_after_insert AFTER INSERT ON public.messages FOR EACH ROW EXECUTE FUNCTION public.bump_conversation_last_message();

CREATE TRIGGER tr_messages_bump_conv AFTER INSERT ON public.messages FOR EACH ROW EXECUTE FUNCTION public.bump_conversation_last_message();

CREATE TRIGGER tr_messages_notify AFTER INSERT ON public.messages FOR EACH ROW EXECUTE FUNCTION public.notify_on_message();

CREATE TRIGGER trg_messages_normalize BEFORE INSERT OR UPDATE ON public.messages FOR EACH ROW EXECUTE FUNCTION public.messages_normalize();

CREATE TRIGGER t_org_members_updated BEFORE UPDATE ON public.org_members FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER t_orgs_updated BEFORE UPDATE ON public.orgs FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.tg_set_timestamp();

CREATE TRIGGER t_profiles_updated BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_presence_updated_at BEFORE UPDATE ON public.user_presence FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


  create policy "avatars_owner_read"
  on "storage"."objects"
  as permissive
  for select
  to authenticated
using (((bucket_id = 'avatars'::text) AND (split_part(name, '/'::text, 1) = (auth.uid())::text)));



  create policy "avatars_owner_rw"
  on "storage"."objects"
  as permissive
  for all
  to authenticated
using (((bucket_id = 'avatars'::text) AND (owner = auth.uid())))
with check (((bucket_id = 'avatars'::text) AND (owner = auth.uid())));



  create policy "avatars_owner_write"
  on "storage"."objects"
  as permissive
  for insert
  to authenticated
with check (((bucket_id = 'avatars'::text) AND (split_part(name, '/'::text, 1) = (auth.uid())::text)));



  create policy "avatars_read_all"
  on "storage"."objects"
  as permissive
  for select
  to authenticated
using ((bucket_id = 'avatars'::text));



  create policy "chat_media_member_read"
  on "storage"."objects"
  as permissive
  for select
  to authenticated
using ((bucket_id = 'chat_media'::text));



  create policy "chat_media_member_write"
  on "storage"."objects"
  as permissive
  for insert
  to authenticated
with check ((bucket_id = 'chat_media'::text));



  create policy "chat_media_owner_read"
  on "storage"."objects"
  as permissive
  for select
  to authenticated
using (((bucket_id = 'chat_media'::text) AND (owner = auth.uid())));



  create policy "chat_media_owner_update"
  on "storage"."objects"
  as permissive
  for update
  to authenticated
using (((bucket_id = 'chat_media'::text) AND (owner = auth.uid())))
with check (((bucket_id = 'chat_media'::text) AND (owner = auth.uid())));



  create policy "chat_media_owner_write"
  on "storage"."objects"
  as permissive
  for insert
  to authenticated
with check (((bucket_id = 'chat_media'::text) AND (owner = auth.uid())));



  create policy "docs_admin_r"
  on "storage"."objects"
  as permissive
  for select
  to authenticated
using (((bucket_id = ANY (ARRAY['documents'::text, 'message_attachments'::text])) AND public.is_admin(auth.uid())));



  create policy "docs_owner_rw"
  on "storage"."objects"
  as permissive
  for all
  to authenticated
using (((bucket_id = ANY (ARRAY['documents'::text, 'message_attachments'::text])) AND (owner = auth.uid())))
with check (((bucket_id = ANY (ARRAY['documents'::text, 'message_attachments'::text])) AND (owner = auth.uid())));



  create policy "vdocs_admin_read"
  on "storage"."objects"
  as permissive
  for select
  to authenticated
using (((bucket_id = 'verification_docs'::text) AND public.is_admin()));



  create policy "vdocs_owner_write"
  on "storage"."objects"
  as permissive
  for insert
  to authenticated
with check (((bucket_id = 'verification_docs'::text) AND (owner = auth.uid())));



