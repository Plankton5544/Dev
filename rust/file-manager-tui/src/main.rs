use std::fs;                    // Like #include for file operations
use std::env;                   // Environment functions

fn main() {
    println!("File Manager Starting...");

    let current_dir = env::current_dir().unwrap();

    // Read directory contents
    if let Ok(entries) = fs::read_dir(current_dir) {
        for entry in entries {
            if let Ok(entry) = entry {
                println!("{}", entry.file_name().to_string_lossy());
            }
        }
    }

}
