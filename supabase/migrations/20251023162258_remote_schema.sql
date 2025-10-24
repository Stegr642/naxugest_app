


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE SCHEMA IF NOT EXISTS "naxugest";


ALTER SCHEMA "naxugest" OWNER TO "postgres";


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "unaccent" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE OR REPLACE FUNCTION "public"."immutable_unaccent"("text") RETURNS "text"
    LANGUAGE "sql" IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
  SELECT extensions.unaccent('extensions.unaccent'::regdictionary, $1)
$_$;


ALTER FUNCTION "public"."immutable_unaccent"("text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."produits_delete"("p_id_produit" bigint) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'naxugest', 'public'
    AS $$
BEGIN
  DELETE FROM naxugest.produits WHERE id_produit = p_id_produit;
END $$;


ALTER FUNCTION "public"."produits_delete"("p_id_produit" bigint) OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "naxugest"."produits" (
    "id_produit" bigint NOT NULL,
    "designation" "text" NOT NULL,
    "qte_stock" numeric(18,3),
    "qte_min" numeric(18,3),
    "prix_unitaire" numeric(18,2),
    "id_unite" bigint,
    "id_categorie" bigint,
    "code_produit" "text" GENERATED ALWAYS AS (((('['::"text" || "upper"("substr"(COALESCE("designation", ''::"text"), 1, 2))) || '] - '::"text") ||
CASE
    WHEN ("id_produit" < 10) THEN ('0'::"text" || ("id_produit")::"text")
    ELSE ("id_produit")::"text"
END)) STORED,
    CONSTRAINT "ck_prix_un_pos" CHECK ((("prix_unitaire" IS NULL) OR ("prix_unitaire" >= (0)::numeric))),
    CONSTRAINT "ck_qte_min_pos" CHECK ((("qte_min" IS NULL) OR ("qte_min" >= (0)::numeric))),
    CONSTRAINT "ck_qte_stock_pos" CHECK ((("qte_stock" IS NULL) OR ("qte_stock" >= (0)::numeric))),
    CONSTRAINT "produits_designation_nonempty" CHECK (("btrim"("designation") <> ''::"text"))
);


ALTER TABLE "naxugest"."produits" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."produits_upsert"("p_id_produit" bigint DEFAULT NULL::bigint, "p_designation" "text" DEFAULT NULL::"text", "p_qte_stock" numeric DEFAULT NULL::numeric, "p_qte_min" numeric DEFAULT NULL::numeric, "p_prix_unitaire" numeric DEFAULT NULL::numeric, "p_id_unite" bigint DEFAULT NULL::bigint, "p_id_categorie" bigint DEFAULT NULL::bigint) RETURNS "naxugest"."produits"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'naxugest', 'public'
    AS $$
DECLARE v_row naxugest.produits;
BEGIN
  IF p_id_produit IS NULL THEN
    INSERT INTO naxugest.produits(
      designation, qte_stock, qte_min, prix_unitaire, id_unite, id_categorie
    ) VALUES (
      p_designation, p_qte_stock, p_qte_min, p_prix_unitaire, p_id_unite, p_id_categorie
    ) RETURNING * INTO v_row;
  ELSE
    UPDATE naxugest.produits SET
      designation   = p_designation,
      qte_stock     = p_qte_stock,
      qte_min       = p_qte_min,
      prix_unitaire = p_prix_unitaire,
      id_unite      = p_id_unite,
      id_categorie  = p_id_categorie
    WHERE id_produit = p_id_produit
    RETURNING * INTO v_row;
  END IF;
  RETURN v_row;
END $$;


ALTER FUNCTION "public"."produits_upsert"("p_id_produit" bigint, "p_designation" "text", "p_qte_stock" numeric, "p_qte_min" numeric, "p_prix_unitaire" numeric, "p_id_unite" bigint, "p_id_categorie" bigint) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."unaccent_simple"("text") RETURNS "text"
    LANGUAGE "sql" IMMUTABLE STRICT PARALLEL SAFE
    AS $_$
  SELECT translate(
    $1,
    'ÀÁÂÃÄÅàáâãäåÈÉÊËèéêëÌÍÎÏìíîïÒÓÔÖÕØòóôöõøÙÚÛÜùúûüÇçÑñÝýÿŒœÆæŠšŽž',
    'AAAAAAaaaaaaEEEEeeeeIIIIiiiiOOOOOOooooooUUUUuuuuCcNnYyyOeoeAeaeSszZ'
  )
$_$;


ALTER FUNCTION "public"."unaccent_simple"("text") OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "naxugest"."categories" (
    "id_categorie" bigint NOT NULL,
    "lib_categorie" "text" NOT NULL
);


ALTER TABLE "naxugest"."categories" OWNER TO "postgres";


ALTER TABLE "naxugest"."categories" ALTER COLUMN "id_categorie" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "naxugest"."categories_id_categorie_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



ALTER TABLE "naxugest"."produits" ALTER COLUMN "id_produit" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "naxugest"."produits_id_produit_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "naxugest"."unites" (
    "id_unite" bigint NOT NULL,
    "lib_unite" "text" NOT NULL
);


