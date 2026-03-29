import os
import re

lib_dir = '/home/rintu/Developer/Practice-Projects/Flutter/flutter_saree_haven/lib'

# Find all files in lib
dart_files = []
for root, dirs, files in os.walk(lib_dir):
    for f in files:
        if f.endswith('.dart'):
            dart_files.append(os.path.join(root, f))

# Pattern to replace CachedNetworkImage with Image.asset for specific known saree imageUrls
# It matches CachedNetworkImage(imageUrl: <var>, fit: <var>, ...)
# and removes the placeholder if it exists on the same or next lines
for file_path in dart_files:
    with open(file_path, 'r') as f:
        content = f.read()

    # Generic replace for simple 1-line or multi-line usages where we can safely replace
    new_content = re.sub(
        r'CachedNetworkImage\(\s*imageUrl:\s*(saree\.imageUrls\.first|widget\.saree\.imageUrls\.first|item\.saree\.imageUrls\.first),\s*fit:\s*BoxFit\.cover,?\s*\)',
        r'Image.asset(\1, fit: BoxFit.cover)',
        content
    )
    
    new_content = re.sub(
        r'CachedNetworkImage\(\s*imageUrl:\s*(saree\.imageUrls\.first|widget\.saree\.imageUrls\.first|item\.saree\.imageUrls\.first),\s*width:\s*([^,]+),\s*height:\s*([^,]+),\s*fit:\s*BoxFit\.cover,?\s*\)',
        r'Image.asset(\1, width: \2, height: \3, fit: BoxFit.cover)',
        new_content
    )
    
    new_content = re.sub(
        r'CachedNetworkImage\(\s*imageUrl:\s*(saree\.imageUrls\.first),\s*fit:\s*BoxFit\.cover,\s*placeholder:[^,]+,?\s*\)',
        r'Image.asset(\1, fit: BoxFit.cover)',
        new_content
    )
    
    # Custom replace for saree_card.dart which has placeholder on multiple lines
    if "saree_card.dart" in file_path:
        new_content = re.sub(
            r'CachedNetworkImage\(\s*imageUrl:\s*saree\.imageUrls\.first,\s*fit:\s*BoxFit\.cover,\s*placeholder:\s*\(context,\s*url\)\s*=>\s*Container\([^)]+\),\s*\)',
            r'Image.asset(saree.imageUrls.first, fit: BoxFit.cover)',
            new_content
        )

    # Some images might not have fit: cover
    new_content = re.sub(
        r'CachedNetworkImage\(\s*imageUrl:\s*(saree\.imageUrls\[index\]|widget\.saree\.imageUrls\[index\]),\s*fit:\s*BoxFit\.cover,?\s*\)',
        r'Image.asset(\1, fit: BoxFit.cover)',
        new_content
    )

    if content != new_content:
        with open(file_path, 'w') as f:
            f.write(new_content)
        print(f"Updated {file_path}")

print("Done")
