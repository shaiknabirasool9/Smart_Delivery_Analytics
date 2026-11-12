# Smart Delivery Analytics System — Business Insights Report

## Executive summary

This report analyzes the project’s seven CSV datasets, covering 1,000 customers, 100 restaurants, 200 delivery partners, and 10,000 orders from January 1, 2023 through December 30, 2024. The outcomes are descriptive and specific to the included data.

Of the 10,000 orders, 8,197 are marked delivered, 1,195 cancelled, and 608 pending. Delivered orders take an average of 54.79 minutes from order time to delivery time. The cancellation rate is 11.95%. The supplied customer behavior data marks 350 customers (35%) with `churn_flag = 1`. Delivered-order `order_amount` totals 6,414,646.55 amount units; currency is not specified.

The main operational opportunity is to investigate high delivery durations and city-level cancellation differences using additional context (such as promised ETA, cancellation reason, time of day, and preparation/dispatch timestamps). The churn label and revenue definitions should be validated before using these figures for decisions.

## Scope and methodology

- Source: the seven CSV files in the repository’s `Dataset/` directory.
- Period: order timestamps range from **2023-01-01 00:56:50** to **2024-12-30 23:32:43**.
- Order outcome percentages use all 10,000 rows as the denominator.
- Delivery duration is `delivered_time - order_time`, in minutes, for rows with `status = 'Delivered'` and a populated delivery timestamp.
- Cancellation rate is cancelled orders divided by all orders in the segment.
- Delivered-order value is the sum of `order_amount` for delivered orders only. The currency and financial meaning of `order_amount` are unspecified.
- Customer churn percentage uses the supplied `customer_behavior.churn_flag` values. It is not independently derived or validated as a churn model.

## Findings

### 1. Order fulfillment and delivery duration

| Measure | Result |
|---|---:|
| Delivered | 8,197 (81.97%) |
| Cancelled | 1,195 (11.95%) |
| Pending | 608 (6.08%) |
| Average delivered-order duration | 54.79 minutes |
| Median delivered-order duration | 54 minutes |
| Delivered orders over 60 minutes | 3,424 (41.77%) |

**Interpretation:** Delivery duration is centered around 54 minutes, but a substantial portion of delivered orders exceed 60 minutes. The 60-minute cutoff is an exploratory segment, not a contractual SLA or evidence that those orders were late. No promised ETA, preparation time, dispatch time, or traffic context is included.

**Recommended next step:** Add or join promised ETA and operational timestamps, then calculate on-time delivery rate and split elapsed time into restaurant preparation, assignment, pickup, and transit components. Prioritize recurring combinations of city, restaurant, and order hour rather than labeling an individual partner slow based on raw averages.

### 2. Cancellations

| Measure | Result |
|---|---:|
| Overall cancellation rate | 11.95% (1,195 / 10,000) |
| Highest city rate: Delhi | 13.29% (147 / 1,106) |
| Second-highest city rate: Kolkata | 13.15% (122 / 928) |

Delhi and Kolkata have the highest cancellation rates among the 10 customer cities. These are modest gaps over the overall rate and do not establish that the city itself causes cancellations. Counts and rates answer different questions; both should be reviewed when prioritizing work.

**Recommended next step:** Segment cancellations by order hour, restaurant, payment outcome, customer, and cancellation reason. The dataset does not include cancellation reason, so operational causes cannot be identified from these rows alone.

### 3. Delivered order value and demand

| Measure | Result |
|---|---:|
| Delivered-order `order_amount` total | 6,414,646.55 amount units |
| Average delivered-order `order_amount` | 782.56 amount units |
| Highest city by delivered order value: Pune | 740,618.58 across 949 delivered orders |
| Next cities: Ahmedabad / Delhi | 712,311.14 / 707,898.84 |

The five highest restaurants by `order_amount` across all order statuses are Star Junction (96,611.99), Taste Kitchen (93,722.43), Golden Express (93,568.80), Royal Corner (93,154.10), and Bombay Corner (92,608.38). This ranking is **all statuses** because the project’s restaurant revenue query sums all orders. It is an order-value ranking, not completed sales or profit; a delivered-only filter is needed for a fulfilled-order ranking.

