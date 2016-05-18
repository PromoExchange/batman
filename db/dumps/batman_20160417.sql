/*
 Navicat Premium Data Transfer

 Source Server         : localhost
 Source Server Type    : PostgreSQL
 Source Server Version : 90305
 Source Host           : localhost
 Source Database       : poppy_development
 Source Schema         : public

 Target Server Type    : PostgreSQL
 Target Server Version : 90305
 File Encoding         : utf-8

 Date: 04/17/2016 11:12:32 AM
*/

-- ----------------------------
--  Sequence structure for authentications_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."authentications_id_seq";
CREATE SEQUENCE "public"."authentications_id_seq" INCREMENT 1 START 1 MAXVALUE 9223372036854775807 MINVALUE 1 CACHE 1;
ALTER TABLE "public"."authentications_id_seq" OWNER TO "poppy";

-- ----------------------------
--  Sequence structure for comments_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."comments_id_seq";
CREATE SEQUENCE "public"."comments_id_seq" INCREMENT 1 START 1 MAXVALUE 9223372036854775807 MINVALUE 1 CACHE 1;
ALTER TABLE "public"."comments_id_seq" OWNER TO "poppy";

-- ----------------------------
--  Sequence structure for reaction_types_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."reaction_types_id_seq";
CREATE SEQUENCE "public"."reaction_types_id_seq" INCREMENT 1 START 5 MAXVALUE 9223372036854775807 MINVALUE 1 CACHE 1;
ALTER TABLE "public"."reaction_types_id_seq" OWNER TO "poppy";

-- ----------------------------
--  Sequence structure for reactions_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."reactions_id_seq";
CREATE SEQUENCE "public"."reactions_id_seq" INCREMENT 1 START 1 MAXVALUE 9223372036854775807 MINVALUE 1 CACHE 1;
ALTER TABLE "public"."reactions_id_seq" OWNER TO "poppy";

-- ----------------------------
--  Sequence structure for users_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."users_id_seq";
CREATE SEQUENCE "public"."users_id_seq" INCREMENT 1 START 1 MAXVALUE 9223372036854775807 MINVALUE 1 CACHE 1;
ALTER TABLE "public"."users_id_seq" OWNER TO "poppy";

-- ----------------------------
--  Sequence structure for whispers_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."whispers_id_seq";
CREATE SEQUENCE "public"."whispers_id_seq" INCREMENT 1 START 1 MAXVALUE 9223372036854775807 MINVALUE 1 CACHE 1;
ALTER TABLE "public"."whispers_id_seq" OWNER TO "poppy";