ALTER TABLE "naxugest"."unites" OWNER TO "postgres";


ALTER TABLE "naxugest"."unites" ALTER COLUMN "id_unite" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "naxugest"."unites_id_unite_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "naxugest"."users" (
    "id_user" bigint NOT NULL,
    "login" "text" NOT NULL,
    "passe" "text" NOT NULL,
    "nom_user" "text"
);


ALTER TABLE "naxugest"."users" OWNER TO "postgres";


ALTER TABLE "naxugest"."users" ALTER COLUMN "id_user" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "naxugest"."users_id_user_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE OR REPLACE VIEW "naxugest"."v_produits" AS
 SELECT "p"."id_produit",
    "p"."code_produit",
    "p"."designation",
    "p"."qte_stock",
    "p"."qte_min",
    "p"."prix_unitaire",
    "p"."id_unite",
    "u"."lib_unite",
    "p"."id_categorie",
    "c"."lib_categorie"
   FROM (("naxugest"."produits" "p"
     LEFT JOIN "naxugest"."unites" "u" USING ("id_unite"))
     LEFT JOIN "naxugest"."categories" "c" USING ("id_categorie"))
  ORDER BY "p"."id_produit";


ALTER VIEW "naxugest"."v_produits" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."v_categories" AS
 SELECT "id_categorie",
    "lib_categorie"
   FROM "naxugest"."categories"
  ORDER BY "id_categorie";


ALTER VIEW "public"."v_categories" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."v_produits" AS
 SELECT "p"."id_produit",
    ((('['::"text" || "upper"("substr"(COALESCE("p"."designation", ''::"text"), 1, 2))) || '] - '::"text") ||
        CASE
            WHEN ("p"."id_produit" < 10) THEN ('0'::"text" || ("p"."id_produit")::"text")
            ELSE ("p"."id_produit")::"text"
        END) AS "code_produit",
    "p"."designation",
    "p"."qte_stock",
    "p"."qte_min",
    "p"."prix_unitaire",
    "p"."id_unite",
    "u"."lib_unite",
    "p"."id_categorie",
    "c"."lib_categorie",
    (("lower"("btrim"("p"."designation")) || ' '::"text") || "lower"("btrim"(COALESCE("c"."lib_categorie", ''::"text")))) AS "search_concat"
   FROM (("naxugest"."produits" "p"
     LEFT JOIN "naxugest"."unites" "u" ON (("u"."id_unite" = "p"."id_unite")))
     LEFT JOIN "naxugest"."categories" "c" ON (("c"."id_categorie" = "p"."id_categorie")));


ALTER VIEW "public"."v_produits" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."v_unites" AS
 SELECT "id_unite",
    "lib_unite"
   FROM "naxugest"."unites"
  ORDER BY "lib_unite";


