## Changelog

v1.8: 
Improve Action.sh
- Added script header with metadata.
- Excluded the bl_protection module from being disabled.
- Introduced disabled_modules.txt for tracking disabled modules.
- Prevented re-enabling of manually or externally disabled modules.
- Trimmed whitespace and newline characters from module names.
- Created enable_list and disable_list for module management.
- Removed disabled_modules.txt after enabling modules to prevent externally enabled modules from being disabled.
- Added feedback messages for enabling/disabling modules.
- Added conditional 10-second sleep before script exit based on specific conditions.
