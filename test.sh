# Define a variable with spaces
var="hello world how are you"
# Iterate over each word in the variable and print them individually
for word in "$var"; do
    echo "Word: $word"
done
