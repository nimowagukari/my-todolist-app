-- CreateEnum
CREATE TYPE "Status" AS ENUM ('not started yet', 'in progress', 'closed');

-- CreateTable
CREATE TABLE "Task" (
    "id" SERIAL NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "summary" VARCHAR(255) NOT NULL,
    "description" VARCHAR(1000),
    "status" "Status" NOT NULL DEFAULT 'not started yet',

    CONSTRAINT "Task_pkey" PRIMARY KEY ("id")
);
