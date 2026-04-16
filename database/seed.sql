--
-- PostgreSQL database dump
--

\restrict hqKrfk5gBalpmH1LtOyG7osBa5iGJwCS89hDm1dAr1ScqSrTQ8FQ6tf9JpZHlco

-- Dumped from database version 18.1
-- Dumped by pg_dump version 18.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP DATABASE IF EXISTS med_diet_db;
--
-- Name: med_diet_db; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE med_diet_db WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Russian_Russia.1251';


ALTER DATABASE med_diet_db OWNER TO postgres;

\unrestrict hqKrfk5gBalpmH1LtOyG7osBa5iGJwCS89hDm1dAr1ScqSrTQ8FQ6tf9JpZHlco
\connect med_diet_db
\restrict hqKrfk5gBalpmH1LtOyG7osBa5iGJwCS89hDm1dAr1ScqSrTQ8FQ6tf9JpZHlco

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: diet_cooking_method_restrictions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.diet_cooking_method_restrictions (
    id integer NOT NULL,
    diet_id integer NOT NULL,
    cooking_method character varying(50) NOT NULL,
    status character varying(20) NOT NULL,
    is_hard boolean DEFAULT false NOT NULL,
    reason text,
    CONSTRAINT diet_cooking_method_restrictions_status_check CHECK (((status)::text = ANY ((ARRAY['allowed'::character varying, 'recommended'::character varying, 'forbidden'::character varying])::text[])))
);


ALTER TABLE public.diet_cooking_method_restrictions OWNER TO postgres;

--
-- Name: diet_cooking_method_restrictions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.diet_cooking_method_restrictions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.diet_cooking_method_restrictions_id_seq OWNER TO postgres;

--
-- Name: diet_cooking_method_restrictions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.diet_cooking_method_restrictions_id_seq OWNED BY public.diet_cooking_method_restrictions.id;


--
-- Name: diet_product_rules; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.diet_product_rules (
    diet_id integer NOT NULL,
    product_id integer NOT NULL,
    status character varying(20) NOT NULL,
    is_hard boolean DEFAULT false NOT NULL,
    reason text,
    CONSTRAINT diet_product_rules_status_check CHECK (((status)::text = ANY ((ARRAY['allowed'::character varying, 'forbidden'::character varying, 'recommended'::character varying])::text[])))
);


ALTER TABLE public.diet_product_rules OWNER TO postgres;

--
-- Name: diets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.diets (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    max_fat_percent double precision,
    max_carbs_percent double precision,
    max_salt_mg double precision,
    max_calories double precision
);


ALTER TABLE public.diets OWNER TO postgres;

--
-- Name: diets_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.diets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.diets_id_seq OWNER TO postgres;

--
-- Name: diets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.diets_id_seq OWNED BY public.diets.id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    id integer NOT NULL,
    name character varying(150) NOT NULL,
    category character varying(100),
    calories_per_100g double precision,
    protein_per_100g double precision,
    fat_per_100g double precision,
    carbs_per_100g double precision,
    salt_mg_per_100g double precision,
    glycemic_index double precision,
    is_spicy boolean DEFAULT false,
    is_acidic boolean DEFAULT false,
    is_saturated_fat boolean DEFAULT false
);


ALTER TABLE public.products OWNER TO postgres;

--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.products_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.products_id_seq OWNER TO postgres;

--
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.products_id_seq OWNED BY public.products.id;


--
-- Name: recipe_diets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.recipe_diets (
    recipe_id integer NOT NULL,
    diet_id integer NOT NULL
);


ALTER TABLE public.recipe_diets OWNER TO postgres;

--
-- Name: recipe_ingredients; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.recipe_ingredients (
    id integer NOT NULL,
    recipe_id integer NOT NULL,
    quantity double precision NOT NULL,
    unit character varying(50),
    product_id integer NOT NULL
);


ALTER TABLE public.recipe_ingredients OWNER TO postgres;

--
-- Name: recipe_ingredients_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.recipe_ingredients_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.recipe_ingredients_id_seq OWNER TO postgres;

--
-- Name: recipe_ingredients_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.recipe_ingredients_id_seq OWNED BY public.recipe_ingredients.id;


--
-- Name: recipe_nutrients_per_100g; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.recipe_nutrients_per_100g (
    recipe_id integer NOT NULL,
    kcal double precision,
    protein double precision,
    fat double precision,
    carbs double precision,
    sugar double precision,
    sodium_mg double precision
);


ALTER TABLE public.recipe_nutrients_per_100g OWNER TO postgres;

--
-- Name: recipes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.recipes (
    id integer NOT NULL,
    title character varying(200) NOT NULL,
    description text,
    cooking_method character varying(100),
    cooking_time integer,
    servings integer,
    instructions text
);


ALTER TABLE public.recipes OWNER TO postgres;

--
-- Name: recipes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.recipes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.recipes_id_seq OWNER TO postgres;

--
-- Name: recipes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.recipes_id_seq OWNED BY public.recipes.id;


--
-- Name: user_product_preferences; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_product_preferences (
    user_id integer NOT NULL,
    product_id integer NOT NULL,
    preference_type character varying(20) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT user_product_preferences_preference_type_check CHECK (((preference_type)::text = ANY ((ARRAY['excluded'::character varying, 'favorite'::character varying])::text[])))
);


ALTER TABLE public.user_product_preferences OWNER TO postgres;

--
-- Name: user_profiles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_profiles (
    user_id integer NOT NULL,
    low_sodium boolean DEFAULT false NOT NULL,
    low_sugar boolean DEFAULT false NOT NULL,
    low_fat boolean DEFAULT false NOT NULL,
    no_spicy boolean DEFAULT false NOT NULL,
    no_acidic boolean DEFAULT false NOT NULL,
    no_saturated_fat boolean DEFAULT false NOT NULL,
    target_kcal double precision,
    target_protein double precision,
    target_fat double precision,
    target_carbs double precision,
    target_sugar double precision,
    target_sodium_mg double precision,
    reference_mass_g_per_day double precision DEFAULT 2000
);


ALTER TABLE public.user_profiles OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    email character varying(150) NOT NULL,
    password_hash text NOT NULL,
    selected_diet_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: v_recipe_count_by_diet; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_recipe_count_by_diet AS
 SELECT d.id AS diet_id,
    d.name AS diet_name,
    count(rd.recipe_id) AS recipe_count
   FROM (public.diets d
     LEFT JOIN public.recipe_diets rd ON ((rd.diet_id = d.id)))
  GROUP BY d.id, d.name
  ORDER BY d.id;


ALTER VIEW public.v_recipe_count_by_diet OWNER TO postgres;

--
-- Name: v_recipe_diet_forbidden_conflicts; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_recipe_diet_forbidden_conflicts AS
 SELECT DISTINCT rd.recipe_id,
    r.title AS recipe_title,
    rd.diet_id,
    d.name AS diet_name,
    p.id AS product_id,
    p.name AS product_name,
    pr.status AS rule_status,
    pr.is_hard,
    pr.reason
   FROM (((((public.recipe_diets rd
     JOIN public.recipes r ON ((r.id = rd.recipe_id)))
     JOIN public.diets d ON ((d.id = rd.diet_id)))
     JOIN public.recipe_ingredients ri ON ((ri.recipe_id = rd.recipe_id)))
     JOIN public.products p ON ((p.id = ri.product_id)))
     JOIN public.diet_product_rules pr ON (((pr.diet_id = rd.diet_id) AND (pr.product_id = p.id))))
  WHERE ((pr.status)::text = 'forbidden'::text)
  ORDER BY rd.diet_id, rd.recipe_id, p.id;


ALTER VIEW public.v_recipe_diet_forbidden_conflicts OWNER TO postgres;

--
-- Name: v_recipe_diet_missing_rules; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_recipe_diet_missing_rules AS
 SELECT DISTINCT rd.recipe_id,
    r.title AS recipe_title,
    rd.diet_id,
    d.name AS diet_name,
    p.id AS product_id,
    p.name AS product_name
   FROM (((((public.recipe_diets rd
     JOIN public.recipes r ON ((r.id = rd.recipe_id)))
     JOIN public.diets d ON ((d.id = rd.diet_id)))
     JOIN public.recipe_ingredients ri ON ((ri.recipe_id = rd.recipe_id)))
     JOIN public.products p ON ((p.id = ri.product_id)))
     LEFT JOIN public.diet_product_rules pr ON (((pr.diet_id = rd.diet_id) AND (pr.product_id = p.id))))
  WHERE (pr.product_id IS NULL)
  ORDER BY rd.diet_id, rd.recipe_id, p.id;


ALTER VIEW public.v_recipe_diet_missing_rules OWNER TO postgres;

--
-- Name: v_recipes_without_nutrients; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_recipes_without_nutrients AS
 SELECT r.id,
    r.title
   FROM (public.recipes r
     LEFT JOIN public.recipe_nutrients_per_100g n ON ((n.recipe_id = r.id)))
  WHERE (n.recipe_id IS NULL)
  ORDER BY r.id;


ALTER VIEW public.v_recipes_without_nutrients OWNER TO postgres;

--
-- Name: diet_cooking_method_restrictions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diet_cooking_method_restrictions ALTER COLUMN id SET DEFAULT nextval('public.diet_cooking_method_restrictions_id_seq'::regclass);


--
-- Name: diets id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diets ALTER COLUMN id SET DEFAULT nextval('public.diets_id_seq'::regclass);


--
-- Name: products id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);


--
-- Name: recipe_ingredients id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recipe_ingredients ALTER COLUMN id SET DEFAULT nextval('public.recipe_ingredients_id_seq'::regclass);


