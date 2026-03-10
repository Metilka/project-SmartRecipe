--
-- PostgreSQL database dump
--

-- Dumped from database version 18.1
-- Dumped by pg_dump version 18.1

-- Started on 2026-03-05 23:06:19

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 234 (class 1259 OID 24612)
-- Name: diet_allowed_products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.diet_allowed_products (
    diet_id integer NOT NULL,
    product_id integer NOT NULL
);


ALTER TABLE public.diet_allowed_products OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 16517)
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
-- TOC entry 229 (class 1259 OID 16516)
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
-- TOC entry 5007 (class 0 OID 0)
-- Dependencies: 229
-- Name: diet_cooking_method_restrictions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.diet_cooking_method_restrictions_id_seq OWNED BY public.diet_cooking_method_restrictions.id;


--
-- TOC entry 233 (class 1259 OID 24593)
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
-- TOC entry 5008 (class 0 OID 0)
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
    is_saturated_fat boolean DEFAULT false,
    product_id integer
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
-- TOC entry 5009 (class 0 OID 0)
-- Dependencies: 221
-- Name: ingredients_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ingredients_id_seq OWNED BY public.ingredients.id;


--
-- TOC entry 232 (class 1259 OID 24578)
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    id integer NOT NULL,
    name character varying(150) NOT NULL,
    category character varying(100)
);


ALTER TABLE public.products OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 24577)
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
-- TOC entry 5010 (class 0 OID 0)
-- Dependencies: 231
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.products_id_seq OWNED BY public.products.id;


--
-- TOC entry 236 (class 1259 OID 24646)
-- Name: recipe_diets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.recipe_diets (
    recipe_id integer NOT NULL,
    diet_id integer NOT NULL
);


ALTER TABLE public.recipe_diets OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 16424)
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
-- TOC entry 5011 (class 0 OID 0)
-- Dependencies: 225
-- Name: recipe_ingredients_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.recipe_ingredients_id_seq OWNED BY public.recipe_ingredients.id;


--
-- TOC entry 237 (class 1259 OID 24663)
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
-- TOC entry 5012 (class 0 OID 0)
-- Dependencies: 223
-- Name: recipes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.recipes_id_seq OWNED BY public.recipes.id;


--
-- TOC entry 235 (class 1259 OID 24629)
-- Name: user_excluded_products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_excluded_products (
    user_id integer NOT NULL,
    product_id integer NOT NULL
);


ALTER TABLE public.user_excluded_products OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 16479)
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
-- TOC entry 227 (class 1259 OID 16478)
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
-- TOC entry 5013 (class 0 OID 0)
-- Dependencies: 227
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- TOC entry 4784 (class 2604 OID 16520)
-- Name: diet_cooking_method_restrictions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diet_cooking_method_restrictions ALTER COLUMN id SET DEFAULT nextval('public.diet_cooking_method_restrictions_id_seq'::regclass);


--
-- TOC entry 4775 (class 2604 OID 16393)
-- Name: diets id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diets ALTER COLUMN id SET DEFAULT nextval('public.diets_id_seq'::regclass);


--
-- TOC entry 4776 (class 2604 OID 16404)
-- Name: ingredients id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ingredients ALTER COLUMN id SET DEFAULT nextval('public.ingredients_id_seq'::regclass);


--
-- TOC entry 4785 (class 2604 OID 24581)
-- Name: products id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);


--
-- TOC entry 4781 (class 2604 OID 16427)
-- Name: recipe_ingredients id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recipe_ingredients ALTER COLUMN id SET DEFAULT nextval('public.recipe_ingredients_id_seq'::regclass);


--
-- TOC entry 4780 (class 2604 OID 16416)
-- Name: recipes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recipes ALTER COLUMN id SET DEFAULT nextval('public.recipes_id_seq'::regclass);


