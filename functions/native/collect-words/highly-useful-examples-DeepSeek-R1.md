## Practical Data Processing Use Cases for `collect-words`

Provide structured insight into unstructured data.

1. **Schema Discovery**
   Extract field names from unstructured data:
   
   ```rebol
   collect-words/deep [
       name: "John" 
       address: [street: "Main" zip: 12345]
   ]
   ;; => [name address street zip]
   ```
2. **Query Parameter Extraction**
   Identify unique parameters in API request templates:
   
   ```rebol
   collect-words [
       "SELECT ?fields FROM ?table WHERE ?conditions"
   ]
   ;; => [fields table conditions]
   ```
3. **Data Pipeline Dependency Mapping**
   Find dependencies in transformation scripts:
   
   ```rebol
   collect-words/deep/set [
       output: transform [input-a input-b]
   ]
   ;; => [output input-a input-b]
   ```
4. **Template Variable Harvesting**
   Collect placeholders from document templates:
   
   ```rebol
   collect-words/deep [
       "Dear ?customer, your order ?order-id is ready"
   ]
   ;; => [customer order-id]
   ```
5. **Data Validation Rule Extraction**
   Identify validation targets from rule definitions:
   
   ```rebol
   collect-words/set [
       email-format: [contains? "@"]
       age-range: [between 18 65]
   ]
   ;; => [email-format age-range]
   ```
6. **Configuration Key Normalization**
   Standardize configuration keys across systems:
   
   ```rebol
   collect-words/ignore [
       SERVER_IP: "1.2.3.4" 
       server_port: 8080
   ] [server_ip]  ;; Case-insensitive ignore
   ```

; ; => [server_port]

```
7. **Data Catalog Generation**
Automate metadata collection from datasets:

```rebol
collect-words/as [
    customer-name: string! 
    purchase-total: money!
] set-word!
;; => [customer-name: purchase-total:]
```

8. **CSV Header Sanitization**
   Clean and normalize column headers:
   
   ```rebol
   headers: ["First Name" "Last_Name" "Date of Birth"]
   collect-words/ignore headers [last_name]  ;; Ignore duplicates.
   ```
9. **Data Masking Field Identification**
   Find sensitive fields in data models:
   
   ```rebol
   collect-words/deep [
       user: [email: ssn: password:]
   ]
   ;; => [user email ssn password]
   ```
10. **Cross-Reference Analysis**
    Map relationships in complex data structures:
    
    ```rebol
    collect-words/deep/set [
        customer: [id: name:]
        order: [cust_id: product-id:]
    ]
    ;; => [customer id name order cust_id product-id]
    ```
11. **Data Transformation Workflow**
    Verify input/output slots in ETL pipelines:
    
    ```rebol
    collect-words/ignore [
        input: load-csv %data.csv
        output: transform [input/age input/name]
    ] system/words
    ;; => [input output age name]
    ```
12. **Dynamic Form Generation**
    Create UI forms from data definitions:
    
    ```rebol
    fields: collect-words/set [
        username: text! 
        password: password!
    ]
    foreach field fields [create-field field]
    ```
13. **Data Quality Rule Tracking**
    Monitor required fields in validation rules:
    
    ```rebol
    required: collect-words/deep [
        [must-have: [customer-id order-date]]
    ]
    ```
14. **API Response Field Mapping**
    Align JSON keys with internal nomenclature:
    
    ```rebol
    collect-words/as [
        "firstName" -> first-name
        "lastName" -> last-name
    ] word!
    ;; => [first-name last-name]
    ```
15. **Data Lineage Tagging**
    Track data elements through processing stages:
    
    ```rebol
    collect-words/deep/ignore [
        raw: [cust_id: name:]
        processed: [customer-id: full-name:]
    ] [name:]  ; Ignore intermediate
    ;; => [raw cust_id processed customer-id full-name]
    ```

## Key Advantages in Data Processing

- **Normalization Power**: Handles diverse naming conventions (snake_case, camelCase, kebab-case)
- **Context Isolation**: `/ignore` prevents namespace collisions.
- **Structure-Aware**: `/deep` processes nested data structures.
- **Metadata Extraction**: Specialized `/set` refinement for definition points.
- **Type Flexibility**: `/as` ensures output compatibility with downstream systems.

These use cases demonstrate how `collect-words` solves real-world data processing challenges by providing structured insight into unstructured data,
maintaining consistency across heterogeneous data sources and enabling automated metadata handling.
