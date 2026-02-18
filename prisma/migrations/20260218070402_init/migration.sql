-- CreateEnum
CREATE TYPE "userRole" AS ENUM ('USER', 'ADMIN', 'MODERATOR', 'SUPERADMIN');

-- CreateEnum
CREATE TYPE "userStatus" AS ENUM ('ACTIVE', 'INACTIVE', 'SUSPENDED', 'DELETED', 'BLOCKED');

-- CreateEnum
CREATE TYPE "mfaMethod" AS ENUM ('totp', 'sms', 'email', 'webauthn');

-- CreateEnum
CREATE TYPE "loginAction" AS ENUM ('login', 'logout');

-- CreateEnum
CREATE TYPE "email_type" AS ENUM ('verification', 'password_reset', 'notification');

-- CreateEnum
CREATE TYPE "email_provider" AS ENUM ('sendgrid', 'mailgun', 'ses', 'stmp');

-- CreateEnum
CREATE TYPE "email_status" AS ENUM ('sent', 'failed', 'pending', 'bounced', 'delivered', 'opened', 'clicked');

-- CreateEnum
CREATE TYPE "eventType" AS ENUM ('create', 'update', 'delete', 'login', 'logout', 'password_change', 'profile_update');

-- CreateEnum
CREATE TYPE "actionType" AS ENUM ('create', 'update', 'delete');

-- CreateEnum
CREATE TYPE "subscriptionStatus" AS ENUM ('ACTIVE', 'PAST_DUE', 'CANCELED', 'TRIALING', 'INCOMPLETE', 'INCOMPLETE_EXPIRED', 'UNPAID');

-- CreateEnum
CREATE TYPE "billingInterval" AS ENUM ('DAY', 'WEEK', 'MONTH', 'YEAR');

-- CreateEnum
CREATE TYPE "paymentStatus" AS ENUM ('PENDING', 'PROCESSING', 'SUCCEEDED', 'FAILED', 'CANCELED', 'REFUNDED');

-- CreateEnum
CREATE TYPE "invoiceStatus" AS ENUM ('DRAFT', 'OPEN', 'PAID', 'VOID', 'UNCOLLECTIBLE');

-- CreateEnum
CREATE TYPE "JobStatus" AS ENUM ('APPLIED', 'SCREENING', 'INTERVIEW', 'OFFER', 'REJECTED', 'ACCEPTED', 'DECLINED', 'WITHDRAWN');

-- CreateEnum
CREATE TYPE "ResponseStatus" AS ENUM ('NO_RESPONSE', 'RESPONSE_RECEIVED', 'AWAITING_RESPONSE');

-- CreateEnum
CREATE TYPE "JobLocationType" AS ENUM ('REMOTE', 'HYBRID', 'ONSITE');

-- CreateEnum
CREATE TYPE "AppliedVia" AS ENUM ('LINKEDIN', 'INDEED', 'COMPANY_WEBSITE', 'REFERRAL', 'RECRUITER', 'JOB_BOARD', 'CAREER_FAIR', 'OTHER');

-- CreateEnum
CREATE TYPE "InterviewType" AS ENUM ('PHONE_SCREEN', 'TECHNICAL', 'BEHAVIORAL', 'SYSTEM_DESIGN', 'ONSITE', 'PANEL', 'FINAL', 'OTHER');

-- CreateEnum
CREATE TYPE "JobPriority" AS ENUM ('LOW', 'MEDIUM', 'HIGH', 'URGENT');

-- CreateEnum
CREATE TYPE "FollowUpStatus" AS ENUM ('PENDING', 'COMPLETED', 'SKIPPED');

-- CreateEnum
CREATE TYPE "FollowUpType" AS ENUM ('EMAIL', 'PHONE', 'LINKEDIN', 'OTHER');

-- CreateEnum
CREATE TYPE "JobTimelineEventType" AS ENUM ('APPLIED', 'RESPONSE_RECEIVED', 'INTERVIEW_SCHEDULED', 'INTERVIEW_COMPLETED', 'OFFER_RECEIVED', 'OFFER_ACCEPTED', 'OFFER_DECLINED', 'REJECTED', 'WITHDRAWN', 'FOLLOW_UP_SENT', 'NOTE_ADDED', 'STATUS_CHANGED', 'DOCUMENT_ADDED', 'CUSTOM');

