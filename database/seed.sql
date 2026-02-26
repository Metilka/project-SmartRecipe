--
-- PostgreSQL database dump
--

\restrict 7tTjyvLeDDLDEOGieMIsYJslCv59X2GSSsiejCAUm6mgo535nh5ZbsCvJbASDdH

-- Dumped from database version 18.1
-- Dumped by pg_dump version 18.1

-- Started on 2026-02-24 23:16:38

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
-- TOC entry 4968 (class 1262 OID 16388)
-- Name: med_diet_db; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE med_diet_db WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Russian_Russia.1251';


ALTER DATABASE med_diet_db OWNER TO postgres;

\unrestrict 7tTjyvLeDDLDEOGieMIsYJslCv59X2GSSsiejCAUm6mgo535nh5ZbsCvJbASDdH
\connect med_diet_db
\restrict 7tTjyvLeDDLDEOGieMIsYJslCv59X2GSSsiejCAUm6mgo535nh5ZbsCvJbASDdH

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
-- TOC entry 234 (class 1259 OID 16517)
-- Name: diet_cooking_method_restrictions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.diet_cooking_method_restrictions (
    id integer NOT NULL,
    diet_id integer,
    cooking_method character varying(50),
    status character varying(20),
    CONSTRAINT diet_cooking_method_restrictions_status_check CHECK (((status)::text = ANY ((ARRAY['allowed'::character varying, 'limited'::character varying, 'forbidden'::character varying])::text[])))
);


ALTER TABLE public.diet_cooking_method_restrictions OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 16516)
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
-- TOC entry 4969 (class 0 OID 0)
-- Dependencies: 233
-- Name: diet_cooking_method_restrictions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.diet_cooking_method_restrictions_id_seq OWNED BY public.diet_cooking_method_restrictions.id;


--
-- TOC entry 228 (class 1259 OID 16442)
-- Name: diet_ingredient_restrictions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.diet_ingredient_restrictions (
    id integer NOT NULL,
    diet_id integer,
    ingredient_id integer,
    status character varying(20),
    CONSTRAINT diet_ingredient_restrictions_status_check CHECK (((status)::text = ANY ((ARRAY['allowed'::character varying, 'limited'::character varying, 'forbidden'::character varying])::text[])))
);


ALTER TABLE public.diet_ingredient_restrictions OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 16441)
-- Name: diet_ingredient_restrictions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.diet_ingredient_restrictions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.diet_ingredient_restrictions_id_seq OWNER TO postgres;

--
-- TOC entry 4970 (class 0 OID 0)
-- Dependencies: 227
-- Name: diet_ingredient_restrictions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.diet_ingredient_restrictions_id_seq OWNED BY public.diet_ingredient_restrictions.id;


--
-- TOC entry 220 (class 1259 OID 16390)
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
-- TOC entry 219 (class 1259 OID 16389)
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
-- TOC entry 4971 (class 0 OID 0)
-- Dependencies: 219
-- Name: diets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.diets_id_seq OWNED BY public.diets.id;


--
-- TOC entry 222 (class 1259 OID 16401)
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
    is_saturated_fat boolean DEFAULT false
);


ALTER TABLE public.ingredients OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16400)
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
-- TOC entry 4972 (class 0 OID 0)
-- Dependencies: 221
-- Name: ingredients_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ingredients_id_seq OWNED BY public.ingredients.id;


--
-- TOC entry 226 (class 1259 OID 16424)
-- Name: recipe_ingredients; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.recipe_ingredients (
    id integer NOT NULL,
    recipe_id integer,
    ingredient_id integer,
    quantity double precision,
    unit character varying(50)
);


ALTER TABLE public.recipe_ingredients OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16423)
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
-- TOC entry 4973 (class 0 OID 0)
-- Dependencies: 225
-- Name: recipe_ingredients_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.recipe_ingredients_id_seq OWNED BY public.recipe_ingredients.id;


--
-- TOC entry 224 (class 1259 OID 16413)
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
-- TOC entry 223 (class 1259 OID 16412)
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
-- TOC entry 4974 (class 0 OID 0)
-- Dependencies: 223
-- Name: recipes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.recipes_id_seq OWNED BY public.recipes.id;


--
-- TOC entry 232 (class 1259 OID 16499)
-- Name: user_exclusions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_exclusions (
    id integer NOT NULL,
    user_id integer,
    ingredient_id integer
);


