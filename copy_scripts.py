import os
import shutil
import sys

lua_dest = r'C:\Jogos\ProjectIgnis\script\unofficial'
jpeg_dest = r'C:\Jogos\ProjectIgnis\pics'
cdb_dest = r'C:\Jogos\ProjectIgnis\expansions'


def copy_files(source_dir, dest_dir, file_extension, file_type):
    """
    Copies files from source_dir to dest_dir with the specified file_extension.
    Prints the filenames being copied.
    
    :param source_dir: The source directory where the files are located.
    :param dest_dir: The destination directory to copy the files to.
    :param file_extension: The file extension to filter by (e.g. '.lua', '.jpg', '.cdb').
    :param file_type: Type of the file (e.g. 'LUA', 'JPG', 'CDB') for printing.
    """
    # Check if source directory exists
    if not os.path.exists(source_dir):
        print(f"Source directory '{source_dir}' does not exist.")
        return
    
    # Ensure destination directory exists, create it if not
    if not os.path.exists(dest_dir):
        os.makedirs(dest_dir)
    
    # Loop through the source directory and copy matching files
    for filename in os.listdir(source_dir):
        if filename.lower().endswith(file_extension):
            src_path = os.path.join(source_dir, filename)
            dst_path = os.path.join(dest_dir, filename)
            shutil.copy2(src_path, dst_path)
            print(f'Copied {file_type}: {filename}')

def main(folder_name=None):
    # If folder_name is provided, use that as base folder
    if folder_name:
        # Define paths using the provided folder name

        lua_source = os.path.join(folder_name, 'scripts')
        jpeg_source = os.path.join(folder_name, 'images')
        cdb_source = os.path.join(folder_name, 'expansions')

        # Call the copy_files function for each file type
        copy_files(lua_source, lua_dest, '.lua', 'LUA')
        copy_files(jpeg_source, jpeg_dest, '.jpg', 'JPG')
        copy_files(cdb_source, cdb_dest, '.cdb', 'CDB')

    else:
        # If no folder_name is passed, use default folder paths
        print("No folder name provided. Please pass a folder name.")
        # You can handle default or interactive folder input here if desired.

if __name__ == "__main__":
    # Check if a folder name was passed as a command-line argument
    if len(sys.argv) > 1:
        folder_name = sys.argv[1]  # Use the first argument as the folder name
        main(folder_name)
    else:
        # No folder name passed, list all folders in the current directory
        current_dir = os.getcwd()
        print(f"Listing all folders in the current directory: {current_dir}")

        # Get all folders (directories) in the current directory
        folders = [f for f in os.listdir(current_dir) if os.path.isdir(os.path.join(current_dir, f)) and not f.startswith('.')]

        # Call main() for each folder
        if folders:
            for folder in folders:
                print(f"Copying files for folder: {folder}")  # Print the message before processing the folder
                main(folder)
        else:
            print("No folders found in the current directory.")