--
-- TOC entry 4782 (class 2604 OID 16482)
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- TOC entry 4998 (class 0 OID 24612)
-- Dependencies: 234
-- Data for Name: diet_allowed_products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.diet_allowed_products (diet_id, product_id) FROM stdin;
1	1
1	3
1	4
1	5
1	6
1	7
1	8
1	9
1	10
1	11
1	12
1	13
1	14
1	15
1	16
1	17
1	18
1	19
1	20
2	1
2	2
2	3
2	4
2	5
2	6
2	7
2	8
2	9
2	10
2	11
2	12
2	13
2	14
2	15
2	16
2	17
2	18
2	19
2	20
3	1
3	2
3	3
3	4
3	5
3	6
3	7
3	8
3	9
3	10
3	11
3	12
3	14
3	15
3	16
3	17
3	18
3	19
3	20
4	1
4	2
4	3
4	4
4	5
4	6
4	7
4	8
4	9
4	10
4	11
4	12
4	13
4	14
4	15
4	16
4	17
4	18
4	19
4	20
5	1
5	2
5	3
5	4
5	5
5	6
5	7
5	8
5	9
5	10
5	11
5	12
5	13
5	14
5	15
5	16
5	17
5	18
5	19
5	20
\.


--
-- TOC entry 4994 (class 0 OID 16517)
-- Dependencies: 230
-- Data for Name: diet_cooking_method_restrictions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.diet_cooking_method_restrictions (id, diet_id, cooking_method, status) FROM stdin;
1	1	жарка	forbidden
2	4	жарка	allowed
\.


--
-- TOC entry 4997 (class 0 OID 24593)
-- Dependencies: 233
-- Data for Name: diet_product_rules; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.diet_product_rules (diet_id, product_id, status) FROM stdin;
3	13	forbidden
1	2	forbidden
4	4	allowed
\.


--
-- TOC entry 4984 (class 0 OID 16390)
-- Dependencies: 220
-- Data for Name: diets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.diets (id, name, description, max_fat_percent, max_carbs_percent, max_salt_mg, max_calories) FROM stdin;
1	Гастроэнтерологическая	Щадящая диета для ЖКТ	30	55	2000	2200
2	Гепатопротекторная	Диета при заболеваниях печени	25	60	1800	2300
3	Диабетическая	Контроль углеводов и сахара	30	45	2000	2000
4	Сердечно-сосудистая	Ограничение соли и насыщенных жиров	25	55	1500	2100
5	Базовая	Общий режим питания	35	60	2500	2500
\.


--
-- TOC entry 4986 (class 0 OID 16401)
-- Dependencies: 222
-- Data for Name: ingredients; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ingredients (id, name, category, calories_per_100g, protein_per_100g, fat_per_100g, carbs_per_100g, salt_mg_per_100g, glycemic_index, is_spicy, is_acidic, is_saturated_fat, product_id) FROM stdin;
16	Оливковое масло	Жиры	884	0	100	0	2	0	f	f	t	1
18	Перец чили	Овощи	40	2	0.4	9	7	15	t	f	f	2
20	Лук репчатый	Овощи	40	1.1	0.1	9	4	10	f	f	f	3
17	Сливочное масло	Жиры	717	0.9	81	0.1	11	0	f	f	t	4
12	Молоко 2.5%	Молочные	52	3.2	2.5	4.8	44	30	f	f	f	5
7	Овсяные хлопья (сухие)	Крупы	370	13	7	60	2	55	f	f	f	6
10	Кабачок	Овощи	17	1.2	0.3	3	8	15	f	f	f	7
8	Картофель	Овощи	77	2	0.1	17	6	80	f	f	f	8
6	Гречка (сухая)	Крупы	343	13	3.4	72	2	50	f	f	f	9
2	Говядина	Мясо	187	18.9	12.4	0	72	0	f	f	t	10
4	Яйцо	Яйца	143	12.6	9.5	0.7	124	0	f	f	t	11
19	Лимон	Фрукты	29	1.1	0.3	9	2	25	f	t	f	12
15	Сахар	Подсластители	387	0	0	100	1	100	f	f	f	13
5	Рис (сухой)	Крупы	360	7	0.6	78	1	70	f	f	f	14
1	Куриная грудка	Мясо	120	22	2.6	0	70	0	f	f	f	15
9	Морковь	Овощи	41	1	0.2	10	69	35	f	f	f	16
3	Треска	Рыба	82	18	0.7	0	60	0	f	f	f	17
11	Брокколи	Овощи	34	2.8	0.4	7	33	10	f	f	f	18
13	Творог 5%	Молочные	121	16	5	3	40	30	f	f	f	19
14	Йогурт натуральный	Молочные	60	10	0.4	3.6	36	35	f	f	f	20
\.