ALTER TABLE public.user_exclusions OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 16498)
-- Name: user_exclusions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_exclusions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_exclusions_id_seq OWNER TO postgres;

--
-- TOC entry 4975 (class 0 OID 0)
-- Dependencies: 231
-- Name: user_exclusions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_exclusions_id_seq OWNED BY public.user_exclusions.id;


--
-- TOC entry 230 (class 1259 OID 16479)
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
-- TOC entry 229 (class 1259 OID 16478)
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
-- TOC entry 4976 (class 0 OID 0)
-- Dependencies: 229
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- TOC entry 4771 (class 2604 OID 16520)
-- Name: diet_cooking_method_restrictions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diet_cooking_method_restrictions ALTER COLUMN id SET DEFAULT nextval('public.diet_cooking_method_restrictions_id_seq'::regclass);


--
-- TOC entry 4767 (class 2604 OID 16445)
-- Name: diet_ingredient_restrictions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diet_ingredient_restrictions ALTER COLUMN id SET DEFAULT nextval('public.diet_ingredient_restrictions_id_seq'::regclass);


--
-- TOC entry 4760 (class 2604 OID 16393)
-- Name: diets id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diets ALTER COLUMN id SET DEFAULT nextval('public.diets_id_seq'::regclass);


--
-- TOC entry 4761 (class 2604 OID 16404)
-- Name: ingredients id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ingredients ALTER COLUMN id SET DEFAULT nextval('public.ingredients_id_seq'::regclass);


--
-- TOC entry 4766 (class 2604 OID 16427)
-- Name: recipe_ingredients id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recipe_ingredients ALTER COLUMN id SET DEFAULT nextval('public.recipe_ingredients_id_seq'::regclass);


--
-- TOC entry 4765 (class 2604 OID 16416)
-- Name: recipes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recipes ALTER COLUMN id SET DEFAULT nextval('public.recipes_id_seq'::regclass);


--
-- TOC entry 4770 (class 2604 OID 16502)
-- Name: user_exclusions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_exclusions ALTER COLUMN id SET DEFAULT nextval('public.user_exclusions_id_seq'::regclass);


--
-- TOC entry 4768 (class 2604 OID 16482)
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- TOC entry 4962 (class 0 OID 16517)
-- Dependencies: 234
-- Data for Name: diet_cooking_method_restrictions; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.diet_cooking_method_restrictions VALUES (1, 1, 'жарка', 'forbidden');
INSERT INTO public.diet_cooking_method_restrictions VALUES (2, 4, 'жарка', 'limited');


--
-- TOC entry 4956 (class 0 OID 16442)
-- Dependencies: 228
-- Data for Name: diet_ingredient_restrictions; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.diet_ingredient_restrictions VALUES (1, 3, 15, 'forbidden');
INSERT INTO public.diet_ingredient_restrictions VALUES (2, 1, 18, 'forbidden');
INSERT INTO public.diet_ingredient_restrictions VALUES (3, 4, 17, 'limited');


--
-- TOC entry 4948 (class 0 OID 16390)
-- Dependencies: 220
-- Data for Name: diets; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.diets VALUES (1, 'Гастроэнтерологическая', 'Щадящая диета для ЖКТ', 30, 55, 2000, 2200);
INSERT INTO public.diets VALUES (2, 'Гепатопротекторная', 'Диета при заболеваниях печени', 25, 60, 1800, 2300);
INSERT INTO public.diets VALUES (3, 'Диабетическая', 'Контроль углеводов и сахара', 30, 45, 2000, 2000);
INSERT INTO public.diets VALUES (4, 'Сердечно-сосудистая', 'Ограничение соли и насыщенных жиров', 25, 55, 1500, 2100);
INSERT INTO public.diets VALUES (5, 'Базовая', 'Общий режим питания', 35, 60, 2500, 2500);


