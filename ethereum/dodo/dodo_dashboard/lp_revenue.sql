-- lp per day

WITH v1_lp_rate AS (
    SELECT "dppAddress" AS contract_address, "lpFeeRate" AS lp_rate, call_block_time AS block_time 
    FROM dodo."DPPFactory_call_initDODOPrivatePool" WHERE call_success IS TRUE    
    UNION
    SELECT contract_address, "newLpFeeRate" AS lp_rate, evt_block_time AS block_time 
    FROM  dodo."DPP_evt_LpFeeRateChange"
),

dpp_lp_rate AS (
    SELECT "output_newBornDODO" AS contract_address, "lpFeeRate" AS lp_rate, call_block_time AS block_time 
    FROM dodo."DODOZoo_call_breedDODO" WHERE call_success IS TRUE    
    UNION
    SELECT contract_address, "newLiquidityProviderFeeRate" AS lp_rate, evt_block_time AS block_time 
    FROM  dodo."DODO_evt_UpdateLiquidityProviderFeeRate"
),

dvm_lp_rate AS (
    SELECT "output_newVendingMachine" AS contract_address, "lpFeeRate" AS lp_rate, call_block_time AS block_time 
    FROM dodo."DVMFactory_call_createDODOVendingMachine" WHERE call_success IS TRUE    
),

dodo_lp_rate AS (
    SELECT * FROM v1_lp_rate
    UNION
    SELECT * FROM dpp_lp_rate
    UNION
    SELECT * FROM dvm_lp_rate
),

dodo_lp_rate_range AS (
 SELECT DISTINCT ON (start_lp.contract_address, start_lp.block_time) start_lp.contract_address AS contract_address, start_lp.lp_rate AS lp_rate, start_lp.block_time AS start_time, coalesce(end_lp.block_time, '2121-01-01') AS end_time
    FROM (
        SELECT * FROM dodo_lp_rate ORDER BY "contract_address", block_time
        ) start_lp
    LEFT JOIN (
        SELECT * FROM dodo_lp_rate ORDER BY "contract_address", block_time
        ) end_lp
    ON start_lp.contract_address = end_lp.contract_address AND start_lp.block_time < end_lp.block_time
)

SELECT date_trunc('day', dex.trades.block_time) AS time,
SUM(CASE WHEN dodo_lp_rate_range.lp_rate IS NOT NULL THEN dex.trades.usd_amount * dodo_lp_rate_range.lp_rate / 10^18 ELSE 0 END) AS lp 
FROM 
dex.trades 
LEFT JOIN dodo_lp_rate_range ON dex.trades.exchange_contract_address = dodo_lp_rate_range.contract_address 
AND dex.trades.block_time BETWEEN dodo_lp_rate_range.start_time AND dodo_lp_rate_range.end_time WHERE dex.trades.project = 'dodo'

GROUP BY 1
ORDER BY 1

-- lp per week

WITH v1_lp_rate AS (
    SELECT "dppAddress" AS contract_address, "lpFeeRate" AS lp_rate, call_block_time AS block_time 
    FROM dodo."DPPFactory_call_initDODOPrivatePool" WHERE call_success IS TRUE    
    UNION
    SELECT contract_address, "newLpFeeRate" AS lp_rate, evt_block_time AS block_time 
    FROM  dodo."DPP_evt_LpFeeRateChange"
),

dpp_lp_rate AS (
    SELECT "output_newBornDODO" AS contract_address, "lpFeeRate" AS lp_rate, call_block_time AS block_time 
    FROM dodo."DODOZoo_call_breedDODO" WHERE call_success IS TRUE    
    UNION
    SELECT contract_address, "newLiquidityProviderFeeRate" AS lp_rate, evt_block_time AS block_time 
    FROM  dodo."DODO_evt_UpdateLiquidityProviderFeeRate"
),

dvm_lp_rate AS (
    SELECT "output_newVendingMachine" AS contract_address, "lpFeeRate" AS lp_rate, call_block_time AS block_time 
    FROM dodo."DVMFactory_call_createDODOVendingMachine" WHERE call_success IS TRUE    
),