--
-- TOC entry 4996 (class 0 OID 24578)
-- Dependencies: 232
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.products (id, name, category) FROM stdin;
1	Оливковое масло	Жиры
2	Перец чили	Овощи
3	Лук репчатый	Овощи
4	Сливочное масло	Жиры
5	Молоко 2.5%	Молочные
6	Овсяные хлопья (сухие)	Крупы
7	Кабачок	Овощи
8	Картофель	Овощи
9	Гречка (сухая)	Крупы
10	Говядина	Мясо
11	Яйцо	Яйца
12	Лимон	Фрукты
13	Сахар	Подсластители
14	Рис (сухой)	Крупы
15	Куриная грудка	Мясо
16	Морковь	Овощи
17	Треска	Рыба
18	Брокколи	Овощи
19	Творог 5%	Молочные
20	Йогурт натуральный	Молочные
\.


--
-- TOC entry 5000 (class 0 OID 24646)
-- Dependencies: 236
-- Data for Name: recipe_diets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.recipe_diets (recipe_id, diet_id) FROM stdin;
1	5
2	5
3	5
\.


--
-- TOC entry 4990 (class 0 OID 16424)
-- Dependencies: 226
-- Data for Name: recipe_ingredients; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.recipe_ingredients (id, recipe_id, ingredient_id, quantity, unit) FROM stdin;
1	2	20	50	г
2	2	6	100	г
3	2	2	200	г
4	1	1	200	г
5	1	5	100	г
6	3	4	150	г
7	3	11	100	г
\.


--
-- TOC entry 5001 (class 0 OID 24663)
-- Dependencies: 237
-- Data for Name: recipe_nutrients_per_100g; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.recipe_nutrients_per_100g (recipe_id, kcal, protein, fat, carbs, sugar, sodium_mg) FROM stdin;
3	99.4	8.68	5.86	3.22	\N	87.6
2	210.57142857142858	14.67142857142857	8.071428571428571	21.857142857142858	\N	42.285714285714285
1	200	17	1.9333333333333333	26	\N	47
\.


--
-- TOC entry 4988 (class 0 OID 16413)
-- Dependencies: 224
-- Data for Name: recipes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.recipes (id, title, description, cooking_method, cooking_time, servings, instructions) FROM stdin;
1	Отварная курица с рисом	Щадящее блюдо для ЖКТ	варка	40	2	1. Промойте рис в холодной воде до прозрачности. Залейте 1 стаканом воды, добавьте щепотку соли и варите на медленном огне 20 минут до готовности. \n2. Куриное филе промойте, залейте холодной водой, доведите до кипения, снимите пену. Варите 20-25 минут до готовности. \n3. Готовую курицу нарежьте небольшими кусочками. Подавайте рис с курицей без добавления специй.
2	Гречка с тушёной говядиной	Питательное блюдо	тушение	60	2	1. Гречку переберите, промойте, залейте водой (соотношение гречки и воды - 1 к 2), добавьте щепотку соли. Варите 20-25 минут до полного впитывания воды. \n2. Говядину нарежьте небольшими кубиками, обжарьте на антипригарной сковороде 20 минут. \n3. Добавьте к мясу 1 мелко нарезанную луковицу, обжаривайте ещё 3-4 минуты. Залейте горячей водой, накройте крышкой и тушите на медленном огне 30-40 минут до мягкости мяса. \n4. Смешайте готовую гречку с тушёной говядиной, дайте настояться под крышкой 5-10 минут перед подачей.
3	Омлет с брокколи	Белковый завтрак	жарка	15	1	1. Брокколи отварите до готовности. \n2. В миске взбейте 2 яйца, добавьте щепотку соли. \n3. Разогрейте сковороду, затем выложите брокколи, залейте яичной смесью. \n4. Готовьте на слабом огне под крышкой 5-7 минут до полного застывания яиц. Подавайте горячим, посыпав зеленью по желанию.
\.


--
-- TOC entry 4999 (class 0 OID 24629)
-- Dependencies: 235
-- Data for Name: user_excluded_products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_excluded_products (user_id, product_id) FROM stdin;
1	10
\.


--
-- TOC entry 4992 (class 0 OID 16479)
-- Dependencies: 228
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, email, password_hash, selected_diet_id, created_at) FROM stdin;
1	testuser@mail.com	hashed_password_example	3	2026-02-24 21:38:18.655125
\.


