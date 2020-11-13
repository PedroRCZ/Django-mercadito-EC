BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS "django_migrations" (
	"id"	integer NOT NULL,
	"app"	varchar(255) NOT NULL,
	"name"	varchar(255) NOT NULL,
	"applied"	datetime NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "auth_group_permissions" (
	"id"	integer NOT NULL,
	"group_id"	integer NOT NULL,
	"permission_id"	integer NOT NULL,
	FOREIGN KEY("group_id") REFERENCES "auth_group"("id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("permission_id") REFERENCES "auth_permission"("id") DEFERRABLE INITIALLY DEFERRED,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "auth_user_groups" (
	"id"	integer NOT NULL,
	"user_id"	integer NOT NULL,
	"group_id"	integer NOT NULL,
	FOREIGN KEY("group_id") REFERENCES "auth_group"("id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("user_id") REFERENCES "auth_user"("id") DEFERRABLE INITIALLY DEFERRED,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "auth_user_user_permissions" (
	"id"	integer NOT NULL,
	"user_id"	integer NOT NULL,
	"permission_id"	integer NOT NULL,
	FOREIGN KEY("user_id") REFERENCES "auth_user"("id") DEFERRABLE INITIALLY DEFERRED,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("permission_id") REFERENCES "auth_permission"("id") DEFERRABLE INITIALLY DEFERRED
);
CREATE TABLE IF NOT EXISTS "account_emailconfirmation" (
	"id"	integer NOT NULL,
	"created"	datetime NOT NULL,
	"sent"	datetime,
	"key"	varchar(64) NOT NULL UNIQUE,
	"email_address_id"	integer NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("email_address_id") REFERENCES "account_emailaddress"("id") DEFERRABLE INITIALLY DEFERRED
);
CREATE TABLE IF NOT EXISTS "account_emailaddress" (
	"id"	integer NOT NULL,
	"verified"	bool NOT NULL,
	"primary"	bool NOT NULL,
	"user_id"	integer NOT NULL,
	"email"	varchar(254) NOT NULL UNIQUE,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("user_id") REFERENCES "auth_user"("id") DEFERRABLE INITIALLY DEFERRED
);
CREATE TABLE IF NOT EXISTS "django_admin_log" (
	"id"	integer NOT NULL,
	"action_time"	datetime NOT NULL,
	"object_id"	text,
	"object_repr"	varchar(200) NOT NULL,
	"change_message"	text NOT NULL,
	"content_type_id"	integer,
	"user_id"	integer NOT NULL,
	"action_flag"	smallint unsigned NOT NULL CHECK("action_flag" >= 0),
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("content_type_id") REFERENCES "django_content_type"("id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("user_id") REFERENCES "auth_user"("id") DEFERRABLE INITIALLY DEFERRED
);
CREATE TABLE IF NOT EXISTS "django_content_type" (
	"id"	integer NOT NULL,
	"app_label"	varchar(100) NOT NULL,
	"model"	varchar(100) NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "auth_permission" (
	"id"	integer NOT NULL,
	"content_type_id"	integer NOT NULL,
	"codename"	varchar(100) NOT NULL,
	"name"	varchar(255) NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("content_type_id") REFERENCES "django_content_type"("id") DEFERRABLE INITIALLY DEFERRED
);
CREATE TABLE IF NOT EXISTS "auth_user" (
	"id"	integer NOT NULL,
	"password"	varchar(128) NOT NULL,
	"last_login"	datetime,
	"is_superuser"	bool NOT NULL,
	"username"	varchar(150) NOT NULL UNIQUE,
	"first_name"	varchar(30) NOT NULL,
	"email"	varchar(254) NOT NULL,
	"is_staff"	bool NOT NULL,
	"is_active"	bool NOT NULL,
	"date_joined"	datetime NOT NULL,
	"last_name"	varchar(150) NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "auth_group" (
	"id"	integer NOT NULL,
	"name"	varchar(150) NOT NULL UNIQUE,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "core_coupon" (
	"id"	integer NOT NULL,
	"code"	varchar(15) NOT NULL,
	"amount"	real NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "core_refund" (
	"id"	integer NOT NULL,
	"reason"	text NOT NULL,
	"accepted"	bool NOT NULL,
	"email"	varchar(254) NOT NULL,
	"order_id"	integer NOT NULL,
	FOREIGN KEY("order_id") REFERENCES "core_order"("id") DEFERRABLE INITIALLY DEFERRED,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "core_payment" (
	"id"	integer NOT NULL,
	"stripe_charge_id"	varchar(50) NOT NULL,
	"amount"	real NOT NULL,
	"timestamp"	datetime NOT NULL,
	"user_id"	integer,
	FOREIGN KEY("user_id") REFERENCES "auth_user"("id") DEFERRABLE INITIALLY DEFERRED,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "core_orderitem" (
	"id"	integer NOT NULL,
	"ordered"	bool NOT NULL,
	"quantity"	integer NOT NULL,
	"item_id"	integer NOT NULL,
	"user_id"	integer NOT NULL,
	FOREIGN KEY("item_id") REFERENCES "core_item"("id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("user_id") REFERENCES "auth_user"("id") DEFERRABLE INITIALLY DEFERRED,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "core_order_items" (
	"id"	integer NOT NULL,
	"order_id"	integer NOT NULL,
	"orderitem_id"	integer NOT NULL,
	FOREIGN KEY("orderitem_id") REFERENCES "core_orderitem"("id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("order_id") REFERENCES "core_order"("id") DEFERRABLE INITIALLY DEFERRED,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "core_billingaddress" (
	"id"	integer NOT NULL,
	"street_address"	varchar(100) NOT NULL,
	"apartment_address"	varchar(100) NOT NULL,
	"country"	varchar(2) NOT NULL,
	"zip"	varchar(100) NOT NULL,
	"user_id"	integer NOT NULL,
	"address_type"	varchar(1) NOT NULL,
	"default"	bool NOT NULL,
	FOREIGN KEY("user_id") REFERENCES "auth_user"("id") DEFERRABLE INITIALLY DEFERRED,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "core_order" (
	"id"	integer NOT NULL,
	"ref_code"	varchar(20) NOT NULL,
	"start_date"	datetime NOT NULL,
	"ordered_date"	datetime NOT NULL,
	"ordered"	bool NOT NULL,
	"being_delivered"	bool NOT NULL,
	"received"	bool NOT NULL,
	"refund_requested"	bool NOT NULL,
	"refund_granted"	bool NOT NULL,
	"coupon_id"	integer,
	"payment_id"	integer,
	"user_id"	integer NOT NULL,
	"shipping_address_id"	integer,
	"billing_address_id"	integer,
	FOREIGN KEY("payment_id") REFERENCES "core_payment"("id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("user_id") REFERENCES "auth_user"("id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("coupon_id") REFERENCES "core_coupon"("id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("billing_address_id") REFERENCES "core_billingaddress"("id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("shipping_address_id") REFERENCES "core_billingaddress"("id") DEFERRABLE INITIALLY DEFERRED,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "core_category" (
	"id"	integer NOT NULL,
	"title"	varchar(100) NOT NULL,
	"slug"	varchar(50) NOT NULL,
	"description"	text NOT NULL,
	"image"	varchar(100) NOT NULL,
	"is_active"	bool NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "django_session" (
	"session_key"	varchar(40) NOT NULL,
	"session_data"	text NOT NULL,
	"expire_date"	datetime NOT NULL,
	PRIMARY KEY("session_key")
);
CREATE TABLE IF NOT EXISTS "django_site" (
	"id"	integer NOT NULL,
	"name"	varchar(50) NOT NULL,
	"domain"	varchar(100) NOT NULL UNIQUE,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "socialaccount_socialapp_sites" (
	"id"	integer NOT NULL,
	"socialapp_id"	integer NOT NULL,
	"site_id"	integer NOT NULL,
	FOREIGN KEY("site_id") REFERENCES "django_site"("id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("socialapp_id") REFERENCES "socialaccount_socialapp"("id") DEFERRABLE INITIALLY DEFERRED,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "socialaccount_socialtoken" (
	"id"	integer NOT NULL,
	"token"	text NOT NULL,
	"token_secret"	text NOT NULL,
	"expires_at"	datetime,
	"account_id"	integer NOT NULL,
	"app_id"	integer NOT NULL,
	FOREIGN KEY("app_id") REFERENCES "socialaccount_socialapp"("id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("account_id") REFERENCES "socialaccount_socialaccount"("id") DEFERRABLE INITIALLY DEFERRED,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "socialaccount_socialapp" (
	"id"	integer NOT NULL,
	"provider"	varchar(30) NOT NULL,
	"name"	varchar(40) NOT NULL,
	"client_id"	varchar(191) NOT NULL,
	"key"	varchar(191) NOT NULL,
	"secret"	varchar(191) NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "socialaccount_socialaccount" (
	"id"	integer NOT NULL,
	"provider"	varchar(30) NOT NULL,
	"uid"	varchar(191) NOT NULL,
	"last_login"	datetime NOT NULL,
	"date_joined"	datetime NOT NULL,
	"user_id"	integer NOT NULL,
	"extra_data"	text NOT NULL,
	FOREIGN KEY("user_id") REFERENCES "auth_user"("id") DEFERRABLE INITIALLY DEFERRED,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "core_item" (
	"id"	integer NOT NULL,
	"title"	varchar(100) NOT NULL,
	"price"	real NOT NULL,
	"discount_price"	real,
	"category_id"	integer NOT NULL,
	"label"	varchar(1) NOT NULL,
	"slug"	varchar(50) NOT NULL,
	"description_long"	text NOT NULL,
	"image"	varchar(100) NOT NULL,
	"is_active"	bool NOT NULL,
	"description_short"	varchar(50) NOT NULL,
	"stock_no"	varchar(10) NOT NULL,
	FOREIGN KEY("category_id") REFERENCES "core_category"("id") DEFERRABLE INITIALLY DEFERRED,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "core_slide" (
	"id"	integer NOT NULL,
	"caption1"	varchar(100) NOT NULL,
	"caption2"	varchar(100) NOT NULL,
	"link"	varchar(100) NOT NULL,
	"is_active"	bool NOT NULL,
	"image"	varchar(100) NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "products_category" (
	"id"	integer NOT NULL,
	"name"	varchar(300) NOT NULL,
	"featured"	bool NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "products_product" (
	"id"	integer NOT NULL,
	"name"	varchar(300) NOT NULL,
	"slug"	varchar(50) NOT NULL,
	"excerpt"	text NOT NULL,
	"detail"	text NOT NULL,
	"price"	real NOT NULL,
	"available"	bool NOT NULL,
	"category_id"	integer NOT NULL,
	"image"	varchar(100) NOT NULL,
	FOREIGN KEY("category_id") REFERENCES "products_category"("id") DEFERRABLE INITIALLY DEFERRED,
	PRIMARY KEY("id" AUTOINCREMENT)
);
INSERT INTO "django_migrations" VALUES (1,'contenttypes','0001_initial','2020-04-12 11:41:19.884409');
INSERT INTO "django_migrations" VALUES (2,'auth','0001_initial','2020-04-12 11:41:20.003373');
INSERT INTO "django_migrations" VALUES (3,'account','0001_initial','2020-04-12 11:41:20.136223');
INSERT INTO "django_migrations" VALUES (4,'account','0002_email_max_length','2020-04-12 11:41:20.789498');
INSERT INTO "django_migrations" VALUES (5,'admin','0001_initial','2020-04-12 11:41:20.927555');
INSERT INTO "django_migrations" VALUES (6,'admin','0002_logentry_remove_auto_add','2020-04-12 11:41:21.028498');
INSERT INTO "django_migrations" VALUES (7,'admin','0003_logentry_add_action_flag_choices','2020-04-12 11:41:21.155229');
INSERT INTO "django_migrations" VALUES (8,'contenttypes','0002_remove_content_type_name','2020-04-12 11:41:21.491595');
INSERT INTO "django_migrations" VALUES (9,'auth','0002_alter_permission_name_max_length','2020-04-12 11:41:21.610098');
INSERT INTO "django_migrations" VALUES (10,'auth','0003_alter_user_email_max_length','2020-04-12 11:41:21.741150');
INSERT INTO "django_migrations" VALUES (11,'auth','0004_alter_user_username_opts','2020-04-12 11:41:21.970261');
INSERT INTO "django_migrations" VALUES (12,'auth','0005_alter_user_last_login_null','2020-04-12 11:41:22.416270');
INSERT INTO "django_migrations" VALUES (13,'auth','0006_require_contenttypes_0002','2020-04-12 11:41:22.625990');
INSERT INTO "django_migrations" VALUES (14,'auth','0007_alter_validators_add_error_messages','2020-04-12 11:41:22.757293');
INSERT INTO "django_migrations" VALUES (15,'auth','0008_alter_user_username_max_length','2020-04-12 11:41:22.864154');
INSERT INTO "django_migrations" VALUES (16,'auth','0009_alter_user_last_name_max_length','2020-04-12 11:41:22.974549');
INSERT INTO "django_migrations" VALUES (17,'auth','0010_alter_group_name_max_length','2020-04-12 11:41:23.086687');
INSERT INTO "django_migrations" VALUES (18,'auth','0011_update_proxy_permissions','2020-04-12 11:41:23.205660');
INSERT INTO "django_migrations" VALUES (19,'core','0001_initial','2020-04-12 11:41:23.736914');
INSERT INTO "django_migrations" VALUES (20,'core','0002_auto_20191105_0426','2020-04-12 11:41:23.905791');
INSERT INTO "django_migrations" VALUES (21,'core','0003_auto_20200412_1441','2020-04-12 11:41:24.120743');
INSERT INTO "django_migrations" VALUES (22,'sessions','0001_initial','2020-04-12 11:41:24.412312');
INSERT INTO "django_migrations" VALUES (23,'sites','0001_initial','2020-04-12 11:41:24.530535');
INSERT INTO "django_migrations" VALUES (24,'sites','0002_alter_domain_unique','2020-04-12 11:41:24.650260');
INSERT INTO "django_migrations" VALUES (25,'socialaccount','0001_initial','2020-04-12 11:41:24.809144');
INSERT INTO "django_migrations" VALUES (26,'socialaccount','0002_token_max_lengths','2020-04-12 11:41:24.969080');
INSERT INTO "django_migrations" VALUES (27,'socialaccount','0003_extra_data_default_dict','2020-04-12 11:41:25.242456');
INSERT INTO "django_migrations" VALUES (28,'core','0004_auto_20200412_1510','2020-04-12 12:11:02.891106');
INSERT INTO "django_migrations" VALUES (29,'core','0005_item_stock_no','2020-04-12 12:57:46.401921');
INSERT INTO "django_migrations" VALUES (30,'core','0006_slide','2020-04-12 22:45:24.815313');
INSERT INTO "django_migrations" VALUES (31,'core','0007_auto_20200510_2016','2020-05-11 03:16:32.270066');
INSERT INTO "django_migrations" VALUES (32,'products','0001_initial','2020-11-07 19:21:26.733508');
INSERT INTO "django_migrations" VALUES (33,'products','0002_auto_20201107_1455','2020-11-07 19:55:50.751238');
INSERT INTO "account_emailaddress" VALUES (1,0,1,3,'hanthit@gmail.com');
INSERT INTO "account_emailaddress" VALUES (2,0,1,4,'hanthit2@gmail.com');
INSERT INTO "account_emailaddress" VALUES (3,0,1,5,'hanthit3@gmail.com');
INSERT INTO "account_emailaddress" VALUES (4,0,1,6,'hanthit5@gmail.com');
INSERT INTO "account_emailaddress" VALUES (5,1,1,7,'wilsom123456789@gmail.com');
INSERT INTO "django_admin_log" VALUES (1,'2020-04-12 11:46:08.497220','1','Dresses','[{"added": {}}]',20,1,1);
INSERT INTO "django_admin_log" VALUES (2,'2020-04-12 11:46:37.051367','1','Aaa','[{"added": {}}]',15,1,1);
INSERT INTO "django_admin_log" VALUES (3,'2020-04-12 11:56:03.236224','2','Watches','[{"added": {}}]',20,1,1);
INSERT INTO "django_admin_log" VALUES (4,'2020-04-12 11:56:05.238264','2','Watches','[]',20,1,2);
INSERT INTO "django_admin_log" VALUES (5,'2020-04-12 11:56:19.367869','3','Bags','[{"added": {}}]',20,1,1);
INSERT INTO "django_admin_log" VALUES (6,'2020-04-12 11:57:38.436114','2','Bbb','[{"changed": {"fields": ["title", "slug", "description", "image"]}}]',15,1,2);
INSERT INTO "django_admin_log" VALUES (7,'2020-04-12 12:11:31.906407','2','Bbb','[{"changed": {"fields": ["description_short", "description_long"]}}]',15,1,2);
INSERT INTO "django_admin_log" VALUES (8,'2020-04-12 12:11:46.862488','1','Aaa','[{"changed": {"fields": ["description_short", "description_long"]}}]',15,1,2);
INSERT INTO "django_admin_log" VALUES (9,'2020-04-12 12:58:40.144143','1','Aaa','[{"changed": {"fields": ["stock_no"]}}]',15,1,2);
INSERT INTO "django_admin_log" VALUES (10,'2020-04-12 12:58:47.218630','2','Bbb','[{"changed": {"fields": ["stock_no"]}}]',15,1,2);
INSERT INTO "django_admin_log" VALUES (11,'2020-04-12 13:03:24.125837','1','Aaa','[{"changed": {"fields": ["slug"]}}]',15,1,2);
INSERT INTO "django_admin_log" VALUES (12,'2020-04-12 13:03:35.251729','1','Aaa','[{"changed": {"fields": ["slug"]}}]',15,1,2);
INSERT INTO "django_admin_log" VALUES (13,'2020-04-12 15:33:06.819665','2','Bbb','[{"changed": {"fields": ["category"]}}]',15,1,2);
INSERT INTO "django_admin_log" VALUES (14,'2020-04-12 21:22:09.999986','4','c1','[{"added": {}}]',20,1,1);
INSERT INTO "django_admin_log" VALUES (15,'2020-04-12 21:22:20.712177','5','c2','[{"added": {}}]',20,1,1);
INSERT INTO "django_admin_log" VALUES (16,'2020-04-12 21:22:28.630605','6','c3','[{"added": {}}]',20,1,1);
INSERT INTO "django_admin_log" VALUES (17,'2020-04-12 21:22:34.788255','7','c3','[{"added": {}}]',20,1,1);
INSERT INTO "django_admin_log" VALUES (18,'2020-04-12 22:08:41.588548','7','c3','[{"changed": {"fields": ["image"]}}]',20,1,2);
INSERT INTO "django_admin_log" VALUES (19,'2020-04-12 22:09:10.437978','7','c3','[]',20,1,2);
INSERT INTO "django_admin_log" VALUES (20,'2020-04-12 22:09:27.713243','7','c3','[{"changed": {"fields": ["image"]}}]',20,1,2);
INSERT INTO "django_admin_log" VALUES (21,'2020-04-12 22:18:28.149730','7','c4','[{"changed": {"fields": ["title", "slug", "description"]}}]',20,1,2);
INSERT INTO "django_admin_log" VALUES (22,'2020-04-12 22:18:39.564847','6','c3','[{"changed": {"fields": ["image"]}}]',20,1,2);
INSERT INTO "django_admin_log" VALUES (23,'2020-04-12 22:46:24.658073','1','caption 1 - caption 2','[{"added": {}}]',21,1,1);
INSERT INTO "django_admin_log" VALUES (24,'2020-04-12 22:49:22.581135','1','caption 1 - caption 2','[{"changed": {"fields": ["image"]}}]',21,1,2);
INSERT INTO "django_admin_log" VALUES (25,'2020-04-12 22:57:01.438890','1','slide 1 caption 1 - slide 1 caption 2','[{"changed": {"fields": ["caption1", "caption2"]}}]',21,1,2);
INSERT INTO "django_admin_log" VALUES (26,'2020-04-12 22:57:25.149757','2','slide 2 caption 1 - slide 2 caption 2','[{"added": {}}]',21,1,1);
INSERT INTO "django_admin_log" VALUES (27,'2020-04-13 00:51:51.940235','1','admin','[{"added": {}}]',10,1,1);
INSERT INTO "django_admin_log" VALUES (28,'2020-04-13 00:52:38.115880','1','admin','',10,1,3);
INSERT INTO "django_admin_log" VALUES (29,'2020-04-13 01:25:47.817494','1','Google','[{"added": {}}]',11,1,1);
INSERT INTO "django_admin_log" VALUES (30,'2020-05-16 07:08:16.320304','1','Gear up with our latest sweat-wicking and lightweight running products and stay connected. - RUN AHEAD INTO SUMMER','[{"changed": {"fields": ["caption1", "caption2", "link", "image"]}}]',21,1,2);
INSERT INTO "django_admin_log" VALUES (31,'2020-05-16 07:20:58.402853','2','Cool and pleasant as if your feet are breathing - CLIMACOOL','[{"changed": {"fields": ["caption1", "caption2", "link", "image"]}}]',21,1,2);
INSERT INTO "django_admin_log" VALUES (32,'2020-11-07 17:42:19.115251','5','wilsom123456789@gmail.com (wilson)','[{"changed": {"fields": ["verified"]}}]',8,1,2);
INSERT INTO "django_admin_log" VALUES (33,'2020-11-07 17:42:47.207929','7','wilson','[{"changed": {"fields": ["is_staff", "is_superuser"]}}]',4,1,2);
INSERT INTO "django_admin_log" VALUES (34,'2020-11-07 17:45:15.901074','1','tecnología','[{"changed": {"fields": ["title", "slug", "description"]}}]',20,1,2);
INSERT INTO "django_admin_log" VALUES (35,'2020-11-07 17:48:08.416918','1','tecnología','[{"changed": {"fields": ["image"]}}]',20,1,2);
INSERT INTO "django_admin_log" VALUES (36,'2020-11-07 17:50:29.661772','2','almacenes','[{"changed": {"fields": ["title", "slug", "description", "image"]}}]',20,1,2);
INSERT INTO "django_admin_log" VALUES (37,'2020-11-07 17:51:10.814730','3','ferreterías','[{"changed": {"fields": ["title", "slug", "description", "image"]}}]',20,1,2);
INSERT INTO "django_admin_log" VALUES (38,'2020-11-07 17:51:44.969565','4','salud','[{"changed": {"fields": ["title", "slug", "description", "image"]}}]',20,1,2);
INSERT INTO "django_admin_log" VALUES (39,'2020-11-07 17:51:54.211256','7','c4','',20,1,3);
INSERT INTO "django_admin_log" VALUES (40,'2020-11-07 17:51:54.288218','6','c3','',20,1,3);
INSERT INTO "django_admin_log" VALUES (41,'2020-11-07 17:51:54.380189','5','c2','',20,1,3);
INSERT INTO "django_admin_log" VALUES (42,'2020-11-07 17:58:45.846964','1','Nintendo Switch Versión 2','[{"changed": {"fields": ["title", "price", "slug", "description_short", "description_long", "image"]}}]',15,1,2);
INSERT INTO "django_admin_log" VALUES (43,'2020-11-07 18:01:32.896862','2','moda','[{"changed": {"fields": ["title", "slug", "description"]}}]',20,1,2);
INSERT INTO "django_admin_log" VALUES (44,'2020-11-07 18:03:39.771955','2','Nike Quest 2 Zapatos Correr Mujer','[{"changed": {"fields": ["title", "price", "slug", "description_short", "description_long", "image"]}}]',15,1,2);
INSERT INTO "django_admin_log" VALUES (45,'2020-11-07 18:07:55.764245','3','JARABE NATURAL PARA TOS Y FLEMA','[{"added": {}}]',15,1,1);
INSERT INTO "django_admin_log" VALUES (46,'2020-11-07 18:12:43.067226','4','Carretilla Carro Coche De Carga Acero Dos Posiciones Freno','[{"added": {}}]',15,1,1);
INSERT INTO "django_content_type" VALUES (1,'admin','logentry');
INSERT INTO "django_content_type" VALUES (2,'auth','permission');
INSERT INTO "django_content_type" VALUES (3,'auth','group');
INSERT INTO "django_content_type" VALUES (4,'auth','user');
INSERT INTO "django_content_type" VALUES (5,'contenttypes','contenttype');
INSERT INTO "django_content_type" VALUES (6,'sessions','session');
INSERT INTO "django_content_type" VALUES (7,'sites','site');
INSERT INTO "django_content_type" VALUES (8,'account','emailaddress');
INSERT INTO "django_content_type" VALUES (9,'account','emailconfirmation');
INSERT INTO "django_content_type" VALUES (10,'socialaccount','socialaccount');
INSERT INTO "django_content_type" VALUES (11,'socialaccount','socialapp');
INSERT INTO "django_content_type" VALUES (12,'socialaccount','socialtoken');
INSERT INTO "django_content_type" VALUES (13,'core','billingaddress');
INSERT INTO "django_content_type" VALUES (14,'core','coupon');
INSERT INTO "django_content_type" VALUES (15,'core','item');
INSERT INTO "django_content_type" VALUES (16,'core','order');
INSERT INTO "django_content_type" VALUES (17,'core','refund');
INSERT INTO "django_content_type" VALUES (18,'core','payment');
INSERT INTO "django_content_type" VALUES (19,'core','orderitem');
INSERT INTO "django_content_type" VALUES (20,'core','category');
INSERT INTO "django_content_type" VALUES (21,'core','slide');
INSERT INTO "django_content_type" VALUES (22,'products','product');
INSERT INTO "django_content_type" VALUES (23,'products','category');
INSERT INTO "auth_permission" VALUES (1,1,'add_logentry','Can add log entry');
INSERT INTO "auth_permission" VALUES (2,1,'change_logentry','Can change log entry');
INSERT INTO "auth_permission" VALUES (3,1,'delete_logentry','Can delete log entry');
INSERT INTO "auth_permission" VALUES (4,1,'view_logentry','Can view log entry');
INSERT INTO "auth_permission" VALUES (5,2,'add_permission','Can add permission');
INSERT INTO "auth_permission" VALUES (6,2,'change_permission','Can change permission');
INSERT INTO "auth_permission" VALUES (7,2,'delete_permission','Can delete permission');
INSERT INTO "auth_permission" VALUES (8,2,'view_permission','Can view permission');
INSERT INTO "auth_permission" VALUES (9,3,'add_group','Can add group');
INSERT INTO "auth_permission" VALUES (10,3,'change_group','Can change group');
INSERT INTO "auth_permission" VALUES (11,3,'delete_group','Can delete group');
INSERT INTO "auth_permission" VALUES (12,3,'view_group','Can view group');
INSERT INTO "auth_permission" VALUES (13,4,'add_user','Can add user');
INSERT INTO "auth_permission" VALUES (14,4,'change_user','Can change user');
INSERT INTO "auth_permission" VALUES (15,4,'delete_user','Can delete user');
INSERT INTO "auth_permission" VALUES (16,4,'view_user','Can view user');
INSERT INTO "auth_permission" VALUES (17,5,'add_contenttype','Can add content type');
INSERT INTO "auth_permission" VALUES (18,5,'change_contenttype','Can change content type');
INSERT INTO "auth_permission" VALUES (19,5,'delete_contenttype','Can delete content type');
INSERT INTO "auth_permission" VALUES (20,5,'view_contenttype','Can view content type');
INSERT INTO "auth_permission" VALUES (21,6,'add_session','Can add session');
INSERT INTO "auth_permission" VALUES (22,6,'change_session','Can change session');
INSERT INTO "auth_permission" VALUES (23,6,'delete_session','Can delete session');
INSERT INTO "auth_permission" VALUES (24,6,'view_session','Can view session');
INSERT INTO "auth_permission" VALUES (25,7,'add_site','Can add site');
INSERT INTO "auth_permission" VALUES (26,7,'change_site','Can change site');
INSERT INTO "auth_permission" VALUES (27,7,'delete_site','Can delete site');
INSERT INTO "auth_permission" VALUES (28,7,'view_site','Can view site');
INSERT INTO "auth_permission" VALUES (29,8,'add_emailaddress','Can add email address');
INSERT INTO "auth_permission" VALUES (30,8,'change_emailaddress','Can change email address');
INSERT INTO "auth_permission" VALUES (31,8,'delete_emailaddress','Can delete email address');
INSERT INTO "auth_permission" VALUES (32,8,'view_emailaddress','Can view email address');
INSERT INTO "auth_permission" VALUES (33,9,'add_emailconfirmation','Can add email confirmation');
INSERT INTO "auth_permission" VALUES (34,9,'change_emailconfirmation','Can change email confirmation');
INSERT INTO "auth_permission" VALUES (35,9,'delete_emailconfirmation','Can delete email confirmation');
INSERT INTO "auth_permission" VALUES (36,9,'view_emailconfirmation','Can view email confirmation');
INSERT INTO "auth_permission" VALUES (37,10,'add_socialaccount','Can add social account');
INSERT INTO "auth_permission" VALUES (38,10,'change_socialaccount','Can change social account');
INSERT INTO "auth_permission" VALUES (39,10,'delete_socialaccount','Can delete social account');
INSERT INTO "auth_permission" VALUES (40,10,'view_socialaccount','Can view social account');
INSERT INTO "auth_permission" VALUES (41,11,'add_socialapp','Can add social application');
INSERT INTO "auth_permission" VALUES (42,11,'change_socialapp','Can change social application');
INSERT INTO "auth_permission" VALUES (43,11,'delete_socialapp','Can delete social application');
INSERT INTO "auth_permission" VALUES (44,11,'view_socialapp','Can view social application');
INSERT INTO "auth_permission" VALUES (45,12,'add_socialtoken','Can add social application token');
INSERT INTO "auth_permission" VALUES (46,12,'change_socialtoken','Can change social application token');
INSERT INTO "auth_permission" VALUES (47,12,'delete_socialtoken','Can delete social application token');
INSERT INTO "auth_permission" VALUES (48,12,'view_socialtoken','Can view social application token');
INSERT INTO "auth_permission" VALUES (49,13,'add_billingaddress','Can add billing address');
INSERT INTO "auth_permission" VALUES (50,13,'change_billingaddress','Can change billing address');
INSERT INTO "auth_permission" VALUES (51,13,'delete_billingaddress','Can delete billing address');
INSERT INTO "auth_permission" VALUES (52,13,'view_billingaddress','Can view billing address');
INSERT INTO "auth_permission" VALUES (53,14,'add_coupon','Can add coupon');
INSERT INTO "auth_permission" VALUES (54,14,'change_coupon','Can change coupon');
INSERT INTO "auth_permission" VALUES (55,14,'delete_coupon','Can delete coupon');
INSERT INTO "auth_permission" VALUES (56,14,'view_coupon','Can view coupon');
INSERT INTO "auth_permission" VALUES (57,15,'add_item','Can add item');
INSERT INTO "auth_permission" VALUES (58,15,'change_item','Can change item');
INSERT INTO "auth_permission" VALUES (59,15,'delete_item','Can delete item');
INSERT INTO "auth_permission" VALUES (60,15,'view_item','Can view item');
INSERT INTO "auth_permission" VALUES (61,16,'add_order','Can add order');
INSERT INTO "auth_permission" VALUES (62,16,'change_order','Can change order');
INSERT INTO "auth_permission" VALUES (63,16,'delete_order','Can delete order');
INSERT INTO "auth_permission" VALUES (64,16,'view_order','Can view order');
INSERT INTO "auth_permission" VALUES (65,17,'add_refund','Can add refund');
INSERT INTO "auth_permission" VALUES (66,17,'change_refund','Can change refund');
INSERT INTO "auth_permission" VALUES (67,17,'delete_refund','Can delete refund');
INSERT INTO "auth_permission" VALUES (68,17,'view_refund','Can view refund');
INSERT INTO "auth_permission" VALUES (69,18,'add_payment','Can add payment');
INSERT INTO "auth_permission" VALUES (70,18,'change_payment','Can change payment');
INSERT INTO "auth_permission" VALUES (71,18,'delete_payment','Can delete payment');
INSERT INTO "auth_permission" VALUES (72,18,'view_payment','Can view payment');
INSERT INTO "auth_permission" VALUES (73,19,'add_orderitem','Can add order item');
INSERT INTO "auth_permission" VALUES (74,19,'change_orderitem','Can change order item');
INSERT INTO "auth_permission" VALUES (75,19,'delete_orderitem','Can delete order item');
INSERT INTO "auth_permission" VALUES (76,19,'view_orderitem','Can view order item');
INSERT INTO "auth_permission" VALUES (77,20,'add_category','Can add category');
INSERT INTO "auth_permission" VALUES (78,20,'change_category','Can change category');
INSERT INTO "auth_permission" VALUES (79,20,'delete_category','Can delete category');
INSERT INTO "auth_permission" VALUES (80,20,'view_category','Can view category');
INSERT INTO "auth_permission" VALUES (81,21,'add_slide','Can add slide');
INSERT INTO "auth_permission" VALUES (82,21,'change_slide','Can change slide');
INSERT INTO "auth_permission" VALUES (83,21,'delete_slide','Can delete slide');
INSERT INTO "auth_permission" VALUES (84,21,'view_slide','Can view slide');
INSERT INTO "auth_permission" VALUES (85,22,'add_product','Can add Producto');
INSERT INTO "auth_permission" VALUES (86,22,'change_product','Can change Producto');
INSERT INTO "auth_permission" VALUES (87,22,'delete_product','Can delete Producto');
INSERT INTO "auth_permission" VALUES (88,22,'view_product','Can view Producto');
INSERT INTO "auth_permission" VALUES (89,23,'add_category','Can add Categoría');
INSERT INTO "auth_permission" VALUES (90,23,'change_category','Can change Categoría');
INSERT INTO "auth_permission" VALUES (91,23,'delete_category','Can delete Categoría');
INSERT INTO "auth_permission" VALUES (92,23,'view_category','Can view Categoría');
INSERT INTO "auth_user" VALUES (1,'pbkdf2_sha256$150000$DRq0Yc22WxLC$0dEqXojF4NZUFWtDP/wuhPtp976bKDhWYM/nho2NHtM=','2020-11-07 17:42:09.601602',1,'admin','','',1,1,'2020-04-12 11:43:53.820766','');
INSERT INTO "auth_user" VALUES (2,'pbkdf2_sha256$150000$52k3n2lxSjoT$c0VmAvBbn82xGiEx5mgukwYMDG18xfVfpq3ZI5VWchs=','2020-05-11 03:20:36.977589',1,'admin7','','',1,1,'2020-05-11 03:18:04.750861','');
INSERT INTO "auth_user" VALUES (3,'pbkdf2_sha256$150000$j22qryp1r2qe$80h8ogva3zUv+E3zd7r2feur0Z301N4kB/5IlVFrbzg=','2020-05-11 04:18:24.301438',0,'hanthit','','hanthit@gmail.com',0,1,'2020-05-11 03:34:58.912935','');
INSERT INTO "auth_user" VALUES (4,'pbkdf2_sha256$150000$eg8i4jBHMkuG$trcIVt0TXuOSeHpTu3GvOBKN1DzBSMdaEZZ7L6azFZ4=',NULL,0,'hanthit2','','hanthit2@gmail.com',0,1,'2020-05-11 04:05:02.677708','');
INSERT INTO "auth_user" VALUES (5,'pbkdf2_sha256$150000$47LfLCzlJ5lG$oYfYRCkmUw41IrmCB0cP6g6ooydJs/C/ThBxgf/ZNKs=',NULL,0,'hanthit3','','hanthit3@gmail.com',0,1,'2020-05-11 04:12:19.752433','');
INSERT INTO "auth_user" VALUES (6,'pbkdf2_sha256$150000$OmZWi0JXgN1p$e6WXRK4EdP4YlYTg6y1uBqAjcMKP6gqUhYa5E7nnBVg=',NULL,0,'hanthit5','','hanthit5@gmail.com',0,1,'2020-05-11 04:13:03.836198','');
INSERT INTO "auth_user" VALUES (7,'pbkdf2_sha256$150000$HqthONZbyYJr$cMMoCVqD6W6x+tmxpXdr2+Zy+gx1z37JyDA6NALYdlk=','2020-11-07 17:30:42',1,'wilson','','wilsom123456789@gmail.com',1,1,'2020-11-07 17:29:16','');
INSERT INTO "core_orderitem" VALUES (1,0,2,1,3);
INSERT INTO "core_orderitem" VALUES (2,0,1,2,3);
INSERT INTO "core_order_items" VALUES (1,1,1);
INSERT INTO "core_order_items" VALUES (2,1,2);
INSERT INTO "core_order" VALUES (1,'','2020-05-11 04:18:24.674405','2020-05-11 04:18:24.673401',0,0,0,0,0,NULL,NULL,3,NULL,NULL);
INSERT INTO "core_category" VALUES (1,'tecnología','tecnologia','tecnología','Pngtreecartoon_style_work_space_411946.jpg',1);
INSERT INTO "core_category" VALUES (2,'moda','moda','moda','text-banner-png-transparent-picture-png-mart-text-banner-png-2390_852.png',1);
INSERT INTO "core_category" VALUES (3,'ferreterías','ferreterias','ferreterías','text-banner-png-transparent-picture-png-mart-text-banner-png-2390_852_fpB7OIg.png',1);
INSERT INTO "core_category" VALUES (4,'salud','salud','salud','text-banner-png-transparent-picture-png-mart-text-banner-png-2390_852_atFTXCp.png',1);
INSERT INTO "django_session" VALUES ('2k1hsor8s8s677bq996t3sfyih02lmav','OTJkZmZjY2E3Y2E4YTlhMWVmM2YxMWM1OTc3NWZjZmExZjU1MzIyMTp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJmNDA0MjQzZTZhODRjNmNjMDUxMWEzNjE2NzY2OGQ2NmMwZTcyYjY0In0=','2020-04-26 11:44:05.287931');
INSERT INTO "django_session" VALUES ('9qu80qly32p8ojsn6x5tqh8gx8vm1o4q','ZTUzMjQ4YmRjODM4NmUzOGQ0NTkwY2M0ZGMxNjFmZjI2MzNiMjYyNjp7InNvY2lhbGFjY291bnRfc3RhdGUiOlt7InByb2Nlc3MiOiJsb2dpbiIsInNjb3BlIjoiIiwiYXV0aF9wYXJhbXMiOiIifSwibk5CcVk3cXNjOGJ6Il19','2020-04-27 01:26:00.595489');
INSERT INTO "django_session" VALUES ('jo0dp3s3cdm3ja1kj5kc30e4wfejehoh','OTJkZmZjY2E3Y2E4YTlhMWVmM2YxMWM1OTc3NWZjZmExZjU1MzIyMTp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJmNDA0MjQzZTZhODRjNmNjMDUxMWEzNjE2NzY2OGQ2NmMwZTcyYjY0In0=','2020-05-30 06:54:03.381528');
INSERT INTO "django_session" VALUES ('da0p5mzp083xalurg3qgrw6v66rn461l','OTJkZmZjY2E3Y2E4YTlhMWVmM2YxMWM1OTc3NWZjZmExZjU1MzIyMTp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJmNDA0MjQzZTZhODRjNmNjMDUxMWEzNjE2NzY2OGQ2NmMwZTcyYjY0In0=','2020-11-21 17:42:09.683580');
INSERT INTO "django_site" VALUES (1,'example.com','example.com');
INSERT INTO "socialaccount_socialapp_sites" VALUES (1,1,1);
INSERT INTO "socialaccount_socialapp" VALUES (1,'google','Google','Client ID','222','111');
INSERT INTO "core_item" VALUES (1,'Nintendo Switch Versión 2',649.0,NULL,1,'S','Nintendo_Switch','¡Llegó nuevamente Nintendo Switch! Además de proporcionar emociones para un solo jugador y multijugador en casa, el sistema Nintendo Switch también permite que los jugadores jueguen el mismo título donde sea, cuando sea y con quien elijan. La movilidad de una computadora de mano ahora se agrega a la potencia de un sistema de juegos en casa para permitir nuevos estilos de juego de videojuegos sin precedentes.','Nintendo-Swicth-V2-Mobile-Store-Ecuador-300x300.jpg',1,'witch Versión 2','123');
INSERT INTO "core_item" VALUES (2,'Nike Quest 2 Zapatos Correr Mujer',89.0,NULL,2,'S','nike','Los Nike Quest 2 son unos zapatos de mujer para correr que te permitirán deslizarte con comodidad sobre una variedad de superficies, su suela exterior añade un patrón de tracción más alto para optimizar tus pisadas. Su mediasuela Phylon te garantiza una excelente amortiguación para seguir sumando kilómetros a tu historial.','nike-quest-2-zapatos-correr-mujer-D_NQ_NP_714014-MEC43982832433_112020-O.webp',1,'Nike Quest 2','456');
INSERT INTO "core_item" VALUES (3,'JARABE NATURAL PARA TOS Y FLEMA',9.36,NULL,4,'S','jarabe-natural-para-tos-y-flema','JARABE BRONQUIAL FORTE, es un producto 100% natural, sin conservantes ni colorantes, que combina las más potentes plantas medicinales con los beneficios de la miel de abeja, propóleo y polen. Está indicado para el alivio de la tos seca y con flema ocasionadas por infecciones en vías respiratorias.','ARTES-PRODUCTOS-49-1-768x768.jpg',1,'jarabe','123');
INSERT INTO "core_item" VALUES (4,'Carretilla Carro Coche De Carga Acero Dos Posiciones Freno',54.0,NULL,3,'S','carretilla-carro-coche-de-carga-acero-dos-posicion','Plataforma De Transporte Carretilla Plegable Carretilla De Mano Hasta 70 Kg

Características

Carro de transporte de aluminio
Es Plegable
Mangos ajustables de 3 etapas
Peso: 3kg
,Capacidad de carga: 70kg máximo
Dimensiones abierto: 41x38.5x100cm','carretila.webp',1,'Carretilla Carro Coche','123');
INSERT INTO "core_slide" VALUES (1,'Gear up with our latest sweat-wicking and lightweight running products and stay connected.','RUN AHEAD INTO SUMMER','/shop/',1,'add_slide_1.jpg');
INSERT INTO "core_slide" VALUES (2,'Cool and pleasant as if your feet are breathing','CLIMACOOL','/shop/',1,'kr_slide_add_2.jpg');
CREATE UNIQUE INDEX IF NOT EXISTS "auth_group_permissions_group_id_permission_id_0cd325b0_uniq" ON "auth_group_permissions" (
	"group_id",
	"permission_id"
);
CREATE INDEX IF NOT EXISTS "auth_group_permissions_group_id_b120cbf9" ON "auth_group_permissions" (
	"group_id"
);
CREATE INDEX IF NOT EXISTS "auth_group_permissions_permission_id_84c5c92e" ON "auth_group_permissions" (
	"permission_id"
);
CREATE UNIQUE INDEX IF NOT EXISTS "auth_user_groups_user_id_group_id_94350c0c_uniq" ON "auth_user_groups" (
	"user_id",
	"group_id"
);
CREATE INDEX IF NOT EXISTS "auth_user_groups_user_id_6a12ed8b" ON "auth_user_groups" (
	"user_id"
);
CREATE INDEX IF NOT EXISTS "auth_user_groups_group_id_97559544" ON "auth_user_groups" (
	"group_id"
);
CREATE UNIQUE INDEX IF NOT EXISTS "auth_user_user_permissions_user_id_permission_id_14a6b632_uniq" ON "auth_user_user_permissions" (
	"user_id",
	"permission_id"
);
CREATE INDEX IF NOT EXISTS "auth_user_user_permissions_user_id_a95ead1b" ON "auth_user_user_permissions" (
	"user_id"
);
CREATE INDEX IF NOT EXISTS "auth_user_user_permissions_permission_id_1fbb5f2c" ON "auth_user_user_permissions" (
	"permission_id"
);
CREATE INDEX IF NOT EXISTS "account_emailconfirmation_email_address_id_5b7f8c58" ON "account_emailconfirmation" (
	"email_address_id"
);
CREATE INDEX IF NOT EXISTS "account_emailaddress_user_id_2c513194" ON "account_emailaddress" (
	"user_id"
);
CREATE INDEX IF NOT EXISTS "django_admin_log_content_type_id_c4bce8eb" ON "django_admin_log" (
	"content_type_id"
);
CREATE INDEX IF NOT EXISTS "django_admin_log_user_id_c564eba6" ON "django_admin_log" (
	"user_id"
);
CREATE UNIQUE INDEX IF NOT EXISTS "django_content_type_app_label_model_76bd3d3b_uniq" ON "django_content_type" (
	"app_label",
	"model"
);
CREATE UNIQUE INDEX IF NOT EXISTS "auth_permission_content_type_id_codename_01ab375a_uniq" ON "auth_permission" (
	"content_type_id",
	"codename"
);
CREATE INDEX IF NOT EXISTS "auth_permission_content_type_id_2f476e4b" ON "auth_permission" (
	"content_type_id"
);
CREATE INDEX IF NOT EXISTS "core_refund_order_id_7fe621fa" ON "core_refund" (
	"order_id"
);
CREATE INDEX IF NOT EXISTS "core_payment_user_id_274e164a" ON "core_payment" (
	"user_id"
);
CREATE INDEX IF NOT EXISTS "core_orderitem_item_id_3b7d0c2e" ON "core_orderitem" (
	"item_id"
);
CREATE INDEX IF NOT EXISTS "core_orderitem_user_id_323fe695" ON "core_orderitem" (
	"user_id"
);
CREATE UNIQUE INDEX IF NOT EXISTS "core_order_items_order_id_orderitem_id_f9cea05f_uniq" ON "core_order_items" (
	"order_id",
	"orderitem_id"
);
CREATE INDEX IF NOT EXISTS "core_order_items_order_id_c5dde6c1" ON "core_order_items" (
	"order_id"
);
CREATE INDEX IF NOT EXISTS "core_order_items_orderitem_id_e44f86b6" ON "core_order_items" (
	"orderitem_id"
);
CREATE INDEX IF NOT EXISTS "core_billingaddress_user_id_3c220740" ON "core_billingaddress" (
	"user_id"
);
CREATE INDEX IF NOT EXISTS "core_order_coupon_id_bade53ba" ON "core_order" (
	"coupon_id"
);
CREATE INDEX IF NOT EXISTS "core_order_payment_id_e5a26a3c" ON "core_order" (
	"payment_id"
);
CREATE INDEX IF NOT EXISTS "core_order_user_id_b03bbffd" ON "core_order" (
	"user_id"
);
CREATE INDEX IF NOT EXISTS "core_order_shipping_address_id_8c054f15" ON "core_order" (
	"shipping_address_id"
);
CREATE INDEX IF NOT EXISTS "core_order_billing_address_id_b33cde99" ON "core_order" (
	"billing_address_id"
);
CREATE INDEX IF NOT EXISTS "core_category_slug_384eca9c" ON "core_category" (
	"slug"
);
CREATE INDEX IF NOT EXISTS "django_session_expire_date_a5c62663" ON "django_session" (
	"expire_date"
);
CREATE UNIQUE INDEX IF NOT EXISTS "socialaccount_socialtoken_app_id_account_id_fca4e0ac_uniq" ON "socialaccount_socialtoken" (
	"app_id",
	"account_id"
);
CREATE UNIQUE INDEX IF NOT EXISTS "socialaccount_socialapp_sites_socialapp_id_site_id_71a9a768_uniq" ON "socialaccount_socialapp_sites" (
	"socialapp_id",
	"site_id"
);
CREATE INDEX IF NOT EXISTS "socialaccount_socialapp_sites_socialapp_id_97fb6e7d" ON "socialaccount_socialapp_sites" (
	"socialapp_id"
);
CREATE INDEX IF NOT EXISTS "socialaccount_socialapp_sites_site_id_2579dee5" ON "socialaccount_socialapp_sites" (
	"site_id"
);
CREATE INDEX IF NOT EXISTS "socialaccount_socialtoken_account_id_951f210e" ON "socialaccount_socialtoken" (
	"account_id"
);
CREATE INDEX IF NOT EXISTS "socialaccount_socialtoken_app_id_636a42d7" ON "socialaccount_socialtoken" (
	"app_id"
);
CREATE UNIQUE INDEX IF NOT EXISTS "socialaccount_socialaccount_provider_uid_fc810c6e_uniq" ON "socialaccount_socialaccount" (
	"provider",
	"uid"
);
CREATE INDEX IF NOT EXISTS "socialaccount_socialaccount_user_id_8146e70c" ON "socialaccount_socialaccount" (
	"user_id"
);
CREATE INDEX IF NOT EXISTS "core_item_category_id_2fe5bbc8" ON "core_item" (
	"category_id"
);
CREATE INDEX IF NOT EXISTS "core_item_slug_07f502d0" ON "core_item" (
	"slug"
);
CREATE INDEX IF NOT EXISTS "products_slug_8f20884e" ON "products_product" (
	"slug"
);
CREATE INDEX IF NOT EXISTS "products_category_id_a7a3a156" ON "products_product" (
	"category_id"
);
COMMIT;
