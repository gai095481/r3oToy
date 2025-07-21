# Data Processing Use Cases for `collect-words`

## Overview

These use cases demonstrate the power of `collect-words` in these areas:

* ​**Data Discovery**​: Automatically finding unique elements in complex data structures.
* ​**Schema Validation**​: Ensuring data completeness and consistency.
* ​**Pattern Analysis**​: Identifying trends and relationships in datasets.
* ​**Dependency Mapping**​: Understanding system interconnections.
* ​**Quality Control**​: Validating data integrity and compliance.
* ​**Performance Optimization**​: Streamlining data processing workflows.
* ​**Security Auditing**​: Comprehensive policy and permission analysis.
* ​**Business Intelligence**​: Extracting actionable insights from operational data.

The function's ability to handle nested structures, filter unwanted elements and maintain uniqueness makes it indispensable for modern data processing pipelines across industries.


## 1. **Configuration Schema Validation**

**Domain:** DevOps, System Administration
**Problem:** Validate that configuration files contain all required keys and identify missing or extra parameters.

```rebol
;; Extract all configuration keys from nested config structure:
config-data: [
    database [host: "localhost" port: 3306 user: "admin"]
    cache [enabled: true timeout: 300]
    logging [level: "info" file: "/var/log/app.log"]
]

required-keys: [host port user enabled timeout level file]
found-keys: collect-words/deep/set config-data
missing-keys: difference required-keys found-keys
extra-keys: difference found-keys required-keys

print ["Missing keys:" mold missing-keys]
print ["Extra keys:" mold extra-keys]
```

## 2. **API Dependency Analysis**

**Domain:** Software Architecture, Microservices
**Problem:** Analyze code to identify all external API endpoints or service dependencies.

```rebol
;; Extract service names from API call patterns:
api-calls: [
    call user-service/get-profile
    invoke payment-service/process
    request inventory-service/check-stock
    call user-service/update-profile
    notify email-service/send
]

services: collect-words/ignore api-calls [call invoke request notify get-profile process check-stock update-profile send]
unique-services: collect-words services
;; Result: [user-service payment-service inventory-service email-service]
```

## 3. **SQL Query Analysis & Optimization**

**Domain:** Database Administration, Performance Tuning
**Problem:** Extract all table names, column references and function calls from complex SQL queries stored as Rebol blocks.

```rebol
;; Parse SQL-like structure for table and column analysis:
sql-structure: [
    select [customer.name order.total payment.status]
    from [customer order payment]
    where [customer.id = order.customer_id and order.id = payment.order_id]
    functions [count sum avg max min]
]

tables: collect-words/deep sql-structure
;; Filter out SQL keywords to get actual database objects:
sql-keywords: [select from where and or functions count sum avg max min]
db-objects: collect-words/ignore tables sql-keywords
```

## 4. **Log File Pattern Extraction**

**Domain:** System Monitoring, Security Analysis
**Problem:** Extract unique error codes, user IDs or system components from structured log data.

```rebol
;; Process log entries to find unique error patterns:
log-entries: [
    [timestamp: "2025-07-21" component: auth-service error-code: E401 user: john]
    [timestamp: "2025-07-21" component: payment-service error-code: E503 user: jane]
    [timestamp: "2025-07-21" component: auth-service error-code: E401 user: mike]
    [timestamp: "2025-07-21" component: db-service error-code: E500 user: admin]
]

;; Extract unique components, error codes and users:
components: []
error-codes: []
users: []

foreach entry log-entries [
    append components select entry 'component
    append error-codes select entry 'error-code
    append users select entry 'user
]

unique-components: collect-words components
unique-errors: collect-words error-codes
unique-users: collect-words users
```

## 5. **Template Variable Discovery**

**Domain:** Web Development, Content Management
**Problem:** Automatically discover all template variables in content templates for validation and documentation.

```rebol
;; Email template with embedded variables:
email-template: [
    "Dear" :customer-name ","
    "Your order" :order-number "totaling" :total-amount
    "will be shipped to" :shipping-address "by" :delivery-date "."
    "Track your package at" :tracking-url
    "Best regards," :company-name
]

template-vars: collect-words email-template
;; Remove static text, keep only variables (get-words become regular words):
static-words: [dear your order totaling will be shipped to by track package at best regards]
variables: collect-words/ignore template-vars static-words
```

## 6. **Data Pipeline Workflow Analysis**

**Domain:** ETL Processing, Data Engineering.
**Problem:** Map data transformation steps and identify processing dependencies in ETL pipelines.

```rebol
;; Data processing pipeline definition:
pipeline-steps: [
    extract [source: database tables: [customers orders products]]
    transform [
        clean-data [remove-nulls standardize-formats]
        enrich-data [calculate-metrics add-categories]
        validate-data [check-constraints verify-ranges]
    ]
    load [target: warehouse tables: [fact-sales dim-customers]]
]

;; Extract all processing step names:
processing-steps: collect-words/deep/ignore pipeline-steps [source target tables]
;; Extract data sources and targets:
data-sources: collect-words/deep/set pipeline-steps
```

## 7. **Security Policy Audit**