dodo_lp_rate AS (
    SELECT * FROM v1_lp_rate
    UNION
    SELECT * FROM dpp_lp_rate
    UNION
    SELECT * FROM dvm_lp_rate
),

dodo_lp_rate_range AS (
 SELECT DISTINCT ON (start_lp.contract_address, start_lp.block_time) start_lp.contract_address AS contract_address, start_lp.lp_rate AS lp_rate, start_lp.block_time AS start_time, coalesce(end_lp.block_time, '2121-01-01') AS end_time
    FROM (
        SELECT * FROM dodo_lp_rate ORDER BY "contract_address", block_time
        ) start_lp
    LEFT JOIN (
        SELECT * FROM dodo_lp_rate ORDER BY "contract_address", block_time
        ) end_lp
    ON start_lp.contract_address = end_lp.contract_address AND start_lp.block_time < end_lp.block_time
)

SELECT date_trunc('week', dex.trades.block_time) AS time,
SUM(CASE WHEN dodo_lp_rate_range.lp_rate IS NOT NULL THEN dex.trades.usd_amount * dodo_lp_rate_range.lp_rate / 10^18 ELSE 0 END) AS lp 
FROM 
dex.trades 
LEFT JOIN dodo_lp_rate_range ON dex.trades.exchange_contract_address = dodo_lp_rate_range.contract_address 
AND dex.trades.block_time BETWEEN dodo_lp_rate_range.start_time AND dodo_lp_rate_range.end_time WHERE dex.trades.project = 'dodo'

GROUP BY 1
ORDER BY 1

-- lp per month

WITH v1_lp_rate AS (
    SELECT "dppAddress" AS contract_address, "lpFeeRate" AS lp_rate, call_block_time AS block_time 
    FROM dodo."DPPFactory_call_initDODOPrivatePool" WHERE call_success IS TRUE    
    UNION
    SELECT contract_address, "newLpFeeRate" AS lp_rate, evt_block_time AS block_time 
    FROM  dodo."DPP_evt_LpFeeRateChange"
),

dpp_lp_rate AS (
    SELECT "output_newBornDODO" AS contract_address, "lpFeeRate" AS lp_rate, call_block_time AS block_time 
    FROM dodo."DODOZoo_call_breedDODO" WHERE call_success IS TRUE    
    UNION
    SELECT contract_address, "newLiquidityProviderFeeRate" AS lp_rate, evt_block_time AS block_time 
    FROM  dodo."DODO_evt_UpdateLiquidityProviderFeeRate"
),

dvm_lp_rate AS (
    SELECT "output_newVendingMachine" AS contract_address, "lpFeeRate" AS lp_rate, call_block_time AS block_time 
    FROM dodo."DVMFactory_call_createDODOVendingMachine" WHERE call_success IS TRUE    
),

dodo_lp_rate AS (
    SELECT * FROM v1_lp_rate
    UNION
    SELECT * FROM dpp_lp_rate
    UNION
    SELECT * FROM dvm_lp_rate
),

dodo_lp_rate_range AS (
 SELECT DISTINCT ON (start_lp.contract_address, start_lp.block_time) start_lp.contract_address AS contract_address, start_lp.lp_rate AS lp_rate, start_lp.block_time AS start_time, coalesce(end_lp.block_time, '2121-01-01') AS end_time
    FROM (
        SELECT * FROM dodo_lp_rate ORDER BY "contract_address", block_time
        ) start_lp
    LEFT JOIN (
        SELECT * FROM dodo_lp_rate ORDER BY "contract_address", block_time
        ) end_lp
    ON start_lp.contract_address = end_lp.contract_address AND start_lp.block_time < end_lp.block_time
)

SELECT date_trunc('month', dex.trades.block_time) AS time,
SUM(CASE WHEN dodo_lp_rate_range.lp_rate IS NOT NULL THEN dex.trades.usd_amount * dodo_lp_rate_range.lp_rate / 10^18 ELSE 0 END) AS lp 
FROM 
dex.trades 
LEFT JOIN dodo_lp_rate_range ON dex.trades.exchange_contract_address = dodo_lp_rate_range.contract_address 
AND dex.trades.block_time BETWEEN dodo_lp_rate_range.start_time AND dodo_lp_rate_range.end_time WHERE dex.trades.project = 'dodo'

