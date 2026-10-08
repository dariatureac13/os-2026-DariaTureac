#!/bin/bash

# Q1. How many requests failed?
grep "FAIL" access.log | wc -l

# Q2. How many different pages were requested, and which?
cut -d' ' -f5 access.log | sort -u | tee /dev/stderr | wc -l

# Q3. How many requests did each page get?
cut -d' ' -f5 access.log | sort | uniq -c

# Q4. Which user or users have the most failed requests, and how many?
grep "FAIL" access.log | cut -d' ' -f3 | sort | uniq -c | sort -rn | head -n 1

# Q5. How many requests did user3 make, and how many of them failed?
grep "user3" access.log | cut -d' ' -f4 | sort | uniq -c

# Q6. Print the last 3 failed requests, showing only time and user.
grep "FAIL" access.log | tail -n 3 | cut -d' ' -f2,3

# Q7. Which login shells appear in /etc/passwd, and how many accounts use each? (field7, separator :)
cut -d':' -f7 /etc/passwd | sort | uniq -c

# Q8. PREDICT, then explain: why do ls /etc | wc -l and ls -l /etc | wc -l differ by exactly one?
echo "ls -l prints an extra summary header line at the top ('total ...'), which increases line count by 1."

# Bonus (+1): grep -E minute ends in 0 and failed
grep "FAIL" access.log | grep -E ":[0-5]0:" | tee /dev/tty | wc -l