--
-- TOC entry 5014 (class 0 OID 0)
-- Dependencies: 229
-- Name: diet_cooking_method_restrictions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.diet_cooking_method_restrictions_id_seq', 2, true);


--
-- TOC entry 5015 (class 0 OID 0)
-- Dependencies: 219
-- Name: diets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.diets_id_seq', 10, true);


--
-- TOC entry 5016 (class 0 OID 0)
-- Dependencies: 221
-- Name: ingredients_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ingredients_id_seq', 20, true);


--
-- TOC entry 5017 (class 0 OID 0)
-- Dependencies: 231
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.products_id_seq', 20, true);


--
-- TOC entry 5018 (class 0 OID 0)
-- Dependencies: 225
-- Name: recipe_ingredients_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.recipe_ingredients_id_seq', 7, true);


--
-- TOC entry 5019 (class 0 OID 0)
-- Dependencies: 223
-- Name: recipes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.recipes_id_seq', 3, true);


--
-- TOC entry 5020 (class 0 OID 0)
-- Dependencies: 227
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 1, true);


--
-- TOC entry 4814 (class 2606 OID 24618)
-- Name: diet_allowed_products diet_allowed_products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diet_allowed_products
    ADD CONSTRAINT diet_allowed_products_pkey PRIMARY KEY (diet_id, product_id);


--
-- TOC entry 4806 (class 2606 OID 16524)
-- Name: diet_cooking_method_restrictions diet_cooking_method_restrictions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diet_cooking_method_restrictions
    ADD CONSTRAINT diet_cooking_method_restrictions_pkey PRIMARY KEY (id);


--
-- TOC entry 4812 (class 2606 OID 24601)
-- Name: diet_product_rules diet_product_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diet_product_rules
    ADD CONSTRAINT diet_product_rules_pkey PRIMARY KEY (diet_id, product_id);


--
-- TOC entry 4789 (class 2606 OID 16399)
-- Name: diets diets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diets
    ADD CONSTRAINT diets_pkey PRIMARY KEY (id);


--
-- TOC entry 4792 (class 2606 OID 16411)
-- Name: ingredients ingredients_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ingredients
    ADD CONSTRAINT ingredients_pkey PRIMARY KEY (id);


--
-- TOC entry 4808 (class 2606 OID 24587)
-- Name: products products_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_name_key UNIQUE (name);


--
-- TOC entry 4810 (class 2606 OID 24585)
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- TOC entry 4819 (class 2606 OID 24652)
-- Name: recipe_diets recipe_diets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recipe_diets
    ADD CONSTRAINT recipe_diets_pkey PRIMARY KEY (recipe_id, diet_id);


--
-- TOC entry 4798 (class 2606 OID 16430)
-- Name: recipe_ingredients recipe_ingredients_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recipe_ingredients
    ADD CONSTRAINT recipe_ingredients_pkey PRIMARY KEY (id);


--
-- TOC entry 4800 (class 2606 OID 24675)
-- Name: recipe_ingredients recipe_ingredients_recipe_id_ingredient_id_uk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recipe_ingredients
    ADD CONSTRAINT recipe_ingredients_recipe_id_ingredient_id_uk UNIQUE (recipe_id, ingredient_id);


--
-- TOC entry 4821 (class 2606 OID 24668)
-- Name: recipe_nutrients_per_100g recipe_nutrients_per_100g_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recipe_nutrients_per_100g
    ADD CONSTRAINT recipe_nutrients_per_100g_pkey PRIMARY KEY (recipe_id);


--
-- TOC entry 4794 (class 2606 OID 16422)
-- Name: recipes recipes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recipes
    ADD CONSTRAINT recipes_pkey PRIMARY KEY (id);


--
-- TOC entry 4817 (class 2606 OID 24635)
-- Name: user_excluded_products user_excluded_products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_excluded_products
    ADD CONSTRAINT user_excluded_products_pkey PRIMARY KEY (user_id, product_id);


--
-- TOC entry 4802 (class 2606 OID 16492)
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 4804 (class 2606 OID 16490)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 4790 (class 1259 OID 24678)
-- Name: idx_ingredients_product; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_ingredients_product ON public.ingredients USING btree (product_id);


--
-- TOC entry 4795 (class 1259 OID 24677)
-- Name: idx_recipe_ingredients_ing; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_recipe_ingredients_ing ON public.recipe_ingredients USING btree (ingredient_id);