--
-- TOC entry 4950 (class 0 OID 16401)
-- Dependencies: 222
-- Data for Name: ingredients; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.ingredients VALUES (1, 'Куриная грудка', 'Мясо', 120, 22, 2.6, 0, 70, 0, false, false, false);
INSERT INTO public.ingredients VALUES (2, 'Говядина', 'Мясо', 187, 18.9, 12.4, 0, 72, 0, false, false, true);
INSERT INTO public.ingredients VALUES (3, 'Треска', 'Рыба', 82, 18, 0.7, 0, 60, 0, false, false, false);
INSERT INTO public.ingredients VALUES (4, 'Яйцо', 'Яйца', 143, 12.6, 9.5, 0.7, 124, 0, false, false, true);
INSERT INTO public.ingredients VALUES (5, 'Рис (сухой)', 'Крупы', 360, 7, 0.6, 78, 1, 70, false, false, false);
INSERT INTO public.ingredients VALUES (6, 'Гречка (сухая)', 'Крупы', 343, 13, 3.4, 72, 2, 50, false, false, false);
INSERT INTO public.ingredients VALUES (7, 'Овсяные хлопья (сухие)', 'Крупы', 370, 13, 7, 60, 2, 55, false, false, false);
INSERT INTO public.ingredients VALUES (8, 'Картофель', 'Овощи', 77, 2, 0.1, 17, 6, 80, false, false, false);
INSERT INTO public.ingredients VALUES (9, 'Морковь', 'Овощи', 41, 1, 0.2, 10, 69, 35, false, false, false);
INSERT INTO public.ingredients VALUES (10, 'Кабачок', 'Овощи', 17, 1.2, 0.3, 3, 8, 15, false, false, false);
INSERT INTO public.ingredients VALUES (11, 'Брокколи', 'Овощи', 34, 2.8, 0.4, 7, 33, 10, false, false, false);
INSERT INTO public.ingredients VALUES (12, 'Молоко 2.5%', 'Молочные', 52, 3.2, 2.5, 4.8, 44, 30, false, false, false);
INSERT INTO public.ingredients VALUES (13, 'Творог 5%', 'Молочные', 121, 16, 5, 3, 40, 30, false, false, false);
INSERT INTO public.ingredients VALUES (14, 'Йогурт натуральный', 'Молочные', 60, 10, 0.4, 3.6, 36, 35, false, false, false);
INSERT INTO public.ingredients VALUES (15, 'Сахар', 'Подсластители', 387, 0, 0, 100, 1, 100, false, false, false);
INSERT INTO public.ingredients VALUES (16, 'Оливковое масло', 'Жиры', 884, 0, 100, 0, 2, 0, false, false, true);
INSERT INTO public.ingredients VALUES (17, 'Сливочное масло', 'Жиры', 717, 0.9, 81, 0.1, 11, 0, false, false, true);
INSERT INTO public.ingredients VALUES (18, 'Перец чили', 'Овощи', 40, 2, 0.4, 9, 7, 15, true, false, false);
INSERT INTO public.ingredients VALUES (19, 'Лимон', 'Фрукты', 29, 1.1, 0.3, 9, 2, 25, false, true, false);
INSERT INTO public.ingredients VALUES (20, 'Лук репчатый', 'Овощи', 40, 1.1, 0.1, 9, 4, 10, false, false, false);


--
-- TOC entry 4954 (class 0 OID 16424)
-- Dependencies: 226
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
-- TOC entry 4952 (class 0 OID 16413)
-- Dependencies: 224
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
-- TOC entry 4960 (class 0 OID 16499)
-- Dependencies: 232
-- Data for Name: user_exclusions; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.user_exclusions VALUES (1, 1, 2);


--
-- TOC entry 4958 (class 0 OID 16479)
-- Dependencies: 230
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.users VALUES (1, 'testuser@mail.com', 'hashed_password_example', 3, '2026-02-24 21:38:18.655125');


--
-- TOC entry 4977 (class 0 OID 0)
-- Dependencies: 233
-- Name: diet_cooking_method_restrictions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.diet_cooking_method_restrictions_id_seq', 2, true);


--
-- TOC entry 4978 (class 0 OID 0)
-- Dependencies: 227
-- Name: diet_ingredient_restrictions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.diet_ingredient_restrictions_id_seq', 3, true);


--
-- TOC entry 4979 (class 0 OID 0)
-- Dependencies: 219
-- Name: diets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.diets_id_seq', 10, true);


--
-- TOC entry 4980 (class 0 OID 0)
-- Dependencies: 221
-- Name: ingredients_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ingredients_id_seq', 20, true);


--
-- TOC entry 4981 (class 0 OID 0)
-- Dependencies: 225
-- Name: recipe_ingredients_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.recipe_ingredients_id_seq', 7, true);


--
-- TOC entry 4982 (class 0 OID 0)
-- Dependencies: 223
-- Name: recipes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.recipes_id_seq', 3, true);


--
-- TOC entry 4983 (class 0 OID 0)
-- Dependencies: 231
-- Name: user_exclusions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_exclusions_id_seq', 1, true);


--
-- TOC entry 4984 (class 0 OID 0)
-- Dependencies: 229
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 1, true);


