import sys
import re

with open('/home/rintu/Developer/Practice-Projects/Flutter/flutter_saree_haven/lib/core/data/mock_repository.dart', 'r') as f:
    text = f.read()

# Replace Pexels URLs with local ones
text = text.replace("'https://images.pexels.com/photos/8838890/pexels-photo-8838890.jpeg?auto=compress&cs=tinysrgb&w=800'", "'assets/Saree/DHAN5161.jpeg'")
text = text.replace("'https://images.pexels.com/photos/8839887/pexels-photo-8839887.jpeg?auto=compress&cs=tinysrgb&w=800'", "'assets/Saree/16611P_1Main.jpeg'")
text = text.replace("'https://images.pexels.com/photos/7250437/pexels-photo-7250437.jpeg?auto=compress&cs=tinysrgb&w=800'", "'assets/Saree/1758169115717_AZASSK2807253752copy.jpeg'")
text = text.replace("'https://images.pexels.com/photos/7250459/pexels-photo-7250459.jpeg?auto=compress&cs=tinysrgb&w=800'", "'assets/Saree/1773488025068_1.jpeg'")
text = text.replace("'https://images.pexels.com/photos/8839893/pexels-photo-8839893.jpeg?auto=compress&cs=tinysrgb&w=800'", "'assets/Saree/DHAN5190.jpeg'")
text = text.replace("'https://images.pexels.com/photos/7250453/pexels-photo-7250453.jpeg?auto=compress&cs=tinysrgb&w=800'", "'assets/Saree/PIK05632.jpeg'")
text = text.replace("'https://images.pexels.com/photos/8838892/pexels-photo-8838892.jpeg?auto=compress&cs=tinysrgb&w=800'", "'assets/Saree/Sonarupa-1.jpeg'")

with open('/home/rintu/Developer/Practice-Projects/Flutter/flutter_saree_haven/lib/core/data/mock_repository.dart', 'w') as f:
    f.write(text)
print("Updated repository")

try:
    with open('/home/rintu/Developer/Practice-Projects/Flutter/flutter_saree_haven/lib/features/home/widgets/saree_card.dart', 'r') as f:
        card_text = f.read()

    new_card_text = re.sub(
        r'CachedNetworkImage\(\s*imageUrl:\s*saree\.imageUrls\.isNotEmpty\s*\?\s*saree\.imageUrls\.first\s*:\s*\'\',\s*fit:\s*BoxFit\.cover,\s*placeholder:\s*\(context,\s*url\)\s*=>\s*Container\(\s*color:\s*AppColors\.background,\s*\),\s*errorWidget:\s*\(context,\s*url,\s*error\)\s*=>\s*const Icon\(Icons\.broken_image\),\s*\)',
        r"Image.asset(saree.imageUrls.isNotEmpty ? saree.imageUrls.first : '', fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image))",
        card_text
    )

    if card_text != new_card_text:
        with open('/home/rintu/Developer/Practice-Projects/Flutter/flutter_saree_haven/lib/features/home/widgets/saree_card.dart', 'w') as f:
            f.write(new_card_text)
        print("Updated saree_card")
except Exception as e:
    print(f"Error on saree card: {e}")