--
-- TOC entry 4796 (class 1259 OID 24676)
-- Name: idx_recipe_ingredients_recipe; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_recipe_ingredients_recipe ON public.recipe_ingredients USING btree (recipe_id);


--
-- TOC entry 4815 (class 1259 OID 24679)
-- Name: idx_user_excluded_products; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_excluded_products ON public.user_excluded_products USING btree (user_id, product_id);


--
-- TOC entry 4829 (class 2606 OID 24619)
-- Name: diet_allowed_products diet_allowed_products_diet_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diet_allowed_products
    ADD CONSTRAINT diet_allowed_products_diet_id_fkey FOREIGN KEY (diet_id) REFERENCES public.diets(id) ON DELETE CASCADE;


--
-- TOC entry 4830 (class 2606 OID 24624)
-- Name: diet_allowed_products diet_allowed_products_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diet_allowed_products
    ADD CONSTRAINT diet_allowed_products_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- TOC entry 4826 (class 2606 OID 16525)
-- Name: diet_cooking_method_restrictions diet_cooking_method_restrictions_diet_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diet_cooking_method_restrictions
    ADD CONSTRAINT diet_cooking_method_restrictions_diet_id_fkey FOREIGN KEY (diet_id) REFERENCES public.diets(id) ON DELETE CASCADE;


--
-- TOC entry 4827 (class 2606 OID 24602)
-- Name: diet_product_rules diet_product_rules_diet_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diet_product_rules
    ADD CONSTRAINT diet_product_rules_diet_id_fkey FOREIGN KEY (diet_id) REFERENCES public.diets(id) ON DELETE CASCADE;


--
-- TOC entry 4828 (class 2606 OID 24607)
-- Name: diet_product_rules diet_product_rules_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diet_product_rules
    ADD CONSTRAINT diet_product_rules_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- TOC entry 4822 (class 2606 OID 24588)
-- Name: ingredients ingredients_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ingredients
    ADD CONSTRAINT ingredients_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE RESTRICT;


--
-- TOC entry 4833 (class 2606 OID 24658)
-- Name: recipe_diets recipe_diets_diet_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recipe_diets
    ADD CONSTRAINT recipe_diets_diet_id_fkey FOREIGN KEY (diet_id) REFERENCES public.diets(id) ON DELETE CASCADE;


--
-- TOC entry 4834 (class 2606 OID 24653)
-- Name: recipe_diets recipe_diets_recipe_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recipe_diets
    ADD CONSTRAINT recipe_diets_recipe_id_fkey FOREIGN KEY (recipe_id) REFERENCES public.recipes(id) ON DELETE CASCADE;


--
-- TOC entry 4823 (class 2606 OID 16436)
-- Name: recipe_ingredients recipe_ingredients_ingredient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recipe_ingredients
    ADD CONSTRAINT recipe_ingredients_ingredient_id_fkey FOREIGN KEY (ingredient_id) REFERENCES public.ingredients(id);


--
-- TOC entry 4824 (class 2606 OID 16431)
-- Name: recipe_ingredients recipe_ingredients_recipe_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recipe_ingredients
    ADD CONSTRAINT recipe_ingredients_recipe_id_fkey FOREIGN KEY (recipe_id) REFERENCES public.recipes(id) ON DELETE CASCADE;


--
-- TOC entry 4835 (class 2606 OID 24669)
-- Name: recipe_nutrients_per_100g recipe_nutrients_per_100g_recipe_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recipe_nutrients_per_100g
    ADD CONSTRAINT recipe_nutrients_per_100g_recipe_id_fkey FOREIGN KEY (recipe_id) REFERENCES public.recipes(id) ON DELETE CASCADE;


--
-- TOC entry 4831 (class 2606 OID 24641)
-- Name: user_excluded_products user_excluded_products_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_excluded_products
    ADD CONSTRAINT user_excluded_products_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- TOC entry 4832 (class 2606 OID 24636)
-- Name: user_excluded_products user_excluded_products_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_excluded_products
    ADD CONSTRAINT user_excluded_products_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 4825 (class 2606 OID 16493)
-- Name: users users_selected_diet_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_selected_diet_id_fkey FOREIGN KEY (selected_diet_id) REFERENCES public.diets(id) ON DELETE SET NULL;


-- Completed on 2026-03-05 23:06:20

--
-- PostgreSQL database dump complete
--

