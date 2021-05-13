-- dodo_deposit_24h
SELECT
    SUM(amount / 10^p.decimals * p.price) as volume
FROM (
    SELECT evt_block_time, amount, CASE WHEN "isBaseToken" THEN m.base_token_address ELSE m.quote_token_address END AS token_address
    FROM dodo."DODO_evt_Deposit" e LEFT JOIN dodo.view_markets m ON contract_address = m.market_contract_address
    AND DATE_PART('day', now() - evt_block_time::timestamptz) < 1
) evt 
LEFT JOIN prices.usd p ON p.minute = date_trunc('minute', evt.evt_block_time) AND p.contract_address = evt.token_address AND DATE_PART('day', now() - p.minute::timestamptz) < 1

-- dodo_buy_shares_24h
WITH view_markets AS (
    SELECT "baseToken" AS base_token_address, "quoteToken" AS quote_token_address, dvm AS market_contract_address FROM dodo."DVMFactory_evt_NewDVM" 
)

SELECT
    SUM(coalesce(quote_token_amount / 10^p_quote_token.decimals * p_quote_token.price, base_token_amount / 10^p_base_token.decimals * p_base_token.price))
    AS volume
FROM (
    SELECT
    call_block_time,
    "output_baseInput" AS base_token_amount,
    "output_quoteInput" AS quote_token_amount,
    m.base_token_address AS base_token_address,
    m.quote_token_address AS quote_token_address
    FROM dodo."DVM_call_buyShares" e
    LEFT JOIN view_markets m ON contract_address = m.market_contract_address
    WHERE call_success = TRUE
    AND DATE_PART('day', now() - e.call_block_time::timestamptz) < 1
) call
LEFT JOIN prices.usd p_base_token ON p_base_token.minute = date_trunc('minute', call.call_block_time) AND p_base_token.contract_address = call.base_token_address AND DATE_PART('day', now() - p_base_token.minute::timestamptz) < 1
LEFT JOIN prices.usd p_quote_token ON p_quote_token.minute = date_trunc('minute', call.call_block_time) AND p_quote_token.contract_address = call.quote_token_address AND DATE_PART('day', now() - p_quote_token.minute::timestamptz) < 1

-- dodo_withdraw_24h
SELECT
    SUM(amount / 10^p.decimals * p.price) as volume
FROM (
    SELECT evt_block_time, amount, CASE WHEN "isBaseToken" THEN m.base_token_address ELSE m.quote_token_address END AS token_address
    FROM dodo."DODO_evt_Withdraw" e LEFT JOIN dodo.view_markets m ON contract_address = m.market_contract_address
    AND DATE_PART('day', now() - evt_block_time::timestamptz) < 1
) evt 
LEFT JOIN prices.usd p ON p.minute = date_trunc('minute', evt.evt_block_time) AND p.contract_address = evt.token_address AND DATE_PART('day', now() - p.minute::timestamptz) < 1

-- dodo_shell_shares_24h
WITH view_markets AS (
    SELECT "baseToken" AS base_token_address, "quoteToken" AS quote_token_address, dvm AS market_contract_address FROM dodo."DVMFactory_evt_NewDVM" 
)

SELECT
    SUM(coalesce(quote_token_amount / 10^p_quote_token.decimals * p_quote_token.price, base_token_amount / 10^p_base_token.decimals * p_base_token.price))
    AS volume
FROM (
    SELECT
    call_block_time,
    "output_baseAmount" AS base_token_amount,
    "output_quoteAmount" AS quote_token_amount,
    m.base_token_address AS base_token_address,
    m.quote_token_address AS quote_token_address
    FROM dodo."DVM_call_sellShares" e
    LEFT JOIN view_markets m ON contract_address = m.market_contract_address
    WHERE call_success = TRUE
    AND DATE_PART('day', now() - e.call_block_time::timestamptz) < 1
) call
LEFT JOIN prices.usd p_base_token ON p_base_token.minute = date_trunc('minute', call.call_block_time) AND p_base_token.contract_address = call.base_token_address AND DATE_PART('day', now() - p_base_token.minute::timestamptz) < 1
LEFT JOIN prices.usd p_quote_token ON p_quote_token.minute = date_trunc('minute', call.call_block_time) AND p_quote_token.contract_address = call.quote_token_address AND DATE_PART('day', now() - p_quote_token.minute::timestamptz) < 1

