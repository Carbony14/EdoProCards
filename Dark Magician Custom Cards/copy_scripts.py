import os
import shutil

# --- Copy .lua files ---
lua_source = 'scripts'
lua_dest = r'C:\Jogos\ProjectIgnis\script\unofficial'


for filename in os.listdir(lua_source):
    if filename.endswith('.lua'):
        src_path = os.path.join(lua_source, filename)
        dst_path = os.path.join(lua_dest, filename)
        shutil.copy2(src_path, dst_path)
        print(f'Copied LUA: {filename}')

# --- Copy .jpeg files ---
jpeg_source = 'images'
jpeg_dest = r'C:\Jogos\ProjectIgnis\pics'


for filename in os.listdir(jpeg_source):
    if filename.lower().endswith('.jpg'):
        src_path = os.path.join(jpeg_source, filename)
        dst_path = os.path.join(jpeg_dest, filename)
        shutil.copy2(src_path, dst_path)
        print(f'Copied JPG: {filename}')

print('All files copied successfully.')