-- ----------------------------
--  Table structure for schema_migrations
-- ----------------------------
DROP TABLE IF EXISTS "public"."schema_migrations";
CREATE TABLE "public"."schema_migrations" (
	"version" varchar NOT NULL COLLATE "default"
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."schema_migrations" OWNER TO "poppy";

-- ----------------------------
--  Records of schema_migrations
-- ----------------------------
BEGIN;
INSERT INTO "public"."schema_migrations" VALUES ('20160325174747');
INSERT INTO "public"."schema_migrations" VALUES ('20160328130332');
INSERT INTO "public"."schema_migrations" VALUES ('20160328130503');
INSERT INTO "public"."schema_migrations" VALUES ('20160328131306');
INSERT INTO "public"."schema_migrations" VALUES ('20160328133125');
INSERT INTO "public"."schema_migrations" VALUES ('20160328173511');
INSERT INTO "public"."schema_migrations" VALUES ('20160328174149');
INSERT INTO "public"."schema_migrations" VALUES ('20160328174150');
INSERT INTO "public"."schema_migrations" VALUES ('20160328174152');
INSERT INTO "public"."schema_migrations" VALUES ('20160328180738');
INSERT INTO "public"."schema_migrations" VALUES ('20160329193632');
INSERT INTO "public"."schema_migrations" VALUES ('20160329194623');
INSERT INTO "public"."schema_migrations" VALUES ('20160329200012');
INSERT INTO "public"."schema_migrations" VALUES ('20160329200154');
INSERT INTO "public"."schema_migrations" VALUES ('20160330154717');
INSERT INTO "public"."schema_migrations" VALUES ('20160401172601');
INSERT INTO "public"."schema_migrations" VALUES ('20160401174239');
INSERT INTO "public"."schema_migrations" VALUES ('20160401181614');
COMMIT;

-- ----------------------------
--  Table structure for reaction_types
-- ----------------------------
DROP TABLE IF EXISTS "public"."reaction_types";
CREATE TABLE "public"."reaction_types" (
	"id" int4 NOT NULL DEFAULT nextval('reaction_types_id_seq'::regclass),
	"created_at" timestamp(6) NOT NULL,
	"updated_at" timestamp(6) NOT NULL,
	"slug" varchar NOT NULL COLLATE "default"
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."reaction_types" OWNER TO "poppy";

-- ----------------------------
--  Records of reaction_types
-- ----------------------------
BEGIN;
INSERT INTO "public"."reaction_types" VALUES ('1', '2016-04-06 14:17:37.107956', '2016-04-06 14:17:37.107956', 'love');
INSERT INTO "public"."reaction_types" VALUES ('2', '2016-04-06 14:17:37.118437', '2016-04-06 14:17:37.118437', 'like');
INSERT INTO "public"."reaction_types" VALUES ('3', '2016-04-06 14:17:37.12345', '2016-04-06 14:17:37.12345', 'meeh');
INSERT INTO "public"."reaction_types" VALUES ('4', '2016-04-06 14:17:37.127165', '2016-04-06 14:17:37.127165', 'dislike');
INSERT INTO "public"."reaction_types" VALUES ('5', '2016-04-06 14:17:37.131107', '2016-04-06 14:17:37.131107', 'hate');
COMMIT;

-- ----------------------------
--  Table structure for comments
-- ----------------------------
DROP TABLE IF EXISTS "public"."comments";
CREATE TABLE "public"."comments" (
	"id" int4 NOT NULL DEFAULT nextval('comments_id_seq'::regclass),
	"user_id" int4 NOT NULL,
	"created_at" timestamp(6) NOT NULL,
	"updated_at" timestamp(6) NOT NULL
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."comments" OWNER TO "poppy";

-- ----------------------------
--  Table structure for authentications
-- ----------------------------
DROP TABLE IF EXISTS "public"."authentications";
CREATE TABLE "public"."authentications" (
	"id" int4 NOT NULL DEFAULT nextval('authentications_id_seq'::regclass),
	"user_id" int4 NOT NULL,
	"provider" varchar NOT NULL COLLATE "default",
	"uid" varchar NOT NULL COLLATE "default",
	"created_at" timestamp(6) NULL,
	"updated_at" timestamp(6) NULL
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."authentications" OWNER TO "poppy";

-- ----------------------------
--  Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS "public"."users";
CREATE TABLE "public"."users" (
	"id" int4 NOT NULL DEFAULT nextval('users_id_seq'::regclass),
	"email" varchar NOT NULL COLLATE "default",
	"crypted_password" varchar COLLATE "default",
	"salt" varchar COLLATE "default",
	"created_at" timestamp(6) NULL,
	"updated_at" timestamp(6) NULL,
	"reset_password_token" varchar COLLATE "default",
	"reset_password_token_expires_at" timestamp(6) NULL,
	"reset_password_email_sent_at" timestamp(6) NULL,
	"activation_state" varchar COLLATE "default",
	"activation_token" varchar COLLATE "default",
	"activation_token_expires_at" timestamp(6) NULL,
	"first_name" varchar COLLATE "default",
	"last_name" varchar COLLATE "default",
	"user_name" varchar NOT NULL COLLATE "default"
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."users" OWNER TO "poppy";

-- ----------------------------
--  Records of users
-- ----------------------------
BEGIN;
INSERT INTO "public"."users" VALUES ('1', 'tim.varley@gmail.com', '$2a$10$kfWG4CYoKwI3LfNZT5gvIeV9anfA6.cGtJkTdrLmsinBpYxh.BlVG', 'xBWeEdMyzHhsY4GELxWe', '2016-04-06 14:17:37.343111', '2016-04-06 14:17:37.616238', null, null, null, 'active', null, null, null, null, 'tvarley');
COMMIT;

-- ----------------------------
--  Table structure for whispers
-- ----------------------------
DROP TABLE IF EXISTS "public"."whispers";
CREATE TABLE "public"."whispers" (
	"id" int4 NOT NULL DEFAULT nextval('whispers_id_seq'::regclass),
	"content" varchar NOT NULL COLLATE "default",
	"created_at" timestamp(6) NOT NULL,
	"updated_at" timestamp(6) NOT NULL,
	"user_id" int4
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."whispers" OWNER TO "poppy";

-- ----------------------------
--  Table structure for reactions
-- ----------------------------
DROP TABLE IF EXISTS "public"."reactions";
CREATE TABLE "public"."reactions" (
	"id" int4 NOT NULL DEFAULT nextval('reactions_id_seq'::regclass),
	"user_id" int4,
	"created_at" timestamp(6) NOT NULL,
	"updated_at" timestamp(6) NOT NULL,
	"reactionable_id" int4 NOT NULL,
	"reactionable_type" varchar NOT NULL COLLATE "default",
	"reaction_type_id" int4 NOT NULL
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."reactions" OWNER TO "poppy";


-- ----------------------------
--  Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."authentications_id_seq" RESTART 2 OWNED BY "authentications"."id";
ALTER SEQUENCE "public"."comments_id_seq" RESTART 2 OWNED BY "comments"."id";
ALTER SEQUENCE "public"."reaction_types_id_seq" RESTART 6 OWNED BY "reaction_types"."id";
ALTER SEQUENCE "public"."reactions_id_seq" RESTART 2 OWNED BY "reactions"."id";
ALTER SEQUENCE "public"."users_id_seq" RESTART 2 OWNED BY "users"."id";
ALTER SEQUENCE "public"."whispers_id_seq" RESTART 2 OWNED BY "whispers"."id";
-- ----------------------------
--  Indexes structure for table schema_migrations
-- ----------------------------
CREATE UNIQUE INDEX  "unique_schema_migrations" ON "public"."schema_migrations" USING btree("version" COLLATE "default" "pg_catalog"."text_ops" ASC NULLS LAST);

-- ----------------------------
--  Primary key structure for table reaction_types
-- ----------------------------
ALTER TABLE "public"."reaction_types" ADD PRIMARY KEY ("id") NOT DEFERRABLE INITIALLY IMMEDIATE;

-- ----------------------------
--  Primary key structure for table comments
-- ----------------------------
ALTER TABLE "public"."comments" ADD PRIMARY KEY ("id") NOT DEFERRABLE INITIALLY IMMEDIATE;

-- ----------------------------
--  Primary key structure for table authentications
-- ----------------------------
ALTER TABLE "public"."authentications" ADD PRIMARY KEY ("id") NOT DEFERRABLE INITIALLY IMMEDIATE;

-- ----------------------------
--  Indexes structure for table authentications
-- ----------------------------
CREATE INDEX  "index_authentications_on_provider_and_uid" ON "public"."authentications" USING btree(provider COLLATE "default" "pg_catalog"."text_ops" ASC NULLS LAST, uid COLLATE "default" "pg_catalog"."text_ops" ASC NULLS LAST);

-- ----------------------------
--  Primary key structure for table users
-- ----------------------------
ALTER TABLE "public"."users" ADD PRIMARY KEY ("id") NOT DEFERRABLE INITIALLY IMMEDIATE;

-- ----------------------------
--  Indexes structure for table users
-- ----------------------------
CREATE INDEX  "index_users_on_activation_token" ON "public"."users" USING btree(activation_token COLLATE "default" "pg_catalog"."text_ops" ASC NULLS LAST);
CREATE UNIQUE INDEX  "index_users_on_email" ON "public"."users" USING btree(email COLLATE "default" "pg_catalog"."text_ops" ASC NULLS LAST);
CREATE INDEX  "index_users_on_reset_password_token" ON "public"."users" USING btree(reset_password_token COLLATE "default" "pg_catalog"."text_ops" ASC NULLS LAST);

-- ----------------------------
--  Primary key structure for table whispers
-- ----------------------------
ALTER TABLE "public"."whispers" ADD PRIMARY KEY ("id") NOT DEFERRABLE INITIALLY IMMEDIATE;

-- ----------------------------
--  Primary key structure for table reactions
-- ----------------------------
ALTER TABLE "public"."reactions" ADD PRIMARY KEY ("id") NOT DEFERRABLE INITIALLY IMMEDIATE;

