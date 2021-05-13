-- total volume
SELECT SUM(usd_amount) as volume
FROM dex.trades
WHERE project = 'dodo'

-- 7d volume
SELECT SUM(usd_amount) as volume
FROM dex.trades
WHERE project = 'dodo' AND DATE_PART('day', now() - block_time::timestamptz) < 7

-- 24h volume
SELECT SUM(usd_amount) as volume
FROM dex.trades
WHERE project = 'dodo' AND DATE_PART('day', now() - block_time::timestamptz) < 1

-- total swap
SELECT COUNT(*) as swaps
FROM dex.trades
WHERE project = 'dodo'

-- total user
SELECT COUNT(DISTINCT traders) as users
FROM (
    SELECT tx_from as traders
    FROM dex.trades
    WHERE project = 'dodo'
    UNION ALL
    SELECT tx_to as traders
    FROM dex.trades
    WHERE project = 'dodo'
)

-- new/old user per day
SELECT
    ssq.time, 
    new_users as new,
    (unique_users - new_users) as old
FROM (
    SELECT
        sq.time, 
        count(*) as new_users
    FROM (
        SELECT
            tx_from as user,
            MIN(date_trunc('day', oi.block_time)) as time
        FROM dex.trades oi WHERE project = 'dodo'
        GROUP BY 1
        ORDER BY 1
    ) sq
    GROUP BY 1
) ssq
LEFT JOIN (
    SELECT
        date_trunc('day', oi.block_time) AS time,
        COUNT(DISTINCT tx_from) as unique_users
    FROM dex.trades oi WHERE project = 'dodo'
    GROUP BY 1
    ORDER BY 1
) t2 ON t2.time = ssq.time
ORDER BY 1 DESC

-- new/old user per week
SELECT
    ssq.time, 
    new_users as new,
    (unique_users - new_users) as old
FROM (
    SELECT
        sq.time, 
        count(*) as new_users
    FROM (
        SELECT
            tx_from as user,
            MIN(date_trunc('week', oi.block_time)) as time
        FROM dex.trades oi WHERE project = 'dodo'
        GROUP BY 1
        ORDER BY 1
    ) sq
    GROUP BY 1
) ssq
LEFT JOIN (
    SELECT
        date_trunc('week', oi.block_time) AS time,
        COUNT(DISTINCT tx_from) as unique_users
    FROM dex.trades oi WHERE project = 'dodo'
    GROUP BY 1
    ORDER BY 1
) t2 ON t2.time = ssq.time
ORDER BY 1 DESC

-- new/old user per month
SELECT
    ssq.time, 
    new_users as new,
    (unique_users - new_users) as old
FROM (
    SELECT
        sq.time, 
        count(*) as new_users
    FROM (
        SELECT
            tx_from as user,
            MIN(date_trunc('month', oi.block_time)) as time
        FROM dex.trades oi WHERE project = 'dodo'
        GROUP BY 1
        ORDER BY 1
    ) sq
    GROUP BY 1
) ssq
LEFT JOIN (
    SELECT
        date_trunc('month', oi.block_time) AS time,
        COUNT(DISTINCT tx_from) as unique_users
    FROM dex.trades oi WHERE project = 'dodo'
    GROUP BY 1
    ORDER BY 1
) t2 ON t2.time = ssq.time
ORDER BY 1 DESC

-- transactions per day (bar chart)
SELECT
    date_trunc('day', tx.block_time) AS time, 
    count(*) as count
FROM (
    SELECT DISTINCT ON (tx_hash) tx_hash, block_time
    FROM dex.trades
    WHERE project = 'dodo'
    ) tx
GROUP BY 1
ORDER BY 1

-- transactions per week (bar chart)
SELECT
    date_trunc('week', tx.block_time) AS time, 
    count(*) as count
FROM (
    SELECT DISTINCT ON (tx_hash) tx_hash, block_time
    FROM dex.trades
    WHERE project = 'dodo'
    ) tx
GROUP BY 1
ORDER BY 1

-- transactions per month (bar chart)
SELECT
    date_trunc('month', tx.block_time) AS time, 
    count(*) as count
FROM (
    SELECT DISTINCT ON (tx_hash) tx_hash, block_time
    FROM dex.trades
    WHERE project = 'dodo'
    ) tx
GROUP BY 1
ORDER BY 1


-- volume per day (bar chart)
SELECT
    date_trunc('day', block_time) AS time, 
    SUM(usd_amount) as volume
FROM dex.trades
WHERE project = 'dodo'
GROUP BY 1
ORDER BY 1


-- volume per week (bar chart)
SELECT
    date_trunc('week', block_time) AS time, 
    SUM(usd_amount) as volume
FROM dex.trades
WHERE project = 'dodo'
GROUP BY 1
ORDER BY 1