**Domain:** Cybersecurity, Compliance
**Problem:** Extract all permissions, roles, and resources from security policy definitions.

```rebol
;; Security policy configuration:
security-policies: [
    role: admin permissions: [read write delete manage-users]
    role: editor permissions: [read write]
    role: viewer permissions: [read]
    resources: [documents reports user-accounts system-settings]
    restrictions: [no-weekend-access require-mfa log-all-actions]
]

roles: collect-words/deep/set security-policies
all-permissions: collect-words/deep security-policies
;; Filter to get only permission-related terms:
policy-keywords: [role permissions resources restrictions]
actual-permissions: collect-words/ignore all-permissions policy-keywords
```

## 8. **Inventory Management & SKU Analysis**

**Domain:** Retail, Supply Chain
**Problem:** Analyze product catalogs to extract unique brands, categories, and product attributes.

```rebol
;; Product catalog data:
product-catalog: [
    product-1 [brand: nike category: shoes size: large color: red]
    product-2 [brand: adidas category: shoes size: medium color: blue] 
    product-3 [brand: nike category: apparel size: small color: red]
    product-4 [brand: puma category: accessories color: black]
]

;; Extract unique brands, categories and attributes:
all-attributes: collect-words/deep/set product-catalog
brands: []
categories: []
sizes: []
colors: []

;; Process each product to categorize attributes:
foreach [product-id details] product-catalog [
    if block? details [
        brand: select details 'brand
        category: select details 'category
        size: select details 'size
        color: select details 'color
        
        if brand [append brands brand]
        if category [append categories category]
        if size [append sizes size]
        if color [append colors color]
    ]
]

unique-brands: collect-words brands
unique-categories: collect-words categories
unique-sizes: collect-words sizes
unique-colors: collect-words colors
```

## 9. **Financial Transaction Pattern Analysis**

**Domain:** FinTech, Fraud Detection.
**Problem:** Extract unique transaction types, merchant categories and payment methods from financial data.

```rebol
;; Transaction data for pattern analysis:
transactions: [
    [type: purchase merchant: grocery-store method: credit-card amount: 45.67]
    [type: withdrawal merchant: atm-network method: debit-card amount: 100.00]
    [type: purchase merchant: online-retailer method: credit-card amount: 89.99]
    [type: transfer merchant: bank-internal method: online-banking amount: 500.00]
]

;; Extract transaction patterns:
transaction-types: []
merchants: []
payment-methods: []

foreach transaction transactions [
    append transaction-types select transaction 'type
    append merchants select transaction 'merchant  
    append payment-methods select transaction 'method
]

unique-transaction-types: collect-words transaction-types
unique-merchants: collect-words merchants
unique-payment-methods: collect-words payment-methods
```

## 10. **Content Management & SEO Analysis**

**Domain:** Digital Marketing, Content Strategy.
**Problem:** Extract keywords, tags and content categories from CMS data for SEO optimization.

```rebol
;; Content metadata for SEO analysis:
content-items: [
    article-1 [
        tags: [technology AI machine-learning]
        category: tech-news
        keywords: [artificial-intelligence automation future-trends]
    ]
    article-2 [
        tags: [business finance investment]
        category: finance-news  
        keywords: [stock-market cryptocurrency blockchain]
    ]
    article-3 [
        tags: [technology blockchain finance]
        category: fintech
        keywords: [cryptocurrency defi smart-contracts]
    ]
]

;; Extract all content classification terms:
all-tags: []
all-keywords: []
all-categories: []

foreach [article-id metadata] content-items [
    if block? metadata [
        tags: select metadata 'tags
        keywords: select metadata 'keywords
        category: select metadata 'category
        
        if block? tags [append all-tags tags]
        if block? keywords [append all-keywords keywords]
        if category [append all-categories category]
    ]
]

unique-tags: collect-words all-tags
unique-keywords: collect-words all-keywords  
unique-categories: collect-words all-categories
trending-topics: intersect unique-tags unique-keywords  ;; Cross-referenced terms.
```

## 11. **Healthcare Data Classification**

**Domain:** Healthcare IT, Medical Records.
**Problem:** Extract medical codes, procedure types and diagnostic categories from patient data.

```rebol
;; Medical record data structure:
patient-records: [
    patient-001 [
        diagnoses: [diabetes-type-2 hypertension obesity]
        procedures: [blood-test mri-scan consultation]
        medications: [metformin lisinopril atorvastatin]
        departments: [endocrinology cardiology]
    ]
    patient-002 [
        diagnoses: [hypertension cardiac-arrhythmia]
        procedures: [ecg stress-test consultation]  
        medications: [lisinopril amiodarone]
        departments: [cardiology emergency]
    ]
]

;; Extract medical classification data:
all-diagnoses: []
all-procedures: []
all-medications: []
all-departments: []

foreach [patient-id record] patient-records [
    if block? record [
        diagnoses: select record 'diagnoses
        procedures: select record 'procedures
        medications: select record 'medications
        departments: select record 'departments
        
        if block? diagnoses [append all-diagnoses diagnoses]
        if block? procedures [append all-procedures procedures] 
        if block? medications [append all-medications medications]
        if block? departments [append all-departments departments]
    ]
]

unique-diagnoses: collect-words all-diagnoses
unique-procedures: collect-words all-procedures
unique-medications: collect-words all-medications
unique-departments: collect-words all-departments
```

