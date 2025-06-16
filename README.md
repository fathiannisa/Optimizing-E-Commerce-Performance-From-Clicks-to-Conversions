# Optimizing-E-Commerce-Performance-From-Clicks-to-Conversions
# E-Commerce SQL Analytics – Sepi Case Study

## 🧠 Objective  
Uncover behavioral insights, performance metrics, and buyer patterns to support decision-making around marketing efficiency, user engagement, and conversion strategy.

---

## 🔍 Key Business Questions & SQL Solutions

### 1. First & Last Order Tracking  
Identified each buyer's first and last order across every shop  
**Techniques:** `GROUP BY`, `MIN()`, `MAX()`, chronological sorting  

---

### 2. Repeat Buyer Detection (Monthly)  
Flagged users who made multiple purchases within a month  
**Techniques:** `EXTRACT(MONTH FROM order_time)`, `HAVING COUNT > 1`  

---

### 3. First Buyer per Shop (with Tie Handling)  
Determined earliest buyers in each shop, including ties  
**Techniques:**  
- `MIN() OVER(PARTITION BY shopid)`  
- `FIRST_VALUE()` for deterministic single result  
- `ROW_NUMBER()` and CTEs for clarity  

---

### 4. Top 10 High-GMV Buyers (ID & SG only)  
Ranked top revenue contributors from Indonesia and Singapore  
**Techniques:**  
- `JOIN` with user-country mapping  
- `SUM(gmv)` aggregation  
- `LIMIT 10` with descending sort  

---

### 5. Even vs. Odd ItemID Order Distribution by Country  
Segmented buyer order activity by parity of item ID  
**Techniques:** `CASE WHEN`, modulo `%`, conditional aggregation  

---

### 6. Shop Conversion & Engagement Metrics  
Calculated conversion rate (CVR) and click-through rate (CTR) per shop  
**Metrics:**  
- CVR = orders / item views  
- CTR = clicks / impressions  
**Techniques:**  
- Window functions: `SUM(...) OVER(PARTITION BY shopid)`  
- Subqueries for total order count  
- Clean metric formatting with typecasting  

---

## 🛠️ SQL Skills & Concepts Applied

| Category              | Techniques Used                                                                 |
|-----------------------|----------------------------------------------------------------------------------|
| Filtering             | `WHERE`, `IN`, `EXTRACT()`                                                       |
| Aggregation           | `COUNT()`, `SUM()`, `MIN()`, `MAX()`                                             |
| Window Functions      | `FIRST_VALUE()`, `ROW_NUMBER()`, `MIN() OVER()`                                  |
| Conditional Logic     | `CASE WHEN` for flag creation and binary logic                                   |
| Subqueries & CTEs     | Modular logic building with CTEs and nested subqueries                           |
| Joins                 | `INNER JOIN`, `USING`, and `JOIN` with temp tables                               |
| Performance Tuning    | Use of temporary tables (`CREATE TEMP TABLE`) for repeated country lookups       |
| Ordering & Ranking    | `ORDER BY`, `LIMIT`, `PARTITION BY`                                              |

---

## 📈 Outcome  
Built a full-stack SQL analysis pipeline to surface buyer trends, shop performance, and item-level behavior — all with clean, readable, and scalable SQL logic.