ALTER VIEW "public"."v_unites" OWNER TO "postgres";


ALTER TABLE ONLY "naxugest"."categories"
    ADD CONSTRAINT "categories_lib_categorie_key" UNIQUE ("lib_categorie");



ALTER TABLE ONLY "naxugest"."categories"
    ADD CONSTRAINT "categories_pkey" PRIMARY KEY ("id_categorie");



ALTER TABLE ONLY "naxugest"."produits"
    ADD CONSTRAINT "produits_pkey" PRIMARY KEY ("id_produit");



ALTER TABLE ONLY "naxugest"."unites"
    ADD CONSTRAINT "unites_lib_unite_key" UNIQUE ("lib_unite");



ALTER TABLE ONLY "naxugest"."unites"
    ADD CONSTRAINT "unites_pkey" PRIMARY KEY ("id_unite");



ALTER TABLE ONLY "naxugest"."users"
    ADD CONSTRAINT "users_login_key" UNIQUE ("login");



ALTER TABLE ONLY "naxugest"."users"
    ADD CONSTRAINT "users_pkey" PRIMARY KEY ("id_user");



CREATE INDEX "idx_produits_categorie" ON "naxugest"."produits" USING "btree" ("id_categorie");



CREATE INDEX "idx_produits_unite" ON "naxugest"."produits" USING "btree" ("id_unite");



CREATE UNIQUE INDEX "produits_designation_uniq" ON "naxugest"."produits" USING "btree" ("lower"("public"."unaccent_simple"("btrim"("designation"))));



ALTER TABLE ONLY "naxugest"."produits"
    ADD CONSTRAINT "produits_id_categorie_fkey" FOREIGN KEY ("id_categorie") REFERENCES "naxugest"."categories"("id_categorie") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "naxugest"."produits"
    ADD CONSTRAINT "produits_id_unite_fkey" FOREIGN KEY ("id_unite") REFERENCES "naxugest"."unites"("id_unite") ON UPDATE CASCADE ON DELETE SET NULL;





ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";





































































































































































GRANT ALL ON FUNCTION "public"."immutable_unaccent"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."immutable_unaccent"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."immutable_unaccent"("text") TO "service_role";



GRANT ALL ON FUNCTION "public"."produits_delete"("p_id_produit" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."produits_delete"("p_id_produit" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."produits_delete"("p_id_produit" bigint) TO "service_role";



GRANT ALL ON FUNCTION "public"."produits_upsert"("p_id_produit" bigint, "p_designation" "text", "p_qte_stock" numeric, "p_qte_min" numeric, "p_prix_unitaire" numeric, "p_id_unite" bigint, "p_id_categorie" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."produits_upsert"("p_id_produit" bigint, "p_designation" "text", "p_qte_stock" numeric, "p_qte_min" numeric, "p_prix_unitaire" numeric, "p_id_unite" bigint, "p_id_categorie" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."produits_upsert"("p_id_produit" bigint, "p_designation" "text", "p_qte_stock" numeric, "p_qte_min" numeric, "p_prix_unitaire" numeric, "p_id_unite" bigint, "p_id_categorie" bigint) TO "service_role";



GRANT ALL ON FUNCTION "public"."unaccent_simple"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."unaccent_simple"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."unaccent_simple"("text") TO "service_role";


















GRANT ALL ON TABLE "public"."v_categories" TO "anon";
GRANT ALL ON TABLE "public"."v_categories" TO "authenticated";
GRANT ALL ON TABLE "public"."v_categories" TO "service_role";



GRANT ALL ON TABLE "public"."v_produits" TO "anon";
GRANT ALL ON TABLE "public"."v_produits" TO "authenticated";
GRANT ALL ON TABLE "public"."v_produits" TO "service_role";



GRANT ALL ON TABLE "public"."v_unites" TO "anon";
GRANT ALL ON TABLE "public"."v_unites" TO "authenticated";
GRANT ALL ON TABLE "public"."v_unites" TO "service_role";









ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";































RESET ALL;