--
-- TOC entry 4791 (class 2606 OID 16524)
-- Name: diet_cooking_method_restrictions diet_cooking_method_restrictions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diet_cooking_method_restrictions
    ADD CONSTRAINT diet_cooking_method_restrictions_pkey PRIMARY KEY (id);


--
-- TOC entry 4783 (class 2606 OID 16449)
-- Name: diet_ingredient_restrictions diet_ingredient_restrictions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diet_ingredient_restrictions
    ADD CONSTRAINT diet_ingredient_restrictions_pkey PRIMARY KEY (id);


--
-- TOC entry 4775 (class 2606 OID 16399)
-- Name: diets diets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diets
    ADD CONSTRAINT diets_pkey PRIMARY KEY (id);


--
-- TOC entry 4777 (class 2606 OID 16411)
-- Name: ingredients ingredients_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ingredients
    ADD CONSTRAINT ingredients_pkey PRIMARY KEY (id);


--
-- TOC entry 4781 (class 2606 OID 16430)
-- Name: recipe_ingredients recipe_ingredients_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recipe_ingredients
    ADD CONSTRAINT recipe_ingredients_pkey PRIMARY KEY (id);


--
-- TOC entry 4779 (class 2606 OID 16422)
-- Name: recipes recipes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recipes
    ADD CONSTRAINT recipes_pkey PRIMARY KEY (id);


--
-- TOC entry 4789 (class 2606 OID 16505)
-- Name: user_exclusions user_exclusions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_exclusions
    ADD CONSTRAINT user_exclusions_pkey PRIMARY KEY (id);


--
-- TOC entry 4785 (class 2606 OID 16492)
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 4787 (class 2606 OID 16490)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 4799 (class 2606 OID 16525)
-- Name: diet_cooking_method_restrictions diet_cooking_method_restrictions_diet_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diet_cooking_method_restrictions
    ADD CONSTRAINT diet_cooking_method_restrictions_diet_id_fkey FOREIGN KEY (diet_id) REFERENCES public.diets(id) ON DELETE CASCADE;


--
-- TOC entry 4794 (class 2606 OID 16450)
-- Name: diet_ingredient_restrictions diet_ingredient_restrictions_diet_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diet_ingredient_restrictions
    ADD CONSTRAINT diet_ingredient_restrictions_diet_id_fkey FOREIGN KEY (diet_id) REFERENCES public.diets(id) ON DELETE CASCADE;


--
-- TOC entry 4795 (class 2606 OID 16455)
-- Name: diet_ingredient_restrictions diet_ingredient_restrictions_ingredient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diet_ingredient_restrictions
    ADD CONSTRAINT diet_ingredient_restrictions_ingredient_id_fkey FOREIGN KEY (ingredient_id) REFERENCES public.ingredients(id);


--
-- TOC entry 4792 (class 2606 OID 16436)
-- Name: recipe_ingredients recipe_ingredients_ingredient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recipe_ingredients
    ADD CONSTRAINT recipe_ingredients_ingredient_id_fkey FOREIGN KEY (ingredient_id) REFERENCES public.ingredients(id);


--
-- TOC entry 4793 (class 2606 OID 16431)
-- Name: recipe_ingredients recipe_ingredients_recipe_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recipe_ingredients
    ADD CONSTRAINT recipe_ingredients_recipe_id_fkey FOREIGN KEY (recipe_id) REFERENCES public.recipes(id) ON DELETE CASCADE;


--
-- TOC entry 4797 (class 2606 OID 16511)
-- Name: user_exclusions user_exclusions_ingredient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_exclusions
    ADD CONSTRAINT user_exclusions_ingredient_id_fkey FOREIGN KEY (ingredient_id) REFERENCES public.ingredients(id) ON DELETE CASCADE;


--
-- TOC entry 4798 (class 2606 OID 16506)
-- Name: user_exclusions user_exclusions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_exclusions
    ADD CONSTRAINT user_exclusions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 4796 (class 2606 OID 16493)
-- Name: users users_selected_diet_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_selected_diet_id_fkey FOREIGN KEY (selected_diet_id) REFERENCES public.diets(id) ON DELETE SET NULL;


-- Completed on 2026-02-24 23:16:38

--
-- PostgreSQL database dump complete
--

\unrestrict 7tTjyvLeDDLDEOGieMIsYJslCv59X2GSSsiejCAUm6mgo535nh5ZbsCvJbASDdH