--
-- Name: recipes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recipes ALTER COLUMN id SET DEFAULT nextval('public.recipes_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: diet_cooking_method_restrictions; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.diet_cooking_method_restrictions VALUES (2, 4, 'жарка', 'allowed', false, NULL);
INSERT INTO public.diet_cooking_method_restrictions VALUES (3, 3, 'жарка', 'allowed', false, NULL);
INSERT INTO public.diet_cooking_method_restrictions VALUES (1, 1, 'жарка', 'forbidden', true, 'Для гастро жарка исключается');
INSERT INTO public.diet_cooking_method_restrictions VALUES (10, 2, 'жарка', 'forbidden', true, 'Для печени жарка исключается');


--
-- Data for Name: diet_product_rules; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.diet_product_rules VALUES (1, 86, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 1, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 3, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 4, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 6, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 42, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 8, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 9, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 10, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 11, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 13, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 14, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 10, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 16, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 17, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 18, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 19, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 20, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 21, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 22, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 23, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 24, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 25, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 26, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 27, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 28, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 52, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 27, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 57, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 32, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 33, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 34, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 4, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 36, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 37, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 38, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 39, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 40, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 41, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 1, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 44, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 45, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 46, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 68, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 67, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 2, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 42, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 51, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 52, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 53, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 54, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 55, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 56, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 57, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 58, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 59, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 60, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 61, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 62, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 63, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 64, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 65, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 66, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 67, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 68, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 43, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 70, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 3, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 5, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 6, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 7, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 8, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 9, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 11, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 12, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 13, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 14, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 15, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 16, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 17, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 18, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 19, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 20, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 21, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 22, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 65, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 24, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 25, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 51, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 28, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 29, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 30, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 4, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 32, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 89, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 34, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 35, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 36, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 37, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 38, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 39, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 40, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 41, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 44, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 45, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 46, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 112, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 115, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 133, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 86, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 88, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 54, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 55, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 56, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 58, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 59, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 60, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 61, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 62, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 63, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 64, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 66, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 69, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 70, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 1, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 2, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 3, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 4, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 5, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 6, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 89, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 8, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 9, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 10, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 11, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 12, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 14, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 15, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 16, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 17, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 18, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 19, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 20, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 21, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 22, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 110, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 24, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 25, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 26, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 27, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 28, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 29, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 30, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 31, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 32, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 33, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 34, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 35, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 112, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 37, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 38, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 39, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 40, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 41, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 42, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 43, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 115, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 71, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 72, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 73, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 74, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 75, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 77, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 78, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 84, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 85, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 87, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 88, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 30, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 45, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 46, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 47, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 48, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 49, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 47, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 51, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 52, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 53, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 54, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 55, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 56, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 57, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 58, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 59, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 49, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 10, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 63, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 64, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 65, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 66, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 67, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 68, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 69, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 70, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 1, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 2, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 3, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 5, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 6, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 7, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 8, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 9, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 11, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 27, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 13, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 14, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 15, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 16, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 17, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 18, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 19, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 20, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 21, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 22, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 52, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 24, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 25, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 26, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 28, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 29, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 53, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 31, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 32, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 57, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 34, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 35, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 36, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 37, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 38, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 39, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 40, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 41, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 42, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 43, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 89, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 45, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 90, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 91, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 98, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 110, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 115, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 51, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 54, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 55, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 56, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 58, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 59, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 60, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 61, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 62, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 63, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 64, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 65, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 123, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 68, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 69, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 70, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 1, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 2, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 3, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 4, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 5, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 6, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 7, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 8, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 9, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 10, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 11, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 12, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 13, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 14, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 15, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 16, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 17, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 18, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 19, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 20, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 21, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 22, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 23, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 24, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 25, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 26, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 27, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 28, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 29, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 30, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 31, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 32, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 33, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 34, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 35, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 36, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 37, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 38, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 39, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 40, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 41, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 42, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 43, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 44, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 45, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 46, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 47, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 48, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 49, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 50, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 51, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 52, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 53, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 54, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 55, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 56, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 57, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 58, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 59, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 60, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 61, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 62, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 63, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 64, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 65, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 66, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 67, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 68, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 69, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 70, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 35, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 43, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 47, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 48, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 49, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 50, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 5, 'recommended', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 7, 'recommended', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 15, 'recommended', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 29, 'recommended', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 31, 'recommended', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 69, 'recommended', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 48, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 129, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 130, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 131, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 133, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 144, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 71, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 72, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 50, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 23, 'recommended', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 26, 'recommended', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 31, 'recommended', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 33, 'recommended', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 13, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 50, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 60, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 61, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 62, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 7, 'recommended', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 23, 'recommended', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 36, 'recommended', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 44, 'recommended', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 23, 'recommended', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 33, 'recommended', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 44, 'recommended', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 46, 'recommended', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 79, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 86, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 89, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 112, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 115, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 71, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 72, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 73, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 74, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 75, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 101, 'recommended', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 102, 'recommended', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 107, 'recommended', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 86, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (3, 112, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 77, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 78, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 79, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 84, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 85, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 86, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 87, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 88, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 89, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 90, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 91, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 98, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 110, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 112, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 115, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 123, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 129, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 130, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 131, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 133, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (5, 144, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 12, 'allowed', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 12, 'forbidden', true, 'Выраженно кислое');
INSERT INTO public.diet_product_rules VALUES (1, 2, 'forbidden', true, 'Острое');
INSERT INTO public.diet_product_rules VALUES (4, 66, 'forbidden', true, 'Очень высокий натрий');
INSERT INTO public.diet_product_rules VALUES (4, 48, 'forbidden', true, 'Маргарин');
INSERT INTO public.diet_product_rules VALUES (4, 50, 'forbidden', true, 'Алкоголь');
INSERT INTO public.diet_product_rules VALUES (1, 74, 'forbidden', true, 'Раздражающее для ЖКТ');
INSERT INTO public.diet_product_rules VALUES (1, 113, 'forbidden', true, 'Острое / раздражающее');
INSERT INTO public.diet_product_rules VALUES (4, 47, 'forbidden', true, 'Майонез');
INSERT INTO public.diet_product_rules VALUES (4, 98, 'forbidden', true, 'Жирное мясо');
INSERT INTO public.diet_product_rules VALUES (4, 137, 'forbidden', true, 'Жирный сыр');
INSERT INTO public.diet_product_rules VALUES (4, 138, 'forbidden', true, 'Жирный сыр');
INSERT INTO public.diet_product_rules VALUES (1, 77, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 104, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (1, 79, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 98, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 53, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 137, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 138, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 113, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 131, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 146, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 79, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 104, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 78, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 77, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 94, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (2, 149, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 67, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 49, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 30, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 113, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 131, 'forbidden', false, NULL);
INSERT INTO public.diet_product_rules VALUES (4, 146, 'forbidden', false, NULL);


--
-- Data for Name: diets; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.diets VALUES (1, 'Гастроэнтерологическая', 'Щадящая диета для ЖКТ', 30, 55, 2000, 2200);
INSERT INTO public.diets VALUES (2, 'Гепатопротекторная', 'Диета при заболеваниях печени', 25, 60, 1800, 2300);
INSERT INTO public.diets VALUES (3, 'Диабетическая', 'Контроль углеводов и сахара', 30, 45, 2000, 2000);
INSERT INTO public.diets VALUES (4, 'Сердечно-сосудистая', 'Ограничение соли и насыщенных жиров', 25, 55, 1500, 2100);
INSERT INTO public.diets VALUES (5, 'Базовая', 'Общий режим питания', 35, 60, 2500, 2500);


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.products VALUES (1, 'Оливковое масло', 'Жиры', 884, 0, 100, 0, 2, 0, false, false, true);
INSERT INTO public.products VALUES (2, 'Перец чили', 'Овощи', 40, 2, 0.4, 9, 7, 15, true, false, false);
INSERT INTO public.products VALUES (3, 'Лук репчатый', 'Овощи', 40, 1.1, 0.1, 9, 4, 10, false, false, false);
INSERT INTO public.products VALUES (4, 'Сливочное масло', 'Жиры', 717, 0.9, 81, 0.1, 11, 0, false, false, true);
INSERT INTO public.products VALUES (5, 'Молоко 2.5%', 'Молочные', 52, 3.2, 2.5, 4.8, 44, 30, false, false, false);
INSERT INTO public.products VALUES (6, 'Овсяные хлопья (сухие)', 'Крупы', 370, 13, 7, 60, 2, 55, false, false, false);
INSERT INTO public.products VALUES (7, 'Кабачок', 'Овощи', 17, 1.2, 0.3, 3, 8, 15, false, false, false);
INSERT INTO public.products VALUES (8, 'Картофель', 'Овощи', 77, 2, 0.1, 17, 6, 80, false, false, false);
INSERT INTO public.products VALUES (9, 'Гречка (сухая)', 'Крупы', 343, 13, 3.4, 72, 2, 50, false, false, false);
INSERT INTO public.products VALUES (10, 'Говядина', 'Мясо', 187, 18.9, 12.4, 0, 72, 0, false, false, true);
INSERT INTO public.products VALUES (11, 'Яйцо', 'Яйца', 143, 12.6, 9.5, 0.7, 124, 0, false, false, true);
INSERT INTO public.products VALUES (12, 'Лимон', 'Фрукты', 29, 1.1, 0.3, 9, 2, 25, false, true, false);
INSERT INTO public.products VALUES (13, 'Сахар', 'Подсластители', 387, 0, 0, 100, 1, 100, false, false, false);
INSERT INTO public.products VALUES (14, 'Рис (сухой)', 'Крупы', 360, 7, 0.6, 78, 1, 70, false, false, false);
INSERT INTO public.products VALUES (15, 'Куриная грудка', 'Мясо', 120, 22, 2.6, 0, 70, 0, false, false, false);
INSERT INTO public.products VALUES (16, 'Морковь', 'Овощи', 41, 1, 0.2, 10, 69, 35, false, false, false);
INSERT INTO public.products VALUES (17, 'Треска', 'Рыба', 82, 18, 0.7, 0, 60, 0, false, false, false);
INSERT INTO public.products VALUES (18, 'Брокколи', 'Овощи', 34, 2.8, 0.4, 7, 33, 10, false, false, false);
INSERT INTO public.products VALUES (19, 'Творог 5%', 'Молочные', 121, 16, 5, 3, 40, 30, false, false, false);
INSERT INTO public.products VALUES (20, 'Йогурт натуральный', 'Молочные', 60, 10, 0.4, 3.6, 36, 35, false, false, false);
INSERT INTO public.products VALUES (21, 'Индейка', 'Мясо', 135, 21, 5, 0, 65, 0, false, false, false);
INSERT INTO public.products VALUES (22, 'Кролик', 'Мясо', 173, 21, 8, 0, 40, 0, false, false, true);
INSERT INTO public.products VALUES (23, 'Лосось', 'Рыба', 208, 20, 13, 0, 60, 0, false, false, true);
INSERT INTO public.products VALUES (24, 'Тунец', 'Рыба', 144, 23, 4.9, 0, 45, 0, false, false, false);
INSERT INTO public.products VALUES (25, 'Форель', 'Рыба', 190, 20.5, 11.5, 0, 55, 0, false, false, true);
INSERT INTO public.products VALUES (26, 'Кефир', 'Молочные', 53, 3, 2.5, 4, 45, 35, false, false, false);
INSERT INTO public.products VALUES (27, 'Сметана', 'Молочные', 206, 2.5, 20, 3.5, 70, 30, false, false, true);
INSERT INTO public.products VALUES (28, 'Сыр нежирный', 'Молочные', 250, 25, 15, 2, 800, 30, false, false, true);
INSERT INTO public.products VALUES (29, 'Огурец', 'Овощи', 15, 0.7, 0.1, 3, 5, 15, false, false, false);
INSERT INTO public.products VALUES (30, 'Помидор', 'Овощи', 18, 0.9, 0.2, 3.9, 5, 30, false, true, false);
INSERT INTO public.products VALUES (31, 'Свекла', 'Овощи', 43, 1.6, 0.2, 9.6, 55, 65, false, false, false);
INSERT INTO public.products VALUES (32, 'Капуста', 'Овощи', 25, 1.3, 0.1, 5.8, 15, 15, false, false, false);
INSERT INTO public.products VALUES (33, 'Шпинат', 'Овощи', 23, 2.9, 0.4, 3.6, 80, 15, false, false, false);
INSERT INTO public.products VALUES (34, 'Тыква', 'Овощи', 26, 1, 0.1, 6.5, 4, 65, false, false, false);
INSERT INTO public.products VALUES (35, 'Баклажан', 'Овощи', 25, 1, 0.2, 5.7, 3, 20, false, false, false);
INSERT INTO public.products VALUES (36, 'Яблоко', 'Фрукты', 52, 0.3, 0.2, 14, 1, 35, false, true, false);
INSERT INTO public.products VALUES (37, 'Груша', 'Фрукты', 57, 0.4, 0.3, 15, 1, 35, false, false, false);
INSERT INTO public.products VALUES (38, 'Черника', 'Ягоды', 57, 0.7, 0.3, 14.5, 1, 40, false, false, false);
INSERT INTO public.products VALUES (39, 'Клубника', 'Ягоды', 32, 0.7, 0.3, 7.7, 1, 40, false, true, false);
INSERT INTO public.products VALUES (40, 'Булгур', 'Крупы', 342, 12, 1.3, 76, 5, 45, false, false, false);
INSERT INTO public.products VALUES (41, 'Киноа', 'Крупы', 368, 14, 6, 64, 5, 50, false, false, false);
INSERT INTO public.products VALUES (42, 'Перловка', 'Крупы', 315, 9.3, 1.1, 67, 5, 30, false, false, false);
INSERT INTO public.products VALUES (43, 'Чечевица', 'Бобовые', 353, 25, 1.1, 60, 5, 30, false, false, false);
INSERT INTO public.products VALUES (44, 'Миндаль', 'Орехи', 579, 21, 50, 22, 1, 15, false, false, true);
INSERT INTO public.products VALUES (45, 'Грецкий орех', 'Орехи', 654, 15, 65, 14, 2, 15, false, false, true);
INSERT INTO public.products VALUES (46, 'Льняное масло', 'Жиры', 884, 0, 100, 0, 0, 0, false, false, true);
INSERT INTO public.products VALUES (47, 'Майонез', 'Соусы', 680, 1, 75, 2.5, 800, 10, false, false, true);
INSERT INTO public.products VALUES (48, 'Маргарин', 'Жиры', 720, 0, 80, 0.5, 800, 0, false, false, true);
INSERT INTO public.products VALUES (49, 'Колбаса', 'Мясо', 300, 12, 28, 1.5, 1200, 0, false, false, true);
INSERT INTO public.products VALUES (50, 'Алкоголь', 'Напитки', 70, 0, 0, 0, 5, 15, false, true, false);
INSERT INTO public.products VALUES (51, 'Шампиньоны', 'Грибы', 22, 3.1, 0.3, 3.3, 5, 10, false, false, false);
INSERT INTO public.products VALUES (52, 'Сливки 10%', 'Молочные', 118, 2.8, 10, 4, 50, 30, false, false, true);
INSERT INTO public.products VALUES (53, 'Сливки 20%', 'Молочные', 205, 2.5, 20, 3.5, 55, 30, false, false, true);
INSERT INTO public.products VALUES (54, 'Паста', 'Крупы', 350, 12, 1.5, 70, 3, 50, false, false, false);
INSERT INTO public.products VALUES (55, 'Петрушка', 'Зелень', 36, 3, 0.8, 6, 50, 15, false, false, false);
INSERT INTO public.products VALUES (56, 'Укроп', 'Зелень', 43, 3.5, 1.1, 7, 61, 15, false, false, false);
INSERT INTO public.products VALUES (57, 'Сыр пармезан', 'Молочные', 431, 38, 29, 4, 1600, 20, false, false, true);
INSERT INTO public.products VALUES (58, 'Хлеб цельнозерновой', 'Хлеб', 247, 9, 3.5, 45, 500, 45, false, false, false);
INSERT INTO public.products VALUES (59, 'Хлеб белый', 'Хлеб', 265, 8, 3, 50, 500, 70, false, false, false);
INSERT INTO public.products VALUES (60, 'Мёд', 'Подсластители', 304, 0.3, 0, 82, 4, 60, false, false, false);
INSERT INTO public.products VALUES (61, 'Изюм', 'Сухофрукты', 299, 3.1, 0.5, 79, 11, 65, false, false, false);
INSERT INTO public.products VALUES (62, 'Курага', 'Сухофрукты', 241, 3.4, 0.5, 63, 25, 55, false, false, false);
INSERT INTO public.products VALUES (63, 'Кукуруза', 'Овощи', 86, 3.2, 1.2, 19, 1, 55, false, false, false);
INSERT INTO public.products VALUES (64, 'Зелёный горошек', 'Овощи', 81, 5.4, 0.4, 14, 2, 45, false, false, false);
INSERT INTO public.products VALUES (65, 'Фасоль', 'Бобовые', 333, 21, 1.5, 60, 5, 30, false, false, false);
INSERT INTO public.products VALUES (66, 'Соевый соус', 'Соусы', 53, 8.1, 0, 4.9, 5500, 15, false, false, false);
INSERT INTO public.products VALUES (67, 'Кетчуп', 'Соусы', 110, 1.5, 0.2, 27, 1100, 45, false, true, false);
INSERT INTO public.products VALUES (68, 'Растительное масло', 'Жиры', 884, 0, 100, 0, 0, 0, false, false, true);
INSERT INTO public.products VALUES (69, 'Куриный бульон', 'Прочее', 10, 1, 0.5, 0.5, 350, 0, false, false, false);
INSERT INTO public.products VALUES (70, 'Говяжий бульон', 'Прочее', 12, 1.2, 0.6, 0.6, 380, 0, false, false, false);
INSERT INTO public.products VALUES (71, 'Кокосовое молоко', 'Молочные', 230, 2.3, 23.8, 5.5, 15, 40, false, false, true);
INSERT INTO public.products VALUES (72, 'Рисовая лапша', 'Крупы', 364, 5, 1, 81, 10, 60, false, false, false);
INSERT INTO public.products VALUES (73, 'Соус терияки', 'Соусы', 89, 4.5, 0, 18, 4300, 20, false, false, false);
INSERT INTO public.products VALUES (74, 'Имбирь', 'Овощи', 80, 1.8, 0.8, 18, 13, 15, true, true, false);
INSERT INTO public.products VALUES (75, 'Лайм', 'Фрукты', 30, 0.7, 0.2, 11, 2, 30, false, true, false);
INSERT INTO public.products VALUES (76, 'Кунжут', 'Семена', 573, 17.7, 49.7, 23.5, 11, 35, false, false, true);
INSERT INTO public.products VALUES (77, 'Тофу', 'Бобовые', 76, 8.1, 4.8, 1.9, 7, 15, false, false, false);
INSERT INTO public.products VALUES (78, 'Нут', 'Бобовые', 364, 19, 6, 61, 24, 35, false, false, false);
INSERT INTO public.products VALUES (79, 'Кукурузная крупа', 'Крупы', 365, 8.3, 1.2, 78, 2, 70, false, false, false);
INSERT INTO public.products VALUES (80, 'Полента', 'Крупы', 370, 8, 1.5, 80, 2, 70, false, false, false);
INSERT INTO public.products VALUES (81, 'Сливочный сыр', 'Молочные', 342, 6, 34, 4, 350, 30, false, false, true);
INSERT INTO public.products VALUES (82, 'Моцарелла', 'Молочные', 280, 22, 20, 2.2, 600, 30, false, false, true);
INSERT INTO public.products VALUES (83, 'Рикотта', 'Молочные', 174, 11, 13, 3, 100, 30, false, false, true);
INSERT INTO public.products VALUES (84, 'Креветки', 'Морепродукты', 99, 24, 0.5, 0, 170, 0, false, false, false);
INSERT INTO public.products VALUES (85, 'Мидии', 'Морепродукты', 86, 12, 2, 3, 200, 0, false, false, false);
INSERT INTO public.products VALUES (86, 'Цукини', 'Овощи', 17, 1.2, 0.3, 3.1, 8, 15, false, false, false);
INSERT INTO public.products VALUES (87, 'Руккола', 'Зелень', 25, 2.6, 0.7, 3.7, 45, 15, true, false, false);
INSERT INTO public.products VALUES (88, 'Авокадо', 'Фрукты', 160, 2, 15, 9, 7, 15, false, false, true);
INSERT INTO public.products VALUES (89, 'Томатный соус', 'Соусы', 50, 1.5, 0.5, 10, 450, 35, false, true, false);
INSERT INTO public.products VALUES (90, 'Базилик', 'Зелень', 44, 3.2, 0.6, 8, 5, 10, false, false, false);
INSERT INTO public.products VALUES (91, 'Орегано', 'Зелень', 265, 9, 4.3, 68, 10, 10, false, false, false);
INSERT INTO public.products VALUES (92, 'Лаваш', 'Хлеб', 275, 9, 1, 55, 450, 65, false, false, false);
INSERT INTO public.products VALUES (93, 'Тортилья', 'Хлеб', 300, 8, 7, 50, 400, 65, false, false, true);
INSERT INTO public.products VALUES (94, 'Грибы вешенки', 'Грибы', 33, 3.3, 0.4, 6, 10, 10, false, false, false);
INSERT INTO public.products VALUES (95, 'Сыр фета', 'Молочные', 264, 14, 21, 4, 1100, 20, false, false, true);
INSERT INTO public.products VALUES (96, 'Гранат', 'Фрукты', 83, 1.7, 1.2, 19, 3, 35, false, true, false);
INSERT INTO public.products VALUES (97, 'Кабачковая икра', 'Прочее', 97, 1.2, 7, 8, 450, 20, false, false, false);
INSERT INTO public.products VALUES (98, 'Куриные бёдра', 'Мясо', 210, 18, 15, 0, 80, 0, false, false, true);
INSERT INTO public.products VALUES (99, 'Филе индейки', 'Мясо', 120, 24, 2, 0, 60, 0, false, false, false);
INSERT INTO public.products VALUES (100, 'Пекинская капуста', 'Овощи', 16, 1.2, 0.2, 3, 20, 15, false, false, false);
INSERT INTO public.products VALUES (101, 'Чиа', 'Семена', 486, 16.5, 30.7, 42.1, 5, 15, false, false, true);
INSERT INTO public.products VALUES (102, 'Льняные семена', 'Семена', 534, 18.3, 42.2, 28.9, 30, 15, false, false, true);
INSERT INTO public.products VALUES (103, 'Финики', 'Сухофрукты', 282, 2.5, 0.4, 75, 1, 70, false, false, false);
INSERT INTO public.products VALUES (104, 'Ячневая крупа', 'Крупы', 315, 10, 1.3, 65, 5, 35, false, false, false);
INSERT INTO public.products VALUES (105, 'Крабовое мясо', 'Морепродукты', 87, 18, 1, 0, 400, 0, false, false, false);
INSERT INTO public.products VALUES (106, 'Куриное яйцо перепелиное', 'Яйца', 158, 13, 11, 0.6, 140, 0, false, false, true);
INSERT INTO public.products VALUES (107, 'Тыквенные семечки', 'Семена', 559, 30, 49, 11, 7, 25, false, false, true);
INSERT INTO public.products VALUES (108, 'Какао', 'Подсластители', 228, 20, 14, 58, 5, 20, false, false, false);
INSERT INTO public.products VALUES (109, 'Кокосовое масло', 'Жиры', 862, 0, 100, 0, 0, 0, false, false, true);
INSERT INTO public.products VALUES (110, 'Салат айсберг', 'Овощи', 14, 0.9, 0.1, 2.9, 10, 15, false, false, false);
INSERT INTO public.products VALUES (111, 'Сельдерей', 'Овощи', 16, 0.7, 0.2, 3, 80, 15, false, false, false);
INSERT INTO public.products VALUES (112, 'Перец болгарский', 'Овощи', 31, 1, 0.3, 6, 2, 35, false, false, false);
INSERT INTO public.products VALUES (113, 'Горчица', 'Соусы', 66, 4, 3, 6, 1100, 20, true, true, false);
INSERT INTO public.products VALUES (114, 'Йогурт греческий', 'Молочные', 59, 10, 0.4, 3.6, 35, 35, false, false, false);
INSERT INTO public.products VALUES (115, 'Куриный фарш', 'Мясо', 160, 18, 9, 0, 70, 0, false, false, true);
INSERT INTO public.products VALUES (116, 'Говяжий фарш', 'Мясо', 250, 17, 20, 0, 75, 0, false, false, true);
INSERT INTO public.products VALUES (117, 'Киноа варёная', 'Крупы', 120, 4.4, 1.9, 21.3, 5, 50, false, false, false);
INSERT INTO public.products VALUES (118, 'Рис бурый', 'Крупы', 370, 7.5, 2.5, 75, 3, 50, false, false, false);
INSERT INTO public.products VALUES (119, 'Паста цельнозерновая', 'Крупы', 350, 13, 2, 68, 5, 45, false, false, false);
INSERT INTO public.products VALUES (120, 'Соус песто', 'Соусы', 490, 5, 50, 6, 800, 15, false, false, true);
INSERT INTO public.products VALUES (121, 'Мед горный', 'Подсластители', 304, 0.3, 0, 82, 4, 60, false, false, false);
INSERT INTO public.products VALUES (122, 'Киви', 'Фрукты', 61, 1.1, 0.5, 14.7, 3, 50, false, true, false);
INSERT INTO public.products VALUES (123, 'Манго', 'Фрукты', 60, 0.8, 0.4, 15, 1, 55, false, false, false);
INSERT INTO public.products VALUES (124, 'Ананас', 'Фрукты', 50, 0.5, 0.1, 13, 1, 60, false, true, false);
INSERT INTO public.products VALUES (125, 'Голубика', 'Ягоды', 57, 0.7, 0.3, 14.5, 1, 40, false, false, false);
INSERT INTO public.products VALUES (126, 'Ежевика', 'Ягоды', 43, 1.4, 0.5, 10, 1, 40, false, false, false);
INSERT INTO public.products VALUES (127, 'Персик', 'Фрукты', 39, 0.9, 0.3, 9.5, 1, 35, false, false, false);
INSERT INTO public.products VALUES (128, 'Абрикос', 'Фрукты', 48, 1.4, 0.4, 11, 1, 35, false, false, false);
INSERT INTO public.products VALUES (129, 'Кальмар', 'Морепродукты', 92, 15, 1.4, 3.1, 200, 0, false, false, false);
INSERT INTO public.products VALUES (130, 'Лапша удон', 'Крупы', 138, 4, 0.5, 29, 500, 55, false, false, false);
INSERT INTO public.products VALUES (131, 'Соус карри', 'Соусы', 120, 1.5, 8, 10, 1200, 30, true, false, false);
INSERT INTO public.products VALUES (132, 'Куриный соус азиатский', 'Соусы', 90, 5, 2, 15, 2000, 20, false, false, false);
INSERT INTO public.products VALUES (133, 'Капуста брокколи замороженная', 'Овощи', 34, 2.8, 0.4, 7, 33, 10, false, false, false);
INSERT INTO public.products VALUES (134, 'Фасоль стручковая', 'Овощи', 31, 1.8, 0.2, 7, 5, 30, false, false, false);
INSERT INTO public.products VALUES (135, 'Кукуруза консервированная', 'Овощи', 86, 3.2, 1.2, 19, 250, 55, false, false, false);
INSERT INTO public.products VALUES (136, 'Томат черри', 'Овощи', 18, 0.9, 0.2, 3.9, 5, 30, false, true, false);
INSERT INTO public.products VALUES (137, 'Сыр гауда', 'Молочные', 356, 25, 27, 2, 800, 20, false, false, true);
INSERT INTO public.products VALUES (138, 'Сыр чеддер', 'Молочные', 404, 25, 33, 1.3, 620, 20, false, false, true);
INSERT INTO public.products VALUES (139, 'Сметана 10%', 'Молочные', 115, 2.5, 10, 3, 50, 30, false, false, true);
INSERT INTO public.products VALUES (140, 'Сметана 20%', 'Молочные', 206, 2.5, 20, 3.5, 70, 30, false, false, true);
INSERT INTO public.products VALUES (141, 'Йогурт питьевой', 'Молочные', 70, 3, 1.5, 11, 50, 35, false, false, false);
INSERT INTO public.products VALUES (142, 'Кефир 1%', 'Молочные', 40, 3, 1, 4, 45, 35, false, false, false);
INSERT INTO public.products VALUES (143, 'Кефир 3.2%', 'Молочные', 60, 3, 3.2, 4, 45, 35, false, false, false);
INSERT INTO public.products VALUES (144, 'Оливки', 'Овощи', 115, 0.8, 10.7, 6.3, 1600, 15, false, false, true);
INSERT INTO public.products VALUES (145, 'Маслины', 'Овощи', 145, 1, 15.3, 3.8, 1800, 15, false, false, true);
INSERT INTO public.products VALUES (146, 'Соус чесночный', 'Соусы', 150, 2, 10, 12, 1200, 20, true, false, false);
INSERT INTO public.products VALUES (147, 'Соус сырный', 'Соусы', 250, 8, 20, 8, 900, 25, false, false, true);
INSERT INTO public.products VALUES (148, 'Куриные крылья', 'Мясо', 203, 18, 15, 0, 80, 0, false, false, true);
INSERT INTO public.products VALUES (149, 'Грибы лесные', 'Грибы', 25, 3, 0.5, 4, 5, 10, false, false, false);
INSERT INTO public.products VALUES (150, 'Сливки 33%', 'Молочные', 330, 2.2, 33, 3, 55, 30, false, false, true);


--
-- Data for Name: recipe_diets; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.recipe_diets VALUES (31, 3);
INSERT INTO public.recipe_diets VALUES (31, 5);
INSERT INTO public.recipe_diets VALUES (32, 3);
INSERT INTO public.recipe_diets VALUES (32, 5);
INSERT INTO public.recipe_diets VALUES (33, 3);
INSERT INTO public.recipe_diets VALUES (33, 5);
INSERT INTO public.recipe_diets VALUES (34, 3);
INSERT INTO public.recipe_diets VALUES (34, 4);
INSERT INTO public.recipe_diets VALUES (34, 5);
INSERT INTO public.recipe_diets VALUES (35, 3);
INSERT INTO public.recipe_diets VALUES (35, 5);
INSERT INTO public.recipe_diets VALUES (36, 3);
INSERT INTO public.recipe_diets VALUES (36, 5);
INSERT INTO public.recipe_diets VALUES (37, 3);
INSERT INTO public.recipe_diets VALUES (37, 5);
INSERT INTO public.recipe_diets VALUES (38, 3);
INSERT INTO public.recipe_diets VALUES (38, 5);
INSERT INTO public.recipe_diets VALUES (39, 3);
INSERT INTO public.recipe_diets VALUES (39, 5);
INSERT INTO public.recipe_diets VALUES (40, 3);
INSERT INTO public.recipe_diets VALUES (40, 5);
INSERT INTO public.recipe_diets VALUES (51, 3);
INSERT INTO public.recipe_diets VALUES (51, 4);
INSERT INTO public.recipe_diets VALUES (51, 5);
INSERT INTO public.recipe_diets VALUES (52, 3);
INSERT INTO public.recipe_diets VALUES (52, 4);
INSERT INTO public.recipe_diets VALUES (52, 5);
INSERT INTO public.recipe_diets VALUES (53, 3);
INSERT INTO public.recipe_diets VALUES (53, 4);
INSERT INTO public.recipe_diets VALUES (83, 1);
INSERT INTO public.recipe_diets VALUES (83, 2);
INSERT INTO public.recipe_diets VALUES (83, 3);
INSERT INTO public.recipe_diets VALUES (83, 4);
INSERT INTO public.recipe_diets VALUES (83, 5);
INSERT INTO public.recipe_diets VALUES (85, 2);
INSERT INTO public.recipe_diets VALUES (85, 3);
INSERT INTO public.recipe_diets VALUES (85, 5);
INSERT INTO public.recipe_diets VALUES (86, 3);
INSERT INTO public.recipe_diets VALUES (86, 4);
INSERT INTO public.recipe_diets VALUES (86, 5);
INSERT INTO public.recipe_diets VALUES (87, 1);
INSERT INTO public.recipe_diets VALUES (87, 2);
INSERT INTO public.recipe_diets VALUES (87, 3);
INSERT INTO public.recipe_diets VALUES (87, 4);
INSERT INTO public.recipe_diets VALUES (87, 5);
INSERT INTO public.recipe_diets VALUES (88, 3);
INSERT INTO public.recipe_diets VALUES (88, 5);
INSERT INTO public.recipe_diets VALUES (89, 2);
INSERT INTO public.recipe_diets VALUES (89, 3);
INSERT INTO public.recipe_diets VALUES (89, 5);
INSERT INTO public.recipe_diets VALUES (90, 3);
INSERT INTO public.recipe_diets VALUES (90, 4);
INSERT INTO public.recipe_diets VALUES (90, 5);
INSERT INTO public.recipe_diets VALUES (60, 3);
INSERT INTO public.recipe_diets VALUES (60, 5);
INSERT INTO public.recipe_diets VALUES (84, 3);
INSERT INTO public.recipe_diets VALUES (84, 5);
INSERT INTO public.recipe_diets VALUES (58, 4);
INSERT INTO public.recipe_diets VALUES (53, 5);
INSERT INTO public.recipe_diets VALUES (54, 1);
INSERT INTO public.recipe_diets VALUES (54, 2);
INSERT INTO public.recipe_diets VALUES (54, 3);
INSERT INTO public.recipe_diets VALUES (54, 4);
INSERT INTO public.recipe_diets VALUES (54, 5);
INSERT INTO public.recipe_diets VALUES (55, 3);
INSERT INTO public.recipe_diets VALUES (55, 5);
INSERT INTO public.recipe_diets VALUES (59, 1);
INSERT INTO public.recipe_diets VALUES (59, 2);
INSERT INTO public.recipe_diets VALUES (59, 3);
INSERT INTO public.recipe_diets VALUES (59, 4);
INSERT INTO public.recipe_diets VALUES (59, 5);
INSERT INTO public.recipe_diets VALUES (58, 5);
INSERT INTO public.recipe_diets VALUES (75, 3);
INSERT INTO public.recipe_diets VALUES (75, 4);
INSERT INTO public.recipe_diets VALUES (75, 5);
INSERT INTO public.recipe_diets VALUES (56, 3);
INSERT INTO public.recipe_diets VALUES (56, 5);
INSERT INTO public.recipe_diets VALUES (61, 3);
INSERT INTO public.recipe_diets VALUES (61, 5);
INSERT INTO public.recipe_diets VALUES (99, 3);
INSERT INTO public.recipe_diets VALUES (99, 5);
INSERT INTO public.recipe_diets VALUES (10, 1);
INSERT INTO public.recipe_diets VALUES (10, 2);
INSERT INTO public.recipe_diets VALUES (10, 3);
INSERT INTO public.recipe_diets VALUES (10, 4);
INSERT INTO public.recipe_diets VALUES (10, 5);
INSERT INTO public.recipe_diets VALUES (82, 3);
INSERT INTO public.recipe_diets VALUES (82, 5);
INSERT INTO public.recipe_diets VALUES (62, 3);
INSERT INTO public.recipe_diets VALUES (62, 4);
INSERT INTO public.recipe_diets VALUES (62, 5);
INSERT INTO public.recipe_diets VALUES (42, 1);
INSERT INTO public.recipe_diets VALUES (42, 3);
INSERT INTO public.recipe_diets VALUES (42, 4);
INSERT INTO public.recipe_diets VALUES (42, 5);
INSERT INTO public.recipe_diets VALUES (81, 3);
INSERT INTO public.recipe_diets VALUES (81, 5);
INSERT INTO public.recipe_diets VALUES (63, 3);
INSERT INTO public.recipe_diets VALUES (63, 4);
INSERT INTO public.recipe_diets VALUES (63, 5);
INSERT INTO public.recipe_diets VALUES (64, 3);
INSERT INTO public.recipe_diets VALUES (64, 4);
INSERT INTO public.recipe_diets VALUES (64, 5);
INSERT INTO public.recipe_diets VALUES (66, 1);
INSERT INTO public.recipe_diets VALUES (66, 2);
INSERT INTO public.recipe_diets VALUES (66, 3);
INSERT INTO public.recipe_diets VALUES (66, 4);
INSERT INTO public.recipe_diets VALUES (66, 5);
INSERT INTO public.recipe_diets VALUES (67, 3);
INSERT INTO public.recipe_diets VALUES (67, 5);
INSERT INTO public.recipe_diets VALUES (68, 2);
INSERT INTO public.recipe_diets VALUES (68, 3);
INSERT INTO public.recipe_diets VALUES (68, 5);
INSERT INTO public.recipe_diets VALUES (70, 1);
INSERT INTO public.recipe_diets VALUES (70, 2);
INSERT INTO public.recipe_diets VALUES (70, 3);
INSERT INTO public.recipe_diets VALUES (70, 4);
INSERT INTO public.recipe_diets VALUES (70, 5);
INSERT INTO public.recipe_diets VALUES (41, 2);
INSERT INTO public.recipe_diets VALUES (41, 3);
INSERT INTO public.recipe_diets VALUES (41, 5);
INSERT INTO public.recipe_diets VALUES (43, 3);
INSERT INTO public.recipe_diets VALUES (43, 4);
INSERT INTO public.recipe_diets VALUES (43, 5);
INSERT INTO public.recipe_diets VALUES (45, 3);
INSERT INTO public.recipe_diets VALUES (45, 4);
INSERT INTO public.recipe_diets VALUES (45, 5);
INSERT INTO public.recipe_diets VALUES (46, 3);
INSERT INTO public.recipe_diets VALUES (46, 4);
INSERT INTO public.recipe_diets VALUES (46, 5);
INSERT INTO public.recipe_diets VALUES (47, 2);
INSERT INTO public.recipe_diets VALUES (91, 3);
INSERT INTO public.recipe_diets VALUES (91, 4);
INSERT INTO public.recipe_diets VALUES (91, 5);
INSERT INTO public.recipe_diets VALUES (92, 3);
INSERT INTO public.recipe_diets VALUES (92, 4);
INSERT INTO public.recipe_diets VALUES (92, 5);
INSERT INTO public.recipe_diets VALUES (93, 3);
INSERT INTO public.recipe_diets VALUES (93, 5);
INSERT INTO public.recipe_diets VALUES (94, 2);
INSERT INTO public.recipe_diets VALUES (94, 3);
INSERT INTO public.recipe_diets VALUES (94, 5);
INSERT INTO public.recipe_diets VALUES (96, 3);
INSERT INTO public.recipe_diets VALUES (96, 5);
INSERT INTO public.recipe_diets VALUES (1, 1);
INSERT INTO public.recipe_diets VALUES (1, 2);
INSERT INTO public.recipe_diets VALUES (1, 3);
INSERT INTO public.recipe_diets VALUES (1, 4);
INSERT INTO public.recipe_diets VALUES (1, 5);
INSERT INTO public.recipe_diets VALUES (2, 3);
INSERT INTO public.recipe_diets VALUES (2, 5);
INSERT INTO public.recipe_diets VALUES (3, 3);
INSERT INTO public.recipe_diets VALUES (3, 4);
INSERT INTO public.recipe_diets VALUES (3, 5);
INSERT INTO public.recipe_diets VALUES (4, 1);
INSERT INTO public.recipe_diets VALUES (4, 2);
INSERT INTO public.recipe_diets VALUES (4, 3);
INSERT INTO public.recipe_diets VALUES (4, 4);
INSERT INTO public.recipe_diets VALUES (4, 5);
INSERT INTO public.recipe_diets VALUES (5, 1);
INSERT INTO public.recipe_diets VALUES (5, 2);
INSERT INTO public.recipe_diets VALUES (5, 3);
INSERT INTO public.recipe_diets VALUES (5, 4);
INSERT INTO public.recipe_diets VALUES (5, 5);
INSERT INTO public.recipe_diets VALUES (6, 1);
INSERT INTO public.recipe_diets VALUES (6, 2);
INSERT INTO public.recipe_diets VALUES (6, 3);
INSERT INTO public.recipe_diets VALUES (6, 4);
INSERT INTO public.recipe_diets VALUES (6, 5);
INSERT INTO public.recipe_diets VALUES (7, 1);
INSERT INTO public.recipe_diets VALUES (7, 2);
INSERT INTO public.recipe_diets VALUES (7, 3);
INSERT INTO public.recipe_diets VALUES (7, 4);
INSERT INTO public.recipe_diets VALUES (7, 5);
INSERT INTO public.recipe_diets VALUES (8, 1);
INSERT INTO public.recipe_diets VALUES (8, 2);
INSERT INTO public.recipe_diets VALUES (8, 3);
INSERT INTO public.recipe_diets VALUES (8, 4);
INSERT INTO public.recipe_diets VALUES (8, 5);
INSERT INTO public.recipe_diets VALUES (9, 1);
INSERT INTO public.recipe_diets VALUES (9, 2);
INSERT INTO public.recipe_diets VALUES (9, 3);
INSERT INTO public.recipe_diets VALUES (9, 4);
INSERT INTO public.recipe_diets VALUES (9, 5);
INSERT INTO public.recipe_diets VALUES (11, 1);
INSERT INTO public.recipe_diets VALUES (11, 2);
INSERT INTO public.recipe_diets VALUES (11, 3);
INSERT INTO public.recipe_diets VALUES (11, 4);
INSERT INTO public.recipe_diets VALUES (11, 5);
INSERT INTO public.recipe_diets VALUES (12, 1);
INSERT INTO public.recipe_diets VALUES (12, 2);
INSERT INTO public.recipe_diets VALUES (12, 3);
INSERT INTO public.recipe_diets VALUES (12, 4);
INSERT INTO public.recipe_diets VALUES (12, 5);
INSERT INTO public.recipe_diets VALUES (13, 3);
INSERT INTO public.recipe_diets VALUES (13, 5);
INSERT INTO public.recipe_diets VALUES (14, 3);
INSERT INTO public.recipe_diets VALUES (14, 4);
INSERT INTO public.recipe_diets VALUES (14, 5);
INSERT INTO public.recipe_diets VALUES (15, 1);
INSERT INTO public.recipe_diets VALUES (15, 2);
INSERT INTO public.recipe_diets VALUES (15, 3);
INSERT INTO public.recipe_diets VALUES (15, 4);
INSERT INTO public.recipe_diets VALUES (15, 5);
INSERT INTO public.recipe_diets VALUES (16, 1);
INSERT INTO public.recipe_diets VALUES (16, 2);
INSERT INTO public.recipe_diets VALUES (16, 4);
INSERT INTO public.recipe_diets VALUES (16, 5);
INSERT INTO public.recipe_diets VALUES (17, 1);
INSERT INTO public.recipe_diets VALUES (17, 2);
INSERT INTO public.recipe_diets VALUES (17, 3);
INSERT INTO public.recipe_diets VALUES (17, 4);
INSERT INTO public.recipe_diets VALUES (17, 5);
INSERT INTO public.recipe_diets VALUES (18, 3);
INSERT INTO public.recipe_diets VALUES (18, 4);
INSERT INTO public.recipe_diets VALUES (18, 5);
INSERT INTO public.recipe_diets VALUES (19, 3);
INSERT INTO public.recipe_diets VALUES (19, 4);
INSERT INTO public.recipe_diets VALUES (19, 5);
INSERT INTO public.recipe_diets VALUES (20, 3);
INSERT INTO public.recipe_diets VALUES (20, 4);
INSERT INTO public.recipe_diets VALUES (20, 5);
INSERT INTO public.recipe_diets VALUES (21, 1);
INSERT INTO public.recipe_diets VALUES (21, 2);
INSERT INTO public.recipe_diets VALUES (21, 4);
INSERT INTO public.recipe_diets VALUES (21, 5);
INSERT INTO public.recipe_diets VALUES (22, 5);
INSERT INTO public.recipe_diets VALUES (23, 3);
INSERT INTO public.recipe_diets VALUES (23, 5);
INSERT INTO public.recipe_diets VALUES (24, 3);
INSERT INTO public.recipe_diets VALUES (24, 4);
INSERT INTO public.recipe_diets VALUES (24, 5);
INSERT INTO public.recipe_diets VALUES (25, 3);
INSERT INTO public.recipe_diets VALUES (25, 4);
INSERT INTO public.recipe_diets VALUES (25, 5);
INSERT INTO public.recipe_diets VALUES (26, 2);
INSERT INTO public.recipe_diets VALUES (26, 3);
INSERT INTO public.recipe_diets VALUES (26, 5);
INSERT INTO public.recipe_diets VALUES (27, 5);
INSERT INTO public.recipe_diets VALUES (28, 3);
INSERT INTO public.recipe_diets VALUES (28, 5);
INSERT INTO public.recipe_diets VALUES (29, 3);
INSERT INTO public.recipe_diets VALUES (29, 5);
INSERT INTO public.recipe_diets VALUES (30, 5);
INSERT INTO public.recipe_diets VALUES (47, 3);
INSERT INTO public.recipe_diets VALUES (47, 5);
INSERT INTO public.recipe_diets VALUES (48, 3);
INSERT INTO public.recipe_diets VALUES (48, 5);
INSERT INTO public.recipe_diets VALUES (49, 3);
INSERT INTO public.recipe_diets VALUES (49, 5);
INSERT INTO public.recipe_diets VALUES (50, 3);
INSERT INTO public.recipe_diets VALUES (50, 4);
INSERT INTO public.recipe_diets VALUES (50, 5);
INSERT INTO public.recipe_diets VALUES (71, 3);
INSERT INTO public.recipe_diets VALUES (71, 4);
INSERT INTO public.recipe_diets VALUES (71, 5);
INSERT INTO public.recipe_diets VALUES (73, 3);
INSERT INTO public.recipe_diets VALUES (73, 5);
INSERT INTO public.recipe_diets VALUES (74, 2);
INSERT INTO public.recipe_diets VALUES (74, 3);
INSERT INTO public.recipe_diets VALUES (74, 5);
INSERT INTO public.recipe_diets VALUES (76, 3);
INSERT INTO public.recipe_diets VALUES (76, 5);
INSERT INTO public.recipe_diets VALUES (77, 1);
INSERT INTO public.recipe_diets VALUES (77, 3);
INSERT INTO public.recipe_diets VALUES (77, 4);
INSERT INTO public.recipe_diets VALUES (77, 5);
INSERT INTO public.recipe_diets VALUES (78, 1);
INSERT INTO public.recipe_diets VALUES (78, 2);
INSERT INTO public.recipe_diets VALUES (78, 3);
INSERT INTO public.recipe_diets VALUES (78, 4);
INSERT INTO public.recipe_diets VALUES (78, 5);
INSERT INTO public.recipe_diets VALUES (79, 3);
INSERT INTO public.recipe_diets VALUES (79, 5);
INSERT INTO public.recipe_diets VALUES (80, 2);
INSERT INTO public.recipe_diets VALUES (80, 3);
INSERT INTO public.recipe_diets VALUES (80, 5);
INSERT INTO public.recipe_diets VALUES (98, 3);
INSERT INTO public.recipe_diets VALUES (98, 5);
INSERT INTO public.recipe_diets VALUES (100, 3);
INSERT INTO public.recipe_diets VALUES (100, 4);
INSERT INTO public.recipe_diets VALUES (100, 5);
INSERT INTO public.recipe_diets VALUES (72, 1);
INSERT INTO public.recipe_diets VALUES (72, 2);
INSERT INTO public.recipe_diets VALUES (72, 3);
INSERT INTO public.recipe_diets VALUES (72, 4);
INSERT INTO public.recipe_diets VALUES (72, 5);
INSERT INTO public.recipe_diets VALUES (97, 1);
INSERT INTO public.recipe_diets VALUES (97, 3);
INSERT INTO public.recipe_diets VALUES (97, 5);
INSERT INTO public.recipe_diets VALUES (57, 3);
INSERT INTO public.recipe_diets VALUES (57, 5);
INSERT INTO public.recipe_diets VALUES (69, 3);
INSERT INTO public.recipe_diets VALUES (69, 5);
INSERT INTO public.recipe_diets VALUES (95, 3);
INSERT INTO public.recipe_diets VALUES (95, 5);
INSERT INTO public.recipe_diets VALUES (44, 3);
INSERT INTO public.recipe_diets VALUES (44, 5);
INSERT INTO public.recipe_diets VALUES (65, 1);
INSERT INTO public.recipe_diets VALUES (65, 2);
INSERT INTO public.recipe_diets VALUES (65, 4);
INSERT INTO public.recipe_diets VALUES (65, 5);


--
-- Data for Name: recipe_ingredients; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.recipe_ingredients VALUES (1, 2, 50, 'г', 3);
INSERT INTO public.recipe_ingredients VALUES (2, 2, 100, 'г', 9);
INSERT INTO public.recipe_ingredients VALUES (3, 2, 200, 'г', 10);
INSERT INTO public.recipe_ingredients VALUES (4, 1, 200, 'г', 15);
INSERT INTO public.recipe_ingredients VALUES (5, 1, 100, 'г', 14);
INSERT INTO public.recipe_ingredients VALUES (6, 3, 150, 'г', 11);
INSERT INTO public.recipe_ingredients VALUES (7, 3, 100, 'г', 18);
INSERT INTO public.recipe_ingredients VALUES (18, 4, 120, 'г', 15);
INSERT INTO public.recipe_ingredients VALUES (19, 4, 70, 'г', 14);
INSERT INTO public.recipe_ingredients VALUES (20, 4, 100, 'г', 7);
INSERT INTO public.recipe_ingredients VALUES (21, 4, 30, 'г', 16);
INSERT INTO public.recipe_ingredients VALUES (22, 4, 300, 'мл', 69);
INSERT INTO public.recipe_ingredients VALUES (137, 30, 70, 'г', 14);
INSERT INTO public.recipe_ingredients VALUES (138, 30, 30, 'г', 3);
INSERT INTO public.recipe_ingredients VALUES (139, 30, 8, 'мл', 68);
INSERT INTO public.recipe_ingredients VALUES (140, 30, 30, 'г', 28);
INSERT INTO public.recipe_ingredients VALUES (197, 31, 80, 'г', 14);
INSERT INTO public.recipe_ingredients VALUES (198, 31, 120, 'г', 15);
INSERT INTO public.recipe_ingredients VALUES (199, 31, 50, 'г', 112);
INSERT INTO public.recipe_ingredients VALUES (200, 31, 40, 'г', 16);
INSERT INTO public.recipe_ingredients VALUES (201, 31, 30, 'г', 3);
INSERT INTO public.recipe_ingredients VALUES (204, 32, 100, 'г', 130);
INSERT INTO public.recipe_ingredients VALUES (329, 54, 40, 'г', 3);
INSERT INTO public.recipe_ingredients VALUES (330, 54, 600, 'мл', 69);
INSERT INTO public.recipe_ingredients VALUES (331, 54, 5, 'г', 55);
INSERT INTO public.recipe_ingredients VALUES (332, 55, 80, 'г', 54);
INSERT INTO public.recipe_ingredients VALUES (333, 55, 60, 'г', 86);
INSERT INTO public.recipe_ingredients VALUES (334, 55, 60, 'г', 112);
INSERT INTO public.recipe_ingredients VALUES (335, 55, 40, 'г', 16);
INSERT INTO public.recipe_ingredients VALUES (336, 55, 30, 'г', 3);
INSERT INTO public.recipe_ingredients VALUES (337, 55, 8, 'мл', 68);
INSERT INTO public.recipe_ingredients VALUES (338, 55, 50, 'мл', 89);
INSERT INTO public.recipe_ingredients VALUES (357, 59, 100, 'г', 8);
INSERT INTO public.recipe_ingredients VALUES (358, 59, 50, 'г', 16);
INSERT INTO public.recipe_ingredients VALUES (359, 59, 80, 'г', 32);
INSERT INTO public.recipe_ingredients VALUES (360, 59, 40, 'г', 3);
INSERT INTO public.recipe_ingredients VALUES (361, 59, 700, 'мл', 69);
INSERT INTO public.recipe_ingredients VALUES (362, 59, 5, 'г', 55);
INSERT INTO public.recipe_ingredients VALUES (380, 63, 150, 'г', 15);
INSERT INTO public.recipe_ingredients VALUES (381, 63, 50, 'г', 3);
INSERT INTO public.recipe_ingredients VALUES (382, 63, 50, 'г', 16);
INSERT INTO public.recipe_ingredients VALUES (383, 63, 150, 'мл', 69);
INSERT INTO public.recipe_ingredients VALUES (384, 63, 5, 'г', 55);
INSERT INTO public.recipe_ingredients VALUES (385, 64, 70, 'г', 40);
INSERT INTO public.recipe_ingredients VALUES (386, 64, 120, 'г', 15);
INSERT INTO public.recipe_ingredients VALUES (387, 64, 60, 'г', 112);
INSERT INTO public.recipe_ingredients VALUES (388, 64, 60, 'г', 86);
INSERT INTO public.recipe_ingredients VALUES (389, 64, 30, 'г', 3);
INSERT INTO public.recipe_ingredients VALUES (390, 64, 8, 'мл', 68);
INSERT INTO public.recipe_ingredients VALUES (391, 64, 150, 'мл', 69);
INSERT INTO public.recipe_ingredients VALUES (396, 66, 120, 'г', 15);
INSERT INTO public.recipe_ingredients VALUES (397, 66, 50, 'г', 16);
INSERT INTO public.recipe_ingredients VALUES (398, 66, 40, 'г', 3);
INSERT INTO public.recipe_ingredients VALUES (399, 66, 100, 'г', 8);
INSERT INTO public.recipe_ingredients VALUES (400, 66, 700, 'мл', 69);
INSERT INTO public.recipe_ingredients VALUES (401, 66, 5, 'г', 55);
INSERT INTO public.recipe_ingredients VALUES (402, 67, 80, 'г', 54);
INSERT INTO public.recipe_ingredients VALUES (403, 67, 100, 'г', 51);
INSERT INTO public.recipe_ingredients VALUES (404, 67, 40, 'г', 3);
INSERT INTO public.recipe_ingredients VALUES (405, 67, 80, 'мл', 52);
INSERT INTO public.recipe_ingredients VALUES (406, 67, 8, 'мл', 68);
INSERT INTO public.recipe_ingredients VALUES (407, 67, 30, 'г', 28);
INSERT INTO public.recipe_ingredients VALUES (408, 68, 100, 'г', 11);
INSERT INTO public.recipe_ingredients VALUES (409, 68, 80, 'г', 29);
INSERT INTO public.recipe_ingredients VALUES (410, 68, 80, 'г', 30);
INSERT INTO public.recipe_ingredients VALUES (411, 68, 50, 'г', 110);
INSERT INTO public.recipe_ingredients VALUES (412, 68, 60, 'г', 20);
INSERT INTO public.recipe_ingredients VALUES (413, 68, 5, 'г', 55);
INSERT INTO public.recipe_ingredients VALUES (420, 70, 100, 'г', 11);
INSERT INTO public.recipe_ingredients VALUES (421, 70, 60, 'г', 16);
INSERT INTO public.recipe_ingredients VALUES (422, 70, 80, 'г', 86);
INSERT INTO public.recipe_ingredients VALUES (423, 70, 60, 'г', 112);
INSERT INTO public.recipe_ingredients VALUES (424, 71, 130, 'г', 15);
INSERT INTO public.recipe_ingredients VALUES (425, 71, 50, 'г', 16);
INSERT INTO public.recipe_ingredients VALUES (465, 78, 100, 'г', 8);
INSERT INTO public.recipe_ingredients VALUES (466, 78, 50, 'г', 16);
INSERT INTO public.recipe_ingredients VALUES (467, 78, 80, 'г', 32);
INSERT INTO public.recipe_ingredients VALUES (468, 78, 80, 'г', 86);
INSERT INTO public.recipe_ingredients VALUES (469, 78, 40, 'г', 3);
INSERT INTO public.recipe_ingredients VALUES (470, 78, 700, 'мл', 69);
INSERT INTO public.recipe_ingredients VALUES (471, 78, 5, 'г', 55);
INSERT INTO public.recipe_ingredients VALUES (472, 79, 80, 'г', 54);
INSERT INTO public.recipe_ingredients VALUES (473, 79, 40, 'г', 28);
INSERT INTO public.recipe_ingredients VALUES (474, 79, 50, 'мл', 5);
INSERT INTO public.recipe_ingredients VALUES (475, 79, 5, 'г', 4);
INSERT INTO public.recipe_ingredients VALUES (476, 79, 5, 'г', 55);
INSERT INTO public.recipe_ingredients VALUES (477, 79, 5, 'г', 56);
INSERT INTO public.recipe_ingredients VALUES (478, 80, 80, 'г', 41);
INSERT INTO public.recipe_ingredients VALUES (479, 80, 80, 'г', 29);
INSERT INTO public.recipe_ingredients VALUES (480, 80, 80, 'г', 30);
INSERT INTO public.recipe_ingredients VALUES (481, 80, 80, 'г', 88);
INSERT INTO public.recipe_ingredients VALUES (482, 80, 60, 'г', 20);
INSERT INTO public.recipe_ingredients VALUES (497, 83, 150, 'г', 11);
INSERT INTO public.recipe_ingredients VALUES (498, 83, 100, 'г', 8);
INSERT INTO public.recipe_ingredients VALUES (499, 83, 50, 'г', 16);
INSERT INTO public.recipe_ingredients VALUES (500, 83, 40, 'г', 3);
INSERT INTO public.recipe_ingredients VALUES (501, 83, 700, 'мл', 69);
INSERT INTO public.recipe_ingredients VALUES (508, 85, 80, 'г', 29);
INSERT INTO public.recipe_ingredients VALUES (509, 85, 80, 'г', 30);
INSERT INTO public.recipe_ingredients VALUES (510, 85, 60, 'г', 112);
INSERT INTO public.recipe_ingredients VALUES (511, 85, 50, 'г', 28);
INSERT INTO public.recipe_ingredients VALUES (512, 85, 60, 'г', 20);
INSERT INTO public.recipe_ingredients VALUES (513, 85, 5, 'г', 55);
INSERT INTO public.recipe_ingredients VALUES (514, 86, 130, 'г', 15);
INSERT INTO public.recipe_ingredients VALUES (515, 86, 70, 'г', 14);
INSERT INTO public.recipe_ingredients VALUES (516, 86, 50, 'г', 16);
INSERT INTO public.recipe_ingredients VALUES (23, 5, 50, 'г', 6);
INSERT INTO public.recipe_ingredients VALUES (24, 5, 80, 'г', 36);
INSERT INTO public.recipe_ingredients VALUES (25, 5, 200, 'мл', 5);
INSERT INTO public.recipe_ingredients VALUES (26, 6, 100, 'г', 15);
INSERT INTO public.recipe_ingredients VALUES (27, 6, 50, 'г', 14);
INSERT INTO public.recipe_ingredients VALUES (28, 6, 40, 'г', 16);
INSERT INTO public.recipe_ingredients VALUES (29, 6, 30, 'г', 3);
INSERT INTO public.recipe_ingredients VALUES (30, 6, 600, 'мл', 69);
INSERT INTO public.recipe_ingredients VALUES (31, 7, 150, 'г', 17);
INSERT INTO public.recipe_ingredients VALUES (32, 7, 80, 'г', 11);
INSERT INTO public.recipe_ingredients VALUES (33, 7, 50, 'г', 16);
INSERT INTO public.recipe_ingredients VALUES (34, 8, 200, 'г', 8);
INSERT INTO public.recipe_ingredients VALUES (35, 8, 100, 'г', 15);
INSERT INTO public.recipe_ingredients VALUES (36, 8, 50, 'мл', 5);
INSERT INTO public.recipe_ingredients VALUES (37, 9, 60, 'г', 14);
INSERT INTO public.recipe_ingredients VALUES (38, 9, 40, 'г', 16);
INSERT INTO public.recipe_ingredients VALUES (39, 9, 80, 'г', 8);
INSERT INTO public.recipe_ingredients VALUES (40, 9, 30, 'г', 3);
INSERT INTO public.recipe_ingredients VALUES (41, 9, 700, 'мл', 69);
INSERT INTO public.recipe_ingredients VALUES (45, 11, 80, 'г', 9);
INSERT INTO public.recipe_ingredients VALUES (46, 11, 120, 'г', 15);
INSERT INTO public.recipe_ingredients VALUES (47, 11, 30, 'г', 16);
INSERT INTO public.recipe_ingredients VALUES (48, 12, 100, 'г', 11);
INSERT INTO public.recipe_ingredients VALUES (49, 12, 50, 'мл', 5);
INSERT INTO public.recipe_ingredients VALUES (50, 13, 250, 'г', 7);
INSERT INTO public.recipe_ingredients VALUES (51, 13, 30, 'г', 3);
INSERT INTO public.recipe_ingredients VALUES (52, 13, 50, 'мл', 52);
INSERT INTO public.recipe_ingredients VALUES (53, 13, 400, 'мл', 69);
INSERT INTO public.recipe_ingredients VALUES (54, 14, 130, 'г', 21);
INSERT INTO public.recipe_ingredients VALUES (603, 100, 80, 'г', 14);
INSERT INTO public.recipe_ingredients VALUES (604, 100, 120, 'г', 17);
INSERT INTO public.recipe_ingredients VALUES (605, 100, 50, 'г', 16);
INSERT INTO public.recipe_ingredients VALUES (606, 100, 60, 'г', 112);
INSERT INTO public.recipe_ingredients VALUES (607, 100, 40, 'г', 3);
INSERT INTO public.recipe_ingredients VALUES (608, 100, 8, 'мл', 68);
INSERT INTO public.recipe_ingredients VALUES (609, 100, 200, 'мл', 69);
INSERT INTO public.recipe_ingredients VALUES (55, 14, 70, 'г', 14);
INSERT INTO public.recipe_ingredients VALUES (56, 14, 40, 'г', 16);
INSERT INTO public.recipe_ingredients VALUES (57, 14, 200, 'мл', 69);
INSERT INTO public.recipe_ingredients VALUES (58, 15, 100, 'г', 15);
INSERT INTO public.recipe_ingredients VALUES (59, 15, 50, 'г', 6);
INSERT INTO public.recipe_ingredients VALUES (60, 15, 40, 'г', 16);
INSERT INTO public.recipe_ingredients VALUES (61, 15, 30, 'г', 3);
INSERT INTO public.recipe_ingredients VALUES (62, 15, 700, 'мл', 69);
INSERT INTO public.recipe_ingredients VALUES (63, 16, 200, 'г', 19);
INSERT INTO public.recipe_ingredients VALUES (64, 16, 50, 'г', 11);
INSERT INTO public.recipe_ingredients VALUES (65, 16, 15, 'г', 13);
INSERT INTO public.recipe_ingredients VALUES (66, 17, 200, 'г', 15);
INSERT INTO public.recipe_ingredients VALUES (67, 17, 30, 'г', 3);
INSERT INTO public.recipe_ingredients VALUES (68, 17, 50, 'г', 11);
INSERT INTO public.recipe_ingredients VALUES (69, 18, 100, 'г', 7);
INSERT INTO public.recipe_ingredients VALUES (70, 18, 50, 'г', 16);
INSERT INTO public.recipe_ingredients VALUES (71, 18, 100, 'г', 8);
INSERT INTO public.recipe_ingredients VALUES (72, 18, 80, 'г', 32);
INSERT INTO public.recipe_ingredients VALUES (73, 18, 40, 'г', 3);
INSERT INTO public.recipe_ingredients VALUES (74, 18, 50, 'мл', 89);
INSERT INTO public.recipe_ingredients VALUES (75, 19, 60, 'г', 42);
INSERT INTO public.recipe_ingredients VALUES (76, 19, 80, 'г', 8);
INSERT INTO public.recipe_ingredients VALUES (77, 19, 40, 'г', 16);
INSERT INTO public.recipe_ingredients VALUES (78, 19, 30, 'г', 3);
INSERT INTO public.recipe_ingredients VALUES (79, 19, 700, 'мл', 69);
INSERT INTO public.recipe_ingredients VALUES (80, 20, 150, 'г', 17);
INSERT INTO public.recipe_ingredients VALUES (81, 20, 80, 'г', 16);
INSERT INTO public.recipe_ingredients VALUES (82, 20, 40, 'г', 3);
INSERT INTO public.recipe_ingredients VALUES (83, 20, 5, 'мл', 68);
INSERT INTO public.recipe_ingredients VALUES (84, 20, 100, 'мл', 69);
INSERT INTO public.recipe_ingredients VALUES (85, 21, 70, 'г', 14);
INSERT INTO public.recipe_ingredients VALUES (86, 21, 400, 'мл', 5);
INSERT INTO public.recipe_ingredients VALUES (87, 21, 10, 'г', 13);
INSERT INTO public.recipe_ingredients VALUES (88, 22, 80, 'г', 54);
INSERT INTO public.recipe_ingredients VALUES (89, 22, 100, 'г', 15);
INSERT INTO public.recipe_ingredients VALUES (90, 22, 80, 'г', 51);
INSERT INTO public.recipe_ingredients VALUES (91, 22, 100, 'мл', 52);
INSERT INTO public.recipe_ingredients VALUES (92, 22, 30, 'г', 3);
INSERT INTO public.recipe_ingredients VALUES (93, 22, 10, 'мл', 68);
INSERT INTO public.recipe_ingredients VALUES (94, 22, 30, 'г', 28);
INSERT INTO public.recipe_ingredients VALUES (95, 23, 80, 'г', 54);
INSERT INTO public.recipe_ingredients VALUES (96, 23, 100, 'мл', 89);
INSERT INTO public.recipe_ingredients VALUES (97, 23, 5, 'г', 90);
INSERT INTO public.recipe_ingredients VALUES (98, 23, 5, 'мл', 68);
INSERT INTO public.recipe_ingredients VALUES (99, 23, 20, 'г', 28);
INSERT INTO public.recipe_ingredients VALUES (100, 24, 70, 'г', 40);
INSERT INTO public.recipe_ingredients VALUES (101, 24, 120, 'г', 15);
INSERT INTO public.recipe_ingredients VALUES (102, 24, 60, 'г', 112);
INSERT INTO public.recipe_ingredients VALUES (103, 24, 60, 'г', 86);
INSERT INTO public.recipe_ingredients VALUES (104, 24, 30, 'г', 3);
INSERT INTO public.recipe_ingredients VALUES (105, 24, 8, 'мл', 68);
INSERT INTO public.recipe_ingredients VALUES (106, 24, 100, 'мл', 69);
INSERT INTO public.recipe_ingredients VALUES (107, 25, 150, 'г', 17);
INSERT INTO public.recipe_ingredients VALUES (108, 25, 180, 'г', 8);
INSERT INTO public.recipe_ingredients VALUES (109, 25, 50, 'г', 16);
INSERT INTO public.recipe_ingredients VALUES (110, 25, 5, 'мл', 1);
INSERT INTO public.recipe_ingredients VALUES (112, 26, 100, 'г', 15);
INSERT INTO public.recipe_ingredients VALUES (113, 26, 80, 'г', 29);
INSERT INTO public.recipe_ingredients VALUES (114, 26, 80, 'г', 30);
INSERT INTO public.recipe_ingredients VALUES (115, 26, 50, 'г', 110);
INSERT INTO public.recipe_ingredients VALUES (116, 26, 100, 'г', 20);
INSERT INTO public.recipe_ingredients VALUES (117, 26, 5, 'г', 55);
INSERT INTO public.recipe_ingredients VALUES (119, 27, 100, 'г', 11);
INSERT INTO public.recipe_ingredients VALUES (120, 27, 40, 'г', 28);
INSERT INTO public.recipe_ingredients VALUES (121, 27, 5, 'г', 55);
INSERT INTO public.recipe_ingredients VALUES (122, 27, 5, 'г', 56);
INSERT INTO public.recipe_ingredients VALUES (123, 27, 30, 'мл', 5);
INSERT INTO public.recipe_ingredients VALUES (124, 27, 5, 'мл', 68);
INSERT INTO public.recipe_ingredients VALUES (125, 28, 80, 'г', 9);
INSERT INTO public.recipe_ingredients VALUES (126, 28, 100, 'г', 51);
INSERT INTO public.recipe_ingredients VALUES (127, 28, 50, 'г', 3);
INSERT INTO public.recipe_ingredients VALUES (128, 28, 10, 'мл', 68);
INSERT INTO public.recipe_ingredients VALUES (129, 28, 200, 'мл', 69);
INSERT INTO public.recipe_ingredients VALUES (130, 29, 200, 'г', 11);
INSERT INTO public.recipe_ingredients VALUES (131, 29, 80, 'г', 8);
INSERT INTO public.recipe_ingredients VALUES (132, 29, 30, 'г', 3);
INSERT INTO public.recipe_ingredients VALUES (133, 29, 50, 'мл', 52);
INSERT INTO public.recipe_ingredients VALUES (134, 29, 500, 'мл', 69);
INSERT INTO public.recipe_ingredients VALUES (135, 30, 130, 'г', 15);
INSERT INTO public.recipe_ingredients VALUES (136, 30, 100, 'мл', 52);
INSERT INTO public.recipe_ingredients VALUES (111, 25, 1, 'шт', 12);
INSERT INTO public.recipe_ingredients VALUES (118, 26, 10, 'мл', 12);
INSERT INTO public.recipe_ingredients VALUES (202, 31, 10, 'мл', 68);
INSERT INTO public.recipe_ingredients VALUES (203, 31, 15, 'мл', 66);
INSERT INTO public.recipe_ingredients VALUES (205, 32, 60, 'г', 86);
INSERT INTO public.recipe_ingredients VALUES (206, 32, 50, 'г', 112);
INSERT INTO public.recipe_ingredients VALUES (207, 32, 40, 'г', 16);
INSERT INTO public.recipe_ingredients VALUES (208, 32, 8, 'мл', 68);
INSERT INTO public.recipe_ingredients VALUES (209, 32, 12, 'мл', 66);
INSERT INTO public.recipe_ingredients VALUES (210, 33, 150, 'г', 15);
INSERT INTO public.recipe_ingredients VALUES (211, 33, 8, 'мл', 68);
INSERT INTO public.recipe_ingredients VALUES (212, 33, 30, 'мл', 73);
INSERT INTO public.recipe_ingredients VALUES (213, 34, 60, 'г', 72);
INSERT INTO public.recipe_ingredients VALUES (214, 34, 80, 'г', 15);
INSERT INTO public.recipe_ingredients VALUES (215, 34, 30, 'г', 16);
INSERT INTO public.recipe_ingredients VALUES (216, 34, 30, 'г', 112);
INSERT INTO public.recipe_ingredients VALUES (217, 34, 400, 'мл', 69);
INSERT INTO public.recipe_ingredients VALUES (218, 35, 120, 'г', 77);
INSERT INTO public.recipe_ingredients VALUES (219, 35, 70, 'г', 86);
INSERT INTO public.recipe_ingredients VALUES (220, 35, 50, 'г', 112);
INSERT INTO public.recipe_ingredients VALUES (221, 35, 10, 'мл', 68);
INSERT INTO public.recipe_ingredients VALUES (222, 35, 10, 'мл', 66);
INSERT INTO public.recipe_ingredients VALUES (223, 36, 80, 'г', 14);
INSERT INTO public.recipe_ingredients VALUES (224, 36, 100, 'г', 84);
INSERT INTO public.recipe_ingredients VALUES (225, 36, 8, 'мл', 68);
INSERT INTO public.recipe_ingredients VALUES (226, 36, 5, 'мл', 66);
INSERT INTO public.recipe_ingredients VALUES (227, 37, 130, 'г', 15);
INSERT INTO public.recipe_ingredients VALUES (228, 37, 40, 'г', 3);
INSERT INTO public.recipe_ingredients VALUES (229, 37, 10, 'мл', 68);
INSERT INTO public.recipe_ingredients VALUES (230, 37, 25, 'г', 131);
INSERT INTO public.recipe_ingredients VALUES (231, 37, 100, 'мл', 71);
INSERT INTO public.recipe_ingredients VALUES (232, 38, 80, 'г', 86);
INSERT INTO public.recipe_ingredients VALUES (233, 38, 60, 'г', 112);
INSERT INTO public.recipe_ingredients VALUES (234, 38, 40, 'г', 16);
INSERT INTO public.recipe_ingredients VALUES (235, 38, 30, 'г', 3);
INSERT INTO public.recipe_ingredients VALUES (236, 38, 8, 'мл', 68);
INSERT INTO public.recipe_ingredients VALUES (237, 38, 15, 'мл', 66);
INSERT INTO public.recipe_ingredients VALUES (238, 39, 70, 'г', 14);
INSERT INTO public.recipe_ingredients VALUES (239, 39, 100, 'г', 11);
INSERT INTO public.recipe_ingredients VALUES (240, 39, 8, 'мл', 68);
INSERT INTO public.recipe_ingredients VALUES (241, 39, 8, 'мл', 66);
INSERT INTO public.recipe_ingredients VALUES (242, 39, 20, 'г', 3);
INSERT INTO public.recipe_ingredients VALUES (243, 40, 80, 'г', 54);
INSERT INTO public.recipe_ingredients VALUES (244, 40, 120, 'г', 15);
INSERT INTO public.recipe_ingredients VALUES (245, 40, 10, 'г', 74);
INSERT INTO public.recipe_ingredients VALUES (246, 40, 30, 'г', 3);
INSERT INTO public.recipe_ingredients VALUES (247, 40, 10, 'мл', 68);
INSERT INTO public.recipe_ingredients VALUES (248, 40, 15, 'мл', 66);
INSERT INTO public.recipe_ingredients VALUES (249, 41, 100, 'г', 24);
INSERT INTO public.recipe_ingredients VALUES (250, 41, 80, 'г', 29);
INSERT INTO public.recipe_ingredients VALUES (251, 41, 80, 'г', 30);
INSERT INTO public.recipe_ingredients VALUES (252, 41, 50, 'г', 110);
INSERT INTO public.recipe_ingredients VALUES (253, 41, 60, 'г', 20);
INSERT INTO public.recipe_ingredients VALUES (255, 41, 5, 'г', 55);
INSERT INTO public.recipe_ingredients VALUES (262, 43, 80, 'г', 40);
INSERT INTO public.recipe_ingredients VALUES (263, 43, 60, 'г', 112);
INSERT INTO public.recipe_ingredients VALUES (264, 43, 60, 'г', 86);
INSERT INTO public.recipe_ingredients VALUES (265, 43, 40, 'г', 16);
INSERT INTO public.recipe_ingredients VALUES (266, 43, 30, 'г', 3);
INSERT INTO public.recipe_ingredients VALUES (267, 43, 8, 'мл', 68);
INSERT INTO public.recipe_ingredients VALUES (268, 43, 100, 'мл', 69);
INSERT INTO public.recipe_ingredients VALUES (274, 45, 70, 'г', 43);
INSERT INTO public.recipe_ingredients VALUES (275, 45, 50, 'г', 16);
INSERT INTO public.recipe_ingredients VALUES (276, 45, 40, 'г', 3);
INSERT INTO public.recipe_ingredients VALUES (277, 45, 80, 'г', 8);
INSERT INTO public.recipe_ingredients VALUES (278, 45, 700, 'мл', 69);
INSERT INTO public.recipe_ingredients VALUES (279, 46, 70, 'г', 41);
INSERT INTO public.recipe_ingredients VALUES (280, 46, 120, 'г', 15);
INSERT INTO public.recipe_ingredients VALUES (281, 46, 60, 'г', 112);
INSERT INTO public.recipe_ingredients VALUES (282, 46, 60, 'г', 86);
INSERT INTO public.recipe_ingredients VALUES (283, 46, 30, 'г', 3);
INSERT INTO public.recipe_ingredients VALUES (284, 46, 8, 'мл', 68);
INSERT INTO public.recipe_ingredients VALUES (285, 46, 150, 'мл', 69);
INSERT INTO public.recipe_ingredients VALUES (286, 47, 100, 'г', 88);
INSERT INTO public.recipe_ingredients VALUES (287, 47, 80, 'г', 29);
INSERT INTO public.recipe_ingredients VALUES (288, 47, 80, 'г', 30);
INSERT INTO public.recipe_ingredients VALUES (289, 47, 50, 'г', 110);
INSERT INTO public.recipe_ingredients VALUES (290, 47, 60, 'г', 20);
INSERT INTO public.recipe_ingredients VALUES (292, 48, 150, 'г', 17);
INSERT INTO public.recipe_ingredients VALUES (293, 48, 80, 'г', 86);
INSERT INTO public.recipe_ingredients VALUES (294, 48, 60, 'г', 112);
INSERT INTO public.recipe_ingredients VALUES (295, 48, 50, 'г', 16);
INSERT INTO public.recipe_ingredients VALUES (296, 48, 8, 'мл', 1);
INSERT INTO public.recipe_ingredients VALUES (298, 49, 80, 'г', 54);
INSERT INTO public.recipe_ingredients VALUES (299, 49, 50, 'г', 28);
INSERT INTO public.recipe_ingredients VALUES (300, 49, 30, 'мл', 5);
INSERT INTO public.recipe_ingredients VALUES (301, 49, 5, 'г', 4);
INSERT INTO public.recipe_ingredients VALUES (302, 50, 120, 'г', 15);
INSERT INTO public.recipe_ingredients VALUES (303, 50, 100, 'г', 8);
INSERT INTO public.recipe_ingredients VALUES (304, 50, 50, 'г', 16);
INSERT INTO public.recipe_ingredients VALUES (305, 50, 80, 'г', 86);
INSERT INTO public.recipe_ingredients VALUES (306, 50, 80, 'г', 32);
INSERT INTO public.recipe_ingredients VALUES (307, 50, 40, 'г', 3);
INSERT INTO public.recipe_ingredients VALUES (308, 50, 50, 'мл', 89);
INSERT INTO public.recipe_ingredients VALUES (309, 50, 8, 'мл', 68);
INSERT INTO public.recipe_ingredients VALUES (310, 50, 200, 'мл', 69);
INSERT INTO public.recipe_ingredients VALUES (311, 51, 80, 'г', 14);
INSERT INTO public.recipe_ingredients VALUES (312, 51, 50, 'г', 16);
INSERT INTO public.recipe_ingredients VALUES (313, 51, 60, 'г', 112);
INSERT INTO public.recipe_ingredients VALUES (314, 51, 50, 'г', 64);
INSERT INTO public.recipe_ingredients VALUES (315, 51, 5, 'мл', 68);
INSERT INTO public.recipe_ingredients VALUES (316, 51, 30, 'г', 3);
INSERT INTO public.recipe_ingredients VALUES (317, 52, 130, 'г', 15);
INSERT INTO public.recipe_ingredients VALUES (318, 52, 120, 'г', 11);
INSERT INTO public.recipe_ingredients VALUES (319, 52, 30, 'г', 3);
INSERT INTO public.recipe_ingredients VALUES (320, 52, 8, 'мл', 68);
INSERT INTO public.recipe_ingredients VALUES (321, 52, 100, 'мл', 69);
INSERT INTO public.recipe_ingredients VALUES (322, 53, 100, 'г', 11);
INSERT INTO public.recipe_ingredients VALUES (323, 53, 80, 'г', 51);
INSERT INTO public.recipe_ingredients VALUES (324, 53, 30, 'г', 3);
INSERT INTO public.recipe_ingredients VALUES (325, 53, 30, 'мл', 5);
INSERT INTO public.recipe_ingredients VALUES (326, 53, 10, 'мл', 68);
INSERT INTO public.recipe_ingredients VALUES (327, 54, 150, 'г', 8);
INSERT INTO public.recipe_ingredients VALUES (328, 54, 50, 'г', 16);
INSERT INTO public.recipe_ingredients VALUES (254, 41, 5, 'мл', 12);
INSERT INTO public.recipe_ingredients VALUES (291, 47, 10, 'мл', 12);
INSERT INTO public.recipe_ingredients VALUES (297, 48, 10, 'мл', 12);
INSERT INTO public.recipe_ingredients VALUES (426, 71, 80, 'г', 86);
INSERT INTO public.recipe_ingredients VALUES (427, 71, 60, 'г', 112);
INSERT INTO public.recipe_ingredients VALUES (428, 71, 40, 'г', 3);
INSERT INTO public.recipe_ingredients VALUES (429, 71, 150, 'мл', 69);
INSERT INTO public.recipe_ingredients VALUES (436, 73, 80, 'г', 54);
INSERT INTO public.recipe_ingredients VALUES (437, 73, 100, 'мл', 89);
INSERT INTO public.recipe_ingredients VALUES (438, 73, 5, 'мл', 68);
INSERT INTO public.recipe_ingredients VALUES (439, 73, 5, 'г', 90);
INSERT INTO public.recipe_ingredients VALUES (440, 73, 20, 'г', 28);
INSERT INTO public.recipe_ingredients VALUES (441, 74, 100, 'г', 17);
INSERT INTO public.recipe_ingredients VALUES (442, 74, 80, 'г', 29);
INSERT INTO public.recipe_ingredients VALUES (443, 74, 80, 'г', 30);
INSERT INTO public.recipe_ingredients VALUES (444, 74, 50, 'г', 110);
INSERT INTO public.recipe_ingredients VALUES (445, 74, 60, 'г', 20);
INSERT INTO public.recipe_ingredients VALUES (446, 74, 5, 'г', 55);
INSERT INTO public.recipe_ingredients VALUES (453, 76, 80, 'г', 14);
INSERT INTO public.recipe_ingredients VALUES (454, 76, 100, 'г', 11);
INSERT INTO public.recipe_ingredients VALUES (455, 76, 60, 'г', 64);
INSERT INTO public.recipe_ingredients VALUES (456, 76, 50, 'г', 16);
INSERT INTO public.recipe_ingredients VALUES (457, 76, 10, 'мл', 68);
INSERT INTO public.recipe_ingredients VALUES (458, 76, 10, 'мл', 66);
INSERT INTO public.recipe_ingredients VALUES (459, 77, 180, 'г', 15);
INSERT INTO public.recipe_ingredients VALUES (460, 77, 150, 'г', 8);
INSERT INTO public.recipe_ingredients VALUES (461, 77, 60, 'г', 16);
INSERT INTO public.recipe_ingredients VALUES (462, 77, 50, 'г', 3);
INSERT INTO public.recipe_ingredients VALUES (463, 77, 10, 'мл', 1);
INSERT INTO public.recipe_ingredients VALUES (464, 77, 5, 'г', 55);
INSERT INTO public.recipe_ingredients VALUES (517, 86, 60, 'г', 112);
INSERT INTO public.recipe_ingredients VALUES (518, 86, 40, 'г', 3);
INSERT INTO public.recipe_ingredients VALUES (519, 86, 8, 'мл', 68);
INSERT INTO public.recipe_ingredients VALUES (520, 86, 200, 'мл', 69);
INSERT INTO public.recipe_ingredients VALUES (521, 87, 120, 'г', 15);
INSERT INTO public.recipe_ingredients VALUES (522, 87, 100, 'г', 8);
INSERT INTO public.recipe_ingredients VALUES (523, 87, 50, 'г', 16);
INSERT INTO public.recipe_ingredients VALUES (524, 87, 80, 'г', 32);
INSERT INTO public.recipe_ingredients VALUES (525, 87, 40, 'г', 3);
INSERT INTO public.recipe_ingredients VALUES (526, 87, 800, 'мл', 69);
INSERT INTO public.recipe_ingredients VALUES (527, 88, 80, 'г', 54);
INSERT INTO public.recipe_ingredients VALUES (528, 88, 100, 'г', 51);
INSERT INTO public.recipe_ingredients VALUES (529, 88, 100, 'мл', 52);
INSERT INTO public.recipe_ingredients VALUES (530, 88, 40, 'г', 3);
INSERT INTO public.recipe_ingredients VALUES (531, 88, 8, 'мл', 68);
INSERT INTO public.recipe_ingredients VALUES (532, 88, 30, 'г', 28);
INSERT INTO public.recipe_ingredients VALUES (533, 89, 100, 'г', 24);
INSERT INTO public.recipe_ingredients VALUES (534, 89, 100, 'г', 11);
INSERT INTO public.recipe_ingredients VALUES (535, 89, 80, 'г', 29);
INSERT INTO public.recipe_ingredients VALUES (536, 89, 80, 'г', 30);
INSERT INTO public.recipe_ingredients VALUES (537, 89, 60, 'г', 20);
INSERT INTO public.recipe_ingredients VALUES (538, 89, 5, 'г', 55);
INSERT INTO public.recipe_ingredients VALUES (539, 90, 80, 'г', 14);
INSERT INTO public.recipe_ingredients VALUES (540, 90, 120, 'г', 17);
INSERT INTO public.recipe_ingredients VALUES (541, 90, 50, 'г', 16);
INSERT INTO public.recipe_ingredients VALUES (542, 90, 40, 'г', 3);
INSERT INTO public.recipe_ingredients VALUES (543, 90, 8, 'мл', 68);
INSERT INTO public.recipe_ingredients VALUES (544, 90, 200, 'мл', 69);
INSERT INTO public.recipe_ingredients VALUES (545, 91, 70, 'г', 40);
INSERT INTO public.recipe_ingredients VALUES (546, 91, 130, 'г', 15);
INSERT INTO public.recipe_ingredients VALUES (547, 91, 60, 'г', 112);
INSERT INTO public.recipe_ingredients VALUES (548, 91, 60, 'г', 86);
INSERT INTO public.recipe_ingredients VALUES (549, 91, 40, 'г', 3);
INSERT INTO public.recipe_ingredients VALUES (550, 91, 8, 'мл', 68);
INSERT INTO public.recipe_ingredients VALUES (551, 91, 150, 'мл', 69);
INSERT INTO public.recipe_ingredients VALUES (552, 92, 70, 'г', 43);
INSERT INTO public.recipe_ingredients VALUES (553, 92, 50, 'г', 16);
INSERT INTO public.recipe_ingredients VALUES (554, 92, 40, 'г', 3);
INSERT INTO public.recipe_ingredients VALUES (555, 92, 100, 'г', 8);
INSERT INTO public.recipe_ingredients VALUES (556, 92, 700, 'мл', 69);
INSERT INTO public.recipe_ingredients VALUES (557, 92, 5, 'г', 55);
INSERT INTO public.recipe_ingredients VALUES (558, 93, 80, 'г', 54);
INSERT INTO public.recipe_ingredients VALUES (559, 93, 60, 'г', 86);
INSERT INTO public.recipe_ingredients VALUES (560, 93, 60, 'г', 112);
INSERT INTO public.recipe_ingredients VALUES (561, 93, 30, 'г', 3);
INSERT INTO public.recipe_ingredients VALUES (562, 93, 8, 'мл', 68);
INSERT INTO public.recipe_ingredients VALUES (563, 93, 40, 'г', 28);
INSERT INTO public.recipe_ingredients VALUES (564, 93, 80, 'мл', 52);
INSERT INTO public.recipe_ingredients VALUES (565, 94, 100, 'г', 15);
INSERT INTO public.recipe_ingredients VALUES (566, 94, 80, 'г', 88);
INSERT INTO public.recipe_ingredients VALUES (567, 94, 80, 'г', 29);
INSERT INTO public.recipe_ingredients VALUES (568, 94, 80, 'г', 30);
INSERT INTO public.recipe_ingredients VALUES (569, 94, 50, 'г', 110);
INSERT INTO public.recipe_ingredients VALUES (570, 94, 60, 'г', 20);
INSERT INTO public.recipe_ingredients VALUES (579, 96, 130, 'г', 15);
INSERT INTO public.recipe_ingredients VALUES (580, 96, 100, 'г', 51);
INSERT INTO public.recipe_ingredients VALUES (581, 96, 50, 'г', 3);
INSERT INTO public.recipe_ingredients VALUES (582, 96, 80, 'мл', 52);
INSERT INTO public.recipe_ingredients VALUES (583, 96, 8, 'мл', 68);
INSERT INTO public.recipe_ingredients VALUES (584, 96, 5, 'г', 55);
INSERT INTO public.recipe_ingredients VALUES (592, 98, 80, 'г', 54);
INSERT INTO public.recipe_ingredients VALUES (593, 98, 100, 'мл', 89);
INSERT INTO public.recipe_ingredients VALUES (594, 98, 5, 'мл', 68);
INSERT INTO public.recipe_ingredients VALUES (595, 98, 5, 'г', 90);
INSERT INTO public.recipe_ingredients VALUES (596, 98, 20, 'г', 28);
INSERT INTO public.recipe_ingredients VALUES (483, 80, 10, 'мл', 12);
INSERT INTO public.recipe_ingredients VALUES (571, 94, 10, 'мл', 12);
INSERT INTO public.recipe_ingredients VALUES (610, 72, 200, 'г', 115);
INSERT INTO public.recipe_ingredients VALUES (611, 72, 150, 'г', 8);
INSERT INTO public.recipe_ingredients VALUES (612, 72, 60, 'г', 16);
INSERT INTO public.recipe_ingredients VALUES (613, 72, 50, 'г', 3);
INSERT INTO public.recipe_ingredients VALUES (614, 72, 800, 'мл', 69);
INSERT INTO public.recipe_ingredients VALUES (615, 72, 5, 'г', 55);
INSERT INTO public.recipe_ingredients VALUES (616, 97, 300, 'г', 133);
INSERT INTO public.recipe_ingredients VALUES (617, 97, 150, 'г', 8);
INSERT INTO public.recipe_ingredients VALUES (618, 97, 600, 'мл', 69);
INSERT INTO public.recipe_ingredients VALUES (619, 97, 100, 'мл', 52);
INSERT INTO public.recipe_ingredients VALUES (620, 57, 100, 'г', 42);
INSERT INTO public.recipe_ingredients VALUES (621, 57, 200, 'г', 15);
INSERT INTO public.recipe_ingredients VALUES (622, 57, 60, 'г', 3);
INSERT INTO public.recipe_ingredients VALUES (623, 57, 60, 'г', 16);
INSERT INTO public.recipe_ingredients VALUES (624, 57, 10, 'мл', 68);
INSERT INTO public.recipe_ingredients VALUES (625, 57, 400, 'мл', 69);
INSERT INTO public.recipe_ingredients VALUES (626, 69, 80, 'г', 14);
INSERT INTO public.recipe_ingredients VALUES (627, 69, 80, 'г', 84);
INSERT INTO public.recipe_ingredients VALUES (628, 69, 80, 'г', 85);
INSERT INTO public.recipe_ingredients VALUES (629, 69, 80, 'г', 129);
INSERT INTO public.recipe_ingredients VALUES (630, 69, 10, 'мл', 68);
INSERT INTO public.recipe_ingredients VALUES (631, 69, 15, 'мл', 66);
INSERT INTO public.recipe_ingredients VALUES (632, 95, 100, 'г', 14);
INSERT INTO public.recipe_ingredients VALUES (633, 95, 150, 'г', 78);
INSERT INTO public.recipe_ingredients VALUES (634, 95, 80, 'г', 33);
INSERT INTO public.recipe_ingredients VALUES (635, 95, 50, 'г', 3);
INSERT INTO public.recipe_ingredients VALUES (636, 95, 10, 'мл', 68);
INSERT INTO public.recipe_ingredients VALUES (637, 95, 50, 'мл', 89);
INSERT INTO public.recipe_ingredients VALUES (638, 44, 50, 'г', 58);
INSERT INTO public.recipe_ingredients VALUES (639, 44, 100, 'г', 88);
INSERT INTO public.recipe_ingredients VALUES (640, 44, 50, 'г', 11);
INSERT INTO public.recipe_ingredients VALUES (642, 65, 40, 'г', 6);
INSERT INTO public.recipe_ingredients VALUES (643, 65, 120, 'г', 20);
INSERT INTO public.recipe_ingredients VALUES (644, 65, 80, 'г', 39);
INSERT INTO public.recipe_ingredients VALUES (650, 60, 80, 'г', 54);
INSERT INTO public.recipe_ingredients VALUES (651, 60, 120, 'г', 84);
INSERT INTO public.recipe_ingredients VALUES (652, 60, 10, 'мл', 1);
INSERT INTO public.recipe_ingredients VALUES (653, 60, 10, 'г', 3);
INSERT INTO public.recipe_ingredients VALUES (654, 60, 5, 'г', 55);
INSERT INTO public.recipe_ingredients VALUES (655, 84, 80, 'г', 54);
INSERT INTO public.recipe_ingredients VALUES (656, 84, 100, 'г', 11);
INSERT INTO public.recipe_ingredients VALUES (657, 84, 10, 'мл', 1);
INSERT INTO public.recipe_ingredients VALUES (658, 84, 20, 'г', 57);
INSERT INTO public.recipe_ingredients VALUES (659, 58, 100, 'г', 79);
INSERT INTO public.recipe_ingredients VALUES (660, 58, 200, 'г', 34);
INSERT INTO public.recipe_ingredients VALUES (661, 58, 400, 'мл', 5);
INSERT INTO public.recipe_ingredients VALUES (662, 58, 15, 'г', 60);
INSERT INTO public.recipe_ingredients VALUES (663, 75, 100, 'г', 41);
INSERT INTO public.recipe_ingredients VALUES (664, 75, 50, 'г', 3);
INSERT INTO public.recipe_ingredients VALUES (665, 75, 60, 'г', 16);
INSERT INTO public.recipe_ingredients VALUES (666, 75, 80, 'г', 112);
INSERT INTO public.recipe_ingredients VALUES (667, 75, 10, 'мл', 68);
INSERT INTO public.recipe_ingredients VALUES (668, 56, 120, 'г', 84);
INSERT INTO public.recipe_ingredients VALUES (669, 56, 100, 'г', 123);
INSERT INTO public.recipe_ingredients VALUES (670, 56, 80, 'г', 88);
INSERT INTO public.recipe_ingredients VALUES (671, 56, 50, 'г', 110);
INSERT INTO public.recipe_ingredients VALUES (672, 56, 60, 'г', 20);
INSERT INTO public.recipe_ingredients VALUES (673, 56, 10, 'мл', 75);
INSERT INTO public.recipe_ingredients VALUES (674, 61, 100, 'г', 29);
INSERT INTO public.recipe_ingredients VALUES (675, 61, 100, 'г', 30);
INSERT INTO public.recipe_ingredients VALUES (676, 61, 80, 'г', 112);
INSERT INTO public.recipe_ingredients VALUES (677, 61, 50, 'г', 144);
INSERT INTO public.recipe_ingredients VALUES (678, 61, 15, 'мл', 1);
INSERT INTO public.recipe_ingredients VALUES (679, 61, 2, 'г', 91);
INSERT INTO public.recipe_ingredients VALUES (680, 99, 60, 'г', 87);
INSERT INTO public.recipe_ingredients VALUES (681, 99, 100, 'г', 37);
INSERT INTO public.recipe_ingredients VALUES (682, 99, 30, 'г', 57);
INSERT INTO public.recipe_ingredients VALUES (683, 99, 20, 'г', 44);
INSERT INTO public.recipe_ingredients VALUES (684, 99, 10, 'мл', 1);
INSERT INTO public.recipe_ingredients VALUES (685, 10, 300, 'г', 17);
INSERT INTO public.recipe_ingredients VALUES (686, 10, 50, 'г', 11);
INSERT INTO public.recipe_ingredients VALUES (687, 10, 10, 'г', 55);
INSERT INTO public.recipe_ingredients VALUES (688, 82, 250, 'г', 17);
INSERT INTO public.recipe_ingredients VALUES (689, 82, 150, 'г', 16);
INSERT INTO public.recipe_ingredients VALUES (690, 82, 100, 'г', 3);
INSERT INTO public.recipe_ingredients VALUES (691, 82, 50, 'мл', 89);
INSERT INTO public.recipe_ingredients VALUES (692, 82, 15, 'мл', 68);
INSERT INTO public.recipe_ingredients VALUES (693, 62, 200, 'г', 17);
INSERT INTO public.recipe_ingredients VALUES (694, 62, 150, 'г', 8);
INSERT INTO public.recipe_ingredients VALUES (695, 62, 50, 'г', 3);
INSERT INTO public.recipe_ingredients VALUES (696, 62, 80, 'г', 86);
INSERT INTO public.recipe_ingredients VALUES (697, 62, 700, 'мл', 69);
INSERT INTO public.recipe_ingredients VALUES (698, 42, 300, 'г', 115);
INSERT INTO public.recipe_ingredients VALUES (699, 42, 150, 'г', 86);
INSERT INTO public.recipe_ingredients VALUES (700, 42, 100, 'г', 16);
INSERT INTO public.recipe_ingredients VALUES (701, 42, 10, 'мл', 1);
INSERT INTO public.recipe_ingredients VALUES (702, 81, 400, 'г', 98);
INSERT INTO public.recipe_ingredients VALUES (703, 81, 150, 'г', 3);
INSERT INTO public.recipe_ingredients VALUES (704, 81, 15, 'мл', 68);
INSERT INTO public.recipe_ingredients VALUES (705, 81, 5, 'г', 55);
INSERT INTO public.recipe_ingredients VALUES (641, 44, 5, 'мл', 12);


--
-- Data for Name: recipe_nutrients_per_100g; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.recipe_nutrients_per_100g VALUES (3, 99.4, 8.68, 5.86, 3.22, NULL, 87.6);
INSERT INTO public.recipe_nutrients_per_100g VALUES (2, 210.57142857142858, 14.67142857142857, 8.071428571428571, 21.857142857142858, NULL, 42.285714285714285);
INSERT INTO public.recipe_nutrients_per_100g VALUES (1, 200, 17, 1.9333333333333333, 26, NULL, 47);
INSERT INTO public.recipe_nutrients_per_100g VALUES (4, 98, 10.2, 2.1, 10.5, 1.8, 180);
INSERT INTO public.recipe_nutrients_per_100g VALUES (5, 95, 3.8, 2.5, 16, 6, 40);
INSERT INTO public.recipe_nutrients_per_100g VALUES (6, 55, 5.5, 1, 7, 0.8, 210);
INSERT INTO public.recipe_nutrients_per_100g VALUES (7, 75, 12, 2.2, 2.5, 1, 70);
INSERT INTO public.recipe_nutrients_per_100g VALUES (8, 115, 8, 2.5, 16, 1.2, 95);
INSERT INTO public.recipe_nutrients_per_100g VALUES (9, 48, 2.5, 0.5, 9.5, 1, 160);
INSERT INTO public.recipe_nutrients_per_100g VALUES (11, 140, 13.5, 2.8, 16, 1, 45);
INSERT INTO public.recipe_nutrients_per_100g VALUES (12, 110, 8.5, 7, 3, 2, 95);
INSERT INTO public.recipe_nutrients_per_100g VALUES (13, 45, 2, 2.5, 4, 1.5, 210);
INSERT INTO public.recipe_nutrients_per_100g VALUES (14, 118, 11, 2.5, 13, 1.2, 60);
INSERT INTO public.recipe_nutrients_per_100g VALUES (15, 58, 6, 1.5, 6, 0.8, 220);
INSERT INTO public.recipe_nutrients_per_100g VALUES (16, 165, 12, 5.5, 18, 8, 85);
INSERT INTO public.recipe_nutrients_per_100g VALUES (17, 145, 18, 7.5, 2, 0.5, 110);
INSERT INTO public.recipe_nutrients_per_100g VALUES (18, 55, 2, 1, 10, 3, 180);
INSERT INTO public.recipe_nutrients_per_100g VALUES (19, 65, 2.5, 0.8, 13, 1, 190);
INSERT INTO public.recipe_nutrients_per_100g VALUES (20, 82, 12, 2.8, 3, 1.5, 70);
INSERT INTO public.recipe_nutrients_per_100g VALUES (21, 98, 3.5, 2.5, 16, 5, 35);
INSERT INTO public.recipe_nutrients_per_100g VALUES (22, 165, 9.5, 7.5, 17, 2, 210);
INSERT INTO public.recipe_nutrients_per_100g VALUES (23, 120, 4.5, 3, 20, 4, 280);
INSERT INTO public.recipe_nutrients_per_100g VALUES (24, 128, 10.5, 4.2, 14, 2.5, 95);
INSERT INTO public.recipe_nutrients_per_100g VALUES (25, 98, 9, 3, 10, 1.2, 55);
INSERT INTO public.recipe_nutrients_per_100g VALUES (26, 72, 8.5, 2, 5.5, 3, 65);
INSERT INTO public.recipe_nutrients_per_100g VALUES (27, 155, 12, 10, 3, 1.5, 210);
INSERT INTO public.recipe_nutrients_per_100g VALUES (28, 125, 5.5, 4.5, 17, 1, 45);
INSERT INTO public.recipe_nutrients_per_100g VALUES (29, 52, 2.5, 2.5, 5.5, 1.5, 190);
INSERT INTO public.recipe_nutrients_per_100g VALUES (30, 148, 11, 7, 13, 2, 130);
INSERT INTO public.recipe_nutrients_per_100g VALUES (31, 165, 12.5, 5.8, 17.2, 2.1, 320);
INSERT INTO public.recipe_nutrients_per_100g VALUES (32, 108, 3.5, 4.2, 15, 2.5, 380);
INSERT INTO public.recipe_nutrients_per_100g VALUES (33, 158, 19.2, 6.8, 5.5, 4, 620);
INSERT INTO public.recipe_nutrients_per_100g VALUES (34, 82, 6.5, 1.8, 10.2, 1.1, 280);
INSERT INTO public.recipe_nutrients_per_100g VALUES (35, 110, 5.5, 7.2, 6.8, 2, 310);
INSERT INTO public.recipe_nutrients_per_100g VALUES (36, 152, 11.5, 3.8, 18, 0.8, 220);
INSERT INTO public.recipe_nutrients_per_100g VALUES (37, 175, 14.2, 10.5, 7.5, 3, 410);
INSERT INTO public.recipe_nutrients_per_100g VALUES (38, 75, 2, 4.8, 7.2, 3.1, 450);
INSERT INTO public.recipe_nutrients_per_100g VALUES (39, 185, 7.5, 7.2, 23.5, 1.2, 260);
INSERT INTO public.recipe_nutrients_per_100g VALUES (40, 162, 13.8, 6.5, 14.2, 1.8, 370);
INSERT INTO public.recipe_nutrients_per_100g VALUES (41, 95, 10.5, 4.2, 5, 2, 80);
INSERT INTO public.recipe_nutrients_per_100g VALUES (43, 105, 3, 3.2, 17, 2, 120);
INSERT INTO public.recipe_nutrients_per_100g VALUES (45, 85, 5.5, 1, 15, 1, 210);
INSERT INTO public.recipe_nutrients_per_100g VALUES (46, 125, 10, 4, 14, 1.5, 95);
INSERT INTO public.recipe_nutrients_per_100g VALUES (47, 115, 2.5, 9, 6, 2, 35);
INSERT INTO public.recipe_nutrients_per_100g VALUES (48, 82, 10, 3.5, 3, 1, 50);
INSERT INTO public.recipe_nutrients_per_100g VALUES (49, 195, 10, 6.5, 25, 2, 280);
INSERT INTO public.recipe_nutrients_per_100g VALUES (50, 92, 7.5, 2.8, 10, 2.5, 160);
INSERT INTO public.recipe_nutrients_per_100g VALUES (51, 120, 3, 2.5, 22, 2, 35);
INSERT INTO public.recipe_nutrients_per_100g VALUES (52, 95, 11, 3.5, 4, 1, 80);
INSERT INTO public.recipe_nutrients_per_100g VALUES (53, 145, 9, 10, 4, 1.5, 120);
INSERT INTO public.recipe_nutrients_per_100g VALUES (54, 55, 2, 1, 10, 1, 210);
INSERT INTO public.recipe_nutrients_per_100g VALUES (55, 110, 4, 3, 18, 3, 140);
INSERT INTO public.recipe_nutrients_per_100g VALUES (59, 48, 1.5, 0.8, 9, 1, 190);
INSERT INTO public.recipe_nutrients_per_100g VALUES (63, 105, 14, 3.5, 3, 1, 180);
INSERT INTO public.recipe_nutrients_per_100g VALUES (64, 128, 10, 4.5, 15, 2, 110);
INSERT INTO public.recipe_nutrients_per_100g VALUES (66, 58, 5.5, 1.2, 7, 1, 210);
INSERT INTO public.recipe_nutrients_per_100g VALUES (67, 175, 8, 8.5, 18, 2, 240);
INSERT INTO public.recipe_nutrients_per_100g VALUES (68, 85, 6.5, 4.5, 5, 2.5, 70);
INSERT INTO public.recipe_nutrients_per_100g VALUES (70, 35, 2, 0.5, 6.5, 2, 25);
INSERT INTO public.recipe_nutrients_per_100g VALUES (71, 85, 9.5, 2, 7, 1.5, 95);
INSERT INTO public.recipe_nutrients_per_100g VALUES (73, 118, 4.5, 3, 20, 4, 250);
INSERT INTO public.recipe_nutrients_per_100g VALUES (74, 85, 8, 3.5, 5, 2, 65);
INSERT INTO public.recipe_nutrients_per_100g VALUES (76, 150, 6, 6.5, 19, 1.5, 280);
INSERT INTO public.recipe_nutrients_per_100g VALUES (77, 118, 10, 3.5, 13, 1.5, 60);
INSERT INTO public.recipe_nutrients_per_100g VALUES (78, 45, 1.8, 0.6, 9, 1.5, 175);
INSERT INTO public.recipe_nutrients_per_100g VALUES (79, 185, 9, 7, 23, 2, 210);
INSERT INTO public.recipe_nutrients_per_100g VALUES (80, 120, 4.5, 6.5, 13, 2, 40);
INSERT INTO public.recipe_nutrients_per_100g VALUES (83, 48, 2.5, 0.8, 8.5, 1, 170);
INSERT INTO public.recipe_nutrients_per_100g VALUES (85, 85, 5.5, 4.5, 5, 2.5, 110);
INSERT INTO public.recipe_nutrients_per_100g VALUES (86, 128, 10, 4, 15, 1.5, 95);
INSERT INTO public.recipe_nutrients_per_100g VALUES (87, 55, 5, 1.2, 6.5, 1, 190);
INSERT INTO public.recipe_nutrients_per_100g VALUES (88, 165, 7.5, 9, 16, 2, 220);
INSERT INTO public.recipe_nutrients_per_100g VALUES (89, 95, 11, 4, 4, 2, 85);
INSERT INTO public.recipe_nutrients_per_100g VALUES (90, 120, 9, 3.5, 14, 1, 100);
INSERT INTO public.recipe_nutrients_per_100g VALUES (91, 125, 10.5, 4, 14, 2, 110);
INSERT INTO public.recipe_nutrients_per_100g VALUES (92, 85, 5.5, 1, 15, 1, 210);
INSERT INTO public.recipe_nutrients_per_100g VALUES (93, 155, 7.5, 7, 17, 2.5, 190);
INSERT INTO public.recipe_nutrients_per_100g VALUES (94, 110, 8, 7, 5, 2, 55);
INSERT INTO public.recipe_nutrients_per_100g VALUES (96, 145, 12, 8, 5, 1.5, 140);
INSERT INTO public.recipe_nutrients_per_100g VALUES (98, 115, 4, 3, 20, 4, 260);
INSERT INTO public.recipe_nutrients_per_100g VALUES (100, 125, 9, 3.5, 15, 1, 100);
INSERT INTO public.recipe_nutrients_per_100g VALUES (72, 75, 6, 2.5, 8, 1, 220);
INSERT INTO public.recipe_nutrients_per_100g VALUES (97, 60, 2.5, 2.5, 7, 1.5, 170);
INSERT INTO public.recipe_nutrients_per_100g VALUES (57, 110, 9, 3.5, 12, 1, 90);
INSERT INTO public.recipe_nutrients_per_100g VALUES (69, 145, 10, 4, 17, 0.5, 350);
INSERT INTO public.recipe_nutrients_per_100g VALUES (95, 125, 5, 3, 20, 2, 130);
INSERT INTO public.recipe_nutrients_per_100g VALUES (44, 210, 7, 15, 12, 1, 180);
INSERT INTO public.recipe_nutrients_per_100g VALUES (65, 120, 4, 2, 22, 10, 40);
INSERT INTO public.recipe_nutrients_per_100g VALUES (60, 175, 12, 7, 18, 0.5, 160);
INSERT INTO public.recipe_nutrients_per_100g VALUES (84, 155, 7, 6, 20, 1.5, 150);
INSERT INTO public.recipe_nutrients_per_100g VALUES (58, 120, 3, 1.5, 25, 8, 40);
INSERT INTO public.recipe_nutrients_per_100g VALUES (75, 115, 4, 3.5, 18, 2, 80);
INSERT INTO public.recipe_nutrients_per_100g VALUES (56, 125, 8, 6, 12, 7, 100);
INSERT INTO public.recipe_nutrients_per_100g VALUES (61, 110, 1.5, 9, 5, 2, 300);
INSERT INTO public.recipe_nutrients_per_100g VALUES (99, 210, 7, 16, 12, 6, 220);
INSERT INTO public.recipe_nutrients_per_100g VALUES (10, 110, 16, 4, 1, 0.5, 90);
INSERT INTO public.recipe_nutrients_per_100g VALUES (82, 95, 9, 3.5, 6, 2, 130);
INSERT INTO public.recipe_nutrients_per_100g VALUES (62, 65, 6, 1, 8, 1, 190);
INSERT INTO public.recipe_nutrients_per_100g VALUES (42, 135, 14, 6, 5, 2, 110);
INSERT INTO public.recipe_nutrients_per_100g VALUES (81, 190, 16, 12, 3, 1, 90);


--
-- Data for Name: recipes; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.recipes VALUES (73, 'Паста с томатами', 'Быстрая паста с томатным соусом и базиликом – классика итальянской кухни.', 'варка', 20, 1, '1. Пасту отварите в подсоленной воде до аль денте, откиньте на дуршлаг. 2. В сковороде разогрейте масло, добавьте томатный соус и прогрейте 2 минуты. 3. Добавьте мелко нарезанный базилик, перемешайте. 4. Выложите пасту в соус, перемешайте и прогрейте 1 минуту. 5. Подавайте с тёртым сыром по желанию.');
INSERT INTO public.recipes VALUES (11, 'Гречка с курицей на пару', 'Полностью паровое блюдо: рассыпчатая гречка и нежная курица с морковью. Идеально для диет, исключающих жарку.', 'варка', 30, 1, '1. Гречку переберите, промойте, залейте 1.5 стаканами воды, варите до готовности 20 минут. 2. Куриное филе нарежьте кусочками, выложите в пароварку вместе с нарезанной морковью. 3. Готовьте курицу на пару 20–25 минут. 4. Подавайте гречку с курицей и морковью, при желании посыпьте зеленью.');
INSERT INTO public.recipes VALUES (12, 'Омлет на пару', 'Нежнейший омлет, приготовленный на пару. Без жарки, с минимальным количеством жира — идеальный диетический завтрак.', 'варка', 15, 1, '1. В миске взбейте яйца с молоком и щепоткой соли до однородности. 2. Форму для пароварки смажьте маслом (или используйте силиконовую). 3. Вылейте яичную смесь в форму, поставьте в пароварку. 4. Готовьте на пару 10–12 минут до полного застывания. 5. Готовый омлет аккуратно переложите на тарелку, можно подавать с зеленью.');
INSERT INTO public.recipes VALUES (74, 'Салат с рыбой', 'Салат с отварной рыбой и свежими овощами в йогуртовой заправке.', 'без обработки', 10, 1, '1. Рыбу отварите или запеките, остудите и разберите на кусочки. 2. Огурец, помидор и салат нарежьте. 3. Для заправки смешайте йогурт с рубленой петрушкой. 4. Смешайте все ингредиенты, заправьте соусом. 5. Подавайте сразу.');
INSERT INTO public.recipes VALUES (1, 'Отварная курица с рисом', 'Классическое диетическое блюдо: отварная курица с рассыпчатым рисом. Без специй и жарки, идеально для восстановления после болезней ЖКТ.', 'варка', 40, 1, '1. Рис тщательно промойте в холодной воде до прозрачности. Залейте 1 стаканом воды, добавьте щепотку соли. Варите на медленном огне под крышкой 15–20 минут до полного впитывания воды. 2. Куриное филе промойте, залейте холодной водой (чтобы покрывало мясо), доведите до кипения, снимите пену. Уменьшите огонь и варите 20–25 минут до готовности. 3. Готовую курицу нарежьте небольшими кусочками или разберите на волокна. 4. Подавайте рис с курицей, при желании можно добавить немного сливочного масла или зелени. Блюдо не требует специй, подходит для щадящего питания.');
INSERT INTO public.recipes VALUES (13, 'Суп-пюре из кабачка', 'Лёгкий крем-суп из кабачка со сливками. Нежный, низкокалорийный, подходит для щадящего питания.', 'варка', 25, 1, '1. Кабачок очистите, нарежьте кубиками. Лук мелко нарежьте. 2. В кастрюле обжарьте лук без масла с небольшим количеством бульона 2 минуты. 3. Добавьте кабачок, залейте бульоном, варите 15 минут до мягкости. 4. Измельчите суп блендером до состояния пюре. 5. Влейте сливки, перемешайте, прогрейте 1 минуту. Подавайте с сухариками или зеленью.');
INSERT INTO public.recipes VALUES (14, 'Рис с индейкой', 'Диетическое блюдо из индейки с рисом и морковью, тушёное в бульоне. Без жарки, с низким содержанием жира.', 'тушение', 35, 1, '1. Индейку нарежьте небольшими кусочками. Морковь натрите на крупной тёрке. 2. В кастрюле с толстым дном разогрейте немного бульона, выложите индейку и обжарьте 3–4 минуты без масла. 3. Добавьте морковь и промытый рис, залейте бульоном (чтобы покрыло). 4. Накройте крышкой и тушите на медленном огне 25–30 минут до готовности риса. 5. Посолите по вкусу в конце. Подавайте горячим.');
INSERT INTO public.recipes VALUES (21, 'Рисовая каша на молоке', 'Классическая рисовая каша на молоке. Нежная, сладкая, подходит для завтрака. Содержит молочный белок и медленные углеводы.', 'варка', 20, 1, '1. Рис промойте до прозрачной воды. 2. В кастрюле доведите молоко до кипения, добавьте рис и сахар. 3. Варите на медленном огне 20–25 минут, постоянно помешивая, чтобы не пригорело. 4. Когда рис станет мягким, а каша загустеет — снимите с огня. 5. Накройте крышкой и дайте настояться 5 минут. Подавайте тёплой, можно добавить кусочек сливочного масла.');
INSERT INTO public.recipes VALUES (41, 'Салат с тунцом', 'Лёгкий салат с отварным тунцом, свежими овощами и йогуртовой заправкой. Богат белком и омега-3.', 'без обработки', 10, 1, '1. Тунец отварите в подсоленной воде 5–7 минут, остудите и нарежьте кубиками. 2. Огурец, помидор и салат нарежьте произвольно. 3. Для заправки смешайте йогурт, лимонный сок и рубленую петрушку. 4. Смешайте все ингредиенты в салатнике, заправьте соусом. 5. Подавайте сразу, можно украсить долькой лимона.');
INSERT INTO public.recipes VALUES (43, 'Булгур с овощами', 'Полезный гарнир из булгура с тушёными овощами. Булгур – цельнозерновая крупа, богатая клетчаткой.', 'тушение', 25, 1, '1. Булгур промойте, залейте 1.5 стаканами воды, варите 15 минут до готовности. 2. Овощи (перец, цукини, морковь, лук) нарежьте соломкой. 3. В глубокой сковороде разогрейте масло, обжарьте овощи 5 минут, добавьте бульон и тушите 10 минут. 4. Смешайте готовый булгур с овощами, прогрейте 2 минуты. 5. Подавайте как гарнир или самостоятельное блюдо.');
INSERT INTO public.recipes VALUES (51, 'Рис с овощами', 'Яркий и полезный гарнир из риса с морковью, перцем и зелёным горошком. Подходит для вегетарианцев.', 'варка', 20, 1, '1. Рис промойте до прозрачной воды, отварите в подсоленной воде 15–20 минут. 2. Морковь, перец и лук нарежьте мелким кубиком. 3. В сковороде разогрейте масло, обжарьте лук и морковь 3 минуты, добавьте перец и горошек, жарьте ещё 2 минуты. 4. Смешайте готовый рис с овощами, прогрейте 1 минуту. 5. Подавайте как гарнир к мясу или рыбе.');
INSERT INTO public.recipes VALUES (52, 'Курица с брокколи', 'Нежное диетическое блюдо: курица с брокколи в собственном соку. Богато белком и витаминами.', 'тушение', 25, 1, '1. Курицу нарежьте кусочками, лук мелко порубите. 2. Брокколи разберите на соцветия. 3. В глубокой сковороде разогрейте масло, обжарьте курицу и лук 5 минут. 4. Добавьте брокколи и бульон, накройте крышкой и тушите 10–12 минут до мягкости. 5. Посолите по вкусу, подавайте с рисом или картофелем.');
INSERT INTO public.recipes VALUES (71, 'Курица с овощами', 'Овощное рагу с курицей – лёгкое и полезное блюдо. Без жарки, на бульоне.', 'тушение', 30, 1, '1. Курицу нарежьте кусочками, овощи – соломкой. 2. В глубокой сковороде разогрейте бульон, обжарьте лук и морковь 3 минуты. 3. Добавьте курицу, цукини и перец, влейте оставшийся бульон. 4. Накройте крышкой и тушите 20–25 минут до мягкости. 5. Посолите в конце, подавайте с рисом или гречкой.');
INSERT INTO public.recipes VALUES (91, 'Курица с булгуром', 'Сытное блюдо с курицей, булгуром и овощами. Булгур – полезная цельнозерновая крупа.', 'тушение', 30, 1, '1. Булгур промойте, залейте 1.5 стаканами воды, варите 15 минут. 2. Курицу нарежьте кубиками, лук, перец и цукини – соломкой. 3. В глубокой сковороде разогрейте масло, обжарьте курицу 5 минут, добавьте овощи и жарьте ещё 5 минут. 4. Влейте бульон, добавьте готовый булгур, перемешайте и тушите 5 минут. 5. Подавайте горячим, посыпав зеленью.');
INSERT INTO public.recipes VALUES (92, 'Суп с чечевицей и овощами', 'Сытный суп из чечевицы с картофелем, морковью и луком. Богат растительным белком и клетчаткой.', 'варка', 35, 1, '1. Чечевицу переберите, промойте, замочите на 30 минут (по желанию). 2. В кастрюле доведите бульон до кипения, добавьте чечевицу и нарезанный кубиками картофель. 3. Варите 15 минут, затем добавьте нарезанные морковь и лук. 4. Варите ещё 15 минут до мягкости. 5. Посолите в конце, при подаче посыпьте петрушкой.');
INSERT INTO public.recipes VALUES (66, 'Суп куриный', 'Домашний куриный суп с картофелем, морковью и луком. Согревает и напоминает о детстве.', 'варка', 40, 1, '1. Курицу залейте холодной водой, доведите до кипения, снимите пену. 2. Добавьте нарезанный кубиками картофель, варите 10 минут. 3. Морковь и лук нарежьте мелкими кубиками, добавьте в суп. 4. Варите ещё 15–20 минут до мягкости овощей. 5. Посолите в конце, при подаче посыпьте рубленой петрушкой.');
INSERT INTO public.recipes VALUES (67, 'Паста с грибами', 'Нежная паста с шампиньонами в сливочно-сырном соусе. Классика итальянской кухни.', 'варка', 25, 1, '1. Пасту отварите в подсоленной воде до состояния аль денте, откиньте на дуршлаг. 2. Грибы и лук мелко нарежьте. 3. На сковороде разогрейте масло, обжарьте лук и грибы 7–10 минут до выпаривания жидкости. 4. Влейте сливки, добавьте тёртый сыр, тушите 3 минуты до загустения. 5. Смешайте пасту с соусом, прогрейте 1 минуту. Подавайте с зеленью.');
INSERT INTO public.recipes VALUES (2, 'Гречка с тушёной говядиной', 'Сытное и полезное блюдо из гречки и нежной говядины, тушёной с луком. Без острых специй, подходит для диет с ограничением жареного.', 'тушение', 60, 1, '1. Гречку переберите, удалите чёрные зёрна, промойте в нескольких водах. Залейте водой в пропорции 1:2 (на 1 стакан гречки 2 стакана воды), добавьте щепотку соли. Варите после закипания на медленном огне 20–25 минут до полного выпаривания воды. 2. Говядину нарежьте небольшими кубиками (2×2 см). На антипригарной сковороде без масла обжарьте мясо 5 минут до румяной корочки (если нужно, добавьте 1 ч.л. растительного масла). 3. Добавьте мелко нарезанную луковицу, обжаривайте ещё 3–4 минуты. Залейте 1 стаканом горячей воды, накройте крышкой и тушите на медленном огне 40–50 минут до мягкости мяса. 4. Смешайте готовую гречку с тушёной говядиной, дайте настояться под крышкой 10 минут. Подавайте горячим.');
INSERT INTO public.recipes VALUES (3, 'Омлет с брокколи', 'Нежный белковый завтрак с брокколи. Омлет готовится без жарки, на слабом огне под крышкой — идеально для диетического питания.', 'жарка', 15, 1, '1. Брокколи разберите на соцветия, промойте. Отварите в подсоленной воде 3–4 минуты до полуготовности, откиньте на дуршлаг. 2. В миске взбейте 2 яйца с 2 ст.л. молока (или воды), добавьте щепотку соли. 3. Разогрейте сковороду с антипригарным покрытием, слегка смажьте маслом. Выложите брокколи, залейте яичной смесью. 4. Готовьте на слабом огне под крышкой 5–7 минут до полного застывания яиц. 5. Готовый омлет переложите на тарелку, при желании посыпьте свежей зеленью. Подавайте тёплым.');
INSERT INTO public.recipes VALUES (4, 'Курица с рисом и кабачком', 'Нежное тушёное блюдо из курицы, риса и кабачка. Готовится без жарки, подходит для щадящих диет.', 'тушение', 35, 1, '1. Куриное филе промойте, нарежьте небольшими кусочками (2–3 см). 2. Кабачок очистите от кожуры (если старая) и нарежьте кубиками. 3. В кастрюле разогрейте куриный бульон, положите курицу и тушите на медленном огне 10 минут. 4. Добавьте кабачок и промытый рис, залейте водой так, чтобы она покрыла ингредиенты на 1 см. 5. Готовьте под крышкой 20 минут до мягкости риса и курицы. При необходимости добавьте щепотку соли. Подавайте тёплым.');
INSERT INTO public.recipes VALUES (5, 'Овсяная каша с яблоком', 'Полезный завтрак из овсянки с яблоком. Готовится на молоке или воде, без сахара — естественная сладость от фрукта.', 'варка', 10, 1, '1. Овсяные хлопья залейте молоком (или водой) в кастрюле. 2. Доведите до кипения, убавьте огонь и варите 5–7 минут, помешивая. 3. Яблоко очистите от кожуры, удалите сердцевину, нарежьте мелкими кубиками. 4. Добавьте яблоко в кашу за 2 минуты до готовности, перемешайте. 5. При подаче можно добавить щепотку корицы (по желанию).');
INSERT INTO public.recipes VALUES (6, 'Суп с курицей и рисом', 'Лёгкий куриный суп с рисом и овощами. Подходит для диетического питания, хорошо усваивается.', 'варка', 40, 1, '1. Куриное филе залейте холодной водой, доведите до кипения, снимите пену. 2. Добавьте промытый рис, варите 10 минут. 3. Морковь и лук очистите, нарежьте мелкими кубиками, добавьте в суп. 4. Варите ещё 15–20 минут до готовности риса и мяса. 5. Посолите по вкусу в конце. Подавайте с зеленью.');
INSERT INTO public.recipes VALUES (7, 'Паровая рыба с овощами', 'Диетическое блюдо на пару: рыба и брокколи с морковью. Сохраняет максимум полезных веществ.', 'варка', 25, 1, '1. Рыбу (треску) промойте, обсушите, слегка посолите. 2. Овощи (брокколи, морковь) нарежьте крупными кусками. 3. Выложите рыбу и овощи в пароварку или на решётку над кастрюлей с кипящей водой. 4. Готовьте 20–25 минут до мягкости рыбы. 5. Подавайте с долькой лимона (по желанию).');
INSERT INTO public.recipes VALUES (8, 'Картофельное пюре с курицей', 'Классическое комфортное блюдо: нежное картофельное пюре с отварной курицей. Без жарки и специй.', 'варка', 30, 1, '1. Картофель очистите, нарежьте крупными кусками, отварите в подсоленной воде 20 минут до мягкости. 2. Куриное филе отварите отдельно 20 минут, затем нарежьте кубиками. 3. Слейте воду с картофеля, разомните в пюре, добавляя тёплое молоко и щепотку соли. 4. Подавайте пюре с кусочками курицы. При желании добавьте немного сливочного масла.');
INSERT INTO public.recipes VALUES (9, 'Рисовый суп с овощами', 'Лёгкий овощной суп с рисом. Готовится быстро, подходит для детского и диетического питания.', 'варка', 30, 1, '1. Вскипятите куриный бульон (или воду). 2. Рис промойте, положите в кипящий бульон, варите 10 минут. 3. Картофель, морковь и лук очистите, нарежьте мелкими кубиками. 4. Добавьте овощи в суп, варите ещё 15–20 минут до мягкости картофеля. 5. Посолите по вкусу, при подаче посыпьте зеленью.');
INSERT INTO public.recipes VALUES (15, 'Куриный суп с овсянкой', 'Полезный куриный суп с овсяными хлопьями. Быстрый в приготовлении, хорошо насыщает, подходит для диет.', 'варка', 30, 1, '1. Куриное филе залейте водой, доведите до кипения, снимите пену. 2. Добавьте нарезанную морковь и лук, варите 15 минут. 3. Овсяные хлопья всыпьте в суп, варите ещё 10–15 минут, помешивая. 4. Посолите по вкусу. При подаче посыпьте свежей зеленью (укропом или петрушкой).');
INSERT INTO public.recipes VALUES (16, 'Запеканка из творога', 'Классическая творожная запеканка. Нежная, сладкая, но с контролируемым количеством сахара. Можно подавать со сметаной или ягодами.', 'запекание', 35, 1, '1. Творог разомните вилкой, добавьте яйцо и сахар, тщательно перемешайте. 2. Форму для запекания смажьте маслом или застелите пергаментом. 3. Выложите творожную массу, разровняйте. 4. Запекайте в разогретой до 180°C духовке 25–30 минут до золотистой корочки. 5. Дайте запеканке немного остыть, затем нарежьте порционными кусочками.');
INSERT INTO public.recipes VALUES (17, 'Паровые котлеты из курицы', 'Сочные паровые куриные котлеты без масла. Отличный источник белка, подходит для диет при заболеваниях ЖКТ и печени.', 'варка', 30, 1, '1. Куриное филе пропустите через мясорубку или измельчите в блендере. 2. Лук мелко нарежьте или натрите. 3. Смешайте фарш с луком, яйцом, добавьте щепотку соли и перца (по желанию). 4. Сформируйте небольшие котлеты, выложите их в пароварку. 5. Готовьте на пару 20–25 минут. Подавайте с гарниром из овощей или рисом.');
INSERT INTO public.recipes VALUES (18, 'Овощное рагу', 'Ароматное овощное рагу без мяса. Можно готовить с любыми сезонными овощами. Подходит для вегетарианского и диетического питания.', 'тушение', 30, 1, '1. Все овощи очистите и нарежьте кубиками одинакового размера. 2. В кастрюле с толстым дном разогрейте 2 ст.л. бульона, обжарьте лук и морковь 3 минуты. 3. Добавьте картофель, кабачок, капусту, томатный соус. Залейте бульоном так, чтобы почти покрыть овощи. 4. Накройте крышкой и тушите на медленном огне 25–30 минут до мягкости всех овощей. 5. Посолите в конце, подавайте с зеленью.');
INSERT INTO public.recipes VALUES (19, 'Суп с перловкой', 'Наваристый суп с перловкой и овощами. Благодаря замачиванию крупа разваривается быстрее и лучше усваивается.', 'варка', 40, 1, '1. Перловку замочите в холодной воде на 1–2 часа (или на ночь). 2. Воду слейте, залейте свежим бульоном, варите 30 минут. 3. Картофель, морковь и лук нарежьте кубиками, добавьте в суп. 4. Варите ещё 20 минут до мягкости картофеля и перловки. 5. Посолите по вкусу, при подаче посыпьте зеленью.');
INSERT INTO public.recipes VALUES (20, 'Тушёная рыба с морковью', 'Нежная рыба, тушёная с морковью и луком. Быстрое и полезное блюдо, богатое белком и омега-3.', 'тушение', 25, 1, '1. Рыбу нарежьте порционными кусками, слегка посолите. 2. Морковь натрите на крупной тёрке, лук мелко нарежьте. 3. В сковороде с антипригарным покрытием разогрейте масло, обжарьте лук и морковь 3 минуты. 4. Выложите рыбу, залейте бульоном, накройте крышкой. 5. Тушите на медленном огне 15–20 минут. Подавайте рыбу с овощами и соусом из сковороды.');
INSERT INTO public.recipes VALUES (54, 'Суп с картофелем', 'Классический овощной суп с картофелем и морковью на курином бульоне. Лёгкий и согревающий.', 'варка', 30, 1, '1. Картофель, морковь и лук очистите, нарежьте кубиками. 2. В кастрюле доведите бульон до кипения. 3. Положите картофель и варите 10 минут, затем добавьте морковь и лук. 4. Варите ещё 15 минут до мягкости овощей. 5. Посолите по вкусу, при подаче посыпьте рубленой петрушкой.');
INSERT INTO public.recipes VALUES (55, 'Паста с овощами', 'Вегетарианская паста с тушёными овощами в томатном соусе. Быстро, полезно, вкусно.', 'варка', 20, 1, '1. Пасту отварите в подсоленной воде до состояния аль денте, откиньте на дуршлаг. 2. Овощи (цукини, перец, морковь, лук) нарежьте соломкой. 3. В сковороде разогрейте масло, обжарьте овощи 5 минут, добавьте томатный соус и тушите ещё 3 минуты. 4. Смешайте пасту с овощным соусом, прогрейте 1 минуту. 5. Подавайте с тертым сыром по желанию.');
INSERT INTO public.recipes VALUES (76, 'Рис с овощами и яйцом', 'Жареный рис с яйцом, морковью и зелёным горошком – блюдо азиатской кухни.', 'жарка', 20, 1, '1. Рис отварите до готовности, остудите (лучше использовать вчерашний). 2. Яйца взбейте, морковь натрите, горошек разморозьте. 3. В воке разогрейте масло, вылейте яйца и обжарьте, помешивая, 1 минуту. 4. Добавьте рис, морковь, горошек и соевый соус. 5. Обжаривайте на сильном огне 3–4 минуты, постоянно перемешивая. Подавайте горячим.');
INSERT INTO public.recipes VALUES (77, 'Курица в духовке', 'Курица, запечённая с картофелем и морковью – классическое семейное блюдо.', 'запекание', 40, 1, '1. Курицу нарежьте порционными кусками, картофель – дольками, морковь – кружочками, лук – полукольцами. 2. Форму для запекания смажьте маслом, выложите курицу и овощи. 3. Посолите, поперчите по вкусу, добавьте веточки петрушки. 4. Запекайте при 190°C 35–40 минут до румяной корочки. 5. Подавайте горячим.');
INSERT INTO public.recipes VALUES (78, 'Суп с овощами', 'Лёгкий овощной суп с картофелем, капустой и цукини.', 'варка', 25, 1, '1. Все овощи нарежьте кубиками одинакового размера. 2. В кастрюле доведите бульон до кипения. 3. Положите картофель, варите 10 минут. 4. Добавьте морковь, лук, капусту и цукини, варите ещё 15 минут. 5. Посолите в конце, при подаче посыпьте зеленью.');
INSERT INTO public.recipes VALUES (79, 'Паста с сыром и зеленью', 'Нежная паста в сырном соусе с зеленью – быстрый и вкусный ужин.', 'варка', 20, 1, '1. Пасту отварите в подсоленной воде, откиньте на дуршлаг. 2. В сковороде растопите сливочное масло, добавьте молоко и тёртый сыр. 3. Помешивая, готовьте соус 2–3 минуты до загустения. 4. Добавьте рубленую зелень, перемешайте. 5. Смешайте пасту с соусом, прогрейте 1 минуту. Подавайте горячим.');
INSERT INTO public.recipes VALUES (80, 'Салат с киноа', 'Полезный салат с киноа, авокадо и свежими овощами. Богат белком и полезными жирами.', 'без обработки', 15, 1, '1. Киноа отварите в подсоленной воде 15 минут, остудите. 2. Огурец, помидор и авокадо нарежьте кубиками. 3. Для заправки смешайте йогурт и лимонный сок. 4. Смешайте киноа с овощами, заправьте соусом. 5. Подавайте охлаждённым или комнатной температуры.');
INSERT INTO public.recipes VALUES (83, 'Суп с брокколи', 'Лёгкий суп с брокколи, картофелем и морковью на курином бульоне.', 'варка', 25, 1, '1. Брокколи разберите на соцветия, картофель и морковь нарежьте кубиками, лук мелко порубите. 2. В кастрюле доведите бульон до кипения. 3. Положите картофель, варите 10 минут, затем добавьте морковь, лук и брокколи. 4. Варите ещё 10–15 минут до мягкости овощей. 5. Посолите по вкусу, при подаче можно добавить сметану или зелень.');
INSERT INTO public.recipes VALUES (22, 'Паста с курицей и грибами в сливочном соусе', 'Сытная паста с курицей, грибами и нежным сливочным соусом. Блюдо европейской кухни, богатое белком.', 'тушение', 35, 1, '1. Пасту отварите в подсоленной воде до состояния аль денте (следуйте инструкции на упаковке). 2. Курицу нарежьте небольшими кусочками, лук мелко порубите. 3. На сковороде разогрейте масло, обжарьте курицу и лук 5 минут. 4. Добавьте нарезанные шампиньоны, жарьте ещё 5 минут. 5. Влейте сливки, добавьте тёртый сыр, перемешайте и тушите 5 минут до загустения. 6. Смешайте соус с отварной пастой, прогрейте 1 минуту. Подавайте с зеленью.');
INSERT INTO public.recipes VALUES (85, 'Салат с овощами и сыром', 'Свежий салат с овощами, сыром и йогуртовой заправкой – лёгкий и полезный.', 'без обработки', 10, 1, '1. Огурец, помидор и перец нарежьте кубиками. 2. Сыр натрите на крупной тёрке. 3. Для заправки смешайте йогурт с рубленой петрушкой, добавьте щепотку соли и перца. 4. Смешайте овощи с сыром, заправьте соусом. 5. Подавайте сразу.');
INSERT INTO public.recipes VALUES (23, 'Паста с томатным соусом и базиликом', 'Простое и ароматное блюдо итальянской кухни. Паста с томатным соусом и свежим базиликом — идеальный быстрый ужин.', 'варка', 25, 1, '1. Пасту отварите согласно инструкции, откиньте на дуршлаг. 2. В сковороде разогрейте масло, добавьте томатный соус, прогрейте 2 минуты. 3. Добавьте мелко нарезанный базилик, перемешайте. 4. Выложите пасту в соус, перемешайте, прогрейте 1 минуту. 5. При подаче посыпьте тёртым сыром и украсьте листиком базилика.');
INSERT INTO public.recipes VALUES (24, 'Курица с булгуром и овощами', 'Полезное и сытное блюдо с курицей, булгуром и овощами. Булгур — цельнозерновая крупа, богатая клетчаткой.', 'тушение', 30, 1, '1. Булгур промойте, залейте 1.5 стаканами воды, варите 15 минут до готовности. 2. Курицу нарежьте кубиками, лук, перец и цукини — соломкой. 3. В воке или глубокой сковороде разогрейте масло, обжарьте курицу 5 минут. 4. Добавьте овощи, жарьте 5–7 минут, помешивая. 5. Влейте бульон, добавьте готовый булгур, перемешайте и тушите 3 минуты. Подавайте горячим.');
INSERT INTO public.recipes VALUES (25, 'Запечённая рыба с картофелем', 'Домашнее блюдо: запечённая рыба с картофелем и морковью. Полноценный ужин с минимумом масла.', 'запекание', 40, 1, '1. Картофель и морковь очистите, нарежьте кружочками. 2. Рыбу нарежьте порционными кусками, сбрызните лимонным соком. 3. Форму для запекания смажьте маслом, выложите слой картофеля, затем рыбу, затем морковь. 4. Посолите, поперчите (по желанию), накройте фольгой. 5. Запекайте при 180°C 35–40 минут. За 10 минут до готовности фольгу снимите для румяной корочки.');
INSERT INTO public.recipes VALUES (26, 'Салат с курицей и йогуртовой заправкой', 'Лёгкий и свежий салат с отварной курицей и йогуртовой заправкой. Идеален для обеда или ужина.', 'без обработки', 15, 1, '1. Куриное филе отварите до готовности, остудите и нарежьте кубиками. 2. Огурцы, помидоры и салат нарежьте крупными кусками. 3. Для заправки смешайте йогурт, лимонный сок, рубленую петрушку, щепотку соли и перца. 4. Смешайте все ингредиенты в салатнике, заправьте соусом. 5. Подавайте сразу, можно украсить семенами кунжута.');
INSERT INTO public.recipes VALUES (27, 'Омлет с сыром и зеленью', 'Быстрый и сытный завтрак: омлет с сыром и зеленью. Богат белком и кальцием.', 'жарка', 10, 1, '1. В миске взбейте яйца с молоком, добавьте щепотку соли. 2. Сыр натрите на мелкой тёрке, зелень мелко порубите. 3. На сковороде разогрейте масло, вылейте яичную смесь. 4. Когда низ схватится, посыпьте сыром и зеленью, накройте крышкой и готовьте на медленном огне 3–4 минуты. 5. Сложите омлет пополам или сверните рулетом. Подавайте горячим.');
INSERT INTO public.recipes VALUES (28, 'Гречка с грибами и луком', 'Классическая гречка с шампиньонами и луком. Простое, бюджетное и очень вкусное блюдо.', 'тушение', 25, 1, '1. Гречку переберите, промойте, отварите в подсоленной воде до готовности (20 минут). 2. Грибы и лук мелко нарежьте. 3. На сковороде разогрейте масло, обжарьте лук до прозрачности (2 минуты), добавьте грибы и жарьте 7–10 минут до выпаривания жидкости. 4. Смешайте готовую гречку с грибами и луком, добавьте бульон для сочности, прогрейте 2 минуты. 5. Подавайте как самостоятельное блюдо или гарнир.');
INSERT INTO public.recipes VALUES (29, 'Суп-пюре из брокколи', 'Нежный суп-пюре из брокколи со сливками. Яркий цвет, приятный вкус, много витаминов.', 'варка', 25, 1, '1. Брокколи разберите на соцветия, картофель и лук нарежьте кубиками. 2. В кастрюле обжарьте лук на небольшом количестве масла 2 минуты. 3. Добавьте брокколи, картофель, залейте бульоном. Варите 15–20 минут до мягкости. 4. Измельчите суп блендером до состояния пюре. 5. Влейте сливки, перемешайте, прогрейте 1 минуту. Подавайте с сухариками или семечками.');
INSERT INTO public.recipes VALUES (30, 'Курица в сливочном соусе с рисом', 'Нежнейшая курица в сливочном соусе с сыром. Отлично сочетается с рассыпчатым рисом — блюдо для всей семьи.', 'тушение', 30, 1, '1. Рис отварите до готовности. 2. Курицу нарежьте кусочками, лук мелко порубите. 3. На сковороде разогрейте масло, обжарьте курицу и лук 5–7 минут. 4. Влейте сливки, добавьте тёртый сыр, тушите 5 минут до загустения соуса. 5. Подавайте курицу в сливочном соусе с гарниром из риса, посыпав зеленью.');
INSERT INTO public.recipes VALUES (31, 'Рис с курицей и овощами по-азиатски', 'Ароматное азиатское блюдо: рис с курицей, болгарским перцем и морковью в соевом соусе. Быстро, вкусно, сытно.', 'жарка', 25, 1, '1. Рис промойте до прозрачной воды, отварите в подсоленной воде до готовности (15–20 минут). 2. Куриное филе нарежьте кубиками, овощи (перец, морковь, лук) – соломкой. 3. В воке или глубокой сковороде разогрейте масло, обжарьте курицу 3–4 минуты, добавьте овощи и жарьте ещё 3–5 минут. 4. Влейте соевый соус, перемешайте, готовьте 1 минуту. 5. Смешайте с отварным рисом, прогрейте всё вместе 1–2 минуты. Подавайте горячим, посыпав зелёным луком или кунжутом.');
INSERT INTO public.recipes VALUES (32, 'Удон с овощами', 'Лёгкое и быстрое блюдо с лапшой удон и свежими овощами. Отличный вариант для вегетарианского обеда (без мяса).', 'жарка', 20, 1, '1. Лапшу удон отварите согласно инструкции (обычно 5–7 минут), откиньте на дуршлаг. 2. Овощи (цукини, перец, морковь) нарежьте тонкой соломкой. 3. В воке разогрейте масло, обжарьте овощи на сильном огне 3–4 минуты. 4. Добавьте отваренную лапшу, влейте соевый соус, перемешайте и прогревайте 1 минуту. 5. Подавайте сразу, можно посыпать кунжутом.');
INSERT INTO public.recipes VALUES (33, 'Курица в соусе терияки', 'Нежная курица в густом соусе терияки – классика азиатской кухни. Идеально сочетается с рисом.', 'жарка', 25, 1, '1. Куриное филе нарежьте кусочками 3×3 см. 2. В сковороде разогрейте масло, обжарьте курицу на среднем огне до золотистой корочки (5–7 минут). 3. Добавьте соус терияки, перемешайте, накройте крышкой и тушите на медленном огне 10 минут. 4. Подавайте с отварным рисом или лапшой, посыпав зелёным луком.');
INSERT INTO public.recipes VALUES (34, 'Суп с рисовой лапшой', 'Лёгкий азиатский суп с рисовой лапшой, курицей и овощами. Быстрый, ароматный и низкокалорийный.', 'варка', 30, 1, '1. Куриный бульон доведите до кипения. 2. Рисовую лапшу разломайте на короткие полоски, опустите в кипящий бульон, варите 3–4 минуты (не переваривайте). 3. Добавьте нарезанные кусочки курицы, морковь и перец (нарезать соломкой). 4. Варите ещё 5 минут до готовности курицы. 5. Посолите по вкусу (бульон уже солёный), при подаче добавьте зелень и дольку лайма.');
INSERT INTO public.recipes VALUES (35, 'Тофу с овощами', 'Вегетарианское блюдо из тофу и овощей в соевом соусе. Источник растительного белка, подходит для веганов (без масла, если заменить).', 'жарка', 20, 1, '1. Тофу нарежьте кубиками 2 см, обсушите бумажным полотенцем. 2. Овощи (цукини, перец) нарежьте соломкой. 3. В сковороде разогрейте масло, обжарьте тофу до румяной корочки со всех сторон (5–7 минут). 4. Добавьте овощи, жарьте ещё 3–4 минуты. 5. Влейте соевый соус, перемешайте и прогрейте 1 минуту. Подавайте с рисом или лапшой.');
INSERT INTO public.recipes VALUES (36, 'Креветки с рисом', 'Пикантное блюдо из морепродуктов: нежные креветки с рисом и соевым соусом. Готовится за 20 минут.', 'жарка', 20, 1, '1. Рис промойте, отварите до готовности. 2. Креветки разморозьте (если замороженные), очистите. 3. На сковороде разогрейте масло, быстро обжарьте креветки на сильном огне 2–3 минуты до розового цвета. 4. Добавьте соевый соус, перемешайте, готовьте 30 секунд. 5. Смешайте креветки с рисом, прогрейте вместе 1 минуту. Подавайте с долькой лимона.');
INSERT INTO public.recipes VALUES (37, 'Курица с карри', 'Ароматная курица в пряном соусе карри на кокосовом молоке. Блюдо тайской кухни, согревает и насыщает.', 'тушение', 30, 1, '1. Куриное филе нарежьте кусочками, лук мелко порубите. 2. В сковороде разогрейте масло, обжарьте курицу и лук 5 минут. 3. Добавьте соус карри и кокосовое молоко, перемешайте. 4. Накройте крышкой и тушите на медленном огне 20 минут, периодически помешивая. 5. Подавайте с отварным рисом, украсив листьями кинзы или базилика.');
INSERT INTO public.recipes VALUES (38, 'Овощи в соевом соусе', 'Быстрый гарнир из свежих овощей, обжаренных в соевом соусе. Сохраняет хрусткость и витамины.', 'жарка', 15, 1, '1. Овощи (цукини, перец, морковь, лук) нарежьте соломкой. 2. В воке или сковороде разогрейте масло, обжарьте овощи на сильном огне 5–7 минут, постоянно помешивая (овощи должны остаться хрустящими). 3. Влейте соевый соус, перемешайте и готовьте ещё 1 минуту. 4. Подавайте как гарнир к мясу, рыбе или как самостоятельное вегетарианское блюдо.');
INSERT INTO public.recipes VALUES (39, 'Рис с яйцом по-китайски', 'Классический китайский жареный рис с яйцом. Простое, быстрое и очень вкусное блюдо из минимума ингредиентов.', 'жарка', 15, 1, '1. Рис отварите до готовности (лучше использовать охлаждённый вчерашний рис – он будет рассыпчатым). 2. Яйца взбейте в миске. 3. В воке разогрейте масло, вылейте яйца и, помешивая, обжарьте 1–2 минуты до образования мелких комочков. 4. Добавьте рис, соевый соус и мелко нарезанный лук (зелёный или репчатый). 5. Обжаривайте всё вместе на сильном огне 2–3 минуты, постоянно перемешивая. Подавайте горячим.');
INSERT INTO public.recipes VALUES (40, 'Лапша с курицей и имбирём', 'Ароматная лапша с курицей, имбирём и соевым соусом. Имбирь придаёт пикантность и свежесть блюду.', 'жарка', 20, 1, '1. Лапшу (яичную или пшеничную) отварите согласно инструкции, откиньте на дуршлаг. 2. Куриное филе нарежьте тонкими полосками, имбирь и лук мелко порубите. 3. В воке разогрейте масло, обжарьте курицу с имбирём и луком 5 минут до золотистого цвета. 4. Добавьте отваренную лапшу, влейте соевый соус, перемешайте. 5. Прогревайте всё вместе 1–2 минуты. Подавайте с кунжутом и зелёным луком.');
INSERT INTO public.recipes VALUES (45, 'Суп с чечевицей', 'Сытный суп из чечевицы с картофелем и морковью. Чечевица – источник растительного белка и железа.', 'варка', 35, 1, '1. Чечевицу переберите, промойте и замочите на 1 час (по желанию). 2. В кастрюле разогрейте немного масла, обжарьте лук и морковь 3 минуты. 3. Добавьте нарезанный картофель, чечевицу и залейте бульоном. 4. Варите 25–30 минут до мягкости чечевицы и картофеля. 5. Посолите в конце, подавайте с зеленью.');
INSERT INTO public.recipes VALUES (46, 'Курица с киноа', 'Полезное блюдо с курицей, киноа и овощами. Киноа – суперфуд, богатый белком и аминокислотами.', 'тушение', 30, 1, '1. Киноа промойте, отварите в подсоленной воде 15 минут. 2. Курицу нарежьте кубиками, лук, перец и цукини – соломкой. 3. На сковороде разогрейте масло, обжарьте курицу 5 минут, добавьте овощи и жарьте ещё 5 минут. 4. Влейте бульон, добавьте готовую киноа, перемешайте и тушите 5 минут. 5. Подавайте горячим, посыпав зеленью.');
INSERT INTO public.recipes VALUES (47, 'Салат с авокадо', 'Свежий салат с авокадо, огурцом и помидорами в йогуртовой заправке. Богат полезными жирами и витаминами.', 'без обработки', 10, 1, '1. Авокадо очистите, удалите косточку, нарежьте кубиками. 2. Огурец, помидор и салат нарежьте произвольно. 3. Для заправки смешайте йогурт и лимонный сок. 4. Аккуратно смешайте все ингредиенты, стараясь не размять авокадо. 5. Подавайте сразу, чтобы авокадо не потемнело.');
INSERT INTO public.recipes VALUES (48, 'Рыба с овощами', 'Лёгкое и полезное блюдо: запечённая треска с овощами. Минимум калорий, максимум вкуса.', 'запекание', 30, 1, '1. Треску нарежьте порционными кусками, сбрызните лимонным соком. 2. Овощи (цукини, перец, морковь) нарежьте крупными кусками. 3. Форму для запекания смажьте оливковым маслом, выложите рыбу и овощи. 4. Запекайте при 180°C 25–30 минут до готовности рыбы. 5. Подавайте с долькой лимона и свежей зеленью.');
INSERT INTO public.recipes VALUES (49, 'Паста с сыром', 'Быстрая и сытная паста с нежным сырным соусом. Классика, которая нравится и детям, и взрослым.', 'варка', 20, 1, '1. Пасту отварите в подсоленной воде до состояния аль денте, откиньте на дуршлаг. 2. В сковороде растопите сливочное масло, добавьте молоко и тёртый сыр. 3. Помешивая, готовьте соус на слабом огне 2–3 минуты до загустения. 4. Смешайте пасту с сырным соусом, прогрейте 1 минуту. 5. Подавайте горячим, посыпав чёрным перцем или зеленью.');
INSERT INTO public.recipes VALUES (50, 'Овощное рагу с курицей', 'Сытное овощное рагу с курицей. Блюдо-конструктор – можно использовать любые сезонные овощи.', 'тушение', 35, 1, '1. Курицу нарежьте кубиками, лук и морковь – мелко, остальные овощи – крупными кусками. 2. В кастрюле с толстым дном разогрейте масло, обжарьте курицу и лук 5 минут. 3. Добавьте морковь, картофель, цукини, капусту, томатный соус и бульон. 4. Накройте крышкой и тушите на медленном огне 25 минут. 5. Посолите в конце, подавайте с зеленью.');
INSERT INTO public.recipes VALUES (53, 'Омлет с грибами', 'Сытный омлет с шампиньонами и луком. Простой и вкусный завтрак или ужин.', 'жарка', 10, 1, '1. Яйца взбейте с молоком и щепоткой соли. 2. Грибы и лук мелко нарежьте. 3. На сковороде разогрейте масло, обжарьте лук и грибы 5–7 минут до выпаривания жидкости. 4. Залейте грибы яичной смесью, накройте крышкой и готовьте на слабом огне 5 минут. 5. Подавайте омлет горячим, посыпав зеленью.');
INSERT INTO public.recipes VALUES (59, 'Суп овощной', 'Лёгкий овощной суп с капустой и картофелем. Базовый рецепт, который можно варьировать.', 'варка', 25, 1, '1. Картофель, морковь, капусту и лук нарежьте кубиками. 2. В кастрюле доведите бульон до кипения. 3. Положите картофель и варите 10 минут, затем добавьте морковь, лук и капусту. 4. Варите ещё 15–20 минут до мягкости овощей. 5. Посолите в конце, при подаче посыпьте зеленью.');
INSERT INTO public.recipes VALUES (63, 'Курица тушёная', 'Нежная тушёная курица с луком и морковью. Без жарки, с минимальным количеством жира.', 'тушение', 30, 1, '1. Курицу нарежьте кусочками, лук и морковь – соломкой. 2. В кастрюле с толстым дном разогрейте немного бульона, обжарьте лук и морковь 3 минуты (без масла). 3. Добавьте курицу и бульон, накройте крышкой. 4. Тушите на медленном огне 25–30 минут до мягкости курицы. 5. Посолите в конце, подавайте с гарниром из риса или картофеля.');
INSERT INTO public.recipes VALUES (64, 'Булгур с курицей', 'Сытное блюдо с курицей, булгуром и овощами. Булгур – полезная цельнозерновая крупа.', 'тушение', 30, 1, '1. Булгур промойте, отварите в подсоленной воде 15 минут. 2. Курицу нарежьте кубиками, лук, перец и цукини – соломкой. 3. В глубокой сковороде разогрейте масло, обжарьте курицу 5 минут, добавьте овощи и жарьте ещё 5 минут. 4. Влейте бульон, добавьте готовый булгур, перемешайте и тушите 5 минут. 5. Подавайте горячим, посыпав зеленью.');
INSERT INTO public.recipes VALUES (68, 'Салат с яйцом', 'Лёгкий салат с варёными яйцами, свежими овощами и йогуртовой заправкой. Отличный вариант для лёгкого обеда.', 'без обработки', 10, 1, '1. Яйца отварите вкрутую (10 минут), остудите и нарежьте кубиками. 2. Огурец, помидор и салат нарежьте произвольно. 3. Для заправки смешайте йогурт с рубленой петрушкой, добавьте щепотку соли и перца. 4. Смешайте все ингредиенты в салатнике, заправьте соусом. 5. Подавайте сразу.');
INSERT INTO public.recipes VALUES (70, 'Овощи на пару', 'Полезный гарнир из овощей, приготовленных на пару. Сохраняет цвет, текстуру и витамины.', 'варка', 20, 1, '1. Брокколи разберите на соцветия, морковь нарежьте кружочками, цукини и перец – соломкой. 2. Выложите овощи в пароварку или на решётку над кастрюлей с кипящей водой. 3. Готовьте на пару 10–15 минут до мягкости. 4. Подавайте как гарнир к мясу или рыбе, можно сбрызнуть лимонным соком.');
INSERT INTO public.recipes VALUES (86, 'Курица с рисом и овощами', 'Плов по-домашнему: курица с рисом, морковью, луком и перцем.', 'тушение', 30, 1, '1. Рис промойте. 2. Курицу нарежьте кубиками, лук и морковь – соломкой, перец – полосками. 3. В глубокой сковороде разогрейте масло, обжарьте курицу 5 минут, добавьте лук и морковь, жарьте ещё 3 минуты. 4. Добавьте рис, перец и бульон, накройте крышкой и тушите 20 минут. 5. Перемешайте, дайте настояться 5 минут. Подавайте горячим.');
INSERT INTO public.recipes VALUES (87, 'Суп с курицей и овощами', 'Домашний куриный суп с картофелем, морковью, луком и капустой.', 'варка', 35, 1, '1. Курицу залейте холодной водой, доведите до кипения, снимите пену. 2. Добавьте нарезанный кубиками картофель, варите 10 минут. 3. Морковь, лук и капусту нарежьте, добавьте в суп. 4. Варите ещё 15–20 минут до мягкости овощей. 5. Посолите в конце, при подаче посыпьте зеленью.');
INSERT INTO public.recipes VALUES (88, 'Паста с грибами и сливками', 'Нежная паста с шампиньонами в сливочно-сырном соусе. Идеально для уютного ужина.', 'варка', 25, 1, '1. Пасту отварите в подсоленной воде до аль денте, откиньте на дуршлаг. 2. Грибы и лук мелко нарежьте. 3. В сковороде разогрейте масло, обжарьте лук и грибы 7–10 минут до выпаривания жидкости. 4. Влейте сливки, добавьте тёртый сыр, тушите 3 минуты до загустения. 5. Смешайте пасту с соусом, прогрейте 1 минуту. Подавайте с зеленью.');
INSERT INTO public.recipes VALUES (89, 'Салат с тунцом и яйцом', 'Салат с тунцом, яйцом и свежими овощами в йогуртовой заправке – богат белком.', 'без обработки', 10, 1, '1. Тунец отварите или используйте консервированный в собственном соку, разомните вилкой. 2. Яйца отварите вкрутую, нарежьте кубиками. 3. Огурец и помидор нарежьте кубиками. 4. Для заправки смешайте йогурт с рубленой петрушкой. 5. Смешайте все ингредиенты, заправьте соусом. Подавайте охлаждённым.');
INSERT INTO public.recipes VALUES (90, 'Рис с рыбой', 'Рис с треской, морковью и луком – простое и полезное блюдо.', 'варка', 30, 1, '1. Рис промойте. 2. Рыбу нарежьте кусочками, морковь и лук – соломкой. 3. В глубокой сковороде разогрейте масло, обжарьте лук и морковь 3 минуты. 4. Добавьте рис и бульон, тушите 10 минут, затем выложите рыбу. 5. Тушите ещё 10 минут до готовности риса. Подавайте с зеленью.');
INSERT INTO public.recipes VALUES (93, 'Паста с овощами и сыром', 'Нежная паста с овощами в сливочно-сырном соусе. Быстрый вегетарианский ужин.', 'варка', 25, 1, '1. Пасту отварите в подсоленной воде до аль денте, откиньте на дуршлаг. 2. Овощи (цукини, перец, лук) нарежьте соломкой. 3. В сковороде разогрейте масло, обжарьте овощи 5 минут, влейте сливки и добавьте тёртый сыр. 4. Тушите соус 3 минуты до загустения, затем добавьте пасту. 5. Перемешайте, прогрейте 1 минуту. Подавайте с зеленью.');
INSERT INTO public.recipes VALUES (94, 'Салат с курицей и авокадо', 'Свежий салат с курицей, авокадо и овощами в йогуртовой заправке. Богат полезными жирами и белком.', 'без обработки', 15, 1, '1. Курицу отварите, остудите, нарежьте кубиками. 2. Авокадо очистите, удалите косточку, нарежьте кубиками. 3. Огурец, помидор и салат нарежьте произвольно. 4. Для заправки смешайте йогурт и лимонный сок, добавьте щепотку соли и перца. 5. Смешайте все ингредиенты, заправьте соусом. Подавайте сразу.');
INSERT INTO public.recipes VALUES (96, 'Курица с грибами', 'Нежная курица с шампиньонами в сливочном соусе. Идеально для уютного ужина.', 'тушение', 30, 1, '1. Курицу нарежьте кусочками, лук и грибы – мелко. 2. В сковороде разогрейте масло, обжарьте курицу 5 минут, добавьте лук и грибы, жарьте ещё 7–10 минут. 3. Влейте сливки, добавьте соль и перец по вкусу, тушите 5 минут. 4. Подавайте с гарниром из риса, картофеля или пасты. 5. При подаче посыпьте рубленой петрушкой.');
INSERT INTO public.recipes VALUES (98, 'Паста с томатным соусом', 'Быстрая паста с томатным соусом и базиликом – классика итальянской кухни.', 'варка', 20, 1, '1. Пасту отварите в подсоленной воде до аль денте, откиньте на дуршлаг. 2. В сковороде разогрейте масло, добавьте томатный соус и прогрейте 2 минуты. 3. Добавьте мелко нарезанный базилик, перемешайте. 4. Выложите пасту в соус, перемешайте и прогрейте 1 минуту. 5. Подавайте с тёртым сыром по желанию.');
INSERT INTO public.recipes VALUES (100, 'Рис с овощами и рыбой', 'Рис с треской, морковью, луком и перцем – простое и полезное блюдо.', 'тушение', 30, 1, '1. Рис промойте. 2. Рыбу нарежьте кусочками, морковь, лук и перец – соломкой. 3. В глубокой сковороде разогрейте масло, обжарьте лук и морковь 3 минуты. 4. Добавьте рис и бульон, тушите 10 минут, затем выложите рыбу и перец. 5. Тушите ещё 10 минут до готовности риса. Подавайте с зеленью.');
INSERT INTO public.recipes VALUES (72, 'Суп с фрикадельками', 'Домашний суп с куриными фрикадельками, картофелем и морковью.', 'варка', 40, 2, '1. Из куриного фарша сформируйте маленькие фрикадельки. 2. В кипящий бульон опустите нарезанный картофель, варите 10 минут. 3. Добавьте фрикадельки и нарезанные морковь с луком. 4. Варите ещё 15 минут. 5. Посолите, добавьте зелень.');
INSERT INTO public.recipes VALUES (97, 'Суп с цветной капустой', 'Лёгкий суп-пюре из цветной капусты с картофелем и сливками.', 'варка', 30, 2, '1. Цветную капусту разберите на соцветия, картофель нарежьте. 2. Отварите в бульоне 15 минут. 3. Измельчите блендером, добавьте сливки и прогрейте. 4. Подавайте с сухариками.');
INSERT INTO public.recipes VALUES (57, 'Курица с перловкой', 'Сытное блюдо из курицы и перловой крупы, тушёное с овощами.', 'тушение', 45, 2, '1. Перловку замочите на 1 час. 2. Курицу обжарьте с луком и морковью. 3. Добавьте перловку и бульон, тушите 30 минут. 4. Посолите, добавьте зелень.');
INSERT INTO public.recipes VALUES (69, 'Рис с морепродуктами', 'Жареный рис с креветками, мидиями и кальмарами.', 'жарка', 25, 1, '1. Рис отварите. 2. Морепродукты обжарьте с чесноком и луком. 3. Добавьте рис, соевый соус, жарьте 3 минуты.');
INSERT INTO public.recipes VALUES (95, 'Рис с нутом и шпинатом', 'Полезное вегетарианское блюдо из риса, нута и шпината в томатном соусе.', 'тушение', 30, 2, '1. Рис отварите. 2. Лук и чеснок обжарьте, добавьте нут, томатную пасту. 3. Тушите 10 минут, добавьте шпинат и рис.');
INSERT INTO public.recipes VALUES (44, 'Запечённый тост с авокадо', 'Хрустящий тост с пюре из авокадо, запечённый с яйцом.', 'запекание', 15, 1, '1. Хлеб подсушите в духовке. 2. Авокадо разомните с лимонным соком. 3. Намажьте на тост, сверху выложите яйцо пашот. 4. Запекайте 5 минут при 180°C.');
INSERT INTO public.recipes VALUES (65, 'Гранола с йогуртом', 'Полезный завтрак из домашней гранолы, греческого йогурта и свежих ягод.', 'без обработки', 5, 1, '1. В миску выложите гранолу. 2. Добавьте йогурт. 3. Сверху выложите ягоды. 4. При желании добавьте мёд.');
INSERT INTO public.recipes VALUES (60, 'Паста с креветками', 'Спагетти с креветками в чесночно-оливковом соусе.', 'варка', 20, 1, '1. Пасту отварите. 2. Креветки обжарьте с чесноком на оливковом масле. 3. Смешайте с пастой, добавьте петрушку.');
INSERT INTO public.recipes VALUES (84, 'Паста с брокколи и чесноком', 'Спагетти с брокколи и чесночным маслом, посыпанные пармезаном.', 'варка', 20, 1, '1. Пасту отварите. 2. Брокколи отварите 3 минуты. 3. Обжарьте чеснок на масле, смешайте с пастой и брокколи. 4. Посыпьте сыром.');
INSERT INTO public.recipes VALUES (58, 'Пшённая каша с тыквой', 'Сладкая пшённая каша с запечённой тыквой и корицей.', 'варка', 35, 2, '1. Пшено промойте, залейте молоком, варите 20 минут. 2. Тыкву запеките до мягкости. 3. Смешайте с кашей, добавьте корицу и мёд.');
INSERT INTO public.recipes VALUES (75, 'Киноа с овощами', 'Полезный гарнир из киноа с тушёными овощами.', 'тушение', 25, 2, '1. Киноа отварите. 2. Лук, морковь, перец обжарьте. 3. Добавьте киноа, тушите 5 минут.');
INSERT INTO public.recipes VALUES (56, 'Салат с креветками и манго', 'Экзотический салат с креветками, манго и авокадо.', 'без обработки', 15, 1, '1. Креветки отварите. 2. Манго, авокадо, салат нарежьте. 3. Заправьте йогуртом и лаймом.');
INSERT INTO public.recipes VALUES (61, 'Греческий салат без сыра', 'Овощной салат с оливками и оливковым маслом.', 'без обработки', 10, 1, '1. Огурцы, помидоры, перец нарежьте. 2. Добавьте оливки, орегано. 3. Заправьте оливковым маслом.');
INSERT INTO public.recipes VALUES (99, 'Салат с рукколой и пармезаном', 'Пряный салат из рукколы, груши и пармезана с ореховой заправкой.', 'без обработки', 10, 1, '1. Рукколу выложите. 2. Грушу нарежьте тонкими ломтиками. 3. Добавьте сыр, орехи. 4. Заправьте смесью масла и бальзамика.');
INSERT INTO public.recipes VALUES (10, 'Рыбные котлеты на пару', 'Нежные паровые котлеты из трески с зеленью.', 'варка', 25, 2, '1. Филе трески перекрутите. 2. Добавьте яйцо, зелень, сформируйте котлеты. 3. Готовьте на пару 20 минут.');
INSERT INTO public.recipes VALUES (82, 'Рыба под маринадом', 'Треска, тушёная с морковью, луком и томатной пастой.', 'тушение', 35, 2, '1. Рыбу нарежьте кусочками. 2. Морковь и лук обжарьте, добавьте томатную пасту. 3. Выложите рыбу, тушите 20 минут.');
INSERT INTO public.recipes VALUES (62, 'Рыбный суп с фенхелем', 'Ароматный суп из трески с фенхелем и картофелем.', 'варка', 30, 2, '1. Лук и фенхель обжарьте. 2. Добавьте картофель, бульон, варите 10 минут. 3. Положите рыбу, варите ещё 10 минут.');
INSERT INTO public.recipes VALUES (42, 'Куриные котлеты с овощами', 'Запечённые куриные котлеты с цукини и морковью.', 'запекание', 30, 2, '1. Из куриного фарша сформируйте котлеты. 2. Выложите на противень с нарезанными овощами. 3. Запекайте при 190°C 25 минут.');
INSERT INTO public.recipes VALUES (81, 'Куриные бёдра тушёные с луком', 'Нежные куриные бёдра, тушёные в собственном соку с луком.', 'тушение', 40, 2, '1. Куриные бёдра обжарьте до румянца. 2. Добавьте лук, тушите 30 минут. 3. При подаче посыпьте зеленью.');


--
-- Data for Name: user_product_preferences; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.user_product_preferences VALUES (1, 10, 'excluded', '2026-04-16 20:04:15.688169');
INSERT INTO public.user_product_preferences VALUES (1, 15, 'favorite', '2026-04-16 20:04:15.688169');
INSERT INTO public.user_product_preferences VALUES (1, 11, 'favorite', '2026-04-16 20:04:15.688169');
INSERT INTO public.user_product_preferences VALUES (1, 18, 'favorite', '2026-04-16 20:04:15.688169');


--
-- Data for Name: user_profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.user_profiles VALUES (1, false, false, false, false, false, false, 2000, 90, 70, 200, 25, NULL, 2000);


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.users VALUES (1, 'testuser@mail.com', 'hashed_password_example', 5, '2026-02-24 21:38:18.655125');


--
-- Name: diet_cooking_method_restrictions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.diet_cooking_method_restrictions_id_seq', 10, true);


--
-- Name: diets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.diets_id_seq', 5, true);


--
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.products_id_seq', 150, true);


--
-- Name: recipe_ingredients_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.recipe_ingredients_id_seq', 705, true);


--
-- Name: recipes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.recipes_id_seq', 100, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 1, true);


--
-- Name: diet_cooking_method_restrictions diet_cooking_method_restrictions_diet_method_uk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diet_cooking_method_restrictions
    ADD CONSTRAINT diet_cooking_method_restrictions_diet_method_uk UNIQUE (diet_id, cooking_method);


--
-- Name: diet_cooking_method_restrictions diet_cooking_method_restrictions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diet_cooking_method_restrictions
    ADD CONSTRAINT diet_cooking_method_restrictions_pkey PRIMARY KEY (id);


--
-- Name: diet_product_rules diet_product_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diet_product_rules
    ADD CONSTRAINT diet_product_rules_pkey PRIMARY KEY (diet_id, product_id);


--
-- Name: diets diets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diets
    ADD CONSTRAINT diets_pkey PRIMARY KEY (id);


--
-- Name: products products_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_name_key UNIQUE (name);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: recipe_diets recipe_diets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recipe_diets
    ADD CONSTRAINT recipe_diets_pkey PRIMARY KEY (recipe_id, diet_id);


--
-- Name: recipe_ingredients recipe_ingredients_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recipe_ingredients
    ADD CONSTRAINT recipe_ingredients_pkey PRIMARY KEY (id);


--
-- Name: recipe_ingredients recipe_ingredients_recipe_id_product_id_uk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recipe_ingredients
    ADD CONSTRAINT recipe_ingredients_recipe_id_product_id_uk UNIQUE (recipe_id, product_id);


--
-- Name: recipe_nutrients_per_100g recipe_nutrients_per_100g_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recipe_nutrients_per_100g
    ADD CONSTRAINT recipe_nutrients_per_100g_pkey PRIMARY KEY (recipe_id);


--
-- Name: recipes recipes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recipes
    ADD CONSTRAINT recipes_pkey PRIMARY KEY (id);


--
-- Name: user_product_preferences user_product_preferences_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_product_preferences
    ADD CONSTRAINT user_product_preferences_pkey PRIMARY KEY (user_id, product_id, preference_type);


--
-- Name: user_profiles user_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_profiles
    ADD CONSTRAINT user_profiles_pkey PRIMARY KEY (user_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_diet_cooking_restrictions_lookup; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_diet_cooking_restrictions_lookup ON public.diet_cooking_method_restrictions USING btree (diet_id, cooking_method, status, is_hard);


--
-- Name: idx_diet_product_rules_diet_status_product; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_diet_product_rules_diet_status_product ON public.diet_product_rules USING btree (diet_id, status, product_id);


--
-- Name: idx_diet_product_rules_lookup; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_diet_product_rules_lookup ON public.diet_product_rules USING btree (diet_id, status, is_hard, product_id);


--
-- Name: idx_products_flags; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_products_flags ON public.products USING btree (is_spicy, is_acidic, is_saturated_fat) WHERE (is_spicy OR is_acidic OR is_saturated_fat);


--
-- Name: idx_recipe_diets_diet_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_recipe_diets_diet_id ON public.recipe_diets USING btree (diet_id);


--
-- Name: idx_recipe_diets_diet_id_recipe_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_recipe_diets_diet_id_recipe_id ON public.recipe_diets USING btree (diet_id, recipe_id);


--
-- Name: idx_recipe_ingredients_product_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_recipe_ingredients_product_id ON public.recipe_ingredients USING btree (product_id);


--
-- Name: idx_recipe_ingredients_recipe; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_recipe_ingredients_recipe ON public.recipe_ingredients USING btree (recipe_id);


--
-- Name: idx_recipe_ingredients_recipe_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_recipe_ingredients_recipe_id ON public.recipe_ingredients USING btree (recipe_id);


--
-- Name: idx_recipes_cooking_method; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_recipes_cooking_method ON public.recipes USING btree (cooking_method);


--
-- Name: idx_user_product_preferences_user_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_product_preferences_user_type ON public.user_product_preferences USING btree (user_id, preference_type, product_id);


--
-- Name: diet_cooking_method_restrictions diet_cooking_method_restrictions_diet_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diet_cooking_method_restrictions
    ADD CONSTRAINT diet_cooking_method_restrictions_diet_id_fkey FOREIGN KEY (diet_id) REFERENCES public.diets(id) ON DELETE CASCADE;


--
-- Name: diet_product_rules diet_product_rules_diet_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diet_product_rules
    ADD CONSTRAINT diet_product_rules_diet_id_fkey FOREIGN KEY (diet_id) REFERENCES public.diets(id) ON DELETE CASCADE;


--
-- Name: diet_product_rules diet_product_rules_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diet_product_rules
    ADD CONSTRAINT diet_product_rules_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: recipe_diets recipe_diets_diet_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recipe_diets
    ADD CONSTRAINT recipe_diets_diet_id_fkey FOREIGN KEY (diet_id) REFERENCES public.diets(id) ON DELETE CASCADE;


--
-- Name: recipe_diets recipe_diets_recipe_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recipe_diets
    ADD CONSTRAINT recipe_diets_recipe_id_fkey FOREIGN KEY (recipe_id) REFERENCES public.recipes(id) ON DELETE CASCADE;


--
-- Name: recipe_ingredients recipe_ingredients_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recipe_ingredients
    ADD CONSTRAINT recipe_ingredients_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE RESTRICT;


--
-- Name: recipe_ingredients recipe_ingredients_recipe_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recipe_ingredients
    ADD CONSTRAINT recipe_ingredients_recipe_id_fkey FOREIGN KEY (recipe_id) REFERENCES public.recipes(id) ON DELETE CASCADE;


--
-- Name: recipe_nutrients_per_100g recipe_nutrients_per_100g_recipe_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recipe_nutrients_per_100g
    ADD CONSTRAINT recipe_nutrients_per_100g_recipe_id_fkey FOREIGN KEY (recipe_id) REFERENCES public.recipes(id) ON DELETE CASCADE;


--
-- Name: user_product_preferences user_product_preferences_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_product_preferences
    ADD CONSTRAINT user_product_preferences_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: user_product_preferences user_product_preferences_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_product_preferences
    ADD CONSTRAINT user_product_preferences_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_profiles user_profiles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_profiles
    ADD CONSTRAINT user_profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: users users_selected_diet_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_selected_diet_id_fkey FOREIGN KEY (selected_diet_id) REFERENCES public.diets(id) ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

\unrestrict hqKrfk5gBalpmH1LtOyG7osBa5iGJwCS89hDm1dAr1ScqSrTQ8FQ6tf9JpZHlco