-- volume per month (bar chart)
SELECT
    date_trunc('month', block_time) AS time, 
    SUM(usd_amount) as volume
FROM dex.trades
WHERE project = 'dodo'
GROUP BY 1
ORDER BY 1


-- top traders day (table)
SELECT
    CONCAT('0x', ENCODE(tx_from, 'hex')) AS user, 
    SUM(usd_amount) AS volume,
    count(*) AS trades
FROM dex.trades
WHERE project = 'dodo' AND DATE_PART('day', now() - block_time::timestamptz) < 1 AND usd_amount IS NOT NULL
GROUP BY tx_from
ORDER BY 2 DESC


-- top traders weekly (table)
SELECT
    CONCAT('0x', ENCODE(tx_from, 'hex')) AS user, 
    SUM(usd_amount) AS volume,
    count(*) AS trades
FROM dex.trades
WHERE project = 'dodo' AND DATE_PART('day', now() - block_time::timestamptz) < 7 AND usd_amount IS NOT NULL
GROUP BY tx_from
ORDER BY 2 DESC


-- top traders all time (table)
SELECT
    CONCAT('0x', ENCODE(tx_from, 'hex')) AS user, 
    SUM(usd_amount) AS volume,
    count(*) AS trades
FROM dex.trades
WHERE project = 'dodo' AND usd_amount IS NOT NULL
GROUP BY tx_from
ORDER BY 2 DESC


-- top token day
SELECT 
    token,
    SUM(usd_amount),
    count(*)
FROM (
    SELECT
    token_a_symbol AS token, usd_amount, block_time
    FROM dex.trades
    WHERE project = 'dodo' AND DATE_PART('day', now() - block_time::timestamptz) < 1 AND usd_amount IS NOT NULL

    UNION ALL

    SELECT
    token_b_symbol AS token, usd_amount, block_time
    FROM dex.trades
    WHERE project = 'dodo' AND DATE_PART('day', now() - block_time::timestamptz) < 1 AND usd_amount IS NOT NULL
)

GROUP BY 1
ORDER BY 2 DESC

-- top token week
SELECT 
    token,
    SUM(usd_amount),
    count(*)
FROM (
    SELECT
    token_a_symbol AS token, usd_amount, block_time
    FROM dex.trades
    WHERE project = 'dodo' AND DATE_PART('day', now() - block_time::timestamptz) < 7 AND usd_amount IS NOT NULL

    UNION ALL

    SELECT
    token_b_symbol AS token, usd_amount, block_time
    FROM dex.trades
    WHERE project = 'dodo' AND DATE_PART('day', now() - block_time::timestamptz) < 7 AND usd_amount IS NOT NULL
)

GROUP BY 1
ORDER BY 2 DESC

-- top token all time
SELECT 
    token,
    SUM(usd_amount),
    count(*)
FROM (
    SELECT
    token_a_symbol AS token, usd_amount, block_time
    FROM dex.trades
    WHERE project = 'dodo' AND usd_amount IS NOT NULL

    UNION ALL

    SELECT
    token_b_symbol AS token, usd_amount, block_time
    FROM dex.trades
    WHERE project = 'dodo' AND usd_amount IS NOT NULL
)

GROUP BY 1
ORDER BY 2 DESC


-- top pair day
SELECT 
    coalesce(token_a_symbol, CONCAT('0x', ENCODE(token_a_address, 'hex'))) || '-' || coalesce(token_b_symbol, CONCAT('0x', ENCODE(token_b_address, 'hex'))) AS token,
    SUM(usd_amount),
    count(*)
FROM dex.trades
WHERE project = 'dodo' AND DATE_PART('day', now() - block_time::timestamptz) < 1 AND usd_amount IS NOT NULL

GROUP BY 1
ORDER BY 2 DESC


-- top pair week
SELECT 
    coalesce(token_a_symbol, CONCAT('0x', ENCODE(token_a_address, 'hex'))) || '-' || coalesce(token_b_symbol, CONCAT('0x', ENCODE(token_b_address, 'hex'))) AS token,
    SUM(usd_amount),
    count(*)
FROM dex.trades
WHERE project = 'dodo' AND DATE_PART('day', now() - block_time::timestamptz) < 7 AND usd_amount IS NOT NULL

GROUP BY 1
ORDER BY 2 DESC


-- top pair all time
SELECT 
    coalesce(token_a_symbol, CONCAT('0x', ENCODE(token_a_address, 'hex'))) || '-' || coalesce(token_b_symbol, CONCAT('0x', ENCODE(token_b_address, 'hex'))) AS token,
    SUM(usd_amount),
    count(*)
FROM dex.trades
WHERE project = 'dodo' AND usd_amount IS NOT NULL

GROUP BY 1
ORDER BY 2 DESC