GROUP BY 1
ORDER BY 1

-- lp revenue 24h

WITH v1_lp_rate AS (
    SELECT "dppAddress" AS contract_address, "lpFeeRate" AS lp_rate, call_block_time AS block_time 
    FROM dodo."DPPFactory_call_initDODOPrivatePool" WHERE call_success IS TRUE    
    UNION
    SELECT contract_address, "newLpFeeRate" AS lp_rate, evt_block_time AS block_time 
    FROM  dodo."DPP_evt_LpFeeRateChange"
),

dpp_lp_rate AS (
    SELECT "output_newBornDODO" AS contract_address, "lpFeeRate" AS lp_rate, call_block_time AS block_time 
    FROM dodo."DODOZoo_call_breedDODO" WHERE call_success IS TRUE    
    UNION
    SELECT contract_address, "newLiquidityProviderFeeRate" AS lp_rate, evt_block_time AS block_time 
    FROM  dodo."DODO_evt_UpdateLiquidityProviderFeeRate"
),

dvm_lp_rate AS (
    SELECT "output_newVendingMachine" AS contract_address, "lpFeeRate" AS lp_rate, call_block_time AS block_time 
    FROM dodo."DVMFactory_call_createDODOVendingMachine" WHERE call_success IS TRUE    
),

dodo_lp_rate AS (
    SELECT * FROM v1_lp_rate
    UNION
    SELECT * FROM dpp_lp_rate
    UNION
    SELECT * FROM dvm_lp_rate
),

dodo_lp_rate_range AS (
 SELECT DISTINCT ON (start_lp.contract_address, start_lp.block_time) start_lp.contract_address AS contract_address, start_lp.lp_rate AS lp_rate, start_lp.block_time AS start_time, coalesce(end_lp.block_time, '2121-01-01') AS end_time
    FROM (
        SELECT * FROM dodo_lp_rate ORDER BY "contract_address", block_time
        ) start_lp
    LEFT JOIN (
        SELECT * FROM dodo_lp_rate ORDER BY "contract_address", block_time
        ) end_lp
    ON start_lp.contract_address = end_lp.contract_address AND start_lp.block_time < end_lp.block_time
)

SELECT
SUM(CASE WHEN dodo_lp_rate_range.lp_rate IS NOT NULL THEN dex.trades.usd_amount * dodo_lp_rate_range.lp_rate / 10^18 ELSE 0 END) AS lp 
FROM 
dex.trades 
LEFT JOIN dodo_lp_rate_range ON dex.trades.exchange_contract_address = dodo_lp_rate_range.contract_address 
AND dex.trades.block_time BETWEEN dodo_lp_rate_range.start_time AND dodo_lp_rate_range.end_time WHERE dex.trades.project = 'dodo' AND DATE_PART('day', now() - block_time::timestamptz) < 1

-- lp revenue 7d

WITH v1_lp_rate AS (
    SELECT "dppAddress" AS contract_address, "lpFeeRate" AS lp_rate, call_block_time AS block_time 
    FROM dodo."DPPFactory_call_initDODOPrivatePool" WHERE call_success IS TRUE    
    UNION
    SELECT contract_address, "newLpFeeRate" AS lp_rate, evt_block_time AS block_time 
    FROM  dodo."DPP_evt_LpFeeRateChange"
),

dpp_lp_rate AS (
    SELECT "output_newBornDODO" AS contract_address, "lpFeeRate" AS lp_rate, call_block_time AS block_time 
    FROM dodo."DODOZoo_call_breedDODO" WHERE call_success IS TRUE    
    UNION
    SELECT contract_address, "newLiquidityProviderFeeRate" AS lp_rate, evt_block_time AS block_time 
    FROM  dodo."DODO_evt_UpdateLiquidityProviderFeeRate"
),

dvm_lp_rate AS (
    SELECT "output_newVendingMachine" AS contract_address, "lpFeeRate" AS lp_rate, call_block_time AS block_time 
    FROM dodo."DVMFactory_call_createDODOVendingMachine" WHERE call_success IS TRUE    
),

