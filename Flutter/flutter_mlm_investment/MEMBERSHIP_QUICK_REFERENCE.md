# Membership Level - Quick Reference

## What Changed?
The default membership level is now **"Basic"** instead of "Member", with proper rank hierarchy.

## Display Format
All users see their membership as: **"{Rank} Member"**

Examples:
- Basic Member ← New default
- Bronze Member
- Silver Member
- Gold Member
- Diamond Member

## Rank System
```
Basic (Level 1) - Default
  ↓ (with 10 team members & $5k investment)
Bronze (Level 2)
  ↓ (with 50 team members & $20k investment)
Silver (Level 3)
  ↓ (with 200 team members & $100k investment)
Gold (Level 4)
  ↓ (with 1,000 team members & $500k investment)
Diamond (Level 5)
```

## Key Points
✅ Default rank for new users: **Basic Member**  
✅ Display format: **"{Rank} Member"**  
✅ Complete hierarchy: **Basic → Bronze → Silver → Gold → Diamond**  
✅ Frontend: Shows "Basic Member" if rank not available  
✅ Backend: Users table default changed to "Basic"  

## Files Changed
1. `profile_screen.dart` - Default fallback to "Basic"
2. `update_schema.php` - Database default to "Basic"

---

**Status**: ✅ Complete and ready to use!
