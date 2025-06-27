### Select predicates only

```
gawk '$1 ~ /\?$/ {print}' what-list-enhanced.txt
```

### Select non-predicates
```
gawk '$1 !~ /\?$/ {print}' what-list-enhanced.txt
```
