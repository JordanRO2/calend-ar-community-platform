import os
import shutil

def collect_dart_files_with_cleaned_comments(source_directory, destination_directory):
    """
    Collect all .dart files from subfolders of source_directory, ensure no initial comment exists,
    prepend a relative path comment to each, and copy them to destination_directory.

    :param source_directory: The root directory to search for .dart files.
    :param destination_directory: The directory where .dart files will be copied.
    """
    # Ensure destination directory exists
    os.makedirs(destination_directory, exist_ok=True)

    # Walk through the source directory
    for root, _, files in os.walk(source_directory):
        for file in files:
            if file.endswith('.dart'):
                source_file_path = os.path.join(root, file)
                relative_path = os.path.relpath(source_file_path, start=source_directory)
                destination_file_path = os.path.join(destination_directory, file)

                # Handle duplicate filenames by appending an index
                base_name, extension = os.path.splitext(file)
                counter = 1
                while os.path.exists(destination_file_path):
                    destination_file_path = os.path.join(
                        destination_directory, f"{base_name}_{counter}{extension}"
                    )
                    counter += 1

                # Read the original file and clean existing comments
                with open(source_file_path, 'r', encoding='utf-8') as src_file:
                    original_lines = src_file.readlines()

                # Remove the initial comment if it exists
                cleaned_lines = []
                for line in original_lines:
                    stripped_line = line.strip()
                    # Check if the line is a comment and is at the top of the file
                    if not stripped_line.startswith("//") or len(cleaned_lines) > 0:
                        cleaned_lines.append(line)

                # Add the new relative path comment
                modified_content = f"// relative path: {relative_path}\n\n" + "".join(cleaned_lines)

                # Write the modified content to the destination file
                with open(destination_file_path, 'w', encoding='utf-8') as dest_file:
                    dest_file.write(modified_content)

                print(f"Copied with relative path: {source_file_path} -> {destination_file_path}")

# Example usage
source_dir = input("Enter the source directory: ")  # E.g., "/path/to/source"
destination_dir = input("Enter the destination directory: ")  # E.g., "/path/to/all_files"

collect_dart_files_with_cleaned_comments(source_dir, destination_dir)