**Recommended next step:** Define the business metric before presenting “revenue.” Report delivered order value separately from placed-order value, payment collections, delivery fees, refunds, discounts, and profit. Reconcile payment records to order status before using `payments.amount` as recognized revenue.

### 4. Customer retention indicators

| Measure | Result |
|---|---:|
| Customers in behavior dataset | 1,000 |
| `churn_flag = 1` | 350 (35%) |
| Average `last_order_days` | 89.5 days |
| Median `last_order_days` | 61 days |

The behavior table’s total orders (8,197) and total spending (6,414,646.55) match the delivered-order count and delivered `order_amount` total in the order data. This suggests the provided behavior metrics represent delivered orders, but the project does not document the exact calculation or churn-label definition.

**Recommended next step:** Confirm the label’s rule, observation date, and lookback window. Then compare repeat rate, recency, frequency, and monetary value across customer cohorts. Evaluate retention interventions using a defined test and control group rather than treating the supplied flag as a validated prediction.

### 5. Ratings and delivery partner performance

The ratings table contains 7,000 ratings with an average of **2.99 / 5**. This is 70% of the 10,000 orders; the remaining orders have no rating row in the included data. Only 83 ratings are 5, while 1,697 are 1 and 1,718 are 2. This distribution warrants a review of rating collection and customer experience, but missing ratings may introduce response bias.

Partner-level average delivery durations vary in the data. Among partners with at least 15 delivered orders, the fastest observed average is 46.60 minutes (42 deliveries) and the slowest is 62.21 minutes (43 deliveries). This is an exploratory comparison and not a fair performance score without location, time, route difficulty, assignment, and order-volume context.

**Recommended next step:** Establish minimum sample sizes and compare like-for-like deliveries. Pair duration with customer ratings, completed volume, cancellation responsibility, and route/shift context; avoid incentivizing speed without quality and safety guardrails.

## Data validation and caveats

- The order table has 10,000 rows; all order customer, restaurant, and partner IDs resolve to the corresponding entity in the CSVs.
- `delivered_time` is blank for 1,803 orders, including non-delivered statuses; delivery-duration metrics correctly use delivered rows only.
- `customer_behavior.churn_flag` is encoded as `1` and `0`, not `Yes` and `No`. SQL filters must use the source encoding or explicitly normalize it.
- The database schema stores `churn_flag` as text, which accepts the CSV values but does not itself document their meaning.
- The dataset has no currency field, costs, refunds, discounts, ETA/SLA, cancellation reason, or operational event timestamps. Do not equate order value with profit or verified revenue, nor elapsed time with SLA lateness.
- Ratings are present for a subset of orders; do not impute missing ratings as zero or neutral without a defined method.
- These are sample-data findings. They should not be generalized to an actual company, current operating conditions, or causal conclusions.

## Recommendations, in priority order

1. Define and document core metrics: delivered order value, net revenue, cancellation rate, on-time rate, churn, and customer rating coverage.
2. Add cancellation reason, promised ETA, and preparation/assignment/pickup timestamps to diagnose the operational drivers.
3. Investigate Delhi and Kolkata cancellation patterns by restaurant and hour, validating rates over time and against sample sizes.
4. Establish a transparent churn definition and cohort baseline before targeting customer retention.
5. Build partner scorecards that account for volume and delivery context, pairing reliability with customer experience.

## Reproducibility

The included SQL analysis is in [`../SQL/03_business_analysis.sql`](../SQL/03_business_analysis.sql) and [`../SQL/04_advanced_sql.sql`](../SQL/04_advanced_sql.sql). The core schema and validation scripts are [`../SQL/01_create_tables.sql`](../SQL/01_create_tables.sql) and [`../SQL/02_data_validation_and_data_cleaning.sql`](../SQL/02_data_validation_and_data_cleaning.sql).