-- dodo_deposit_per_day
SELECT
    date_trunc('day', evt_block_time) AS time,
    SUM(amount / 10^p.decimals * p.price) as volume
FROM (
    SELECT evt_block_time, amount, CASE WHEN "isBaseToken" THEN m.base_token_address ELSE m.quote_token_address END AS token_address
    FROM dodo."DODO_evt_Deposit" e LEFT JOIN dodo.view_markets m ON contract_address = m.market_contract_address
) evt 
LEFT JOIN prices.usd p ON p.minute = date_trunc('minute', evt.evt_block_time) AND p.contract_address = evt.token_address

GROUP BY 1
ORDER BY 1

-- dodo_withdraw_per_day
SELECT
    date_trunc('day', evt_block_time) AS time,
    SUM(amount / 10^p.decimals * p.price) as volume
FROM (
    SELECT evt_block_time, amount, CASE WHEN "isBaseToken" THEN m.base_token_address ELSE m.quote_token_address END AS token_address
    FROM dodo."DODO_evt_Withdraw" e LEFT JOIN dodo.view_markets m ON contract_address = m.market_contract_address
) evt 
LEFT JOIN prices.usd p ON p.minute = date_trunc('minute', evt.evt_block_time) AND p.contract_address = evt.token_address

GROUP BY 1
ORDER BY 1


-- dodo_buy_shares_per_day
WITH view_markets AS (
    SELECT "baseToken" AS base_token_address, "quoteToken" AS quote_token_address, dvm AS market_contract_address FROM dodo."DVMFactory_evt_NewDVM" 
)

SELECT
    date_trunc('day', call_block_time) AS time,
    SUM(coalesce(quote_token_amount / 10^p_quote_token.decimals * p_quote_token.price, base_token_amount / 10^p_base_token.decimals * p_base_token.price))
    AS volume
FROM (
    SELECT
    call_block_time,
    "output_baseInput" AS base_token_amount,
    "output_quoteInput" AS quote_token_amount,
    m.base_token_address AS base_token_address,
    m.quote_token_address AS quote_token_address
    FROM dodo."DVM_call_buyShares" e
    LEFT JOIN view_markets m ON contract_address = m.market_contract_address
    WHERE call_success = TRUE
) call
LEFT JOIN prices.usd p_base_token ON p_base_token.minute = date_trunc('minute', call.call_block_time) AND p_base_token.contract_address = call.base_token_address
LEFT JOIN prices.usd p_quote_token ON p_quote_token.minute = date_trunc('minute', call.call_block_time) AND p_quote_token.contract_address = call.quote_token_address

GROUP BY 1
ORDER BY 1

-- dodo_sell_shares_per_day
WITH view_markets AS (
    SELECT "baseToken" AS base_token_address, "quoteToken" AS quote_token_address, dvm AS market_contract_address FROM dodo."DVMFactory_evt_NewDVM" 
)

SELECT
    date_trunc('day', call_block_time) AS time,
    SUM(coalesce(quote_token_amount / 10^p_quote_token.decimals * p_quote_token.price, base_token_amount / 10^p_base_token.decimals * p_base_token.price))
    AS volume
FROM (
    SELECT
    call_block_time,
    "output_baseAmount" AS base_token_amount,
    "output_quoteAmount" AS quote_token_amount,
    m.base_token_address AS base_token_address,
    m.quote_token_address AS quote_token_address
    FROM dodo."DVM_call_sellShares" e
    LEFT JOIN view_markets m ON contract_address = m.market_contract_address
    WHERE call_success = TRUE
) call
LEFT JOIN prices.usd p_base_token ON p_base_token.minute = date_trunc('minute', call.call_block_time) AND p_base_token.contract_address = call.base_token_address
LEFT JOIN prices.usd p_quote_token ON p_quote_token.minute = date_trunc('minute', call.call_block_time) AND p_quote_token.contract_address = call.quote_token_address

GROUP BY 1
ORDER BY 1