dodo_lp_rate AS (
    SELECT * FROM v1_lp_rate
    UNION
    SELECT * FROM dpp_lp_rate
    UNION
    SELECT * FROM dvm_lp_rate
),

dodo_lp_rate_range AS (
 SELECT DISTINCT ON (start_lp.contract_address, start_lp.block_time) start_lp.contract_address AS contract_address, start_lp.lp_rate AS lp_rate, start_lp.block_time AS start_time, coalesce(end_lp.block_time, '2121-01-01') AS end_time
    FROM (
        SELECT * FROM dodo_lp_rate ORDER BY "contract_address", block_time
        ) start_lp
    LEFT JOIN (
        SELECT * FROM dodo_lp_rate ORDER BY "contract_address", block_time
        ) end_lp
    ON start_lp.contract_address = end_lp.contract_address AND start_lp.block_time < end_lp.block_time
)

SELECT
SUM(CASE WHEN dodo_lp_rate_range.lp_rate IS NOT NULL THEN dex.trades.usd_amount * dodo_lp_rate_range.lp_rate / 10^18 ELSE 0 END) AS lp 
FROM 
dex.trades 
LEFT JOIN dodo_lp_rate_range ON dex.trades.exchange_contract_address = dodo_lp_rate_range.contract_address 
AND dex.trades.block_time BETWEEN dodo_lp_rate_range.start_time AND dodo_lp_rate_range.end_time WHERE dex.trades.project = 'dodo' AND DATE_PART('day', now() - block_time::timestamptz) < 7

-- lp revenue all time

WITH v1_lp_rate AS (
    SELECT "dppAddress" AS contract_address, "lpFeeRate" AS lp_rate, call_block_time AS block_time 
    FROM dodo."DPPFactory_call_initDODOPrivatePool" WHERE call_success IS TRUE    
    UNION
    SELECT contract_address, "newLpFeeRate" AS lp_rate, evt_block_time AS block_time 
    FROM  dodo."DPP_evt_LpFeeRateChange"
),

dpp_lp_rate AS (
    SELECT "output_newBornDODO" AS contract_address, "lpFeeRate" AS lp_rate, call_block_time AS block_time 
    FROM dodo."DODOZoo_call_breedDODO" WHERE call_success IS TRUE    
    UNION
    SELECT contract_address, "newLiquidityProviderFeeRate" AS lp_rate, evt_block_time AS block_time 
    FROM  dodo."DODO_evt_UpdateLiquidityProviderFeeRate"
),

dvm_lp_rate AS (
    SELECT "output_newVendingMachine" AS contract_address, "lpFeeRate" AS lp_rate, call_block_time AS block_time 
    FROM dodo."DVMFactory_call_createDODOVendingMachine" WHERE call_success IS TRUE    
),

dodo_lp_rate AS (
    SELECT * FROM v1_lp_rate
    UNION
    SELECT * FROM dpp_lp_rate
    UNION
    SELECT * FROM dvm_lp_rate
),

dodo_lp_rate_range AS (
 SELECT DISTINCT ON (start_lp.contract_address, start_lp.block_time) start_lp.contract_address AS contract_address, start_lp.lp_rate AS lp_rate, start_lp.block_time AS start_time, coalesce(end_lp.block_time, '2121-01-01') AS end_time
    FROM (
        SELECT * FROM dodo_lp_rate ORDER BY "contract_address", block_time
        ) start_lp
    LEFT JOIN (
        SELECT * FROM dodo_lp_rate ORDER BY "contract_address", block_time
        ) end_lp
    ON start_lp.contract_address = end_lp.contract_address AND start_lp.block_time < end_lp.block_time
)

SELECT
SUM(CASE WHEN dodo_lp_rate_range.lp_rate IS NOT NULL THEN dex.trades.usd_amount * dodo_lp_rate_range.lp_rate / 10^18 ELSE 0 END) AS lp 
FROM 
dex.trades 
LEFT JOIN dodo_lp_rate_range ON dex.trades.exchange_contract_address = dodo_lp_rate_range.contract_address 
AND dex.trades.block_time BETWEEN dodo_lp_rate_range.start_time AND dodo_lp_rate_range.end_time WHERE dex.trades.project = 'dodo'
