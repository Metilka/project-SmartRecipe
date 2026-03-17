--
-- PostgreSQL database dump
--

\restrict Qe9Xavcxl4QUxf2HvRwrpan7l38teE0h9667nKCPfAO06B7m1DjJ0EGVPqgsoAe

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

\unrestrict Qe9Xavcxl4QUxf2HvRwrpan7l38teE0h9667nKCPfAO06B7m1DjJ0EGVPqgsoAe
\connect med_diet_db
\restrict Qe9Xavcxl4QUxf2HvRwrpan7l38teE0h9667nKCPfAO06B7m1DjJ0EGVPqgsoAe

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
-- Name: diet_allowed_products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.diet_allowed_products (
    diet_id integer NOT NULL,
    product_id integer NOT NULL
);


ALTER TABLE public.diet_allowed_products OWNER TO postgres;

--
-- Name: diet_cooking_method_restrictions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.diet_cooking_method_restrictions (
    id integer NOT NULL,
    diet_id integer,
    cooking_method character varying(50),
    status character varying(20),
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
-- Name: ingredients; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ingredients (
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
    is_saturated_fat boolean DEFAULT false,
    product_id integer
);


ALTER TABLE public.ingredients OWNER TO postgres;

--
-- Name: ingredients_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ingredients_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ingredients_id_seq OWNER TO postgres;

--
-- Name: ingredients_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ingredients_id_seq OWNED BY public.ingredients.id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    id integer NOT NULL,
    name character varying(150) NOT NULL,
    category character varying(100)
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
    ingredient_id integer NOT NULL,
    quantity double precision NOT NULL,
    unit character varying(50)
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
-- Name: user_excluded_products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_excluded_products (
    user_id integer NOT NULL,
    product_id integer NOT NULL
);


ALTER TABLE public.user_excluded_products OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    email character varying(150) NOT NULL,
    password_hash text NOT NULL,
    selected_diet_id integer,
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
-- Name: diet_cooking_method_restrictions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diet_cooking_method_restrictions ALTER COLUMN id SET DEFAULT nextval('public.diet_cooking_method_restrictions_id_seq'::regclass);


--
-- Name: diets id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diets ALTER COLUMN id SET DEFAULT nextval('public.diets_id_seq'::regclass);


--
-- Name: ingredients id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ingredients ALTER COLUMN id SET DEFAULT nextval('public.ingredients_id_seq'::regclass);


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
-- Data for Name: diet_allowed_products; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.diet_allowed_products VALUES (1, 1);
INSERT INTO public.diet_allowed_products VALUES (1, 3);
INSERT INTO public.diet_allowed_products VALUES (1, 4);
INSERT INTO public.diet_allowed_products VALUES (1, 5);
INSERT INTO public.diet_allowed_products VALUES (1, 6);
INSERT INTO public.diet_allowed_products VALUES (1, 7);
INSERT INTO public.diet_allowed_products VALUES (1, 8);
INSERT INTO public.diet_allowed_products VALUES (1, 9);
INSERT INTO public.diet_allowed_products VALUES (1, 10);
INSERT INTO public.diet_allowed_products VALUES (1, 11);
INSERT INTO public.diet_allowed_products VALUES (1, 12);
INSERT INTO public.diet_allowed_products VALUES (1, 13);
INSERT INTO public.diet_allowed_products VALUES (1, 14);
INSERT INTO public.diet_allowed_products VALUES (1, 15);
INSERT INTO public.diet_allowed_products VALUES (1, 16);
INSERT INTO public.diet_allowed_products VALUES (1, 17);
INSERT INTO public.diet_allowed_products VALUES (1, 18);
INSERT INTO public.diet_allowed_products VALUES (1, 19);
INSERT INTO public.diet_allowed_products VALUES (1, 20);
INSERT INTO public.diet_allowed_products VALUES (2, 1);
INSERT INTO public.diet_allowed_products VALUES (2, 2);
INSERT INTO public.diet_allowed_products VALUES (2, 3);
INSERT INTO public.diet_allowed_products VALUES (2, 4);
INSERT INTO public.diet_allowed_products VALUES (2, 5);
INSERT INTO public.diet_allowed_products VALUES (2, 6);
INSERT INTO public.diet_allowed_products VALUES (2, 7);
INSERT INTO public.diet_allowed_products VALUES (2, 8);
INSERT INTO public.diet_allowed_products VALUES (2, 9);
INSERT INTO public.diet_allowed_products VALUES (2, 10);
INSERT INTO public.diet_allowed_products VALUES (2, 11);
INSERT INTO public.diet_allowed_products VALUES (2, 12);
INSERT INTO public.diet_allowed_products VALUES (2, 13);
INSERT INTO public.diet_allowed_products VALUES (2, 14);
INSERT INTO public.diet_allowed_products VALUES (2, 15);
INSERT INTO public.diet_allowed_products VALUES (2, 16);
INSERT INTO public.diet_allowed_products VALUES (2, 17);
INSERT INTO public.diet_allowed_products VALUES (2, 18);
INSERT INTO public.diet_allowed_products VALUES (2, 19);
INSERT INTO public.diet_allowed_products VALUES (2, 20);
INSERT INTO public.diet_allowed_products VALUES (3, 1);
INSERT INTO public.diet_allowed_products VALUES (3, 2);
INSERT INTO public.diet_allowed_products VALUES (3, 3);
INSERT INTO public.diet_allowed_products VALUES (3, 4);
INSERT INTO public.diet_allowed_products VALUES (3, 5);
INSERT INTO public.diet_allowed_products VALUES (3, 6);
INSERT INTO public.diet_allowed_products VALUES (3, 7);
INSERT INTO public.diet_allowed_products VALUES (3, 8);
INSERT INTO public.diet_allowed_products VALUES (3, 9);
INSERT INTO public.diet_allowed_products VALUES (3, 10);
INSERT INTO public.diet_allowed_products VALUES (3, 11);
INSERT INTO public.diet_allowed_products VALUES (3, 12);
INSERT INTO public.diet_allowed_products VALUES (3, 14);
INSERT INTO public.diet_allowed_products VALUES (3, 15);
INSERT INTO public.diet_allowed_products VALUES (3, 16);
INSERT INTO public.diet_allowed_products VALUES (3, 17);
INSERT INTO public.diet_allowed_products VALUES (3, 18);
INSERT INTO public.diet_allowed_products VALUES (3, 19);
INSERT INTO public.diet_allowed_products VALUES (3, 20);
INSERT INTO public.diet_allowed_products VALUES (4, 1);
INSERT INTO public.diet_allowed_products VALUES (4, 2);
INSERT INTO public.diet_allowed_products VALUES (4, 3);
INSERT INTO public.diet_allowed_products VALUES (4, 4);
INSERT INTO public.diet_allowed_products VALUES (4, 5);
INSERT INTO public.diet_allowed_products VALUES (4, 6);
INSERT INTO public.diet_allowed_products VALUES (4, 7);
INSERT INTO public.diet_allowed_products VALUES (4, 8);
INSERT INTO public.diet_allowed_products VALUES (4, 9);
INSERT INTO public.diet_allowed_products VALUES (4, 10);
INSERT INTO public.diet_allowed_products VALUES (4, 11);
INSERT INTO public.diet_allowed_products VALUES (4, 12);
INSERT INTO public.diet_allowed_products VALUES (4, 13);
INSERT INTO public.diet_allowed_products VALUES (4, 14);
INSERT INTO public.diet_allowed_products VALUES (4, 15);
INSERT INTO public.diet_allowed_products VALUES (4, 16);
INSERT INTO public.diet_allowed_products VALUES (4, 17);
INSERT INTO public.diet_allowed_products VALUES (4, 18);
INSERT INTO public.diet_allowed_products VALUES (4, 19);
INSERT INTO public.diet_allowed_products VALUES (4, 20);
INSERT INTO public.diet_allowed_products VALUES (5, 1);
INSERT INTO public.diet_allowed_products VALUES (5, 2);
INSERT INTO public.diet_allowed_products VALUES (5, 3);
INSERT INTO public.diet_allowed_products VALUES (5, 4);
INSERT INTO public.diet_allowed_products VALUES (5, 5);
INSERT INTO public.diet_allowed_products VALUES (5, 6);
INSERT INTO public.diet_allowed_products VALUES (5, 7);
INSERT INTO public.diet_allowed_products VALUES (5, 8);
INSERT INTO public.diet_allowed_products VALUES (5, 9);
INSERT INTO public.diet_allowed_products VALUES (5, 10);
INSERT INTO public.diet_allowed_products VALUES (5, 11);
INSERT INTO public.diet_allowed_products VALUES (5, 12);
INSERT INTO public.diet_allowed_products VALUES (5, 13);
INSERT INTO public.diet_allowed_products VALUES (5, 14);
INSERT INTO public.diet_allowed_products VALUES (5, 15);
INSERT INTO public.diet_allowed_products VALUES (5, 16);
INSERT INTO public.diet_allowed_products VALUES (5, 17);
INSERT INTO public.diet_allowed_products VALUES (5, 18);
INSERT INTO public.diet_allowed_products VALUES (5, 19);
INSERT INTO public.diet_allowed_products VALUES (5, 20);


--
-- Data for Name: diet_cooking_method_restrictions; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.diet_cooking_method_restrictions VALUES (1, 1, 'жарка', 'forbidden');
INSERT INTO public.diet_cooking_method_restrictions VALUES (2, 4, 'жарка', 'allowed');


--
-- Data for Name: diet_product_rules; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.diet_product_rules VALUES (3, 13, 'forbidden');
INSERT INTO public.diet_product_rules VALUES (1, 2, 'forbidden');
INSERT INTO public.diet_product_rules VALUES (4, 4, 'allowed');


--
-- Data for Name: diets; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.diets VALUES (1, 'Гастроэнтерологическая', 'Щадящая диета для ЖКТ', 30, 55, 2000, 2200);
INSERT INTO public.diets VALUES (2, 'Гепатопротекторная', 'Диета при заболеваниях печени', 25, 60, 1800, 2300);
INSERT INTO public.diets VALUES (3, 'Диабетическая', 'Контроль углеводов и сахара', 30, 45, 2000, 2000);
INSERT INTO public.diets VALUES (4, 'Сердечно-сосудистая', 'Ограничение соли и насыщенных жиров', 25, 55, 1500, 2100);
INSERT INTO public.diets VALUES (5, 'Базовая', 'Общий режим питания', 35, 60, 2500, 2500);


--
-- Data for Name: ingredients; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.ingredients VALUES (16, 'Оливковое масло', 'Жиры', 884, 0, 100, 0, 2, 0, false, false, true, 1);
INSERT INTO public.ingredients VALUES (18, 'Перец чили', 'Овощи', 40, 2, 0.4, 9, 7, 15, true, false, false, 2);
INSERT INTO public.ingredients VALUES (20, 'Лук репчатый', 'Овощи', 40, 1.1, 0.1, 9, 4, 10, false, false, false, 3);
INSERT INTO public.ingredients VALUES (17, 'Сливочное масло', 'Жиры', 717, 0.9, 81, 0.1, 11, 0, false, false, true, 4);
INSERT INTO public.ingredients VALUES (12, 'Молоко 2.5%', 'Молочные', 52, 3.2, 2.5, 4.8, 44, 30, false, false, false, 5);
INSERT INTO public.ingredients VALUES (7, 'Овсяные хлопья (сухие)', 'Крупы', 370, 13, 7, 60, 2, 55, false, false, false, 6);
INSERT INTO public.ingredients VALUES (10, 'Кабачок', 'Овощи', 17, 1.2, 0.3, 3, 8, 15, false, false, false, 7);
INSERT INTO public.ingredients VALUES (8, 'Картофель', 'Овощи', 77, 2, 0.1, 17, 6, 80, false, false, false, 8);
INSERT INTO public.ingredients VALUES (6, 'Гречка (сухая)', 'Крупы', 343, 13, 3.4, 72, 2, 50, false, false, false, 9);
INSERT INTO public.ingredients VALUES (2, 'Говядина', 'Мясо', 187, 18.9, 12.4, 0, 72, 0, false, false, true, 10);
INSERT INTO public.ingredients VALUES (4, 'Яйцо', 'Яйца', 143, 12.6, 9.5, 0.7, 124, 0, false, false, true, 11);
INSERT INTO public.ingredients VALUES (19, 'Лимон', 'Фрукты', 29, 1.1, 0.3, 9, 2, 25, false, true, false, 12);
INSERT INTO public.ingredients VALUES (15, 'Сахар', 'Подсластители', 387, 0, 0, 100, 1, 100, false, false, false, 13);
INSERT INTO public.ingredients VALUES (5, 'Рис (сухой)', 'Крупы', 360, 7, 0.6, 78, 1, 70, false, false, false, 14);
INSERT INTO public.ingredients VALUES (1, 'Куриная грудка', 'Мясо', 120, 22, 2.6, 0, 70, 0, false, false, false, 15);
INSERT INTO public.ingredients VALUES (9, 'Морковь', 'Овощи', 41, 1, 0.2, 10, 69, 35, false, false, false, 16);
INSERT INTO public.ingredients VALUES (3, 'Треска', 'Рыба', 82, 18, 0.7, 0, 60, 0, false, false, false, 17);
INSERT INTO public.ingredients VALUES (11, 'Брокколи', 'Овощи', 34, 2.8, 0.4, 7, 33, 10, false, false, false, 18);
INSERT INTO public.ingredients VALUES (13, 'Творог 5%', 'Молочные', 121, 16, 5, 3, 40, 30, false, false, false, 19);
INSERT INTO public.ingredients VALUES (14, 'Йогурт натуральный', 'Молочные', 60, 10, 0.4, 3.6, 36, 35, false, false, false, 20);


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.products VALUES (1, 'Оливковое масло', 'Жиры');
INSERT INTO public.products VALUES (2, 'Перец чили', 'Овощи');
INSERT INTO public.products VALUES (3, 'Лук репчатый', 'Овощи');
INSERT INTO public.products VALUES (4, 'Сливочное масло', 'Жиры');
INSERT INTO public.products VALUES (5, 'Молоко 2.5%', 'Молочные');
INSERT INTO public.products VALUES (6, 'Овсяные хлопья (сухие)', 'Крупы');
INSERT INTO public.products VALUES (7, 'Кабачок', 'Овощи');
INSERT INTO public.products VALUES (8, 'Картофель', 'Овощи');
INSERT INTO public.products VALUES (9, 'Гречка (сухая)', 'Крупы');
INSERT INTO public.products VALUES (10, 'Говядина', 'Мясо');
INSERT INTO public.products VALUES (11, 'Яйцо', 'Яйца');
INSERT INTO public.products VALUES (12, 'Лимон', 'Фрукты');
INSERT INTO public.products VALUES (13, 'Сахар', 'Подсластители');
INSERT INTO public.products VALUES (14, 'Рис (сухой)', 'Крупы');
INSERT INTO public.products VALUES (15, 'Куриная грудка', 'Мясо');
INSERT INTO public.products VALUES (16, 'Морковь', 'Овощи');
INSERT INTO public.products VALUES (17, 'Треска', 'Рыба');
INSERT INTO public.products VALUES (18, 'Брокколи', 'Овощи');
INSERT INTO public.products VALUES (19, 'Творог 5%', 'Молочные');
INSERT INTO public.products VALUES (20, 'Йогурт натуральный', 'Молочные');


--
-- Data for Name: recipe_diets; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.recipe_diets VALUES (1, 5);
INSERT INTO public.recipe_diets VALUES (2, 5);
INSERT INTO public.recipe_diets VALUES (3, 5);


--
-- Data for Name: recipe_ingredients; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.recipe_ingredients VALUES (1, 2, 20, 50, 'г');
INSERT INTO public.recipe_ingredients VALUES (2, 2, 6, 100, 'г');
INSERT INTO public.recipe_ingredients VALUES (3, 2, 2, 200, 'г');
INSERT INTO public.recipe_ingredients VALUES (4, 1, 1, 200, 'г');
INSERT INTO public.recipe_ingredients VALUES (5, 1, 5, 100, 'г');
INSERT INTO public.recipe_ingredients VALUES (6, 3, 4, 150, 'г');
INSERT INTO public.recipe_ingredients VALUES (7, 3, 11, 100, 'г');


--
-- Data for Name: recipe_nutrients_per_100g; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.recipe_nutrients_per_100g VALUES (3, 99.4, 8.68, 5.86, 3.22, NULL, 87.6);
INSERT INTO public.recipe_nutrients_per_100g VALUES (2, 210.57142857142858, 14.67142857142857, 8.071428571428571, 21.857142857142858, NULL, 42.285714285714285);
INSERT INTO public.recipe_nutrients_per_100g VALUES (1, 200, 17, 1.9333333333333333, 26, NULL, 47);


--
-- Data for Name: recipes; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.recipes VALUES (1, 'Отварная курица с рисом', 'Щадящее блюдо для ЖКТ', 'варка', 40, 2, '1. Промойте рис в холодной воде до прозрачности. Залейте 1 стаканом воды, добавьте щепотку соли и варите на медленном огне 20 минут до готовности. 
2. Куриное филе промойте, залейте холодной водой, доведите до кипения, снимите пену. Варите 20-25 минут до готовности. 
3. Готовую курицу нарежьте небольшими кусочками. Подавайте рис с курицей без добавления специй.');
INSERT INTO public.recipes VALUES (2, 'Гречка с тушёной говядиной', 'Питательное блюдо', 'тушение', 60, 2, '1. Гречку переберите, промойте, залейте водой (соотношение гречки и воды - 1 к 2), добавьте щепотку соли. Варите 20-25 минут до полного впитывания воды. 
2. Говядину нарежьте небольшими кубиками, обжарьте на антипригарной сковороде 20 минут. 
3. Добавьте к мясу 1 мелко нарезанную луковицу, обжаривайте ещё 3-4 минуты. Залейте горячей водой, накройте крышкой и тушите на медленном огне 30-40 минут до мягкости мяса. 
4. Смешайте готовую гречку с тушёной говядиной, дайте настояться под крышкой 5-10 минут перед подачей.');
INSERT INTO public.recipes VALUES (3, 'Омлет с брокколи', 'Белковый завтрак', 'жарка', 15, 1, '1. Брокколи отварите до готовности. 
2. В миске взбейте 2 яйца, добавьте щепотку соли. 
3. Разогрейте сковороду, затем выложите брокколи, залейте яичной смесью. 
4. Готовьте на слабом огне под крышкой 5-7 минут до полного застывания яиц. Подавайте горячим, посыпав зеленью по желанию.');


--
-- Data for Name: user_excluded_products; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.user_excluded_products VALUES (1, 10);


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.users VALUES (1, 'testuser@mail.com', 'hashed_password_example', 3, '2026-02-24 21:38:18.655125');


--
-- Name: diet_cooking_method_restrictions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.diet_cooking_method_restrictions_id_seq', 2, true);


--
-- Name: diets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.diets_id_seq', 10, true);


--
-- Name: ingredients_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ingredients_id_seq', 20, true);


--
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.products_id_seq', 20, true);


--
-- Name: recipe_ingredients_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.recipe_ingredients_id_seq', 7, true);


--
-- Name: recipes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.recipes_id_seq', 3, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 1, true);


--
-- Name: diet_allowed_products diet_allowed_products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diet_allowed_products
    ADD CONSTRAINT diet_allowed_products_pkey PRIMARY KEY (diet_id, product_id);


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
-- Name: ingredients ingredients_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ingredients
    ADD CONSTRAINT ingredients_pkey PRIMARY KEY (id);


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
-- Name: recipe_ingredients recipe_ingredients_recipe_id_ingredient_id_uk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recipe_ingredients
    ADD CONSTRAINT recipe_ingredients_recipe_id_ingredient_id_uk UNIQUE (recipe_id, ingredient_id);


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
-- Name: user_excluded_products user_excluded_products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_excluded_products
    ADD CONSTRAINT user_excluded_products_pkey PRIMARY KEY (user_id, product_id);


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
-- Name: idx_ingredients_product; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_ingredients_product ON public.ingredients USING btree (product_id);


--
-- Name: idx_recipe_ingredients_ing; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_recipe_ingredients_ing ON public.recipe_ingredients USING btree (ingredient_id);


--
-- Name: idx_recipe_ingredients_recipe; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_recipe_ingredients_recipe ON public.recipe_ingredients USING btree (recipe_id);


--
-- Name: idx_user_excluded_products; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_excluded_products ON public.user_excluded_products USING btree (user_id, product_id);


--
-- Name: diet_allowed_products diet_allowed_products_diet_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diet_allowed_products
    ADD CONSTRAINT diet_allowed_products_diet_id_fkey FOREIGN KEY (diet_id) REFERENCES public.diets(id) ON DELETE CASCADE;


--
-- Name: diet_allowed_products diet_allowed_products_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diet_allowed_products
    ADD CONSTRAINT diet_allowed_products_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


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
-- Name: ingredients ingredients_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ingredients
    ADD CONSTRAINT ingredients_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE RESTRICT;


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
-- Name: recipe_ingredients recipe_ingredients_ingredient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recipe_ingredients
    ADD CONSTRAINT recipe_ingredients_ingredient_id_fkey FOREIGN KEY (ingredient_id) REFERENCES public.ingredients(id);


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
-- Name: user_excluded_products user_excluded_products_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_excluded_products
    ADD CONSTRAINT user_excluded_products_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: user_excluded_products user_excluded_products_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_excluded_products
    ADD CONSTRAINT user_excluded_products_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: users users_selected_diet_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_selected_diet_id_fkey FOREIGN KEY (selected_diet_id) REFERENCES public.diets(id) ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

\unrestrict Qe9Xavcxl4QUxf2HvRwrpan7l38teE0h9667nKCPfAO06B7m1DjJ0EGVPqgsoAe

