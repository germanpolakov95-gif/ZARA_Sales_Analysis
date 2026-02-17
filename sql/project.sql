-- SCHEMA: public

-- DROP SCHEMA IF EXISTS public ;

CREATE SCHEMA IF NOT EXISTS public
    AUTHORIZATION pg_database_owner;

COMMENT ON SCHEMA public
    IS 'standard public schema';

GRANT USAGE ON SCHEMA public TO PUBLIC;

GRANT ALL ON SCHEMA public TO pg_database_owner;


-- Reference tables
CREATE TABLE IF NOT EXISTS public.brands
(
    brand_id integer NOT NULL DEFAULT nextval('brands_brand_id_seq'::regclass),
    brand_name text COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT brands_pkey PRIMARY KEY (brand_id),
    CONSTRAINT brand_name_unique UNIQUE (brand_name)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.brands
    OWNER to postgres;



CREATE TABLE IF NOT EXISTS public.sections
(
    section_id integer NOT NULL DEFAULT nextval('sectioms_section_id_seq'::regclass),
    section_name text COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT sectioms_pkey PRIMARY KEY (section_id),
    CONSTRAINT section_name_unique UNIQUE (section_name)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.sections
    OWNER to postgres;


CREATE TABLE IF NOT EXISTS public.product_position
(
    position_id integer NOT NULL DEFAULT nextval('product_position_position_id_seq'::regclass),
    position_name text COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT product_position_pkey PRIMARY KEY (position_id),
    CONSTRAINT position_name_unique UNIQUE (position_name)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.product_position
    OWNER to postgres;


CREATE TABLE IF NOT EXISTS public.products
(
    product_id bigint NOT NULL,
    sku text COLLATE pg_catalog."default" NOT NULL,
    name_ text COLLATE pg_catalog."default" NOT NULL,
    description text COLLATE pg_catalog."default" NOT NULL,
    url text COLLATE pg_catalog."default",
    price numeric,
    currency text COLLATE pg_catalog."default",
    CONSTRAINT products_pkey PRIMARY KEY (product_id),
    CONSTRAINT sku_unique UNIQUE (sku)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.products
    OWNER to postgres;


-- Fact Sales
CREATE TABLE IF NOT EXISTS public.fact_sales
(
    sale_id integer NOT NULL DEFAULT nextval('fact_sales_sale_id_seq'::regclass),
    product_id bigint,
    brand_id integer,
    section_id integer,
    category_id integer,
    position_id integer,
    promotion boolean,
    seasonal boolean,
    scraped_at timestamp without time zone,
    sales_volume integer,
    CONSTRAINT fact_sales_pkey PRIMARY KEY (sale_id),
    CONSTRAINT brand_fkey FOREIGN KEY (brand_id)
        REFERENCES public.brands (brand_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT category_fkey FOREIGN KEY (category_id)
        REFERENCES public.categories (category_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT position_fkey FOREIGN KEY (position_id)
        REFERENCES public.product_position (position_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT product_fkey FOREIGN KEY (product_id)
        REFERENCES public.products (product_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT section_fkey FOREIGN KEY (section_id)
        REFERENCES public.sections (section_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.fact_sales
    OWNER to postgres;



-- Temporary table for importing data from csv
CREATE TABLE IF NOT EXISTS public.import_from_csv
(
    product_id bigint,
    product_position text COLLATE pg_catalog."default",
    promotion text COLLATE pg_catalog."default",
    product_category text COLLATE pg_catalog."default",
    seasonal text COLLATE pg_catalog."default",
    sales_volume integer,
    brand text COLLATE pg_catalog."default",
    url text COLLATE pg_catalog."default",
    sku text COLLATE pg_catalog."default",
    name_ text COLLATE pg_catalog."default",
    description text COLLATE pg_catalog."default",
    price numeric,
    currency text COLLATE pg_catalog."default",
    scraped_at timestamp without time zone,
    terms text COLLATE pg_catalog."default",
    sections text COLLATE pg_catalog."default"
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.import_from_csv
    OWNER to postgres;


-- Import data from csv
/*
COPY public.import_from_csv
FROM '"C:\Users\Server\OneDrive\Desktop\pet-project\zara.csv"'
DELIMITER';' 
CSV HEADER;
*/


-- Populating reference tables with unique values
INSERT INTO public.brands (brand_name)
SELECT DISTINCT brand FROM public.import_from_csv
ON CONFLICT (brand_name) DO NOTHING;

INSERT INTO public.sections (section_name)
SELECT DISTINCT sections FROM public.import_from_csv
ON CONFLICT (section_name) DO NOTHING;

INSERT INTO public.categories (category_name)
SELECT DISTINCT terms FROM public.import_from_csv
ON CONFLICT (category_name) DO NOTHING;

INSERT INTO public.product_position (position_name)
SELECT DISTINCT product_position FROM public.import_from_csv
ON CONFLICT (position_name) DO NOTHING;

INSERT INTO public.products (product_id, sku, name_, description, url, price, currency)
SELECT DISTINCT 
 product_id, 
 sku, 
 name_, 
 description, 
 url, 
 price, 
 currency
FROM public.import_from_csv
ON CONFLICT (product_id) DO NOTHING;



-- Clearing data from complete duplicates and rows with empty/missing values
DELETE FROM import_from_csv
WHERE product_id IS NULL 
OR product_position IS NULL 
OR promotion IS NULL
OR product_category IS NULL
OR seasonal IS NULL
OR sales_volume IS NULL
OR brand IS NULL
OR url IS NULL
OR sku IS NULL
OR name_ IS NULL
OR description IS NULL
OR price IS NULL
OR currency IS NULL
OR terms IS NULL
OR scraped_at IS NULL
OR sections IS NULL;


DELETE FROM import_from_csv
WHERE ctid NOT IN (
    SELECT min(ctid)
    FROM import_from_csv
    GROUP BY product_id, product_position, promotion, product_category, seasonal, 
 sales_volume, brand, url, sku, name_, description, price, currency, terms, scraped_at, sections
);


-- Adding data to fact sales
INSERT INTO public.fact_sales (
  product_id, brand_id, section_id, category_id, position_id,
  promotion, seasonal, scraped_at, sales_volume
)
SELECT 
 s.product_id,
 b.brand_id,
 sec.section_id,
 cat.category_id,
 pos.position_id,
 (s.promotion = 'Yes')::BOOLEAN,
 (s.seasonal = 'Yes')::BOOLEAN,
 s.scraped_at,
 s.sales_volume
FROM public.import_from_csv s
JOIN public.brands b ON b.brand_name = s.brand
JOIN public.sections sec ON sec.section_name = s.sections
JOIN public.categories cat ON cat.category_name = s.terms
JOIN public.product_position pos ON pos.position_name = s.product_position
ON CONFLICT DO NOTHING;

-- Delete the temporary table
DROP TABLE import_from_csv;