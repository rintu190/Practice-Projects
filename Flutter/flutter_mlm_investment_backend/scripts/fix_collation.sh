#!/bin/bash
# Script to fix MySQL collation compatibility issues
# Converts utf8mb4_0900_ai_ci to utf8mb4_unicode_ci for older MySQL versions

echo "🔧 Fixing MySQL collation compatibility..."

# Check if input file is provided
if [ -z "$1" ]; then
    echo "Usage: ./fix_collation.sh <input_sql_file> [output_sql_file]"
    echo "Example: ./fix_collation.sh dump.sql dump_fixed.sql"
    exit 1
fi

INPUT_FILE="$1"
OUTPUT_FILE="${2:-${INPUT_FILE%.sql}_fixed.sql}"

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "❌ Error: Input file '$INPUT_FILE' not found!"
    exit 1
fi

echo "📄 Input file: $INPUT_FILE"
echo "📄 Output file: $OUTPUT_FILE"

# Create backup
cp "$INPUT_FILE" "${INPUT_FILE}.backup"
echo "✅ Backup created: ${INPUT_FILE}.backup"

# Replace collations
sed -e 's/utf8mb4_0900_ai_ci/utf8mb4_unicode_ci/g' \
    -e 's/COLLATE utf8mb4_unicode_ci/COLLATE utf8mb4_unicode_ci/g' \
    -e 's/CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci/CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci/g' \
    "$INPUT_FILE" > "$OUTPUT_FILE"

echo "✅ Collation fixed!"
echo ""
echo "📊 Changes made:"
echo "   utf8mb4_0900_ai_ci → utf8mb4_unicode_ci"
echo ""
echo "🎯 Next steps:"
echo "   1. Review the fixed file: $OUTPUT_FILE"
echo "   2. Import to production: mysql -u user -p database < $OUTPUT_FILE"
echo ""
echo "✨ Done!"
