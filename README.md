# AppData Cleaner

Find and identify leftover application data on Windows that's wasting disk space.

When you uninstall applications on Windows, many leave behind folders in 
AppData\Local and AppData\Roaming. Over time, these orphaned folders can 
accumulate and consume significant disk space.

This PowerShell script:
- Scans your AppData directories for folders
- Compares them against currently installed applications
- Identifies potential leftovers from uninstalled apps
- Shows folder sizes to help prioritize cleanup
- Provides safe recommendations (manual review required)

**Note:** Always review results carefully before deleting anything. Some folders 
may be shared resources or system components.
