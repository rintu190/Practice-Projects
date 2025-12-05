#!/bin/bash
# MySQL Collation Fixer for Production Import
# Converts MySQL 8.0 dump to MySQL 5.7 compatible format

echo "🔧 MySQL Collation Compatibility Fixer"
echo "======================================"
echo ""

# Check if input file is provided
if [ -z "$1" ]; then
    echo "❌ Error: No input file specified"
    echo ""
    echo "Usage: ./fix_dump_collation.sh <input_dump.sql> [output_dump.sql]"
    echo ""
    echo "Example:"
    echo "  ./fix_dump_collation.sh my_dump.sql my_dump_fixed.sql"
    echo ""
    exit 1
fi

INPUT_FILE="$1"
OUTPUT_FILE="${2:-${INPUT_FILE%.sql}_mysql57.sql}"

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "❌ Error: Input file '$INPUT_FILE' not found!"
    exit 1
fi

echo "📄 Input file:  $INPUT_FILE"
echo "📄 Output file: $OUTPUT_FILE"
echo ""

# Create backup
BACKUP_FILE="${INPUT_FILE}.backup_$(date +%Y%m%d_%H%M%S)"
cp "$INPUT_FILE" "$BACKUP_FILE"
echo "✅ Backup created: $BACKUP_FILE"
echo ""

echo "🔄 Processing SQL dump..."

# Fix the SQL dump
sed -e 's/utf8mb4_0900_ai_ci/utf8mb4_unicode_ci/g' \
    -e 's/DEFAULT ENCRYPTION=.N.//' \
    -e 's/\/\*!80016 DEFAULT ENCRYPTION=.N. \*\///' \
    "$INPUT_FILE" > "$OUTPUT_FILE"

echo "✅ Collation fixed!"
echo ""
echo "📊 Changes made:"
echo "   ✓ utf8mb4_0900_ai_ci → utf8mb4_unicode_ci"
echo "   ✓ Removed MySQL 8.0 encryption directives"
echo ""
echo "📦 File size:"
echo "   Original: $(du -h "$INPUT_FILE" | cut -f1)"
echo "   Fixed:    $(du -h "$OUTPUT_FILE" | cut -f1)"
echo ""
echo "🎯 Next steps:"
echo "   1. Upload $OUTPUT_FILE to your production server"
echo "   2. Create database:"
echo "      mysql -u username -p -e \"CREATE DATABASE thefrxig_mlm_investment CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;\""
echo "   3. Import the fixed dump:"
echo "      mysql -u username -p thefrxig_mlm_investment < $OUTPUT_FILE"
echo ""
echo "✨ Done!"