## 12. **Network Topology & Infrastructure Mapping**

**Domain:** Network Administration, IT Infrastructure.
**Problem:** Extract device types, network segments and connection protocols from network configurations.

```rebol
;; Network infrastructure configuration:
network-config: [
    segment: dmz devices: [firewall-01 web-server-01 load-balancer-01]
    segment: internal devices: [db-server-01 app-server-01 app-server-02]
    segment: management devices: [monitoring-server backup-server]
    protocols: [https ssh snmp tcp-443 tcp-22 tcp-161]
    device-types: [firewall server load-balancer switch router]
]

;; Extract network components:
segments: []
devices: []
protocols: []
device-types: []

;; Process configuration sections:
if block? select network-config 'protocols [
    protocols: select network-config 'protocols
]
if block? select network-config 'device-types [
    device-types: select network-config 'device-types
]

;; Extract devices from each segment:
segment-keywords: [segment devices]
all-network-elements: collect-words/deep/ignore network-config segment-keywords
network-segments: collect-words/deep/set network-config
unique-protocols: collect-words protocols
unique-device-types: collect-words device-types
```

## 13. **Manufacturing Process Control**

**Domain:** Industrial Automation, Quality Control.
**Problem:** Extract process steps, quality checkpoints and equipment names from manufacturing workflows.

```rebol
;; Manufacturing process definition:
manufacturing-process: [
    stage: preparation equipment: [mixer-01 conveyor-a scales-digital]
    stage: processing equipment: [oven-industrial press-hydraulic cutter-laser]
    stage: quality-control checkpoints: [weight-check dimension-check surface-inspection]
    stage: packaging equipment: [wrapper-automatic labeler sealer]
    quality-standards: [iso-9001 fda-approved haccp-certified]
]

;; Extract manufacturing components:
stages: []
equipment: []
checkpoints: []
standards: []

;; Process manufacturing data:
all-elements: collect-words/deep manufacturing-process
process-keywords: [stage equipment checkpoints quality-standards]
manufacturing-assets: collect-words/ignore all-elements process-keywords
manufacturing-stages: collect-words/deep/set manufacturing-process
```

## 14. **Customer Journey & Analytics Mapping**

**Domain:** Customer Experience, Marketing Analytics.
**Problem:** Extract touchpoints, conversion events and customer segments from analytics data.

```rebol
;; Customer journey analytics data:
customer-journeys: [
    segment: new-visitors touchpoints: [landing-page signup-form welcome-email]
    segment: returning-customers touchpoints: [login-page dashboard purchase-flow]
    segment: premium-users touchpoints: [premium-features support-chat billing-portal]
    conversion-events: [signup purchase upgrade renewal cancellation]
    channels: [organic-search paid-ads email-marketing social-media]
]

;; Extract customer experience elements:
segments: []
touchpoints: []
events: []
channels: []

;; Process journey data:
all-journey-elements: collect-words/deep customer-journeys
journey-keywords: [segment touchpoints conversion-events channels]
customer-interactions: collect-words/ignore all-journey-elements journey-keywords
customer-segments: collect-words/deep/set customer-journeys
```

## 15. **Research Data Categorization & Meta-Analysis**

**Domain:** Academic Research, Scientific Data Processing.
**Problem:** Extract research themes, methodologies and data sources from academic datasets.

```rebol
;; Research study metadata:
research-studies: [
    study-001 [
        theme: climate-change methodology: statistical-analysis
        data-sources: [satellite-imagery weather-stations ocean-sensors]
        keywords: [global-warming temperature-trends carbon-emissions]
    ]
    study-002 [
        theme: machine-learning methodology: experimental-design  
        data-sources: [public-datasets survey-responses lab-experiments]
        keywords: [neural-networks deep-learning pattern-recognition]
    ]
    study-003 [
        theme: climate-change methodology: predictive-modeling
        data-sources: [historical-data simulation-models satellite-imagery]
        keywords: [climate-modeling sea-level-rise carbon-emissions]
    ]
]

;; Extract research classification elements:
themes: []
methodologies: []
data-sources: []
keywords: []

foreach [study-id metadata] research-studies [
    if block? metadata [
        theme: select metadata 'theme
        methodology: select metadata 'methodology
        sources: select metadata 'data-sources  
        study-keywords: select metadata 'keywords
        
        if theme [append themes theme]
        if methodology [append methodologies methodology]
        if block? sources [append data-sources sources]
        if block? study-keywords [append keywords study-keywords]
    ]
]

unique-themes: collect-words themes
unique-methodologies: collect-words methodologies
unique-data-sources: collect-words data-sources
unique-keywords: collect-words keywords

;; Find cross-study patterns:
interdisciplinary-themes: intersect unique-themes unique-keywords
common-methodologies: collect-words methodologies  ; Shows frequency through duplicates before making them unique.
```
