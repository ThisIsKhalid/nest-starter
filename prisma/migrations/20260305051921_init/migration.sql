/*
  Warnings:

  - The values [USER,MODERATOR] on the enum `userRole` will be removed. If these variants are still used in the database, this will fail.
  - You are about to drop the `Post` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `User` table. If the table is not empty, all the data it contains will be lost.

*/
-- AlterEnum
BEGIN;
CREATE TYPE "userRole_new" AS ENUM ('SEEKER', 'RECRUITER', 'ADMIN', 'SUPERADMIN');
ALTER TABLE "public"."authUser" ALTER COLUMN "role" DROP DEFAULT;
ALTER TABLE "authUser" ALTER COLUMN "role" TYPE "userRole_new" USING ("role"::text::"userRole_new");
ALTER TYPE "userRole" RENAME TO "userRole_old";
ALTER TYPE "userRole_new" RENAME TO "userRole";
DROP TYPE "public"."userRole_old";
ALTER TABLE "authUser" ALTER COLUMN "role" SET DEFAULT 'SEEKER';
COMMIT;

-- DropForeignKey
ALTER TABLE "Post" DROP CONSTRAINT "Post_authorId_fkey";

-- DropIndex
DROP INDEX "authUser_username_idx";

-- AlterTable
ALTER TABLE "authUser" ALTER COLUMN "role" SET DEFAULT 'SEEKER';

-- DropTable
DROP TABLE "Post";

-- DropTable
DROP TABLE "User";

-- CreateTable
CREATE TABLE "loginHistory" (
    "id" TEXT NOT NULL,
    "authId" TEXT NOT NULL,
    "ipAddress" TEXT NOT NULL,
    "userAgent" TEXT NOT NULL,
    "device_id" TEXT,
    "geo_country" TEXT,
    "geo_city" TEXT,
    "action" "loginAction" NOT NULL,
    "success" BOOLEAN NOT NULL,
    "failureReason" TEXT,
    "attemptNumber" INTEGER NOT NULL DEFAULT 1,
    "isSuspicious" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "loginHistory_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "emailHistory" (
    "id" TEXT NOT NULL,
    "authId" TEXT NOT NULL,
    "emailTo" TEXT NOT NULL,
    "emailType" "email_type" NOT NULL,
    "subject" TEXT NOT NULL,
    "emailProvider" "email_provider",
    "messageId" TEXT NOT NULL,
    "emailStatus" "email_status" NOT NULL,
    "retry_count" INTEGER NOT NULL DEFAULT 0,
    "ipAddress" TEXT,
    "userAgent" TEXT,
    "sentAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "errorMessage" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "emailHistory_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "userProfile" (
    "id" TEXT NOT NULL,
    "authId" TEXT NOT NULL,
    "firstName" TEXT,
    "lastName" TEXT,
    "bio" TEXT,
    "avatarUrl" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "userProfile_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "loginHistory_authId_createdAt_idx" ON "loginHistory"("authId", "createdAt");

-- CreateIndex
CREATE INDEX "emailHistory_authId_idx" ON "emailHistory"("authId");

-- CreateIndex
CREATE INDEX "emailHistory_emailTo_idx" ON "emailHistory"("emailTo");

-- CreateIndex
CREATE INDEX "emailHistory_sentAt_idx" ON "emailHistory"("sentAt");

-- CreateIndex
CREATE INDEX "emailHistory_messageId_idx" ON "emailHistory"("messageId");

-- CreateIndex
CREATE UNIQUE INDEX "userProfile_authId_key" ON "userProfile"("authId");

-- CreateIndex
CREATE INDEX "userProfile_authId_idx" ON "userProfile"("authId");

-- AddForeignKey
ALTER TABLE "loginHistory" ADD CONSTRAINT "loginHistory_authId_fkey" FOREIGN KEY ("authId") REFERENCES "authUser"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "emailHistory" ADD CONSTRAINT "emailHistory_authId_fkey" FOREIGN KEY ("authId") REFERENCES "authUser"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "userProfile" ADD CONSTRAINT "userProfile_authId_fkey" FOREIGN KEY ("authId") REFERENCES "authUser"("id") ON DELETE CASCADE ON UPDATE CASCADE;