-- CreateEnum
CREATE TYPE "JobDocumentType" AS ENUM ('RESUME', 'COVER_LETTER', 'PORTFOLIO', 'OFFER_LETTER', 'CONTRACT', 'OTHER');

-- CreateEnum
CREATE TYPE "JobSourceType" AS ENUM ('MANUAL', 'AI_URL_PARSED', 'AI_DESCRIPTION_PARSED', 'IMPORTED', 'EXTENSION');

-- CreateEnum
CREATE TYPE "JobReminderType" AS ENUM ('FOLLOW_UP_DUE', 'INTERVIEW_REMINDER', 'OFFER_DEADLINE', 'APPLICATION_DEADLINE', 'CUSTOM');

-- CreateEnum
CREATE TYPE "ReminderStatus" AS ENUM ('PENDING', 'SENT', 'FAILED', 'CANCELLED');

-- CreateTable
CREATE TABLE "ActivityLogEvent" (
    "id" TEXT NOT NULL,
    "tableName" TEXT NOT NULL,
    "recordId" TEXT NOT NULL,
    "action" "actionType" NOT NULL,
    "actionedBy" TEXT,
    "ipAddress" TEXT,
    "userAgent" TEXT,
    "device" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "eventType" "eventType",

    CONSTRAINT "ActivityLogEvent_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ActivityLogEventDetail" (
    "id" TEXT NOT NULL,
    "eventId" TEXT NOT NULL,
    "fieldName" TEXT NOT NULL,
    "oldValue" TEXT,
    "newValue" TEXT,

    CONSTRAINT "ActivityLogEventDetail_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "authUser" (
    "id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "password" TEXT NOT NULL,
    "username" TEXT NOT NULL,
    "role" "userRole" NOT NULL DEFAULT 'USER',
    "verified" BOOLEAN NOT NULL DEFAULT false,
    "status" "userStatus" NOT NULL DEFAULT 'ACTIVE',
    "tokenVersion" INTEGER NOT NULL DEFAULT 1,
    "deletedAt" TIMESTAMP(3),
    "provider" TEXT NOT NULL DEFAULT 'local',
    "providerId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "authUser_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "authSecurity" (
    "id" TEXT NOT NULL,
    "authId" TEXT NOT NULL,
    "failedAttempts" INTEGER NOT NULL DEFAULT 0,
    "lastFailedAt" TIMESTAMP(3),
    "lockExpiresAt" TIMESTAMP(3),
    "mfaEnabled" BOOLEAN NOT NULL DEFAULT false,
    "mfaMethod" "mfaMethod",
    "mfaSecret" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "lastPasswordChange" TIMESTAMP(3),

    CONSTRAINT "authSecurity_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "ActivityLogEvent_tableName_recordId_createdAt_idx" ON "ActivityLogEvent"("tableName", "recordId", "createdAt");

-- CreateIndex
CREATE INDEX "ActivityLogEvent_actionedBy_createdAt_idx" ON "ActivityLogEvent"("actionedBy", "createdAt");

-- CreateIndex
CREATE INDEX "ActivityLogEventDetail_eventId_idx" ON "ActivityLogEventDetail"("eventId");

-- CreateIndex
CREATE UNIQUE INDEX "authUser_email_key" ON "authUser"("email");

-- CreateIndex
CREATE UNIQUE INDEX "authUser_username_key" ON "authUser"("username");

-- CreateIndex
CREATE INDEX "authUser_email_id_providerId_idx" ON "authUser"("email", "id", "providerId");

-- CreateIndex
CREATE INDEX "authUser_username_idx" ON "authUser"("username");

-- CreateIndex
CREATE UNIQUE INDEX "authSecurity_authId_key" ON "authSecurity"("authId");

-- CreateIndex
CREATE INDEX "authSecurity_authId_idx" ON "authSecurity"("authId");

-- AddForeignKey
ALTER TABLE "ActivityLogEvent" ADD CONSTRAINT "ActivityLogEvent_actionedBy_fkey" FOREIGN KEY ("actionedBy") REFERENCES "authUser"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ActivityLogEventDetail" ADD CONSTRAINT "ActivityLogEventDetail_eventId_fkey" FOREIGN KEY ("eventId") REFERENCES "ActivityLogEvent"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "authSecurity" ADD CONSTRAINT "authSecurity_authId_fkey" FOREIGN KEY ("authId") REFERENCES "authUser"("id") ON DELETE CASCADE ON UPDATE CASCADE;
