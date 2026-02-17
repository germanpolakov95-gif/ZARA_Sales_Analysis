
-- Top 10 products by sales
EXPLAIN ANALYZE
SELECT 
 p.name_,
 c.category_name,
 SUM(fs.sales_volume) AS total_sales
FROM public.fact_sales fs
JOIN public.products p ON fs.product_id = p.product_id
JOIN public.categories c ON fs.category_id = c.category_id
GROUP BY p.name_, c.category_name
ORDER BY total_sales DESC 
LIMIT 10; 

-- Sales by category and section 
EXPLAIN ANALYZE
SELECT 
    sec.section_name,
    c.category_name,
    AVG(fs.sales_volume) AS avg_sales,
    COUNT(*) AS product_count
FROM public.fact_sales fs
JOIN public.sections sec ON fs.section_id = sec.section_id
JOIN public.categories c ON fs.category_id = c.category_id
GROUP BY sec.section_name, c.category_name
ORDER BY avg_sales DESC;

-- The impact of promos on sales
EXPLAIN ANALYZE
SELECT 
    fs.promotion,
    AVG(fs.sales_volume) AS avg_sales,
    SUM(fs.sales_volume) AS total_sales
FROM public.fact_sales fs
GROUP BY fs.promotion;

-- Sales by position in the store
EXPLAIN ANALYZE
SELECT 
    pos.position_name,
    SUM(fs.sales_volume) AS total_sales
FROM public.fact_sales fs
JOIN public.product_position pos ON fs.position_id = pos.position_id
GROUP BY pos.position_name
ORDER BY total_sales DESC;

-- Price and sales dynamics 
EXPLAIN ANALYZE
SELECT 
    p.price,
    AVG(fs.sales_volume) AS avg_sales
FROM public.fact_sales fs
JOIN public.products p ON fs.product_id = p.product_id
GROUP BY p.price
ORDER BY p.price;

-- Seasonal vs non-seasonal 
EXPLAIN ANALYZE
SELECT 
    fs.seasonal,
    SUM(fs.sales_volume) AS total_sales
FROM public.fact_sales fs
GROUP BY fs.seasonal;