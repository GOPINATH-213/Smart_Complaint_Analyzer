import os
import urllib.request
import zipfile
import ssl

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

fonts_dir = os.path.join("assets", "google_fonts")
os.makedirs(fonts_dir, exist_ok=True)

zip_url = "https://fonts.google.com/download?family=Inter"
zip_path = os.path.join(fonts_dir, "inter.zip")

print("Downloading Inter fonts zip from Google Fonts...")
try:
    req = urllib.request.Request(zip_url, headers={'User-Agent': 'Mozilla/5.0'})
    with urllib.request.urlopen(req, context=ctx, timeout=30) as response, open(zip_path, 'wb') as out_file:
        out_file.write(response.read())
    
    print("Extracting...")
    with zipfile.ZipFile(zip_path, 'r') as zip_ref:
        zip_ref.extractall(fonts_dir)
        
    print("Done extracting. Cleaning up...")
    os.remove(zip_path)
    
    # We might need to move fonts from subdirectories (like "static/") to root of assets/google_fonts
    static_dir = os.path.join(fonts_dir, "static")
    if os.path.exists(static_dir):
        for f in os.listdir(static_dir):
            if f.endswith(".ttf"):
                os.replace(os.path.join(static_dir, f), os.path.join(fonts_dir, f))
        # remove static dir
        for f in os.listdir(static_dir):
            os.remove(os.path.join(static_dir, f))
        os.rmdir(static_dir)

    print("Fonts installed successfully.")
except Exception as e:
    print(f"Error: {e}")
