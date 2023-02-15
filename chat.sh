#!/bin/sh

input=$1
output_file="${input// /_}.txt"

# Limit output file name to 100 characters
if [ ${#output_file} -gt 100 ]; then
  output_file="${output_file:0:100}.txt"
fi

# Add timestamp to prevent file duplication
timestamp=$(date +%s)
output_file="${output_file%.*}_$timestamp.${output_file##*.}"

echo "\n[+] Input: $input"
echo "\n[+] Output:"

curl_output=$(curl -s https://api.openai.com/v1/completions \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer $CHATGPT_TOKEN" \
  -d '{
  "model": "text-davinci-003",
  "prompt": "'"$input"'",
  "max_tokens": 4000,
  "temperature": 1.0
}' \
| jq -r '.choices[].text')

# Format the output to 100 characters per line
curl_output=$(echo "$curl_output" | fold -w 100 -s)

echo $curl_output

# Write input and output to file
echo "Input: $input" > $output_file
echo "\nOutput: $curl_output" >> $output_file
